package edu.kcntt.quanlykhoa.service;

import edu.kcntt.quanlykhoa.entity.Bophan;
import edu.kcntt.quanlykhoa.repository.BophanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service @RequiredArgsConstructor
public class BophanService {
  private final BophanRepository repo;

  public List<Bophan> list(){ return repo.findAll(); }

  @Transactional
  public Bophan create(Bophan b){ return repo.save(b); }

  @Transactional
  public Bophan update(Long id, Bophan in){
    Bophan b = repo.findById(id).orElseThrow();
    b.setTenBophan(in.getTenBophan());
    b.setLoaiBophan(in.getLoaiBophan());
    b.setBophanCha(in.getBophanCha());
    return repo.save(b);
  }

  public void delete(Long id){ repo.deleteById(id); }
}
