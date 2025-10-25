package edu.kcntt.quanlykhoa.service;

import edu.kcntt.quanlykhoa.dto.AuthDtos.*;
import edu.kcntt.quanlykhoa.entity.NguoiDung;
import edu.kcntt.quanlykhoa.exception.BusinessException;
import edu.kcntt.quanlykhoa.repository.NguoiDungRepository;
import edu.kcntt.quanlykhoa.security.JwtUtil;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class AuthService {

    private static final String EDU_DOMAIN = "@gv.edu.vn";

    private final NguoiDungRepository repo;
    private final BCryptPasswordEncoder encoder;
    private final JwtUtil jwt;

    public AuthService(NguoiDungRepository repo, BCryptPasswordEncoder encoder, JwtUtil jwt) {
        this.repo = repo;
        this.encoder = encoder;
        this.jwt = jwt;
    }

    private void validateEduEmail(String email) {
        if (email == null || !email.toLowerCase().endsWith(EDU_DOMAIN))
            throw new BusinessException("Email phải có đuôi " + EDU_DOMAIN);
    }

    public AuthResponse register(RegisterRequest req) {
        String email = req.email() == null ? null : req.email().trim().toLowerCase();
        validateEduEmail(email);
        if (repo.existsByEmailIgnoreCase(email))
            throw new BusinessException("Email đã tồn tại.");

        // Chỉ cho đăng ký vai trò GV
        var u = new NguoiDung();
        u.setEmail(email);
        u.setHoTen(req.hoTen());
        u.setVaiTro(NguoiDung.VaiTro.GV);
        u.setDonViId(null); // có thể cập nhật sau khi vào bộ môn
        u.setMatKhauBam(encoder.encode(req.password())); // thêm setter trong entity nếu chưa có
        // Nếu entity hiện tại chưa có setter cho mat_khau_bam -> thêm vào (xem lưu ý cuối)

        var saved = repo.save(u);
        String token = jwt.generate(saved.getEmail(), Map.of(
                "uid", saved.getId().toString(),
                "name", saved.getHoTen(),
                "role", saved.getVaiTro().name()
        ));
        return new AuthResponse(token, new UserView(saved.getId().toString(), saved.getEmail(), saved.getHoTen(), saved.getVaiTro().name()));
    }

    public AuthResponse login(LoginRequest req) {
        String email = req.email() == null ? null : req.email().trim().toLowerCase();
        validateEduEmail(email);
        var u = repo.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new BusinessException("Tài khoản hoặc mật khẩu không đúng."));

        if (!encoder.matches(req.password(), u.getMatKhauBam()))
            throw new BusinessException("Tài khoản hoặc mật khẩu không đúng.");

        String token = jwt.generate(u.getEmail(), Map.of(
                "uid", u.getId().toString(),
                "name", u.getHoTen(),
                "role", u.getVaiTro().name()
        ));
        return new AuthResponse(token, new UserView(u.getId().toString(), u.getEmail(), u.getHoTen(), u.getVaiTro().name()));
    }
}
