# Calc simple CLI calculator

A lot of times I just want to calculate something quickly.
I hate having to resort to Google for calculating basic things.

## Features

* subtraction, addition
* division, multiplication
* power, modulo
* parenthesis
* PI
* ANS (contains the result of the last row)

## Usage

```
$ ./calc 
🧮 5*2^0.5*PI
22.21441469
🧮 4+2
6
🧮 -2-2
-4
🧮 ans
-4
🧮 2/0
error
```

## Testing

The calculator comes with a comprehensive test suite that verifies all functionality. To run the tests:

```bash
# First build the calculator if not already built
make

# Then run the test suite
cd tests && ./run_tests.sh
```

The test suite includes:
- Basic arithmetic operations (+, -, *, /, %, ^)
- Order of operations
- Decimal number handling
- Constants (PI)
- Multiple prefix combinations (-, +, --, ++, etc.)
- Complex expressions with parentheses
- ANS variable functionality

Test cases are defined in `tests/test_cases.txt` and can be easily extended. The test runner provides colored output showing passed/failed tests with detailed error reporting.
