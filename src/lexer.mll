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

{
  open Base
  open Parser

  module Util = struct
    (** [to_int lexbuf] converts the next lexeme from [lexbuf] from an
      Epsilon integer constant into an OCaml integer. *)
    let to_int lexbuf =
      Lexing.lexeme lexbuf
      |> String.substr_replace_all ~pattern:"_" ~with_:""
      |> Int.of_string
  end
}

let letter = ['a'-'z' 'A'-'Z' '_']
let blank = [' ' '\t']
let newline = ('\n' | "\r\n" )
let digit = ['0'-'9']
let integer = digit (digit | '_')*
let identifier = letter (letter | digit)*
let comment_start = "(*"
let comment_end = "*)"

(* Primary entrypoint for tokenizing Epsilon programs into tokens. *)
rule r =
  parse
  | newline                           { Lexing.new_line lexbuf; r lexbuf }
  | blank+                            { r lexbuf }
  | comment_start                     { c 0 lexbuf }

  | "let"                             { LET }
  | "in"                              { IN }
  | "match"                           { MATCH }
  | "type"                            { TYPE }
  | "if"                              { IF }
  | "then"                            { THEN }
  | "else"                            { ELSE }
  | "of"                              { OF }
  | "true"                            { TRUE }
  | "false"                           { FALSE }
  | "and"                             { AND }

  | "&&"                              { DAMPER }
  | "||"                              { DPIPE }
  | "{"                               { LBRACE }
  | "}"                               { RBRACE }
  | "["                               { LBRACK }
  | "]"                               { RBRACK }
  | "("                               { LPAREN }
  | ")"                               { RPAREN }
  | "'"                               { QUOTE }
  | "::"                              { DCOLON }
  | '@'                               { AT }
  | '\\'                              { LAMBDA }
  | "."                               { DOT }
  | ","                               { COMMA }
  | ";"                               { SEMI }
  | ":"                               { COLON }
  | "->"                              { RARR }
  | "<-"                              { LARR }
  | '|'                               { PIPE }

  | ">="                              { GE }
  | "<="                              { LE }
  | ">"                               { GT }
  | "<"                               { LT }
  | "!="                              { NE }
  | '='                               { EQ }
  | '+'                               { PLUS }
  | '-'                               { MINUS }
  | '*'                               { TIMES }
  | '/'                               { DIV }
  | '%'                               { MOD }

  | integer                           { INT (Util.to_int lexbuf) }
  | identifier                        { ID (Lexing.lexeme lexbuf) }
  | eof                               { EOF }
  | _                                 { failwith "Invalid token" } (* TODO: add proper syntax errors *)

and c level =
  parse
  | comment_start                     { c (level + 1) lexbuf }
  | comment_end                       { if level = 0 then r lexbuf else c (level - 1) lexbuf }
  | eof                               { failwith "Unexpected end-of-file, unterminated comment."}
  | _                                 { c level lexbuf }