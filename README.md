# Mojo Reference Demo

An experimental drop in replacement for DynamicVector. It probably has some bugs and it is likely that the nice things it does with References will be implemented in the Standard Library in a more reliable way shortly. But it shows why References are useful and demonstrates new features like `__refitem__` and `__lifetime_of(self)`.

The repo contains:
- The DynamicVector [implementation](https://github.com/mikowals/dynamic_vector.mojo/blob/main/dynamic_vector.mojo#L4).
- An attempt at [DynamicVectorSlice](https://github.com/mikowals/dynamic_vector.mojo/blob/main/dynamic_vector.mojo#L98).
- verbose.mojo - [demonstrates](https://github.com/mikowals/dynamic_vector.mojo/tree/main?tab=readme-ov-file#__setitem__-works-much-better-with-references) avoiding extra copies and deletes.
- vector_benchmark.mojo - shows [time savings](https://github.com/mikowals/dynamic_vector.mojo/tree/main?tab=readme-ov-file#time-savings-when-updating-struct-elements) when updating a 256 x 256 vector of vectors.
- slice.mojo - [exercies DynamicVectorSlice](https://github.com/mikowals/dynamic_vector.mojo/tree/main?tab=readme-ov-file#python-style-slices---var-evens--vec02) and `vec[::]` notation.

# `__setitem__` works much better with References

The current Standard Library implementation has a workaround where `__getitem__` and `__setitem__` are tightly linked. And since `__getitem__` produces a copy this leads to a large amount of extra copies, moves, and deletes. You can see all this extra activity very clearly in a simple 2x2 `DynamicVector[DynamicVector[Verbose]]` where `Verbose` is a custom `struct` that logs all these events.

Running `mojo verbose.mojo` outputs all lifecycle activities from 2x2 nested stdlib vectors vs a 2x2 using References internally. It updates one value and displays the updated value.

Calling `vec[1][1] = 1000` made of stdlib `DynamicVector`s produces: 5 copies, 5 deletes, and 10 moves:

```console
update one value in std lib vector of vectors
copyinit with value: 0 hidden_id: 100
moveinit with value: 0 hidden_id 100
copyinit with value: 1 hidden_id: 101
moveinit with value: 1 hidden_id 101
copyinit with value: 1 hidden_id: 101
moveinit with value: 0 hidden_id 100
del with value: 0 hidden_id 100
moveinit with value: 1 hidden_id 101
del with value: 1 hidden_id 101
copyinit with value: 0 hidden_id: 100
moveinit with value: 0 hidden_id 100
copyinit with value: 1 hidden_id: 101
moveinit with value: 1 hidden_id 101
moveinit with value: 1 hidden_id 101
del with value: 1 hidden_id 101
moveinit with value: 1000 hidden_id 101
moveinit with value: 0 hidden_id 100
del with value: 0 hidden_id 100
moveinit with value: 1 hidden_id 101
del with value: 1 hidden_id 101
finished update in std lib vector of vectors
```

Calling `vec[1][1] = 2000` with Reference based DynamicVector (uses `__refitem__(index)[] = 2000`) does no intermediate copies, deletes, or moves,

```console
update one value in reference based vector of vectors
finished update in reference based vector of vectors
```

# Time savings when updating struct elements

`mojo vector_benchmark.mojo` will time updating each value one by one in 256 x 256 `DynamicVector[DynamicVector[Int]]`.

```console
Std lib vector of vectors:  0.0070529722222222218 seconds
Reference based vector of vectors:  2.2355799664866878e-05 seconds
__setitem__ with References is  315.48736023548634 times faster than the std lib version.
```

This is the time savings by switching to efficient Reference usage - avoiding the extra activity in the previous demo - for a relatively small number of nested fields. While the nesting multiplies the time savings in this example, there will be some savings in any update of a `struct` using `__setitem__` in `DynamicVector`. The larger the `struct` the larger the savings, independent of how small field being updated is. In this example, we are only updating a reference passable ("trivial") Int and it still triggers copies and deletes of sibling vectors. These are avoided if instead you update a Reference.



# Python-style slices - `var evens = vec[0::2]`

`mojo slice_demo.mojo` creates some slices and demonstrates inplace updates since each slice holds a Reference to the original vector.

```console
original vec (size = 16) [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
slice_1 = vec[0::2] (size = 8) [0, 2, 4, 6, 8, 10, 12, 14]
slice_2 = slice_1[0::2] (size = 4) [0, 4, 8, 12]

after slice_2[2] = 1000
slice_2 = slice_1[0::2] (size = 4) [0, 4, 1000, 12]
slice_1 = vec[0::2] (size = 8) [0, 2, 4, 6, 1000, 10, 12, 14]
original vec (size = 16) [0, 1, 2, 3, 4, 5, 6, 7, 1000, 9, 10, 11, 12, 13, 14, 15]
```

The real world use case for something like this is in [Fast Fourier Transform Demo](https://github.com/duckki/field-fft-mojo/blob/main/python/fft-python.py#L15) where the Python-style slices are readable and efficient.
