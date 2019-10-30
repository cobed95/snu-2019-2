(* 
 * Author: Eundo Lee
 * Student No.: 2014-12071
 * Target Exercise: 2-1
 *)
type exp =
    | X
    | INT of int
    | REAL of float
    | ADD of exp * exp
    | SUB of exp * exp
    | MUL of exp * exp
    | DIV of exp * exp
    | SIGMA of exp * exp * exp
    | INTEGRAL of exp * exp * exp

exception FreeVariable

let rec calculate expr = 
    let rec sigma (a, b, f) = 
        if a > b then 0.
        else (f (float_of_int a)) +. (sigma ((a + 1), b, f)) in
    let rec integral (a, b, f) =
        if (a == b) || ((a < b) && (b < a +. 0.1)) then 0.
        else if (a < b) then ((f a) *. 0.1) +. (integral ((a +. 0.1), b, f)) 
        else -.(integral(b, a, f)) in
    let rec getFunc candidate =
        match candidate with
        | X -> (fun x -> x)
        | INT value -> (fun x -> (float_of_int value))
        | REAL value -> (fun x -> value)
        | ADD (lhs, rhs) -> (fun x -> ((getFunc lhs) x) +. ((getFunc rhs) x))
        | SUB (lhs, rhs) -> (fun x -> ((getFunc lhs) x) -. ((getFunc rhs) x))
        | MUL (lhs, rhs) -> (fun x -> ((getFunc lhs) x) *. ((getFunc rhs) x))
        | DIV (lhs, rhs) -> (fun x -> ((getFunc lhs) x) /. ((getFunc rhs) x))
        | SIGMA (a, b, f) -> 
                (fun x -> sigma ((int_of_float (calculate a)), (int_of_float (calculate b)), (getFunc f)))
        | INTEGRAL (a, b, f) ->
                (fun x -> integral ((calculate a), (calculate b), (getFunc f))) in
    match expr with
    | X -> raise FreeVariable
    | INT value -> (float_of_int value)
    | REAL value -> value
    | ADD (lhs, rhs) -> (calculate lhs) +. (calculate rhs)
    | SUB (lhs, rhs) -> (calculate lhs) -. (calculate rhs)
    | MUL (lhs, rhs) -> (calculate lhs) *. (calculate rhs)
    | DIV (lhs, rhs) -> (calculate lhs) /. (calculate rhs)
    | SIGMA (a, b, f) -> (sigma ((int_of_float (calculate a)), (int_of_float (calculate b)), (getFunc f)))
    | INTEGRAL (a, b, f) -> (integral ((calculate a), (calculate b), (getFunc f)))

