package edu.kcntt.quanlykhoa.service;

import edu.kcntt.quanlykhoa.dto.CapNhatTrangThaiReq;
import edu.kcntt.quanlykhoa.dto.NguoidungCreateReq;
import edu.kcntt.quanlykhoa.dto.NguoidungUpdateReq;
import edu.kcntt.quanlykhoa.entity.Bophan;
import edu.kcntt.quanlykhoa.entity.Nguoidung;
import edu.kcntt.quanlykhoa.entity.enums.TrangThaiNguoiDung;
import edu.kcntt.quanlykhoa.repository.BophanRepository;
import edu.kcntt.quanlykhoa.repository.NguoidungRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service @RequiredArgsConstructor
public class NguoidungService {
  private final NguoidungRepository repo;
  private final BophanRepository bophanRepo;

  public List<Nguoidung> list(){ return repo.findAll(); }

  public Nguoidung get(Long id){ return repo.findById(id).orElseThrow(); }

  @Transactional
  public Nguoidung create(NguoidungCreateReq req){
    Bophan bp = (req.bophanId() != null) ? bophanRepo.findById(req.bophanId()).orElse(null) : null;

    Nguoidung u = Nguoidung.builder()
        .tenDangNhap(req.tenDangNhap())
        .matKhauMaHoa(req.matKhauMaHoa())
        .hoTen(req.hoTen())
        .vaiTro(req.vaiTro())
        .bophan(bp)
        .trangThai(TrangThaiNguoiDung.active)
        .build();
    return repo.save(u);
  }

  @Transactional
  public Nguoidung update(Long id, NguoidungUpdateReq req){
    Nguoidung u = repo.findById(id).orElseThrow();
    if (req.hoTen() != null) u.setHoTen(req.hoTen());
    if (req.vaiTro() != null) u.setVaiTro(req.vaiTro());
    if (req.bophanId() != null) {
      Bophan bp = bophanRepo.findById(req.bophanId()).orElse(null);
      u.setBophan(bp);
    }
    return repo.save(u);
  }

  // Soft delete theo trigger trong DB: không xoá cứng
  @Transactional
  public Nguoidung capNhatTrangThai(Long id, CapNhatTrangThaiReq req){
    Nguoidung u = repo.findById(id).orElseThrow();
    u.setTrangThai(req.trangThai());
    return repo.save(u);
  }
}
