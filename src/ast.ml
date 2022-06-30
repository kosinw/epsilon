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

type id = string

type toplevel =
  | Defn of definition
  | Expr of expr

and definition = (id * expr) list

and expr =
  | ConstantExpr of constant
  | VarExpr of id
  | PrefixExpr of prefix_op * expr
  | InfixExpr of infix_op * expr * expr
  | ConditionalExpr of expr * expr * expr option
  | ApplicationExpr of expr * expr list

and constant =
  | Int of int
  | Bool of bool
  | Unit

and prefix_op =
  | Neg

and infix_op =
  | Plus
  | Minus
  | Times
  | Div
  | Mod
  | Eq
  | Ne
  | Lt
  | Gt
  | Le
  | Ge

type t = toplevel list