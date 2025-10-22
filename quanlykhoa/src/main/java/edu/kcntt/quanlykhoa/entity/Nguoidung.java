package edu.kcntt.quanlykhoa.entity;

import edu.kcntt.quanlykhoa.entity.enums.TrangThaiNguoiDung;
import edu.kcntt.quanlykhoa.entity.enums.VaiTro;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(
    name = "nguoidung",
    uniqueConstraints = @UniqueConstraint(name = "uk_nguoidung_tendangnhap", columnNames = "tendangnhap")
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Nguoidung {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name="tendangnhap", nullable=false, length=100)
    private String tenDangNhap;

    @Column(name="matkhaumahoa", nullable=false, length=255)
    private String matKhauMaHoa; // tạm nhận chuỗi đã mã hoá

    @Column(name="hoten", nullable=false, length=200)
    private String hoTen;

    @Enumerated(EnumType.STRING)
    @Column(name="vaitro", nullable=false, length=20)
    private VaiTro vaiTro; // {truongkhoa,truongbomon,giangvien}

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="bophanid", foreignKey=@ForeignKey(name="nguoidung_bophanid_fkey"))
    private Bophan bophan; // nullable, ON DELETE SET NULL

    @Enumerated(EnumType.STRING)
    @Column(name="trangthai", nullable=false, length=20)
    @Builder.Default
    private TrangThaiNguoiDung trangThai = TrangThaiNguoiDung.active; // default 'active'

    @Column(name="ngaytao", nullable=false)
    @Builder.Default
    private LocalDateTime ngayTao = LocalDateTime.now();
}
