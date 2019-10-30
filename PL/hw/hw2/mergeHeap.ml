(*
 * Author: Eundo Lee
 * Student No.: 2014-12071
 * Target Exercise: 2-3
 *)
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

