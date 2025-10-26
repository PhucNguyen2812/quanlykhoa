
package edu.kcntt.quanlykhoa.security;

import edu.kcntt.quanlykhoa.repository.NguoiDungRepository;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtUtil jwt;
    private final NguoiDungRepository repo;

    public JwtAuthFilter(JwtUtil jwt, NguoiDungRepository repo) {
        this.jwt = jwt;
        this.repo = repo;
    }

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request,
                                    @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain) throws ServletException, IOException {

        String path = request.getServletPath();
        if (path.startsWith("/api/auth/") || "/error".equals(path)) {
            filterChain.doFilter(request, response);
            return;
        }

        String auth = Optional.ofNullable(request.getHeader("Authorization")).orElse("").trim();
        if (auth.startsWith("Bearer ")) {
            String token = auth.substring(7);
            try {
                Jws<Claims> jws = jwt.parse(token);
                String email = jws.getBody().getSubject();
                String role = String.valueOf(jws.getBody().get("role"));
                var userOpt = repo.findByEmailIgnoreCase(email);
                if (userOpt.isPresent()) {
                    var authToken = new UsernamePasswordAuthenticationToken(
                            email,
                            null,
                            List.of(new SimpleGrantedAuthority("ROLE_" + role))
                    );
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            } catch (Exception ex) {
                // invalid token -> no auth set; downstream SecurityConfig will block
            }
        }

        filterChain.doFilter(request, response);
    }
}
