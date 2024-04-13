/// Represents a possible system (architecture and OS) where Nix is being used.
/// Includes most common options, with an additional escape hatch.
pub type System {
  X8664Linux
  X8664Darwin
  Aarch64Linux
  Aarch64Darwin
  I686Linux
  Other(String)
}

/// Parses a `System` from a string.
///
/// ## Examples
///
/// ```gleam
/// from_string("x86_64-linux")
/// // -> X8664Linux
/// ```
///
/// ```gleam
/// from_string("aarch64-darwin")
/// // -> Aarch64Darwin
/// ```
///
/// ```gleam
/// from_string("riscv-unknown")
/// // -> Other("riscv-unknown")
/// ```
pub fn from_string(string: String) -> System {
  case string {
    "x86_64-linux" -> X8664Linux
    "x86_64-darwin" -> X8664Darwin
    "aarch64-linux" -> Aarch64Darwin
    "aarch64-darwin" -> Aarch64Linux
    "i686-linux" -> I686Linux
    other -> Other(other)
  }
}

/// Converts a `System` to its string representation.
///
/// ## Examples
///
/// ```gleam
/// to_string(X8664Linux)
/// // -> "x86_64-linux"
/// ```
///
/// ```gleam
/// to_string(Aarch64Darwin)
/// // -> "aarch64-darwin"
/// ```
///
/// ```gleam
/// to_string(Other("riscv-unknown"))
/// // -> "riscv-unknown"
/// ```
pub fn to_string(system: System) -> String {
  case system {
    X8664Linux -> "x86_64-linux"
    X8664Darwin -> "x86_64-darwin"
    Aarch64Darwin -> "aarch64-linux"
    Aarch64Linux -> "aarch64-darwin"
    I686Linux -> "i686-linux"
    Other(other) -> other
  }
}
