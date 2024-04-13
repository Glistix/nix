import gleam/float
import gleam/int
import gleam/iterator
import gleam/result
import gleeunit/should
import glistix/nix/array

pub fn array_and_list_test() {
  let list = [Ok(1), Error(3), Ok(3)]

  list
  |> array.from_list
  |> array.to_list
  |> should.equal(list)
}

pub fn array_basic_ops_test() {
  let list = [Ok(1), Error(3), Ok(3)]

  let arr =
    list
    |> array.from_list

  arr
  |> array.get(1)
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
  |> array.append(array.from_list([Ok(100), Error(100)]))
  |> array.to_list
  |> should.equal([Ok(1), Error(3), Ok(3), Ok(100), Error(100)])
}

pub fn array_access_test() {
  let empty = array.from_list([])

  empty
  |> array.get(-1)
  |> should.be_error

  empty
  |> array.get(0)
  |> should.be_error

  empty
  |> array.get(1)
  |> should.be_error

  let array = array.from_list([1, 2])

  array
  |> array.get(-1)
  |> should.be_error

  array
  |> array.get(0)
  |> should.equal(Ok(1))

  array
  |> array.get(1)
  |> should.equal(Ok(2))

  array
  |> array.get(2)
  |> should.be_error

  array
  |> array.get(2_324_234)
  |> should.be_error
}

pub fn array_append_test() {
  let first = array.from_list([1, 2])
  let second = array.from_list([7, 8, 9])

  array.append(first, second)
  |> should.equal(array.from_list([1, 2, 7, 8, 9]))
}

pub fn array_concat_test() {
  let first = array.from_list([1, 2])
  let second = array.from_list([7, 8])
  let third = array.from_list([-1, -2])

  array.from_list([first, second, third])
  |> array.concat
  |> should.equal(array.from_list([1, 2, 7, 8, -1, -2]))

  array.from_list([first, second, third])
  |> array.flatten
  |> should.equal(array.from_list([1, 2, 7, 8, -1, -2]))
}

pub fn array_fold_test() {
  array.from_list([1, 2, 3])
  |> array.fold(from: 0, with: fn(acc, elem) { acc + elem })
  |> should.equal(6)

  array.from_list([1, 2, 3])
  |> array.fold_right(from: 0, with: fn(acc, elem) { acc + elem })
  |> should.equal(6)
}

pub fn array_index_map_test() {
  array.from_list(["a", "b", "c"])
  |> array.index_map(with: fn(index, element) { #(index, element) })
  |> array.to_list
  |> should.equal([#(0, "a"), #(1, "b"), #(2, "c")])
}

pub fn array_flat_map_test() {
  array.from_list([1, 2, 3])
  |> array.flat_map(with: fn(elem) {
    let pow =
      int.power(2, int.to_float(elem))
      |> result.unwrap(or: 0.0)
      |> float.round

    array.from_list([elem, pow])
  })
  |> should.equal(array.from_list([1, 2, 2, 4, 3, 8]))
}

pub fn array_contains_test() {
  array.from_list([1, 2, 3])
  |> array.contains(3)
  |> should.be_true()

  array.from_list([1, 2, 3])
  |> array.contains(4)
  |> should.be_false()
}

pub fn array_filter_test() {
  array.from_list([2, 3, 4, 5])
  |> array.filter(keeping: fn(x) { x > 3 })
  |> should.equal(array.from_list([4, 5]))

  array.from_list([2, 3, 4, 5])
  |> array.filter(keeping: fn(x) { x < 1 })
  |> should.equal(array.from_list([]))
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
  |> should.equal(#(array.from_list([10, 32]), array.from_list([3, 4])))
}

pub fn array_all_any_test() {
  let arr = array.from_list([1, 2, 3, 4])

  arr
  |> array.all(satisfying: fn(value) { value > 1 })
  |> should.be_false

  arr
  |> array.all(satisfying: fn(value) { value < 5 })
  |> should.be_true

  arr
  |> array.any(satisfying: fn(value) { value > 1 })
  |> should.be_true

  arr
  |> array.any(satisfying: fn(value) { value > 5 })
  |> should.be_false
}

pub fn array_generate_test() {
  array.generate(4, with: fn(i) { 100 * i })
  |> array.to_list
  |> should.equal([0, 100, 200, 300])
}

pub fn array_iterator_conversion_test() {
  [1, 2, 3, 4]
  |> iterator.from_list
  |> array.from_iterator
  |> should.equal(array.from_list([1, 2, 3, 4]))

  array.from_list([1, 2, 3, 4])
  |> array.to_iterator
  |> iterator.map(fn(x) { 2 * x })
  |> iterator.to_list
  |> should.equal([2, 4, 6, 8])
}
