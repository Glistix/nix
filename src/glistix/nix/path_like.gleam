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
