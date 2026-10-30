# Common (CL) for VS Code

Colors Common code inside `<cl>` and `<cl-code>` blocks in `.html` files.
Common pages are plain HTML, so there is no separate file type: `.cl` already
belongs to Common Lisp and OpenCL, and Common does not claim it. Words of the language, text, the `[holes]` inside
text, numbers and comments each get their own color from your theme.

## Install

There is no marketplace listing yet. Copy this folder into your extensions
directory and reload the window:

```sh
# macOS / Linux
cp -r editor/vscode ~/.vscode/extensions/common-cl-0.4.0

# Windows (PowerShell)
Copy-Item -Recurse editor\vscode $env:USERPROFILE\.vscode\extensions\common-cl-0.4.0
```

Then in VS Code: Command Palette, "Developer: Reload Window".

## What it does

- Injects into HTML, so an ordinary `.html` file lights up inside `<cl>` tags.

The word list in `syntaxes/cl.json` is the same list as `cl words`. When a word
is added to the language, add it there too.
