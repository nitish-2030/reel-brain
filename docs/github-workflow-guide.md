# GitHub Setup & Progress Showcase Guide

This is the plan used to organize this repo so it doesn't read like a one-day dump — commit history, README, issues, and progress logs are all meant to tell the real story of how this was built over a week+.

## Repo structure

```text
reel-brain/
├── README.md          — project overview: what/why/how
├── SETUP.md            — how to actually run this yourself
├── .gitignore
├── docs/               — context files, setup guide, design decisions
├── workflows/          — n8n workflow JSON exports
├── notion/             — Notion database schema notes
├── progress/           — chronological progress logs (what broke, what was learned)
├── scripts/            — startup automation (Cloudflare tunnel + n8n)
└── learnings/          — deeper dives into concepts learned along the way
```

## Commit convention

Prefix commits so the history is scannable at a glance:

- `step1:`, `step2:`, … — completing a stage from the setup guide
- `feat:` — new capability added
- `fix:` — bug fix
- `docs:` — documentation-only changes
- `progress:` — progress log update

## Progress tracking

- One GitHub Issue per project stage (Update n8n, Telegram bot, Notion DB, Gemini key, connect in n8n, build workflow, daily usage, optional Verify & Expand), each as a checklist.
- A simple Kanban Project board: To Do / In Progress / Done, with issues linked.
- Reference issue numbers in commits (`Closes #3`) so GitHub auto-links/closes them.
- Labels: `setup`, `automation`, `enhancement`, `bug`.

## Keeping the repo honest as you go

After finishing any piece of work:

1. Update the relevant file in `progress/` with what broke, why, and how it was fixed.
2. Update the status checklist in `README.md` if a milestone changed.
3. Close/move the related GitHub issue or project board card.
4. Commit with a proper prefix and push — small, frequent commits, not one giant dump at the end.

## Before you commit or push

- Never commit real API keys, bot tokens, or Notion integration tokens — check `.gitignore` covers `.env*`, and double check any workflow JSON exports for embedded database IDs/URLs before pushing (n8n exports don't include actual secrets, but they can include your real Notion database ID/URL — see `workflows/README.md`).
- Export n8n workflows as JSON (`workflows/`) so they're reviewable and importable by anyone.

## What a developer should see when they open this repo

- **README.md** — what the project is, why it exists, how it works, current status
- **SETUP.md** — enough detail to actually run this on their own machine
- **Issues / Project board** — exactly which stages are done, in progress, or not started
- **Commit history** — a clean, readable trail of how the project was actually built, including the dead ends
- **docs/** — full context and the design decisions behind the trickier parts (e.g. Step 7)
- **No secrets, tokens, or API keys anywhere in the repo**