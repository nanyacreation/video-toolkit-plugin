> **Workspace (added by the video-toolkit plugin).** This command works inside a claude-code-video-toolkit
> workspace. Every repo path below (`tools/`, `templates/`, `projects/`, `brands/`, `lib/`, `examples/`,
> `_internal/`, `docker/`, `.claude/…`, `CLAUDE.md`, `.env`) is relative to the workspace root named in this
> session's "video-toolkit workspace" context. Run shell commands from there (`cd "<workspace>" && …`) and read
> files by their full path under it. If the context says no workspace is set up, stop and offer
> `/video-toolkit:install` first. If the user is working in a different repo, keep their files there and use the
> workspace only for the toolkit's tools, templates and projects.
