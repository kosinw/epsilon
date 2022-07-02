(*
 Copyright (c) 2022 Kosi Nwabueze

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *)

(** Module for handling source code locations. *)

type span
(** Source location ranges in source programs. *)

type 'a t
(** A node tagged with location data. *)

val make_span : Lexing.position -> Lexing.position -> span
(** [make_span start finish] creates a new span from two lexer positions.  *)

val span_of_lexbuf : Lexing.lexbuf -> span
(** [span_of_lexbuf lexbuf] gets the location range from current lexer buffer and creates
    a new span from it. *)

val locate : ?s:span -> 'a -> 'a t
(** [locate ?s x m] wraps a value [x] with an optional location range [s]. *)

val mk : Lexing.position * Lexing.position -> 'a -> 'a t
(** [mk pos x] creates a node tagged with location data given a pair of [Lexing.position]
    and a node [x]. *)

val pp : (Format.formatter -> 'a -> unit) -> Format.formatter -> 'a t -> unit

val show: (Format.formatter -> 'a -> unit) -> 'a t -> string