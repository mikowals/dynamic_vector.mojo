import testing
from dynamic_vector import DynamicVector


@value
struct MojoTest:
    """
    A utility struct for testing.
    """

    var test_name: String

    fn __init__(inout self, test_name: String):
        self.test_name = test_name
        print("# " + test_name)

    fn assert_true(self, cond: Bool, message: String):
        """
        Wraps testing.assert_true.
        """
        try:
            testing.assert_true(cond, message)
        except e:
            print(e)

    fn assert_equal(self, a: Int, b: Int, message: String):
        """
        Wraps testing.assert_equal.
        """
        try:
            testing.assert_equal(a, b, message)
        except e:
            print(e)

    fn assert_equal(self, a: String, b: String, message: String):
        """
        Wraps testing.assert_equal.
        """
        try:
            testing.assert_equal(a, b, message)
        except e:
            print(e)

    fn match_values(self, vec: DynamicVector[Int], *values: Int, first_index: Int = 0):
        try:
            var count = len(values)
            for i in range(first_index, first_index + count):
                testing.assert_true(
                    vec[i] == values[i - first_index],
                    String("Mismatch at index ")
                    + String(i)
                    + ": expected "
                    + values[i - first_index]
                    + ", got "
                    + vec[i],
                )
        except e:
            print(e)

    fn match_values(
        self, vec: DynamicVector[String], *values: String, first_index: Int = 0
    ):
        try:
            var count = len(values)
            for i in range(first_index, first_index + count):
                testing.assert_true(
                    vec[i] == values[i - first_index],
                    String("Mismatch at index ")
                    + String(i)
                    + ": expected "
                    + values[i - first_index]
                    + ", got "
                    + vec[i],
                )
        except e:
            print(e)
