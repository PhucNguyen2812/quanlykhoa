package edu.kcntt.quanlykhoa.controller;

import edu.kcntt.quanlykhoa.entity.MaMoiNhom;
import edu.kcntt.quanlykhoa.entity.NguoiDung;
import edu.kcntt.quanlykhoa.service.MaMoiService;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/ma-moi")
public class MaMoiController {

    private final MaMoiService service;

    public MaMoiController(MaMoiService service) { this.service = service; }

    @PostMapping("/{lopId}")
    public MaMoiNhom taoMaMoi(@PathVariable UUID lopId, @RequestBody Map<String,Object> body) {
        NguoiDung mock = new NguoiDung();
        mock.setId(UUID.fromString("00000000-0000-0000-0000-000000000001"));
        mock.setVaiTro(NguoiDung.VaiTro.TBM);

        OffsetDateTime expires = OffsetDateTime.parse((String) body.get("expiresAt"));
        int maxUses = (int) body.getOrDefault("maxUses", 10);
        String moTa = (String) body.getOrDefault("moTa", "");
        return service.taoMaMoi(lopId, mock, expires, maxUses, moTa);
    }

    @PostMapping("/redeem")
    public void redeem(@RequestBody Map<String,String> body) {
        UUID gvId = UUID.fromString("00000000-0000-0000-0000-000000000002"); // mock GV
        service.redeem(gvId, body.get("code"));
    }
}
