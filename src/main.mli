(** Entrypoint module for the canonical Epsilon compiler. *)

val pp_syntax : Format.formatter -> Syntax.t -> unit [@@ocaml.toplevel_printer]
val parse_string : ?pos:Lexing.position -> string -> Syntax.t