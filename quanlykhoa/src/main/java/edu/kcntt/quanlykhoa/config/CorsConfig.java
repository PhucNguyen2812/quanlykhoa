package com.phuc.quanlykhoa.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
public class CorsConfig {

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        // Cho phép FE React (port 5173) gọi sang BE (port 8080)
        config.setAllowedOrigins(List.of("http://localhost:5173"));
        // Cho phép các phương thức HTTP này
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        // Cho phép các header gửi kèm
        config.setAllowedHeaders(List.of("Authorization", "Content-Type"));
        // Cho phép cookie hoặc token kèm theo (nếu dùng)
        config.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
