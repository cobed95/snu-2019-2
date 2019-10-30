type crazy2 = 
    | NIL
    | ZERO of crazy2
    | ONE of crazy2
    | MONE of crazy2

let crazy2val crazy2 =
    let rec crazy2ValIter crazy2 mult =
        match crazy2 with 
        |NIL -> 0
        |ZERO (tail) -> 0 + (crazy2ValIter tail (mult * 2))
        |ONE (tail) -> mult + (crazy2ValIter tail (mult * 2))
        |MONE (tail) -> (- mult) + (crazy2ValIter tail (mult * 2)) in
    crazy2ValIter crazy2 1
