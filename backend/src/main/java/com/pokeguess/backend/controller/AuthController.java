package com.pokeguess.controller;

import com.example.demo.model.Usuario;
import com.pokeguess.repository.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*") 
public class AuthController {

    private final UsuarioRepository usuarioRepository;

    public AuthController(UsuarioRepository usuarioRepository) {
        this.usuarioRepository = usuarioRepository;
    }

    @PostMapping("/cadastro")
    public ResponseEntity<String> cadastrar(@RequestBody Usuario usuario) {
        if (usuarioRepository.findByUsername(usuario.getUsername()).isPresent()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Usuário já cadastrado!");
        }
        
        usuario.setWins(0); // Garante que comece com 0
        usuarioRepository.save(usuario);
        return ResponseEntity.status(HttpStatus.CREATED).body("Usuário registrado com sucesso!");
    }

    @PostMapping("/login")
    public ResponseEntity<Usuario> login(@RequestBody Usuario usuario) {
        Optional<Usuario> usuarioBanco = usuarioRepository.findByUsername(usuario.getUsername());

        if (usuarioBanco.isPresent() && usuarioBanco.get().getPassword().equals(usuario.getPassword())) {
            // Retorna o objeto inteiro do usuário (com a quantidade de vitórias)
            return ResponseEntity.ok(usuarioBanco.get());
        }

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }

    @PutMapping("/vitoria/{username}")
    public ResponseEntity<String> registrarVitoria(@PathVariable String username) {
        Optional<Usuario> usuarioBanco = usuarioRepository.findByUsername(username);

        if (usuarioBanco.isPresent()) {
            Usuario u = usuarioBanco.get();
            u.setWins(u.getWins() + 1);
            usuarioRepository.save(u); // Atualiza no banco
            return ResponseEntity.ok("Vitória registrada!");
        }

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Usuário não encontrado.");
    }
}