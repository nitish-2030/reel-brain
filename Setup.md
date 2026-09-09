# Setup — Run Reel Brain On Your Own Machine

This is the condensed, "just get it running" guide. For the original longer step-by-step (with the copy-paste AI prompts it was originally built from), see `docs/setup-guide.md`. For *why* things are built the way they are, see `docs/project-context.md` and `docs/step7-verify-architecture.md`.

Target: **$0 total cost**, everything on free tiers, no credit card required anywhere.

## 0. Prerequisites

- Windows (this was built and tested on Windows; the n8n/Telegram/Gemini/Notion parts are OS-agnostic, but the provided startup script and `Execute Command` calls are PowerShell/Windows-flavored)
- [Node.js + npm](https://nodejs.org)
- [Python](https://python.org) (needed by `yt-dlp`)
- [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) and [`ffmpeg`](https://ffmpeg.org/download.html) on your PATH
- [`cloudflared`](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/) on your PATH
- n8n installed globally: `npm install -g n8n`

## 1. Get your free accounts and keys

Do these in order — each is free, no card required:

1. **Telegram bot + private channel** — talk to `@BotFather` to create a bot and get a Bot Token, create a private channel, add the bot as admin. See `docs/setup-guide.md` Step 1 for the detailed walkthrough.
2. **Notion database** — create the database described in `notion/schema.md`, create an internal integration, connect the database to it, get the integration token and database ID.
3. **Google Gemini API key** — sign up at [aistudio.google.com](https://aistudio.google.com), generate an API key, **leave billing disabled**.
4. **Tavily API key** *(only if you want the optional Step 7 "Verify This" feature)* — sign up at [app.tavily.com](https://app.tavily.com), get an API key.

Keep all four somewhere safe. `.env.example` at the repo root lists exactly what you'll need — copy it and fill it in for your own reference (it's gitignored).

## 2. Set permanent environment variables (once)

These two don't change between runs, so set them as **Windows System Environment Variables** (System Properties → Environment Variables → System variables → New), not in the startup script:

```text
NODES_EXCLUDE=[]
N8N_RESTRICT_FILE_ACCESS_TO=D:\reel_temp
```

- `NODES_EXCLUDE=[]` re-enables the `Execute Command` node, which n8n 2.0+ disables by default for security. This project needs it for `yt-dlp` and `ffmpeg`.
- `N8N_RESTRICT_FILE_ACCESS_TO` tells n8n which folder it's allowed to read/write files from disk. Point it at wherever you want downloaded reel videos to land temporarily — create that folder if it doesn't exist (e.g. `D:\reel_temp`).

Restart your terminal (or your machine) after setting these so they take effect.

## 3. Import the workflows

1. Start n8n: `n8n` (or use `scripts/start-reelbrain.ps1`, see step 5 below).
2. Open `http://localhost:5678` in your browser.
3. **Workflows → Import from File** → select `workflows/reel-brain-main-pipeline.json`.
4. Repeat for `workflows/reel-brain-verify-and-expand.json` if you want the optional Step 7 feature.
5. n8n will flag every node with a credential it doesn't recognize (they were exported from someone else's instance). For each one, click it and either create a new credential or map it to one you've already created — see the credential list in `workflows/README.md`.
6. Replace the placeholder `REPLACE_WITH_YOUR_NOTION_DATA_SOURCE_ID` / `REPLACE_WITH_YOUR_NOTION_DATABASE_URL` values in both workflows' Notion nodes with your own database ID/URL from step 1.

## 4. Get a public HTTPS URL for the Telegram webhook

Telegram requires HTTPS for its webhook; local n8n is only `http://localhost:5678`. The free, zero-setup fix is a Cloudflare Quick Tunnel — see step 5, it's automated for you.

If you'd rather do it manually once, just to confirm everything works:

```powershell
cloudflared tunnel --url http://localhost:5678
```

Copy the `https://*.trycloudflare.com` URL it prints, then set it before starting n8n:

```powershell
$env:WEBHOOK_URL = "https://<your-tunnel-url>/"
n8n
```

Note: a Quick Tunnel's URL changes every time you restart it, so you'd have to repeat this every session — which is exactly what the startup script in step 5 automates away.

## 5. Daily startup (after the one-time setup above)

Run `scripts/start-reelbrain.ps1` (see that file for a `.bat` wrapper you can double-click). It will:

1. Start a fresh Cloudflare Quick Tunnel
2. Wait for its URL to appear
3. Set `WEBHOOK_URL` to that URL
4. Start n8n, which auto-registers the new webhook with Telegram

Leave that terminal window open while you want the automation running. Ctrl+C stops n8n; the tunnel process will need to be closed separately (it runs in its own window).

## 6. Test it end to end

1. Forward an Instagram reel link to your private Telegram channel.
2. Watch the n8n editor — you should see the workflow execute (download → compress → upload to Gemini → analyze → write to Notion → delete temp file).
3. Check Notion — a new row should appear with a real, video-based Summary/Tags/Problem, not "I cannot access external websites."
4. If you set up Step 7: tick **Verify This** on any saved row, wait for the next Notion poll cycle (up to a few minutes depending on your trigger's poll interval), and check that **Verified Solution** and **Search Log** get filled in and the checkbox unchecks itself.

## Troubleshooting

These are the real issues hit while building this — see `progress/` for the full blow-by-blow:

| Symptom | Cause | Fix |
|---|---|---|
| `Execute Command` node missing from search | Disabled by default in n8n 2.0+ | Set `NODES_EXCLUDE=[]` (step 2) |
| `'' is not a valid URL` from yt-dlp | Telegram fires on `channel_post`, not `message`, for channel posts | Use `{{ $json.channel_post.text }}`, not `{{ $json.message.text }}` |
| `Access to the file is not allowed` | n8n blocks file access outside its allowed folder by default | Set `N8N_RESTRICT_FILE_ACCESS_TO` to your temp folder (step 2) |
| Filename expression resolves to literal `{{ }}` text | Complex inline expressions don't reliably commit in some n8n UI fields | Move the logic into a Code node that outputs a clean value, then reference that with a simple expression |
| Gemini says "I cannot access external websites" | Only the URL/caption was sent, not actual video | Download with `yt-dlp` first, upload the actual video file to Gemini's File API |
| `No file(s) found` in Read/Write Files from Disk | A stale/incorrect path was referenced somewhere upstream | Trace the path value through every node in the chain, not just the one that errored |