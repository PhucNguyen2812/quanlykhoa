
package edu.kcntt.quanlykhoa.controller;

import edu.kcntt.quanlykhoa.dto.ThongBaoDtos.ThongBaoView;
import edu.kcntt.quanlykhoa.service.ThongBaoService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api")
public class ThongBaoController {

    private final ThongBaoService service;

    public ThongBaoController(ThongBaoService service) {
        this.service = service;
    }

    @GetMapping("/nhom/{nhomId}/thong-bao")
    public List<ThongBaoView> list(@PathVariable UUID nhomId) {
        return service.listByGroup(nhomId);
    }

    @PostMapping(value = "/nhom/{nhomId}/thong-bao", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ThongBaoView create(@PathVariable UUID nhomId,
                               @RequestPart("tieuDe") String tieuDe,
                               @RequestPart(value = "noiDung", required = false) String noiDung,
                               @RequestPart(value = "hanNop", required = false) String hanNopIso,
                               @RequestPart(value = "files", required = false) List<MultipartFile> files,
                               Authentication auth) throws IOException {
        if (auth == null) throw new RuntimeException("Chưa đăng nhập");
        OffsetDateTime hanNop = null;
        if (hanNopIso != null && !hanNopIso.isBlank()) {
            hanNop = OffsetDateTime.parse(hanNopIso);
        }
        return service.create(nhomId, auth.getName(), tieuDe, noiDung, hanNop, files);
    }

    @GetMapping("/tep/{tepId}")
    public ResponseEntity<byte[]> download(@PathVariable UUID tepId) {
        var f = service.getFile(tepId);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(f.contentType() == null ? "application/octet-stream" : f.contentType()))
                .header("Content-Disposition", "attachment; filename=\"" + f.fileName() + "\"")
                .contentLength(f.bytes().length)
                .body(f.bytes());
    }
}
