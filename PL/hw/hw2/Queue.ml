(*
 * Author: Eundo Lee
 * Student No.: 2014-12071
 * Target Exercise: 2-4
 *)
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

