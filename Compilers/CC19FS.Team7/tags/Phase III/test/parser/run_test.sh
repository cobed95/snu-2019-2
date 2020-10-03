echo "Starting test with test_parser and test_parser.ref"
echo "Testing $1"
../../snuplc/test_parser $1 > ./our_result.txt
../../snuplc/reference/test_parser.ref $1 > ./ref_result.txt
echo ""
echo "TEST RESULT DIFFERENCES:"
echo ""
diff ./our_result.txt ./ref_result.txt
