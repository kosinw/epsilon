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
rule token =
  parse
  | newline                           { L.newline lexbuf; token lexbuf }
  | blank+                            { token lexbuf }
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
  | '"'                               { let b = Buffer.create 256 in STRING (string lexbuf.lex_start_p b lexbuf) }
  | identifier                        { ID (Lexing.lexeme lexbuf) }
  | eof                               { EOF }
  | _                                 { failwith "invalid token" } (* TODO: add proper syntax errors *)

and comment =
  parse
  | newline | eof                     { token lexbuf }
  | _                                 { comment lexbuf }

(* TODO(kosi): Add escape sequences *)
and string start buf =
  parse
  | '"'                             { lexbuf.lex_start_p <- start; Buffer.contents buf }
  | eof                             { failwith "invalid eof" }
  | _ as c                          { Buffer.add_char buf c; string start buf lexbuf; }