import testing
from dynamic_vector import DynamicVector, DynamicVectorSlice


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

    fn assert_equal(self, a: Int, b: Int, label: String):
        """
        Wraps testing.assert_equal.
        """
        try:
            testing.assert_equal(
                a, b, String("Actual ") + label + " '" + a + "', expected '" + b + "'."
            )

        except e:
            print(e)

    fn assert_equal(self, a: String, b: String, label: String):
        """
        Wraps testing.assert_equal.
        """
        try:
            testing.assert_equal(
                a, b, String("Actual ") + label + " '" + a + "', expected '" + b + "'."
            )
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

    fn match_values(
        self, vec: DynamicVectorSlice[String], *values: String, first_index: Int = 0
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

    fn match_slice(self, result: Slice, expected: Slice, name: String):
        """
        Wraps testing.match_slice.
        """
        try:
            testing.assert_equal(
                result.start,
                expected.start,
                String(name + ": expected start ")
                + expected.start
                + " got "
                + result.start,
            )
            testing.assert_equal(
                result.end,
                expected.end,
                String(name + ": expected end ") + expected.end + " got " + result.end,
            )
            testing.assert_equal(
                result.step,
                expected.step,
                String(name + ": expected step ")
                + expected.step
                + " got "
                + result.step,
            )
        except e:
            print(e)


fn append_values(inout v: DynamicVector[String], *vals: String) raises:
    for i in range(len(vals)):
        v.append(vals[i])


fn append_values(inout v: DynamicVector[Int], *vals: Int) raises:
    for i in range(len(vals)):
        v.append(vals[i])
