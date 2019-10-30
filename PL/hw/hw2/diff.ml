(*
 * Author: Eundo Lee
 * Student No.: 2014-12071
 * Target Exercise: 2-2
 *)
type ae = 
    | CONST of int
    | VAR of string
    | POWER of string * int
    | TIMES of ae list
    | SUM of ae list

exception InvalidArgument

let rec diff (expr, diffTarget) = 
    match expr with
    | CONST c -> CONST 0
    | VAR str -> 
            if str = diffTarget then CONST 1
            else CONST 0
    | POWER (str, c) ->
            if str = diffTarget
            then (match c with
            | 1 -> CONST 1
            | 0 -> CONST 0
            | _ -> TIMES [(CONST c); POWER (str, (c - 1))])
            else expr
    | TIMES exprList ->
            (match exprList with
            | head :: tail -> 
                    (match tail with
                    | [] -> (diff (head, diffTarget))
                    | _ -> SUM [
                        (TIMES [(diff (head, diffTarget)); (TIMES tail)]); 
                        (TIMES [head; (diff ((TIMES tail), diffTarget))])
                    ])
            | [] -> raise InvalidArgument)
    | SUM exprList ->
            (match exprList with
            | head :: tail ->
                    (match tail with
                    | [] -> diff (head, diffTarget)
                    | _ -> SUM [
                        (diff (head, diffTarget));
                        (diff ((SUM tail), diffTarget))
                    ])
            | [] -> raise InvalidArgument)

