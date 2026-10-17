# 05 · BACKEND SCHEMA: Instagram Wrapped

> Supabase Postgres + RLS. Persona JSON goes in, the engine writes runs, metrics and cards, and only frozen share snapshots are ever public.
> If this file disagrees with `docs/DECISIONS.md`, DECISIONS.md wins. Photo ids are the `maya.json` ids. `chapter` is one of `memories`, `interests`, `moments`, `people`, `identity`.

## 1. Data flow

1. `data/personas/*.json` is validated (Zod) and seeded into source tables by `supabase/seed.ts`.
2. App: persona tap → anonymous sign-in → `claim-persona` Edge Function copies that persona's source rows to the new user id → calls `build-run`.
3. `build-run` runs `_shared/engine` → writes `wrapped_runs`, `metrics`, `archetype_scores`, `cards`.
4. App reads `cards` + `metrics` for its own user (RLS).
5. Share → app uploads rendered PNG to Storage `shares/` and inserts `share_snapshots`. The web landing reads only that table.

## 2. Tables

| Table | Purpose | Key columns |
| --- | --- | --- |
| `profiles` | One per user | `id` (= auth uid), `handle`, `display_name`, `avatar_path`, `account_type` (personal/creator/business), `is_teen`, `persona_key` |
| `privacy_settings` | S12 toggles | `user_id`, `include_dm_stats`, `include_watch_history`, `include_saves`, `allow_together`, `ranked_circle` (default false), `hide_usernames_on_share` (default true), `autoplay` |
| `content_items` | Posts, Reels, Stories | `id`, `owner_id`, `kind`, `posted_at`, `media_path`, `caption`, `likes`, `comments`, `shares`, `saves`, `replies`, `views` |
| `daily_activity` | Per-day aggregates | `user_id`, `day`, `minutes`, `late_night_last_ts`, `stories_watched`, `stories_available`, `reels_sent`, `saves` |
| `interaction_edges` | Private ties | `user_id`, `counterpart_handle`, `likes`, `comments`, `story_replies`, `dm_sends`, `score` |
| `interest_scores` | Monthly topic interest | `user_id`, `month` (1-12), `category`, `liked`, `saved`, `reels_seconds`, `explore_score` |
| `liked_colors` | Dominant color per liked post | `user_id`, `post_ref`, `dominant_hex` |
| `wrapped_runs` | One recap per user/year/edition | `id`, `user_id`, `year`, `edition`, `period_start`, `period_end`, `tier`, `status`, `engine_version`, `generated_at` |
| `metrics` | Every number shown | `id`, `run_id`, `key`, `value_num`, `value_text`, `unit`, `provenance`, `method`, `window_start`, `window_end` |
| `archetype_scores` | Personality math | `run_id`, `archetype`, `score`, `rank`, `rationale` (jsonb: inputs used) |
| `cards` | Ordered cards | `id`, `run_id`, `code`, `type`, `chapter`, `sort_order`, `payload` (jsonb), `metric_ids` (uuid[]), `shareable`, `teen_safe`, `hidden` |
| `card_feedback` | More of this / Not me / Guilty / looks wrong | `id`, `card_id`, `user_id`, `kind`, `target`, `reason`, `created_at` |
| `consent_grants` | Together / ranked circle / named fans | `id`, `grantor_id`, `grantee_id`, `scope`, `status`, timestamps |
| `together_sessions`, `together_items` | Phase 2 | initiator, partner, approved items |
| `share_snapshots` | Frozen public share | `id`, `slug`, `card_id`, `owner_id`, `format`, `style`, `image_path`, `alt_text`, `revoked`, `created_at` |
| `share_events` | Analytics | `snapshot_id`, `destination` (story/dm/save/link), `created_at` |
| `events` | Prototype analytics | `user_id`, `name`, `props` jsonb, `created_at` |

## 3. Relationships

- `profiles` 1─* `content_items`, `daily_activity`, `interaction_edges`, `interest_scores`, `liked_colors`, `wrapped_runs`
- `wrapped_runs` 1─* `metrics`, `archetype_scores`, `cards`
- `cards` 1─* `card_feedback`, `share_snapshots`; `share_snapshots` 1─* `share_events`

## 4. Auth flow (prototype)

1. S02 persona tap → `supabase.auth.signInAnonymously()`.
2. App calls `claim-persona` `{ persona_key }` → service role copies persona rows to `auth.uid()` → calls `build-run`.
3. Session stored in Keychain by the SDK; survives relaunch.
4. Scheduled cleanup deletes claimed copies after 24 h idle.
5. `/s/[slug]` needs no session.

## 5. Card payloads (`cards.payload` jsonb) for maya

Photo ids match `data/personas/maya.json`. `copy` holds every sentence that contains a number. Views print `copy` as-is. A standalone figure plus a caption with no number stays a structured field (card 7's `47`, the like bubble, card 12's reason columns).

`wrapped_runs.copy` for maya's full run:

```jsonc
{ "window": "JAN 1 TO NOV 15, 2026", "summary": "13 cards. Replay them, remix them, share the ones you like." }
```

The summary count follows the card list (11 for a teen run, 4 for a lite run).

```jsonc
// 1 opening. Chapter memories. No info button.
{ "handle": "maya.lens", "photos": ["tile-1","tile-2","tile-3","tile-4","tile-5"], "windowLabel": "Jan 1 to Nov 15",
  "copy": { "headline": "2026 looked good on you.", "support": "Built from your own posts and Stories, Jan 1 to Nov 15." } }
// 2 yearInMemories. Chapter memories.
{ "months": [{ "month": 1, "photo": "m-01" }, /* m-02 through m-11 */], "topMonth": 8, "topMonthPosts": 9, "topMonthStories": 61, "montageSeconds": 15,
  "copy": { "support": "August was your busiest month: 9 posts, 61 Stories.", "playLabel": "PLAY YOUR YEAR · 0:15",
    "hubHighlight": "11 months", "hubDetail": "Play the 15-second recap" } }
// 3 feedColor. Chapter interests.
{ "paletteName": "Midnight Camel", "likedPosts": 1840, "swatches": [
  { "hex": "#1F2A44", "pct": 31 }, { "hex": "#C8A27C", "pct": 24 }, { "hex": "#8B3A3A", "pct": 19 },
  { "hex": "#E9E1D3", "pct": 15 }, { "hex": "#4E6B4A", "pct": 11 } ],
  "copy": { "footnote": "% = main color in each of 1,840 liked posts" } }
// 4 yourAlgorithm. Chapter interests. Opens with nothing selected.
{ "topics": [ { "name": "Streetwear drops" }, { "name": "Film cameras" },
  { "name": "Ceramic frogs", "isUndercut": true, "watched": 63 } ],
  "copy": { "undercut": "63 watched. No judgment." } }
// 5 reelsRabbitHole. Chapter interests. Percents are the top 5 and sum to 92.
{ "categories": [ ["Streetwear",31], ["Food in Chicago",22], ["Film photography",18], ["Interior design",12], ["Ceramics",9] ],
  "fastestRising": { "name": "Ceramics", "multiple": 4, "since": "June" }, "reelsSent": 1206,
  "copy": { "fastestRising": "Ceramics, 4x since June", "sent": "And you sent 1,206 of them to friends.", "hubDetail": "4x since June" } }
// 6 mainCharacterPost. Chapter moments.
{ "postId": "post_0719", "photo": "main-character", "likes": 2184, "comments": 418, "vsAverage": 3, "postedAt": "2026-07-19",
  "copy": { "comments": "418 comments. Unhinged ones.", "average": "That's 3x your average post.",
    "posted": "Measured · posted Jul 19", "dateChip": "Jul 19",
    "hubHighlight": "2,184 likes", "hubDetail": "Jul 19, 3x your average" } }
// 7 brokeTheGroupChat. Chapter moments. 47 is a figure, not part of a sentence.
{ "storyId": "story_0314", "photo": "story-0314", "replies": 47, "windowHours": 24, "postedAt": "2026-03-14",
  "copy": { "storyChip": "Story · Mar 14" } }
// 8 yourCircle. Chapter people. Private. Alphabetical, never ranked.
{ "handles": ["dee.films","jules.mp","nico_k","sam.wav","tori.eats"] }
// 9 threeAmClub. Chapter people. teenSafe=false. Eyebrow stays "YOUR HABITS".
{ "latestLocalTime": "03:42", "weekday": "Tuesday", "month": "May",
  "copy": { "headline": "Welcome to the 3AM club.", "time": "3:42 AM" } }
// 10 plotTwist. Chapter identity. The sentence has no digit, so it stays on `sentence`.
{ "sentence": "In June you fell into ceramics and never climbed out.", "category": "Ceramics",
  "monthly": [3,2,4,3,5,22,41,58,64,71,80], "turnMonth": 6 }
// 11 personalityTeaser. Chapter identity. No info button.
{ "copy": { "clues": ["You saved 1,214 posts", "You posted 38 times all year", "You watched 96% of friends’ Stories"] } }
// 12 personalityReveal. Chapter identity. Reason columns stay value + label.
{ "primary": "curator", "primaryScore": 70, "secondary": "ghost", "secondaryScore": 30,
  "reasons": [ ["1,214","posts saved"], ["38","posts all year"], ["96%","of friends’ Stories watched"] ],
  "copy": { "primaryMatch": "70% Curator match", "secondaryMatch": "30% Ghost match" } }
// 13 shareCards. Chapter identity.
{ "identity": { "archetype": "curator", "stat": ["1,214","posts saved"] },
  "numbers": { "photo": "year-card", "stats": [["412","Stories"],["38","Posts"],["1,206","Reels sent"],["1,214","Saves"]], "topInterest": "Streetwear" },
  "copy": { "identityYear": "MY 2026", "numbersTitle": "2026 in numbers" } }
```

Canonical maya numbers (must match everywhere): 38 posts, 412 Stories, 1,206 Reels sent, 1,214 saves, 301 days active, 1,840 liked posts, 96% friends’ Stories watched.

The card 6 comments template is `"{comments} comments. Unhinged ones."`. For maya that renders the `copy.comments` string above.

## 6. Engine (`supabase/functions/_shared/engine`)

Pure functions, Deno-tested:
- `computeMetrics(source, window) → Metric[]` (every metric has provenance + method)
- `scoreArchetypes(metrics) → ArchetypeScore[]` (normalized 0-100, top two returned, rationale lists inputs)
- `selectCards(metrics, scores, profile, privacy) → Card[]` (skip-if-missing, teen filter, lite tier, undercut rule for topic 3, ordering 1-13, five chapters)
- `renderCopy(card, metrics) → copy object` (templates filled with verified values; this is the only place a number is written into a sentence)
- `paletteName(swatches)` from a fixed lookup table (no AI)

Circle handles are sorted alphabetically before they are written to the payload. The category-share metric's method is exactly: "Top 5 categories by share of your Reels watch time. Other categories: 8%." There is no Other row on the card.

## 7. Row Level Security

| Table | Policy |
| --- | --- |
| Source tables, `wrapped_runs`, `metrics`, `cards`, `archetype_scores`, `privacy_settings` | Owner only (`user_id = auth.uid()` or run owner) |
| `cards` update | Owner may update `hidden` only |
| `metrics`, `cards` insert | Service role (engine) only |
| `card_feedback` | Owner insert/select |
| `share_snapshots` | Public select where `revoked = false`; owner insert/update |
| `consent_grants` | Grantor or grantee select; grantee updates status |

## 8. Core migration (excerpt)

```sql
create type edition as enum ('personal','creator');
create type provenance as enum ('measured','estimated','inferred');

create table profiles (
  id uuid primary key references auth.users on delete cascade,
  handle text unique not null, display_name text, avatar_path text,
  account_type text not null check (account_type in ('personal','creator','business')),
  is_teen boolean not null default false, persona_key text);

create table wrapped_runs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles on delete cascade,
  year int not null, edition edition not null,
  period_start date not null, period_end date not null,
  tier text not null default 'full' check (tier in ('full','lite')),
  status text not null default 'pending' check (status in ('pending','ready','failed')),
  engine_version text not null, generated_at timestamptz,
  copy jsonb not null default '{}',
  unique (user_id, year, edition));

create table metrics (
  id uuid primary key default gen_random_uuid(),
  run_id uuid not null references wrapped_runs on delete cascade,
  key text not null, value_num numeric, value_text text, unit text,
  provenance provenance not null, method text not null,
  window_start date not null, window_end date not null);

create table cards (
  id uuid primary key default gen_random_uuid(),
  run_id uuid not null references wrapped_runs on delete cascade,
  code text not null, type text not null,
  chapter text not null check (chapter in ('memories','interests','moments','people','identity')),
  sort_order int not null, payload jsonb not null default '{}',
  metric_ids uuid[] not null default '{}',
  shareable boolean not null default true, teen_safe boolean not null default true,
  hidden boolean not null default false);

create table share_snapshots (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null, card_id uuid not null references cards on delete cascade,
  owner_id uuid not null references profiles on delete cascade,
  format text not null check (format in ('story','post','square')),
  style text not null default 'bold', image_path text not null, alt_text text not null,
  revoked boolean not null default false, created_at timestamptz not null default now());

alter table wrapped_runs enable row level security;
create policy own_runs on wrapped_runs for select using (user_id = auth.uid());
alter table share_snapshots enable row level security;
create policy public_snapshots on share_snapshots for select using (revoked = false);
create policy own_snapshots on share_snapshots for all using (owner_id = auth.uid());
```

Remaining tables follow the same pattern: owner-only by default, public only through `share_snapshots`.
