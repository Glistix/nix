//// Types and functions related to Nix path types.

/// Represents a path in the filesystem.
/// Usually indicates a file or directory to be saved to the Nix store.
pub type Path

/// Creates a path from a string.
/// When it starts with /, it is absolute (relative to the filesystem root).
/// When it starts with ~/, it is relative to the user's home folder.
/// When it starts with ../, it is relative to the parent folder of the current file.
/// When it starts with ./ or anything else, it is relative to the folder of the current file.
///
/// ## Examples
///
/// ```gleam
/// from_string("./file.nix")
/// // -> //nix(./file.nix)
/// ```
@external(nix, "../../nix_ffi.nix", "path_from_string")
pub fn from_string(string: String) -> Path

/// Converts a path to a string form.
@external(nix, "../../nix_ffi.nix", "builtins_to_string")
pub fn to_string(path: Path) -> String
