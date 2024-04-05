import gleeunit/should
import nix/path

pub fn local_path_test() {
  path.from_string("abc")
  |> should.equal(path.from_string("./abc"))

  path.from_string("def")
  |> path.to_string
  |> should.equal(
    path.from_string("./def")
    |> path.to_string,
  )
}

pub fn top_path_test() {
  path.from_string("../abc")
  |> should.equal(path.from_string("./../abc"))

  path.from_string("../def")
  |> path.to_string
  |> should.equal(
    path.from_string("./../def")
    |> path.to_string,
  )
}

pub fn abs_path_test() {
  path.from_string("/abs/path")
  |> path.to_string
  |> should.equal("/abs/path")
}
