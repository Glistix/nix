//// Contains types and functions related to Nix's built-in lists (consisting of arrays).

/// A Nix list. This is not a linked list, but rather a contiguous array.
/// The fastest way to access values in this array is by index.
/// Recursion over this type tends to be slower, as a consequence (would be `O(N^2)`).
pub type Array(element)

/// Reduces a list of elements into a single value by calling a given function
/// on each element, going from start to end.
///
/// Runs in linear time, and is strict (uses the `foldl'` built-in).
@external(nix, "../nix_ffi.nix", "array_fold")
pub fn fold(
  over array: Array(a),
  from init: b,
  with operator: fn(b, a) -> b,
) -> b

/// Reduces a list of elements into a single value by calling a given function
/// on each element, going from end to start.
///
/// Runs in linear time, and is lazy and recursive, so large arrays can cause a stack overflow.
@external(nix, "../nix_ffi.nix", "array_fold_right")
pub fn fold_right(
  over array: Array(a),
  from init: b,
  with operator: fn(b, a) -> b,
) -> b

/// Get the element at the given index.
@external(nix, "../nix_ffi.nix", "array_get")
pub fn get(array: Array(a), at index: Int) -> Result(a, Nil)

/// Returns a new array containing only the elements of the first array after
/// the function has been applied to each one.
///
/// Runs in linear time.
@external(nix, "../nix_ffi.nix", "array_map")
pub fn map(array: Array(a), with operator: fn(a) -> b) -> Array(b)

/// Gets the amount of elements in the array.
///
/// Runs in constant time.
@external(nix, "../nix_ffi.nix", "array_size")
pub fn size(array: Array(a)) -> Int

/// Checks if an array contains any element equal to the given value.
@external(nix, "../nix_ffi.nix", "array_contains")
pub fn contains(array: Array(a), any elem: a) -> Bool

/// Joins two arrays using Nix's built-in `++` operator.
@external(nix, "../nix_ffi.nix", "array_concat2")
pub fn concat2(first: Array(a), second: Array(a)) -> Array(a)

/// Sorts an array using the built-in `sort` function.
/// The comparator should return `True` if the first element is considered
/// 'less' than the second, and `False` otherwise.
/// This uses a stable sort algorithm, meaning elements which compare equal
/// preserve their relative order.
@external(nix, "../nix_ffi.nix", "array_sort")
pub fn sort(array: Array(a), by compare: fn(a, a) -> Bool) -> Array(a)

/// Partitions an array's elements into a pair of arrays based on the output
/// of the given function. The first array returned includes elements for which
/// the function returned `True`, while the second array includes elements for
/// which the function returned `False`.
@external(nix, "../nix_ffi.nix", "array_partition")
pub fn partition(
  array: Array(a),
  with categorise: fn(a) -> Bool,
) -> #(Array(a), Array(a))

/// Converts a Gleam list to a Nix array.
///
/// Runs in linear time, and is recursive, so large lists can cause a stack overflow.
@external(nix, "../nix_ffi.nix", "array_from_list")
pub fn from_list(list: List(a)) -> Array(a)

/// Converts a Nix array to a Gleam list.
///
/// Runs in linear time.
@external(nix, "../nix_ffi.nix", "array_to_list")
pub fn to_list(array: Array(a)) -> List(a)

/// Generates an array with a specified length. Takes a function which specifies
/// a value for each index in the new array.
///
/// Runs in linear time, but is not recursive (uses the built-in `genList` function).
@external(nix, "../nix_ffi.nix", "array_generate")
pub fn generate(
  length: Int,
  with generator: fn(Int) -> element,
) -> Array(element)
