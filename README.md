# Epsilon

> A compiler for a small statically-typed functional programming language.

## Table of Contents

- [Epsilon](#epsilon)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Syntax](#syntax)
    - [Comments](#comments)
    - [Functions](#functions)
    - [Literals](#literals)
    - [Boolean Logic](#boolean-logic)
    - [Conditionals](#conditionals)
    - [Lists](#lists)
    - [Let Expressions](#let-expressions)
    - [Operators](#operators)
    - [Algebraic Types](#algebraic-types)
    - [Formal Syntax](#formal-syntax)
  - [Semantics](#semantics)
  - [Features](#features)
  - [License](#license)
  - [References](#references)

## Overview

Epsilon is a compiled, small, eager statically-typed functional programming language that I wrote to learn more about programming language theory and compilers. Epsilon doesn't ever really aim to be a production-ready language but more of a grounds for experiments with programming languages.

Epsilon targets an LLVM backend which does handles most of the complicated optimziation; however, certain optimizations are also done in the compiler front end / middle end as an educational exercise in implementing compiler optimization.

Epsilon inherits its syntax and semantics from the ML family of programming languages. In particular, Epsilon syntactically looks close to [Reason](https://reasonml.github.io/) and models the runtime behavior of [OCaml](https://ocaml.org/)/[Reason](https://reasonml.github.io/).


## Syntax
This is a syntax reference to most of the language functionalities for Epsilon. A formal grammar in Backus-Naur form is available at the [end of this section](#formal-syntax).

### Comments

```ocaml
(* This is a comment. *)
(* 
  This is an outer comment.
  (* We can nest comments in other comments. *)
*)
```

### Functions

```ocaml
(* Function, alongside all other variables in Epsilon, can optionally have annotations. *)
let square: int -> int = \x -> x * x

square 12 (* is 144 *)


(* In Epsilon, all functions can be recursive by default. *)
let factorial: int -> int = \x -> {
  match x {
    | 0 -> 1
    | _ -> x * factorial (x - 1)
  }
}

(* Curly braces are optional in certain contexts. *)
let factorial = \x ->
  match x
  | 0 -> 1
  | _ -> x * factorial (x - 1)

factorial 5 (* is 120 *)

(* Functions are also curried by default. *)
let add: int -> int -> int = \x y -> x + y

(* Partially applying the argument to the add function. *)
let add2 = add 2

add2 3 (* is 5 *)
```

### Literals

```ocaml
true  : bool
false : bool

22    : int
3.14  : float

"foo" : string

()    : unit  (* The unit type is a special type which represents no value. *)
```

### Boolean Logic

```ocaml
not true (* false *)
not false (* true *)
1 = 1 (* true *)
1 <> 1 (* false *)
1 < 10 (* true *)
```

### Conditionals

```ocaml
(* If expressions have to be type checked so every if expression must have an else clause OR if expressions must be of the unit type. *)

if n > 0 then
  "n is a positive number"
else if n = 0 then
  "n is zero"
else
  "n is a negative number"
```

### Lists

```ocaml
(* All three of the following expressions are equivalent *)
[3, 5, 7, 9]
3 :: [5, 7, 9]
3 :: 5 :: 7 :: 9 :: []

(* Summing elements in a list using tail recursion. *)
let sum_aux = \acc lst -> {
  match lst {
    | [] -> acc
    | h :: t -> sum_aux (acc + h) t
  }
}

let sum = \lst -> sum_aux 0 lst

sum [3, 5, 7, 9] (* is 24 *)

(* Summing elements in a list using higher-order functions. *)
let sum = List.fold_right (+) 0

sum [3, 5, 7, 9] (* is 24 *)
```

### Let Expressions

```ocaml
let hello_world = {
  let hello = "Hello" in
  let world = "world" in
  hello ++ ", " ++ world
}
```

### Operators

```ocaml
(* The forward pipeline operator is a nice way to chain together function calls. *)
let nice_names: string list -> string =
  \names -> {
    names
    |> List.sort
    |> String.concat ", "
  }

(* By the way, the forward pipeline operator is defined as such. *)
let (|>) : 'a -> ('a -> 'b) -> 'b =
  \x f -> f x

(* New infix operators can be defined using the (operator) syntax. *)
(* Here is the definition of a new exponentiation operator via repeated squaring. *)

(* [x ^ n] calculates [x] raised to the [n]th power. [n] must be greater than or equal to 0. *)
let (^): int -> int -> int = 
  \x n -> {
    match n, n % 2 {
      | 0, _ -> 1
      | _, 0 -> (x * x) ^ (n / 2)
      | _, _ -> x * ((x * x) ^ ((n - 1) / 2))
    }
  }
```

### Algebraic Types

```ocaml
(* Variant types or product types. *)
type int_tree =
  | Leaf
  | Internal of int_tree * int * int_tree

(* Record types or sum types. *)
type point = { 
  x: int,
  y: int
 }
```

> TODO: Imperative programming

### Formal Syntax

```
```

## Semantics

## Features

Here is a rough outline of all features planned for the compiler. 

Phase 1. Subset Compiler
- [ ] Lexical Analysis
- [ ] Syntax Analysis
- [ ] Type checking
- [ ] Intermediate Trees
- [ ] Instruction Selection
- [ ] Liveness Analysis
- [ ] Register Allocation
- [ ] Runtime Library
- [ ] Dataflow Analysis

Phase 2. Language Features
- [ ] Error diagnostics
- [ ] Algebraic types
- [ ] Type polymorphism
- [ ] Toplevel system
- [ ] First-class functions
- [ ] Hindley-Milner type inference
- [ ] Pattern Matching
- [ ] Concurrency (Fibers or Actors?)
- [ ] Hygenic Macros
- [ ] Modules

## License

Epsilon is distributed under the terms of the [GNU GPLv3 License](./LICENSE.md).

## References

* [Modern Compiler Implementation in ML](https://www.cs.princeton.edu/~appel/modern/ml/) by Andrew M. Appel
* [Real World OCaml, 2nd ed.](https://dev.realworldocaml) by Yaron Minsky and Anil Madhavapeddy
* [OCaml Programming: Correct + Efficient + Beautiful](https://cs3110.github.io/textbook/cover.html) by Michael R. Clarkson
* [Programming Language Zoo](http://plzoo.andrej.com/) by Andrej Bauer and Matija Pretnar
* [ReasonML Programming Language](https://reasonml.github.io/) by ReasonML Team