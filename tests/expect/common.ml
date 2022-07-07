open Epsilon

let print_syntax x = Main.parse_string x |> Pretty.syntax_tree |> print_endline
