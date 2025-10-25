package edu.kcntt.quanlykhoa.dto;

import java.util.UUID;

public class UserView {
    private UUID id;
    private String email;
    private String hoTen;
    private String vaiTro; // để FE hiển thị, có thể null

    public UserView(UUID id, String email, String hoTen, String vaiTro) {
        this.id = id; this.email = email; this.hoTen = hoTen; this.vaiTro = vaiTro;
    }
    public UUID getId() { return id; }
    public String getEmail() { return email; }
    public String getHoTen() { return hoTen; }
    public String getVaiTro() { return vaiTro; }
}
