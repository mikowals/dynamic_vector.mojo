from dynamic_vector import DynamicVector, DynamicVectorSlice
from tests.utils import MojoTest, append_values


fn to_string(vec: DynamicVectorSlice[String], name: String) raises -> String:
    var res = String(name + " (size = " + len(vec) + ") [")
    for i in range(len(vec)):
        if i == len(vec) - 1:
            res += String(vec[i]) + "]"
        else:
            res += String(vec[i]) + ", "
    return res


fn to_string(vec: DynamicVectorSlice[Int], name: String) raises -> String:
    var res = String(name + " (size = " + len(vec) + ") [")
    for i in range(len(vec)):
        if i == len(vec) - 1:
            res += String(vec[i]) + "]"
        else:
            res += String(vec[i]) + ", "
    return res


fn test_create_slice() raises:
    var test = MojoTest("create DynamicVectorSlice")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(1, 3))
    test.assert_equal(
        len(slice), 2, String("expected length ") + 2 + " got " + len(slice)
    )
    test.assert_equal(slice[0], "b", "expected 'b' got " + slice[0])
    test.assert_equal(slice[1], "c", "expected 'c' got " + slice[1])


fn test_slice_bounds() raises:
    var test = MojoTest("basic bounds")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(1, 3))
    test.match_slice(slice._slice, Slice(1, 3, 1), "basic bounds")
    test.match_values(slice, "b", "c")


# Can only test open ended slice with [1::1] syntax, so create second slice
# TODO: test directly on DynamicVector when sugar syntax is fixed
fn test_slice_no_end() raises:
    var test = MojoTest("no end")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var preslice = DynamicVectorSlice[String](Reference(vec), Slice(0, 4))
    var slice = preslice[1::1]
    test.match_slice(slice._slice, Slice(1, 4, 1), "no end")
    test.match_values(slice, "b", "c", "d")


fn test_slice_negative_end() raises:
    var test = MojoTest("negative end")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(-1))
    test.match_slice(slice._slice, Slice(0, 3, 1), "negative end")
    test.match_values(slice, "a", "b", "c")


fn test_slice_negative_start() raises:
    var test = MojoTest("negative start")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(-2, 3))
    test.match_slice(slice._slice, Slice(2, 3, 1), "negative start")


fn test_slice_stride() raises:
    var test = MojoTest("strided bounds")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(1, 4, 2))
    test.match_slice(slice._slice, Slice(1, 4, 2), "strided bounds")
    test.match_values(slice, "b", "d")


fn test_slice_multple_slices() raises:
    var test = MojoTest("multiple slices")
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
    test.match_slice(slice1._slice, Slice(0, 16, 2), "multiple slices")
    var slice2 = slice1[1::3]
    test.match_slice(slice2._slice, Slice(2, 16, 6), "multiple slices")
    var slice3 = slice2[1::2]
    test.match_slice(slice3._slice, Slice(8, 16, 12), "multiple slices")
    test.match_values(slice3, "i")


fn test_slice_setitem() raises:
    var test = MojoTest("setitem")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(1, 3))
    slice[0] = "x"
    slice[1] = "y"
    test.match_values(slice, "x", "y")
    test.match_values(vec, "a", "x", "y", "d")


# TODO: this could be vec[0:2] = vec2[0:2]
fn test_slice_assignment_from_slice() raises:
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
fn test_slice_assignment_from_vector() raises:
    var test = MojoTest("assignment from vector")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var vec2 = DynamicVector[String](capacity=2)
    append_values(vec2, "y", "z")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(1, 3))
    slice.__setitem__(Slice(0, 2), vec2)
    test.match_values(vec, "a", "y", "z", "d")


fn test_slice_iter() raises:
    var test = MojoTest("iter")
    var vec = DynamicVector[String](capacity=4)
    append_values(vec, "a", "b", "c", "d")
    var slice = DynamicVectorSlice[String](Reference(vec), Slice(1, 3))
    var res = String("")
    for i in slice:
        res += i[]
    test.assert_equal(res, "bc", "expected 'bc' got " + res)


fn main() raises:
    test_create_slice()
    test_slice_bounds()
    test_slice_no_end()
    test_slice_negative_end()
    test_slice_negative_start()
    test_slice_stride()
    test_slice_multple_slices()
    test_slice_setitem()
    test_slice_assignment_from_slice()
    test_slice_assignment_from_vector()
    test_slice_iter()
