---
description: Set up (or update) the claude-code-video-toolkit workspace the plugin's commands and tools run in
argument-hint: "[folder, default ~/claude-code-video-toolkit]"
---

Set up the claude-code-video-toolkit workspace at release `__TOOLKIT_TAG__`, the release this plugin was built from.
The plugin carries the skills and commands; the workspace carries the tools, templates, brands, examples and the
user's own `projects/`, so it lives in a normal folder the user owns, never inside the plugin's cache.

Target folder: `$ARGUMENTS` if given, otherwise `~/claude-code-video-toolkit`. Expand `~` to the user's home.

1. **Prerequisites.** Check `git --version` (required) and `node --version` (22+ required for rendering).
   Note, without installing anything, whether `uv` and `ffmpeg` exist; they are optional now and `/video-toolkit:setup`
   covers them. If git or Node is missing, say what to install and stop.

2. **Existing folder.**
   - Contains `_internal/toolkit-registry.json`: it is already a workspace. Read its `"version"`. If it is
     `__TOOLKIT_VERSION__`, say so and go to step 4. Otherwise run `git -C <folder> status --porcelain`. Clean: offer to
     move it with `git -C <folder> fetch --tags origin && git -C <folder> checkout __TOOLKIT_TAG__`. Not clean: list the
     changed files and ask before touching anything; never stash, reset or delete the user's work.
   - Exists but isn't a workspace and isn't empty: ask for another folder.

3. **Clone** (about 80 MB, mostly example videos and templates):
   ```bash
   git clone --branch __TOOLKIT_TAG__ https://github.com/digitalsamba/claude-code-video-toolkit.git "<folder>"
   ```
   A detached HEAD on the tag is expected.

4. **Remember the folder** so later sessions find it from any directory:
   ```bash
   mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/video-toolkit" && printf '%s\n' "<folder>" > "${XDG_CONFIG_HOME:-$HOME/.config}/video-toolkit/workspace"
   ```

5. **Python tools (optional).** If `uv` exists, offer `cd "<folder>" && uv sync` (needed for AI voiceover, images,
   music and the cloud GPU tools). Run it if the user agrees.

6. **Smoke test (optional).** Offer the no-keys render: `cd "<folder>/examples/hello-world" && npm install && npm run render`.

7. **Tell the user**, briefly:
   - where the workspace is, and that the workspace location is picked up automatically from the next session;
     for the rest of this session, use `<folder>` as the workspace root;
   - next steps: `/video-toolkit:setup` for cloud GPU, storage and voice (about 5 minutes, mostly free tiers),
     then `/video-toolkit:video` to make a video;
   - if they open Claude Code inside the workspace itself, the repo's own `/setup`, `/video` etc. also appear next
     to the plugin's `/video-toolkit:*` ones. They are the same commands, and either works.
