from tests.test_dynamic_vector import main as test_dynamic_vector
from tests.test_dynamic_vector_slice import main as test_dynamic_vector_slice
from time import now


fn main() raises:
    var start = now()
    test_dynamic_vector()
    var end = now()
    print("All Dynamcic Vector tests passed in ", (end - start) / 1e6, "ms")
    print()
    var start2 = now()
    test_dynamic_vector_slice()
    var end2 = now()
    print("All Dynamcic Vector Slice tests passed in ", (end2 - start2) / 1e6, "ms")
    print()
    print("total time: ", (end2 - start2 + end - start) / 1e6, "ms")
