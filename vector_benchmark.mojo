from dynamic_vector import DynamicVector, DynamicVectorSlice
from collections import List
from random import randint, randn, random_si64
from benchmark import run


@always_inline
fn vector_of_vectors(size: Int = 256) -> Float64:
    var vec_outer = List[List[Int]](capacity=size)
    for i in range(size):
        var vec_inner = List[Int](capacity=size)
        for j in range(size):
            vec_inner.append(j)
        vec_outer.append(vec_inner)

    @always_inline
    @parameter
    fn wrapper():
        for i in range(size):
            var val = int(random_si64(0, 100))
            for j in range(size):
                vec_outer[i][j] = val

    var report = run[wrapper](min_runtime_secs=0.2, max_runtime_secs=1.0)
    print("Std lib vector of vectors:", report.mean("ms"), "milliseconds")
    _ = (vec_outer,)
    return report.mean()


@always_inline
fn vector_of_vectors_2(size: Int = 256) -> Float64:
    var vec_outer = DynamicVector[DynamicVector[Int]](capacity=size)
    for i in range(size):
        var vec_inner = DynamicVector[Int](capacity=size)
        for j in range(size):
            vec_inner.push_back(j)
        vec_outer.push_back(vec_inner)

    @always_inline
    @parameter
    fn wrapper():
        for i in range(size):
            var val = int(random_si64(0, 100))
            for j in range(size):
                vec_outer[i][j] = val

    var report = run[wrapper](min_runtime_secs=0.2, max_runtime_secs=1.0)
    print(
        "Reference based vector of vectors:", report.mean("ms"), "milliseconds"
    )
    _ = (vec_outer,)
    return report.mean()


fn main():
    print("update every element one by one in 256 x 256 vector of vectors.")
    print()
    var time_one = vector_of_vectors()
    var time_two = vector_of_vectors_2()
    print(
        "__setitem__ with References is ",
        time_one / time_two,
        "times faster than the std lib version.",
    )
