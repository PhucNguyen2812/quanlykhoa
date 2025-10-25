package edu.kcntt.quanlykhoa.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * Filter JWT tạm thời (chưa kiểm tra token).
 * Mục đích hiện tại: không chặn /api/auth/** để FE có thể đăng ký/đăng nhập.
 * Khi triển khai JWT thực, thay phần thân class này bằng logic verify token.
 */
@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain) throws ServletException, IOException {

        String path = request.getServletPath();

        // BỎ QUA cho auth + error
        if (path.startsWith("/api/auth/") || "/error".equals(path)) {
            filterChain.doFilter(request, response);
            return;
        }

        // Hiện tại cho qua luôn (chưa xác thực JWT)
        filterChain.doFilter(request, response);
    }
}
