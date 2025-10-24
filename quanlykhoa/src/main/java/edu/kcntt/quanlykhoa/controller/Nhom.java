package edu.kcntt.quanlykhoa.controller;

import edu.kcntt.quanlykhoa.entity.NguoiDung;
import edu.kcntt.quanlykhoa.service.NhomService;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/nhom")
public class Nhom {

    private final NhomService service;

    public Nhom(NhomService service) { this.service = service; }

    @PostMapping
    public edu.kcntt.quanlykhoa.entity.Nhom taoNhom(@RequestBody Map<String, Object> body) {
        // TODO: thay bằng user thật sau khi tích hợp security
        NguoiDung mock = new NguoiDung();
        mock.setId(UUID.fromString("00000000-0000-0000-0000-000000000001"));
        mock.setVaiTro(NguoiDung.VaiTro.TBM);

        String maLop = (String) body.get("maLop");
        String tenLop = (String) body.get("tenLop");
        String namHoc = (String) body.get("namHoc");
        String moTa   = (String) body.getOrDefault("moTa", "");
        UUID donViId  = body.get("donViId") == null ? null : UUID.fromString((String) body.get("donViId"));

        return service.taoNhom(mock, maLop, tenLop, namHoc, donViId, moTa);
    }
}
