package com.pokeguess.controller;

import com.pokeguess.backend.model.Usuario;
import com.pokeguess.repository.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*") // Permite que o Flutter acione o backend sem bloqueios de segurança locais
public class AuthController {

    private final UsuarioRepository usuarioRepository;

    // Injeção de dependência via construtor
    public AuthController(UsuarioRepository usuarioRepository) {
        this.usuarioRepository = usuarioRepository;
    }

    @PostMapping("/cadastro")
    public ResponseEntity<String> cadastrar(@RequestBody Usuario usuario) {
        // Verifica se o nome de usuário já está tomado
        if (usuarioRepository.findByUsername(usuario.getUsername()).isPresent()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Usuário já cadastrado!");
        }
        
        // Salva o usuário diretamente no banco
        usuarioRepository.save(usuario);
        return ResponseEntity.status(HttpStatus.CREATED).body("Usuário registrado com sucesso!");
    }

    @PostMapping("/login")
    public ResponseEntity<String> login(@RequestBody Usuario usuario) {
        Optional<Usuario> usuarioBanco = usuarioRepository.findByUsername(usuario.getUsername());

        // Valida se o usuário existe e se a senha coincide
        if (usuarioBanco.isPresent() && usuarioBanco.get().getPassword().equals(usuario.getPassword())) {
            return ResponseEntity.ok("Login bem-sucedido!");
        }

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Credenciais inválidas!");
    }
}