%{
  open Syntax
%}

(*
  TODO(kosinw): The following language features and syntax still need to be implemented:
  - Qualified name access (e.g. fields and modules)
  - Type definitions
  - Floating point numbers
  - Variants
  - Type parameters (polymorphism)
  - List literals and operators
  - Pattern matching
  - Mutable bindings
  - Remove hard-coding of Array.make
*)

(* Binary operators *)
%token PLUS "+" MINUS "-" TIMES "*" DIV "/" MOD "%"
%token EQ "=" NE "!=" LT "<" GT ">" LE "<=" GE ">="

(* Keywords and Punctuation *)
%token FUN "fun" LET "let" AND "and" TYPE "type" IF "if" 
%token ELSE "else" MUTABLE "mutable" 
%token TRUE "true" FALSE "false"
%token DAMPER "&&" DPIPE "||"
%token LBRACE "{" RBRACE "}" LBRACK "[" RBRACK "]"
%token LPAREN "(" RPAREN ")" USCORE "_"
%token DOT "." COMMA "," SEMI ";" COLON ":" RARR "->"

(* Other tokens *)
%token <string> ID
%token <string> STRING
%token <int> INT
%token EOF

(* Operator precedence and assosciativity *)
(* Lowest precedence *)
%right        "->"
%nonassoc     "else"
%right        "||"
%right        "&&"
%nonassoc     "=" "!=" "<" ">" "<=" ">="
%left         "+" "-"
%left         "*" "/" "%"
%nonassoc     PREFIX
(* Highest precedence *)

%start <Syntax.t> main

%%

let main := 
  | ~ = terminated(seq_expr_body, EOF);                           < Program >
  | EOF;                                                          { Invalid }

(* PATTERNS *)
let complex_pattern :=
  | pattern
  | constraint_pattern

let constraint_pattern ==
  | mark(constraint_pattern_)

let constraint_pattern_ :=
  | ~ = pattern; ":"; ~ = type_expr;                             < ConstraintPattern >

let pattern ==
  | mark(pattern_)
  | delimited("(", complex_pattern, ")")

let pattern_ :=
  | "_";                                                         { AnyPattern }
  | ~ = const;                                                   < ConstPattern >
  | ~ = mark(ID);                                                < VarPattern >

(* CONSTANTS *)
let const ==
  | mark(const_)

let const_ :=
  | i = INT;                                                      { IntConst i }
  | s = STRING;                                                   { StringConst s }
  | "true";                                                       { BoolConst true }
  | "false";                                                      { BoolConst false }
  | "("; ")";                                                     { UnitConst }

let op ==
  | "+";                                                          { Syntax.PLUS }
  | "-";                                                          { Syntax.MINUS }
  | "*";                                                          { Syntax.TIMES }
  | "/";                                                          { Syntax.DIV }
  | "%";                                                          { Syntax.MOD }
  | "=";                                                          { Syntax.EQ }
  | "!=";                                                         { Syntax.NE }
  | ">";                                                          { Syntax.GT }
  | "<";                                                          { Syntax.LT }
  | ">=";                                                         { Syntax.GE }
  | "<=";                                                         { Syntax.LE }
  | "&&";                                                         { Syntax.AND }
  | "||";                                                         { Syntax.OR }

(* TYPE EXPRESSIONS *)
let type_expr :=
  | primitive_type_expr
  | arrow_type_expr

let primitive_type_expr ==
  | mark(primitive_type_expr_)
  | delimited("(", type_expr, ")")

let primitive_type_expr_ :=
  | x = mark(ID);                                                 { ConstructorType (x, []) }
  | x = mark(ID); l = delimited("(", type_argument_list, ")");    { ConstructorType (x, l) }
 
let type_argument_list :=
  | separated_nonempty_list(",", type_expr)

let arrow_type_expr ==
  | mark(arrow_type_expr_)

let arrow_type_expr_ :=
  | a = primitive_type_expr; "->"; b = primitive_type_expr;       { ArrowType (a, b) } 
  | x = primitive_type_expr; "->"; xs = arrow_type_expr;          { ArrowType (x, xs) }

(** COMPLEX EXPRESSIONS **)
let seq_expr_item :=
  | mark(let_definition)
  | expr

let let_definition ==
  | ~ = preceded("let", let_bindings);                            < LetExpr >

let let_bindings :=
  | separated_nonempty_list("and", let_binding)

let let_binding :=
  | p = complex_pattern; "="; e = expr;                           { p, e }

(* VALUE EXPRESSIONS *)
let expr :=
  | simple_expr
  | mark(conditional_expr)
  | mark(prefix_expr)
  | mark(infix_expr)
  | fun_expr
  | mark(application_expr)
  | mark(constraint_expr)

let simple_expr :=  
  | mark(constant_expr)
  | mark(var_expr)
  | seq_expr
  | delimited("(", expr, ")")

let constant_expr ==
  | ~ = const;                                                    < ConstExpr >

let var_expr ==
  | ~ = mark(ID);                                                 < VarExpr >

let prefix_expr ==
  | "-"; ~ = expr; %prec PREFIX                                   { PrefixExpr (MINUS, expr) }

let infix_expr ==
  | e1 = expr; e2 = op; e3 = expr;                                { InfixExpr (e1, e2, e3) }
  
let conditional_expr ==
  | "if"; c = delimited("(", expr, ")"); t = simple_expr;                                 
                                                                  { ConditionalExpr (c, t, None) }
  | "if"; c = delimited("(", expr, ")"); t = simple_expr; "else"; f = expr;               
                                                                  { ConditionalExpr (c, t, Some f) }
let fun_expr ==
  | preceded("fun", fun_expr_body)

let fun_expr_body :=
  | x = pattern; "->"; y = expr;                                  { Location.mk $sloc (FunExpr (x, y)) }
  | x = pattern; xs = fun_expr_body;                              { Location.mk $sloc (FunExpr (x, xs)) }

let application_expr ==
  | f = simple_expr; a = simple_expr+;                            < ApplicationExpr >

let constraint_expr ==
  | "("; e = expr; ":"; t = type_expr; ")";                       { ConstraintExpr (e, t)  }

let seq_expr ==
  | delimited("{", seq_expr_body, "}")

let seq_expr_body :=
  | x = seq_expr_item; ";"?;                                     { x }
  | x = seq_expr_item; ";"; xs = seq_expr_body;                  { Location.mk $sloc (SequenceExpr (x, xs)) }

(** UTILITIES **)
let mark(X) ==
  | x = X;                                                        { Location.mk $sloc x }
(** [mark X] transforms the semantic action of the production X to produce a type of
  ['a Location.t] where ['a] is the type of the semantic action of X. *)