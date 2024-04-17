//// Types related to fixed-output derivations.

/// Possible algorithms to calculate a fixed-output derivation's hash.
pub type HashAlgorithm {
  Sha1
  Sha256
  Sha512
}

/// Possible modes to calculate a fixed-output derivation's hash.
pub type HashMode {
  /// The output must be a non-executable regular file, whose hash is computed.
  Flat
  /// The output can be anything, and the hash is calculated over the NAR of the
  /// output.
  Recursive
}

pub fn algorithm_to_string(algorithm: HashAlgorithm) -> String {
  case algorithm {
    Sha1 -> "sha1"
    Sha256 -> "sha256"
    Sha512 -> "sha512"
  }
}

pub fn mode_to_string(mode: HashMode) -> String {
  case mode {
    Flat -> "flat"
    Recursive -> "recursive"
  }
}
