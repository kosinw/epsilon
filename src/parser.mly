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

%{
  open Ast
%}

(* Binary operators *)
%token PLUS "+" MINUS "-" TIMES "*" DIV "/" MOD "%"
%token EQ "=" NE "!=" LT "<" GT ">" LE "<=" GE ">="

(* Keywords and Punctuation *)
%token FUN LET IN AND MATCH TYPE IF THEN ELSE OF TRUE FALSE
%token DAMPER "&&" DPIPE "||"
%token LBRACE "{" RBRACE "}" LBRACK "[" RBRACK "]"
%token LPAREN "(" RPAREN ")" QUOTE "'"
%token DOT "." COMMA "," SEMI ";" COLON ":"
%token RARR "->" LARR "<-" PIPE "|" AT "@" DCOLON "::"

(* Other tokens *)
%token <string> ID
%token <int> INT
%token EOF

(* Operator precedence and assosciativity *)
%nonassoc     THEN
%nonassoc     ELSE
%left         "+" "-"
%left         "*" "/"
%nonassoc     PREFIX
%left         APP

%start <Ast.t> program

%%

// TODO(kosinw): Add optional ';;' after every compilation item for delimiting items.
// This is useful in the scenario of having a toplevel where a ';;' means compile
// everything before ';;'.

//
// === TOPLEVEL ===
//
let program :=
  | ~ = separated_list(";", toplevel); EOF;       <>

let toplevel :=
  | ~ = definition; < Defn >
  | ~ = expr;       < Expr >

//
// === DEFINITIONS ===
//
let definition :=
  | let_definition

let let_definition ==
  | LET; ~ = separated_nonempty_list(AND, let_binding); <>

let let_binding :=
  | n = ID; "="; e = expr;  { n, e }

//
// === EXPRESSIONS ===
//
let expr :=
  | simple_expr 
  | prefix_expr
  | infix_expr
  | conditional_expr
  | application_expr

let simple_expr :=
  | constant_expr
  | variable_expr
  | delimited("(", expr, ")")

let constant_expr ==
  | x = INT;                { ConstantExpr (Int x) }
  | TRUE;                   { ConstantExpr (Bool true) }
  | FALSE;                  { ConstantExpr (Bool false) }
  | "("; ")";               { ConstantExpr Unit }

let infix_expr ==
  | e1 = expr; b = infix_op; e2 = expr; { InfixExpr (b, e1, e2) }

let infix_op ==
  | "+";    { Plus }
  | "-";    { Minus }
  | "*";    { Times }
  | "/";    { Div }

let prefix_expr ==
  | "-"; ~ = expr;  %prec PREFIX { PrefixExpr (Neg, expr) }

let variable_expr ==
  | ~ = ID; < VarExpr >

let conditional_expr ==
  | IF; e1 = expr; THEN; e2 = expr; e3 = ioption(ELSE; expr); < ConditionalExpr >

let application_expr ==
  | ~ = expr; ~ = arguments; %prec APP < ApplicationExpr >

let arguments :=
  | simple_expr+