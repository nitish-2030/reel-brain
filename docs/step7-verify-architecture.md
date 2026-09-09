# Step 7 — Verify & Expand: Architecture & Design Decisions

This is the design record for the optional "Verify This" feature. The actual working workflow is `workflows/reel-brain-verify-and-expand.json`; this file explains **why** it's built the way it is, including the two approaches that were tried and rejected.

## What Step 7 does

For any reel already saved in Notion, ticking the **Verify This** checkbox on that page automatically:

1. Takes that reel's saved Summary (and Link, if present).
2. Determines whether the claim made in the reel is currently true and actually possible, using real, current web information — not just an AI model's static training knowledge.
3. If accurate: produces a clear, complete step-by-step guide (tools, costs, prerequisites).
4. If false/outdated/misleading: says so clearly and explains why, with reference to what was found.
5. Writes the result back into the **same** Notion row, in a new **Verified Solution** column.
6. Also logs every search query used, in a new **Search Log** column, so the verdict is never a black box.

## What was tried and rejected

### Option A — Gemini's built-in Google Search grounding

Gemini's API has a built-in `google_search` tool that lets the model search the live web before answering — the obvious fit for fact-checking.

**Rejected because:** Google Search grounding on the Gemini API requires Cloud Billing to be enabled on the project, even though it advertises a free monthly quota (e.g. 5,000 grounded prompts/month on Gemini 3.x models). Enabling billing requires a credit card on file, and Google may require a one-time prepayment to activate it. That breaks the project's hard $0 / no-credit-card requirement, even if actual usage would stay within the "free" quota. Without billing enabled at all, Gemini's normal rate limits are also much stricter regardless of grounding.

### Option B — Gemini's own training knowledge only (no live search)

The simplest fallback: just ask Gemini to judge the claim using whatever it already knows, with no external search.

**Rejected as the primary approach because:** this can't verify anything time-sensitive or recent. A reel claiming "this new AI tool just launched" or "this trick works as of this month" would get an "uncertain" answer at best from a model with a training cutoff — which defeats the point of a *verification* feature. It remains a fallback if search fails (see "Graceful, not brittle" below).

## The chosen approach — decouple search from Gemini

Split the job into two independent, genuinely free pieces:

1. **Gemini — reasoning only.** Decides *what* to search for (generates search queries), and later, *interprets* the search results and reaches a verdict. Gemini itself never searches the web directly in this design.
2. **A separate free search API — does the actual web searching.** Chosen provider: **Tavily**.

This effectively rebuilds what "search grounding" does internally, but swaps in a search provider that doesn't demand a credit card.

### Why Tavily

Compared against the realistic free search API options (as of September 2026):

| Provider | Free tier | Card required? | Verdict |
|---|---|---|---|
| **Tavily** | 1,000 credits/month, recurring | No | **Chosen** — built for LLM agents, sustainable |
| Brave Search | $5 signup credit, one-time | Yes | Rejected — card required even for the "free" credit |
| Serper | 2,500 queries, one-time | No | Rejected — doesn't refill monthly, not sustainable |
| Google Custom Search JSON API | 100/day | No | Rejected — closed to new signups, shutting down Jan 2027 |
| SerpApi | 250/month | No | Rejected — too low for target daily usage |
| Bing Search API | (discontinued) | – | Rejected — API discontinued Aug 2025 |

Tavily is the only option that is both card-free **and** offers a real, recurring monthly allowance suited to this use case.

### Budget math (target: ~10 reels/day verified)

- Default: 3 searches per reel × 10 reels/day ≈ 900 credits/month → fits inside Tavily's 1,000/month free tier.
- Some ambiguous reels may need up to 6 searches (see loop logic below), so average usage may creep slightly higher if many reels are ambiguous — monitor via the Tavily dashboard.
- The design keeps the default at 3 searches, only escalating when Gemini itself flags the evidence as insufficient — most reels stay cheap.

## Final architecture

```text
Notion "Verify This" checkbox ticked
             │
             ▼
    Notion Trigger (polling every 1-10 min)
             │
             ▼
    Code node: extract Summary + Link + Page ID
             │
             ▼
    Gemini (HTTP Request): generate exactly 3-6 broad,
    distinct search queries that would help verify the claim
             │
             ▼
    Loop: run each query against Tavily's search API,
    collect all results (query + results pairs)
             │
             ▼
    Gemini (HTTP Request): final verification using ALL
    collected search results
    → outputs { verified: true/false, explanation: "...",
                 sources: ["url1", "url2", ...] }
             │
             ▼
    Notion: update the SAME page (not a new row)
      - "Verified Solution" ← explanation + sources
      - "Search Log"        ← all queries used + count
      - "Verify This"       ← unchecked, so it doesn't re-trigger
```

The implemented workflow (`workflows/reel-brain-verify-and-expand.json`) generates 6 queries up front rather than the adaptive 3-then-escalate loop originally sketched here — a simpler, still-cheap-enough default that avoids an extra "is this evidence sufficient?" round trip. If you want the adaptive version, add an IF node after the Tavily search step that checks Gemini's own confidence and only branches into 2-3 more queries when it's low, capped at 6 total.

## What "done" looks like

1. **Trigger** — ticking "Verify This" on any saved reel starts verification automatically within one polling cycle, with zero other manual steps.
2. **Real verification** — based on actual current web search evidence (via Tavily), not just Gemini's static training knowledge.
3. **Transparency** — every verification produces a visible "Search Log" in Notion showing exactly which queries were run.
4. **Result write-back** — the final verdict, explanation, and sources are written into the same Notion row, not a separate table.
5. **Cost** — stays within Tavily's free 1,000 credits/month at ~10 verifications/day, and Gemini stays on its existing free tier.
6. **Graceful, not brittle** — if Tavily returns no useful results (obscure or non-English content), still produce a best-effort answer from whatever evidence was found, falling back toward Option B's behavior only as a last resort, and note low confidence in "Verified Solution" if that happens.

## Key learnings from this design process

1. **"Free tier" and "no billing required" are not the same thing.** Several providers advertise a free quota but still require a card on file to unlock it — always verify this explicitly before designing around a feature.
2. **Decoupling reasoning from search gives more control anyway.** Generating targeted queries and capping exactly how many searches run is more predictable and debuggable than trusting a black-box "search grounding" call.
3. **Always log the actual search queries used**, not just the final answer — makes it possible to sanity-check *why* a verdict was reached, and to debug a verification that looks wrong.