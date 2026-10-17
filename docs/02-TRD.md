# 02 · TRD: Instagram Wrapped

> Written for the coding agent. Every MUST / MUST NOT here is a hard rule.
> If this file disagrees with `docs/DECISIONS.md`, DECISIONS.md wins.

## 1. Architecture at a glance

```text
iPhone app (SwiftUI)  ──supabase-swift──▶  Supabase (Postgres + RLS + Storage + Auth)
        │                                         ▲
        │ instagram-stories:// (Sharing to Stories)│ Edge Functions (TypeScript/Deno)
        ▼                                         │   claim-persona · build-run
   Real Instagram app                              │   _shared/engine (all metric math)
                                                   │
Web share landing (Next.js on Vercel) /s/[slug] ───┘  reads share_snapshots only
```

The app never computes numbers. The engine computes them server-side; the app decodes and renders.

## 2. Stack

| Layer | Choice | Notes |
| --- | --- | --- |
| App | Swift 6, SwiftUI, iOS 17+, iPhone only, portrait only | `@Observable` view models, async/await |
| Project file | **XcodeGen** (`ios/project.yml`) | Cursor edits `project.yml`, never hand-edits `.xcodeproj` |
| Build/run from Cursor | **SweetPad** extension or `xcodebuild` CLI | Simulator: the newest installed 6.1" non-Pro iPhone. Do not download a simulator runtime without asking. Physical device for Share to Story |
| Packages (SPM) | `supabase-swift` only | No other third-party UI libs. No Lottie. |
| Motion | SwiftUI animations, `PhaseAnimator`, `KeyframeAnimator`, `matchedGeometryEffect` | Reduce Motion fallbacks required |
| Charts | Swift Charts (plot twist bars, creator charts); custom `Shape`s elsewhere | |
| Audio | AVFoundation: one `AVAudioPlayer` per chapter, 800 ms crossfade, `.ambient` session | Silent switch mutes, like Instagram |
| Video (montage) | AVFoundation `AVPlayer`; `AVAssetWriter` export is a stretch goal | |
| Haptics | `.sensoryFeedback` on reveal moments | |
| Share images | `ImageRenderer` at 1080x1920, 1080x1350, 1080x1080 | |
| Share to Instagram | Meta "Sharing to Stories" (`instagram-stories://share?source_application=<FACEBOOK_APP_ID>` + `UIPasteboard` items) | Requires a Facebook App ID. Add `instagram-stories` to `LSApplicationQueriesSchemes`. Check Meta's current docs for pasteboard keys before coding. |
| Backend | Supabase: anonymous Auth, Postgres, RLS, Storage, Edge Functions | |
| Engine | TypeScript in `supabase/functions/_shared/engine`, Deno tests | Pure functions only |
| Share landing | Next.js App Router on Vercel, `@vercel/og` for link previews | One route: `/s/[slug]` |
| Fonts | Wrapped cards: Archivo variable (bundled, `design/fonts`) or Instagram Sans if available. Instagram chrome: **SF Pro (system)** | See UIUX brief section 2 |
| Tests | Swift Testing (view models, decoding), XCUITest (player gestures, share flow), Deno tests (engine) | |
| Distribution | TestFlight | Never App Store |

## 3. Repo layout

```text
ig-wrapped/
  .cursor/rules/            # agent rules (from this kit)
  docs/                     # these six docs
  design/                   # PNG screens, flow map, HTML source, photos, IG reference shots
  data/personas/            # maya.json + 5 more personas (Zod-validated)
  ios/
    project.yml             # XcodeGen
    IGWrapped/
      App/                  # IGWrappedApp.swift, AppRouter, Environment
      InstagramShell/       # pixel-faithful IG chrome: TopBar, StoryTray, FeedPost, TabBar, StoryViewerChrome
      Features/
        Login/  Building/  Onboarding/  EditionPicker/
        Player/             # StoryPlayer, ProgressBars, GestureLayer, ChapterAudio
        Cards/Personal/     # one View per card: OpeningCard ... ShareCards
        Cards/Creator/
        CardInfo/  Share/  Hub/  Remix/  Privacy/  Together/  Quiz/  PastYears/
      DesignSystem/         # Tokens.swift, Typography.swift, Components/, PersonalityMarks/
      Services/             # SupabaseService, StoryShareService, AudioService, ImageExportService
      Models/               # Codable contracts (below)
      Resources/            # Assets.xcassets, Fonts/, Brand/ (gitignored), Audio/ (gitignored), SamplePhotos/
    IGWrappedTests/  IGWrappedUITests/
  supabase/
    migrations/
    functions/claim-persona/  functions/build-run/  functions/_shared/engine/
    seed.ts
  web/                      # share landing
```

## 4. Core contracts (Swift)

```swift
enum Provenance: String, Codable { case measured, estimated, inferred }
enum Edition: String, Codable { case personal, creator }
enum Tier: String, Codable { case full, lite }

struct Metric: Codable, Identifiable, Hashable {
  let id: UUID
  let key: String            // "reels_sent"
  let valueNum: Double?
  let valueText: String?
  let unit: String?
  let provenance: Provenance
  let method: String         // one line, shown in the info sheet
  let windowStart: Date
  let windowEnd: Date
}

struct Card: Codable, Identifiable, Hashable {
  let id: UUID
  let code: String           // "P02"
  let type: CardType         // enum, one case per journey screen
  let sortOrder: Int         // 1...13
  let chapter: Chapter       // .memories .interests .moments .people .identity
  let payload: CardPayload   // typed enum with associated values per CardType
  let metricIds: [UUID]
  let shareable: Bool
  let teenSafe: Bool
  var hidden: Bool
}

enum CardType: String, Codable {
  case opening, yearInMemories, feedColor, yourAlgorithm, reelsRabbitHole,
       mainCharacterPost, brokeTheGroupChat, yourCircle, threeAmClub,
       plotTwist, personalityTeaser, personalityReveal, shareCards
}

struct WrappedRun: Codable, Identifiable {
  let id: UUID; let year: Int; let edition: Edition; let tier: Tier
  let status: String; let periodStart: Date; let periodEnd: Date
}
```

`CardPayload` is decoded from the `cards.payload` jsonb with a custom decoder keyed on `type`. Payload shapes per card are listed in `docs/05-BACKEND-SCHEMA.md` section 5. Every sentence that contains a number is a finished string on `payload.copy`. Views display `copy` verbatim and never interpolate a metric into a sentence.

```swift
enum Chapter: String, Codable { case memories, interests, moments, people, identity }
```

## 5. Agent rules

MUST
- Read the relevant docs and the matching `design/screens/*.png` before building any screen.
- Match the PNG layout, colors, type sizes and spacing. Exact values are in `design/source/*.dc.html` (1 CSS px = 1 pt).
- Match real Instagram chrome using `design/reference/instagram/` screenshots (UIUX brief section 3).
- Keep all metric math in `supabase/functions/_shared/engine` as pure, tested functions.
- Show provenance, window and method for every number (info sheet).
- Use `DesignSystem` tokens only. No hard-coded colors, fonts or spacing in feature views.
- Support VoiceOver, Reduce Motion, Dynamic Type on body text, 44 pt tap targets.
- Show "Concept prototype. Not affiliated with Instagram. Sample data." on login and Hub footer.
- Keep `Resources/Brand` and `Resources/Audio` out of git.
- Build in the order of `docs/06-IMPLEMENTATION-PLAN.md`; finish each step's Done-when before the next.

MUST NOT
- Fetch real Instagram data, use the Instagram Graph API, or scrape.
- Invent numbers in views. Missing metric means the card is skipped.
- Show profile visitors, DM contents, or anyone's ranking in shareable output.
- Add screens, cards or features not in the PRD.
- Copy Spotify Wrapped visuals.
- Prepare an App Store submission.

## 6. Non-functional requirements

| Area | Target |
| --- | --- |
| Cold launch to home | < 1.5 s on iPhone 12+ |
| Banner tap to first card | < 2.0 s (Building screen holds min 1.5 s) |
| Card transitions | 60 fps; 120 fps on ProMotion |
| Share image render | < 1.0 s per format |
| Accessibility | Full VoiceOver path through all 13 cards |
| Devices | iPhone SE 3 (375 pt wide) to Pro Max (440 pt); iOS 17+ |
| Offline | Cached run keeps playing; shares queue |

## 7. Configuration

```text
# ios/Config.xcconfig  (gitignored; Config.example.xcconfig committed)
SUPABASE_URL =
SUPABASE_ANON_KEY =
FACEBOOK_APP_ID =
SHARE_BASE_URL =

# supabase secrets (never in the app)
SUPABASE_SERVICE_ROLE_KEY
```

## 8. Production architecture (pitch only, not built)

Activity sources → privacy and eligibility layer → annual aggregation engine → story selection engine → constrained copy layer (templates filled with verified values) → native rendering in the Stories viewer → staged rollout with per-card kill switch.
