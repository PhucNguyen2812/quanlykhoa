package edu.kcntt.quanlykhoa.entity;

import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "lop_hoc")
public class Nhom {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "ma_lop", nullable = false, unique = true)
    private String maLop;

    @Column(name = "ten_lop", nullable = false)
    private String tenLop;

    @Column(name = "nam_hoc", nullable = false)
    private String namHoc;

    @Column(name = "don_vi_id")
    private UUID donViId;

    @Column(name = "nguoi_so_huu_id")
    private UUID nguoiSoHuuId;

    @Column(name = "mo_ta")
    private String moTa;

    @Column(name = "anh_bia_url")
    private String anhBiaUrl;

    @Column(name = "luu_tru")
    private boolean luuTru;

    @Column(name = "created_at")
    private OffsetDateTime createdAt;

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getMaLop() { return maLop; }
    public void setMaLop(String maLop) { this.maLop = maLop; }
    public String getTenLop() { return tenLop; }
    public void setTenLop(String tenLop) { this.tenLop = tenLop; }
    public String getNamHoc() { return namHoc; }
    public void setNamHoc(String namHoc) { this.namHoc = namHoc; }
    public UUID getDonViId() { return donViId; }
    public void setDonViId(UUID donViId) { this.donViId = donViId; }
    public UUID getNguoiSoHuuId() { return nguoiSoHuuId; }
    public void setNguoiSoHuuId(UUID nguoiSoHuuId) { this.nguoiSoHuuId = nguoiSoHuuId; }
    public String getMoTa() { return moTa; }
    public void setMoTa(String moTa) { this.moTa = moTa; }
    public String getAnhBiaUrl() { return anhBiaUrl; }
    public void setAnhBiaUrl(String anhBiaUrl) { this.anhBiaUrl = anhBiaUrl; }
    public boolean isLuuTru() { return luuTru; }
    public void setLuuTru(boolean luuTru) { this.luuTru = luuTru; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}
