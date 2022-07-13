module I = Parser.MenhirInterpreter
module P = Parser
module U = MenhirLib.LexerUtil
module E = MenhirLib.ErrorReports

(** The concept of this submodule is to provide a persistent data structure
   as an abstraction over the lexer. The idea is that lexers can be
   generated from ocamllex and simply cache all the tokens produced
   during its execution. Then checkpoints can be easily kept as
   valid points of time in the lexer's execution. This allows for backtracking
   and is particularly useful during parser error recovery.

   Reference: https://github.com/yurug/menhir-error-recovery
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

  val loc : checkpoint -> Lexing.position * Lexing.position
  (** [loc checkpoint] gets the current location of the token emitted at [checkpoint]. *)

  val get' : checkpoint -> token
  (** [get' checkpoint] works the same way as [get] but instead returns
             a parser token without location information.  *)

  val next : checkpoint -> checkpoint
  (** [next checkpoint] returns the next checkpoint from the lexer. *)

  val token : checkpoint -> checkpoint * ptoken
  (** [token checkpoint] returns the next checkpoint and its assosciated token from the lexer. *)

  val skip_until : (token -> bool) -> checkpoint -> checkpoint
  (** [skip_until predicate checkpoint] returns the first checkpoint before [predicate (get' checkpoint)]
      is true. If [EOF] is reached before predicate is true, then the checkpoint right before 
      [EOF] is returned instead.  *)
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
  let location_of_ptoken (_, start, finish) = (start, finish)

  let init lexbuf =
    let supplier = I.lexer_lexbuf_to_supplier Lexer.token lexbuf in
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
      if t = EOF || pred t then checkpoint' else aux checkpoint'
    in
    aux checkpoint
end

(* ---------------------------------- *)

let resume_from_error last_reduction_p lexer =
  match last_reduction_p with
  | `FoundNothing checkpoint | `FoundSeqItem checkpoint ->
      let lexer = Lexer.skip_until (fun t -> t = SEMI) lexer in
      (lexer, checkpoint)

let update_last_reduction last_input_p last_reduction_p production =
  let open I in
  match lhs production with
  | X (N N_seq_expr_item) -> `FoundSeqItem last_input_p
  | _ -> last_reduction_p

let parse (lexbuf : Lexing.lexbuf) =
  (* [on_error] is responsible for both reporting errors to the
     diagnostic report as well as returning a lexer and parser checkpoint
     from which error recovery will occur. *)
  let on_error last_reduction_p lexer =
    Printf.eprintf "%sError: Syntax error\n" (U.range (Lexer.loc lexer));
    resume_from_error last_reduction_p lexer
  in

  (* [run] is the main looping mechanism for the incremental parser.

     We maintain [last_reduction_p] as the last checkpoint in the parser
     to back track to if we encounter an error midway through reducing
     another production.

     We maintain [last_input_p] as the last checkpoint in the parser
     which a token was requested (this is the checkpoint which must be
     used during error recovery).

     [lexer] and [checkpoint] are persistent data structures which
     represent the state of the lexer and parser respectively.
  *)
  let rec run last_reduction_p last_input_p checkpoint lexer =
    match checkpoint with
    | I.InputNeeded _ ->
        let lexer, token = Lexer.token lexer in
        (* [last_input] is updated here. *)
        run last_reduction_p checkpoint (I.offer checkpoint token) lexer
    | I.Shifting _ ->
        (* Do nothing special here just continue parsing. *)
        run last_reduction_p last_input_p (I.resume checkpoint) lexer
    | I.AboutToReduce (_, production) ->
        (* Update last reduction since we are about to reduce a nonterminal symbol. *)
        run
          (update_last_reduction last_input_p last_reduction_p production)
          last_input_p (I.resume checkpoint) lexer
    | I.Rejected -> failwith "rejected"
    | I.HandlingError _ ->
        let lexer, checkpoint = on_error last_reduction_p lexer in
        run last_reduction_p last_input_p checkpoint lexer
    | I.Accepted v -> v
  in
  let checkpoint = P.Incremental.main lexbuf.lex_curr_p in
  let lexer = Lexer.init lexbuf in
  run (`FoundNothing checkpoint) checkpoint checkpoint lexer

let parse_string s =
  let lexbuf = U.init "<no file>" (Lexing.from_string s) in
  parse lexbuf
