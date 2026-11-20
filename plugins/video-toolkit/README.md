# video-toolkit: Claude Code plugin

[claude-code-video-toolkit](https://github.com/digitalsamba/claude-code-video-toolkit) (MIT, © Digital Samba)
packaged as an installable Claude Code plugin. You tell Claude what video you want, and it writes the script,
generates the voiceover, music and visuals, and renders the MP4.

Built from upstream release **v0.29.1**.

## Install

```
/plugin marketplace add <your-github-user>/video-toolkit-plugin
/plugin install video-toolkit@video-toolkit-marketplace
```

Then, once:

```
/video-toolkit:install      # clones the toolkit workspace to ~/claude-code-video-toolkit (or a folder you name)
/video-toolkit:setup        # cloud GPU, storage, voice (~5 min, mostly free tiers)
/video-toolkit:video        # make a video
```

Requirements: git and Node.js 22+. [uv](https://docs.astral.sh/uv/) is needed for the AI tools. FFmpeg and Blender are optional.

## How it is split

| Lives in the plugin | Lives in the workspace (a normal folder you own) |
|---|---|
| 16 skills: `remotion`, `ffmpeg`, `elevenlabs`, `video-design`, `playwright-recording`, `ltx2`, `acestep`, `ideogram4`, `blender`, … | `tools/` (Python CLIs), `templates/`, `lib/` components, `brands/`, `examples/` |
| 16 commands: `/video-toolkit:video`, `:setup`, `:design`, `:brand`, `:template`, `:scene-review`, `:generate-voiceover`, `:redub`, `:record-demo`, `:thumbnail`, `:publish`, … plus `:install` | **your `projects/`**, `.env` with your keys, `.venv` |
| A SessionStart hook that finds the workspace | |

The workspace stays out of the plugin on purpose. Plugin updates replace the plugin's folder, which would delete
your projects and keys. The toolkit's tools also expect the repo layout, and it's about 80 MB.

The hook looks for the workspace in this order: `$VIDEO_TOOLKIT_HOME`, the current directory or a parent of it,
the folder saved by `/video-toolkit:install` (in `~/.config/video-toolkit/workspace`), then `~/claude-code-video-toolkit`.
It tells Claude the path, so the commands work from any directory. Without a workspace, the skills still give their
guidance, and the commands offer to run `/video-toolkit:install`.

If you open Claude Code inside the workspace itself, the repo's own `/video`, `/setup`, … also show up next to
`/video-toolkit:*`. They're the same commands.

## Differences from upstream

- Each upstream command starts with a short "workspace" note telling Claude to resolve repo paths against the workspace.
- `design.md` gets frontmatter, with the description taken from the toolkit's registry.
- New: the `install` command and the workspace-finding hook.
- Skills are copied unchanged.

## Updating to a new upstream release

```bash
scripts/sync-from-upstream.sh v0.30.0
claude plugin validate plugins/video-toolkit
```

This regenerates `plugins/video-toolkit/` from that tag and stamps the version into the manifests and into the
`install` command, so the workspace it clones matches the skills. Plugin-owned files live in `scripts/static/`.

Windows: the hook needs `bash` (Git Bash or WSL).
