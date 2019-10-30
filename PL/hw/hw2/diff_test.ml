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


let (|>) g f = f g
type r = (int * ((string * int) list)) list

let rec sum r1 r2 = 
    match r1, r2 with
    | _, [] -> r1
    | [], _ -> r2
    | (c1, xs1)::t1, (c2, xs2)::t2 ->
        if xs1 = xs2 then (c1 + c2, xs1)::(sum t1 t2)
        else if xs1 < xs2 then 
            (c1, xs1)::(sum t1 r2)
        else
            (c2, xs2)::(sum r1 t2)
let rec mult res a =

    match a with
    | CONST c1 -> 
        List.map (fun (c, xs) -> (c1 * c, xs)) res
	
    | VAR v ->
        mult res (POWER (v, 1))

    | POWER (x1, n1) ->
        let r = 
            List.map (fun (c, xs) ->
                let rec iter rlst = 
                    match rlst with
                    | [] -> [(x1, n1)]
                    | (x2, n2)::tl ->
                        if x1 = x2 then (x2, n1 + n2)::tl
                        else if x1 < x2 then (x1, n1)::rlst
                        else (x2, n2)::(iter tl) in
                (c, iter xs)) res in
        List.fold_left (fun res elem -> sum res [elem]) [] r  

    | SUM alst -> (
        match alst with
        | [] -> []
        | a::tl -> sum (mult res a) (mult res (SUM tl))
    )

    | TIMES alst ->
    (
        match alst with
        | [] -> res
        | a::tl -> mult (mult res a) (TIMES tl)
    )


let normalize a = 
    (mult [1, []] a)
    |> List.filter (fun (c, _) -> c <> 0)


let equals n1 a = 
    n1 = (normalize a)

let _ = print_endline (string_of_bool ( diff (SUM [(TIMES [CONST 3; VAR "x" ; POWER ("y",2) ; VAR "z"]); VAR "y"] , "x")
|> equals [3, ["y", 2; "z", 1]]
))

