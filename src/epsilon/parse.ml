(* This module performs error recovery using Menhir's incremental and
   inspection APIs. 
   
   As there are tons of ways to recover from errors in parsing,
   this parser takes a panic-mode apporach to error recovery where when
   a syntax error is encountered, the lexer reverts to the most recent 
   expression reduction and continues parsing until it hits another 
   semicolon, parens, or curly brace.

   This avoids the problem where a syntax error may be encountered in the
   middle of an ill-defined expression or definition and ensures that
   the parser can reach the end 
*)

module I = Parser.MenhirInterpreter
module P = Parser
module L = Lexer

(* The concept of this submodule is to provide a persistent data structure
   as an abstraction over lexing states. The idea is I can take the lexer
   generated from ocamllex and simply cache all the tokens produced

   See: https://github.com/yurug/menhir-error-recovery
*)

(* module Lexer : sig
  type checkpoint
end = struct end *)

let parse lexbuf = P.main L.token lexbuf

let parse_string s =
  let lexbuf = Lexing.from_string s in
  parse lexbuf
