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

type t = expr

and expr =
  | LetExpr of (id * expr) list
  | ConstantExpr of constant
  | VarExpr of id
  | PrefixExpr of op * expr
  | InfixExpr of expr * op * expr
  | ConditionalExpr of expr * expr * expr option
  | ApplicationExpr of expr * expr list
  | SequenceExpr of expr list

and constant =
  | Int of int
  | Bool of bool
  | Unit

and op =
  | PLUS
  | MINUS
  | TIMES
  | DIV
  | MOD
  | EQ
  | NE
  | GT
  | LT
  | GE
  | LE
  | AND
  | OR