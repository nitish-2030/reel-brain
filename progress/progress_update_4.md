# 🧠 Reel Brain — Progress Log (Session 4)

> **Session focus:** Video compression + file-path reliability fixes on the main capture pipeline
> **Status:** ✅ Working — main pipeline reached v1 complete
> **Date:** September 2026

---

## 📌 What this session covers

The core Telegram → yt-dlp → Gemini → Notion pipeline was already working, but downloaded reel videos were going to Gemini's File API uncompressed — slower uploads and more Gemini processing/credits than necessary. This session adds an FFmpeg compression step, and fixes a chain of file-path bugs that surfaced while wiring it in.

---

## Problem 1 — Downloaded videos were too large

**Symptom:** Large videos increased upload time and Gemini processing/credit usage.

**Solution:** Added an FFmpeg compression step between download and upload:

```text
scale → 480p
video bitrate → 800k
audio bitrate → 64k
```

```bash
ffmpeg -y -i "original.mp4" -vf "scale=-2:480" -b:v 800k -c:a aac -b:a 64k "original_c.mp4"
```

**Result:** Much smaller video while keeping enough quality for Gemini to actually analyze.

## Problem 2 — Wrong file path was being passed downstream

**Symptom:** The workflow sometimes passed an incorrect/stale path to the next node.

**Root cause:** `yt-dlp`'s `Execute Command` output includes more than just the final path in `stdout`.

**Solution:** A dedicated Code node takes the **last non-empty line** of the command's stdout, which is the actual file path:

```javascript
const stdout = $input.item.json.stdout.trim();
const lines = stdout.split('\n').filter(l => l.trim().length > 0);
const filePath = lines[lines.length - 1].trim();
```

**Result:** The workflow reliably gets the real downloaded file path, not a stale or partial one.

## Problem 3 — Compressed file path needed to be generated, not guessed

**Symptom:** After FFmpeg created the compressed `_c.mp4` file, the next node needed that exact path — but it wasn't being produced consistently.

**Solution:** A Code node derives the compressed path directly from the original path (`original.mp4` → `original_c.mp4`), and was corrected to read from the node that holds the *current* path rather than an earlier, now-stale reference.

**Result:** The correct compressed file path reaches the file-reading node every time.

## Problem 4 — `Read/Write Files from Disk` reported "No file(s) found"

**Symptom:** Despite FFmpeg completing successfully (`exitCode: 0`) and the compressed file existing on disk, the Read/Write node couldn't find it.

**Investigation:** Traced the path value through every node in the chain rather than assuming any single node was at fault.

**Root cause:** A node reference upstream was pointing at an older, incorrect path value instead of the freshly generated compressed path.

**Solution:** Corrected the node reference so the compressed-path Code node and the Read/Write node were both looking at the same, current value.

**Result:** `Read/Write Files from Disk` successfully reads the compressed reel every time.

---

## Final pipeline shape after this session

```text
Telegram Reel
      ↓
Download reel (yt-dlp)
      ↓
Extract actual file path (Code node — last stdout line)
      ↓
FFmpeg compression (480p, 800k video / 64k audio)
      ↓
Derive compressed path (Code node)
      ↓
Read compressed file from disk
      ↓
Upload to Gemini File API
      ↓
Gemini video analysis (HTTP Request → generateContent)
      ↓
Parse structured result (Code node)
      ↓
Notion — new row created
      ↓
Delete temp video file (cleanup)
```

---

## Current status

| Component | Status |
|---|---|
| Reel download | ✅ |
| Actual file path extraction | ✅ |
| FFmpeg compression | ✅ |
| Compressed file path derivation | ✅ |
| File reading from disk | ✅ |
| Gemini upload | ✅ |
| Gemini analysis | ✅ |
| Notion storage | ✅ |
| Temporary file cleanup | ✅ |
| Fallback (caption-only) path | ✅ |
| Photo/screenshot branch | ✅ |

**🎯 Status: Reel Brain main capture pipeline — v1 complete.** End-to-end tested with real reels and photos. Remaining optional work is the Step 7 Verify & Expand feature (see `progress_update_3.md` for its design and `progress_update_5.md` for its build).