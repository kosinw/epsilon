(** Module for handling source code locations. *)

type location
(** Source location ranges in source programs. *)

type 'a t
(** A node tagged with location data. *)

val make_location : Lexing.position -> Lexing.position -> location
(** [make_location start finish] creates a new location range from two lexer positions.  *)

val of_lexbuf : Lexing.lexbuf -> location
(** [of_lexbuf lexbuf] gets the location range from current lexer buffer and creates
    a new span from it. *)

val unwrap : 'a t -> 'a
(** [unwrap x] removes the location information from [x]. *)

val mk : Lexing.position * Lexing.position -> 'a -> 'a t
(** [mk pos x] creates a node tagged with location data given a pair of [Lexing.position]
    and a node [x]. *)

val pp : (Format.formatter -> 'a -> unit) -> Format.formatter -> 'a t -> unit
val show : (Format.formatter -> 'a -> unit) -> 'a t -> string
