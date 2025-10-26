package edu.kcntt.quanlykhoa.entity;

import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "nhom")
public class Nhom {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "ma_nhom", nullable = false, unique = true)
    private String MaNhom;

    @Column(name = "ten_nhom", nullable = false)
    private String tenNhom;

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


    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getMaNhom() { return MaNhom; }
    public void setMaNhom(String MaNhom) { this.MaNhom = MaNhom; }
    public String gettenNhom() { return tenNhom; }
    public void settenNhom(String tenNhom) { this.tenNhom = tenNhom; }
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

}
