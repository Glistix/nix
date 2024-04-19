//// Contains types and functions related to Nix's built-in lists (consisting of arrays).

import gleam/int
import gleam/iterator.{type Iterator, Done, Next}
import gleam/order.{type Order}

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
  over array: Array(item),
  from init: acc,
  with operator: fn(acc, item) -> acc,
) -> acc

/// Reduces a list of elements into a single value by calling a given function
/// on each element, going from end to start.
///
/// Runs in linear time, and is lazy and recursive, so large arrays can cause a stack overflow.
@external(nix, "../../nix_ffi.nix", "array_fold_right")
pub fn fold_right(
  over array: Array(item),
  from init: acc,
  with operator: fn(acc, item) -> acc,
) -> acc

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

/// Similar to `fold`, but the function receives each element's
/// index alongside the accumulator and the element.
///
/// Runs in linear time and is strict.
pub fn index_fold(
  over array: Array(item),
  from initial: acc,
  with operator: fn(acc, item, Int) -> acc,
) -> acc {
  let #(result, _) =
    fold(over: array, from: #(initial, 0), with: fn(acc, item) {
      let #(acc, index) = acc
      #(operator(acc, item, index), index + 1)
    })

  result
}

/// Similar to `map`, but the function receives each element
/// as well as its index.
///
/// Runs in linear time.
pub fn index_map(
  over array: Array(a),
  with operator: fn(a, Int) -> b,
) -> Array(b) {
  generate(size(array), with: fn(index) {
    array
    |> do_unsafe_get(index)
    |> operator(index)
  })
}

/// Similar to `map`, but flattens the resulting array of arrays after mapping.
///
/// This function is more efficient than a `map` followed by `flatten`, as it
/// uses the built-in `builtins.concatMap` function.
///
/// ## Examples
///
/// ```gleam
/// flat_map(from_list([8, 9, 10]), fn(x) { from_list([x, x - 1, x * 2]) })
/// // -> from_list([8, 7, 16, 9, 8, 18, 10, 9, 20])
/// ```
@external(nix, "../../nix_ffi.nix", "array_flat_map")
pub fn flat_map(
  over array: Array(a),
  with operator: fn(a) -> Array(b),
) -> Array(b)

/// Gets the amount of elements in the array.
///
/// Runs in constant time.
@external(nix, "../../nix_ffi.nix", "array_size")
pub fn size(array: Array(a)) -> Int

/// Checks if an array contains any element equal to the given value.
@external(nix, "../../nix_ffi.nix", "array_contains")
pub fn contains(array: Array(a), any elem: a) -> Bool

/// Returns the first element of the array, if it isn't empty.
///
/// ## Examples
///
/// ```gleam
/// first(from_list([]))
/// // -> Error(Nil)
///
/// first(from_list([1]))
/// // -> Ok(1)
///
/// first(from_list([2, 3, 4]))
/// // -> Ok(2)
/// ```
pub fn first(array: Array(a)) -> Result(a, Nil) {
  case size(array) {
    0 -> Error(Nil)
    _ -> Ok(do_unsafe_first(array))
  }
}

/// Returns the first element of the array without checking.
@external(nix, "../../nix_ffi.nix", "array_first")
fn do_unsafe_first(array: Array(a)) -> a

/// Returns the array minus its first element, or `Error(Nil)` if it is empty.
///
/// Note that this runs in linear time, so using `rest` with a recursive algorithm
/// will yield `O(n^2)` complexity. Consider using increasing indices to access the
/// array instead, if possible. Alternatively, use a `List` with such algorithms
/// instead, as the equivalent operation over `List` runs in constant time (while
/// indexing over a `List` runs in linear time).
///
/// ## Examples
///
/// ```gleam
/// rest(from_list([]))
/// // -> Error(Nil)
///
/// rest(from_list([1]))
/// // -> Ok(from_list([]))
///
/// rest(from_list([1, 2]))
/// // -> Ok(from_list([2]))
/// ```
pub fn rest(array: Array(a)) -> Result(Array(a), Nil) {
  case size(array) {
    0 -> Error(Nil)
    _ -> Ok(do_unsafe_rest(array))
  }
}

/// Returns the elements of the array after the first without checking.
@external(nix, "../../nix_ffi.nix", "array_rest")
fn do_unsafe_rest(array: Array(a)) -> Array(a)

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

/// Finds the first element in the array for which the function returns `True`.
///
/// If no such element exists, returns `Error(Nil)`.
///
/// Note that, currently, this will always traverse the whole array.
///
/// ## Examples
///
/// ```gleam
/// find(from_list([1, 2, 3, 4, 5]), fn(x) { x > 3 })
/// // -> Ok(4)
///
/// find(from_list([10]), fn(x) { x == 5 })
/// // -> Error(Nil)
/// ```
pub fn find(
  in array: Array(a),
  one_that is_desired: fn(a) -> Bool,
) -> Result(a, Nil) {
  // Folding will be the most efficient way for now while we don't have tail-call
  // optimization. See also nixpkgs' `lib/lists.nix`
  fold(over: array, from: Error(Nil), with: fn(found, item) {
    case found {
      Ok(_) -> found
      Error(_) ->
        case is_desired(item) {
          True -> Ok(item)
          False -> found
        }
    }
  })
}

/// Reverses the array, returning a new array with its elements in the opposite
/// order as the given array.
///
/// Runs in linear time.
///
/// ## Examples
///
/// ```gleam
/// reverse(from_list([1, 2, 3, 4]))
/// // -> from_list([4, 3, 2, 1])
/// ```
pub fn reverse(array: Array(a)) -> Array(a) {
  let len = size(array)

  generate(len, fn(i) { do_unsafe_get(array, len - 1 - i) })
}

/// Sorts an array using the built-in `sort` function through
/// the given comparator. Sorts in ascending order by default,
/// but the order can be reversed through `order.reverse`
/// in the standard library.
///
/// This uses a stable sort algorithm, meaning elements which compare equal
/// preserve their relative order.
///
/// ## Examples
///
/// ```gleam
/// sort(from_list([3, 10, 4, 32]), by: int.compare)
/// // -> from_list([32, 10, 4, 3])
///
/// sort(from_list([3, 10, 4, 32]), by: order.reverse(int.compare))
/// // -> from_list([3, 4, 10, 32])
/// ```
pub fn sort(array: Array(a), by compare: fn(a, a) -> Order) -> Array(a) {
  do_sort(array, fn(a, b) { compare(a, b) == order.Lt })
}

/// The compare function must return True if the first element is less than the
/// second.
@external(nix, "../../nix_ffi.nix", "array_sort")
pub fn do_sort(array: Array(a), compare: fn(a, a) -> Bool) -> Array(a)

/// Partitions an array's elements into a pair of arrays based on the output
/// of the given function. The first array returned includes elements for which
/// the function returned `True`, while the second array includes elements for
/// which the function returned `False`.
@external(nix, "../../nix_ffi.nix", "array_partition")
pub fn partition(
  array: Array(a),
  with categorise: fn(a) -> Bool,
) -> #(Array(a), Array(a))

/// Splits an array in two before the given index.
/// If the array isn't long enough to contain that index,
/// the first returned array will be equal to the full given
/// array, and the second returned array will be empty.
///
/// ## Examples
///
/// ```gleam
/// split(from_list([12, 34, 56]), at: 0)
/// // -> #(from_list([]), from_list([12, 34, 56]))
///
/// split(from_list([12, 34, 56]), at: 1)
/// // -> #(from_list([12]), from_list([34, 56]))
///
/// split(from_list([12, 34, 56]), at: 3)
/// // -> #(from_list([12, 34, 56]), from_list([]))
/// ```
pub fn split(array: Array(a), at index: Int) -> #(Array(a), Array(a)) {
  let size = size(array)
  case index < size {
    True -> #(
      generate(index, with: fn(i) { do_unsafe_get(array, i) }),
      generate(size - index, with: fn(i) { do_unsafe_get(array, i + index) }),
    )
    False -> #(array, from_list([]))
  }
}

/// Takes a specific portion of an array, slicing from the given
/// position and stopping after the given length, generating a new array.
/// Negative lengths can be used to take from the end of the array.
/// If the slicing would go out of bounds, returns an error.
///
/// ## Examples
///
/// ```gleam
/// slice(from: from_list([1, 2, 3, 4]), at: 1, take: 2)
/// // -> Ok(from_list([2, 3]))
///
/// slice(from: from_list([1, 2, 3, 4]), at: 4, take: -3)
/// // -> Ok(from_list([2, 3, 4]))
///
/// slice(from: from_list([]), at: 1, take: 2)
/// // -> Error(Nil)
/// ```
pub fn slice(
  from array: Array(a),
  at position: Int,
  take length: Int,
) -> Result(Array(a), Nil) {
  let start = int.min(position, position + length)
  let end = int.max(position, position + length)
  case start < 0 || end > size(array) {
    True -> Error(Nil)
    False ->
      Ok(
        generate(int.absolute_value(length), with: fn(i) {
          do_unsafe_get(array, i + start)
        }),
      )
  }
}

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

/// Combines two arrays into an array of 2-element tuples, where the tuple at
/// position 'i' contains element 'i' from the first array and element 'i' from
/// the second array.
///
/// If one array is longer than the other, the returned array will have the
/// size of the shortest, with the longer array's extra items being ignored.
///
/// ## Examples
///
/// ```gleam
/// zip(from_list([1, 2]), from_list([3, 4]))
/// // -> from_list([#(1, 3), #(2, 4)])
///
/// zip(from_list([1, 2]), from_list([3]))
/// // -> from_list([#(1, 3)])
///
/// zip(from_list([1, 2]), from_list([]))
/// // -> from_list([])
/// ```
pub fn zip(first: Array(a), with second: Array(b)) -> Array(#(a, b)) {
  let len = int.min(size(first), size(second))

  generate(len, with: fn(i) {
    #(do_unsafe_get(first, i), do_unsafe_get(second, i))
  })
}

/// Takes an array of 2-element tuples and returns two arrays.
///
/// ## Examples
///
/// ```gleam
/// unzip(from_list([#(1, 2), #(3, 4)]))
/// // -> #(from_list([1, 3]), from_list([2, 4]))
///
/// unzip([])
/// // -> #(from_list([]), from_list([]))
/// ```
pub fn unzip(input: Array(#(a, b))) -> #(Array(a), Array(b)) {
  #(map(input, fn(pair) { pair.0 }), map(input, fn(pair) { pair.1 }))
}

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
