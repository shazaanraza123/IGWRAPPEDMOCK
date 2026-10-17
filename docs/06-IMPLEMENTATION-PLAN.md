# 06 · IMPLEMENTATION PLAN: Instagram Wrapped

> One step at a time. Do not start a step until the previous step's **Done when** passes. Commit after every step with message `step N: <title>`.
> After each step, post a short report: what was built, how Done-when was verified, screenshots for any UI step, open questions.
> If this file disagrees with `docs/DECISIONS.md`, DECISIONS.md wins.

## Phase A: foundation

| # | Step | Build | Done when |
| --- | --- | --- | --- |
| 0 | Repo + tooling | Monorepo layout from TRD §3. `ios/project.yml` (XcodeGen), SPM `supabase-swift`, `Config.example.xcconfig`, `.gitignore` (Brand, Audio, Config.xcconfig). Supabase project + CLI. `web/` Next.js stub. | `xcodegen generate` + build succeeds; app launches to a blank screen on the newest installed 6.1" non-Pro iPhone simulator (do not download a runtime); `supabase start` runs. If Docker is not installed, stop |
| 1 | Design system | `Tokens.swift`, `Typography.swift` (Archivo variable with `wdth` axis + SF Pro for shell), all components in UIUX §5 as stubs, `#if DEBUG` Styleguide screen and `ReferenceOverlay` | Styleguide shows every token, type style and component |
| 2 | Personas | `data/personas/*.json` for maya (provided), ghost, connector, emerging, established, teen. Zod schema `data/schema.ts` | All validate; maya totals equal the canonical numbers in SCHEMA §5 |
| 3 | Schema + seed | Migrations, RLS, `seed.ts` | `supabase db reset` builds everything; RLS test: user A cannot read user B's runs |
| 4 | Engine: metrics | `computeMetrics` with provenance/method | Deno tests cover every metric used by the 13 cards |
| 5 | Engine: cards | `scoreArchetypes`, `selectCards`, `renderCopy`, lite tier, teen filter, undercut rule, alphabetical circle, `build-run` function | maya → exactly the 13 cards with payloads equal to SCHEMA §5, including `copy`; teen → 11 cards; ghost → lite tier |
| 6 | Auth | S02 persona picker, anonymous sign-in, `claim-persona` | Pick maya → run ready; relaunch keeps session |

## Phase B: Instagram shell (fidelity first)

| # | Step | Build | Done when |
| --- | --- | --- | --- |
| 7 | IG home | `IGTopBar`, `IGStoryTray` (with Wrapped bubble), `IGFeedPost`, `IGTabBar` (Home, Reels, DMs, Search, Profile), placeholder tab screens | Stop if `design/reference/instagram/01-home.png` is missing. Otherwise side by side via ReferenceOverlay, misalignment under 2 pt on the Step 0 simulator |
| 8 | IG Story viewer chrome | `IGStoryViewerChrome`, friend fake stories, open-from-tray zoom, swipe-down dismiss | Opening a friend bubble feels identical to Instagram (compare with reference video/screens) |

## Phase C: Wrapped core

| # | Step | Build | Done when |
| --- | --- | --- | --- |
| 9 | Story player | `StoryPlayer`: progress bars, tap zones (left 1/3 back), hold to pause + hide chrome, swipe down dismiss, chapter cube transition, autoplay, VoiceOver, Reduce Motion, `AudioService` chapter music | XCUITest covers every gesture in APPFLOW §2; music follows chapters and respects silent switch |
| 10 | Cards 1-4 | Opening, Year in memories (+ montage stub), Feed color, Your algorithm (feedback saves) | Each matches its PNG via ReferenceOverlay (`design/screens`); feedback rows written |
| 11 | Cards 5-9 | Reels rabbit hole, Main character, Broke the chat, Your circle (private, no share), 3AM club | Match PNGs; teen persona skips 8 and 9 |
| 12 | Cards 10-13 | Plot twist, Teaser (Reveal disables autoplay, no info button), Personality reveal (8 marks implemented), Identity card full-bleed with the toggle, Share pill, and Hub link in the bottom 100 pt | Match PNGs incl. `personality-marks.png`; reveal haptic fires; toggle crossfades to the Numbers card |
| 13 | Entry flow | S03 Building, S04 Before we start, S05 Edition picker, banner + tray entry from S01 | Banner → card 1 in < 2 s; pro persona sees picker |
| 14 | Card info sheet | S09 provenance, window, method, looks wrong, hide | Every card opens a correct sheet; hidden card disappears everywhere |

## Phase D: share loop (the pitch)

| # | Step | Build | Done when |
| --- | --- | --- | --- |
| 15 | Share rendering | `ImageRenderer` for 3 formats x 4 styles; Show-on-card toggles | Exported 1080x1920 PNG respects Story safe zones; numbers identical across styles |
| 16 | Share sheet + Sharing to Stories | S10, real `instagram-stories://` handoff, Save to Photos, Send, Copy link, `share_snapshots` upload | **On a physical iPhone, a Wrapped card opens in the real Instagram Story composer** |
| 17 | Web landing | `web/` `/s/[slug]` + OG image + See yours | Link opens on a logged-out phone showing only the snapshot |

## Phase E: Hub, privacy, polish

| # | Step | Build | Done when |
| --- | --- | --- | --- |
| 18 | Hub | S08 highlights, all 13, tools, data window | Matches `S08-wrapped-hub.png` |
| 19 | Privacy | S12 toggles re-run `build-run`, delete, teen rules | DM toggle off removes DM-derived values; delete wipes run |
| 20 | Remix | S11 four styles as theme layers | Style switch never changes a number |
| 21 | Quality pass | Perf (TRD §6), VoiceOver audit, empty/offline states, copy review | All targets met; every APPFLOW §4 state exists |
| 22 | Creator edition | PRD §9 | Both creator personas play end to end |
| 23 | Phase 2 | Together, Guess My Wrapped | Joint card only after both approve; disappears on revoke |
| 24 | Pitch package | 60-90 s screen recording (banner → share → See yours in one take), TestFlight build | Recording done with licensed/royalty-free audio |

## Cut order if time is short
Remix (20) → Creator (22) → Phase 2 (23). Never cut: the shell fidelity (7-8), the player (9), card 12-13, or the share loop (15-17).
