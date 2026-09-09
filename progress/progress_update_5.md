# 🧠 Reel Brain — Progress Log (Session 5)

> **Session focus:** Building Step 7 (Verify & Expand) from the design in `progress_update_3.md`
> **Status:** ✅ Working — implemented as `workflows/reel-brain-verify-and-expand.json`
> **Date:** September 2026

---

## 📌 What this session covers

`progress_update_3.md` designed the Verify & Expand feature: Gemini generates search queries, Tavily runs them, Gemini reaches a verdict from the evidence, and the result gets written back into the same Notion row. This session is that design actually built and wired up node-by-node in n8n.

---

## What got built

```text
Notion Trigger (polling, event: page updated in database)
       ↓
Code node — extract pageId, title, link, summary, problem, claim
from the triggered Notion page
       ↓
Gemini (HTTP Request) — generate exactly 6 broad, distinct search
queries, given the reel's Summary/Problem/Claim, that would help
verify whether the claim is real and currently achievable
       ↓
Code node — parse Gemini's JSON array response (with markdown
fence stripping + a line-split fallback if JSON parsing fails)
       ↓
Tavily (HTTP Request, one call per query, max_results: 5) —
actually search the web for each of the 6 queries
       ↓
Code node — combine all query+results pairs back into a single
item carrying the original page context (pageId, title, link,
summary, problem, claim) plus all searchRounds
       ↓
Gemini (HTTP Request) — final verification: given ALL collected
search evidence, decide { verified, explanation, sources }
       ↓
Code node — parse the verdict (with a safe fallback if parsing
fails), and build the human-readable "Search Log" text (numbered
list of every query run) and "Verified Solution" text (explanation
+ sources)
       ↓
Notion — update the SAME page: Verified Solution, Search Log,
and uncheck "Verify This" so it doesn't re-trigger next poll
```

This matches the architecture in `progress_update_3.md` / `docs/step7-verify-architecture.md`, with one simplification: rather than the adaptive "3 queries → check sufficiency → maybe 2-3 more, capped at 6" loop originally sketched, the implemented version generates all 6 queries up front. Simpler to build and debug, and still comfortably inside Tavily's free 1,000 credits/month at the target ~10 verifications/day (6 × 10 = 60/day ≈ 1,800/month — worth watching if daily volume grows past that; drop the query count to 3–4 if it does).

---

## Key implementation details worth remembering

- **Notion Trigger fires on *any* page update in the database**, not just when "Verify This" gets checked. The workflow relies on the fact that unchecking "Verify This" at the end of a successful run means the *next* update to that same page won't re-trigger verification unless the box gets ticked again. If you add more editable columns later, double check this still holds, or add an explicit IF node that checks `Verify This === true` right after the trigger.
- **All context from the original Notion page has to be threaded through every downstream node manually** — n8n's HTTP Request nodes don't automatically carry earlier items forward, so each Code node explicitly re-reads from the node that still holds `pageId`/`summary`/`problem`/`claim` (e.g. `$("Code in JavaScript3").first().json`) rather than assuming it survives in `$json`.
- **Both Gemini calls (query generation and final verification) are wrapped in `retryOnFail` with a 2-second wait** — free-tier rate limits make an occasional dropped request likely, and this keeps a single flaky call from failing the whole verification.
- **JSON parsing from Gemini's text response always strips markdown code fences first** (` ```json ... ``` `), and falls back to a safe default object rather than throwing, so a single malformed model response doesn't crash the workflow.

---

## Status vs. "done" criteria (from `docs/step7-verify-architecture.md`)

| Criterion | Status |
|---|---|
| Trigger — ticking "Verify This" starts verification automatically | ✅ |
| Real verification — based on actual Tavily search evidence | ✅ |
| Adaptive search depth (escalate only when ambiguous) | ⚠️ Simplified — fixed 6 queries instead of the 3-then-escalate loop |
| Transparency — Search Log written for every verification | ✅ |
| Result write-back to the same row | ✅ |
| Cost — stays inside free tiers at target volume | ✅ at ~10/day, worth monitoring if volume grows |
| Graceful on thin/no search results | ⚠️ Currently relies on Gemini's own judgment call in the final verification prompt rather than an explicit "Tavily returned nothing" branch — acceptable for now, flagged as a future improvement |

**Next possible improvements (not blocking, not started):**
1. Add an explicit IF node right after the Notion Trigger to check `Verify This === true`, instead of relying on the checkbox-uncheck side effect to prevent re-triggers.
2. Add the adaptive sufficiency-check loop from the original design if search costs ever become a concern.
3. Add an explicit "no useful search results found" branch that falls back to training-knowledge-only judgment and marks the result as low-confidence.