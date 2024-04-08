import gleam/dict
import gleeunit/should
import nix/array
import nix/attrset

pub fn attrset_init_test() {
  let set = attrset.new()

  set
  |> attrset.size
  |> should.equal(0)

  set
  |> attrset.get("a")
  |> should.be_error
}

pub fn attrset_set_test() {
  let set = attrset.new()
  let set =
    set
    |> attrset.set("a", 340)
    |> attrset.set("b", 345)

  set
  |> attrset.size
  |> should.equal(2)

  set
  |> attrset.get("a")
  |> should.be_ok
  |> should.equal(340)

  set
  |> attrset.get("b")
  |> should.be_ok
  |> should.equal(345)
}

pub fn attrset_merge_test() {
  let first =
    attrset.new()
    |> attrset.set("a", 123)
    |> attrset.set("b", 456)
    |> attrset.set("c", 789)

  let second =
    attrset.new()
    |> attrset.set("a", 444)
    |> attrset.set("b", 555)
    |> attrset.set("e", 999)

  let result =
    attrset.new()
    |> attrset.set("a", 444)
    |> attrset.set("b", 555)
    |> attrset.set("c", 789)
    |> attrset.set("e", 999)

  first
  |> attrset.merge(with: second)
  |> should.equal(result)
}

pub fn attrset_intersect_test() {
  let first =
    attrset.new()
    |> attrset.set("a", 123)
    |> attrset.set("b", 456)
    |> attrset.set("c", 789)

  let second =
    attrset.new()
    |> attrset.set("a", "444")
    |> attrset.set("b", "555")
    |> attrset.set("e", "999")

  let result =
    attrset.new()
    |> attrset.set("a", 123)
    |> attrset.set("b", 456)

  first
  |> attrset.intersect(with: second)
  |> should.equal(result)
}

pub fn attrset_from_list_and_array_test() {
  let attrs = [#("a", 1), #("b", 2), #("b", 3)]

  let expected =
    attrset.new()
    |> attrset.set("a", 1)
    |> attrset.set("b", 2)

  attrs
  |> attrset.from_list
  |> should.equal(expected)

  attrs
  |> array.from_list
  |> attrset.from_array
  |> should.equal(expected)
}

pub fn attrset_from_to_dict_test() {
  let pairs = [#("a", 1), #("b", 2), #("c", 3)]

  pairs
  |> dict.from_list
  |> attrset.from_dict
  |> attrset.to_dict
  |> dict.to_list
  |> should.equal(pairs)
}

pub fn attrset_map_values_test() {
  attrset.from_list([#("a", 1), #("b", 2), #("c", 3)])
  |> attrset.map_values(with: fn(_, value) { value >= 2 })
  |> should.equal(
    attrset.from_list([#("a", False), #("b", True), #("c", True)]),
  )
}

pub fn attrset_extract_lists_test() {
  let set = attrset.from_list([#("a", 1), #("b", 2), #("c", 1)])

  set
  |> attrset.names
  |> should.equal(["a", "b", "c"])

  set
  |> attrset.values
  |> should.equal([1, 2, 1])

  set
  |> attrset.to_list
  |> should.equal([#("a", 1), #("b", 2), #("c", 1)])

  set
  |> attrset.to_array
  |> should.equal(
    [#("a", 1), #("b", 2), #("c", 1)]
    |> array.from_list,
  )
}
