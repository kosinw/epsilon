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
    let of_int lexbuf =
      Lexing.lexeme lexbuf
      |> String.substr_replace_all ~pattern:"_" ~with_:""
      |> Int.of_string
  end
}

let letter = ['a'-'z' 'A'-'Z' '_']
let blank = [' ' '\t']
let newline = ('\n' | "\r\n" )

let digit = ['0'-'9']
let hex_digit = ['0'-'9' 'a'-'f' 'A'-'F']
let octal_digit = ['0'-'7']

let D = digit (digit | '_')*
let H = "0x" hex_digit (hex_digit | '_')*
let O = "0o" octal_digit (octal_digit | '_')*

let identifier = letter (letter | digit)*


(* Primary entrypoint for tokenizing Epsilon programs into tokens. *)
rule tokenize =
  parse
  | newline                           { Lexing.new_line lexbuf; tokenize lexbuf }
  | blank+                            { tokenize lexbuf }
  | "//"                              { comment lexbuf }

  | "fun"                             { FUN }
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

  | D | H | O                         { INT (Util.of_int lexbuf) }

  | identifier                        { ID (Lexing.lexeme lexbuf) }
  | eof                               { EOF }
  | _                                 { failwith "Invalid token" } (* TODO: add proper syntax errors *)

and comment =
  parse
  | newline | eof                     { tokenize lexbuf }
  | _                                 { comment lexbuf }