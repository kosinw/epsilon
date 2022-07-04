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

module Tree : sig
  (** Intermediate representation before abstract syntax tree is pretty printed. *)
  type t = Leaf of string * t list | Terminal of string

  val of_syntax : Syntax.t -> t
  (** [of_syntax ast] convers an abstract syntax tree into intermediate representation. *)
end = struct
  type t = Leaf of string * t list | Terminal of string

  let make_leaf text children = Leaf (text, children)
  let make_terminal text = Terminal text

  let rec of_syntax (Program e : Syntax.t) =
    make_leaf "Program" [ of_expr (Location.unwrap e) ]

  and of_pattern : Syntax.pattern' -> t = function
    | AnyPattern -> make_terminal "AnyPattern"
    | ConstPattern c ->
        Location.unwrap c |> of_const
        |> Printf.sprintf "ConstPattern: %s"
        |> make_terminal
    | VarPattern v ->
        Location.unwrap v |> Printf.sprintf "VarPattern: %s" |> make_terminal
    | ConstraintPattern (p, te) ->
        let p' = Location.unwrap p |> of_pattern in
        let te' = Location.unwrap te |> of_type_expr in
        make_leaf "ConstraintPattern" [ p'; te' ]

  and of_expr = function
    | LetExpr l ->
        let l' = List.map of_binding l in
        make_leaf "LetExpr" l'
    | VarExpr v ->
        Location.unwrap v |> Printf.sprintf "VarExpr: %s" |> make_terminal
    | PrefixExpr (o, e) ->
        let e' = Location.unwrap e in
        let contents = Printf.sprintf "PrefixExpr: %s" (of_operator o) in
        make_leaf contents [ of_expr e' ]
    | InfixExpr (e1, o, e2) ->
        let e1' = Location.unwrap e1 in
        let e2' = Location.unwrap e2 in
        let contents = Printf.sprintf "InfixExpr: %s" (of_operator o) in
        make_leaf contents [ of_expr e1'; of_expr e2' ]
    | ConditionalExpr (c, t, f) ->
        let exprs =
          [ Some c; Some t; f ]
          |> List.filter_map (Option.map Location.unwrap)
          |> List.map of_expr
        in
        make_leaf "ConditionalExpr" exprs
    | FunExpr (p, e) ->
        let p' = Location.unwrap p |> of_pattern in
        let e' = Location.unwrap e |> of_expr in
        make_leaf "FunExpr" [ p'; e' ]
    | ApplicationExpr (e, l) ->
        let children =
          e :: l |> List.map (fun x -> x |> Location.unwrap |> of_expr)
        in
        make_leaf "ApplicationExpr" children
    | SequenceExpr (e1, e2) ->
        let children =
          [ e1; e2 ] |> List.map (fun x -> x |> Location.unwrap |> of_expr)
        in
        make_leaf "SequenceExpr" children
    | ConstExpr c ->
        Location.unwrap c |> of_const
        |> Printf.sprintf "ConstExpr: %s"
        |> make_terminal
    | ConstraintExpr (e, te) ->
        let e' = Location.unwrap e |> of_expr in
        let te' = Location.unwrap te |> of_type_expr in
        make_leaf "ConstraintExpr" [ e'; te' ]

  and of_binding (p, e) =
    let p' = Location.unwrap p |> of_pattern in
    let e' = Location.unwrap e |> of_expr in
    make_leaf "LetDefinition" [ p'; e' ]

  and of_const = function
    | IntConst i -> Int.to_string i
    | StringConst s -> {|"|} ^ s ^ {|"|}
    | BoolConst b -> Bool.to_string b
    | UnitConst -> "()"

  and of_type_expr = function
    | ConstructorType (i, []) ->
        let contents =
          Printf.sprintf "ConstructorType: %s" (Location.unwrap i)
        in
        make_terminal contents
    | ConstructorType (i, l) ->
        let children =
          List.map (fun x -> x |> Location.unwrap |> of_type_expr) l
        in
        let contents =
          Printf.sprintf "ConstructorType: %s" (Location.unwrap i)
        in
        make_leaf contents children
    | ArrowType (te1, te2) ->
        let children =
          [ te1; te2 ]
          |> List.map (fun x -> x |> Location.unwrap |> of_type_expr)
        in
        make_leaf "ArrowType" children

  and of_operator = function
    | PLUS -> "+"
    | MINUS -> "-"
    | TIMES -> "*"
    | DIV -> "/"
    | MOD -> "%"
    | EQ -> "="
    | NE -> "!="
    | GT -> ">"
    | LT -> "<"
    | GE -> ">="
    | LE -> "<="
    | AND -> "&&"
    | OR -> "||"
end

let rec output_tree ~indent ~level ~last ~parents ppf (t : Tree.t) =
  for i = 1 to level - 1 do
    if List.mem (i - 1) parents then Format.pp_print_string ppf "│"
    else Format.pp_print_string ppf " ";
    Format.pp_print_string ppf (String.init indent (Fun.const ' '))
  done;

  if level > 0 then (
    if last then Format.pp_print_string ppf "└"
    else Format.pp_print_string ppf "├";
    Format.pp_print_string ppf "─ ");

  match t with
  | Terminal s -> Format.fprintf ppf "%s\n" s
  | Leaf (s, l) ->
      Format.fprintf ppf "%s\n" s;
      let l' = List.rev l in
      let parents' = level :: parents in
      List.iter
        (output_tree ~indent ~level:(level + 1) ~last:false ~parents:parents'
           ppf)
        (List.rev (List.tl l'));
      output_tree ~indent ~level:(level + 1) ~last:true ~parents ppf
        (List.hd l')

let pp_syntax_tree ?(indent = 2) ppf ast =
  let t = Tree.of_syntax ast in
  Format.fprintf ppf "%a"
    (output_tree ~indent ~level:0 ~last:true ~parents:[])
    t

let syntax_tree ?(indent = 2) ast =
  ignore (Format.flush_str_formatter ());
  pp_syntax_tree ~indent Format.str_formatter ast;
  Format.flush_str_formatter ()
