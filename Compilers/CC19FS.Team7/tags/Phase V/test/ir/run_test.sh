echo "Starting test with our ir generator and reference ir generator"
echo "Testing $1"
../../snuplc/test_ir $1 > ./our_result.txt
../../snuplc/reference/test_ir $1 > ./ref_result.txt
echo ""
echo "TEST RESULT DIFFERENCES:"
echo ""
diff ./our_result.txt ./ref_result.txt
