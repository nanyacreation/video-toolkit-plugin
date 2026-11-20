#!/usr/bin/env bash
# SessionStart hook: find the claude-code-video-toolkit workspace and tell Claude where it is.
# Lookup order: $VIDEO_TOOLKIT_HOME, the current directory or a parent, the path saved by
# /video-toolkit:install, then ~/claude-code-video-toolkit.
PLUGIN_VERSION="0.29.1"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/video-toolkit/workspace"

is_ws() { [ -n "$1" ] && [ -f "$1/_internal/toolkit-registry.json" ]; }

ws=""
if is_ws "${VIDEO_TOOLKIT_HOME:-}"; then ws="$VIDEO_TOOLKIT_HOME"; fi
if [ -z "$ws" ]; then
  d="$PWD"
  while [ -n "$d" ] && [ "$d" != "/" ]; do
    if is_ws "$d"; then ws="$d"; break; fi
    d="$(dirname "$d")"
  done
fi
if [ -z "$ws" ] && [ -f "$CONFIG" ]; then
  saved="$(head -1 "$CONFIG")"
  if is_ws "$saved"; then ws="$saved"; fi
fi
if [ -z "$ws" ] && is_ws "$HOME/claude-code-video-toolkit"; then ws="$HOME/claude-code-video-toolkit"; fi

if [ -n "$ws" ]; then
  ver="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$ws/_internal/toolkit-registry.json" | head -1)"
  msg="video-toolkit workspace: $ws (toolkit $ver; plugin built for $PLUGIN_VERSION). The video-toolkit plugin's skills and commands use repo paths such as tools/, templates/, projects/, brands/, _internal/ and .claude/skills/; resolve them against this directory and run toolkit commands from it."
  if [ -n "$ver" ] && [ "$ver" != "$PLUGIN_VERSION" ]; then
    msg="$msg The workspace version differs from the plugin's; if a path or flag is missing, suggest /video-toolkit:install to move the workspace to $PLUGIN_VERSION."
  fi
else
  msg="video-toolkit workspace: not set up. The video-toolkit plugin's skills give video-production guidance anywhere, but its commands and the tools they run (tools/, templates/, projects/) need the workspace. Before anything that needs them, offer /video-toolkit:install."
fi

# JSON-escape the message (backslashes and quotes only; the message has no newlines).
esc="$(printf '%s' "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g')"
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$esc"
