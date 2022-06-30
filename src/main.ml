(* TODO(kosinw): Move this out into seperate module and have proper
   entry point for the compiler. *)
include Nice_parser.Make (struct
  type result = Ast.t
  type token = Parser.token

  exception ParseError = Parser.Error

  let parse = Parser.program

  include Lexer
end)