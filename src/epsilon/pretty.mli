(** This module handles pretty printing syntax trees in a tree-like format
    similar to the UNIX tree command. *)

val pp_syntax_tree : ?indent:int -> Format.formatter -> Syntax.t -> unit
(** [pp_syntax_tree ?indent ppf ast] pretty-prints the syntax tree into a tree-style format into a pretty printer. *)

val syntax_tree : ?indent:int -> Syntax.t -> string
(** [syntax_tree ?indent ast] pretty-prints the syntax tree into a tree-style format as a string. *)
