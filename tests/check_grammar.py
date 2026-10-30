"""Every word in the interpreter's DICTIONARY table must be in the VS Code
grammar's keyword list.   Usage:  python3 -I tests/check_grammar.py"""
import json, re, sys

match = json.load(open("editor/vscode/syntaxes/cl.json"))["repository"]["keyword"]["match"]
keywords = set(match[match.index("(") + 1 : match.rindex(")")].split("|"))

src = open("src/cl.c").read()
table = src[src.index("static const Word DICTIONARY[]") : src.index("#define NWORDS")]
words = set(re.findall(r'\{\s*"([a-z]+)"', table))        # every entry, including the form-less ones

missing = sorted(w for w in words if w not in keywords)
if missing:
    print("missing in grammar:", ", ".join(missing)); sys.exit(1)
print(f"grammar covers all {len(words)} dictionary words")
