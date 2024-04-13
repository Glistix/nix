import gleeunit
import glistix/nix

pub fn main() {
  gleeunit.main()
}

pub fn deep_eval_test() {
  nix.deep_eval([1, 2, 3])

  10
}
