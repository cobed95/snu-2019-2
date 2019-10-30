(* 2-1 *)
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

(* answer: 3794.565 *)
let expression = 
    ADD(
        DIV(
            MUL(
                ADD(
                    INT(1),
                    SUB(
                        REAL(2.5),
                        INT(3)
                    )
                ),
                SUB(
                    REAL(5.5),
                    INT(5)
                )
            ),
            REAL(0.5)
        ),
        ADD(
            SIGMA(
                INT(1),
                SIGMA(
                    INT(1),
                    INT(4),
                    X
                ),
                ADD(
                    MUL(
                        X,
                        MUL(
                            X,
                            X
                        )
                    ),
                    ADD(
                        MUL(
                            X,
                            X
                        ),
                        ADD(
                            X,
                            INT(1)
                        )
                    )
                )
            ),
            INTEGRAL(
                INT(1),
                INT(10),
                SUB(
                    MUL(
                        X,
                        X
                    ),
                    INT(1)
                )
            )
        )
    )
let _ = print_endline (string_of_float (calculate expression))

(* 2-2 *)
type ae = 
    | CONST of int
    | VAR of string
    | POWER of string * int
    | TIMES of ae list
    | SUM of ae list

exception InvalidArgument

let rec parse_ae : ae -> string = fun expr ->
        match expr with
        | CONST i -> string_of_int i
        | VAR s -> s
        | POWER (s, i) -> s ^ "^" ^ (string_of_int i)
        | TIMES arr -> 
            (match arr with
            | [] -> ""
            | head::tail -> 
                (match tail with
                | [] -> (parse_ae head) 
                | _ -> "(" ^ (parse_ae head) ^ " * " ^ (parse_ae (TIMES tail)) ^ ")"))
        | SUM arr ->
            (match arr with
            | [] -> ""
            | head::tail ->
                (match tail with
                | [] -> (parse_ae head) 
                | _ -> "(" ^ (parse_ae head) ^ " + " ^ (parse_ae (SUM tail)) ^ ")")) 


let rec diff (expr, diffTarget) = 
    let _ = print_endline (parse_ae expr) in
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

(* test *)
let x = TIMES[POWER("x", 3); TIMES[CONST 3; POWER("x", 2)]]
let y = TIMES[SUM[TIMES[CONST 2; VAR "x"]; CONST 1]; SUM[TIMES[CONST 2; VAR "x"]; CONST 1]]
let z = SUM[TIMES[VAR("a"); POWER("x", 2)]; TIMES[VAR("b"); POWER("x", 1)]; VAR("c")]

let _ = print_endline (parse_ae x)
let _ = print_endline (parse_ae (diff(x, "x")))
let _ = print_endline "----------------------------------"
let _ = print_endline (parse_ae y)
let _ = print_endline (parse_ae (diff (y, "x")))
let _ = print_endline "----------------------------------"
let _ = print_endline (parse_ae z)
let _ = print_endline (parse_ae (diff (z, "x")))

(* 2-3 *)
type heap = EMPTY | NODE of rank * value * heap * heap
and rank = int
and value = int

exception EmptyHeap

let rank h = 
    match h with 
    | EMPTY -> -1
    | NODE(r, _, _, _) -> r

let findMin h = 
    match h with 
    | EMPTY -> raise EmptyHeap
    | NODE(_, x, _, _) -> x

let shake (x, lh, rh) =
    if (rank lh) >= (rank rh)
    then NODE(((rank rh) + 1), x, lh, rh)
    else NODE(((rank lh) + 1), x, rh, lh)

let rec merge (lh, rh) = 
    match (lh, rh) with
    | (NODE(_, lhVal, lhLeftChild, lhRightChild), NODE(_, rhVal, rhLeftChild, rhRightChild)) ->
            if lhVal <= rhVal
            then shake (lhVal, (merge(lhLeftChild, lhRightChild)), rh)
            else shake (rhVal, (merge(rhLeftChild, rhRightChild)), lh)
    | (EMPTY, _) -> rh
    | (_, EMPTY) -> lh

let insert (x, h) = merge (h, NODE(0, x, EMPTY, EMPTY))

let deleteMin h =
    match h with 
    | EMPTY -> raise EmptyHeap
    | NODE(_, x, lh, rh) -> merge (lh, rh)

let rec stringOfHeap h =
    match h with
    | EMPTY -> "EMPTY"
    | NODE(r, v, lh, rh) ->
            "NODE(" ^ 
            (string_of_int r) ^ ", " ^ 
            (string_of_int v) ^ ", " ^ 
            (stringOfHeap lh) ^ ", " ^ 
            (stringOfHeap rh) ^ ")"

let rec checkRank h =
    match h with
    | EMPTY -> true
    | NODE(_, _, lh, rh) -> 
            ((rank lh) >= (rank rh)) &&
            (checkRank lh) &&
            (checkRank rh)

let rec checkMin h min =
    match h with
    | EMPTY -> true
    | NODE(_, v, lh, rh) ->
            (min <= v) &&
            (checkMin lh min) &&
            (checkMin rh min)

let max = 10000

let rec test h num =
    let safeMinCheck = 
        try 
            if (checkMin h (findMin h)) then true
            else false
        with EmptyHeap -> true in
    let random = Random.int max in
    let commonTest = (safeMinCheck) && (checkRank h) in
    if num < 0 then true
    else if random < (max / 10) then 
        try commonTest && (test (deleteMin h) (num - 1))
        with EmptyHeap -> commonTest && (test (insert(random, h)) (num - 1))
    else commonTest && (test (insert(random, h)) (num - 1))

let _ = 
    if (test EMPTY max) then print_endline "test is good"
    else print_endline "test is not good"

(* 2-4 *)
module type Queue =
    sig
        type element
        type queue
        exception EMPTY_Q
        val emptyQ: queue
        val enQ: queue * element -> queue
        val deQ: queue -> element * queue
    end

module IntListQ =
    struct 
        type element = int list
        type queue = (element list) * (element list)
        exception EMPTY_Q
        let emptyQ = ([], [])

        let enQ (someQ, someEl) = 
            match someQ with
            | (left, right) -> (someEl :: left, right)

        let rec deQ someQ =
            let rec dump (from, target) =
                match from with
                | [] -> (from, target)
                | head :: tail -> dump (tail, head::target) in
            match someQ with
            | ([], []) -> raise EMPTY_Q
            | (left, right) ->
                    (match right with
                    | [] -> deQ (dump (left, right))
                    | rightHead :: rightTail -> (rightHead, (left, rightTail)))
    end

module ValidIntListQ = (IntListQ: Queue)

let max = 100

let rec enqueueSequentially q start =
    if start >= max then q
    else enqueueSequentially (IntListQ.enQ(q, [start])) (start + 1)

let rec dequeueAndPrintTillEmpty q =
    match q with
    | ([], []) -> print_endline "done"
    | _ -> 
            (match IntListQ.deQ q with
            | (resultEl, resultQ) -> 
                    (match resultEl with
                    | head :: tail -> 
                            print_endline (string_of_int head);
                            dequeueAndPrintTillEmpty resultQ
                    | [] -> print_endline "empty list"))

let queue = enqueueSequentially IntListQ.emptyQ 0
let _ = dequeueAndPrintTillEmpty queue
