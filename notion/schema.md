# Notion Database Schema — "Reel Brain"

This is the exact schema the workflows in `workflows/` read and write. Create a Notion database with these columns before importing the workflows (names and types must match exactly — n8n's Notion node maps to them by name).

| Column name | Type | Set by | Purpose |
|---|---|---|---|
| **Title** | Title (default) | Main pipeline | The reel/photo caption, or the reel link if there's no caption |
| **Summary** | Rich text | Main pipeline | Gemini's summary of the actual video/image/caption content |
| **Tags** | Multi-select | Main pipeline | 3–5 tags Gemini generates for search/filter |
| **Link** | URL | Main pipeline (reels only) | The original Instagram link |
| **Date Saved** | Date | Main pipeline | Date the entry was created |
| **Type** | Select — options: `Reel`, `Image`, `Other` | Main pipeline | What kind of content this was |
| **Problem** | Rich text | Main pipeline | What need/problem Gemini thinks this content addresses |
| **Claim** | Rich text | Main pipeline | A specific, checkable factual claim Gemini extracted (exact tool/brand/number/instruction), or empty if none |
| **Verify This** | Checkbox | You (manually) | Tick this on any saved page to trigger Step 7. The verify workflow automatically **unchecks** it when done, so it won't re-trigger on the next poll |
| **Verified Solution** | Rich text | Verify & Expand workflow | Final verdict + step-by-step guide + sources, written back into the same row |
| **Search Log** | Rich text | Verify & Expand workflow | Every search query actually run for that verification (for auditing/debugging — never trust the verdict blindly) |

## Setting it up in Notion

1. Create a new database (Table view is easiest) with the columns above.
2. Go to **Settings → Connections** (or the `···` menu on the database) and create/select an internal integration, then connect this specific database to it.
3. Copy the integration token — this is the value the `notionApi` credential in n8n needs.
4. Get the database ID from the database URL: `https://www.notion.so/<workspace>/<DATABASE_ID>?v=...` — the 32-character ID right after your workspace name.
5. Paste that ID into the `dataSourceId.value` field of both imported workflows (see `workflows/README.md`).

## Notes

- `Verify This`, `Verified Solution`, and `Search Log` are only needed if you're using the optional Step 7 workflow (`reel-brain-verify-and-expand.json`). The core capture pipeline works without them.
- Keep `Type`'s options exactly as `Reel` / `Image` / `Other` (case-sensitive) — the workflows write these literal strings.