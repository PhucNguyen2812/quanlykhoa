
package edu.kcntt.quanlykhoa.controller;

import edu.kcntt.quanlykhoa.entity.MaMoiNhom;
import edu.kcntt.quanlykhoa.repository.NguoiDungRepository;
import edu.kcntt.quanlykhoa.service.MaMoiService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/ma-moi")
public class MaMoiController {

    private final MaMoiService service;
    private final NguoiDungRepository nguoiDungRepo;

    public MaMoiController(MaMoiService service, NguoiDungRepository nguoiDungRepo) {
        this.service = service;
        this.nguoiDungRepo = nguoiDungRepo;
    }

    /** Tạo mã mời cho một nhóm (TBM/TK hoặc chủ nhóm sử dụng) */
    @PostMapping("/{lopId}")
    public MaMoiNhom taoMaMoi(@PathVariable UUID lopId,
                               @RequestBody Map<String,Object> body,
                               Authentication auth) {
        if (auth == null) throw new RuntimeException("Chưa đăng nhập");
        var nguoi = nguoiDungRepo.findByEmailIgnoreCase(auth.getName()).orElseThrow();

        OffsetDateTime expires = OffsetDateTime.parse((String) body.get("expiresAt"));
        int maxUses = body.get("maxUses") == null ? 10 : ((Number) body.get("maxUses")).intValue();
        String moTa = (String) body.getOrDefault("moTa", "");
        return service.taoMaMoi(lopId, nguoi, expires, maxUses, moTa);
    }

    /** Tham gia nhóm bằng mã mời */
    @PostMapping("/redeem")
    public void redeem(@RequestBody Map<String,String> body, Authentication auth) {
        if (auth == null) throw new RuntimeException("Chưa đăng nhập");
        var nguoi = nguoiDungRepo.findByEmailIgnoreCase(auth.getName()).orElseThrow();
        service.redeem(nguoi.getId(), body.get("code"));
    }

    /** Lấy (hoặc tạo mới mặc định) mã mời hiện tại của nhóm */
    @GetMapping("/current/{lopId}")
    public MaMoiNhom current(@PathVariable UUID lopId, Authentication auth) {
        if (auth == null) throw new RuntimeException("Chưa đăng nhập");
        var nguoi = nguoiDungRepo.findByEmailIgnoreCase(auth.getName()).orElseThrow();
        var existing = service.findLatestActive(lopId);
        if (existing != null) return existing;
        return service.taoMaMoi(lopId, nguoi, OffsetDateTime.now().plusDays(7), 100, "auto");
    }
}
