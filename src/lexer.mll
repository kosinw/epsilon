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
  open Parser
  module L = MenhirLib.LexerUtil

  module Util = struct
    (** [to_int lexbuf] converts the next lexeme from [lexbuf] from an
      Epsilon integer constant into an OCaml integer. *)
    let of_int lexbuf =
      Lexing.lexeme lexbuf
      |> Stdlib.int_of_string
  end

  exception LexError of string
}

let letter = ['a'-'z' 'A'-'Z']
let blank = [' ' '\t']
let newline = ('\n' | "\r\n" )

let digit = ['0'-'9']
let hex_digit = ['0'-'9' 'a'-'f' 'A'-'F']
let octal_digit = ['0'-'7']

let dec = digit (digit | '_')*
let hex = "0x" hex_digit (hex_digit | '_')*
let oct = "0o" octal_digit (octal_digit | '_')*

(* TODO(kosinw): Adding hack to lexer to include dots in identifiers so that
  certain functions like Array.length and Array.make will work *)
let identifier = (letter | '_') (letter | digit | '_' | "'" | '.')*

(* Primary entrypoint for tokenizing Epsilon programs into tokens. *)
rule next_token =
  parse
  | newline                           { L.newline lexbuf; next_token lexbuf }
  | blank+                            { next_token lexbuf }
  | "//"                              { comment lexbuf }
  | "fun"                             { FUN }
  | "let"                             { LET }
  | "and"                             { AND }
  | "type"                            { TYPE }
  | "if"                              { IF }
  | "else"                            { ELSE }
  | "mutable"                         { MUTABLE }
  | "true"                            { TRUE }
  | "false"                           { FALSE }
  | "&&"                              { DAMPER }
  | "||"                              { DPIPE }
  | "{"                               { LBRACE }
  | "}"                               { RBRACE }
  | "["                               { LBRACK }
  | "]"                               { RBRACK }
  | "("                               { LPAREN }
  | ")"                               { RPAREN }
  | "."                               { DOT }
  | ","                               { COMMA }
  | ";"                               { SEMI }
  | ":"                               { COLON }
  | "->"                              { RARR }
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
  | '_'                               { USCORE }
  | dec | hex | oct                   { INT (Util.of_int lexbuf) }
  | '"'                               { let b = Buffer.create 256 in STRING (next_string lexbuf.lex_start_p b lexbuf) }
  | identifier                        { ID (Lexing.lexeme lexbuf) }
  | eof                               { EOF }
  | _                                 { raise @@ LexError "invalid token" } (* TODO: add proper syntax errors *)

and comment =
  parse
  | newline | eof                     { next_token lexbuf }
  | _                                 { comment lexbuf }

(* TODO(kosi): Add escape sequences *)
and next_string start buf =
  parse
  | '"'                             { lexbuf.lex_start_p <- start; Buffer.contents buf }
  | eof                             { raise @@ LexError "invalid eof" }
  | _ as c                          { Buffer.add_char buf c; next_string start buf lexbuf; }