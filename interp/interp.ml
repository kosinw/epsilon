(*
 Copyright (c) 2022 Kosi Nwabueze

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *)

open Base
open Poly

type id = string
type binop = Plus | Times | Minus | Div

type stmt =
  | CompoundStmt of stmt * stmt
  | AssignStmt of id * expr
  | PrintStmt of expr list

and expr =
  | IdExpr of id
  | NumExpr of int
  | OpExpr of expr * binop * expr
  | EseqExpr of stmt * expr

let program =
  CompoundStmt
    ( AssignStmt ("a", OpExpr (NumExpr 5, Plus, NumExpr 3)),
      CompoundStmt
        ( AssignStmt
            ( "b",
              EseqExpr
                ( PrintStmt [ IdExpr "a"; OpExpr (IdExpr "a", Minus, NumExpr 1) ],
                  OpExpr (NumExpr 10, Times, IdExpr "a") ) ),
          PrintStmt [ IdExpr "b" ] ) )

(** A module of utility functions. *)
module type Util = sig
  val max_of_int : int list -> int
  (** [max_of_int lst] returns [None] if [lst] is empty; otherwise returns 
      [Some v] where v is the maximum integer in the list.*)

  val max : int -> int -> int
  (** [max a b] returns [a] if [b < a] otherwise returns [b]. *)

  val list_of_string : int list -> string
  (** [list_of_string lst] returns a string representation of list, [lst]. *)
end

module Util : Util = struct
  let rec max_of_int_aux acc = function
    | [] -> acc
    | x :: t ->
        let next = match acc with None -> Some x | Some v -> Some (max v x) in
        max_of_int_aux next t

  let max_of_int lst =
    match max_of_int_aux None lst with
    | Some v -> v
    | None -> failwith "Invalid argument: [lst] was empty."

  let max a b = if b < a then a else b

  let list_of_string lst =
    String.concat ~sep:"; " (List.map ~f:Int.to_string lst)
    |> Printf.sprintf "[%s]"
end

let rec maxargs : stmt -> int = function
  | CompoundStmt (a, b) -> max (maxargs a) (maxargs b)
  | AssignStmt (_, expr) -> exprargs expr
  | PrintStmt exprs ->
      let maxSubexprs = exprs |> List.map ~f:exprargs |> Util.max_of_int in
      Util.max maxSubexprs (List.length exprs)

and exprargs : expr -> int = function
  | IdExpr _ | NumExpr _ -> 0
  | OpExpr (e1, _, e2) -> max (exprargs e1) (exprargs e2)
  | EseqExpr (stmt, expr) -> Util.max (maxargs stmt) (exprargs expr)

module Table = struct
  type t = (id * int) list

  let empty : t = []
  let update : t * id * int -> t = fun (t, id, v) -> (id, v) :: t

  let rec lookup : t * id -> int = function
    | (a, v) :: _, id when a = id -> v
    | _ :: t, id -> lookup (t, id)
    | [], _ -> failwith "Invalid lookup"
end

let rec interp_stmt : stmt * Table.t -> Table.t =
 fun (stmt, t) ->
  match stmt with
  | CompoundStmt (l, r) -> interp_stmt (r, interp_stmt (l, t))
  | AssignStmt (i, e) ->
      let v, t = interp_expr (e, t) in
      Table.update (t, i, v)
  | PrintStmt exprs ->
      let l, t = List.fold_left ~f:fold_expr_list ~init:([], t) exprs in
      Stdio.print_endline (Util.list_of_string (List.rev l));
      t

and fold_expr_list (expr_list, t) expr =
  let ev, t = interp_expr (expr, t) in
  (ev :: expr_list, t)

and interp_expr : expr * Table.t -> int * Table.t =
 fun (expr, t) ->
  match expr with
  | IdExpr id -> (Table.lookup (t, id), t)
  | NumExpr n -> (n, t)
  | OpExpr (l, op, r) -> (
      let lr, t = interp_expr (l, t) in
      let rr, t = interp_expr (r, t) in
      match op with
      | Plus -> (lr + rr, t)
      | Times -> (lr * rr, t)
      | Minus -> (lr - rr, t)
      | Div -> (lr / rr, t))
  | EseqExpr (s, e) ->
      let t = interp_stmt (s, t) in
      interp_expr (e, t)

let interp stmt : unit =
  interp_stmt (stmt, Table.empty) |> ignore;
  ()

let () =
  Stdio.printf "%d\n" (maxargs program);
  interp program
