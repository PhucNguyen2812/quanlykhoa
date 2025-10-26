
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
    private final SecureRandom rnd = new SecureRandom();

    public MaMoiService(MaMoiRepository maMoiRepo, NhomRepository nhomRepo, JdbcTemplate jdbc) {
        this.maMoiRepo = maMoiRepo;
        this.nhomRepo = nhomRepo;
        this.jdbc = jdbc;
    }

    private String randomCode() {
        String alphabet = "abcdefghijklmnopqrstuvwxyz0123456789";
        String code;
        do {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < 7; i++) sb.append(alphabet.charAt(rnd.nextInt(alphabet.length())));
            code = sb.toString();
        } while (maMoiRepo.existsByCode(code));
        return code;
    }

    public MaMoiNhom taoMaMoi(UUID lopId, NguoiDung nguoi, OffsetDateTime expiresAt, int maxUses, String moTa) {
        if (!nhomRepo.existsById(lopId)) throw new BusinessException("Nhóm không tồn tại.");
        String code = randomCode();

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

    public MaMoiNhom findLatestActive(UUID lopId) {
        return maMoiRepo.findTopByLopIdAndBatTrueOrderByCreatedAtDesc(lopId).orElse(null);
    }
}
