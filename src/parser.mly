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

/* Binary operators */
%token PLUS "+" MINUS "-" TIMES "*" DIV "/" MOD "%"
%token EQ "=" NE "!=" LT "<" GT ">" LE "<=" GE ">="

/* Keywords and Punctuation */
%token LET IN AND MATCH TYPE IF THEN ELSE OF TRUE FALSE
%token DAMPER "&&" DPIPE "||"
%token LBRACE "{" RBRACE "}" LBRACK "[" RBRACK "]"
%token LPAREN "(" RPAREN ")" QUOTE "'"
%token LAMBDA DOT "." COMMA "," SEMI ";" COLON ":"
%token RARR "->" LARR "<-" PIPE "|" AT "@" DCOLON "::"

%token EOF

%token <string> ID
%token <int> INT

%start <unit> r

%%

r:
  | EOF                                                         {()}
  ;