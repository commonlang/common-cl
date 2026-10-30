#!/bin/sh
# Prepare a release: make release VERSION=0.5.0
#
# Sets CL_VERSION in src/cl.c, turns the "Unreleased" section of CHANGELOG.md
# into "X.Y.Z (today)", updates the specs page if the demo site is here,
# regenerates the agent skill, and runs the tests and the sanitizer. If any
# step fails, every file is put back as it was. It never commits, tags or
# pushes: it prints the commands for you to run.
set -e
cd "$(dirname "$0")/.."

new="$1"
if ! printf '%s' "$new" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "usage: make release VERSION=MAJOR.MINOR.PATCH   (for example 0.5.0)" >&2; exit 2
fi
old=$(sed -n 's/^#define CL_VERSION "\(.*\)"$/\1/p' src/cl.c)
[ -n "$old" ] || { echo "could not find CL_VERSION in src/cl.c" >&2; exit 1; }

# The new version must come after the old one.
newer=$(awk -v a="$old" -v b="$new" 'BEGIN {
  split(a, x, "."); split(b, y, ".")
  for (i = 1; i <= 3; i++) { if (y[i] + 0 > x[i] + 0) { print 1; exit } if (y[i] + 0 < x[i] + 0) { print 0; exit } }
  print 0 }')
[ "$newer" = 1 ] || { echo "$new is not newer than the current version, $old" >&2; exit 1; }

# There must be something to release.
unreleased=$(awk '/^## Unreleased/ { on = 1; next } /^## / { on = 0 } on && NF' CHANGELOG.md)
if ! grep -q '^## Unreleased' CHANGELOG.md || [ -z "$unreleased" ]; then
  echo "CHANGELOG.md has nothing under '## Unreleased'. Add what changed first." >&2; exit 1
fi

files="src/cl.c CHANGELOG.md skills/common/SKILL.md"
[ -f examples/site/specs.html ] && files="$files examples/site/specs.html"
backup=$(mktemp -d)
for f in $files; do mkdir -p "$backup/$(dirname "$f")"; cp "$f" "$backup/$f"; done
restore() {
  echo "" >&2
  echo "Release $new stopped: a check failed (see above). Every file is back as it was." >&2
  for f in $files; do cp "$backup/$f" "$f"; done
  rm -rf "$backup"
  make >/dev/null 2>&1 || true
}
trap restore EXIT

today=$(date +%Y-%m-%d)
sed "s/^#define CL_VERSION \"$old\"$/#define CL_VERSION \"$new\"/" src/cl.c > "$backup/cl.c.new" && cp "$backup/cl.c.new" src/cl.c
# Keep an empty Unreleased section on top for the next changes.
awk -v v="$new" -v d="$today" '!done && /^## Unreleased/ { print; print ""; print "## " v " (" d ")"; done = 1; next } { print }' CHANGELOG.md > "$backup/CHANGELOG.new" && cp "$backup/CHANGELOG.new" CHANGELOG.md
if [ -f examples/site/specs.html ]; then
  sed -e "s|<code>$old</code> (<code>cl version</code>)|<code>$new</code> (<code>cl version</code>)|" \
      -e "s|true of version $old\.|true of version $new.|" examples/site/specs.html > "$backup/specs.new" && cp "$backup/specs.new" examples/site/specs.html
fi

echo "== building $new"
rm -f cl                     # a fresh build: the old binary may look newer than the edit
make
make agents
echo "== tests"
make test
echo "== sanitizer"
make sanitize
make

trap - EXIT
rm -rf "$backup"
echo ""
echo "Ready: Common $new. Check the diff, then:"
echo "  git commit -am \"Release $new\""
echo "  git tag v$new"
echo "  git push && git push --tags"
