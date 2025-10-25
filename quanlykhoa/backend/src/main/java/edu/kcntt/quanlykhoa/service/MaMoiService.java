package edu.kcntt.quanlykhoa.service;

import edu.kcntt.quanlykhoa.entity.MaMoiNhom;
import edu.kcntt.quanlykhoa.entity.NguoiDung;
import edu.kcntt.quanlykhoa.exception.BusinessException;
import edu.kcntt.quanlykhoa.repository.MaMoiRepository;
import edu.kcntt.quanlykhoa.repository.NhomRepository;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.PreparedStatementCallback;
import org.springframework.jdbc.core.PreparedStatementCreator;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.OffsetDateTime;
import java.util.UUID;

@Service
public class MaMoiService {

    private final MaMoiRepository maMoiRepo;
    private final NhomRepository nhomRepo;
    private final JdbcTemplate jdbc;

    public MaMoiService(MaMoiRepository maMoiRepo, NhomRepository nhomRepo, JdbcTemplate jdbc) {
        this.maMoiRepo = maMoiRepo;
        this.nhomRepo = nhomRepo;
        this.jdbc = jdbc;
    }

    private static final String ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final SecureRandom R = new SecureRandom();

    private String genCode() {
        StringBuilder sb = new StringBuilder(8);
        for (int i = 0; i < 8; i++) sb.append(ALPHABET.charAt(R.nextInt(ALPHABET.length())));
        return sb.toString();
    }

    public MaMoiNhom taoMaMoi(UUID lopId, NguoiDung nguoi, OffsetDateTime expiresAt, int maxUses, String moTa) {
        if (nguoi.getVaiTro() == NguoiDung.VaiTro.GV)
            throw new BusinessException("Giảng viên không được tạo mã mời.");

        nhomRepo.findById(lopId).orElseThrow(() -> new BusinessException("Không tìm thấy lớp."));

        String code;
        do { code = genCode(); } while (maMoiRepo.existsByCode(code));

        MaMoiNhom m = new MaMoiNhom();
        m.setLopId(lopId);
        m.setCode(code);
        m.setExpiresAt(expiresAt);
        m.setMaxUses(maxUses);
        m.setUsedCount(0);
        m.setMoTa(moTa);
        m.setBat(true);
        m.setCreatedBy(nguoi.getId());
        m.setCreatedAt(OffsetDateTime.now());
        return maMoiRepo.save(m);
    }

    /** Gọi function Postgres redeem_invite(user_id, code) */
    public void redeem(UUID userId, String code) {
        jdbc.execute(
            (PreparedStatementCreator) con -> {
                var ps = con.prepareStatement("SELECT redeem_invite(?, ?)");
                ps.setObject(1, userId);
                ps.setString(2, code);
                return ps;
            },
            (PreparedStatementCallback<Void>) ps -> {
                ps.execute();
                return null;
            }
        );
    }
}
