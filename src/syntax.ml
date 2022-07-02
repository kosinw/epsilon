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

(** Abstract syntax tree produced by parser. *)

type t = Program of expr [@@unboxed] [@@deriving show]

and id = string

and pattern' =
  | AnyPattern  (** The pattern [_]. *)
  | ConstPattern of const
      (** Patterns that match constants such as [1], ['a'], [true]. *)
  | VarPattern of id  (** A variable pattern like [x]. *)
  | ConstraintPattern of pattern * type_expr
      (** A pattern with a type annotation [(P : T)]. *)

and pattern = pattern' Location.t

and expr =
  | LetExpr of (pattern * expr) list
  | VarExpr of id
  | PrefixExpr of op * expr
  | InfixExpr of expr * op * expr
  | ConditionalExpr of expr * expr * expr option
  | FunExpr of pattern * expr
  | ApplicationExpr of expr * expr list
  | SequenceExpr of expr * expr
  | ConstExpr of const
  | ConstraintExpr of expr * type_expr

and const' =
  | IntConst of int
  | StringConst of string
  | BoolConst of bool
  | UnitConst

and const = const' Location.t

and type_expr =
  | ArrowType of type_expr * type_expr
  | ConstructorType of id * type_expr list

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
