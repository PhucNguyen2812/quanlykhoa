package edu.kcntt.quanlykhoa.dto;

public class LoginResponse {
    private String token;
    private UserView user;

    public LoginResponse(String token, UserView user) {
        this.token = token; this.user = user;
    }
    public String getToken() { return token; }
    public UserView getUser() { return user; }
}
