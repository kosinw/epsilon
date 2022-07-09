(** [pp_position ppf pos] pretty-prints a lexer position as a pair of the form
    [(ln x, col y)] where [x] is the line number the token originates from and [y]
    is the offset from the beginning of the line (starting at 0). *)
let pp_position ppf (pos : Lexing.position) =
  let ln = pos.pos_lnum in
  let col = pos.pos_cnum - pos.pos_bol in
  Format.fprintf ppf "@[<hov>(ln %i, col %i)@]" ln col

type position = (Lexing.position[@printer fun fmt -> fprintf "%a" pp_position])
type location = position * position [@@deriving show]
type 'a t = 'a * location [@@deriving show]

let make_location start finish = (start, finish)

let of_lexbuf lexbuf =
  make_location (Lexing.lexeme_start_p lexbuf) (Lexing.lexeme_end_p lexbuf)

let unwrap (data, _) = data
let mk (startpos, endpos) x = (x, make_location startpos endpos)
