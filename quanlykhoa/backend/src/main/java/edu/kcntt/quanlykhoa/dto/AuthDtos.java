package edu.kcntt.quanlykhoa.dto;

public class AuthDtos {
    public record RegisterRequest(String hoTen, String email, String password) {}
    public record LoginRequest(String email, String password) {}
    public record UserView(String id, String email, String hoTen, String vaiTro) {}
    public record AuthResponse(String token, UserView user) {}
}
