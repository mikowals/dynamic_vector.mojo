from dynamic_vector import DynamicVector, DynamicVectorSlice, Python3Slice
from testing import assert_equal
from tests.utils import MojoTest, append_values


@parameter
fn assert_equal_with_message(
    test: MojoTest, actual: Int, expected: Int, label: String
) raises:
    test.assert_equal(
        actual, expected, label + " - Expected: " + expected + ", Actual: " + actual
    )


@value
struct Settable(CollectionElement):
    var value: Int

    fn set_value(inout self, v: Int):
        self.value = v

    fn get_value(self) -> Int:
        return self.value


fn test_create_dynamic_vector() raises:
    var test = MojoTest("create DynamicVector")
    var v = DynamicVector[Int](capacity=2)

    test.assert_true(len(v) == 0, "initial size")
    test.assert_true(v.capacity == 2, "initial capacity")


fn test_push_back() raises:
    var test = MojoTest("push_back")
    var v = DynamicVector[Int](capacity=2)
    append_values(v, 1, 2, 3)
    test.assert_equal(len(v), 3, "size")
    test.match_values(v, 1, 2, 3)
    test.assert_equal(v.capacity, 4, "capacity")


fn test_append() raises:
    var test = MojoTest("append")
    var v = DynamicVector[String](capacity=2)
    append_values(v, "abc", "def", "ghi")
    test.assert_equal(len(v), 3, "size")
    test.match_values(v, "abc", "def", "ghi")
    test.assert_equal(v.capacity, 4, "capacity")


fn test_append_zero_capacity() raises:
    var test = MojoTest("append_zero_capacity")
    var v = DynamicVector[Int](capacity=0)
    v.append(1)
    test.assert_equal(len(v), 1, "size after append")
    test.assert_equal(v[0], 1, "v[0]")


fn test_resize_larger() raises:
    var test = MojoTest("resize")
    var v = DynamicVector[Int](capacity=1)
    v.resize(2, 7)
    test.assert_equal(len(v), 2, "size")
    test.match_values(v, 7, 7)
    test.assert_equal(v.capacity, 2, "capacity")


fn test_resize_smaller() raises:
    var test = MojoTest("resize smaller")
    var v = DynamicVector[Int](capacity=2)
    append_values(v, 1, 2)
    v.resize(1, 0)
    test.assert_equal(len(v), 1, "size")
    test.assert_equal(v[0], 1, "v[0]")
    test.assert_equal(v.capacity, 2, "capacity")


fn test_resize_current_size() raises:
    var test = MojoTest("resize_current_size")
    var v = DynamicVector[Int](capacity=2)
    append_values(v, 1, 2)
    v.resize(len(v), 0)
    test.assert_equal(len(v), 2, "size")
    test.match_values(v, 1, 2)


fn test_pop_back() raises:
    var test = MojoTest("pop_back")
    var v = DynamicVector[Int](capacity=2)
    append_values(v, 1, 2, 3)
    var val = v.pop_back()
    test.assert_equal(len(v), 2, "size")
    test.assert_equal(val, 3, "first popped value")
    val = v.pop_back()
    test.assert_equal(len(v), 1, "size 1")
    test.assert_equal(val, 2, "second popped value")
    val = v.pop_back()
    test.assert_equal(len(v), 0, "size 0")
    test.assert_equal(val, 1, "third popped value")


fn test_pop_back_empty() raises:
    var test = MojoTest("pop_back_empty")
    var v = DynamicVector[Int](capacity=2)
    var val = v.pop_back()
    test.assert_true(True, "pop_back on empty did not crash")


fn test_capacity_increase() raises:
    var test = MojoTest("capacity increase")
    var v = DynamicVector[Int](capacity=2)
    append_values(v, 1, 2, 3)
    test.assert_equal(v.capacity, 4, "capacity")
    v.push_back(4)
    test.match_values(v, 1, 2, 3, 4)


fn test_getitem() raises:
    var test = MojoTest("getitem")
    var v = DynamicVector[Settable](capacity=2)
    v.push_back(Settable(1))
    v.push_back(Settable(2))
    var a = v[0]
    a.set_value(100)
    test.assert_equal(a.get_value(), 100, "value")
    test.assert_equal(v[0].get_value(), 1, "value")


fn test_setitem() raises:
    var test = MojoTest("setitem")
    var v = DynamicVector[Int](capacity=2)
    append_values(v, 1, 2)
    v[0] = 3
    test.match_values(v, 3, 2)


fn test_getitem_setitem_valid_index() raises:
    var test = MojoTest("getitem_setitem_valid_index")
    var v = DynamicVector[Int](capacity=2)
    append_values(v, 1, 2)
    var item = v[1]
    test.assert_equal(item, 2, "v[1]")
    v[1] = 3
    test.assert_equal(v[1], 3, "v[1]")


fn test_copyinit() raises:
    var test = MojoTest("copyinit")
    var v = DynamicVector[Int](capacity=2)
    append_values(v, 1, 2)
    var v2 = v
    test.assert_equal(len(v2), 2, "size")
    test.match_values(v2, 1, 2)
    v2[0] = 3
    test.assert_equal(v2[0], 3, "v2[0]")
    test.assert_equal(v[0], 1, "v[0]")


fn test_moveinit() raises:
    var test = MojoTest("moveinit")
    var v = DynamicVector[Int](capacity=2)
    var orig_ptr = v.data
    append_values(v, 1, 2)
    var v2 = v ^
    test.assert_equal(len(v2), 2, "size")
    test.match_values(v2, 1, 2)
    v2[0] = 3
    test.assert_equal(v2[0], 3, "v2[0]")
    test.assert_true(orig_ptr == v2.data, "data pointer is the same")


fn test_delete() raises:
    var test = MojoTest("delete")
    var v = DynamicVector[Int](capacity=2)
    var ptr = v.data
    v.push_back(1)
    _ = v ^
    """
    Need to force clean up and check pointer is freed but the below fails
    test.assert_true(not ptr, "data pointer is null")
    """


fn test_refitem() raises:
    var test = MojoTest("refitem")
    var v = DynamicVector[Int](capacity=2)
    append_values(v, 1, 2)
    var ref = v.__refitem__(0)
    var x = ref.mlir_ref_type
    test.assert_equal(ref[], 1, "v[0]")


fn test_slice() raises:
    var test = MojoTest("slice")
    var v = DynamicVector[Int](capacity=2)
    append_values(v, 1, 2, 3)
    var slice = v.__getitem__(Python3Slice(1, 3))
    test.assert_equal(len(slice), 2, "slice length")
    test.assert_equal(slice[1], 3, "slice[1]")
    slice[0] = 4
    test.assert_equal(v[1], 4, "original element")


fn test_clear() raises:
    var test = MojoTest("clear")
    var v = DynamicVector[Int](capacity=2)
    append_values(v, 1, 2)
    v.clear()
    test.assert_equal(len(v), 0, "size")
    test.assert_equal(v.capacity, 2, "capacity")


fn test_append_after_clear() raises:
    var test = MojoTest("append_after_clear")
    var v = DynamicVector[Int](capacity=2)
    append_values(v, 1, 2)
    v.clear()
    test.assert_equal(len(v), 0, "size after clear")
    append_values(v, 3, 4)
    test.assert_equal(len(v), 2, "size after append")
    test.match_values(v, 3, 4)


fn test_extend() raises:
    var test = MojoTest("extend")
    var v = DynamicVector[Int](capacity=2)
    append_values(v, 1, 2)
    var v2 = DynamicVector[Int](capacity=2)
    append_values(v2, 3, 4)
    v.extend(v2)
    test.assert_equal(len(v), 4, "size")
    test.match_values(v, 1, 2, 3, 4)
    test.assert_equal(v.capacity, 4, "capacity")


fn test_extend_with_self() raises:
    var test = MojoTest("extend_with_self")
    var v = DynamicVector[Int](capacity=2)
    append_values(v, 1, 2)
    v.extend(v)
    test.assert_equal(len(v), 4, "size after extend with self")
    test.match_values(v, 1, 2, 1, 2)


fn test_reverse_even() raises:
    var test = MojoTest("reverse")
    var v = DynamicVector[String](capacity=5)
    append_values(v, "a", "b", "c", "d", "e")
    v.reverse()
    test.match_values(v, "e", "d", "c", "b", "a")


fn test_reverse_odd() raises:
    var test = MojoTest("reverse")
    var v = DynamicVector[String](capacity=5)
    append_values(v, "a", "b", "c", "d")
    v.reverse()
    test.match_values(v, "d", "c", "b", "a")


fn test_iter() raises:
    var test = MojoTest("iter")
    var v = DynamicVector[Int](capacity=5)
    append_values(v, 1, 2, 3, 4)
    var sum = 0
    for i in v:
        sum += i[]
    test.assert_equal(sum, 10, "sum")


fn test_iter_next() raises:
    var test = MojoTest("iter __next__")
    var v = DynamicVector[Int](capacity=5)
    append_values(v, 1, 2, 3, 4)
    var iter = v.__iter__()
    test.assert_equal(len(iter), 4, "iter length")
    var val = iter.__next__()
    test.assert_equal(val[], 1, "first value")
    test.assert_equal(len(iter), 3, "iter length")


fn test_steal_data() raises:
    var test = MojoTest("steal_data")
    var v = DynamicVector[Int](capacity=2)
    var orig_data = v.data
    append_values(v, 1, 2)
    var data = v.steal_data()
    test.assert_equal(len(v), 0, "vector size")
    test.assert_equal(v.capacity, 0, "vector capacity")
    test.assert_true(not v.data, "vector data is null")
    test.assert_equal(data, orig_data, "stolen pointer")


fn test_as_alias() raises:
    var test = MojoTest("assigmnet to alias")

    @parameter
    fn create_vector() -> DynamicVector[Int]:
        var v = DynamicVector[Int](capacity=2)
        v.append(1)
        v.append(2)
        return v

    alias vec = create_vector()
    test.assert_equal(len(vec), 2, "vector length")
    # compile time error without defining __getitem__ to avoid using __refitem__
    test.assert_equal(vec[0], 1, "alias access")


fn main() raises:
    test_create_dynamic_vector()
    test_push_back()
    test_append()
    test_append_zero_capacity()
    test_resize_larger()
    test_resize_smaller()
    test_resize_current_size()
    test_pop_back()
    test_pop_back_empty()
    test_capacity_increase()
    test_getitem()
    test_setitem()
    test_getitem_setitem_valid_index()
    test_copyinit()
    test_moveinit()
    test_delete()
    test_refitem()
    test_slice()
    test_clear()
    test_append_after_clear()
    test_extend()
    test_extend_with_self()
    test_reverse_even()
    test_reverse_odd()
    test_iter()
    test_iter_next()
    test_steal_data()
    test_as_alias()
