//// Types and functions related to Nix derivations.

import gleam/dynamic
import glistix/nix/array.{type Array}
import glistix/nix/attrset.{type AttrSet}
import glistix/nix/path_like.{type PathLike, NixPath, StringPath}
import glistix/nix/system.{type System}

/// A derivation in Nix is a special attribute set with building information
/// as well as where it is to be stored in the Nix store.
pub type Derivation

/// A derivation's builder program, and the args to call it with.
/// Not to be confused with the `DerivationBuilder` type.
pub type Builder {
  Builder(path: PathLike, args: List(String))
}

/// Creates a new derivation.
/// Use a `DerivationBuilder` to specify more options.
///
/// Please refer to the NixOS manual, at https://nixos.org/manual/nix/stable/language/derivations,
/// to learn more about these options.
pub fn new(
  named name: String,
  on system: System,
  using builder: Builder,
) -> Derivation {
  let system = system.to_string(system)

  let builder_path = case builder.path {
    NixPath(path) -> dynamic.from(path)
    StringPath(path) -> dynamic.from(path)
  }

  let args =
    builder.args
    |> array.from_list

  do_new(name, system, builder_path, args, attrset.new())
}

@external(nix, "../../nix_ffi.nix", "derivation_new")
fn do_new(
  name: String,
  system: String,
  builder: builder,
  args: Array(String),
  options: AttrSet(options),
) -> Derivation

/// Converts an attribute set, which is assumed to be a derivation already,
/// to a derivation. If it is not a derivation, it will be cast into one
/// (that is, it will receive the `type: "derivation"` attribute).
@external(nix, "../../nix_ffi.nix", "derivation_from_attrset")
pub fn from_attrset(attrset: AttrSet(a)) -> Derivation
