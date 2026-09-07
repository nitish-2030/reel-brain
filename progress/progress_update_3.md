# 🧠 Reel Brain — Progress Log (Session 3)

> **Session focus:** Step 7 (Verify & Expand) — research, blocker, and final architecture
> **Status:** 🔄 In Progress (design finalized, build starting)
> **Date:** September 2026

---

## 📌 What This Session Covers

Started building the optional **Step 7 — "Verify This"** feature: for any saved reel tagged "Verify This" in Notion, the system should fact-check the claim and produce a step-by-step guide if it's real.

Hit a real blocker around how to actually fact-check against **current, live information** — not just Gemini's static training knowledge — while staying inside the project's original $0 budget with no credit card.

---

# 🐛 The Blocker — Gemini's Built-In Search Grounding Requires Billing

## What I initially tried

Gemini API supports a built-in **Google Search grounding** tool (`google_search`) that lets the model search the live web before answering — exactly what "Verify This" needs, since reels often claim things that may be outdated or false.

## ❌ Why it didn't work for this project

Researched this properly before building anything, and confirmed:

- Google Search grounding on the Gemini API **requires Cloud Billing to be enabled** on the project — even though it advertises a monthly free quota (5,000 grounded prompts/month on Gemini 3.x models).
- Enabling billing requires a **credit card on file**, and Google may require a one-time prepayment verification to activate it.
- Without billing enabled, Gemini API rate limits are also much stricter (5–10 requests/minute) regardless of grounding.

**Bottom line:** there is no way to use Gemini's own search grounding without linking a card, even if actual usage would stay within the free quota. This directly conflicts with the project's original $0 / no-card requirement.

## Two options I considered, and rejected

| Option | Problem |
|---|---|
| **A — Gemini + Google Search grounding** | Requires billing + card, even for free-tier quota. Rejected — breaks $0/no-card constraint. |
| **B — Gemini's own training knowledge only** (no live search) | Free, no card needed — but can't verify anything time-sensitive or recent. A reel claiming "this AI tool launched last month" would get an "uncertain" answer at best, defeating the point of *verification*. |

Neither option gave a real, live fact-check without either a) requiring billing, or b) being blind to current information.

---

# ✅ The Solution — Decouple Search From Gemini

Instead of relying on Gemini's *built-in* search tool, split the job into two separate, independently free pieces:

1. **Gemini** — reasoning only: decide *what* to search for, and later, *interpret* the search results
2. **A separate, genuinely free/no-card search API** — actually perform the web searches

This is essentially building a lightweight version of what "search grounding" already does internally, but with a search provider that doesn't demand billing.

## New Architecture

```text
Notion "Verify This" ✓
         ↓
   Notion Trigger (polling)
         ↓
   Gemini: generate 3 broad search queries
         ↓
   Free Search API: run each query, collect results
         ↓
   Gemini: "Is this evidence enough to verify?"
      ├─ Yes → go to final verification
      └─ No  → generate 2-3 more queries, search again
                (capped at 6 total searches per reel)
         ↓
   Gemini: final verification using ALL collected search results
      → {verified, explanation, sources}
         ↓
   Notion: update page with result + full search query log
```

## Choosing the Search Provider

Compared the realistic free options as of September 2026:

| Provider | Free tier | Card required? | Verdict |
|---|---|---|---|
| **Tavily** | 1,000 credits/month, recurring | **No** | ✅ Chosen — built for LLM agents, no card, sustainable monthly allowance |
| Brave Search | $5 signup credit only, one-time | **Yes** | ❌ Card required even for the "free" credit; unlimited free plan was discontinued in Feb 2026 |
| Serper | 2,500 queries | No | ❌ One-time trial only, doesn't refill monthly — not sustainable for ongoing use |
| Google Custom Search JSON API | 100/day | No | ❌ Closed to new signups; shutting down entirely Jan 1, 2027 |
| SerpApi | 250/month | No | ❌ Too low for 10 reels/day × multiple searches per reel |
| Bing Search API | — | — | ❌ Discontinued August 2025 |

**Tavily won** — the only provider that's both card-free *and* offers a real recurring monthly allowance suited to this exact use case.

### Budget math (target: ~10 reels/day)

- 3 searches/reel × 10 reels/day = 30/day ≈ **900 credits/month** → fits inside Tavily's 1,000/month free tier
- If some ambiguous reels need up to 6 searches, average usage may creep slightly higher — plan is to keep the *default* at 3 and only escalate when Gemini flags insufficient evidence, keeping most reels cheap.

---

## 💡 Key Learnings From This Session

1. **"Free tier" and "no billing required" are not the same thing.** Several providers/features advertise a free quota but still require a card on file to unlock — always verify this explicitly before designing around a feature.

2. **Decoupling reasoning from search gives more control anyway.** Even setting billing aside, generating 3–6 targeted queries and controlling exactly how many searches run (with a hard cap) is more predictable and debuggable than trusting a black-box "search grounding" call.

3. **Always log the actual search queries used per verification**, not just the final answer — makes it possible to sanity-check *why* Gemini reached a verdict, and to debug if a verification looks wrong.

---

# 📊 Status

| Item | Status |
|---|---|
| Researched Gemini grounding billing requirement | ✅ Confirmed — requires card |
| Rejected training-knowledge-only approach | ✅ Insufficient for time-sensitive claims |
| Chosen search provider (Tavily) | ✅ Decided |
| New architecture designed (query-gen → search → sufficiency check → verify) | ✅ Designed |
| n8n workflow built | 🔄 In progress |
| End-to-end tested | ⏳ Not yet |

**Next step:** Build out the Tavily-based verification workflow in n8n (Notion Trigger → Gemini query generation → Tavily search loop → Gemini final verification → Notion update), test with a real reel, confirm search log and verified answer are accurate.
