//// Types and functions related to Nix attribute sets.

import gleam/dict.{type Dict}

import glistix/nix/array.{type Array}

/// Represents any attribute set in Nix, containing values of a single type.
pub type AttrSet(value)

/// Creates a new, empty attribute set.
@external(nix, "../../nix_ffi.nix", "attrset_new")
pub fn new() -> AttrSet(a)

/// Gets the amount of attributes in the attribute set.
@external(nix, "../../nix_ffi.nix", "attrset_size")
pub fn size(set: AttrSet(a)) -> Int

/// Gets the value associated with that attribute, if it exists.
@external(nix, "../../nix_ffi.nix", "attrset_get")
pub fn get(set: AttrSet(a), attr: String) -> Result(a, Nil)

/// Updates the value of an attribute in the attribute set,
/// returning the new, updated attribute set.
///
/// The original attribute set is NOT changed and is immutable.
@external(nix, "../../nix_ffi.nix", "attrset_set")
pub fn set(set: AttrSet(a), at attr: String, to value: a) -> AttrSet(a)

/// Updates values in the given attribute set using the output of the given
/// function, which is called with each attribute's name and value and returns
/// the new value.
@external(nix, "../../nix_ffi.nix", "attrset_map_values")
pub fn map_values(
  in set: AttrSet(a),
  with fun: fn(String, a) -> b,
) -> AttrSet(b)

/// Merges two attribute sets, such that attributes in the second set
/// override those in the first with the same name.
@external(nix, "../../nix_ffi.nix", "attrset_merge")
pub fn merge(first: AttrSet(a), with second: AttrSet(a)) -> AttrSet(a)

/// Generates an attribute set with all attributes in the first set
/// which have the same name as some attribute in the second set.
@external(nix, "../../nix_ffi.nix", "attrset_intersect")
pub fn intersect(first: AttrSet(a), with second: AttrSet(b)) -> AttrSet(a)

/// Obtains the list of attribute names in the given attribute set.
/// Returns an `Array` as it uses `builtins.attrNames`. You can use
/// `array.to_list` to convert to a `List`.
///
/// ## Examples
///
/// ```gleam
/// from_list([#("a", 5), #("b", 6)]) |> names
/// // -> array.from_list(["a", "b"])
/// ```
@external(nix, "../../nix_ffi.nix", "attrset_names")
pub fn names(in set: AttrSet(a)) -> Array(String)

/// Obtains the list of values in the given attribute set.
/// Returns an `Array` as it uses `builtins.attrValues`. You can use
/// `array.to_list` to convert to a `List`.
///
/// ## Examples
///
/// ```gleam
/// from_list([#("a", 5), #("b", 6)]) |> values
/// // -> array.from_list([5, 6])
/// ```
@external(nix, "../../nix_ffi.nix", "attrset_values")
pub fn values(in set: AttrSet(a)) -> Array(a)

/// Creates an attribute set from a list of `#(name, value)` pairs.
///
/// If there are two attributes with the same name, the first occurrence
/// takes precedence.
pub fn from_list(attrs: List(#(String, value))) -> AttrSet(value) {
  case attrs {
    [] -> new()
    [#(key, value), ..rest] -> {
      from_list(rest)
      |> set(key, value)
    }
  }
}

/// Creates an attribute set from an array of `#(name, value)` pairs.
///
/// If there are two attributes with the same name, the first occurrence
/// takes precedence.
@external(nix, "../../nix_ffi.nix", "attrset_from_array")
pub fn from_array(attrs: Array(#(String, value))) -> AttrSet(value)

/// Creates an attribute set from a dictionary with string keys.
pub fn from_dict(dict: Dict(String, value)) -> AttrSet(value) {
  dict
  |> dict.to_list
  |> from_list
}

/// Obtains a list of `#(name, value)` pairs from an attribute set.
pub fn to_list(set: AttrSet(a)) -> List(#(String, a)) {
  to_array(set)
  |> array.to_list
}

/// Obtains an array of `#(name, value)` pairs from an attribute set.
@external(nix, "../../nix_ffi.nix", "attrset_to_array")
pub fn to_array(set: AttrSet(a)) -> Array(#(String, a))

/// Converts an attribute set to a dictionary with string keys.
pub fn to_dict(set: AttrSet(a)) -> Dict(String, a) {
  set
  |> to_list
  |> dict.from_list
}
