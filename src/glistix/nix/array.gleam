//// Contains types and functions related to Nix's built-in lists (consisting of arrays).

import gleam/iterator.{type Iterator, Done, Next}

/// A Nix list. This is not a linked list, but rather a contiguous array.
/// The fastest way to access values in this array is by index.
/// Recursion over this type tends to be slower, as a consequence (would be `O(N^2)`).
pub type Array(element)

/// Reduces a list of elements into a single value by calling a given function
/// on each element, going from start to end.
///
/// Runs in linear time, and is strict (uses the `foldl'` built-in).
@external(nix, "../../nix_ffi.nix", "array_fold")
pub fn fold(
  over array: Array(a),
  from init: b,
  with operator: fn(b, a) -> b,
) -> b

/// Reduces a list of elements into a single value by calling a given function
/// on each element, going from end to start.
///
/// Runs in linear time, and is lazy and recursive, so large arrays can cause a stack overflow.
@external(nix, "../../nix_ffi.nix", "array_fold_right")
pub fn fold_right(
  over array: Array(a),
  from init: b,
  with operator: fn(b, a) -> b,
) -> b

/// Get the element at the given index.
///
/// ## Examples
///
/// ```gleam
/// get(from_list([1, 2, 3]), 0)
/// // -> Ok(1)
///
/// get(from_list([1, 2, 3]), 2)
/// // -> Ok(3)
///
/// get(from_list([1, 2, 3]), 3)
/// // -> Error(Nil)
/// ```
pub fn get(array: Array(a), at index: Int) -> Result(a, Nil) {
  case index >= 0 && index < size(array) {
    True -> Ok(do_unsafe_get(array, index))
    False -> Error(Nil)
  }
}

/// Gets the element at the given index without checking.
@external(nix, "../../nix_ffi.nix", "array_get")
fn do_unsafe_get(array: Array(a), index: Int) -> a

/// Returns a new array containing only the elements of the first array after
/// the function has been applied to each one.
///
/// Runs in linear time.
@external(nix, "../../nix_ffi.nix", "array_map")
pub fn map(over array: Array(a), with operator: fn(a) -> b) -> Array(b)

/// Similar to `map`, but the function receives each element
/// as well as its index.
///
/// Runs in linear time.
pub fn index_map(
  over array: Array(a),
  with operator: fn(Int, a) -> b,
) -> Array(b) {
  generate(size(array), with: fn(index) {
    array
    |> do_unsafe_get(index)
    |> operator(index, _)
  })
}

/// Similar to `map`, but flattens the resulting array of arrays after mapping.
///
/// ## Examples
///
/// ```gleam
/// flat_map(from_list([8, 9, 10]), fn(x) { from_list([x, x - 1, x * 2]) })
/// // -> from_list([8, 7, 16, 9, 8, 18, 10, 9, 20])
/// ```
pub fn flat_map(
  over array: Array(a),
  with operator: fn(a) -> Array(b),
) -> Array(b) {
  array
  |> map(with: operator)
  |> flatten
}

/// Gets the amount of elements in the array.
///
/// Runs in constant time.
@external(nix, "../../nix_ffi.nix", "array_size")
pub fn size(array: Array(a)) -> Int

/// Checks if an array contains any element equal to the given value.
@external(nix, "../../nix_ffi.nix", "array_contains")
pub fn contains(array: Array(a), any elem: a) -> Bool

/// Filters the array, returning a new array containing only the elements
/// for which the predicate function returned `True`.
///
/// ## Examples
///
/// ```gleam
/// filter(from_list([2, 3, 4, 5]), keeping: fn(x) { x > 3 })
/// // -> from_list([4, 5])
///
/// filter(from_list([2, 3, 4, 5]), keeping: fn(x) { x < 1 })
/// // -> from_list([])
/// ```
@external(nix, "../../nix_ffi.nix", "array_filter")
pub fn filter(array: Array(a), keeping predicate: fn(a) -> Bool) -> Array(a)

/// Joins the second array to the end of the first using Nix's
/// built-in `++` operator.
///
/// ## Examples
///
/// ```gleam
/// append(from_list([1, 2]), from_list([7, 8]))
/// // -> from_list([1, 2, 7, 8])
/// ```
@external(nix, "../../nix_ffi.nix", "array_append")
pub fn append(first: Array(a), second: Array(a)) -> Array(a)

/// Concatenates an array of arrays into a single array.
/// Uses `builtins.concatLists` for this task.
///
/// ## Examples
///
/// ```gleam
/// let first = from_list([1, 2])
/// let second = from_list([3, 4])
/// let third = from_list([5])
/// concat(from_list([first, second, third]))
/// // -> from_list([1, 2, 3, 4, 5])
/// ```
@external(nix, "../../nix_ffi.nix", "array_concat")
pub fn concat(arrays: Array(Array(a))) -> Array(a)

/// This is the same as `concat`, which joins an array of arrays into
/// a single array.
///
/// ## Examples
///
/// ```gleam
/// let first = from_list([1, 2])
/// let second = from_list([3, 4])
/// let third = from_list([5])
/// flatten(from_list([first, second, third]))
/// // -> from_list([1, 2, 3, 4, 5])
/// ```
pub fn flatten(arrays: Array(Array(a))) -> Array(a) {
  concat(arrays)
}

/// Sorts an array using the built-in `sort` function.
/// The comparator should return `True` if the first element is considered
/// 'less' than the second, and `False` otherwise.
/// This uses a stable sort algorithm, meaning elements which compare equal
/// preserve their relative order.
@external(nix, "../../nix_ffi.nix", "array_sort")
pub fn sort(array: Array(a), by compare: fn(a, a) -> Bool) -> Array(a)

/// Partitions an array's elements into a pair of arrays based on the output
/// of the given function. The first array returned includes elements for which
/// the function returned `True`, while the second array includes elements for
/// which the function returned `False`.
@external(nix, "../../nix_ffi.nix", "array_partition")
pub fn partition(
  array: Array(a),
  with categorise: fn(a) -> Bool,
) -> #(Array(a), Array(a))

/// Checks if the predicate is satisfied for all elements in the array,
/// returning `True` if the function returns `True` for all elements,
/// or `False` if it returned `False` for at least one element.
@external(nix, "../../nix_ffi.nix", "array_all")
pub fn all(in array: Array(a), satisfying predicate: fn(a) -> Bool) -> Bool

/// Checks if the predicate is satisfied for at least one element in the array,
/// returning `True` if the function returns `True` for one or more elements,
/// or `False` if it returned `False` for all elements.
@external(nix, "../../nix_ffi.nix", "array_any")
pub fn any(in array: Array(a), satisfying predicate: fn(a) -> Bool) -> Bool

/// Converts a Gleam list to a Nix array.
///
/// Runs in linear time, and is recursive, so large lists can cause a stack overflow.
@external(nix, "../../nix_ffi.nix", "array_from_list")
pub fn from_list(list: List(a)) -> Array(a)

/// Converts a Nix array to a Gleam list.
///
/// Runs in linear time.
@external(nix, "../../nix_ffi.nix", "array_to_list")
pub fn to_list(array: Array(a)) -> List(a)

/// Converts a Gleam iterator to a Nix array.
///
/// Runs in linear time.
pub fn from_iterator(iterator: Iterator(a)) -> Array(a) {
  iterator
  |> iterator.fold(from_list([]), fn(acc, elem) {
    acc
    |> append(from_list([elem]))
  })
}

/// Converts a Nix array to a Gleam iterator.
pub fn to_iterator(array: Array(a)) -> Iterator(a) {
  let count = size(array)

  iterator.unfold(from: 0, with: fn(i) {
    case i == count {
      True -> Done
      False -> Next(do_unsafe_get(array, i), i + 1)
    }
  })
}

/// Generates an array with a specified length. Takes a function which specifies
/// a value for each index in the new array.
///
/// Runs in linear time, but is not recursive (uses the built-in `genList` function).
@external(nix, "../../nix_ffi.nix", "array_generate")
pub fn generate(
  length: Int,
  with generator: fn(Int) -> element,
) -> Array(element)
