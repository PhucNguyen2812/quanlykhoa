package edu.kcntt.quanlykhoa.entity;

import edu.kcntt.quanlykhoa.entity.enums.LoaiBoPhan;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "bophan")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Bophan {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(name = "tenbophan", nullable = false, length = 200)
  private String tenBophan;

  @Enumerated(EnumType.STRING)
  @Column(name = "loaibophan", nullable = false, length = 20)
  private LoaiBoPhan loaiBophan; // {khoa,bomon}

  // khoá ngoại tự tham chiếu, ON DELETE SET NULL
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "bophanchaid")
  private Bophan bophanCha;
}
