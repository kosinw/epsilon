(** This module handles pretty printing syntax trees in a tree-like format
    similar to the UNIX tree command. *)

val pp_syntax_tree : Format.formatter -> Syntax.t -> unit [@@ocaml.toplevel_printer]
(** [pp_syntax_tree ppf ast] pretty-prints the syntax tree into a tree-style format into a pretty printer. *)

val syntax_tree : Syntax.t -> string
(** [syntax_tree ast] pretty-prints the syntax tree into a tree-style format as a string. *)
