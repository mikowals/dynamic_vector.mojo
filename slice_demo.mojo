from dynamic_vector import DynamicVector, DynamicVectorSlice


fn main():
    var vec = DynamicVector[Int](capacity=32)
    for i in range(16):
        vec.push_back(i)
    print("original vec (size =", len(vec), end=") [")
    for i in range(len(vec)):
        if i == len(vec) - 1:
            print(vec[i], end="]\n")
        else:
            print(vec[i], end=", ")
    # vec[0::2] doesn't work because of #1871 (https://github.com/modularml/mojo/issues/1871)
    var slice_1 = vec.__getitem__(Slice(0, 16, 2))

    print("slice_1 = vec[0::2] (size =", len(slice_1), end=") [")
    for i in range(len(slice_1)):
        if i == len(slice_1) - 1:
            print(slice_1[i], end="]\n")
        else:
            print(slice_1[i], end=", ")
    var slice_2 = slice_1[0::2]
    print("slice_2 = slice_1[0::2] (size =", len(slice_2), end=") [")
    for i in range(len(slice_2)):
        if i == len(slice_2) - 1:
            print(slice_2[i], end="]\n")
        else:
            print(slice_2[i], end=", ")

    print()
    slice_2[2] = 1000
    print("after slice_2[2] = 1000")
    print("slice_2 = slice_1[0::2] (size =", len(slice_2), end=") [")
    for i in range(len(slice_2)):
        if i == len(slice_2) - 1:
            print(slice_2[i], end="]\n")
        else:
            print(slice_2[i], end=", ")

    print("slice_1 = vec[0::2] (size =", len(slice_1), end=") [")
    for i in range(len(slice_1)):
        if i == len(slice_1) - 1:
            print(slice_1[i], end="]\n")
        else:
            print(slice_1[i], end=", ")

    print("original vec (size =", len(vec), end=") [")
    for i in range(len(vec)):
        if i == len(vec) - 1:
            print(vec[i], end="]\n")
        else:
            print(vec[i], end=", ")
