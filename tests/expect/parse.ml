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

open Epsilon

let print_syntax x = Main.parse_string x |> Pprint.syntax_tree |> print_endline

let%expect_test "constant decimal expression tree" =
  print_syntax "1";
  [%expect {|
    Program
    └─ ConstExpr: 1 |}]

let%expect_test "constant hexadecimal expression tree" =
  print_syntax "0x41";
  [%expect {|
    Program
    └─ ConstExpr: 65 |}]

let%expect_test "constant boolean expression tree" =
  print_syntax "true";
  [%expect {|
    Program
    └─ ConstExpr: true |}]

let%expect_test "constant string expression tree" =
  print_syntax {| "hello, world!" |};
  [%expect {|
    Program
    └─ ConstExpr: "hello, world!" |}]

let%expect_test "simple variable expression tree" =
  print_syntax {| chopper |};
  [%expect
    {|
    Program
    └─ VarExpr: chopper |}]
  
let%expect_test "binary operators expression tree" =
  print_syntax {| 4 + 5 * 6 - 7 |};
  [%expect{|
    Program
    └─ InfixExpr: -
       ├─ InfixExpr: +
       │  ├─ ConstExpr: 4
       │  └─ InfixExpr: *
       │     ├─ ConstExpr: 5
       │     └─ ConstExpr: 6
       └─ ConstExpr: 7 |}]