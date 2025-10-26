
package edu.kcntt.quanlykhoa.service;

import edu.kcntt.quanlykhoa.dto.ThongBaoDtos.ThongBaoView;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.rowset.SqlRowSet;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class ThongBaoService {

    private final JdbcTemplate jdbc;

    public ThongBaoService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<ThongBaoView> listByGroup(UUID nhomId) {
        // dùng bảng cũ: bai_dang + tep_bai_dang
        String sql = """
            SELECT b.id, b.tieu_de, b.noi_dung, b.han_nop, b.created_at, b.nguoi_dang_id,
                   COALESCE((SELECT COUNT(1) FROM tep_bai_dang t WHERE t.bai_dang_id = b.id),0) AS so_tep
            FROM bai_dang b
            WHERE b.lop_id = ?
            ORDER BY b.created_at DESC
        """;
        return jdbc.query(sql, (rs, i) -> new ThongBaoView(
                rs.getObject("id").toString(),
                rs.getString("tieu_de"),
                rs.getString("noi_dung"),
                rs.getObject("han_nop") == null ? null : rs.getObject("han_nop", java.time.OffsetDateTime.class),
                rs.getObject("created_at", java.time.OffsetDateTime.class),
                rs.getObject("nguoi_dang_id").toString(),
                rs.getInt("so_tep")
        ), nhomId);
    }

    public record FileDto(String fileName, String contentType, long size, byte[] bytes) {}
    public record FileRow(UUID id, String fileName, String contentType, long size, byte[] bytes) {}

    public FileRow getFile(UUID id) {
        SqlRowSet rs = jdbc.queryForRowSet("SELECT id, ten_tap_tin, content_type, kich_thuoc, du_lieu FROM tep_bai_dang WHERE id = ?", id);
        if (!rs.next()) throw new RuntimeException("Không tìm thấy tệp");
        String name = rs.getString("ten_tap_tin");
        String ct = rs.getString("content_type");
        long size = rs.getLong("kich_thuoc");
        byte[] data = jdbc.queryForObject("SELECT du_lieu FROM tep_bai_dang WHERE id = ?", byte[].class, id);
        return new FileRow(id, name, ct, size, data);
    }

    @Transactional
    public ThongBaoView create(UUID nhomId, String posterEmail,
                               String tieuDe, String noiDung, OffsetDateTime hanNop,
                               List<MultipartFile> files) throws IOException {

        if (files != null && files.size() > 4) {
            throw new RuntimeException("Tối đa 4 tệp");
        }
        if (files != null) {
            long tooBig = files.stream().filter(f -> f.getSize() > 50L*1024*1024).count();
            if (tooBig > 0) throw new RuntimeException("Mỗi tệp tối đa 50MB");
        }

        // Lấy id người đăng từ email
        UUID nguoiDangId = jdbc.queryForObject("SELECT id FROM nguoi_dung WHERE lower(email)=lower(?)", UUID.class, posterEmail);

        // Insert bai_dang, dùng RETURNING
        UUID baiDangId = jdbc.queryForObject(
                "INSERT INTO bai_dang (id, lop_id, tieu_de, noi_dung, han_nop, nguoi_dang_id, created_at) VALUES (gen_random_uuid(), ?, ?, ?, ?, ?, now()) RETURNING id",
                UUID.class, nhomId, tieuDe, noiDung, hanNop, nguoiDangId);

        if (files != null) {
            for (MultipartFile f : files) {
                byte[] data = f.getBytes();
                String ct = f.getContentType();
                String name = f.getOriginalFilename();
                long size = f.getSize();
                jdbc.update("INSERT INTO tep_bai_dang (id, bai_dang_id, ten_tap_tin, du_lieu, kich_thuoc, content_type) VALUES (gen_random_uuid(), ?, ?, ?, ?, ?)",
                        baiDangId, name, data, size, ct);
            }
        }

        return jdbc.queryForObject("""
                SELECT b.id, b.tieu_de, b.noi_dung, b.han_nop, b.created_at, b.nguoi_dang_id,
                       COALESCE((SELECT COUNT(1) FROM tep_bai_dang t WHERE t.bai_dang_id = b.id),0) AS so_tep
                FROM bai_dang b WHERE b.id=?
        """, (rs, i) -> new ThongBaoView(
                rs.getObject("id").toString(),
                rs.getString("tieu_de"),
                rs.getString("noi_dung"),
                rs.getObject("han_nop") == null ? null : rs.getObject("han_nop", java.time.OffsetDateTime.class),
                rs.getObject("created_at", java.time.OffsetDateTime.class),
                rs.getObject("nguoi_dang_id").toString(),
                rs.getInt("so_tep")
        ), baiDangId);
    }
}
