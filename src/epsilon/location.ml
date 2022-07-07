type position = Lexing.position

(** [pp_position ppf pos] pretty-prints a lexer position as a pair of the form
    [(ln x, col y)] where [x] is the line number the token originates from and [y]
    is the offset from the beginning of the line (starting at 0). *)
let pp_position ppf (pos : position) =
  let ln = pos.pos_lnum in
  let col = pos.pos_cnum - pos.pos_bol in
  Format.fprintf ppf "@[<hov>(ln %i, col %i)@]" ln col

type location =
  | Somewhere of position * position
      (** A value representing a span between two positions. *)
  | Nowhere  (** A value representing the absence of a span. *)
[@@deriving show]

type 'a t = 'a * location [@@deriving show]

let make_location start finish = Somewhere (start, finish)

let of_lexbuf lexbuf =
  make_location (Lexing.lexeme_start_p lexbuf) (Lexing.lexeme_end_p lexbuf)

let unwrap (data, _) = data
let locate ?(s = Nowhere) x = (x, s)
let mk (startpos, endpos) x = locate ~s:(make_location startpos endpos) x