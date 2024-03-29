/// Evaluates the first expression strictly and returns the second.
///
/// Nix is lazy by default, so most values aren't actually computed until
/// prompted to by evaluation. This function can be used to force a value
/// (the first parameter) to be evaluated. For this to properly work, however,
/// make sure that this `seq` call is evaluated in the first place by using
/// its return value.
@external(nix, "../nix_ffi.nix", "builtins_seq")
pub fn seq(first first: a, then second: b) -> b

/// Evaluates the first expression deeply strictly, and returns the second.
///
/// This is similar to [`seq`], except that the first parameter's inner values
/// are also recursively evaluated. In other words, the first parameter's value
/// and any values within it are all fully evaluated.
@external(nix, "../nix_ffi.nix", "builtins_deep_seq")
pub fn deep_seq(first first: a, then second: b) -> b
