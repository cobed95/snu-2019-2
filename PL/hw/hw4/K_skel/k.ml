(*
 * SNU 4190.310 Programming Languages 2019 Fall
 *  K- Interpreter Skeleton Code
 *)

(* Location Signature *)
module type LOC =
sig
  type t
  val base : t
  val equal : t -> t -> bool
  val diff : t -> t -> int
  val increase : t -> int -> t
end

module Loc : LOC =
struct
  type t = Location of int
  let base = Location(0)
  let equal (Location(a)) (Location(b)) = (a = b)
  let diff (Location(a)) (Location(b)) = a - b
  let increase (Location(base)) n = Location(base+n)
end

(* Memory Signature *)
module type MEM = 
sig
  type 'a t
  exception Not_allocated
  exception Not_initialized
  val empty : 'a t (* get empty memory *)
  val load : 'a t -> Loc.t  -> 'a (* load value : Mem.load mem loc => value *)
  val store : 'a t -> Loc.t -> 'a -> 'a t (* save value : Mem.store mem loc value => mem' *)
  val alloc : 'a t -> Loc.t * 'a t (* get fresh memory cell : Mem.alloc mem => (loc, mem') *)
end

(* Environment Signature *)
module type ENV =
sig
  type ('a, 'b) t
  exception Not_bound
  val empty : ('a, 'b) t (* get empty environment *)
  val lookup : ('a, 'b) t -> 'a -> 'b (* lookup environment : Env.lookup env key => content *)
  val bind : ('a, 'b) t -> 'a -> 'b -> ('a, 'b) t  (* id binding : Env.bind env key content => env'*)
end

(* Memory Implementation *)
module Mem : MEM =
struct
  exception Not_allocated
  exception Not_initialized
  type 'a content = V of 'a | U
  type 'a t = M of Loc.t * 'a content list
  let empty = M (Loc.base,[])

  let rec replace_nth = fun l n c -> 
    match l with
    | h::t -> if n = 1 then c :: t else h :: (replace_nth t (n - 1) c)
    | [] -> raise Not_allocated

  let load (M (boundary,storage)) loc =
    match (List.nth storage ((Loc.diff boundary loc) - 1)) with
    | V v -> v 
    | U -> raise Not_initialized

  let store (M (boundary,storage)) loc content =
    M (boundary, replace_nth storage (Loc.diff boundary loc) (V content))

  let alloc (M (boundary,storage)) = 
    (boundary, M (Loc.increase boundary 1, U :: storage))
end

(* Environment Implementation *)
module Env : ENV=
struct
  exception Not_bound
  type ('a, 'b) t = E of ('a -> 'b)
  let empty = E (fun x -> raise Not_bound)
  let lookup (E (env)) id = env id
  let bind (E (env)) id loc = E (fun x -> if x = id then loc else env x)
end

(*
 * K- Interpreter
 *)
module type KMINUS =
sig
  exception Error of string
  type id = string
  type exp =
    | NUM of int | TRUE | FALSE | UNIT
    | VAR of id
    | ADD of exp * exp
    | SUB of exp * exp
    | MUL of exp * exp
    | DIV of exp * exp
    | EQUAL of exp * exp
    | LESS of exp * exp
    | NOT of exp
    | SEQ of exp * exp            (* sequence *)
    | IF of exp * exp * exp       (* if-then-else *)
    | WHILE of exp * exp          (* while loop *)
    | LETV of id * exp * exp      (* variable binding *)
    | LETF of id * id list * exp * exp (* procedure binding *)
    | CALLV of id * exp list      (* call by value *)
    | CALLR of id * id list       (* call by referenece *)
    | RECORD of (id * exp) list   (* record construction *)
    | FIELD of exp * id           (* access record field *)
    | ASSIGN of id * exp          (* assgin to variable *)
    | ASSIGNF of exp * id * exp   (* assign to record field *)
    | READ of id
    | WRITE of exp
    
  type program = exp
  type memory
  type env
  type value =
    | Num of int
    | Bool of bool
    | Unit
    | Record of (id -> Loc.t)
  val emptyMemory : memory
  val emptyEnv : env
  val run : memory * env * program -> value
end

module RecordMap = Map.Make(String)

module K : KMINUS =
struct
  exception Error of string

  type id = string
  type exp =
    | NUM of int | TRUE | FALSE | UNIT
    | VAR of id
    | ADD of exp * exp
    | SUB of exp * exp
    | MUL of exp * exp
    | DIV of exp * exp
    | EQUAL of exp * exp
    | LESS of exp * exp
    | NOT of exp
    | SEQ of exp * exp            (* sequence *)
    | IF of exp * exp * exp       (* if-then-else *)
    | WHILE of exp * exp          (* while loop *)
    | LETV of id * exp * exp      (* variable binding *)
    | LETF of id * id list * exp * exp (* procedure binding *)
    | CALLV of id * exp list      (* call by value *)
    | CALLR of id * id list       (* call by referenece *)
    | RECORD of (id * exp) list   (* record construction *)
    | FIELD of exp * id           (* access record field *)
    | ASSIGN of id * exp          (* assgin to variable *)
    | ASSIGNF of exp * id * exp   (* assign to record field *)
    | READ of id
    | WRITE of exp

  type program = exp

  type value =
    | Num of int
    | Bool of bool
    | Unit
    | Record of (id -> Loc.t)
    
  type memory = value Mem.t
  type env = (id, env_entry) Env.t
  and  env_entry = Addr of Loc.t | Proc of id list * exp * env

  let emptyMemory = Mem.empty
  let emptyEnv = Env.empty

  let value_int v =
    match v with
    | Num n -> n
    | _ -> raise (Error "TypeError : not int")

  let value_bool v =
    match v with
    | Bool b -> b
    | _ -> raise (Error "TypeError : not bool")

  let value_unit v =
    match v with
    | Unit -> ()
    | _ -> raise (Error "TypeError : not unit")

  let value_record v =
    match v with
    | Record r -> r
    | _ -> raise (Error "TypeError : not record")

  let lookup_env_loc e x =
    try
      (match Env.lookup e x with
      | Addr l -> l
      | Proc _ -> raise (Error "TypeError : not addr")) 
    with Env.Not_bound -> raise (Error "Unbound")

  let lookup_env_proc e f =
    try
      (match Env.lookup e f with
      | Addr _ -> raise (Error "TypeError : not proc") 
      | Proc (id_list, exp, env) -> (id_list, exp, env))
    with Env.Not_bound -> raise (Error "Unbound")

  let rec eval mem env e =
    let eval_two_expr mem env e1 e2 = 
      let (v1, mem') = eval mem env e1 in
      let (v2, mem'') = eval mem' env e2 in
      (v1, v2, mem'') in
    match e with
    | NUM n -> (Num n, mem)
    | TRUE -> (Bool true, mem)
    | FALSE -> (Bool false, mem)
    | UNIT -> (Unit, mem)
    | VAR x -> 
      let l = lookup_env_loc env x in
      let v = Mem.load mem l in
      (v, mem)
    | ADD (e1, e2) ->
      let (v1, v2, mem') = eval_two_expr mem env e1 e2 in
      (Num ((value_int v1) + (value_int v2)), mem')
    | SUB (e1, e2) ->
      let (v1, v2, mem') = eval_two_expr mem env e1 e2 in
      (Num ((value_int v1) - (value_int v2)), mem')
    | MUL (e1, e2) ->
      let (v1, v2, mem') = eval_two_expr mem env e1 e2 in
      (Num ((value_int v1) * (value_int v2)), mem')
    | DIV (e1, e2) ->
      let (v1, v2, mem') = eval_two_expr mem env e1 e2 in
      (Num ((value_int v1) / (value_int v2)), mem')
    | EQUAL (e1, e2) ->
      let (v1, v2, mem') = eval_two_expr mem env e1 e2 in
      (match v1, v2 with
      | Num _, Num _ -> (Bool ((value_int v1) == (value_int v2)), mem')
      | Bool val1, Bool val2 -> (Bool ((value_bool v1) == (value_bool v2)), mem')
      | Unit, Unit -> (Bool ((value_unit v1) == (value_unit v2)), mem')
      | _, _ -> ((Bool false), mem'))
    | LESS (e1, e2) ->
      let (v1, v2, mem') = eval_two_expr mem env e1 e2 in
      (Bool ((value_int v1) < (value_int v2)), mem')
    | NOT e ->
      let (v, mem') = eval mem env e in
      (Bool(not (value_bool v)), mem')
    | SEQ (e1, e2) ->
      let (_, v, mem') = eval_two_expr mem env e1 e2 in
      (v, mem')
    | IF (econd, etrue, efalse) ->
      let (vcond, memcond) = eval mem env econd in
      let true_result = lazy (eval memcond env etrue) in
      let false_result = lazy (eval memcond env efalse) in
      if (value_bool vcond) then (Lazy.force true_result)
      else (Lazy.force false_result)
    | WHILE (econd, eexec) ->
      let (vcond, memcond) = eval mem env econd in
      let exec_result = lazy (eval memcond env eexec) in
      if (value_bool vcond) 
      then (eval (match exec_result with lazy (_, memexec) -> memexec) env e)
      else (Unit, memcond)
    | READ x -> 
      let v = Num (read_int()) in
      let l = lookup_env_loc env x in
      (v, Mem.store mem l v)
    | WRITE e ->
      let (v, mem') = eval mem env e in
      let n = value_int v in
      let _ = print_endline (string_of_int n) in
      (v, mem')
    | LETV (x, e1, e2) ->
      let (v, mem') = eval mem env e1 in
      let (l, mem'') = Mem.alloc mem' in
      eval (Mem.store mem'' l v) (Env.bind env x (Addr l)) e2
    | LETF (id, args, body, parent_scope) ->
      let env' = Env.bind env id (Proc (args, body, env)) in
      eval mem env' parent_scope
    | ASSIGN (x, e) ->
      let (v, mem') = eval mem env e in
      let l = lookup_env_loc env x in
      (v, Mem.store mem' l v)
    | RECORD id_exp_list ->
      (match id_exp_list with
      | [] -> (Unit, mem)
      | _ ->
        let reducer_to_val a b = 
          match b with (id, exp) ->
            (match a with (prev_list, prev_mem) ->
              let (v, curr_mem) = eval prev_mem env exp in
              ((id, v) :: prev_list, curr_mem)) in
        let (id_val_list, exec) = List.fold_left reducer_to_val ([], mem) id_exp_list in
        let reducer_to_loc a b =
          match b with (id, v) ->
            (match a with (prev_list, prev_mem) ->
              let (l, alloc) = Mem.alloc prev_mem in
              let stored = Mem.store alloc l v in
              ((id, l) :: prev_list, stored)) in
        let (id_loc_list, memx) = List.fold_left reducer_to_loc ([], exec) id_val_list in
        let reducer_to_map a b = match b with (id, l) -> RecordMap.add id l a in
        let rec_map = List.fold_left reducer_to_map RecordMap.empty id_loc_list in
        ((Record (fun id -> 
            try RecordMap.find id rec_map
            with Not_found -> raise (Error "Unbound")
        )), memx))
    | FIELD (exp, id) ->
      let (r, mem') = eval mem env exp in
      ((Mem.load mem' (value_record r id)), mem')
    | ASSIGNF (rec_exp, id, val_exp) ->
      let (r, mem') = eval mem env rec_exp in
      let record = value_record r in
      let (v, mem'') = eval mem' env val_exp in
      (v, Mem.store mem'' (record id) v)
    | CALLV (id, exp_list) ->
      let reducer_to_val a b =
        match a with (val_list, prev_mem) ->
          let (v, mem') = eval prev_mem env b in
          (v :: val_list, mem') in
      let (val_list, exec_mem) = List.fold_left reducer_to_val ([], mem) exp_list in
      let val_list_rev = List.rev val_list in
      let (id_list, body, sub_env) = lookup_env_proc env id in
      let reducer_to_env a b c = 
        match a with (prev_env, prev_mem) ->
          let (l, alloc) = Mem.alloc prev_mem in
          let stored = Mem.store alloc l c in
          ((Env.bind prev_env b (Addr l)), stored) in
      let (env', mem') = 
        if (List.length id_list) != (List.length val_list_rev) then raise (Error "InvalidArg")
        else List.fold_left2 reducer_to_env (sub_env, exec_mem) id_list val_list_rev in
      let env_with_self = Env.bind env' id (Proc (id_list, body, env')) in
      (eval mem' env_with_self body)
    | CALLR (id, id_list) ->
      let loc_list = List.map (lookup_env_loc env) id_list in
      let (arg_id_list, body, sub_env) = lookup_env_proc env id in
      let reducer_to_env prev_env arg loc = Env.bind prev_env arg (Addr loc) in
      let bound_env = 
        if (List.length arg_id_list) != (List.length loc_list) then raise (Error "InvalidArg")
        else List.fold_left2 reducer_to_env sub_env arg_id_list loc_list in
      let env_with_self = Env.bind bound_env id (Proc (arg_id_list, body, bound_env)) in
      (eval mem env_with_self body)

  let run (mem, env, pgm) = 
    let (v, _ ) = eval mem env pgm in
    v
end
