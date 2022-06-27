<p align="center">
 <a href="https://kosinw.com" target="_blank" rel="noopener">
  <img src="media/banner.png" />
 </a>
</p>

> A compiler for a statically-typed and functional programming language.

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
- [Semantics](#semantics)
- [Features](#features)
- [License](#license)
- [References](#references)

# Overview

Epsilon is a compiled, small, eager statically-typed functional programming language that I wrote to learn more about programming language theory and compilers. Epsilon doesn't ever really aim to be a production-ready language but more of a grounds for experiments with programming languages.

Epsilon targets an LLVM backend which does handles most of the complicated optimziation; however, certain optimizations are also done in the compiler front end / middle end as an educational exercise in implementing compiler optimization.

Epsilon inherits its syntax and semantics from the ML family of programming languages. In particular, Epsilon syntactically looks close to [Reason](https://reasonml.github.io/) and models the runtime behavior of [OCaml](https://ocaml.org/)/[Reason](https://reasonml.github.io/).


# Syntax
This is a syntax reference to most of the language functionalities for Epsilon. If you want to see a formal grammar for Epsilon, the closest is the Menhir parser file at [src/parser.mly](src/parser.mly).

## Comments

```re
// This is a comment.
```

## Functions

```re
// A function definition.
let square: int -> int = fun x -> x * x

square 12 // is 144

// Due to Epsilon's type inference system, type annotations can be omitted in most contexts.
let square = fun x -> x * x

// In Epsilon, all functions can be recursive by default.
let factorial: int -> int = fun x -> {
  match x {
    | 0 -> 1
    | _ -> x * factorial (x - 1)
  }
}

// A no argument function, useful for side effects.
let foo: unit -> unit = fun () {
  printfn "Hello, new world!"
}

factorial 5 // is 120

// Functions are also curried by default.
let add: int -> int -> int = fun x y -> x + y

// Partially applying the argument to the add function.
let add2 = add 2

add2 3 // is 5
```

## Literals

```re
true  : bool
false : bool

22    : int
3.14  : float

"foo" : string

()    : unit  // The unit type is a special type which represents no value.
```

## Boolean Logic

```re
not true // false
not false // true
1 = 1 // true
1 != 1 // false
1 < 10 // true
```

## Conditionals

```re
// If expressions have to follow the same semantics as they do in OCaml

if n > 0 then
  "n is a positive number"
else if n = 0 then
  "n is zero"
else
  "n is a negative number"
```

## Lists

```re
// All three of the following expressions are equivalent
[3, 5, 7, 9]
3 :: [5, 7, 9]
3 :: 5 :: 7 :: 9 :: []

// Summing elements in a list using tail recursion.
let sum_aux = fun acc lst -> {
  match lst {
    | [] -> acc
    | h :: t -> sum_aux (acc + h) t
  }
}

let sum = \lst -> sum_aux 0 lst

sum [3, 5, 7, 9] // is 24

// Summing elements in a list using higher-order functions.
let sum = List.fold_right (+) 0

sum [3, 5, 7, 9] (* is 24 *)
```

## Let Expressions

```re
let hello_world = {
  let hello = "Hello" in
  let world = "world" in
  hello ++ ", " ++ world
}
```

## Operators

```re
// The forward pipeline operator is a nice way to chain together function calls.
let nice_names: string list -> string = fun names -> {
  names
  |> List.sort
  |> String.concat ", "
}

// By the way, the forward pipeline operator is defined as such.
let (|>) : 'a -> ('a -> 'b) -> 'b = fun x f -> f x

// New infix operators can be defined using the (operator) syntax.
// Here is the definition of a new exponentiation operator via repeated squaring.

// [x ^ n] calculates [x] raised to the [n]th power. [n] must be greater than or equal to 0.
let (^): int -> int -> int = fun x n -> {
  match n, n % 2 {
    | 0, _ -> 1
    | _, 0 -> (x * x) ^ (n / 2)
    | _, _ -> x * ((x * x) ^ ((n - 1) / 2))
  }
}
```

## Algebraic Types

```re
// Variant types or product types.
type int_tree =
  | Leaf
  | Internal of int_tree * int * int_tree

// Record types or sum types.
type point = { 
  x: int,
  y: int
 }
```

# Semantics

# Features

Here is a rough outline of all features planned for the compiler. 

Phase 1. Subset Compiler
- [x] Lexical Analysis
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

# License

Epsilon is distributed under the terms of the [GNU GPLv3 License](./LICENSE.md).

# References

* [Modern Compiler Implementation in ML](https://www.cs.princeton.edu/~appel/modern/ml/) by Andrew M. Appel
* [Real World OCaml, 2nd ed.](https://dev.realworldocaml) by Yaron Minsky and Anil Madhavapeddy
* [OCaml Programming: Correct + Efficient + Beautiful](https://cs3110.github.io/textbook/cover.html) by Michael R. Clarkson
* [Programming Language Zoo](http://plzoo.andrej.com/) by Andrej Bauer and Matija Pretnar
* [The ReasonML Manual](https://reasonml.github.io/) by ReasonML Team
* [The OCaml System Manual](https://v2.ocaml.org/manual/index.html) by Xavier Leroy and OCaml team