package edu.kcntt.quanlykhoa.dto;

import edu.kcntt.quanlykhoa.entity.enums.VaiTro;

public record NguoidungUpdateReq(
  String hoTen,
  VaiTro vaiTro,
  Long bophanId
) {}
