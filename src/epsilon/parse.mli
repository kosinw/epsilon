(** This module contains entry points for the language parser. The parser may output
    diagnostic information if any errors or warnings are encountered in which case
    an exception is raised. Otherwise, a syntax tree is produced to be used with
    later stages of the compiler. *)

val parse_string : string -> Syntax.t
(** [parse_string s] parses [s] into a abstract syntax tree if [s]  *)
