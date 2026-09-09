# Project Context — Reel Brain

## The problem this exists to solve

I watch reels/content on Instagram and save them, or send them to another account, intending to revisit and use them later — ideas, tools, tutorials, solutions to problems. But I forget about them and never go back, so the saved content is effectively lost, even though it might contain exactly what I need later (an AI tool, an automation trick, a solution to a problem I'm facing right now).

## The goal

A personal automated system — "Reel Brain" — that:

1. **Captures** — I forward any reel/content I want to save to a Telegram bot/channel (my "inbox"). No manual organizing needed.
2. **Understands & stores** — An n8n automation picks up each forwarded item, sends it to Google Gemini (free tier), which watches/reads it and produces a short summary, relevant tags, and what problem/need it addresses. This gets saved as a new row in a Notion database, so every saved reel becomes a searchable, summarized entry instead of a forgotten link.
3. **Recalls** — When I later have a problem or need ("I need an AI image tool", "how do I automate X"), I can search/filter my Notion database by tag or keyword and instantly see which saved reels are relevant, with a summary, so I don't have to rewatch everything.
4. **Verifies & expands** *(optional, advanced)* — For any reel that claims to teach a technique or solution, I can tag it "Verify This", and the automation sends it back to the AI to check if the claim is real/accurate/currently possible, and if so produce a full step-by-step guide (tools, costs, prerequisites). If it's outdated or misleading, it says so clearly. The result gets stored back in Notion too.

## System design / tech stack (target: $0)

- **Telegram** — private channel + bot = capture inbox (free)
- **n8n** — automation engine, running locally on Windows via npm (not Docker, not n8n cloud)
- **Google AI Studio (Gemini API)** — the "brain": video/audio/text understanding, summarizing, tagging, and later, verification reasoning
- **Notion** — free-tier database, the searchable storage layer

```text
Instagram reel
      → forwarded to Telegram channel
      → n8n workflow triggers
      → content sent to Gemini API
      → Gemini returns summary + tags
      → n8n writes a new row into Notion
      → search Notion later when there's a need
```

## Environment this was built in

- OS: Windows
- Comfortable with terminal/CLI: yes
- Already installed before this project: Node.js, npm, n8n (global via npm), Python, Docker (not used — n8n runs via npm/CLI, not Docker)
- Budget: $0 — every tool/service must be free tier, no paid subscriptions, no credit card on file

## Definition of "done" (original success criteria)

1. **Capture** — forwarding any Instagram reel to the Telegram channel requires zero manual steps beyond the forward itself.
2. **Understand & store** — a new Notion row appears automatically with an accurate summary based on the *real* video/audio content (not just the caption or URL), relevant tags, and the problem/need addressed — reliably, for a few reels a day.
3. **Recall** — later search/filter Notion by tag or keyword to find relevant saved reels without rewatching them.
4. **Reliability** — the system keeps working across PC restarts with a short startup routine, no leftover files piling up, and graceful fallback (not a crash) when a reel can't be downloaded.
5. **Cost** — everything stays on free tiers, $0 total.
6. **(Optional)** the Verify & Expand feature is a bonus, not required for the core project to be "done".

See `progress/` for the real, chronological build log — what broke, why, and how each thing was fixed.