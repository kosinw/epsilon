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

include Common

let%expect_test "covers constant decimal expression tree" =
  print_syntax "1";
  [%expect {|
    Program
    └─ ConstExpr: 1 |}]

let%expect_test "covers constant hexadecimal expression tree" =
  print_syntax "0x41";
  [%expect {|
    Program
    └─ ConstExpr: 65 |}]

let%expect_test "covers constant boolean expression tree" =
  print_syntax "true";
  [%expect {|
    Program
    └─ ConstExpr: true |}]

let%expect_test "covers constant string expression tree" =
  print_syntax {| "hello, world!" |};
  [%expect {|
    Program
    └─ ConstExpr: "hello, world!" |}]

let%expect_test "covers simple variable expression tree" =
  print_syntax {| chopper |};
  [%expect {|
    Program
    └─ VarExpr: chopper |}]

let%expect_test "covers binary operators expression tree" =
  print_syntax {| 4 + 5 * 6 - 7 |};
  [%expect
    {|
    Program
    └─ InfixExpr: -
       ├─ InfixExpr: +
       │  ├─ ConstExpr: 4
       │  └─ InfixExpr: *
       │     ├─ ConstExpr: 5
       │     └─ ConstExpr: 6
       └─ ConstExpr: 7 |}]

let%expect_test "covers complex patterns expression tree" =
  print_syntax
    {|
    fun _ -> ();
    fun x -> ();
    fun () -> ();
    fun (y: int) -> ()
  |};
  [%expect
    {|
    Program
    └─ SequenceExpr
       ├─ FunExpr
       │  ├─ AnyPattern
       │  └─ ConstExpr: ()
       └─ SequenceExpr
          ├─ FunExpr
          │  ├─ VarPattern: x
          │  └─ ConstExpr: ()
          └─ SequenceExpr
             ├─ FunExpr
             │  ├─ ConstPattern: ()
             │  └─ ConstExpr: ()
             └─ FunExpr
                ├─ ConstraintPattern
                │  ├─ VarPattern: y
                │  └─ ConstructorType: int
                └─ ConstExpr: () |}]

let%expect_test "covers let expression tree" =
  print_syntax {|
    let x = 13 and y = x + 25
  |};
  [%expect
    {|
    Program
    └─ LetExpr
       ├─ LetDefinition
       │  ├─ VarPattern: x
       │  └─ ConstExpr: 13
       └─ LetDefinition
          ├─ VarPattern: y
          └─ InfixExpr: +
             ├─ VarExpr: x
             └─ ConstExpr: 25 |}]

let%expect_test "covers conditional expression tree" =
  print_syntax
    {|
    if (true) (print_endline "Hello, new world!") else (print_endline "Impossible")
  |};
  [%expect
    {|
    Program
    └─ ConditionalExpr
       ├─ ConstExpr: true
       ├─ ApplicationExpr
       │  ├─ VarExpr: print_endline
       │  └─ ConstExpr: "Hello, new world!"
       └─ ApplicationExpr
          ├─ VarExpr: print_endline
          └─ ConstExpr: "Impossible" |}]

let%expect_test "covers operator prcedence testing in expression tree" =
  print_syntax
    {|
    (if (x = 3) {
      fun x y -> unbound 3 * y + x - 15 // (((unbound 3) * y) + x) - 15
    } else (fun x y -> unbound (-y)) : int -> int -> unbound(int));

    -22
  |};
  [%expect
    {|
    Program
    └─ SequenceExpr
       ├─ ConstraintExpr
       │  ├─ ConditionalExpr
       │  │  ├─ InfixExpr: =
       │  │  │  ├─ VarExpr: x
       │  │  │  └─ ConstExpr: 3
       │  │  ├─ FunExpr
       │  │  │  ├─ VarPattern: x
       │  │  │  └─ FunExpr
       │  │  │     ├─ VarPattern: y
       │  │  │     └─ InfixExpr: -
       │  │  │        ├─ InfixExpr: +
       │  │  │        │  ├─ InfixExpr: *
       │  │  │        │  │  ├─ ApplicationExpr
       │  │  │        │  │  │  ├─ VarExpr: unbound
       │  │  │        │  │  │  └─ ConstExpr: 3
       │  │  │        │  │  └─ VarExpr: y
       │  │  │        │  └─ VarExpr: x
       │  │  │        └─ ConstExpr: 15
       │  │  └─ FunExpr
       │  │     ├─ VarPattern: x
       │  │     └─ FunExpr
       │  │        ├─ VarPattern: y
       │  │        └─ ApplicationExpr
       │  │           ├─ VarExpr: unbound
       │  │           └─ PrefixExpr: -
       │  │              └─ VarExpr: y
       │  └─ ArrowType
       │     ├─ ConstructorType: int
       │     └─ ArrowType
       │        ├─ ConstructorType: int
       │        └─ ConstructorType: unbound
       │           └─ ConstructorType: int
       └─ PrefixExpr: -
          └─ ConstExpr: 22 |}]
