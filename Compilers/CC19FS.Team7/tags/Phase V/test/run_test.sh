echo "Starting test with our compiler and reference compiler"
echo "Testing $1"
../../snuplc/snuplc $1 > ./our_result.txt
../../snuplc/reference/snuplc $1 > ./ref_result.txt
echo ""
echo "TEST RESULT DIFFERENCES:"
echo ""
diff ./our_result.txt ./ref_result.txt
