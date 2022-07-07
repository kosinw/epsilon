(** Entrypoint module for the canonical Epsilon compiler. *)

val pp_syntax : Format.formatter -> Syntax.t -> unit
  [@@ocaml.toplevel_printer]
(** [pp_syntax ppf ast] pretty-prints the abstract syntax tree. *)

val parse_string : ?pos:Lexing.position -> string -> Syntax.t
(** [parse_string ?pos s] parses an input string to an abstract syntax tree. *)

val parse_chan : ?pos:Lexing.position -> in_channel -> Syntax.t
(** [parse_chan ?pos c] parses input received from an input channel into an abstract syntax tree. *)

val parse_file : string -> Syntax.t
(** [parse_file s] parses file at path [s] into an abstract syntax tree. *)
