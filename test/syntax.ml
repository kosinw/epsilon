let test_example () =
  Alcotest.(check string) "same string" "foo" "foo"

let () =
  let open Alcotest in
  run "syntax" [
    "example", [ test_case "Foo" `Quick test_example ]
  ]