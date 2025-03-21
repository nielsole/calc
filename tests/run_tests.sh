#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BLUE='\033[0;34m'

# Counters for test results
TOTAL=0
PASSED=0
FAILED=0

# Compile the calculator if needed
if [ ! -f "../calc" ]; then
    echo -e "${BLUE}Compiling calculator...${NC}"
    cd .. && make
    cd tests
fi

echo -e "${BLUE}Running tests...${NC}\n"

# Function to compare floating point numbers with tolerance
compare_float() {
    local expected=$1
    local actual=$2
    local tolerance=0.0000001

    # Remove scientific notation if present
    expected=$(echo $expected | sed 's/[eE]+\?/*10^/g')
    actual=$(echo $actual | sed 's/[eE]+\?/*10^/g')

    # Calculate absolute difference
    local diff=$(echo "scale=10; a=$actual-$expected; if(a<0) -a else a" | bc)
    local result=$(echo "$diff < $tolerance" | bc)
    
    return $((1-result))
}

# Function to run a test and compare results
run_test() {
    local expression="$1"
    local expected="$2"
    local output="$3"
    local actual=$(echo "$output" | grep -v "standard_in" | head -n1 | tr -d '\n')
    
    if [ "$actual" = "error" ]; then
        echo -e "${RED}✗ FAIL${NC}: $expression"
        echo -e "  Expected: $expected"
        echo -e "  Got:      Syntax Error"
        ((FAILED++))
    elif [ -z "$actual" ]; then
        echo -e "${RED}✗ FAIL${NC}: $expression"
        echo -e "  Expected: $expected"
        echo -e "  Got:      No output"
        ((FAILED++))
    elif compare_float "$expected" "$actual" || [ "$actual" = "$expected" ]; then
        echo -e "${GREEN}✓ PASS${NC}: $expression = $actual"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}: $expression"
        echo -e "  Expected: $expected"
        echo -e "  Got:      $actual"
        ((FAILED++))
    fi
    ((TOTAL++))
}

# Create temporary files
ANS_FILE=$(mktemp)
in_ans_section=false

# First pass: Run non-ANS tests and collect ANS tests
while IFS= read -r line; do
    # Handle section detection
    if [[ "$line" =~ ^#.*Previous.*answer.*$ ]]; then
        in_ans_section=true
        continue
    fi
    
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^#.*$ ]] && continue
    
    # Split the line into expression and expected result
    if [[ "$line" =~ (.*)=(.*)$ ]]; then
        expression="${BASH_REMATCH[1]}"
        expected="${BASH_REMATCH[2]}"
        
        # Remove all whitespace and leading/trailing spaces
        expression=$(echo "$expression" | tr -d '[:space:]')
        expected=$(echo "$expected" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        
        if $in_ans_section; then
            # Save ANS tests for later
            echo "$expression=$expected" >> "$ANS_FILE"
        else
            # Run regular test
            output=$(printf "%s\n" "$expression" | ../calc 2>&1)
            run_test "$expression" "$expected" "$output"
        fi
    fi
done < "test_cases.txt"

# Print first summary
echo -e "\n${BLUE}Test Summary:${NC}"
echo -e "Total tests:  $TOTAL"
echo -e "${GREEN}Tests passed: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Tests failed: $FAILED${NC}"
else
    echo -e "Tests failed: $FAILED"
fi

# Run ANS tests if any exist
if [ -s "$ANS_FILE" ]; then
    echo -e "\n${BLUE}Running ANS tests...${NC}\n"
    
    # Create input file
    TMP_INPUT=$(mktemp)
    while IFS= read -r test; do
        echo "${test%=*}" >> "$TMP_INPUT"
    done < "$ANS_FILE"
    
    # Run tests through calculator
    output=$(cat "$TMP_INPUT" | ../calc 2>&1)
    readarray -t results <<< "$output"
    
    # Process results
    i=0
    while IFS= read -r test; do
        expression="${test%=*}"
        expected="${test#*=}"
        run_test "$expression" "$expected" "${results[$i]}"
        ((i++))
    done < "$ANS_FILE"
    
    # Clean up
    rm -f "$TMP_INPUT"
fi

# Clean up
rm -f "$ANS_FILE"

# Final summary
echo -e "\n${BLUE}Final Test Summary:${NC}"
echo -e "Total tests:  $TOTAL"
echo -e "${GREEN}Tests passed: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Tests failed: $FAILED${NC}"
else
    echo -e "Tests failed: $FAILED"
fi

# Set exit code based on test results
[ $FAILED -eq 0 ]
