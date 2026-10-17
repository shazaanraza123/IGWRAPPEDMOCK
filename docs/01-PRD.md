# 01 · PRD: Instagram Wrapped

> Read order for agents: DECISIONS → PRD → TRD → APPFLOW → UIUX-BRIEF → BACKEND-SCHEMA → IMPLEMENTATION-PLAN.
> This file defines WHAT we build and WHY. Never invent features that are not here.
> If this file disagrees with `docs/DECISIONS.md`, DECISIONS.md wins.

## 1. One-liner

**Spotify tells you what you listened to alone. Instagram tells you who you were with.**

Instagram Wrapped is a yearly, Story-format recap of a user's year on Instagram. It lives inside Instagram, plays like Stories, and every card is built to be shared back to Stories.

## 2. What we are building (this repo)

A **native SwiftUI iPhone prototype** that looks and behaves like a real Instagram feature, running on **synthetic persona data**. It is a concept pitch, not an Instagram product.

- Distributed through **TestFlight only**. Never submitted to the App Store (it uses Instagram brand marks).
- Login screen and Hub footer must say: **"Concept prototype. Not affiliated with Instagram. Sample data."**
- No real Instagram data, no Instagram Graph API, no scraping.
- The demo video recorded from this app is the main pitch asset.
- Entry is the home banner and the Wrapped story-tray bubble only. There is no push notification and no profile-menu entry.

Editions:

| Edition | Status in this build |
| --- | --- |
| Personal ("This was your world") | **Build first, polish fully** |
| Creator ("This was the world you built") | Build second (see section 9) |
| Wrapped Together ("These are the moments you shared") | Phase 2 |

## 3. Why Instagram would ship it

| Instagram priority | What Wrapped does |
| --- | --- |
| Stories volume | Every card has a designed Story template. Drives a December spike in Story posts. |
| Sends and DMs | Share to DM, Wrapped Together and Guess My Wrapped all run through DMs. |
| Reactivation | A yearly reason for lapsed and passive users to open the app. Non-posters still get a full recap. |
| Creator retention | Creators get a brand-ready year-end report and a "play more of this" plan. |
| Recommendation quality + trust | "Your algorithm thinks you're into..." collects explicit More of this / Not me feedback. |

**Prior art:** In Dec 2024 Instagram shipped a manual year-end Story collage. It had no stats, no auto highlights, no archive. Wrapped is the data-driven version of demand Instagram has already shown.

**Viral loop:** user shares card to Story → friend sees it → taps **See yours** → opens their own Wrapped → shares again.

## 4. Goals and non-goals

Goals
1. Every user, including people who never post, gets a recap that feels personal and worth sharing.
2. The journey has an emotional arc: **memories → interests → people → identity**. That line is the narrative arc, not the chapter enum. Playback uses five chapters: Memories (cards 1–2), Interests (3–5), Moments (6–7), People (8–9), Identity (10–13). Eyebrow text is copy and is not a chapter id.
3. Sharing is one tap and produces a card that reads at a glance inside a Story.
4. Trust: nothing about another person is shown publicly without consent.

Non-goals
- Not a year-round analytics dashboard.
- No screen-time shaming.
- No profile-visitor data. No DM contents. Ever.
- No AI-written claims about mood, relationships, health or identity.
- Not a Spotify Wrapped reskin: no Spotify shapes, colors, type or copy patterns.

## 5. Users and personas

| Persona key | Who | What they want |
| --- | --- | --- |
| `maya` (hero demo persona) | Story poster and saver, Chicago, into streetwear, film cameras, food, interiors, ceramics | Relive the year, flex her personality |
| `ghost` | Lurker, posts almost never | Proof their year counted |
| `connector` | Social butterfly, lives in DMs and Close Friends | Celebrate friends |
| `emerging` | Creator, 1K to 50K followers | Growth story, what to post next |
| `established` | Creator, 50K+ | Shareable flex, brand-ready report |
| `teen` | Teen account variant of `maya` | Same journey with teen-unsafe cards removed |

The demo always uses `maya`. Her numbers are fixed in `data/personas/maya.json` and every screen must match them.

## 6. The Personal journey (13 screens, current version)

Each screen is one full-screen Story card. Design reference for every card is in `design/screens/`. Photo ids on every payload are the `maya.json` ids (`tile-1` … `tile-5`, `m-01` … `m-11`, `main-character`, `year-card`, `story-0314`). A missing photo draws the gradient placeholder from card 2 and does not fail the card. Sentences that contain a number come from the engine `copy` object. Views do not assemble them.

| # | Screen | Design file | What it shows (maya's data) | Share rule |
| --- | --- | --- | --- | --- |
| 1 | Opening | `01-opening.png` | @handle, photo grid, "2026 looked good on you.", data window Jan 1 to Nov 15 | Shareable from the Hub. No pill on the card. Top row is mute and X (no info) |
| 2 | Year in memories | `02-year-in-memories.png` | One photo per month Jan to Nov, August flagged as top month (9 posts, 61 Stories), play 15 s montage | Shareable from the Hub. No pill on the card |
| 3 | Feed color | `03-feed-color.png` | 3x3 tinted grid, 5 swatches with %, palette name "Midnight Camel" | Shareable |
| 4 | Your algorithm | `04-your-algorithm.png` | 3 Explore topics with **More of this / Not me**; topic 3 joke only if far from 1 and 2 | Shareable |
| 5 | Reels rabbit hole | `05-reels-rabbit-hole.png` | 5 categories by share of Reels time, fastest rising, Reels sent 1,206 | Shareable |
| 6 | Main character post | `06-main-character-post.png` | Most-liked post large, 2,184 likes, 418 comments, 3x average. Sticker copy is the engine template "{comments} comments. Unhinged ones." | Shareable |
| 7 | Broke the group chat | `07-broke-the-group-chat.png` | Most-replied Story (Mar 14), 47 replies. **Count only** | Shareable (own Story only) |
| 8 | Your circle | `08-your-circle.png` | 5 accounts, **unranked, no counts**, handles sorted alphabetically | **Private only** |
| 9 | 3AM club | `09-3am-club.png` | Latest session 3:42 AM, a Tuesday in May | Shareable; **removed for teens** |
| 10 | Plot twist | `10-plot-twist.png` | "In June you fell into ceramics and never climbed out." + monthly bars | Shareable |
| 11 | Personality teaser | `11-personality-teaser.png` | Three clues, then **Reveal** button | Not shareable |
| 12 | Personality reveal | `12-personality-reveal.png` | The Curator, side of The Ghost, 70% / 30% **match scores** | Shareable (hero) |
| 13 | Share cards | `13a-identity-card.png`, `13b-numbers-card.png` | Identity card full-bleed in the player, with an Identity/Numbers toggle, Share pill, and "Go to your Hub" in the bottom 100 pt. Toggle crossfades to the Numbers card | Shareable |

Card catalog cards that are NOT in this journey (later phases): Never-miss, Saved universe, Year in one word, DM superlatives.

### Personality archetypes (primary + secondary, each with a documented rule)

| Archetype | Rule | Mark color |
| --- | --- | --- |
| The Curator | Saves high relative to posts | Magenta `#D300C5` |
| The Ghost | Watches nearly every Story, rarely likes or posts | Ink `#26262B` |
| The Reel Dealer | Top percentile of Reels sent to friends | Orange `#FF7A00` |
| The Main Character | Posts often and gets strong engagement | Yellow `#FFD600` |
| The Close Friend | Most activity in Close Friends and DMs | Green `#27C866` |
| The Trendspotter | Engages with audio and topics early in their rise | Violet `#7638FA` |
| The Social Butterfly | Interactions spread across many accounts | Pink `#FF0069` |
| The Archivist | Stories nearly daily, grid barely touched | Paper `#F7F3EC` |

Marks: `design/screens/personality-marks.png`. Percentages are **classification match scores**, never "you are 70% X".

## 7. Shared features

| Feature | Requirement | Phase |
| --- | --- | --- |
| Story player | Tap right next, tap left back, hold pause, swipe down exit, autoplay toggle, Reduce Motion respected | MVP |
| Card info sheet | Time window, metric definition, label Measured / Estimated / Inferred, "This looks wrong", "Hide this card" | MVP |
| Share sheet | Identity / Numbers card picker, Story 9:16 / Post 4:5 / Square 1:1, 4 styles, "Show on card" toggles, real Share to Story, Send, Save, Copy link | MVP |
| Wrapped Hub | Highlights (4), Explore your year (all 13), Make it yours (tools), data window shown | MVP |
| Remix | 4 styles (Bold, Scrapbook, Numbers, Photo Film). Restyles only, numbers never change | MVP |
| Privacy controls | Exclude DMs / watch history / saves, hide cards, ranked circle opt-in (off), autoplay, delete | MVP |
| Low-data fallback | Lighter photo recap, never fake numbers, never a blank screen | MVP |
| Wrapped Together | Invite, both approve, joint card, revoke anytime | Phase 2 |
| Guess My Wrapped | Story quiz from shareable cards only | Phase 2 |
| Year over year | "vs 2025" deltas | Phase 4 |

## 8. Privacy rules (non-negotiable)

1. Private by default. Nothing posts unless the user taps share on that card.
2. Only show the user's own behavior outward. Never someone else's behavior toward them.
3. No profile-visit counts, no story-screenshot data, no DM contents, no named DM rankings.
4. Anything naming another person (Circle ranking, Together, Day-Ones) needs consent or stays private.
5. No sensitive inferences: relationships, religion, sexuality, health, mood.
6. Teen accounts: no 3AM club, no circle, no social comparisons.
7. Every number traces to a source, window and method. If we can't back it, we don't show it.

## 9. Creator edition (build after Personal is demo-ready)

Its own story, not Personal with follower numbers. Order: Opening → The climb (followers) → Viral timeline (monthly views, tap peaks) → Biggest hit (toggle views / shares / saves / engagement rate) → Three kinds of hits (Viral, Conversation Starter, Hidden Gem) → Format face-off → Beyond your followers → Creator DNA (8 creator archetypes) → Play more of this (data-backed suggestion) → Creator report export. Same design system, "Culture Report" art direction (ink + lime `#C6FF3D` highlight).

## 10. Success metrics

| Goal | Production metric | Prototype proxy (5 usability tests) |
| --- | --- | --- |
| Discovery | % eligible accounts that open | Testers find entry unaided |
| Completion | % reaching card 13 | Completion rate |
| Sharing | % sharing at least 1 card | Testers who'd post a card |
| Virality | See yours opens per share | n/a |
| Trust | Privacy complaints, "looks wrong" reports | Testers feel in control (4+/5) |
| Rec feedback | % tapping More of this / Not me | n/a |

Time spent is deliberately **not** a success metric.
