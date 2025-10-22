package edu.kcntt.quanlykhoa.dto;

import edu.kcntt.quanlykhoa.entity.enums.TrangThaiNguoiDung;
import jakarta.validation.constraints.NotNull;

public record CapNhatTrangThaiReq(@NotNull TrangThaiNguoiDung trangThai) {}
