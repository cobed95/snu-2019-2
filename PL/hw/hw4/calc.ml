type Bop = OpAdd
         | OpSub
         | OpMul


type token = TkInt of int
           | TkBop of Bop
           | TkLPar
           | TkRPar

type exp = EInt of int
         | EOp of Bop * Exp * Exp
         | EError

let expression ts0 =
    let (lhs, ts1) = term ts0 in
    match ts1 with
    | head :: ts2 -> 
        (match head with
        | TkBop (opT) ->
            (match opT with
            | OpMul -> (lhs, ts1)
            | _ -> 
                let (rhs, ts3) = term ts2 in
                (EOp (opT, lhs, rhs), ts3))
        | TkRParens -> (lhs, ts1))
        |
    | [] -> (lhs, ts1)

let expression' ts0 =
    (match ts0 with
    | head :: ts1 ->
        (match head with
        | TkBop (opT) ->
            (match opT with
            | OpMul -> (EError, ts1)
            | _ -> term ts1)
                
    | [] -> (EError, ts0)
    

let term ts0 =
    let (lhs, ts1) = factor ts0 in
    match ts1 with
    | head :: ts2 ->
        (match head with
        | TkBop (opT) ->
            (match opT with
            | OpMul -> 
                let (rhs, ts3) = term ts2 in
                (EOp (opT, lhs, rhs), ts3)
            | _ -> (EError, ts1))
        | _ -> Term


let factor token_stream =
    match token_stream with
    | head :: tail -> 
        (match head with
        | TkInt (num) -> 
        | TkLPar ->
    |
