LIBRARY_DIR := src/epsilon
MENHIR := esy dune exec menhir -- --unused-tokens
PARSER_MESSAGES := $(LIBRARY_DIR)/parserMessages.messages

# [make build] is used to build all libraries and executables.

.PHONY: build
build: complete
	@ esy install && esy build

# [make watch] is used to automatically rebuild libraries and executables
# when they are changed on the filesystem. [make watch] also automatically
# runs all unit and expectation tests under the tests/ directory.

.PHONY: watch
watch:
	@ esy dune build -w @check @runtest

# NOTE(kosinw): Taken from https://gitlab.inria.fr/fpottier/menhir/

# [make update] is used under the programmer's manual control, after the
# grammar in [parser.mly] has been modified.

# It updates the file [parserMessages.messages] with new auto-generated
# comments for all error states.

.PHONY: update
update: $(PARSER_MESSAGES)
	@ cp -f $(LIBRARY_DIR)/parserMessages.messages /tmp/parserMessages.messages.bak
	@ $(MENHIR) $(LIBRARY_DIR)/parser.mly \
		--update-errors $(LIBRARY_DIR)/parserMessages.messages \
		> /tmp/parserMessages.updated
	@ mv /tmp/parserMessages.updated $(LIBRARY_DIR)/parserMessages.messages

# [make strip] strips away the auto-generated comments found in the file
# parserMessages.messages. It is typically used after [make update], which
# creates many such comments.

.PHONY: strip
strip:
	@ sed -e "/^##/d" -i.bak $(LIBRARY_DIR)/parserMessages.messages

# [make complete] is used when the completeness check fails, that is, when
# there exist error states that are not reached by any of the sentences in the
# file parserMessages.messages. [make complete] adds the missing sentences
# (with dummy error messages) to this file, so that the completeness check
# succeeds. It is then up to the programmer to study these sentences and
# replace the dummy messages with suitable messages.

.PHONY: complete
complete: $(PARSER_MESSAGES)
	@ $(MENHIR) $(LIBRARY_DIR)/parser.mly \
	    --list-errors \
	    > /tmp/parserMessages.auto.messages
	@ $(MENHIR) $(LIBRARY_DIR)/parser.mly \
	    --merge-errors /tmp/parserMessages.auto.messages \
	    --merge-errors $(LIBRARY_DIR)/parserMessages.messages \
	    > /tmp/parserMessages.merged
	@ mv /tmp/parserMessages.merged $(LIBRARY_DIR)/parserMessages.messages

$(PARSER_MESSAGES):
	@ touch $(PARSER_MESSAGES)

# [make promote] is typically used with expect tests and is used to update the results
# of the tests. Read more about dune promotion on the official dune website.
# https://dune.readthedocs.io/en/stable/dune-files.html#promote

.PHONY: promote
promote:
	@ esy dune promote

# [make fmt] runs ocamlformat, the official formatter for OCaml code, on all source files.

.PHONY: fmt
fmt:
	@ esy dune build @fmt --auto-promote

# [make utop] launches utop, the standard toplevel (REPL) for OCaml but with all libraries
# automatically included (for exploratory programming).

.PHONY: utop
utop:
	@ esy dune utop

# [make clean] cleans all files from dune's $build directory.

.PHONY: clean
clean:
	@ esy dune clean