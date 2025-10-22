package edu.kcntt.quanlykhoa.controller;

import edu.kcntt.quanlykhoa.dto.CapNhatTrangThaiReq;
import edu.kcntt.quanlykhoa.dto.NguoidungCreateReq;
import edu.kcntt.quanlykhoa.dto.NguoidungUpdateReq;
import edu.kcntt.quanlykhoa.entity.Nguoidung;
import edu.kcntt.quanlykhoa.service.NguoidungService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/nguoidung")
@RequiredArgsConstructor
public class NguoidungController {
  private final NguoidungService service;

  @GetMapping public List<Nguoidung> list(){ return service.list(); }

  @GetMapping("/{id}") public Nguoidung get(@PathVariable Long id){ return service.get(id); }

  @PostMapping public ResponseEntity<Nguoidung> create(@Valid @RequestBody NguoidungCreateReq req){
    return ResponseEntity.ok(service.create(req));
  }

  @PutMapping("/{id}") public ResponseEntity<Nguoidung> update(@PathVariable Long id, @RequestBody NguoidungUpdateReq req){
    return ResponseEntity.ok(service.update(id, req));
  }

  // Soft delete / cập nhật trạng thái: active|tamngung|xoa
  @PatchMapping("/{id}/trangthai")
  public ResponseEntity<Nguoidung> capNhatTrangThai(@PathVariable Long id, @Valid @RequestBody CapNhatTrangThaiReq req){
    return ResponseEntity.ok(service.capNhatTrangThai(id, req));
  }
}
