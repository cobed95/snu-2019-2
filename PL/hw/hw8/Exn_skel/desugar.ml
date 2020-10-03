(*
 * SNU 4190.310 Programming Languages 
 * Homework "Exceptions are sugar" Skeleton
 *)

open Xexp

let var_count = ref 0

let new_name () = 
  let _ = var_count := !var_count + 1 in
  "k_" ^ (string_of_int !var_count)

let rec alpha_conv exp subst = 
  match exp with
  | Num n -> Num n
  | Var x -> (try Var (List.assoc x subst) with Not_found -> Var x)
  | Fn (x, e) ->
    let x' = new_name () in
    let subst' = (x, x') :: subst in
    Fn (x', alpha_conv e subst')
  | App (e1, e2) -> App (alpha_conv e1 subst, alpha_conv e2 subst)
  | If (e1, e2, e3) -> 
    If (alpha_conv e1 subst, alpha_conv e2 subst, alpha_conv e3 subst)
  | Equal (e1, e2) ->
    Equal (alpha_conv e1 subst, alpha_conv e2 subst)
  | Raise e ->
    Raise (alpha_conv e subst)
  | Handle (e1, n, e2) ->
    Handle (alpha_conv e1 subst, n, alpha_conv e2 subst)

let magic_number = 201912

(* TODO : Implement this function *)
let removeExn : xexp -> xexp = fun e ->
  let rec cps' exp =
    let e = new_name () in
    let k = new_name () in
    match exp with
    | Num n ->
      Fn (e, Fn (k, App (Var k, Num n)))
    | Var id ->
      Fn (e, Fn (k, App (Var k, Var id)))
    | Fn (arg_id, body) ->
      let e' = new_name () in
      let k' = new_name () in
      Fn (e,
        Fn (k, 
          App (Var k,
            Fn (arg_id,
              Fn (e',
                Fn (k',
                  App (
                    App (cps' body, Var e'),
                    Var k'
                  )
                )
              )
            )
          )
        )
      )
    | App (fun_exp, arg_exp) ->
      let v1 = new_name () in
      let v2 = new_name () in
      Fn (e,
        Fn (k,
          App (
            App (cps' fun_exp,
              Var e
            ),
            Fn (v1,
              App (
                App (cps' arg_exp,
                  Var e
                ),
                Fn (v2,
                  App (
                    App (
                      App (Var v1, Var v2),
                      Var e
                    ),
                    Var k
                  )
                )
              )
            )
          )
        )
      )
    | If (cond, if_body, else_body) ->
      let v1 = new_name () in
      let v2 = new_name () in
      let v3 = new_name () in
      Fn (e,
        Fn (k, 
          App (
            App (cps' cond,
              Var e
            ),
            Fn (v1,
              If (Var v1,
                App (
                  App (cps' if_body,
                    Var e
                  ),
                  Fn (v2,
                    App (Var k, Var v2)
                  )
                ),
                App (
                  App (cps' else_body,
                    Var e
                  ),
                  Fn (v3,
                    App (Var k, Var v3)
                  )
                )
              )
            )
          )
        )
      )
    | Equal (lhs, rhs) ->
      let v1 = new_name () in
      let v2 = new_name () in
      Fn (e,
        Fn (k, 
          App (
            App (cps' lhs,
              Var e
            ),
            Fn (v1,
              App (
                App (cps' rhs,
                  Var e
                ),
                Fn (v2,
                  App (Var k, Equal (Var v1, Var v2))
                )
              )
            )
          )
        )
      )
    | Raise exn_exp ->
      let v = new_name () in
      Fn (e,
        Fn (k, 
          App (
            App (cps' exn_exp, Var e),
            Fn (v, App (Var e, Var v))
          )
        )
      )
    | Handle (body, exn_num, handler) ->
      let exn_in_body = new_name () in
      let exn_in_handler = new_name () in
      let equality = new_name () in
      let handler_res = new_name () in
      let equality_check var_name num = Equal (Var var_name, Num num) in
      let shoot_up exn_name = App (Var e, Var exn_name) in
      let handle_here handled = App (Var k, Var handled) in
      let new_handler =
        Fn (exn_in_body,
          App (
            (* check equality *)
            App (cps' (equality_check exn_in_body exn_num), Var e),
            Fn (equality, 
              If (Var equality,
                (* if equal *)
                App (
                  (* if there is another exception in handler, shoot up *)
                  App (cps' handler, 
                    Fn (exn_in_handler, shoot_up exn_in_handler)
                  ),
                  (* else continue with result of handler *)
                  Fn (handler_res, handle_here handler_res)
                ),
                (* else shoot up *)
                (shoot_up exn_in_body)
              )
            )
          )
        ) in
      Fn (e,
        Fn (k,
          App (
            App (cps' body, new_handler),
            (* if no exception, continue *)
            Var k
          )
        )
      ) in
  let cps exp = cps' (alpha_conv exp []) in
  let var_start = new_name () in
  let ident = Fn (var_start, Var var_start) in
  let exc_start = new_name () in
  let base_exc = Fn (exc_start, Num magic_number) in
  App (App ((cps e), base_exc), ident)

