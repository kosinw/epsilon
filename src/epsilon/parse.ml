module I = Parser.MenhirInterpreter
module P = Parser
module L = Lexer

(** The concept of this submodule is to provide a persistent data structure
   as an abstraction over the lexer. The idea is that lexers can be
   generated from ocamllex and simply cache all the tokens produced
   during its execution. Then checkpoints can be easily kept as
   valid points of time in the lexer's execution. This allows for backtracking
   and is particularly useful during parser error recovery.

   See: https://github.com/yurug/menhir-error-recovery
*)
module Lexer : sig
  open Parser

  type checkpoint
  (** Abstract type checkpoint represents an intermediate state of a lexer. This checkpoint
             represents a state where some or all of the characters from the initial lexer buffer
             have been read and converted into lexical tokens.  *)

  type ptoken = token * Lexing.position * Lexing.position
  (** A parser token associated with a start and end lexer position. *)

  val init : Lexing.lexbuf -> checkpoint
  (** [init lexbuf] initializes a new lexer given a lexer buffer. *)

  val get : checkpoint -> ptoken
  (** [get checkpoint] gets the token emitted at [checkpoint]
             and its position emitted by the lexer at this checkpoint. *)

  val loc : checkpoint -> Location.location
  (** [loc checkpoint] gets the current location of the token emitted at [checkpoint]. *)

  val get' : checkpoint -> token
  (** [get' checkpoint] works the same way as [get] but instead returns
             a parser token without location information.  *)

  val next : checkpoint -> checkpoint
  (** [next checkpoint] returns the next checkpoint from the lexer. *)

  val token : checkpoint -> checkpoint * ptoken
  (** [token checkpoint] returns the next checkpoint and its assosciated token from the lexer. *)

  val skip_until : (token -> bool) -> checkpoint -> checkpoint
  (** [skip_until predicate checkpoint] returns the checkpoint right before the checkpoint
             where [predicate (get' checkpoint)] is true. If [EOF] is reached before predicate
             is true, then the checkpoint right before [EOF] is returned instead.  *)
end = struct
  open Parser

  type ptoken = token * Lexing.position * Lexing.position

  type checkpoint = {
    check_supplier : I.supplier;
    check_buffer_size : int ref;
    check_buffer : ptoken list ref;
    check_token_index : int;
  }

  (* Forward function composition operator from F#. *)
  let ( >> ) f g x = g (f x)
  let token_of_ptoken (token, _, _) = token

  let location_of_ptoken (_, start, finish) =
    Location.make_location start finish

  let init lexbuf =
    let supplier = I.lexer_lexbuf_to_supplier L.token lexbuf in
    {
      check_supplier = supplier;
      check_buffer_size = ref 0;
      check_buffer = ref [];
      check_token_index = -1;
    }

  let maybe_grow
      {
        check_supplier = supplier;
        check_buffer = buffer;
        check_buffer_size = size;
        check_token_index = n;
      } =
    while n >= !size do
      let tok = supplier () in
      buffer := tok :: !buffer;
      incr size
    done

  let get
      ({
         check_buffer = buffer;
         check_buffer_size = size;
         check_token_index = n;
         _;
       } as checkpoint) =
    maybe_grow checkpoint;
    match n with
    | -1 -> failwith "checkpoint is out of range"
    | _ -> List.nth !buffer (!size - n - 1)

  let loc = get >> location_of_ptoken
  let get' = get >> token_of_ptoken
  let peek buffer = List.hd !buffer |> token_of_ptoken

  let next_checkpoint checkpoint =
    { checkpoint with check_token_index = checkpoint.check_token_index + 1 }

  let next checkpoint =
    let checkpoint = next_checkpoint checkpoint in
    maybe_grow checkpoint;
    checkpoint

  let token checkpoint =
    let checkpoint' = next checkpoint in
    (checkpoint', get checkpoint')

  let skip_until pred checkpoint =
    let rec aux checkpoint =
      let checkpoint', (t, _, _) = token checkpoint in
      if t = EOF then checkpoint
      else if pred t then checkpoint
      else aux checkpoint'
    in
    aux checkpoint
end

(* ---------------------------------- *)

type last_reduction = [
  | `FoundDefinitionAt of Syntax.t I.checkpoint
  | `FoundBraceAt of Syntax.t I.checkpoint
  | `FoundNothingAt of Syntax.t I.checkpoint
]

let parse (lexbuf : Lexing.lexbuf) =
  (* [run] is the main looping mechanism for the incremental parser. *)
  let rec run checkpoint lexer =
    match checkpoint with
    | I.InputNeeded _ ->
        let lexer, token = Lexer.token lexer in
        run (I.offer checkpoint token) lexer
    | I.Shifting _ | I.AboutToReduce _ ->
        (* Do nothing special here just continue parsing. *)
        (* TODO(kosinw): Make I.AboutToReduce keep track of the last production that was reduced. *)
        run (I.resume checkpoint) lexer
    | I.Rejected | I.HandlingError _ ->
        (* TODO(kosinw): Definitely replace this with fancy error reporting *)
        failwith "syntax error occurred"
    | I.Accepted v -> v
  in
  let checkpoint = P.Incremental.main lexbuf.lex_curr_p in
  let lexer = Lexer.init lexbuf in
  run checkpoint lexer

let parse_string s =
  let module U = MenhirLib.LexerUtil in
  let lexbuf = Lexing.from_string s |> U.init "" in
  parse lexbuf
