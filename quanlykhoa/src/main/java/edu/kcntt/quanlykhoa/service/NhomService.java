package edu.kcntt.quanlykhoa.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import edu.kcntt.quanlykhoa.repository.NhomRepository;

@Service
@RequiredArgsConstructor
public class NhomService {

    private final NhomRepository nhomRepository;

    /**
     * Danh sách nhóm do người dùng hiện tại sở hữu.
     * @param userId id người dùng đang đăng nhập
     */
    public List<Map<String, Object>> listMyGroups(UUID userId) {
        return nhomRepository.listByOwner(userId);
    }

    // các hàm hiện có (tạo nhóm, tham gia nhóm, v.v.) — giữ nguyên, không chỉnh sửa
}
