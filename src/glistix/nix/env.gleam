//// Functions to access the outer environment.

import glistix/nix/system.{type System}

/// Accesses the current system, if available.
/// It won't be available in pure evaluation mode,
/// so it is not recommended to depend on this function.
///
/// ## Examples
///
/// ```gleam
/// current_system()
/// // -> Ok(X8664Linux)
/// ```
pub fn current_system() -> Result(System, Nil) {
  case do_current_system() {
    Ok(system) -> Ok(system.from_string(system))
    Error(error) -> Error(error)
  }
}

@external(nix, "../../nix_ffi.nix", "current_system")
fn do_current_system() -> Result(String, Nil)

/// Accesses the current Unix time in seconds since the epoch
/// (January 1, 1970), if available.
/// It won't be available in pure evaluation mode,
/// so it is not recommended to depend on this function.
///
/// Repeated calls to this function will return the same value as the first.
///
/// ## Examples
///
/// ```gleam
/// current_time()
/// // -> Ok(1683705525)
/// ```
@external(nix, "../../nix_ffi.nix", "current_time")
pub fn current_time() -> Result(Int, Nil)

/// Gets the value of an environment variable at evaluation time,
/// if the variable was specified with a non-empty value.
/// It is not recommended to depend on this function, in order to
/// avoid creating dependencies on the environment.
///
/// ## Examples
///
/// ```gleam
/// get_env(named: "PATH")
/// // -> Ok("/usr/bin:/some/folder")
///
/// get_env(named: "VERY_MUCH_UNKNOWN")
/// // -> Error(Nil)
/// ```
@external(nix, "../../nix_ffi.nix", "get_env")
pub fn get_env(named name: String) -> Result(String, Nil)
