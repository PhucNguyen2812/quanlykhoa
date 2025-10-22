package edu.kcntt.quanlykhoa.repository;

import edu.kcntt.quanlykhoa.entity.Nguoidung;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface NguoidungRepository extends JpaRepository<Nguoidung, Long> {
  Optional<Nguoidung> findByTenDangNhap(String tenDangNhap);
}
