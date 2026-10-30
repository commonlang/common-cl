# Working on Common (CL)

Common is a plain-English web language. This repository is its interpreter,
written in C. To **write Common pages**, read
[skills/common/SKILL.md](skills/common/SKILL.md): it lists every word with its
one accepted form, the traps from other languages, and the safety rules.
Do not guess the syntax.

Agents that maintain this repository on their own (triage, fixes, security
patches, releases) must also follow [MAINTAINING.md](MAINTAINING.md): changes
reach `main` only through pull requests that a person approves, agents run the
full checks themselves and post the results, and agents work only on issues a
person labelled `agent-ok`.

## Layout

- `src/cl.c` is the whole interpreter, dev server and CGI mode, in one C11 file.
  The vocabulary is the `DICTIONARY` table near the top; `SYNONYMS` maps words
  from other languages to the Common word to use instead.
- `docs/dictionary.md` is the reference for people. `docs/deploy.md` covers hosting.
- `tests/run.sh` is the test suite. `tests/features.html` and
  `tests/features.expected` pin the output of every feature and error.
- `editor/vscode/` is syntax highlighting. `tests/check_grammar.py` fails when
  a dictionary word is missing from it.
- `skills/common/` is the skill for AI agents. `SKILL.md` is generated: edit
  `skills/SKILL.head.md` or the dictionary, then run `make agents`.

## Build and test

```sh
make              # build ./cl (SQLite and Postgres are added when installed)
make test         # the test suite; must pass before any change is done
make sanitize     # the tests under AddressSanitizer and UBSan, then make clean (rebuild after)
make agents       # regenerate skills/common/SKILL.md after changing words
make bench        # a rough speed check: run before and after a change to the interpreter
make release VERSION=X.Y.Z  # prepare a release; see MAINTAINING.md. Never tags or pushes
```

## Rules for changes (from CONTRIBUTING.md)

- One form per word. Never add a second way to write something; add the other
  spelling to `SYNONYMS` so the error points to the real word.
- Every new word needs a `DICTIONARY` entry with a working example, a section
  in `docs/dictionary.md`, the VS Code grammar, a test, and `make agents`.
- Errors teach: say what went wrong and show the line written correctly.
- Visitor values (`query`, `form`, `path`, `remembered`, database text) are
  marked `untrusted`/`tainted` and must never reach SQL text, file names,
  `go to` off the site, or email recipients. Keep that true for new words.
- Only optional libraries, detected by the Makefile. Plain C11 otherwise.
- Write for readers new to programming: plain words, short sentences.
