type expr = 
    | NUM of int
    | PLUS of expr * expr
    | MINUS of expr * expr
    | MULT of expr * expr
    | DIVIDE of expr * expr
    | MAX of expr list;;

let rec eval expr = 
    let rec getMax exprList max =
        match exprList with
        |head :: tail ->
                let intHead = eval head in
                if intHead > max then (getMax tail intHead)
                else (getMax tail max)
        |[] -> max in
    match expr with
    |NUM value -> value
    |PLUS (lhs, rhs) -> (eval lhs) + (eval rhs)
    |MINUS (lhs, rhs) -> (eval lhs) - (eval rhs)
    |MULT (lhs, rhs) -> (eval lhs) * (eval rhs)
    |DIVIDE (lhs, rhs) -> (eval lhs) / (eval rhs)
    |MAX exprList ->
            (match exprList with
            |head :: tail -> getMax tail (eval head)
            |[] -> 0);;

let _ =
    let expr = MINUS(DIVIDE(MULT(MAX [NUM 1; NUM 2; PLUS(NUM 1, NUM 2)], NUM 3), NUM 4), NUM (-1)) in
    let except = DIVIDE(NUM 3, NUM 0) in
    Printf.printf "%d %d\n" (eval expr) (eval except);;
