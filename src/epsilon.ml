open Base

let parse_string s =
  let lexbuf = Lexing.from_string s in
  let tokens = ref [] in

  let rec loop () =
    let token = Lexer.r lexbuf in
    tokens := token :: !tokens;

    match token with Parser.EOF -> () | _ -> loop ()
  in

  loop ();

  List.rev !tokens
