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

let show_spans = ref true

let pp_positions ppf (p : Lexing.position * Lexing.position) =
  let ln (pos : Lexing.position) = pos.pos_lnum in
  let col (pos : Lexing.position) = pos.pos_cnum - pos.pos_bol in
  let s, f = p in
  Format.fprintf ppf "@,@[<hov 2>{from = (%i, %i),@ to = (%i, %i)}@]" (ln s)
    (col s) (ln f) (col f)

type span =
  | Somewhere of Lexing.position * Lexing.position
      [@printer fun ppf -> fprintf ppf "%a" pp_positions]
      (** A value representing a span between two positions. *)
  | Nowhere [@printer fun ppf _ -> fprintf ppf "nowhere"]
      (** A value representing the absence of a span. *)
[@@deriving show]

type 'a t = { data : 'a; span : span }

let make_span start finish = Somewhere (start, finish)

let span_of_lexbuf lexbuf =
  make_span (Lexing.lexeme_start_p lexbuf) (Lexing.lexeme_end_p lexbuf)

let unwrap { data; _ } = data

let locate ?(s = Nowhere) x = { data = x; span = s }
let mk (startpos, endpos) x = locate ~s:(make_span startpos endpos) x

let pp fmt1 ppf x =
  if !show_spans then Format.fprintf ppf "%a %a" fmt1 x.data pp_span x.span
  else Format.fprintf ppf "%a" fmt1 x.data

let show fmt1 x =
  let ppf = Format.str_formatter in
  pp fmt1 ppf x;
  Format.flush_str_formatter ()
