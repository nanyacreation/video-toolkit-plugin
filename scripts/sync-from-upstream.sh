#!/usr/bin/env bash
# Regenerate plugins/video-toolkit from an upstream claude-code-video-toolkit release.
#
#   scripts/sync-from-upstream.sh v0.29.1
#
# Copies .claude/skills and .claude/commands from that tag, prepends the workspace
# preamble to every upstream command, and stamps the version into plugin.json,
# marketplace.json and the install command. Files under scripts/static/ are
# plugin-owned (install command, hooks) and copied as-is.
set -euo pipefail

TAG="${1:?usage: $0 <upstream tag, e.g. v0.29.1>}"
VERSION="${TAG#v}"
UPSTREAM="https://github.com/digitalsamba/claude-code-video-toolkit.git"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN="$ROOT/plugins/video-toolkit"
STATIC="$ROOT/scripts/static"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
git clone -q --depth 1 --branch "$TAG" "$UPSTREAM" "$WORK/src"
SRC="$WORK/src"

rm -rf "$PLUGIN/skills" "$PLUGIN/commands" "$PLUGIN/hooks"
mkdir -p "$PLUGIN/skills" "$PLUGIN/commands" "$PLUGIN/hooks" "$PLUGIN/.claude-plugin"

# Skills: copied verbatim. Their relative paths (tools/, templates/, .claude/skills/...)
# resolve against the workspace, which the SessionStart hook names for Claude.
cp -R "$SRC/.claude/skills/." "$PLUGIN/skills/"

PREAMBLE="$STATIC/command-preamble.md"
for f in "$SRC/.claude/commands/"*.md; do
  out="$PLUGIN/commands/$(basename "$f")"
  if head -1 "$f" | grep -q '^---$'; then
    # Keep frontmatter first, then the preamble, then the body.
    awk -v pre="$PREAMBLE" '
      NR==1 { print; infm=1; next }
      infm && /^---$/ { print; print ""; while ((getline l < pre) > 0) print l; print ""; infm=0; next }
      { print }
    ' "$f" > "$out"
  else
    # No frontmatter upstream: take the description from the toolkit's registry.
    desc="$(python3 -I -c 'import json,sys; r=json.load(open(sys.argv[1])); print(r["commands"].get(sys.argv[2],{}).get("description",""))' \
      "$SRC/_internal/toolkit-registry.json" "$(basename "$f" .md)")"
    { if [ -n "$desc" ]; then printf -- '---\ndescription: %s\n---\n\n' "$desc"; fi
      cat "$PREAMBLE"; echo; cat "$f"; } > "$out"
  fi
done

cp "$STATIC/install.md" "$PLUGIN/commands/install.md"
cp "$STATIC/hooks.json" "$PLUGIN/hooks/hooks.json"
cp "$STATIC/locate-workspace.sh" "$PLUGIN/hooks/locate-workspace.sh"
chmod +x "$PLUGIN/hooks/locate-workspace.sh"
cp "$SRC/LICENSE" "$PLUGIN/LICENSE"
cp "$SRC/LICENSE" "$ROOT/LICENSE"
cp "$ROOT/README.md" "$PLUGIN/README.md"

# Stamp the version everywhere it appears.
sed -i.bak "s/__TOOLKIT_TAG__/$TAG/g; s/__TOOLKIT_VERSION__/$VERSION/g" \
  "$PLUGIN/commands/install.md" "$PLUGIN/hooks/locate-workspace.sh"
rm -f "$PLUGIN"/commands/*.bak "$PLUGIN"/hooks/*.bak
sed "s/__TOOLKIT_VERSION__/$VERSION/g" "$STATIC/plugin.json" > "$PLUGIN/.claude-plugin/plugin.json"
sed "s/__TOOLKIT_VERSION__/$VERSION/g" "$STATIC/marketplace.json" > "$ROOT/.claude-plugin/marketplace.json"

echo "Synced $TAG: $(ls "$PLUGIN/skills" | wc -l | tr -d ' ') skills, $(ls "$PLUGIN/commands" | wc -l | tr -d ' ') commands"
