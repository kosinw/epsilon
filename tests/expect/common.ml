open Epsilon
module Parse = Epsilon.Parse

let print_syntax x = Parse.parse_string x |> Pretty.syntax_tree |> print_endline
