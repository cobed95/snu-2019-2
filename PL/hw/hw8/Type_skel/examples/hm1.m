let rec iter = fn i => fn j =>
    if i = j then 
        10
    else 
        (iter (i+1) j) + i
in
    ((iter 0 10), "abc")
end
