# 🧠 Reel Brain

> **A personal automation system that turns saved Instagram Reels into a searchable knowledge base.**

Reel Brain solves a simple problem:

You find useful Instagram Reels about AI tools, automation, tutorials, ideas, or solutions — save them for later — and then forget about them.

Reel Brain turns those saved Reels (and now screenshots too) into **organized, summarized, searchable knowledge**.

---

## 🚀 How It Works

The basic workflow is:

**Instagram Reel / Screenshot → Telegram → n8n → Gemini → Notion**

### 1. Capture

Forward an Instagram Reel, or send a screenshot/photo, to a private Telegram channel.

### 2. Understand

Local n8n picks up the content:
- **Reels** → downloaded locally with `yt-dlp`, then uploaded to Gemini's File API for real video analysis
- **Photos/Screenshots** → sent directly to Gemini as inline base64 image data
- **Failed/private reels** → automatically fall back to caption-only analysis so nothing errors out silently

### 3. Summarize & Tag

Gemini generates:

* A short summary
* Relevant tags
* The problem or need the content addresses

### 4. Store

n8n saves the result as a new entry in a Notion database, tagged by `Type` (Reel / Image).

### 5. Recall

Later, search or filter Notion by keyword, tag, or date to find useful content without rewatching everything.

---

## 🏗️ Architecture

```text
┌─────────────────────────┐
│ Instagram Reel / Photo  │
└────────────┬────────────┘
             │ Forward
             ▼
┌─────────────────────────┐
│     Telegram Inbox      │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│       Local n8n         │
│   (Reel vs Photo IF)    │
└──────┬──────────┬───────┘
       │          │
   Reel branch  Photo branch
   (yt-dlp +     (inline
   File API)     base64)
       │          │
       ▼          ▼
┌─────────────────────────┐
│      Google Gemini      │
│    AI Analysis          │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│         Notion          │
│    Knowledge Base       │
└────────────┬────────────┘
             │
             ▼
       Search & Recall
```

Public access to local n8n is provided via a Cloudflare Tunnel, started automatically alongside n8n through a single startup script.

---

## 🛠️ Tech Stack

| Technology            | Purpose                                                   |
| --------------------- | --------------------------------------------------------- |
| **Telegram**          | Personal inbox for forwarded Reels and photos              |
| **n8n**               | Local automation engine                                   |
| **Google Gemini API** | Video/image/text understanding, summarization and tagging |
| **Notion**            | Searchable storage and knowledge base                     |
| **Cloudflare Tunnel** | Exposes local n8n to Telegram's webhook over HTTPS         |
| **yt-dlp**            | Downloads actual Reel video content for analysis           |
| **FFmpeg**             | Compresses downloaded video (480p) before it's sent to Gemini, to save upload time and API usage |
| **Tavily**             | Free web search API used only by the optional Verify & Expand feature |
| **Node.js / npm**     | Runs the local n8n setup                                  |

All services run on free tiers.

**Target cost: $0**

---

## 📋 Notion Database

Each saved piece of content is stored with:

* **Title**
* **Summary**
* **Tags**
* **Link**
* **Date Saved**
* **Type** — Reel / Image / Other

This turns a collection of random saved Reels and screenshots into structured information that can be searched later.

---

## 📂 Repository Structure

```text
reel-brain/
│
├── README.md            — this file: what/why/how
├── SETUP.md              — how to actually run this on your own machine
├── .env.example          — every config value/credential you'll need
├── .gitignore
│
├── docs/
│   └── Project context, original setup guide, Step 7 design decisions
│
├── workflows/
│   └── n8n workflow exports (main pipeline + Verify & Expand)
│
├── notion/
│   └── Notion database schema
│
├── scripts/
│   └── Startup automation (Cloudflare tunnel + n8n)
│
├── progress/
│   └── Chronological progress logs — what broke, what was learned
│
└── learnings/
    └── Deeper dives into concepts learned along the way
```

---

## 📊 Current Status

### Setup Progress

* [x] GitHub repository created
* [x] Local Git repository initialized
* [x] GitHub remote connected
* [x] Initial repository structure created
* [x] `.gitignore` configured
* [x] n8n updated and running locally
* [x] Telegram Bot + private channel
* [x] Notion database
* [x] Gemini API setup
* [x] Connect Telegram + Gemini + Notion in n8n
* [x] Build complete automation workflow (Reel branch)
* [x] Fallback handling for failed/private reels (caption-only path)
* [x] Photo/screenshot analysis branch (inline base64 → Gemini)
* [x] Automated startup script (tunnel + webhook + n8n)
* [x] FFmpeg compression step for downloaded video
* [x] Cleanup step for downloaded video files
* [x] Verify & Expand feature *(optional)* — Gemini query generation + Tavily search + Gemini verdict, written back to the same Notion row
* [ ] Permanent Cloudflare Named Tunnel (pending free/cheap domain)

> **Current phase:** Core pipeline is fully working end-to-end for both Reels and photos, including graceful fallback for undownloadable reels, video compression, temp-file cleanup, and a one-click daily startup script. The optional Verify & Expand feature is also built and working. Remaining work is the permanent tunnel (needs a domain) and general reliability polish.

---

## 🗺️ Roadmap

### Phase 1 — Foundation ✅

* Set up and verify n8n
* Create Telegram bot and private channel
* Create Notion database
* Configure Gemini API

### Phase 2 — Integration ✅

* Connect Telegram to n8n
* Connect Gemini to n8n
* Connect Notion to n8n
* Test each integration

### Phase 3 — Automation ✅

* Detect forwarded content (Reel vs Photo, via IF node)
* Download and process Reel video content via `yt-dlp` + Gemini File API
* Process photos/screenshots via inline base64 to Gemini
* Generate summary and tags
* Save structured information to Notion
* Handle cases where video download fails (caption-only fallback)

### Phase 4 — Daily Usage ✅

* ✅ One-click startup script (Cloudflare Tunnel + webhook + n8n)
* ✅ Moved `NODES_EXCLUDE` / `N8N_RESTRICT_FILE_ACCESS_TO` into permanent system env vars
* ✅ Cleanup step deletes downloaded `.mp4` files after successful Notion save
* [ ] Upgrade to a Cloudflare Named Tunnel once a domain is available (permanent webhook URL)
* [ ] Create useful Notion views (Unreviewed / Reviewed / Favorites)
* [ ] Develop a regular review habit

### Phase 5 — Optional Expansion ✅

**"Verify This"** is built and working: ticking the checkbox on a saved Reel has Gemini generate search queries, runs them through Tavily's free search API, and has Gemini produce a verified, step-by-step solution — written back into the same Notion row along with a full search log. See `docs/step7-verify-architecture.md` for the design and `progress/progress_update_5.md` for the build.

---

## 🔐 Security

**Never commit secrets to this repository.**

API keys, bot tokens, Notion integration tokens, credentials, and other sensitive configuration should remain outside Git.

The repository's `.gitignore` is configured to help prevent common secret/configuration files from being committed.

---

## 💡 Why Reel Brain?

The goal isn't simply to save more content.

The goal is to make saved content **useful later**.

Instead of:

```text
"I remember seeing a Reel about this..."
```

The goal is:

```text
"I need a solution for X."
        ↓
Search Notion
        ↓
Find relevant Reel or screenshot
        ↓
Read the summary
        ↓
Use the useful information
```

---

## 📌 Project Philosophy

**Capture → Understand → Organize → Recall**

> Save less mentally.
> Remember more automatically.

---

## 📄 Documentation

Additional project documentation and setup information is maintained inside the `docs/` and `progress/` directories.

---

## ⚠️ Project Status

Reel Brain's core automation is **working end-to-end** for both Reels and photos. The project is being polished incrementally (cleanup, permanent tunnel, optional Verify & Expand feature) rather than treated as fully "done."