# Progress — Reel Brain

A dated changelog of what actually got built, session by session. Each entry links to the full write-up (problems hit, root causes, fixes) in `progress/`.

---

## Session 1 — Core pipeline: Telegram → yt-dlp → Gemini → Notion
**Status:** ✅ Done
Built the first working end-to-end path: a reel forwarded to Telegram gets downloaded with `yt-dlp`, uploaded to Gemini's File API, analyzed, and saved to Notion. Fixed the "Gemini can't access external URLs" blocker, the disabled `Execute Command` node, the `channel_post` vs `message` field mixup, the file-access restriction, and swapped n8n's built-in Gemini node for a direct HTTP Request call so a video file could actually be attached.
→ Full details: [`progress/progress.md`](progress/progress.md)

## Session 2 — Fallback handling, photo support, startup automation
**Status:** ✅ Done
Added a caption-only fallback branch for reels that fail to download or are private. Added a full photo/screenshot analysis branch (inline base64 to Gemini, no `yt-dlp` needed). Fixed a type-coercion bug in the IF node that was misrouting plain reel links into the photo branch. Automated the daily Cloudflare Quick Tunnel + webhook + n8n startup into one script.
→ Full details: [`progress/progress_update_2.md`](progress/progress_update_2.md)

## Session 3 — Step 7 design: why Gemini's built-in search grounding got rejected
**Status:** ✅ Design finalized
Researched using Gemini's built-in Google Search grounding for the "Verify This" feature — confirmed it requires Cloud Billing (a credit card), which breaks the project's $0/no-card requirement even though it advertises a free quota. Designed the alternative: Gemini for reasoning, Tavily for the actual free web search, capped at 6 searches per verification.
→ Full details: [`progress/progress_update_3.md`](progress/progress_update_3.md)

## Session 4 — FFmpeg compression + file-path reliability fixes
**Status:** ✅ Done — main pipeline reached v1 complete
Added FFmpeg compression (480p, 800k video / 64k audio) before uploading reel videos to Gemini, cutting upload time and API usage. Fixed a chain of file-path bugs this surfaced: reading the wrong line of `yt-dlp`'s stdout, deriving the compressed filename correctly, and a stale node reference that made `Read/Write Files from Disk` report "No file(s) found" even though the file existed.
→ Full details: [`progress/progress_update_4.md`](progress/progress_update_4.md)

## Session 5 — Step 7 built: Verify & Expand is live
**Status:** ✅ Done
Built the Tavily-based verification workflow designed in Session 3: Notion Trigger on the "Verify This" checkbox → Gemini generates 6 search queries → Tavily runs them → Gemini reaches a verdict from the evidence → result and full search log written back into the same Notion row, checkbox auto-unchecked so it doesn't re-trigger.
→ Full details: [`progress/progress_update_5.md`](progress/progress_update_5.md)

---

## Current status

Core capture pipeline (Reel + Photo → Gemini → Notion) and the optional Verify & Expand feature are both built and working end-to-end. Remaining open items: a permanent Cloudflare Named Tunnel (needs a domain), Notion review views, and a regular review habit — see the Roadmap section of `README.md`.