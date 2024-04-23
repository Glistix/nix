# glistix_nix

**Mirrors:** **[GitHub](https://github.com/glistix/nix)** | **[Codeberg](https://codeberg.org/glistix/nix)**

A library for interacting with built-in Nix types and functions when using [Glistix](https://github.com/glistix/glistix).

[![Package Version](https://img.shields.io/hexpm/v/nix_lib)](https://hex.pm/packages/glistix_nix)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glistix_nix/)

## Installation

Run the command below to use `glistix_nix` in your Glistix project. Note that you will have to patch
`gleam_stdlib` in your project to point to [`glistix/stdlib`](https://github.com/glistix/stdlib).
See its README for instructions. (This should be done by default when creating a new Glistix
project.)

```sh
# Add to your Glistix project
glistix add glistix_nix
```

Please note that functions exposed by this library are only suitable for Glistix's Nix target,
and do not work on Erlang or JavaScript.

## Example

```gleam
import gleam/io
import gleam/int
import glistix/nix
import glistix/nix/array.{type Array}
import glistix/nix/attrset.{type AttrSet}

pub fn main() {
  // Use to deeply evaluate an expression
  nix.deep_eval(#(io.println("Hi")))

  // Work with arrays
  let array: Array(#(String, Int)) =
    [1, 2, 3, 4]
    |> array.from_list
    |> array.map(fn(x) {
      let name =
        x + 1
        |> int.to_string

      #(name, x)
    })

  // Work with attribute sets
  let attrset: AttrSet(Int) =
    array
    |> attrset.from_array

  let assert Ok(value) =
    attrset
    |> attrset.get("2")

  value // -> 1
}
```

Further documentation can be found at <https://hexdocs.pm/glistix_nix>.

## Development

When developing, make sure to apply the Glistix patch for `gleam_stdlib`
locally so that it may work in the Nix target.

You can do this by running `git submodule init` to init the
[`glistix/stdlib`](https://github.com/glistix/stdlib) submodule upon cloning.

You will then be able to run the command below to the test the library.

```
// Run library tests
glistix test
```

## License

This project is licensed under Apache 2.0 and MIT, at your option.
