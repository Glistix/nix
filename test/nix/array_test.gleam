import nix/array
import gleeunit/should

pub fn array_and_list_test() {
  let list = [Ok(1), Error(3), Ok(3)]

  list
  |> array.from_list
  |> array.to_list
  |> should.equal(list)
}

pub fn array_basic_ops_test() {
  let list = [Ok(1), Error(3), Ok(3)]

  let arr = list
  |> array.from_list

  arr
  |> array.at(1)
  |> should.be_ok
  |> should.equal(Error(3))

  arr
  |> array.size
  |> should.equal(3)

  arr
  |> array.map(fn(res) {
    case res {
      Ok(x) -> Ok(x + 1)
      Error(x) -> Error(x - 1)
    }
  })
  |> array.to_list
  |> should.equal([Ok(2), Error(2), Ok(4)])

  arr
  |> array.concat2(_, array.from_list([Ok(100), Error(100)]))
  |> array.to_list
  |> should.equal([Ok(1), Error(3), Ok(3), Ok(100), Error(100)])
}

pub fn array_fold_test() {
  array.from_list([1, 2, 3])
  |> array.fold(from: 0, with: fn(acc, elem) { acc + elem })
  |> should.equal(6)

  array.from_list([1, 2, 3])
  |> array.fold_right(from: 0, with: fn(acc, elem) { acc + elem })
  |> should.equal(6)
}

pub fn array_sort_test() {
  array.from_list([3, 10, 4, 32])
  |> array.sort(by: fn(a, b) { b < a })
  |> array.to_list
  |> should.equal([32, 10, 4, 3])

  array.from_list([3, 10, 4, 32])
  |> array.sort(by: fn(a, b) { a < b })
  |> array.to_list
  |> should.equal([3, 4, 10, 32])
}

pub fn array_partition_test() {
  array.from_list([3, 4, 10, 32])
  |> array.partition(with: fn(x) { x > 5 })
  |> should.equal(
    #(
      array.from_list([10, 32]),
      array.from_list([3, 4])
    )
  )
}

pub fn array_generate_test() {
  array.generate(4, with: fn(i) { 100 * i })
  |> array.to_list
  |> should.equal([0, 100, 200, 300])
}