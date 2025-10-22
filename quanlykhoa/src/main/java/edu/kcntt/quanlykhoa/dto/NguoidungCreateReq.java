package edu.kcntt.quanlykhoa.dto;

import edu.kcntt.quanlykhoa.entity.enums.VaiTro;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record NguoidungCreateReq(
  @NotBlank String tenDangNhap,
  @NotBlank String matKhauMaHoa, // tạm thời nhận chuỗi đã mã hoá
  @NotBlank String hoTen,
  @NotNull  VaiTro vaiTro,
  Long bophanId
) {}
