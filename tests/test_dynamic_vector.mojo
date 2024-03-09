from dynamic_vector import DynamicVector, DynamicVectorSlice
from testing import assert_equal
from tests.utils import MojoTest


fn test_create_dynamic_vector() raises:
    var test = MojoTest("create DynamicVector")
    var v = DynamicVector[Int](capacity=2)
    test.assert_true(len(v) == 0, "initial size 0")
    test.assert_true(v.capacity == 2, "initial capacity 2")


fn test_push_back() raises:
    var test = MojoTest("push_back")
    var v = DynamicVector[Int](capacity=2)
    v.push_back(1)
    test.assert_equal(len(v), 1, "size 1")
    test.assert_equal(v[0], 1, "value 1")
    v.push_back(2)
    test.assert_equal(len(v), 2, "size 2")
    test.assert_equal(v[1], 2, "value 2")
    v.push_back(3)
    test.assert_equal(len(v), 3, "size 3")
    test.assert_equal(v[2], 3, "value 3")
    test.assert_equal(v.capacity, 4, "capacity 4")


fn test_append() raises:
    var test = MojoTest("append")
    var v = DynamicVector[String](capacity=2)
    v.append(String("abc"))
    test.assert_equal(len(v), 1, "size 1")
    test.assert_equal(v[0], "abc", "value abc")
    v.append(String("def"))
    test.assert_equal(len(v), 2, "size 2")
    test.assert_equal(v[1], "def", "value def")
    v.append(String("ghi"))
    test.assert_equal(len(v), 3, "size 3")
    test.assert_equal(v[2], "ghi", "value ghi")
    test.assert_equal(v.capacity, 4, "capacity 4")


fn test_resize() raises:
    var test = MojoTest("resize")
    var v = DynamicVector[Int](capacity=2)
    v.resize(4, 7)
    test.assert_equal(len(v), 4, "size 4")
    test.assert_equal(v[0], 7, "value 7")
    test.assert_equal(v[1], 7, "value 7")
    test.assert_equal(v[2], 7, "value 7")
    test.assert_equal(v[3], 7, "value 7")
    test.assert_equal(v.capacity, 4, "capacity 4")


fn test_pop_back() raises:
    var test = MojoTest("pop_back")
    var v = DynamicVector[Int](capacity=2)
    v.push_back(1)
    v.push_back(2)
    v.push_back(3)
    var val = v.pop_back()
    test.assert_equal(len(v), 2, "size 2")
    test.assert_equal(val, 3, "value 3")
    val = v.pop_back()
    test.assert_equal(len(v), 1, "size 1")
    test.assert_equal(val, 2, "value 2")
    val = v.pop_back()
    test.assert_equal(len(v), 0, "size 0")
    test.assert_equal(val, 1, "value 1")


fn test_capacity_increase() raises:
    var test = MojoTest("capacity increase")
    var v = DynamicVector[Int](capacity=2)
    v.push_back(1)
    v.push_back(2)
    v.push_back(3)
    test.assert_equal(v.capacity, 4, "capacity 4")
    v.push_back(4)
    test.assert_equal(v[0], 1, "still value 1")
    test.assert_equal(v[1], 2, "still value 2")
    test.assert_equal(v[2], 3, "value 3")
    test.assert_equal(v[3], 4, "value 4")


fn test_getitem() raises:
    var test = MojoTest("getitem")
    var v = DynamicVector[Int](capacity=2)
    v.push_back(1)
    v.push_back(2)
    test.assert_equal(v[0], 1, "value 1")
    test.assert_equal(v[1], 2, "value 2")
    var a = v[0]
    a = 2
    test.assert_equal(v[0], 1, "still value 1")


fn test_setitem() raises:
    var test = MojoTest("setitem")
    var v = DynamicVector[Int](capacity=2)
    v.push_back(1)
    v.push_back(2)
    v[0] = 3
    test.assert_equal(v[0], 3, "value 3")
    test.assert_equal(v[1], 2, "value 2")


fn test_copyinit() raises:
    var test = MojoTest("copyinit")
    var v = DynamicVector[Int](capacity=2)
    v.push_back(1)
    v.push_back(2)
    var v2 = v
    test.assert_equal(len(v2), 2, "size 2")
    test.assert_equal(v2[0], 1, "value 1")
    test.assert_equal(v2[1], 2, "value 2")
    v2[0] = 3
    test.assert_equal(v2[0], 3, "value 3")
    test.assert_equal(v[0], 1, "value still 1")


fn test_moveinit() raises:
    var test = MojoTest("moveinit")
    var v = DynamicVector[Int](capacity=2)
    var orig_ptr = v.data
    v.push_back(1)
    v.push_back(2)
    var v2 = v ^
    test.assert_equal(len(v2), 2, "size 2")
    test.assert_equal(v2[0], 1, "value 1")
    test.assert_equal(v2[1], 2, "value 2")
    v2[0] = 3
    test.assert_equal(v2[0], 3, "value 3")
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
    v.push_back(1)
    v.push_back(2)
    var ref = v.__refitem__(0)
    var x = ref.mlir_ref_type
    test.assert_equal(ref[], 1, "value 1")


fn test_slice() raises:
    var test = MojoTest("slice")
    var v = DynamicVector[Int](capacity=2)
    v.push_back(1)
    v.push_back(2)
    v.push_back(3)
    var slice = v.__getitem__(Slice(1, 3))
    test.assert_equal(len(slice), 2, "slice length = 2")
    test.assert_equal(slice[1], 3, "value 3")
    slice[0] = 4
    test.assert_equal(v[1], 4, "original element contains 4")


fn main() raises:
    test_create_dynamic_vector()
    test_push_back()
    test_append()
    test_resize()
    test_pop_back()
    test_capacity_increase()
    test_getitem()
    test_setitem()
    test_copyinit()
    test_moveinit()
    test_delete()
    test_refitem()
    test_slice()
