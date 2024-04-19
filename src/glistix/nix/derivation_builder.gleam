//// Module for the `DerivationBuilder` type and its functions.

import gleam/dynamic.{type Dynamic}
import glistix/nix/array.{type Array}
import glistix/nix/attrset.{type AttrSet}
import glistix/nix/derivation.{type Builder, type Derivation}
import glistix/nix/path_like.{NixPath, StringPath}
import glistix/nix/system.{type System}

/// This type lets you compose a derivation's creation options
/// through builder functions.
///
/// Use `build` to finish the creation of the derivation.
pub opaque type DerivationBuilder(name, system, builder) {
  DerivationBuilder(
    name: name,
    system: system,
    builder: builder,
    options: AttrSet(Dynamic),
  )
}

/// Creates a derivation builder without any initial information.
pub fn new() -> DerivationBuilder(Nil, Nil, Nil) {
  DerivationBuilder(Nil, Nil, Nil, attrset.new())
}

/// Sets the name of the derivation being built.
pub fn with_name(
  derivation: DerivationBuilder(name, system, builder),
  name: String,
) -> DerivationBuilder(String, system, builder) {
  let DerivationBuilder(_, system, builder, options) = derivation
  DerivationBuilder(name, system, builder, options)
}

/// Sets the system of the derivation being built.
pub fn with_system(
  derivation: DerivationBuilder(name, system, builder),
  system: System,
) -> DerivationBuilder(name, System, builder) {
  let DerivationBuilder(name, _, builder, options) = derivation
  DerivationBuilder(name, system, builder, options)
}

/// Sets the program and arguments which will build this derivation.
pub fn with_builder(
  derivation: DerivationBuilder(name, system, builder),
  builder: Builder,
) -> DerivationBuilder(name, system, Builder) {
  let DerivationBuilder(name, system, _, options) = derivation
  DerivationBuilder(name, system, builder, options)
}

/// Sets the outputs of this derivation.
/// When not specified, the outputs are just `[ "out" ]`.
pub fn with_outputs(
  derivation: DerivationBuilder(name, system, builder),
  outputs: List(String),
) -> DerivationBuilder(name, system, builder) {
  let outputs =
    outputs
    |> array.from_list
    |> dynamic.from

  let options =
    derivation.options
    |> attrset.set("outputs", outputs)

  DerivationBuilder(..derivation, options: options)
}

/// Sets an extra option when creating the derivation.
/// Take care here as invalid options will cause a crash.
pub fn with_extra_option(
  derivation: DerivationBuilder(name, system, builder),
  set name: String,
  to value: value,
) -> DerivationBuilder(name, system, builder) {
  let options =
    derivation.options
    |> attrset.set(name, dynamic.from(value))

  DerivationBuilder(..derivation, options: options)
}

/// Creates a derivation given its builder.
/// The builder must have set a name, system and builder program for the
/// derivation.
/// Note that this does NOT cause the derivation to be "built" in the Nix sense;
/// it simply creates the object representing the derivation.
pub fn build(
  derivation: DerivationBuilder(String, System, Builder),
) -> Derivation {
  let DerivationBuilder(name, system, builder, options) = derivation

  let system = system.to_string(system)

  let builder_path = case builder.path {
    NixPath(path) -> dynamic.from(path)
    StringPath(path) -> dynamic.from(path)
  }

  let args =
    builder.args
    |> array.from_list

  do_build(name, system, builder_path, args, options)
}

@external(nix, "../../nix_ffi.nix", "derivation_new")
fn do_build(
  name: String,
  system: String,
  builder: builder,
  args: Array(String),
  options: AttrSet(options),
) -> Derivation
