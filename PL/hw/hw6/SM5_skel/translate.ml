(*
 * SNU 4190.310 Programming Languages 
 * K-- to SM5 translator skeleton code
 *)

open K
open Sm5
module Translator = struct

  (* TODO : complete this function  *)
  let rec trans : K.program -> Sm5.command = function
    | K.NUM i -> [Sm5.PUSH (Sm5.Val (Sm5.Z i))]
    | K.TRUE -> [Sm5.PUSH (Sm5.Val (Sm5.B true))]
    | K.FALSE -> [Sm5.PUSH (Sm5.Val (Sm5.B false))]
    | K.UNIT -> [Sm5.PUSH (Sm5.Val Unit)]
    | K.VAR id -> [Sm5.PUSH (Sm5.Id id); Sm5.LOAD]
    | K.ADD (e1, e2) -> trans e1 @ trans e2 @ [Sm5.ADD]
    | K.SUB (e1, e2) -> trans e1 @ trans e2 @ [Sm5.SUB]
    | K.MUL (e1, e2) -> trans e1 @ trans e2 @ [Sm5.MUL]
    | K.DIV (e1, e2) -> trans e1 @ trans e2 @ [Sm5.DIV]
    | K.EQUAL (e1, e2) -> trans e1 @ trans e2 @ [Sm5.EQ]
    | K.LESS (e1, e2) -> trans e1 @ trans e2 @ [Sm5.LESS]
    | K.NOT (e) -> trans e @ [Sm5.NOT]
    | K.ASSIGN (id, e) -> trans e @ [Sm5.PUSH (Sm5.Id id); Sm5.STORE] 
    | K.SEQ (e1, e2) -> trans e1 @ trans e2
    | K.IF (econd, etrue, efalse) -> trans econd @ [Sm5.JTR (trans etrue, trans efalse)]
    | K.WHILE (econd, ebody) -> 
      let while_func_call = K.CALLV ("while#", K.UNIT) in
      let while_func_decl = K.LETF("while#", "x#", K.IF (econd, K.SEQ(ebody, while_func_call), K.UNIT), while_func_call) in
      trans while_func_decl
    | K.FOR (id, einit, eterm, ebody) ->
      let term_plus_one = K.ADD(eterm, K.NUM 1) in
      let while_body = K.SEQ (ebody, K.ASSIGN(id, K.ADD (K.VAR id, K.NUM 1))) in
      let while_loop = K.WHILE (K.LESS (K.VAR id, term_plus_one), while_body) in
      let init_while_loop = K.SEQ (K.ASSIGN (id, einit), while_loop) in
      trans init_while_loop
    | K.LETV (x, e1, e2) -> 
      trans e1 @ [Sm5.MALLOC; Sm5.BIND x; Sm5.PUSH (Sm5.Id x); Sm5.STORE] @
      trans e2 @ [Sm5.UNBIND; Sm5.POP]
    | K.LETF (func_id, arg_id, ebody, eparent) ->
      let cbody = trans ebody in
      let bind_to_self cbody = (Sm5.BIND func_id) :: cbody in
      let unbind_from_self cbody_bound_to_self = cbody_bound_to_self @ [Sm5.UNBIND; Sm5.POP] in
      [Sm5.PUSH (Sm5.Fn (arg_id, unbind_from_self (bind_to_self cbody))); Sm5.BIND func_id] @
      trans eparent @ 
      [Sm5.UNBIND; Sm5.POP]
    | K.CALLV (id, e) ->
      [Sm5.PUSH (Sm5.Id id); Sm5.PUSH (Sm5.Id id)] @ trans e @ [Sm5.MALLOC; Sm5.CALL]
    | K.CALLR (func_id, arg_id) ->
      [Sm5.PUSH (Sm5.Id func_id); Sm5.PUSH (Sm5.Id func_id); Sm5.PUSH (Sm5.Id (arg_id)); Sm5.LOAD; Sm5.PUSH (Sm5.Id (arg_id)); Sm5.CALL]
    | K.READ x -> [Sm5.GET; Sm5.PUSH (Sm5.Id x); Sm5.STORE; Sm5.PUSH (Sm5.Id x); Sm5.LOAD]
    | K.WRITE e -> trans e @ [Sm5.PUT]
    | _ -> failwith "Unimplemented"

end
