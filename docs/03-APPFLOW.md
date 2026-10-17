# 03 · APPFLOW: Instagram Wrapped

> Every screen and what every tap does. Screen IDs (S01...) are used in code names, tests and docs.
> Visual map: `design/app-flow-map.png`. The "Push / profile menu" box on that image is out of scope.
> If this file disagrees with `docs/DECISIONS.md`, DECISIONS.md wins.
> Navigation in this file wins over any `href` in `design/source/*.dc.html`.

## 1. Navigation map

```text
S01 Home (IG shell) ──banner / tray bubble──▶ S02 Persona login (prototype only)
   ──▶ S03 Building your year ──▶ S04 Before we start ──(pro accounts)──▶ S05 Edition picker
   ──▶ S07 Story player: cards 1..13 ──▶ S08 Wrapped Hub
S07/S08 ──share──▶ S10 Share sheet ──Add to Story──▶ real Instagram Story composer
Friend's Story ──"See yours" link──▶ S17 Web landing ──▶ S01/S02
S08 ──▶ S11 Remix · S12 Privacy · S13 Together · S14 Guess My Wrapped · S16 Past years
S07 (i) ──▶ S09 Card info sheet
```

## 2. Story player gestures (must feel identical to Instagram Stories)

| Input | Action |
| --- | --- |
| Tap left 1/3 of screen | Previous card (on card 1: restart card) |
| Tap right 2/3 of screen | Next card |
| Press and hold | Pause timer, music and animation; hide chrome (progress bars and top row fade out). Release resumes |
| Swipe down | Interactive dismiss: card scales down with finger, release past threshold exits to S08 Hub (progress saved) |
| Swipe left / right | Jump to next / previous **chapter** with Instagram's cube transition (chapters: Memories 1-2, Interests 3-5, Moments 6-7, People 8-9, Identity 10-13) |
| Swipe up | Open S09 card info sheet |
| Autoplay | Card advances after its duration (6 s default, 9 s for cards 2, 10, 12) unless autoplay is off in S12 |
| VoiceOver | Swipe right/left = next/prev card; two-finger double tap = pause; escape gesture = exit |

Progress bars: 13 segments, current one fills over the card duration.

## 3. Screens

### S01 Home (Instagram shell)
Pixel-faithful Instagram home. Design: `design/screens/00-home-entry.png` + real IG reference shots.

| Element | Action | Goes to |
| --- | --- | --- |
| Top-left **+** (Create) | Non-functional in prototype; toast "Not part of this demo" | Same |
| Top-right heart | Non-functional; toast | Same |
| Story tray "Your story" | Non-functional | Same |
| Story tray **Wrapped** bubble (gradient ring, "26") | Open Wrapped | S02 (first launch) else S03 |
| Friend story bubbles | Open a static fake Story (1 image) in IG Story viewer chrome, swipe down to close | Fake story |
| Wrapped banner (pink card). Copy: "Your 2026 Wrapped is here", "Open your Wrapped", "About 2 min" | Open Wrapped | S02 / S03 |
| Banner X | Hide banner for session; Wrapped still in tray | Same |
| Feed post | Scrolls; like double-tap animates heart (static data) | Same |
| Tab bar: Home, Reels, DMs, Search, Profile | Home active; others show a static placeholder screen with the IG tab bar | Placeholder |

### S02 Persona login (prototype only)
| Element | Action | Goes to |
| --- | --- | --- |
| Concept label | Static: "Concept prototype. Not affiliated with Instagram. Sample data." | n/a |
| Persona cards (6) | Anonymous sign-in, claim persona | S03 |
| "What is this?" | Sheet with project context | Sheet |

### S03 Building your year
Animated story ring fills (min 1.5 s). Ready → S04 (first time) or S07 resume. Lite tier → shows "A lighter recap this year" then S04. Failed → "We couldn't build your Wrapped" + Try again.

### S04 Before we start
| Element | Action | Goes to |
| --- | --- | --- |
| Start | Begin | S05 if professional account, else S07 |
| Choose what's included | Privacy controls, then back | S12 → S04 |
| How Wrapped works | Sheet: data window, what's never included | Sheet |

### S05 Edition picker (professional accounts)
Personal → S07 personal. Creator → S07 creator. Watch both → personal then creator queued.

### S07 Story player: per-card interactions

Top row on every card: Wrapped mark + "Wrapped", then (i), mute, close (X). Close → S08. Cards 1 and 11 have no metrics, so (i) is hidden and the row is mute and X. There is no Pause button. Pause is press-and-hold only.

Bottom pill: "Share" beside a provenance line (cards 3, 6, 10). "Share this story" when the pill stands alone (cards 4, 5, 7, 9). Card 8 uses the private lock pill and has no share. Cards 1 and 2 have no pill. Those two cards are still shareable from the Hub tile. Controls drawn at 36 pt keep that size and use a 44 pt hit area.

| Card | Interactive elements | Behavior |
| --- | --- | --- |
| 1 Opening | none | "Tap to start" hint pulses once. No share pill. No (i) |
| 2 Year in memories | Month tiles; **Play your year** tile | Tile tap: full-screen photo with month label (tap to close). A missing month photo uses the gradient placeholder. Play: 15 s montage with chapter music; finishing returns to card. No share pill |
| 3 Feed color | Swatch tap | Swatch expands showing hex and "% of liked posts where this color dominates" |
| 4 Your algorithm | **More of this** / **Not me** per topic; **Guilty** on topic 3 | Opens with nothing selected. The PNG's checked "More of this" is the selected style, not the default. Saves `card_feedback`; toast "Got it. We'll tune Explore." Selected state persists |
| 5 Reels rabbit hole | Category bar tap | Shows 3 sample Reel thumbnails for that category (persona data) |
| 6 Main character post | Post tap | Opens the post in IG post-detail chrome (static). The sticker reads the engine string "418 comments. Unhinged ones." |
| 7 Broke the group chat | Story thumbnail tap | Plays the Story in IG Story viewer chrome. Never shows reply contents |
| 8 Your circle | Avatar tap | Avatar enlarges privately; no counts. Handles are shown in alphabetical order. No share button on this card |
| 9 3AM club | none | Clock hand animates to 3:42 |
| 10 Plot twist | none | Bars animate June onward |
| 11 Personality teaser | **Reveal my personality** | Disables autoplay on this card; tap → card 12 with reveal animation + haptic. No (i) |
| 12 Personality reveal | **Share your personality** / **See your share cards** | → S10 with Identity card / → card 13 |
| 13 Share cards | Identity card drawn full-bleed. Bottom 100 pt: Identity/Numbers `SegmentedToggle`, black **Share** pill, **Go to your Hub** text link | Toggle crossfades to the Numbers card. Share → S10. Hub link → S08 |
| Any shareable card | Share icon (bottom pill "Share this story") | → S10 with that card |
| Any card | (i) | → S09 |

### S08 Wrapped Hub
| Element | Action | Goes to |
| --- | --- | --- |
| Personal / Creator toggle | Switch edition (pro accounts) | Same |
| Identity card thumbnail | Open | S07 card 13 |
| Replay | Restart | S07 card 1 |
| Share | Share sheet | S10 |
| Highlights (4 tiles) | Open that card | S07 card n |
| Explore your year (13 tiles) | Open that card; Your circle tile shows lock | S07 card n |
| View all 13 | Start at card 1 | S07 |
| Remix · Wrapped Together · Guess My Wrapped · Privacy · Past years | Open tool | S11 · S13 · S14 · S12 · S16 |
| Back | Leave Wrapped | S01 |

### S09 Card info sheet
Provenance badge (Measured solid / Estimated dotted / Inferred dashed) + one-line meaning; window and method; **This looks wrong** (reason picker → toast); **Hide this card** (removes from player, Hub, quiz); Close. The Reels card method line is: "Top 5 categories by share of your Reels watch time. Other categories: 8%." Cards 1 and 11 have no (i) because they have no metrics.

### S10 Share sheet
| Element | Action |
| --- | --- |
| Identity card / Numbers card | Switch which card is shared (when opened from a non-final card: that card + the two share cards) |
| Format: Story 9:16 / Post 4:5 / Square 1:1 | Re-render preview |
| Style: Bold / Scrapbook / Numbers / Photo Film | Re-skin; numbers unchanged |
| Show on card chips | Toggle @handle, individual stats, second personality, cover photo (Numbers card) |
| **Your story** | `ImageRenderer` → Sharing to Stories → real Instagram composer. Copies See yours link to clipboard with toast "Link copied. Add it with the link sticker." |
| Send | iOS share sheet with image + link |
| Save | Save to Photos (request permission) |
| Copy link | Creates `share_snapshots` row, copies `/s/[slug]` |
| Cancel / swipe down | Dismiss |

### S11 Remix
4 style chips re-skin all cards; card include toggles; Preview (mini player); Save style; Export video (stretch).

### S12 Privacy
Toggles: include DM stats, include watch history, include saves, allow Together invites, **ranked circle (off)**, hide usernames on shares (on), autoplay. Hidden cards list (unhide). **Delete my Wrapped** (confirm → deletes run → S01). Any toggle change re-runs `build-run` and shows S03 briefly.

### S13 Wrapped Together (phase 2)
Invite a friend (persona picker) → pending → partner accepts and picks memories → both approve → joint card. Either can revoke; revoked share links show "No longer available".

### S14 Guess My Wrapped (phase 2)
Pick 3 shareable cards → quiz with plausible wrong answers → Add to Story → results.

### S16 Past years
Single row "2025: not available in this demo" (static).

### S17 Web share landing `/s/[slug]`
Shows only the frozen shared image, centered on ink, plus one white "See yours" pill (opens the app via universal link, else a TestFlight info page) and one text link, "What's Instagram Wrapped?". `design/screens/story-posted-preview.png` is the posted Story with the link sticker. It is not S17.

## 4. Empty, error and edge states

| Situation | Behavior |
| --- | --- |
| Not enough data | Lite tier: cards 1, 2, 12, 13 only |
| A card's metric missing | Card skipped silently, progress bar count adjusts |
| Teen persona | Cards 8 and 9 removed (11 cards) |
| Offline mid-player | Cached cards keep playing; share actions queue with banner |
| Instagram not installed | Your story button → toast "Instagram isn't installed" + Save instead |
| Photos permission denied | Toast with Settings link |
