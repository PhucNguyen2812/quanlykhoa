package edu.kcntt.quanlykhoa.service;

import edu.kcntt.quanlykhoa.entity.NguoiDung;
import edu.kcntt.quanlykhoa.entity.Nhom;
import edu.kcntt.quanlykhoa.exception.BusinessException;
import edu.kcntt.quanlykhoa.repository.NhomRepository;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.UUID;

@Service
public class NhomService {

    private final NhomRepository repo;

    public NhomService(NhomRepository repo) { this.repo = repo; }

    public Nhom taoNhom(NguoiDung nguoi, String maLop, String tenLop, String namHoc, UUID donViId, String moTa) {
        if (nguoi.getVaiTro() == NguoiDung.VaiTro.GV)
            throw new BusinessException("Giảng viên không được tạo lớp.");

        if (repo.existsByMaLop(maLop))
            throw new BusinessException("Mã lớp đã tồn tại.");

        Nhom nhom = new Nhom();
        nhom.setMaLop(maLop.trim());
        nhom.setTenLop(tenLop.trim());
        nhom.setNamHoc(namHoc);
        nhom.setDonViId(donViId);
        nhom.setNguoiSoHuuId(nguoi.getId());
        nhom.setMoTa(moTa);
        nhom.setCreatedAt(OffsetDateTime.now());
        return repo.save(nhom);
    }
}
