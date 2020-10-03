(*
 * SNU 4190.310 Programming Languages
 * Type Checker Skeleton Code
 *)

open M
open Pp

type var = string

let count = ref 0 

let new_var () = 
  let _ = count := !count +1 in
  "x_" ^ (string_of_int !count)

type typ = 
  | TInt
  | TBool
  | TString
  | TPair of typ * typ
  | TLoc of typ
  | TFun of typ * typ
  | TVar of var
  (* Modify, or add more if needed *)

let is_primitive tp = 
  match tp with
  | TInt -> true
  | TBool -> true
  | TString -> true
  | _ -> false

let is_loc tp = 
  match tp with 
  | TLoc _ -> true
  | _ -> false

let rec string_of_typ t = 
  match t with
  | TInt -> "int"
  | TBool -> "bool"
  | TString -> "string"
  | TPair (t1, t2) -> 
    "pair of " ^ (string_of_typ t1) ^ ", " ^ (string_of_typ t2)
  | TLoc (inner_t) ->
    "loc of " ^ (string_of_typ inner_t)
  | TFun (arg_t, res_t) ->
    (string_of_typ arg_t) ^ " -> " ^ (string_of_typ res_t)
  | TVar (name) -> name


let substitute s t = 
  let rec substitute_one s1 t1 = 
    match t1 with 
    | TVar (name) -> 
      (match s1 with (s_name, s_type) -> 
        if name = s_name then s_type
        else t1)
    | TPair (fst_t, snd_t) ->
      TPair (substitute_one s1 fst_t, substitute_one s1 snd_t)
    | TLoc (inner_t) ->
      TLoc (substitute_one s1 inner_t)
    | TFun (arg_t, res_t) ->
      TFun (substitute_one s1 arg_t, substitute_one s1 res_t)
    | _ -> t1 in
  List.fold_right substitute_one s t

let substitute_env s tyenv =
  List.map (fun (n, tp) -> (n, substitute s tp)) tyenv

let string_of_subst subst =
  match subst with (name, t) -> name ^ ": " ^ (string_of_typ t)

let rec string_of_slist slist =
  match slist with
  | head :: tail -> (string_of_subst head) ^ ", " ^ (string_of_slist tail)
  | [] -> ""

let rec unify t1 t2 =
  match (t1, t2) with
  | (TInt, TInt) -> []
  | (TBool, TBool) -> []
  | (TString, TString) -> []
  | (TPair (t1_1, t1_2), TPair (t2_1, t2_2)) -> 
    let s = unify t1_1 t2_1 in
    let s' = unify (substitute s t1_2) (substitute s t2_2) in
    s' @ s
  | (TLoc inner_t1, TLoc inner_t2) -> unify inner_t1 inner_t2
  | (TFun (arg_t1, res_t1), TFun (arg_t2, res_t2)) ->
    let s = unify arg_t1 arg_t2 in
    let s' = unify (substitute s res_t1) (substitute s res_t2) in
    s' @ s
  | (TVar name1, TVar name2) ->
    if name1 = name2 then []
    else [(name1, t2)]
  | (TVar name, _) -> [(name, t2)]
  | (_, TVar name) -> [(name, t1)]
  | _ -> raise (M.TypeError ("Incompatible types " ^ (string_of_typ t1) ^ ", " ^ (string_of_typ t2)))

let unify_with_primitives t = 
  try unify TInt t
  with M.TypeError _ -> 
    try unify TBool t
    with M.TypeError _ ->
      try unify TString t
      with M.TypeError _ -> raise (M.TypeError ("type " ^ (string_of_typ t) ^ " is not primitive"))

let add_to_env (name, tp) tyenv =
  if (List.exists (fun (s, _) -> s = name) tyenv)
  then List.map (fun (s, t) -> if s = name then (s, tp) else (s, t)) tyenv
  else (name, tp) :: tyenv
    
let rec m_algorithm tyenv exp tp = 
  match exp with
  | M.CONST c ->
    (match c with
    | S _ -> unify TString tp
    | N _ -> unify TInt tp
    | B _ -> unify TBool tp)
  | M.VAR id ->
    let t = 
      try List.assoc id tyenv
      with Not_found -> raise (M.TypeError ("No type for " ^ id ^ " in type environment")) in
    unify tp t
  | M.FN (arg_id, f_body) ->
    let arg_t = TVar (new_var ()) in
    let res_t = TVar (new_var ()) in
    let s = unify (TFun (arg_t, res_t)) tp in
    let binding = (arg_id, (substitute s arg_t)) in
    let s' = m_algorithm (add_to_env binding (substitute_env s tyenv)) f_body (substitute s res_t) in
    s' @ s
  | M.APP (f_exp, arg_exp) ->
    let arg_t = TVar (new_var ()) in
    let s = m_algorithm tyenv f_exp (TFun (arg_t, tp)) in
    let s' = m_algorithm (substitute_env s tyenv) arg_exp (substitute s arg_t) in
    s' @ s
  | M.LET (decl, e_parent) -> 
    (match decl with
    | M.REC (f_id, arg_id, f_body) -> 
      let arg_t = TVar (new_var ()) in
      let res_t = TVar (new_var ()) in
      let arg_binding = (arg_id, arg_t) in
      let fun_binding = (f_id, TFun (arg_t, res_t)) in
      let tyenv' = add_to_env arg_binding (add_to_env fun_binding tyenv) in
      let s = m_algorithm tyenv' f_body res_t in
      let s' = m_algorithm (substitute_env s tyenv') e_parent (substitute s tp) in
      s' @ s
    | M.VAL (v_id, e_child) -> 
      let v_type = TVar (new_var ()) in
      let s = m_algorithm tyenv e_child v_type in
      let binding = (v_id, (substitute s v_type)) in
      let tyenv' = add_to_env binding (substitute_env s tyenv) in
      let s' = m_algorithm tyenv' e_parent (substitute s tp) in
      s' @ s)
  | M.IF (e_cond, e_if, e_else) -> 
    let s = m_algorithm tyenv e_cond TBool in
    let s' = m_algorithm (substitute_env s tyenv) e_if (substitute s tp) in
    let concat = s' @ s in
    let s'' = m_algorithm (substitute_env concat tyenv) e_else (substitute concat tp) in
    s'' @ concat
  | M.BOP (op, lhs, rhs) -> 
    (match op with
    | ADD -> 
      let s = unify TInt tp in
      let s' = m_algorithm (substitute_env s tyenv) lhs TInt in
      let concat = s' @ s in
      let s'' = m_algorithm (substitute_env concat tyenv) rhs TInt in
      s'' @ concat
    | SUB ->
      let s = unify TInt tp in
      let s' = m_algorithm (substitute_env s tyenv) lhs TInt in
      let concat = s' @ s in
      let s'' = m_algorithm (substitute_env concat tyenv) rhs TInt in
      s'' @ concat
    | EQ ->
      let s = unify TBool tp in
      let lhs_t = TVar (new_var ()) in
      let s' = m_algorithm (substitute_env s tyenv) lhs lhs_t in
      let concat0 = s' @ s in
      let subst_lhs_t = substitute concat0 lhs_t in
      let s'' = 
        try unify_with_primitives subst_lhs_t
        with M.TypeError _ ->
          let inner_t = TVar (new_var ()) in
          try unify (TLoc inner_t) subst_lhs_t
          with M.TypeError _ -> raise (M.TypeError ((string_of_typ subst_lhs_t) ^ " is not comparable.")) in
      let concat1 = s'' @ concat0 in
      let s''' = m_algorithm (substitute_env concat1 tyenv) rhs (substitute s'' subst_lhs_t) in
      s''' @ concat1
    | AND ->
      let s = unify TBool tp in
      let s' = m_algorithm (substitute_env s tyenv) lhs TBool in
      let concat = s' @ s in
      let s'' = m_algorithm (substitute_env concat tyenv) rhs TBool in
      s'' @ concat
    | OR -> 
      let s = unify TBool tp in
      let s' = m_algorithm (substitute_env s tyenv) lhs TBool in
      let concat = s' @ s in
      let s'' = m_algorithm (substitute_env concat tyenv) rhs TBool in
      s'' @ concat)
  | M.READ -> unify TInt tp
  | M.WRITE e -> 
    let s = m_algorithm tyenv e tp in
    let s' = unify_with_primitives (substitute s tp) in 
    s' @ s
  | M.MALLOC e -> 
    let inner_t = TVar (new_var ()) in
    let s = unify (TLoc inner_t) tp in
    let s' = m_algorithm (substitute_env s tyenv) e (substitute s inner_t) in
    s' @ s
  | M.ASSIGN (lhs, rhs) -> 
    let s = m_algorithm tyenv lhs (TLoc tp) in
    let s' = m_algorithm (substitute_env s tyenv) rhs (substitute s tp) in
    s' @ s
  | M.BANG e -> m_algorithm tyenv e (TLoc tp)
  | M.SEQ (e1, e2) -> 
    let s = m_algorithm tyenv e1 (TVar (new_var ())) in
    let s' = m_algorithm (substitute_env s tyenv) e2 (substitute s tp) in
    s' @ s
  | M.PAIR (e1, e2) -> 
    let t1 = TVar (new_var ()) in
    let t2 = TVar (new_var ()) in
    let s = unify (TPair (t1, t2)) tp in
    let s' = m_algorithm (substitute_env s tyenv) e1 (substitute s t1) in
    let concat = s'@ s in
    let s'' = m_algorithm (substitute_env concat tyenv) e2 (substitute concat t2) in
    s'' @ concat
  | M.FST e_pair -> 
    let t2 = TVar (new_var ()) in
    m_algorithm tyenv e_pair (TPair (tp, t2))
  | M.SND e_pair -> 
    let t1 = TVar (new_var ()) in
    m_algorithm tyenv e_pair (TPair (t1, tp))
 
let rec type_of_typ t =
  match t with
  | TInt -> M.TyInt
  | TBool -> M.TyBool
  | TString -> M.TyString
  | TPair (t1, t2) -> M.TyPair (type_of_typ t1, type_of_typ t2)
  | TLoc (inner_t) -> M.TyLoc (type_of_typ inner_t)
  | TFun (arg_t, res_t) -> M.TyArrow (type_of_typ arg_t, type_of_typ res_t)
  | TVar name -> raise (M.TypeError (name ^ " is undefined"))



(* TODO : Implement this function *)
let check : M.exp -> M.types = fun exp ->
  let p_type = TVar (new_var ()) in
  let s = m_algorithm [] exp p_type in
  type_of_typ (substitute s p_type)

