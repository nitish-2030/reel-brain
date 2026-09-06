# 🧠 Reel Brain — Progress Log (Session 2)

> **Session focus:** Fallback handling, photo/screenshot support, startup automation
> **Status:** ✅ Working
> **Date:** September 2026

---

## 📌 What Was Added This Session

1. Fallback handling for reels that fail to download or are private
2. A full photo/screenshot analysis branch (separate from the video pipeline)
3. A bug fix in the IF node used to route Reels vs Photos
4. An automated startup script (Cloudflare Tunnel + webhook + n8n) to remove manual daily setup steps

---

# 🐛 Problems & Solutions

## Problem 1 — IF Node Routing Photos Incorrectly (False Positive)

### ❌ Symptom

Even a plain reel link (no photo attached) was being routed into the **True (Photo)** branch of the IF node.

### 🔍 Root Cause

The condition field:

```javascript
{{ $json.channel_post.photo }}
```

was typed as a **String** in n8n's condition editor. When `photo` didn't exist, n8n coerced the missing value into the literal string `"undefined"` instead of a real `undefined`/`null`. A non-empty string passed the `exists` check, so it evaluated as **true** even without a photo.

### ✅ Solution

Replaced the condition with an explicit boolean check that can't be fooled by type coercion:

```javascript
{{ Array.isArray($json.channel_post.photo) && $json.channel_post.photo.length > 0 }}
```

Operator set to **Boolean → is true**.

### 💡 Learning

Don't trust n8n's implicit type coercion on `exists`/`not empty` checks for fields that may be entirely absent from the JSON. Prefer explicit boolean expressions.

---

## Problem 2 — No Safety Net for Failed/Private Reel Downloads

### ❌ Symptom

If `yt-dlp` failed to download a reel (private account, deleted post, etc.), the workflow had no fallback and would error out instead of still saving *something* useful to Notion.

### ✅ Solution

Added a second branch off the `yt-dlp` Execute Command step:

```text
yt-dlp Execute Command
       ↓
   Error check
       ↓
 ┌─────────────┴─────────────┐
 │                           │
Success                   Failure
 │                           │
Existing video flow     Caption-only flow
(File API upload,       (Code → HTTP → Code
 generateContent)         → Notion, no video)
```

- On failure, only the Telegram caption text (`channel_post.text`) is sent to Gemini for analysis.
- Notion entry is still created, noting that video content was unavailable.

### 💡 Result

The workflow now degrades gracefully instead of failing silently or erroring on private/unavailable reels — matching the original project requirement.

---

## Problem 3 — No Way to Handle Photos/Screenshots

### ❌ Symptom

The original pipeline only handled Instagram Reel links (`channel_post.text`). Forwarding a screenshot or photo did nothing useful.

### ✅ Solution — New Photo Branch

Since images are small, this branch skips `yt-dlp` and the Gemini File API entirely, using **inline base64** instead:

```text
Telegram Trigger (channel_post.photo exists)
           ↓
    Code Node
    (extract fileId + caption)
           ↓
  Telegram — Get File
  (downloads binary image)
           ↓
  Move Binary Data
  (binary → base64 string)
           ↓
  HTTP Request → Gemini generateContent
  (inline_data: base64 + mimeType)
           ↓
    Code Node
    (parse Gemini JSON)
           ↓
      Notion
   (Type: Image)
```

### Key details

- Telegram sends multiple resolutions per photo in an array — always take the **last** element (highest resolution):
  ```javascript
  const photos = $json.channel_post.photo;
  const fileId = photos[photos.length - 1].file_id;
  ```
- Telegram's **File Actions → Get a File** operation downloads the actual binary.
- No cleanup step needed for this branch — nothing touches disk, unlike the video pipeline.
- Reused the same Gemini JSON parsing Code node logic from the reel pipeline.
- Notion write uses a **separate, duplicated Notion node** (not merged with the reel branch) — same database, `Type` set to `Image` instead of `Reel`. Kept separate deliberately to avoid needing a Merge node to reconcile differing field structures (reels have a `Link`, photos don't).

### 💡 Result

Sending a screenshot to the Telegram channel now produces a real Gemini-generated description, tags, and "problem addressed" summary, saved to Notion exactly like a reel.

---

## Problem 4 — Cloudflare Quick Tunnel URL Changes Every Restart

### ❌ Symptom

Each time n8n/tunnel restarted, Cloudflare Quick Tunnel generated a new random `*.trycloudflare.com` URL, requiring the Telegram webhook to be manually reconnected every session.

### 🔍 Root Cause / Context

A **Named Tunnel** (permanent URL) requires owning a domain added to Cloudflare — not available right now ($0 budget constraint).

### ✅ Solution ($0, current)

Automated the reconnect instead of eliminating it, using n8n's own webhook auto-registration behavior:

- n8n's Telegram Trigger node automatically calls Telegram's `setWebhook` on startup, using whatever `WEBHOOK_URL` env var is set.
- A single PowerShell startup script now:
  1. Starts the Cloudflare Quick Tunnel, logging output to a file
  2. Polls that file (every 2s, up to a 30s timeout) for the new `trycloudflare.com` URL
  3. Sets `WEBHOOK_URL` to that fresh URL
  4. Starts n8n, which auto-registers the new webhook with Telegram

```powershell
Start-Process powershell -ArgumentList "cloudflared tunnel --url http://localhost:5678 > tunnel-output.txt 2>&1"

$tunnelUrl = $null
$maxWaitSeconds = 30
$elapsed = 0

while (-not $tunnelUrl -and $elapsed -lt $maxWaitSeconds) {
    Start-Sleep -Seconds 2
    $elapsed += 2
    $match = Select-String -Path tunnel-output.txt -Pattern "https://.*trycloudflare\.com" -ErrorAction SilentlyContinue
    if ($match) { $tunnelUrl = $match.Matches[0].Value }
}

if (-not $tunnelUrl) {
    Write-Host "ERROR: Tunnel failed to start within $maxWaitSeconds seconds. Check tunnel-output.txt for details."
    exit 1
}

$env:WEBHOOK_URL = "$tunnelUrl/"
n8n
```

Wrapped in a `.bat` file so it's a genuine double-click, since `.ps1` files don't run directly from Explorer:

```bat
powershell -ExecutionPolicy Bypass -File "D:\reel_temp\start-reelbrain.ps1"
```

### 💡 Future Fix (deferred)

Once a cheap domain (~$1–10/year) is available: switch to a **Cloudflare Named Tunnel**, get a permanent hostname, set the Telegram webhook once and never again, and optionally run the tunnel as a Windows service for auto-start on boot.

### 💡 Learning

`NODES_EXCLUDE` and `N8N_RESTRICT_FILE_ACCESS_TO` were moved into permanent Windows System Environment Variables, so the startup script only needs to manage the one value that legitimately changes every session (`WEBHOOK_URL`).

---

# 📊 Session Summary

| Item                                             | Status |
| ------------------------------------------------ | ------ |
| Fallback handling for failed/private reels        | ✅      |
| Photo/screenshot analysis branch                  | ✅      |
| IF node type-coercion bug fixed                   | ✅      |
| Automated startup script (tunnel + webhook + n8n) | ✅      |
| Permanent Named Tunnel (domain-based)             | ⏳ Deferred (needs domain) |
| Downloaded video cleanup step                     | ⏳ Not started |
| Verify & Expand feature                           | ⏳ Optional, not started |

**Core pipeline status:** 🟢 Reel and Photo capture both working end-to-end, with graceful degradation on failure, and a one-click daily startup routine.
