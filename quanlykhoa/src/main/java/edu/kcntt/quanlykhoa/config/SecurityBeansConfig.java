package edu.kcntt.quanlykhoa.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class SecurityBeansConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        // Default strength 10. Nếu cần có thể dùng new BCryptPasswordEncoder(strength).
        return new BCryptPasswordEncoder();
    }
}
