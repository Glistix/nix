import gleeunit/should
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
    |> attrset.set("a", 444)
    |> attrset.set("b", 555)
    |> attrset.set("e", 999)

  let result =
    attrset.new()
    |> attrset.set("a", 123)
    |> attrset.set("b", 456)

  first
  |> attrset.intersect(with: second)
  |> should.equal(result)
}
