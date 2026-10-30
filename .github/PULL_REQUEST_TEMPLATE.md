## What this changes

<!-- One word, one fix, or one piece of docs. Link the issue if there is one: Fixes #123 -->

## Why it belongs in Common

<!-- For anything beyond a bug fix or docs: why a language this small needs it. -->

## Checklist

- [ ] `make && make test` prints "All tests passed"
- [ ] `make sanitize` passes (then `make` again, since it ends with `make clean`)
- [ ] A test covers the change, including any new error message
- [ ] New or changed words: `DICTIONARY` entry, `docs/dictionary.md`, VS Code grammar, `make agents`
- [ ] Visitor values still never reach SQL text, file names, off-site `go to`, or email recipients
- [ ] `CHANGELOG.md` has a line under `## Unreleased` if users will notice the change
- [ ] I wrote this contribution, or otherwise have the right to submit it under the Apache License 2.0, and it contains no secrets or proprietary code (see CONTRIBUTING.md)
