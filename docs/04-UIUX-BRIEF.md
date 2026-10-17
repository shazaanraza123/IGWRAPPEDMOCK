# 04 · UI/UX DESIGN BRIEF: Instagram Wrapped

> Two visual worlds live in this app:
> 1. **Instagram shell**: the real Instagram UI (home, story tray, Story viewer, tab bar, post detail). Must be indistinguishable from the real app. Match reference screenshots, not memory.
> 2. **Wrapped cards**: our design language. Match `design/screens/*.png` exactly; exact values in `design/source/*.dc.html`.
> If this file disagrees with `docs/DECISIONS.md`, DECISIONS.md wins. Eyebrows, pill labels, and the card 13 player follow DECISIONS when the HTML still shows the old Pause button.

## 1. Wrapped direction

Flat, loud Instagram-gradient color fields, one per card, ink type, and Instagram-native graphic motifs (story rings, profile grids, Explore mosaic, notification bubbles, link stickers). Not Spotify: no blobs, squiggles, checkerboards or Spotify type.

## 2. Tokens

### Colors (`DesignSystem/Tokens.swift`)

| Token | Hex | Use |
| --- | --- | --- |
| `ink` | `#0B0B0D` | Text on bright cards, dark card backgrounds |
| `paper` | `#F7F3EC` | Light cards (Feed color, Numbers card) |
| `igYellow` | `#FFD600` | Moments cards, accents on dark |
| `igOrange` | `#FF7A00` | People / Reels cards |
| `igPink` | `#FF0069` | Opening, banners, primary accent |
| `igMagenta` | `#D300C5` | Personality cards |
| `igViolet` | `#7638FA` | Algorithm card |
| `closeGreen` | `#27C866` | Broke the chat card, Close Friend mark |
| `nightNavy` | `#141B4D` | 3AM club |
| `likeRed` | `#FF3040` | Like notification bubble |
| `pinkOnDark` | `#FF5C9A` | Eyebrows on dark cards |
| `surface` | `#17171B` / `#1E1E22` | Sheets, Hub rows, segmented controls |
| `muted` | `#A1A1AA` | Secondary text on dark |

Story-ring gradient (conic, from 200°): `#FFD600 → #FF7A00 → #FF0069 → #D300C5 → #7638FA → #FFD600`.

Card background per screen: 1 pink · 2 ink · 3 paper · 4 violet · 5 orange · 6 yellow · 7 green · 8 orange · 9 navy · 10 yellow · 11 ink · 12 magenta · 13a magenta · 13b paper.

Rules: one bright field per card; text on bright fields is ink; white text only on ink, navy, violet, magenta. Body text contrast ≥ 4.5:1.

### Typography

| Style | Font | Size / line height | Weight / width | Use |
| --- | --- | --- | --- | --- |
| Hero | Archivo | 96 to 116 / 0.82 | 900, width 62% | Personality name, Plot twist |
| Display | Archivo | 46 to 72 / 0.86 | 900, width 62%, uppercase, tracking -1 | Card headlines |
| Big number | Archivo | 54 to 88 / 0.85 | 900, width 62% | Stats |
| Title | Archivo | 20 to 36 / 1.0 | 900, width 70 to 72% | Topics, categories |
| Body | Archivo | 15 to 17 / 1.3 | 600 | Supporting lines |
| Eyebrow | Archivo | 12 / 1.0 | 800, tracking 1.4, uppercase | Chapter labels |
| Caption | Archivo | 13 / 1.2 | 600 | Provenance, chips |
| IG chrome | **SF Pro (system)** | per reference | per reference | Everything in the Instagram shell |

Bundle `design/fonts/archivo-latin-wdth-normal.woff2` converted to TTF, or use Instagram Sans if available. Set width with the `wdth` variation axis (62 = condensed display).

### Spacing and layout
- Design frame 390 x 844 pt. 1 CSS px in the source files = 1 pt.
- Card side gutter 20 pt. Grids: 4 pt gaps (photo grids), 8 to 18 pt elsewhere.
- Top safe zone: progress bars at y 50, top row at y 60 to 104. Content starts at y ≥ 128.
- Bottom: primary action pill centered, 50 pt tall, bottom inset 26 pt.
- A control drawn at 36 pt (More of this, Not me, Guilty) keeps that visual height. Its hit area is 44 pt.

## 3. Instagram fidelity spec (the shell)

**Source of truth: `design/reference/instagram/` screenshots taken from the current Instagram iOS app** (checklist in that folder's README). When a measurement here disagrees with a reference screenshot, the screenshot wins. Overlay screenshots at 50% opacity in a debug view (`#if DEBUG` `ReferenceOverlay`) to check alignment.

Current Instagram layout (2025-2026 navigation redesign):
- **Tab bar** (5 items, icons only): Home, Reels, DMs (paper plane), Search, Profile (avatar). Create (+) is no longer in the tab bar.
- **Home top bar**: Create (+) top-left, Instagram wordmark, notifications heart top-right. DMs moved to the tab bar.
- **Dark mode** is the demo default.

Shell components to build (`InstagramShell/`), each matched to a reference:

| Component | Key details to match |
| --- | --- |
| `IGTopBar` | + left, wordmark asset (user supplied in `Resources/Brand`, placeholder until then), heart right with red unread dot |
| `IGStoryTray` | Your story (grey ring, blue + badge), unseen gradient ring, seen grey ring, username 12 pt truncated; Wrapped bubble uses gradient ring + pink fill + "26" |
| `IGFeedPost` | Header (avatar, username semibold, location, ...), 4:5 media, action row (heart, comment, share, save right), "Liked by ...", caption, timestamp |
| `IGTabBar` | Icon weights and selected states from reference; profile avatar with ring when selected |
| `IGStoryViewerChrome` | Segmented bars, avatar + username + time, ..., X; bottom "Send message" field, heart, paper plane; used for friend stories and the "posted Story" demo |
| `IGPostDetail` | Static detail view for card 6 |

Instagram motion to copy: Story open from tray (zoom from bubble), interactive swipe-down dismiss, cube transition between Story chapters, double-tap like heart burst, haptic on like.

Brand assets (Instagram glyph, wordmark) are supplied by the user into `Resources/Brand/` (gitignored). Never draw or recreate them in code.

## 4. Wrapped card anatomy

1. Progress bars (13 segments, 3 pt, 3 pt gap)
2. Top row: Wrapped mark (30 pt ring with "26") + "Wrapped", then (i), mute, X (44 pt targets). Cards 1 and 11 hide (i). No Pause button on any card
3. Eyebrow. This is copy from the HTML, not the chapter id. Card 9 reads "YOUR HABITS"
4. Display headline
5. Hero visual (grid, chart, photo, mark, list). A missing photo is the card 2 gradient placeholder
6. Supporting line. If the line contains a number, it is `payload.copy`, not a string built in the view
7. Provenance chip or line (Measured / Inferred + window)
8. Action pill. "Share" on cards 3, 6, and 10 (it sits beside a provenance line). "Share this story" on cards 4, 5, 7, and 9. Private lock pill on card 8. No pill on cards 1 and 2

Card 13 draws 13a full-bleed and keeps its own bottom 100 pt clear. That zone stacks the Identity/Numbers `SegmentedToggle`, the black Share pill, and the "Go to your Hub" text link. The Numbers card crossfades in. Player chrome stays above the card.

The home banner duration reads "About 2 min". The algorithm card opens with no topic selected.

## 5. Components (`DesignSystem/Components`)

`StoryProgressBars`, `WrappedTopRow`, `CardShell(background:)`, `Eyebrow`, `DisplayHeadline`, `BigNumber`, `PhotoTile` (with month chip), `SwatchStrip`, `CategoryBar`, `StickerChip` (rotated ink sticker), `LikeBubble`, `CommentBubble`, `StoryThumb` (gradient-ring frame), `ReplyBubbles` (abstract, no text), `AvatarRing`, `ClockFace`, `MonthBars`, `ClueRow`, `PersonalityMark(archetype:)`, `MatchBar`, `SharePill`, `PrivatePill`, `ProvenanceBadge`, `SegmentedToggle`, `ToggleChip`, `HubTile`, `HighlightTile`, `ToolRow`, `ShareActionButton`.

Personality marks: 8 SwiftUI `Shape`/`Canvas` drawings matching `design/screens/personality-marks.png` and the SVG in `design/source/Marks.dc.html`.

## 6. Motion

| Moment | Duration | Curve | Reduce Motion |
| --- | --- | --- | --- |
| Card enter | 450 ms | spring (response 0.45, damping 0.85) | 150 ms crossfade |
| Big number count-up | 900 ms | easeOut | final value |
| List stagger | 60 ms / item | easeOut | all at once |
| Headline | 600 ms word by word | spring | static |
| Bars / chart grow | 800 ms | easeInOut | static |
| Personality reveal | ring segments spin in 900 ms, name scales 0.8 → 1, haptic `.success` | | crossfade |
| Sheet | 280 ms | spring | 150 ms fade |

Every card has one payoff moment (number lands, name appears, photo settles).

## 7. Music

One track per chapter, 800 ms crossfade, ducks under the montage, muted by the silent switch.

These five chapters are the music and cube-swipe groups. They are not the eyebrow strings.

| Chapter | Cards | Mood |
| --- | --- | --- |
| Memories | 1-2 | Big, nostalgic build |
| Interests | 3-5 | Playful, bouncy |
| Moments | 6-7 | Warm, upbeat |
| People | 8-9 | Late-night, mellow |
| Identity | 10-13 | Drop on the reveal |

Tracks are the user's choice, stored in `Resources/Audio` (gitignored). Public video cuts use licensed or royalty-free audio.

## 8. Share templates

| Format | Pixels | Rule |
| --- | --- | --- |
| Story | 1080 x 1920 | Keep top 250 px and bottom 340 px free of key content (Instagram overlays) |
| Post | 1080 x 1350 | Recompose, don't crop |
| Square | 1080 x 1080 | Hero + headline only |

Identity card (`13a`) is the default share. It never names another person.

## 9. Voice

- Personal: playful, warm, a little roast-y, never mean. Headlines under 10 words, second person.
- Inferred things are guesses: "Your algorithm thinks you're into...", never "You are...".
- Never shame time spent or low numbers.

## 10. Screens without a PNG

Use the nearest designed pattern. Do not invent a new visual.

- S02, S03, S04, S05: ink background, card typography, Hub buttons and segmented controls.
- S09, S11, S12: share-sheet styling (`#121214` sheet, `ToggleChip`, `ToolRow`).
- S13, S14, S16: Hub rows.
- S17 web landing: the shared PNG centered on ink, one white "See yours" pill, one text link.

A later PNG for S02 or S09 replaces this section for that screen. Remix skins other than Bold wait until Step 20.

## 11. Accessibility
VoiceOver label per card (a full sentence summary), Reduce Motion, Reduce Transparency, Dynamic Type for body text, 44 pt targets, autoplay off option.
