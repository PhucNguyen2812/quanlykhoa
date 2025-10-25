package edu.kcntt.quanlykhoa.repository;

import edu.kcntt.quanlykhoa.entity.MaMoiNhom;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface MaMoiRepository extends JpaRepository<MaMoiNhom, UUID> {
    Optional<MaMoiNhom> findByCode(String code);
    boolean existsByCode(String code);
}
