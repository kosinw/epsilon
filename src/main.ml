(* TODO(kosinw): Move this out into seperate module and have proper
   entry point for the compiler. *)
include Nice_parser.Make (struct
  type result = Syntax.t
  type token = Parser.token

  exception ParseError = Parser.Error

  let parse = Parser.main

  include Lexer
end)

let ( >> ) f g x = g (f x)
let pp = parse_string >> (Syntax.show >> print_endline)
let () = pp_exceptions ()
