package edu.kcntt.quanlykhoa.web;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class SpaController {
  @GetMapping({"/{path:[^\\.]*}", "/**/{path:^(?!api).*$}"})
  public String forward() { return "forward:/index.html"; }
}
