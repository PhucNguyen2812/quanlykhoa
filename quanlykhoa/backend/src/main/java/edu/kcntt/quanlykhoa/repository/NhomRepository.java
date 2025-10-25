package edu.kcntt.quanlykhoa.repository;

import edu.kcntt.quanlykhoa.entity.Nhom;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface NhomRepository extends JpaRepository<Nhom, UUID> {
    boolean existsByMaLop(String maLop);
}
