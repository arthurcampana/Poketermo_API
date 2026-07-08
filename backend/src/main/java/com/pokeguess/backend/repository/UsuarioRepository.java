package com.pokeguess.backend.repository;

import com.pokeguess.backend.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    // Método customizado para buscar um usuário pelo nome no banco
    Optional<Usuario> findByUsername(String username);
}