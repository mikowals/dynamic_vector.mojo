from dynamic_vector import DynamicVector, DynamicVectorSlice
from collections.vector import DynamicVector as StdDynamicVector


struct Verbose(CollectionElement):
    var value: Int
    var hidden_id: Int

    fn __init__(inout self, value: Int):
        print("init", value)
        self.value = value
        self.hidden_id = value + 100

    fn print(self, name: String):
        print(name, "value:", self.value, "hidden_id", self.hidden_id)

    fn __copyinit__(inout self, other: Self):
        print("copyinit with value:", other.value, "hidden_id:", other.hidden_id)
        self.value = other.value
        self.hidden_id = other.hidden_id

    fn __moveinit__(inout self, owned other: Self):
        print("moveinit with value:", other.value, "hidden_id", other.hidden_id)
        self.value = other.value
        self.hidden_id = other.hidden_id

    fn __del__(owned self):
        print("del with value:", self.value, "hidden_id", self.hidden_id)

    fn get_value(self) -> Int:
        return self.value

    fn set_value(inout self, new_value: Int):
        self.value = new_value


fn main():
    print("show init, copy, move, and delete for objects in vector of vectors.")
    print()
    print("build std lib 2x2 vector of vectors")
    var outer_1 = StdDynamicVector[StdDynamicVector[Verbose]](capacity=2)
    for i in range(2):
        var inner = StdDynamicVector[Verbose](capacity=2)
        for j in range(2):
            inner.push_back(Verbose(j))
        outer_1.push_back(inner)
    print("finished building std lib vector of vectors")
    print()
    print("build reference based 2x2 vector of vectors")
    var outer_2 = DynamicVector[DynamicVector[Verbose]](capacity=2)
    for i in range(2):
        var inner = DynamicVector[Verbose](capacity=2)
        for j in range(2):
            inner.push_back(Verbose(j + 2))
        outer_2.push_back(inner)
    print("finished building reference based vector of vectors")
    print()

    print("update one value in std lib vector of vectors")
    outer_1[1][1].value = 1000
    print("finished update in std lib vector of vectors")
    print()
    print("fetch from std lib vector of vectors")
    print("confirm std lib vector of vectors update at [1][1]:", outer_1[1][1].value)
    print("finished fetch from std lib vector of vectors")
    print()

    print("update one value in reference based vector of vectors")
    outer_2[1][1].value = 2000
    print("finished update in reference based vector of vectors")
    print()
    print("fetch from reference based vector of vectors")
    print(
        "confirm reference based vector of vectors update at [1][1]:",
        outer_2[1][1].value,
    )
    print("finished fetch from reference based vector of vectors")
    print()

    print("verbose cleanup")
    _ = (outer_1, outer_2)
