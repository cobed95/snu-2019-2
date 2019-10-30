type crazy2 = 
    | NIL
    | ZERO of crazy2
    | ONE of crazy2
    | MONE of crazy2

let crazy2add (a, b) =
    let rec appendWithCarry (crazy, carry) =
        match (crazy, carry) with 
        |(NIL, _) -> carry
        |(_, ZERO(_)) -> crazy
        |(ZERO(tail), ONE(_)) -> ONE(tail)
        |(ONE(tail), ONE(_)) -> ZERO(appendWithCarry (tail, ONE(NIL)))
        |(MONE(tail), ONE(_)) -> ZERO(tail)
        |(ZERO(tail), MONE(_)) -> MONE(tail)
        |(ONE(tail), MONE(_)) -> ZERO(tail)
        |(MONE(tail), MONE(_)) -> ZERO(appendWithCarry (tail, MONE(NIL)))
        |(_, NIL) -> appendWithCarry (crazy, ZERO(NIL)) in
    let rec crazy2AddIter (a, b, carry) =
        match (a, b, carry) with
        |(NIL, _, _) -> appendWithCarry (b, carry)
        |(_, NIL, _) -> appendWithCarry (a, carry)
        |(ZERO(tailA), ZERO(tailB), ZERO(_)) -> ZERO(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(ONE(tailA), ZERO(tailB), ZERO(_)) -> ONE(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(MONE(tailA), ZERO(tailB), ZERO(_)) -> MONE(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(ZERO(tailA), ONE(tailB), ZERO(_)) -> ONE(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(ONE(tailA), ONE(tailB), ZERO(_)) -> ZERO(crazy2AddIter (tailA, tailB, ONE(NIL)))
        |(MONE(tailA), ONE(tailB), ZERO(_)) -> ZERO(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(ZERO(tailA), MONE(tailB), ZERO(_)) -> MONE(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(ONE(tailA), MONE(tailB), ZERO(_)) -> ZERO(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(MONE(tailA), MONE(tailB), ZERO(_)) -> ZERO(crazy2AddIter (tailA, tailB, MONE(NIL)))
        |(ZERO(tailA), ZERO(tailB), ONE(_)) -> ONE(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(ONE(tailA), ZERO(tailB), ONE(_)) -> ZERO(crazy2AddIter (tailA, tailB, ONE(NIL)))
        |(MONE(tailA), ZERO(tailB), ONE(_)) -> ZERO(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(ZERO(tailA), ONE(tailB), ONE(_)) -> ZERO(crazy2AddIter (tailA, tailB, ONE(NIL)))
        |(ONE(tailA), ONE(tailB), ONE(_)) -> ONE(crazy2AddIter (tailA, tailB, ONE(NIL)))
        |(MONE(tailA), ONE(tailB), ONE(_)) -> ONE(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(ZERO(tailA), MONE(tailB), ONE(_)) -> ZERO(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(ONE(tailA), MONE(tailB), ONE(_)) -> ONE(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(MONE(tailA), MONE(tailB), ONE(_)) -> ZERO(crazy2AddIter (tailA, tailB, MONE(NIL)))
        |(ZERO(tailA), ZERO(tailB), MONE(_)) -> MONE(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(ONE(tailA), ZERO(tailB), MONE(_)) -> ZERO(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(MONE(tailA), ZERO(tailB), MONE(_)) -> ZERO(crazy2AddIter (tailA, tailB, MONE(NIL)))
        |(ZERO(tailA), ONE(tailB), MONE(_)) -> ZERO(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(ONE(tailA), ONE(tailB), MONE(_)) -> ONE(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(MONE(tailA), ONE(tailB), MONE(_)) -> MONE(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(ZERO(tailA), MONE(tailB), MONE(_)) -> ZERO(crazy2AddIter (tailA, tailB, MONE(NIL)))
        |(ONE(tailA), MONE(tailB), MONE(_)) -> MONE(crazy2AddIter (tailA, tailB, ZERO(NIL)))
        |(MONE(tailA), MONE(tailB), MONE(_)) -> MONE(crazy2AddIter (tailA, tailB, MONE(NIL))) 
        |(_, _, NIL) -> crazy2AddIter (a, b, ZERO(NIL)) in
    crazy2AddIter (a, b, ZERO(NIL))

