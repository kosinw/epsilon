(** This module contains type definitions for the abstract syntax
    tree produced by the parser module. *)

(* TODO(kosinw):
   - Add documentation strings to every prime type (e.g. expr', const')
   - Move operator to string coversion into this module *)

type t = Program of expr [@@unboxed] [@@deriving show]

and pattern' =
  | AnyPattern  (** The pattern [_]. *)
  | ConstPattern of const
      (** Patterns that match constants such as [1], ['a'], [true]. *)
  | VarPattern of id  (** A variable pattern like [x]. *)
  | ConstraintPattern of pattern * type_expr
      (** A pattern with a type annotation [(P : T)]. *)

and pattern = pattern' Location.t

and expr' =
  | LetExpr of (pattern * expr) list
  | VarExpr of id
  | PrefixExpr of operator * expr
  | InfixExpr of expr * operator * expr
  | ConditionalExpr of expr * expr * expr option
  | FunExpr of pattern * expr
  | ApplicationExpr of expr * expr list
  | SequenceExpr of expr * expr
  | ConstExpr of const
  | ConstraintExpr of expr * type_expr

and expr = expr' Location.t

and const' =
  | IntConst of int
  | StringConst of string
  | BoolConst of bool
  | UnitConst

and const = const' Location.t

and type_expr' =
  | ArrowType of type_expr * type_expr
  | ConstructorType of id * type_expr list

and type_expr = type_expr' Location.t

and operator =
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

and id = string Location.t
