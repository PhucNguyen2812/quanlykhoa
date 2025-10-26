package edu.kcntt.quanlykhoa.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.*;

import edu.kcntt.quanlykhoa.repository.NguoiDungRepository;
import edu.kcntt.quanlykhoa.service.NhomService;

@RestController
@RequiredArgsConstructor
public class Nhom {

    private final NhomService nhomService;
    private final NguoiDungRepository nguoiDungRepository;

 
    private UUID currentUserId() {
    var auth = SecurityContextHolder.getContext().getAuthentication();
    if (auth == null || !auth.isAuthenticated()) {
        throw new RuntimeException("Chưa xác thực");
    }

    // Spring luôn set getName() = username (thường là email) của user đã xác thực
    String username = auth.getName(); // ví dụ: tk@gv.edu.vn

    return nguoiDungRepository.findByEmailIgnoreCase(username)
            .map(ng -> ng.getId())
            .orElseThrow(() -> new RuntimeException("Không tìm thấy user: " + username));
}


    @GetMapping("/api/nhom")
    public List<Map<String, Object>> listMyGroups() {
        UUID uid = currentUserId();
        return nhomService.listMyGroups(uid);
    }

}
