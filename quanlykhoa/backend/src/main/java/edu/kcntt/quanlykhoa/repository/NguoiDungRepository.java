package edu.kcntt.quanlykhoa.repository;

import edu.kcntt.quanlykhoa.entity.NguoiDung;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface NguoiDungRepository extends JpaRepository<NguoiDung, UUID> {
    Optional<NguoiDung> findByEmailIgnoreCase(String email);
    boolean existsByEmailIgnoreCase(String email);
}
