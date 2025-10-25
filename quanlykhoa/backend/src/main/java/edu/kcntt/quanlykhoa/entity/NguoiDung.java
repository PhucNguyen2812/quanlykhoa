package edu.kcntt.quanlykhoa.entity;

import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "nguoi_dung")
public class NguoiDung {

    public enum VaiTro { TK, TBM, GV }

    @Id
    @GeneratedValue
    private UUID id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "ho_ten", nullable = false)
    private String hoTen;

    @Enumerated(EnumType.STRING)
    @Column(name = "vai_tro", nullable = false)
    private VaiTro vaiTro;

    @Column(name = "don_vi_id")
    private UUID donViId;
    
    @Column(name = "mat_khau_bam", nullable = false)
    private String matKhauBam;

    public String getMatKhauBam() { return matKhauBam; }
    public void setMatKhauBam(String matKhauBam) { this.matKhauBam = matKhauBam; }
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getHoTen() { return hoTen; }
    public void setHoTen(String hoTen) { this.hoTen = hoTen; }
    public VaiTro getVaiTro() { return vaiTro; }
    public void setVaiTro(VaiTro vaiTro) { this.vaiTro = vaiTro; }
    public UUID getDonViId() { return donViId; }
    public void setDonViId(UUID donViId) { this.donViId = donViId; }
}
