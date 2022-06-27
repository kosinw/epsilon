open! Base

module Parser = Nice_parser.Make (struct
  type result = Syntax.module_unit
  type token = Parser.token

  exception ParseError = Parser.Error

  let parse = Parser.compilation_unit

  include Lexer
end)

let parse_string, parse_file, parse_chan =
  Parser.(parse_string, parse_file, parse_chan)
