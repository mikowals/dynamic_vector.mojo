from memory import UnsafePointer
from memory.unsafe_pointer import (
    destroy_pointee,
    initialize_pointee,
    move_from_pointee,
    move_pointee,
)
from algorithm.swap import swap
from utils.variant import Variant
import math

alias i1 = __mlir_type.i1
alias i1_1 = __mlir_attr.`1: i1`
alias i1_0 = __mlir_attr.`0: i1`
alias NoneOrInt = Variant[NoneType, Int]
alias MAX_FINITE = math.limit.max_finite[DType.int64]().__int__()


struct DynamicVector[T: CollectionElement](Sized, CollectionElement):
    var data: UnsafePointer[T]
    var size: Int
    var capacity: Int

    @always_inline
    fn __init__(inout self, *, capacity: Int):
        self.capacity = capacity
        self.data = UnsafePointer[T].alloc(capacity)
        self.size = 0

    @always_inline
    fn __del__(owned self):
        for i in range(self.size):
            destroy_pointee(self.data + i)
        self.data.free()

    @always_inline
    fn __copyinit__(inout self, other: Self):
        self.capacity = other.capacity
        self.size = other.size
        self.data = UnsafePointer[T].alloc(self.capacity)
        for i in range(self.size):
            var new_value = other[i]
            initialize_pointee(self.data + i, new_value)

    @always_inline
    fn __moveinit__(inout self, owned other: Self):
        self.capacity = other.capacity
        self.size = other.size
        self.data = other.data
        other.data = UnsafePointer[T]()
        other.size = 0
        other.capacity = 0

    fn append(inout self, owned value: T):
        if self.size == self.capacity:
            self.reserve(self.capacity * 2)
        self.data[self.size] = value^
        self.size += 1

    fn push_back(inout self, owned value: T):
        self.append(value^)

    @always_inline
    fn pop_back(inout self) -> T:
        self.size -= 1
        return move_from_pointee(self.data + self.size)

    fn __refitem__(
        inout self,
        index: Int,
    ) -> Reference[T, __mlir_attr.`1: i1`, __lifetime_of(self)]:
        return (self.data + index)[]

    @always_inline
    fn reserve(inout self, new_capacity: Int):
        if new_capacity <= self.capacity:
            return
        var new_data = UnsafePointer[T].alloc(new_capacity)
        for i in range(self.size):
            move_pointee(src=self.data + i, dst=new_data + i)
        self.data.free()
        self.data = new_data
        self.capacity = new_capacity

    @always_inline
    fn resize(inout self, new_size: Int, value: T):
        if new_size > self.size:
            if new_size > self.capacity:
                self.reserve(new_size)
            for _ in range(self.size, new_size):
                self.append(value)
        elif new_size < self.size:
            for i in range(new_size, self.size):
                destroy_pointee(self.data + i)
            self.size = new_size

    @always_inline
    fn clear(inout self):
        for i in range(self.size):
            destroy_pointee(self.data + i)
        self.size = 0

    @always_inline
    fn extend(inout self, owned other: Self):
        self.reserve(self.size + len(other))
        for i in range(len(other)):
            move_pointee(src=other.data + i, dst=self.data + self.size + i)
        self.size += len(other)
        other.size = 0

    @always_inline
    fn reverse(inout self):
        var a = self.data
        var b = self.data + self.size - 1
        while a < b:
            # a[0] and b[0] is using AnyPointer.__refitem__ and automatic dereference
            swap[T](a[0], b[0])
            a = a + 1
            b = b - 1

    # This is only required if self is in an alias.
    # Otherwise it tries next __getitem__ where self is inout so an immuatable alias there causes error.
    @always_inline
    fn __getitem__(self, index: Int) -> T:
        return self.data[index]

    @always_inline
    fn __getitem__(
        inout self, _slice: Python3Slice
    ) raises -> DynamicVectorSlice[T, __lifetime_of(self)]:
        return DynamicVectorSlice[T](Reference(self), _slice)

    @always_inline
    fn __len__(self) -> Int:
        return self.size

    @always_inline
    fn __iter__(
        inout self,
    ) -> _DynamicVectorIter[T, i1_1, __lifetime_of(self)]:
        return _DynamicVectorIter[T, i1_1, __lifetime_of(self)](Reference(self))

    @always_inline
    fn steal_data(inout self) -> UnsafePointer[T]:
        var res = self.data
        self.data = UnsafePointer[T]()
        self.size = 0
        self.capacity = 0
        return res


# Avoid __init__(Ref, Slice, Size) initializer because we calculate size.
@register_passable
struct DynamicVectorSlice[T: CollectionElement, L: MutLifetime](
    Sized, CollectionElement
):
    var data: Reference[DynamicVector[T], i1_1, L]
    var _slice: Slice
    var size: Int

    @always_inline
    fn __init__(
        inout self,
        data: Reference[DynamicVector[T], i1_1, L],
        _slice: Python3Slice,
    ) raises:
        self.data = data
        self._slice = _slice.to_numeric_slice(len(data[]))
        self.size = len(self._slice)

    @always_inline
    fn __init__(
        inout self,
        other: Self,
        _slice: Python3Slice,
    ) raises:
        self.data = other.data
        self._slice = Self.adapt_slice(_slice, other._slice, len(other))
        self.size = len(self._slice)

    fn __copyinit__(inout self, other: Self):
        self.data = other.data
        self._slice = other._slice
        self.size = other.size

    @always_inline
    fn __refitem__(self, index: Int) -> Reference[T, i1_1, L]:
        return self.data[].data.__refitem__(self._slice[index])

    @always_inline
    fn __getitem__(inout self, _slice: Python3Slice) raises -> Self:
        return Self(self, _slice)

    @always_inline
    fn __len__(self) -> Int:
        return self.size

    @always_inline
    fn to_vector(self) raises -> DynamicVector[T]:
        var res = DynamicVector[T](capacity=len(self))
        for i in range(len(self)):
            res.append(self[i])
        return res

    @always_inline
    @staticmethod
    fn adapt_slice(
        _slice: Python3Slice, base_slice: Slice, size: Int
    ) raises -> Slice:
        """Helper function adapt the received slice to correct indices of the underlying vector.

        Args:
            _slice: The desired slice specified in current slice indices.
            base_slice: The _slice field of the current slice.
            size: The size of the current slice being sliced.

        Returns:
            A new slice with indices of the underlying vector.
        """

        var result_slice = _slice.to_numeric_slice(size)
        # bound results to be within the previous slice bounds
        var upper_bound_exclusive = base_slice.end if base_slice.step > 0 else base_slice.start + 1
        var lower_bound_exclusive = base_slice.start - 1 if base_slice.step > 0 else base_slice.end

        # convert to indices of the base_slice
        result_slice.start = base_slice[result_slice.start]
        result_slice.end = base_slice[result_slice.end]

        # Detetermine step and direction of resulting slice
        result_slice.step *= base_slice.step

        # bounds checks with adjustment for inclusive bound on start
        if result_slice.step > 0:
            result_slice.start = math.max(
                lower_bound_exclusive + 1, result_slice.start
            )
            result_slice.end = math.min(upper_bound_exclusive, result_slice.end)
        else:
            result_slice.start = math.min(
                upper_bound_exclusive - 1, result_slice.start
            )
            result_slice.end = math.max(lower_bound_exclusive, result_slice.end)
        return result_slice

    @always_inline
    fn __setitem__(
        inout self, _slice: Python3Slice, owned values: DynamicVectorSlice[T]
    ) raises:
        var target_slice = DynamicVectorSlice[T](self, _slice)
        if len(target_slice) != len(values):
            raise Error(
                String("slice assignment size mismatch: received ")
                + len(values)
                + "new values but destination expects "
                + len(target_slice)
            )
        for i in range(len(target_slice)):
            target_slice[i] = values[i]

    @always_inline
    fn __setitem__(
        inout self, _slice: Slice, owned value: DynamicVector[T]
    ) raises:
        self.__setitem__(
            _slice,
            DynamicVectorSlice[T](
                Reference(value), Python3Slice(0, len(value), 1)
            ),
        )

    @always_inline
    fn __iter__(inout self) -> _DynamicVectorSliceIter[T, L]:
        return _DynamicVectorSliceIter[T, L](self)

    # Useful print method for debugging
    # Static with T = Int because T might not be Stringable
    @staticmethod
    fn to_string(
        inout vec: DynamicVectorSlice[Int], name: String
    ) raises -> String:
        var res = String(name + " (size = " + len(vec) + ") [")
        for val in vec:
            res += String(val[]) + ", "

        return res[:-2] + "]"

    # Useful print method for debugging
    # Static with T = String because T might not be Stringable
    @staticmethod
    fn to_string(
        inout vec: DynamicVectorSlice[String], name: String
    ) raises -> String:
        var res = String(name + " (size = " + len(vec) + ") [")
        for val in vec:
            res += val[] + ", "

        return res[:-2] + "]"


@value
struct _DynamicVectorIter[
    T: CollectionElement, mutability: i1, lifetime: AnyLifetime[mutability].type
](CollectionElement, Sized):
    var index: Int
    var src: Reference[DynamicVector[T], mutability, lifetime]

    @always_inline
    fn __init__(
        inout self, src: Reference[DynamicVector[T], mutability, lifetime]
    ):
        self.index = 0
        self.src = src

    # TODO: Check if this can be simplified after #1921 was fixed.
    # Mojo #1921: https://github.com/modularml/mojo/issues/1921#event-12066222345
    @always_inline
    fn __next__(inout self) -> Reference[T, i1_0, lifetime]:
        var ptr = self.src[].data
        var res = ptr.__refitem__(self.index)
        self.index += 1
        return res

    @always_inline
    fn __len__(self) -> Int:
        return len(self.src[]) - self.index


@value
struct _DynamicVectorSliceIter[T: CollectionElement, lifetime: MutLifetime](
    CollectionElement, Sized
):
    var index: Int
    var src: DynamicVectorSlice[T, lifetime]

    @always_inline
    fn __init__(inout self, src: DynamicVectorSlice[T, lifetime]):
        self.index = 0
        self.src = src

    @always_inline
    fn __next__(inout self) -> Reference[T, i1_1, lifetime]:
        var res = self.src.__refitem__(self.index)
        self.index += 1
        return res

    @always_inline
    fn __len__(self) -> Int:
        return len(self.src) - self.index


@value
struct Python3Slice:
    """Slice that preserves empty inputs as None for correct handling of [::-1] etc.
    """

    var start: NoneOrInt
    var end: NoneOrInt
    var step: NoneOrInt

    fn __init__(inout self, slice: Slice):
        debug_assert(slice.start >= 0, "Slice start must not be negative.")
        debug_assert(slice.end >= 0, "Slice end must not be negative.")
        self.start = slice.start
        self.end = slice.end
        self.step = slice.step

    fn __init__(inout self, start: Int, end: Int):
        self.start = start
        self.end = end
        self.step = 1

    fn __init__(inout self, end: Int):
        self.start = None
        self.end = end
        self.step = 1

    fn _has_step(self) -> Bool:
        return self.step.isa[Int]()

    fn _has_start(self) -> Bool:
        return self.start.isa[Int]()

    fn _has_end(self) -> Bool:
        return self.end.isa[Int]()

    fn to_numeric_slice(self, size: Int = MAX_FINITE) raises -> Slice:
        """Create a new slice with all indices converted to valid numeric indices.

        Nones are replaced with upper and lower bounds based on size. Negative indices are
        converted to indices from the right. With negative step, if end starts as None it will
        be set to -1 for exclusive bound.

        Args:
            size: The length of the vector being sliced. Defaults to maximum finite Int64 value.

        Returns:
            A new slice with indices converted based on size.
        """
        var step = 1 if not self._has_step() else self.step.get[Int]()[]
        if step == 0:
            raise Error("Step cannot be zero")
        var default_start = 0 if step > 0 else size - 1
        var default_end = size if step > 0 else -1
        var start = default_start
        var end = default_end
        if self._has_start():
            start = self.start.get[Int]()[]
            if start < 0:
                start += size

        if self._has_end():
            end = self.end.get[Int]()[]
            if end < 0:
                end += size

        if step < 0:
            start = math.min(start, default_start)
        else:
            end = math.min(end, default_end)

        return Slice(start, end, step)
