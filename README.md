<p align="center">
 <a href="https://kosinw.com" target="_blank" rel="noopener">
  <img src="media/banner.png" />
 </a>
</p>

Epsilon is a compiled, small, strict, and statically-typed functional language similar to the [ML programming language](https://en.wikipedia.org/wiki/ML_(programming_language)). I am currently working on this compiler to learn more about functional programming, programming language theory and compilers. 

Epsilon doesn't ever really aim to be a production-ready language but more of a grounds for experiments with programming languages. Nonetheless, the goal is to compile useful programs written in Epsilon such as a [raytracer](https://raytracing.github.io/) or a [text editor](https://viewsourcecode.org/snaptoken/kilo/) into machine-executable binaries.

Epsilon targets an LLVM backend which does handles most of the complicated optimziation; however, certain optimizations are also done in the compiler front end / middle end as an educational exercise in implementing compiler optimization.

Epsilon inherits its syntax and semantics from the ML family of programming languages. In particular, Epsilon syntactically looks close to and behaves like the [Reason](https://reasonml.github.io/) programming language.

# Table of Contents

1. [Table of Contents](#table-of-contents)
2. [Overview](#overview)
   1. [Comments](#comments)
   2. [Let Bindings](#let-bindings)
   3. [Primitive Types](#primitive-types)
   4. [Arithmetic](#arithmetic)
   5. [Logical](#logical)
   6. [Conditional](#conditional)
   7. [Functions](#functions)
   8. [Data Structures](#data-structures)
   9. [Records](#records)
3. [Examples](#examples)
4. [Features](#features)
5. [License](#license)
6. [References](#references)

# Overview

This is an overview of all important language and syntactical features in Epsilon. Generally speaking, most of the syntax will look very similar to [Reason](https://reasonml.github.io/docs/en/overview); however, the syntax for certain constructs such as function application and definition look closer to [OCaml](https://v2.ocaml.org/manual/).

## Comments

Epsilon features C-style comments that have proper nesting levels for multi line comments.

| Feature             | Example                   |
| :------------------ | :------------------------ |
| Single line comment | `// this is a comment`    |
| Multi line comment  | `/* this is a comment */` |

## Let Bindings

Let bindings work closer to the same way let definitions work in OCaml rather than let expressions. All let expresions are immutable and cannot be reassigned (however they can be shadowed).

| Feature              | Example                      |
| :------------------- | :--------------------------- |
| Int value            | `let random_number = 42;`    |
| With type annotation | `let fizz: string = "Fizz";` |
| Function value       | `let succ = fun x -> x + 1;` |

## Primitive Types

Epsilon features a few primitive data types including numbers, strings, booleans, and arrays. Epsilon also has a [special unit type](https://en.wikipedia.org/wiki/Unit_type) which is important for imperative programming. Functions are also first-class values in Epsilon.

| Feature  | Example                                           |
| :------- | :------------------------------------------------ |
| Int      | `let x: int = 12; // alternatively 0x0C or 0o14.` |
| Float    | `let y: float = 2.45;`                            |
| Boolean  | `let z: bool = true;`                             |
| String   | `let a: string = "hello, world!";`                |
| Unit     | `let u: unit = ();`                               |
| Array    | `let l: array(int) = [\|1, 2, 3, 4, 5\|];`        |
| Function | `let f: int -> int = fun x -> 2 * x;`             |

## Arithmetic

Epsilon distinguishes between two types of numbers: real numbers (represented by IEEE 754 floating point values) and integral numbers. 

Epsilon also supports integer literals in both hexadecimal and octal numbers systems alongside the default decimal numbering system.

Negative numbers and negation is grammatically encoded as a unary operator rather than there existing negative numeric literals (however, optimizing stages of the compiler will automatically convert these).

| Feature           | Example                                      |
| :---------------- | :------------------------------------------- |
| Integer           | `23`, `1_000_000`, `0xdeadbeef`, `0o657`     |
| Integer operators | `-23`, `2 * 4 + 15 / 3 - 8`, `15 % 3`        |
| Floats            | `3.14`                                       |
| Float operators   | `-.23.0`, `2.0 *. 4.0 +. 15.0 /. 3.0 -. 8.0` |

## Logical

The boolean and logical facilities in Epsilon work similar to most other programming languages.

| Feature           | Example              |
| :---------------- | :------------------- |
| Primitives        | `true`, `false`      |
| Comparison        | `>`, `<`, `>=`, `<=` |
| Boolean operators | `\|\|`, `&&`, `not`  |
| Equality          | `=`, `!=`            |

## Conditional

If constructs are expressions in Epsilon. Every if expression require matching types for both the then-clause and else-clause. Else-clauses can only be emitted if the type of the if-expression is `unit`.

| Feature            | Example                                      |
| :----------------- | :------------------------------------------- |
| If expression      | `if (condition) { printfn "hello, world"; }` |
| If-else expression | `if (condition) { a; } else { b; }`          |

## Functions

Functions are first-class values in Epsilon as they usually are in other ML languages. Functions are also automatically curried and fixed-point (recursive).

| Feature               | Example                                                     |
| :-------------------- | :---------------------------------------------------------- |
| Function definition   | `let add = fun a b -> a + b;`                               |
| Function application  | `add 2 3; // 5`                                             |
| Recursive functions   | `let fact = fun n -> if (n = 0) 0 else (n * fact (n - 1));` |
| Partial application   | `let add2 = add 2; add2 3; // 5`                            |
| Forward pipe operator | ` 32 \|> (add 2) \|> (add 3);`                              |
| Inline typing         | `let add = fun (a: int) (b: int) -> a + b;`                 |
| Explicit typing       | `let add: int -> int -> int = fun a b -> a + b;`            |

## Data Structures

Epsilon supports two data structures out of the box: arrays and tuples.

| Feature        | Example                          |
| :------------- | :------------------------------- |
| Arrays         | `[\| 3, 4, 5 \|]`                |
| Array length   | `let n = Array.length array;`    |
| Array indexing | `arr[0];`                        |
| Array mutation | `arr[i] = 12;`                   |
| Array creation | `let arr = Array.make length 0;` |
| Tuples         | `("hello", "world")`             |

## Records

Records are product types which are useful for storing data in named fields. Records use nominal typing (as opposed to structural typing).

| Feature                | Example                           |
| :--------------------- | :-------------------------------- |
| Record definition      | `type t = { a: int, b: bool };`   |
| Record creation        | `let x = { a: 3, b: false };`     |
| Record access          | `x.a;`                            |
| Mutable record fields  | `type v = { mutable c: string };` |
| Mutable record updates | `y.c = "bravo";`                  |

---

> TODO(kosi): Add sections on pattern matching, variants, modules, and imperative programming

# Examples

Examples programs written in Epsilon can be found under the `examples/` directory in this repository.

# Features

Here is a rough outline of all features planned for the compiler and programming language.

Phase 1. Compiler Stages
- [x] Lexical Analysis
- [x] Syntax Analysis
- [ ] Type Checking
- [ ] Type Inference
- [ ] IR (K-normalization, $\alpha$ -conversion, $\beta$ -reduction)
- [ ] Optimization I (Inline expansion, constant folding, etc.)
- [ ] Closure conversion
- [ ] Instruction Selection
- [ ] Register Allocation + Spilling
- [ ] Runtime + Garbage Collection

Phase 2. Language Design
- [ ] Error diagnostics
- [ ] Algebraic Data Types
- [ ] Pattern Matching
- [ ] Toplevel system
- [ ] Function Polymorphization
- [ ] Macros
- [ ] Modules

# License

Epsilon is distributed under the terms of the [GNU GPLv3 License](./LICENSE.md).

# References

* [Modern Compiler Implementation in ML](https://www.cs.princeton.edu/~appel/modern/ml/) - Andrew M. Appel
* [Real World OCaml, 2nd ed.](https://dev.realworldocaml) - Yaron Minsky and Anil Madhavapeddy
* [OCaml Programming: Correct + Efficient + Beautiful](https://cs3110.github.io/textbook/cover.html) - Michael R. Clarkson
* [MinCaml: A Simple and Efficient Compiler for a Minimal Functional Language](https://esumii.github.io/min-caml/paper.pdf) - Eijiro Sumii
* [The ReasonML Manual](https://reasonml.github.io/)
* [The OCaml System Manual](https://v2.ocaml.org/manual/index.html)