# Workflows

Two n8n workflow exports live here. Together they are the entire Reel Brain automation — nothing runs outside n8n.

| File | Trigger | What it does |
|---|---|---|
| `reel-brain-main-pipeline.json` | Telegram Trigger (`channel_post`) | Capture branch. Routes reels vs photos, downloads/compresses reel video, sends video or photo or caption-only to Gemini, writes a new Notion page, cleans up the temp video file. |
| `reel-brain-verify-and-expand.json` | Notion Trigger (polling) | Optional Step 7 "Verify This" branch. Watches for the `Verify This` checkbox, has Gemini generate search queries, runs them through Tavily, asks Gemini for a verdict, and writes the result back into the *same* Notion page. |

Import both into n8n via **Workflows → Import from File**.

## ⚠️ Before you import

These exports came straight out of a real, working local instance. A few fields still point at the original owner's private Notion database and are **placeholders you must replace**:

- `dataSourceId.value` → your own Notion data source / database ID
- `dataSourceId.cachedResultUrl` → your own Notion database URL

They're set to `REPLACE_WITH_YOUR_NOTION_DATA_SOURCE_ID` / `REPLACE_WITH_YOUR_NOTION_DATABASE_URL` in these files. n8n workflow exports do **not** include actual API keys/tokens (those live in n8n's encrypted credential store on each machine), so the `credentials.id` values you'll see are just local reference IDs — they will not work on your machine and n8n will ask you to map each one to your own credential the first time you open the workflow.

## Required n8n credentials

Set these up in **n8n → Credentials** before importing (see the root `SETUP.md` for the full walkthrough):

1. **Telegram account** (`telegramApi`) — Bot Token from BotFather
2. **Notion account** (`notionApi`) — Notion internal integration token, shared with your database
3. **Gemini HTTP header auth** (`httpHeaderAuth`) — used twice under different credential names in the export (`gogapi`, `gogpalmapi2`, `gogapi2`); you only need **one** real Gemini API key — just point all three at the same credential when n8n asks you to remap them. Header: `x-goog-api-key: <your Gemini API key>`
4. **Google Gemini(PaLM) Api account** (`googlePalmApi`) — used only by the "Upload a media file" node (Gemini File API upload), same API key as above
5. **Tavily API** (`httpHeaderAuth`) — only needed for `reel-brain-verify-and-expand.json`. Header: `Authorization: Bearer <your Tavily API key>`

## System requirements on the machine running n8n

- `yt-dlp` and `ffmpeg` available on PATH (used via `Execute Command` nodes)
- `Execute Command` node enabled (disabled by default in n8n 2.0+): start n8n with `NODES_EXCLUDE=[]`
- File access to your temp folder allowed: start n8n with `N8N_RESTRICT_FILE_ACCESS_TO=<your temp folder>`, e.g. `D:\reel_temp`
- A public HTTPS URL for the Telegram webhook (a Cloudflare Quick Tunnel works with zero setup — see `scripts/start-reelbrain.ps1`)

See `docs/setup-guide.md` and `SETUP.md` for the full step-by-step.