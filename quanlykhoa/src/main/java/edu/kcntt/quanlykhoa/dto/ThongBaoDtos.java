
package edu.kcntt.quanlykhoa.dto;

import java.time.OffsetDateTime;

public class ThongBaoDtos {
    public record ThongBaoView(
            String id,
            String tieuDe,
            String noiDung,
            OffsetDateTime hanNop,
            OffsetDateTime createdAt,
            String nguoiDangId,
            int soTep
    ) {}
    public record TepMeta(
            String id,
            String tenTapTin,
            long kichThuoc
    ) {}
}
