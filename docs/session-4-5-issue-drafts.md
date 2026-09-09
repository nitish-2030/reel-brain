# Issue Drafts — Sessions 4 & 5

Copy each block below into GitHub's "New Issue" form (title, then body). Suggested labels are noted per issue — create them first under **Issues → Labels** if they don't exist yet (`automation`, `bug`, `enhancement`).

When you commit the related work, reference the issue number to auto-close it, e.g. `git commit -m "feat: add ffmpeg compression + fix file-path bugs (Closes #6)"`.

---

## Issue 1

**Title:** `Compress reel video before Gemini upload + fix file-path bugs`

**Labels:** `automation`, `bug`

**Body:**

```markdown
## Goal
Reduce upload time and Gemini API usage by compressing downloaded reel
videos before sending them to Gemini's File API.

## Tasks
- [x] Add an FFmpeg `Execute Command` step: scale to 480p, video bitrate
      800k, audio bitrate 64k
- [x] Fix: `Read/Write Files from Disk` was picking up the wrong line of
      `yt-dlp`'s stdout — extract the actual file path from the last
      non-empty line instead
- [x] Fix: derive the compressed file path (`original_c.mp4`) from the
      original path reliably, instead of guessing it downstream
- [x] Fix: "No file(s) found" error in `Read/Write Files from Disk` —
      traced to a stale node reference upstream, not a real missing file
- [x] Confirm end-to-end: forward a reel, confirm the compressed file is
      what actually reaches Gemini, confirm Notion still gets a correct
      summary

## Result
Main pipeline reaches v1 complete. Full write-up in
`progress/progress_update_4.md`.
```

---

## Issue 2

**Title:** `Build Step 7 — "Verify This" fact-checking feature`

**Labels:** `enhancement`

**Body:**

```markdown
## Goal
For any saved reel tagged "Verify This" in Notion, automatically check
whether its claim is currently true and achievable using real web
search evidence (not just the model's static training knowledge), and
write a step-by-step guide + source list back into the same row.

## Design constraint
Must stay inside the project's $0 / no-credit-card budget. Gemini's
built-in Google Search grounding requires Cloud Billing (a card on
file) even for its free quota — rejected. See
`docs/step7-verify-architecture.md` for the full comparison.

## Tasks
- [x] Research and reject Gemini's built-in search grounding (billing
      requirement confirmed)
- [x] Compare free search API providers, choose Tavily (no card,
      1,000 credits/month recurring)
- [x] Design architecture: Notion Trigger -> Gemini query generation ->
      Tavily search -> Gemini verdict -> Notion update
- [x] Build the workflow in n8n (`workflows/reel-brain-verify-and-expand.json`)
- [x] Test end-to-end with a real "Verify This" tick — confirm
      `Verified Solution` and `Search Log` populate and the checkbox
      auto-unchecks

## Result
Feature built and working. Full write-up in
`progress/progress_update_5.md`. Design record in
`docs/step7-verify-architecture.md`.

## Follow-ups (not blocking, separate issues if picked up later)
- Add an explicit IF check for `Verify This === true` right after the
  Notion Trigger, instead of relying on the checkbox-uncheck side
  effect to prevent re-triggers
- Add the adaptive "3 queries, escalate to 6 if insufficient" loop from
  the original design if Tavily usage ever gets close to the free tier
  limit (currently fixed at 6 queries per verification)
```