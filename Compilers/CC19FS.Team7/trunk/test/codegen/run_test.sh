echo "Starting test with our compiler and reference compiler"
echo "Testing $1"
cat $1 > "ref_$1"
../../snuplc/snuplc $1
../../snuplc/reference/snuplc "ref_$1"
echo ""
echo "TEST RESULT DIFFERENCES:"
echo ""
diff "./$1.s" "./ref_$1.s"
