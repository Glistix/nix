//// Module concerning the `PathLike` type.

import glistix/nix/path.{type Path}

/// Represents any object which could be used to represent a path within Nix.
pub type PathLike {
  /// A regular path object.
  /// Usually, when used, triggers a copy to the Nix store.
  NixPath(Path)

  /// A string which points to any path in the system.
  StringPath(String)
}

/// Converts this path-like object to a string containing the
/// path it represents.
/// If it holds a regular path, it will be converted first,
/// but if it holds a string, it is directly returned.
pub fn to_string(path: PathLike) -> String {
  case path {
    NixPath(path) -> path.to_string(path)
    StringPath(path) -> path
  }
}
