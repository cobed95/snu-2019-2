let val f = fn x => 1 in
    let rec f = fn x => (
        if (f (x)) then true
        else false
    ) in
    f 1
    end;
    f 1
end
