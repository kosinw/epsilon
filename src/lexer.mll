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
  open Base

  let to_int lexbuf =
    Lexing.lexeme lexbuf
    |> String.substr_replace_all ~pattern:"_" ~with_:""
    |> Int.of_string
}

let letter = ['a'-'z' 'A'-'Z' '_']
let whitespace = [' ' '\t']
let newline = ('\n' | "\r\n" )
let int_literal = ['0'-'9']['0'-'9' '_']*

rule tokenize =
  parse
  | newline                           { Lexing.new_line lexbuf; tokenize lexbuf }
  | whitespace+                       { tokenize lexbuf }
  | '+'                               { PLUS }
  | '-'                               { MINUS }
  | '*'                               { TIMES }
  | '/'                               { DIV }
  | int_literal                       { INT (to_int lexbuf) }
  | letter+                           { ID (Lexing.lexeme lexbuf) }
  | eof                               { EOF }