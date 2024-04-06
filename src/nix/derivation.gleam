//// Types and functions related to Nix derivations.

import gleam/dynamic.{type Dynamic}
import nix/array.{type Array}
import nix/attrset.{type AttrSet}
import nix/path.{type Path}
import nix/system.{type System}

/// A derivation in Nix is a special attribute set with building information
/// as well as where it is to be stored in the Nix store.
pub type Derivation

pub type BuilderPath {
  /// Use a builder from a path which will reside in the Nix store.
  StorePath(Path)
  /// Use a builder from an arbitrary path in the system.
  ArbitraryPath(String)
}

/// Extra derivation creation options.
/// When multiple of the same option are specified,
/// the last one wins.
pub type ExtraOption {
  Outputs(List(String))
}

fn convert_extra_options(options: List(ExtraOption)) -> List(#(String, Dynamic)) {
  case options {
    [] -> []
    [Outputs(outs), ..rest] -> [
      #(
        "outputs",
        outs
          |> array.from_list
          |> dynamic.from,
      ),
      ..convert_extra_options(rest)
    ]
  }
}

/// Creates a new derivation.
///
/// Please refer to the NixOS manual, at https://nixos.org/manual/nix/stable/language/derivations,
/// to learn more about these options.
pub fn new(
  named name: String,
  on system: System,
  using builder: BuilderPath,
  with args: List(String),
  and_with options: List(ExtraOption),
) -> Derivation {
  let system = system.to_string(system)

  let builder = case builder {
    StorePath(path) -> dynamic.from(path)
    ArbitraryPath(path) -> dynamic.from(path)
  }

  let args =
    args
    |> array.from_list

  let options =
    convert_extra_options(options)
    |> attrset.from_list

  do_new(name, system, builder, args, options)
}

@external(nix, "../nix_ffi.nix", "derivation_new")
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
@external(nix, "../nix_ffi.nix", "derivation_from_attrset")
pub fn from_attrset(attrset: AttrSet(a)) -> Derivation
