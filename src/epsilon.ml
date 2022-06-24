open Base

type token = [%import: Parser.token] [@@deriving show]
type tokens = token list [@@deriving show]

(** [parse_string s] compiles valid Epsilon programs into syntax trees. *)
let parse_string s =
  let lexbuf = Lexing.from_string s in
  let tokens : tokens ref = ref [] in

  let rec loop () =
    let token = Lexer.tokenize lexbuf in
    tokens := token :: !tokens;

    match token with Parser.EOF -> () | _ -> loop ()
  in

  loop ();

  List.rev !tokens
