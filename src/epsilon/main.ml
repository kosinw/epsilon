(* TODO(kosinw): Move this out into seperate module and have proper
   entry point for the compiler. *)
include Nice_parser.Make (struct
  include Lexer

  type result = Syntax.t
  type token = Parser.token

  exception ParseError = Parser.Error
  exception LexError = Failure

  let parse = Parser.main
  let next_token = Lexer.token
end)

let pp_syntax = Pretty.pp_syntax_tree ~indent:2
let () = pp_exceptions ()
