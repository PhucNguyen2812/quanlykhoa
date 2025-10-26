package edu.kcntt.quanlykhoa.repository;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

// ĐỔI TÊN ENTITY NẾU CẦN: Nhom / LopHoc / NhomEntity ...
import edu.kcntt.quanlykhoa.entity.Nhom;

public interface NhomRepository extends JpaRepository<Nhom, UUID> {

    @Query(value = """
        select id, ma_nhom, ten_nhom, mo_ta
        from nhom
        where nguoi_so_huu_id = :uid
        order by ten_nhom asc
        """, nativeQuery = true)
    List<Map<String, Object>> listByOwner(@Param("uid") UUID uid);
}
