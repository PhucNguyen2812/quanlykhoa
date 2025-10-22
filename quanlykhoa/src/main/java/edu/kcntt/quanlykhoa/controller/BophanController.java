package edu.kcntt.quanlykhoa.controller;

import edu.kcntt.quanlykhoa.entity.Bophan;
import edu.kcntt.quanlykhoa.service.BophanService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/bophan")
@RequiredArgsConstructor
public class BophanController {
  private final BophanService service;

  @GetMapping public List<Bophan> list(){ return service.list(); }

  @PostMapping public ResponseEntity<Bophan> create(@RequestBody Bophan req){
    return ResponseEntity.ok(service.create(req));
  }

  @PutMapping("/{id}") public ResponseEntity<Bophan> update(@PathVariable Long id, @RequestBody Bophan req){
    return ResponseEntity.ok(service.update(id, req));
  }

  @DeleteMapping("/{id}") public ResponseEntity<Void> delete(@PathVariable Long id){
    service.delete(id);
    return ResponseEntity.noContent().build();
  }
}
