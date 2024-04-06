//// Library for interacting with Nix built-in types and functions.

pub type TypeOf {
  IntType
  BoolType
  StringType
  PathType
  NullType
  SetType
  ListType
  LambdaType
  FloatType
}

/// Gets the Nix type of a value.
///
/// Note that this function works with the value's
/// representation within Nix, and so the returned type
/// shouldn't be associated with a particular Gleam type,
/// as Gleam types might be represented by different Nix
/// types.
pub fn typeof(of subject: a) -> TypeOf {
  case do_typeof(subject) {
    "int" -> IntType
    "bool" -> BoolType
    "string" -> StringType
    "path" -> PathType
    "null" -> NullType
    "set" -> SetType
    "list" -> ListType
    "lambda" -> LambdaType
    "float" -> FloatType
    _ -> panic as "Unexpected type received"
  }
}

@external(nix, "./nix_ffi.nix", "builtins_typeof")
fn do_typeof(subject: a) -> String

/// Evaluates the expression strictly, recursively.
///
/// Nix is lazy by default, so most values aren't actually computed until
/// prompted to by evaluation. This function can be used to force a value
/// (one of the parameters) to be recursively evaluated upon evaluation.
/// That is, once this function is called, the given value and any values
/// within it (such as list items or attribute set values) are also evaluated.
/// This is used to ensure side-effects, such as printing (through `trace`)
/// or panics, are applied even from within data structures.
///
/// Please note that misusing this function may result in performance losses,
/// or even infinite recursion with infinite data structures.
///
/// ## Examples
///
/// ```gleam
/// {
///   deep_eval([panic as "Bad")])
///   "Unreachable here"
///
///   10
/// }
/// // -> error: Bad
/// ```
@external(nix, "./nix_ffi.nix", "deep_eval")
pub fn deep_eval(expression: a) -> a
