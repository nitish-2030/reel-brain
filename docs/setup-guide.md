# Setup Guide — 100% Free Version

Stack: Telegram (free) + n8n local/self-hosted (free) + Google AI Studio / Gemini API (free tier) + Notion (free).
**Total cost: $0.**

This is the original step-by-step plan the project was built from. It's kept here for historical/reference value — for the condensed, "just get it running" version with the fixes this project actually needed along the way, see `SETUP.md` in the repo root.

Prerequisites assumed: Windows, Node.js/npm/n8n already installed, Python already installed, comfortable with a terminal. Docker is installed but not used.

## Step 0 — Update n8n

Update n8n to the latest version via npm, confirm the version, start it locally at `http://localhost:5678`, and know how to stop it cleanly (Ctrl+C).

## Step 1 — Telegram bot + private channel

1. Create a Telegram bot via **BotFather**, save the Bot Token.
2. Create a new **private** Telegram channel.
3. Add the bot as an **admin** of that channel.
4. Test by forwarding a message into the channel.

Result: a bot token + a private channel with the bot as admin, confirmed working.

## Step 2 — Notion database

Create a database with these columns (see `notion/schema.md` for the full, current schema):

- Title (text)
- Summary (text)
- Tags (multi-select)
- Link (URL)
- Date Saved (date)
- Type (select: Reel / Image / Other)

Then:

1. Create a Notion **internal integration** and get its token.
2. Share/connect the database with that integration.
3. Note the **Database ID** from the database's URL.

## Step 3 — Google AI Studio (Gemini) API key

1. Sign up at [aistudio.google.com](https://aistudio.google.com).
2. Generate a free API key — **do not enable billing**, to stay on the free tier.
3. Store the key securely (not in plain text files committed anywhere).
4. Use a current Gemini Flash/Flash-Lite model that supports video/audio understanding.
5. Note the free tier's rate limits so you know roughly how many reels/day you can process.

Gemini can understand audio/video directly in one call, so no separate transcription tool (e.g. Whisper) is needed.

## Step 4 — Connect everything inside n8n

1. Add Telegram credentials in n8n, test the connection.
2. Add Gemini credentials — check whether your n8n version has a built-in Gemini node with the functionality you need, or use an HTTP Request node against the Gemini API directly (this project ended up needing the HTTP Request approach — see `progress/progress.md`, Problem 6).
3. Add Notion credentials, test the connection.
4. Confirm all three work with a simple test workflow.

## Step 5 — Build the automation workflow

Trigger on a new Telegram channel post → pass the reel content (video/audio if accessible, plus caption) to Gemini in one call → have Gemini summarize in 2 lines, extract 3–5 tags, and state the problem/need addressed → create a Notion row with Title, Summary, Tags, Link, Date Saved, Type → if video/audio isn't accessible, fall back to caption-only and note that in the Notion entry.

Watch out for Gemini free-tier rate limits with real-world use (a few reels a day) — add retry logic / delays if needed.

## Step 6 — Daily usage habit

1. Fastest way to forward a reel from Instagram to Telegram (fewest taps).
2. Since n8n runs locally, decide whether it needs to be actively running for the automation to trigger, and how to start it in the background/on startup.
3. Search/filter the Notion database by tag, keyword, or date.
4. A simple weekly review routine (e.g. "every Sunday, review new entries for 10 minutes").
5. Notion views like "Unreviewed" / "Reviewed" / "Favorites".

## Step 7 (optional) — Verify & Expand

For any reel tagged "Verify This": take its content/caption, check whether the claim is factually accurate and currently possible using real, current information (not just the model's static training knowledge), and if accurate, produce a full step-by-step guide. If inaccurate/outdated/misleading, say so and explain why. Store the result back into Notion in a "Verified Solution" column.

**Note:** the original plan for this step assumed Gemini's built-in Google Search grounding tool could be used directly. In practice that required enabling Cloud Billing (a credit card on file), which broke the $0/no-card requirement — see `docs/step7-verify-architecture.md` for the actual approach that was built instead (Gemini for reasoning + Tavily for the actual free web search).

---

Order to follow: Step 0 → 1 → 2 → 3 → 4 → 5 → 6 → (7 optional). Don't move to the next step until the current one is confirmed working.