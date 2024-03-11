from dynamic_vector import DynamicVector, DynamicVectorSlice


fn print_vec(vec: DynamicVector[Int], name: String) -> None:
    print(name, "(size =", len(vec), end=") [")
    for i in range(len(vec)):
        if i == len(vec) - 1:
            print(vec[i], end="]\n")
        else:
            print(vec[i], end=", ")


fn print_slice(vec: DynamicVectorSlice[Int], name: String) raises -> None:
    print(name, "(size =", len(vec), end=") [")
    for i in range(len(vec)):
        if i == len(vec) - 1:
            print(vec[i], end="]\n")
        else:
            print(vec[i], end=", ")


fn main() raises:
    var vec = DynamicVector[Int](capacity=32)
    for i in range(16):
        vec.push_back(i)
    print_vec(vec, "original vec")
    # vec[0::2] doesn't work because of #1871 (https://github.com/modularml/mojo/issues/1871)
    var slice_1 = vec.__getitem__(Slice(0, 16, 2))
    print_slice(slice_1, "slice_1 = vec[0::2]")

    var slice_2 = slice_1[0::2]
    print_slice(slice_2, "slice_2 = slice_1[0::2]")

    print()
    slice_2[2] = 1000
    print("after slice_2[2] = 1000")
    print_slice(slice_2, "slice_2 = slice_1[0::2]")
    print_slice(slice_1, "slice_1 = vec[0::2]")
    print_vec(vec, "original vec")
    print()
    var tmp = DynamicVector[Int](capacity=2)
    tmp.push_back(100)
    tmp.push_back(200)

    # Workaround for syntax sugar issues. Should become vec[1:3] = tmp.
    var tmp_slice = DynamicVectorSlice[Int](Reference(vec), Slice(0, len(vec)))
    tmp_slice.__setitem__(Slice(1, 3), tmp)
    print("after vec[1:3] = [100, 200]")
    print_vec(vec, "original vec")
