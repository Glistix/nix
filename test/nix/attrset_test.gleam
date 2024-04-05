import nix/attrset
import gleeunit/should

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
