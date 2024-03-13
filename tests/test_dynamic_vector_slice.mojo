from dynamic_vector import DynamicVector, DynamicVectorSlice
from tests.utils import MojoTest, append_values


fn test_create_slice() raises:
    var test = MojoTest("create")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(1, 3))
    test.assert_equal(len(slice), 2, "size")
    test.assert_equal(slice[0], "b", "slice[0]")
    test.assert_equal(slice[1], "c", "slice[1]")


fn test_start_equals_length() raises:
    var test = MojoTest("start equals length")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(4, 4))
    test.assert_equal(len(slice), 0, "size")


fn test_zero_length_slice() raises:
    var test = MojoTest("zero length slice")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(2, 2))
    test.assert_equal(len(slice), 0, "size")


fn test_modify_vector_affects_slice() raises:
    var test = MojoTest("modify vector affects slice")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(1, 3))
    vec[1] = "x"
    test.assert_equal(slice[0], "x", "slice element")


fn test_bounds() raises:
    var test = MojoTest("basic bounds")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(1, 3))
    test.match_slice(slice._slice, Slice(1, 3, 1), "basic bounds")
    test.match_values(slice, "b", "c")


# Can only test open ended slice with [1::1] syntax, so create second slice
# TODO: test directly on DynamicVector when sugar syntax is fixed
fn test_no_end() raises:
    var test = MojoTest("no end")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var preslice = DynamicVectorSlice[String](Reference(vec), Slice(0, 4))
    var slice = preslice[1::1]
    test.match_slice(slice._slice, Slice(1, 4, 1), "no end")
    test.match_values(slice, "b", "c", "d")


fn test_negative_end() raises:
    var test = MojoTest("negative end")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(-1))
    test.match_slice(slice._slice, Slice(0, 3, 1), "negative end")
    test.match_values(slice, "a", "b", "c")


fn test_negative_start() raises:
    var test = MojoTest("negative start")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(-2, 3))
    test.match_slice(slice._slice, Slice(2, 3, 1), "negative start")


fn test_stride() raises:
    var test = MojoTest("strided bounds")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(1, 4, 2))
    test.match_slice(slice._slice, Slice(1, 4, 2), "strided bounds")
    test.match_values(slice, "b", "d")


fn test_negative_stride() raises:
    var test = MojoTest("negative stride")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(-1, 0, -1))
    test.match_slice(slice._slice, Slice(3, 0, -1), "negative stride")
    test.match_values(slice, "d", "c", "b")


fn test_negative_stride_sugared() raises:
    var test = MojoTest("negative stride sugared")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(0, 4, 1))
    var slice2 = slice[::-1]
    test.match_slice(slice2._slice, Slice(3, -1, -1), "negative stride sugared")
    test.match_values(slice2, "d", "c", "b", "a")


fn test_chained_slices() raises:
    var test = MojoTest("chained slices")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice1 = DynamicVectorSlice[String](Reference(vec), Slice(0, 4))
    var slice2 = slice1[1:3]
    test.assert_equal(len(slice2), 2, "size")
    test.assert_equal(slice2[0], "b", "first element")


fn test_chained_strided_slices() raises:
    var test = MojoTest("chained strided slices")
    var vec = DynamicVector[String](capacity=16)
    append_values(
        vec,
        "a",
        "b",
        "c",
        "d",
        "e",
        "f",
        "g",
        "h",
        "i",
        "j",
        "k",
        "l",
        "m",
        "n",
        "o",
        "p",
    )
    var slice1 = DynamicVectorSlice[String](Reference(vec), Slice(0, 16, 2))
    test.match_slice(slice1._slice, Slice(0, 16, 2), "multiple slices 1")
    var slice2 = slice1[1::3]
    test.match_slice(slice2._slice, Slice(2, 16, 6), "multiple slices 2")
    var slice3 = slice2[1::2]
    test.match_slice(slice3._slice, Slice(8, 16, 12), "multiple slices 3")
    test.match_values(slice3, "i")


fn test_setitem() raises:
    var test = MojoTest("setitem")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(1, 3))
    slice[0] = "x"
    slice[1] = "y"
    test.match_values(slice, "x", "y")
    test.match_values(vec, "a", "x", "y", "d")


# TODO: this could be vec[0:2] = vec2[0:2]
fn test_assignment_from_slice() raises:
    var test = MojoTest("assignment from slice")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var vec2 = DynamicVector[String](capacity=2)
    append_values(vec2, "y", "z")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(0, 2))
    slice.__setitem__(
        Slice(0, 2),
        DynamicVectorSlice[String](Reference(vec2), Slice(0, 2)),
    )
    test.match_values(vec, "y", "z", "c", "d")


# TODO: this could be vec[1:3] = vec2
fn test_assignment_from_vector() raises:
    var test = MojoTest("assignment from vector")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var vec2 = DynamicVector[String](capacity=2)
    append_values(vec2, "y", "z")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(1, 3))
    slice.__setitem__(Slice(0, 2), vec2)
    test.match_values(vec, "a", "y", "z", "d")


fn test_iter() raises:
    var test = MojoTest("iter")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(1, 3))
    var res = String("")
    for i in slice:
        res += i[]
    test.assert_equal(res, "bc", "concatenated result")


fn test_iterate_empty_slice() raises:
    var test = MojoTest("iterate empty slice")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(2, 2))
    var count = 0
    for item in slice:
        count += 1
    test.assert_equal(count, 0, "iteration count")


fn main() raises:
    test_create_slice()
    test_start_equals_length()
    test_zero_length_slice()
    test_modify_vector_affects_slice()
    test_bounds()
    test_no_end()
    test_negative_end()
    test_negative_start()
    test_stride()
    test_negative_stride()
    test_negative_stride_sugared()
    test_chained_slices()
    test_chained_strided_slices()
    test_setitem()
    test_assignment_from_slice()
    test_assignment_from_vector()
    test_iter()
    test_iterate_empty_slice()
