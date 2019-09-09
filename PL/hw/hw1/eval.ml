type expr = 
    | NUM of int
    | PLUS of expr * expr
    | MINUS of expr * expr;;

type formula =
    | TRUE
    | FALSE
    | NOT of formula
    | ANDALSO of formula * formula
    | ORELSE of formula * formula
    | IMPLY of formula * formula
    | LESS of expr * expr;;

let rec eval formula = 
    let rec evalExpr expr =
        match expr with
        |NUM (n) -> n
        |PLUS (a, b) -> (evalExpr a) + (evalExpr b)
        |MINUS (a, b) -> (evalExpr a) - (evalExpr b) in
    match formula with
    |TRUE -> true
    |FALSE -> false
    |NOT (proposition) -> not (eval proposition)
    |ANDALSO (prop1, prop2) -> (eval prop1) && (eval prop2)
    |ORELSE (prop1, prop2) -> (eval prop1) || (eval prop2)
    |IMPLY (predicate, conclusion) -> 
            if not (eval predicate) then true
            else eval conclusion
    |LESS (lhs, rhs) -> (evalExpr lhs) < (evalExpr rhs);;

(* Below is for testing. Must be removed before submission *)
let _ = 
    if eval (NOT(LESS(PLUS(NUM(1), NUM(4)), MINUS(NUM(3), NUM(1))))) then 
        print_endline "true"
    else print_endline "false";;
