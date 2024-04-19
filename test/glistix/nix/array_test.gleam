import gleam/float
import gleam/int
import gleam/iterator
import gleam/order
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

pub fn array_create_test() {
  array.new()
  |> should.equal(array.from_list([]))

  array.single(50)
  |> should.equal(array.from_list([50]))
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

pub fn array_index_fold_test() {
  array.from_list([1, 2, 3])
  |> array.index_fold(from: #(0, []), with: fn(acc, elem, index) {
    #(acc.0 + elem, [index, ..acc.1])
  })
  |> should.equal(#(6, [2, 1, 0]))
}

pub fn array_index_map_test() {
  array.from_list(["a", "b", "c"])
  |> array.index_map(with: fn(element, index) { #(element, index) })
  |> array.to_list
  |> should.equal([#("a", 0), #("b", 1), #("c", 2)])
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

pub fn array_first_test() {
  array.from_list([])
  |> array.first
  |> should.be_error

  array.from_list([1])
  |> array.first
  |> should.equal(Ok(1))

  array.from_list([2, 3])
  |> array.first
  |> should.equal(Ok(2))
}

pub fn array_rest_test() {
  array.from_list([])
  |> array.rest
  |> should.be_error

  array.from_list([1])
  |> array.rest
  |> should.equal(Ok(array.from_list([])))

  array.from_list([2, 3])
  |> array.rest
  |> should.equal(Ok(array.from_list([3])))
}

pub fn array_filter_test() {
  array.from_list([2, 3, 4, 5])
  |> array.filter(keeping: fn(x) { x > 3 })
  |> should.equal(array.from_list([4, 5]))

  array.from_list([2, 3, 4, 5])
  |> array.filter(keeping: fn(x) { x < 1 })
  |> should.equal(array.from_list([]))
}

pub fn array_filter_map_test() {
  array.from_list([#(1, True), #(2, False), #(3, False), #(4, True)])
  |> array.filter_map(with: fn(x) {
    case x {
      #(value, True) -> Ok(value)
      #(_, False) -> Error(Nil)
    }
  })
  |> should.equal(array.from_list([1, 4]))

  array.from_list([2, 3, 4, 5])
  |> array.filter_map(with: Error)
  |> should.equal(array.from_list([]))

  array.from_list([2, 3, 4, 5])
  |> array.filter_map(with: fn(x) { Ok(x + 1) })
  |> should.equal(array.from_list([3, 4, 5, 6]))
}

pub fn array_find_test() {
  array.from_list([2, 3, 4, 5])
  |> array.find(one_that: fn(x) { x > 3 })
  |> should.equal(Ok(4))

  array.from_list([2, 3, 4, 5])
  |> array.find(one_that: fn(x) { x < 1 })
  |> should.be_error
}

pub fn array_find_map_test() {
  array.from_list([#(1, False), #(2, False), #(3, True), #(4, True)])
  |> array.find_map(fn(x) {
    case x {
      #(value, True) -> Ok(value)
      #(_, False) -> Error(Nil)
    }
  })
  |> should.equal(Ok(3))

  array.from_list([array.from_list([]), array.from_list([1, 2])])
  |> array.find_map(array.first)
  |> should.equal(Ok(1))

  array.from_list([array.from_list([]), array.from_list([])])
  |> array.find_map(array.first)
  |> should.be_error

  array.from_list([])
  |> array.find_map(array.first)
  |> should.be_error
}

pub fn array_reduce_test() {
  array.from_list([1, 2, 3])
  |> array.reduce(with: fn(a, b) { a + b })
  |> should.equal(Ok(6))

  array.from_list([])
  |> array.reduce(with: fn(a, b) { a + b })
  |> should.be_error
}

pub fn array_reverse_test() {
  array.from_list([1, 2, 3, 4])
  |> array.reverse
  |> should.equal(array.from_list([4, 3, 2, 1]))

  array.from_list([])
  |> array.reverse
  |> should.equal(array.from_list([]))
}

pub fn array_sort_test() {
  array.from_list([3, 10, 4, 32])
  |> array.sort(by: order.reverse(int.compare))
  |> array.to_list
  |> should.equal([32, 10, 4, 3])

  array.from_list([3, 10, 4, 32])
  |> array.sort(by: int.compare)
  |> array.to_list
  |> should.equal([3, 4, 10, 32])
}

pub fn array_partition_test() {
  array.from_list([3, 4, 10, 32])
  |> array.partition(with: fn(x) { x > 5 })
  |> should.equal(#(array.from_list([10, 32]), array.from_list([3, 4])))
}

pub fn array_split_test() {
  array.from_list([12, 34, 56, 78])
  |> array.split(at: 0)
  |> should.equal(#(array.from_list([]), array.from_list([12, 34, 56, 78])))

  array.from_list([12, 34, 56, 78])
  |> array.split(at: 1)
  |> should.equal(#(array.from_list([12]), array.from_list([34, 56, 78])))

  array.from_list([12, 34, 56, 78])
  |> array.split(at: 4)
  |> should.equal(#(array.from_list([12, 34, 56, 78]), array.from_list([])))
}

pub fn array_slice_test() {
  array.slice(from: array.from_list([1, 2, 3, 4]), at: 1, take: 2)
  |> should.equal(Ok(array.from_list([2, 3])))

  array.slice(from: array.from_list([1, 2, 3, 4]), at: 4, take: -3)
  |> should.equal(Ok(array.from_list([2, 3, 4])))

  array.slice(from: array.from_list([]), at: 1, take: 2)
  |> should.equal(Error(Nil))
}

pub fn array_transpose_test() {
  array.from_list([
    array.from_list([1, 2, 3]),
    array.from_list([4, 5, 6]),
    array.from_list([7, 8, 9]),
  ])
  |> array.transpose
  |> should.equal(
    array.from_list([
      array.from_list([1, 4, 7]),
      array.from_list([2, 5, 8]),
      array.from_list([3, 6, 9]),
    ]),
  )

  array.from_list([
    array.from_list([]),
    array.from_list([1]),
    array.from_list([2, 3]),
    array.from_list([4, 5, 6]),
    array.from_list([7, 8, 9]),
  ])
  |> array.transpose
  |> should.equal(
    array.from_list([
      array.from_list([1, 2, 4, 7]),
      array.from_list([3, 5, 8]),
      array.from_list([6, 9]),
    ]),
  )

  array.from_list([])
  |> array.transpose
  |> should.equal(array.from_list([]))
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

pub fn array_zip_test() {
  array.zip(array.from_list([1, 3]), array.from_list([2, 4]))
  |> should.equal(array.from_list([#(1, 2), #(3, 4)]))

  array.zip(array.from_list([1, 2]), array.from_list([3]))
  |> should.equal(array.from_list([#(1, 3)]))

  array.zip(array.from_list([1, 2]), array.from_list([]))
  |> should.equal(array.from_list([]))
}

pub fn array_unzip_test() {
  array.from_list([#(1, 2), #(3, 4)])
  |> array.unzip
  |> should.equal(#(array.from_list([1, 3]), array.from_list([2, 4])))

  array.from_list([])
  |> array.unzip
  |> should.equal(#(array.from_list([]), array.from_list([])))
}

pub fn array_range_test() {
  array.range(0, 0)
  |> should.equal(array.from_list([0]))

  array.range(0, 5)
  |> should.equal(array.from_list([0, 1, 2, 3, 4, 5]))

  array.range(1, -5)
  |> should.equal(array.from_list([1, 0, -1, -2, -3, -4, -5]))
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
