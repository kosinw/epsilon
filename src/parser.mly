// Copyright (c) 2022 Kosi Nwabueze
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

%{
  open Syntax
%}

/* Binary operators */
%token PLUS "+" MINUS "-" TIMES "*" DIV "/" MOD "%"
%token EQ "=" NE "!=" LT "<" GT ">" LE "<=" GE ">="

/* Keywords and Punctuation */
%token FUN LET IN AND MATCH TYPE IF THEN ELSE OF TRUE FALSE
%token DAMPER "&&" DPIPE "||"
%token LBRACE "{" RBRACE "}" LBRACK "[" RBRACK "]"
%token LPAREN "(" RPAREN ")" QUOTE "'"
%token DOT "." COMMA "," SEMI ";" COLON ":"
%token RARR "->" LARR "<-" PIPE "|" AT "@" DCOLON "::"

%token EOF

%token <string> ID
%token <int> INT

%start <Syntax.module_unit> compilation_unit

%%

// TODO(kosinw): Add optional ';;' after every compilation item for delimiting items.
// This is useful in the scenario of having a toplevel where a ';;' means compile
// everything before ';;'.

//
// === COMPILATION UNITS ===
//
let compilation_unit :=
  | items = compilation_item+; EOF; { MUnit items }

let compilation_item ==
  | ~ = definition; < MDefn >
  | ~ = expr;       < MExpr >

//
// === DEFINITIONS ===
//
let definition :=
  | ~ = let_definition; <>

let let_definition :=
  | LET; ~ = separated_nonempty_list(AND, let_binding); < DLet >

let let_binding ==
  | n = ID; "="; e = expr;  { { name = n; expr = e; } }

//
// === EXPRESSIONS ===
//
let expr :=
  | ~ = constant_expr; <>

let constant_expr ==
  | ~ = INT;  < EInt >