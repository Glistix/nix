import nix
import nix/array
import gleam/io
import gleam/string

pub fn strict(value: a, rest: fn() -> b) -> b {
  nix.seq(value, rest())
}

pub fn main() {
  array_test()
}

pub fn array_test() {
  let list = [Ok(1), Error(3), Ok(3)]
  let arr = array.from_list(list)

  // Use 'strict' to ensure assertions are executed
  use <- strict({
    let assert [Ok(1), Error(3), Ok(3)] =
      arr
      |> array.to_list
  })

  use <- strict({
    let assert Ok(Error(3)) =
      arr
      |> array.get(1)
  })

  use <- strict({
    let assert 3 =
      arr
      |> array.size
  })

  let arr =
    arr
    |> array.concat(array.from_list([Ok(4), Ok(5)]))

  let assert True =
    arr == array.from_list([Ok(1), Error(3), Ok(3), Ok(4), Ok(5)])
}
