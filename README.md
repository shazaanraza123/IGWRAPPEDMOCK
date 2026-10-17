# Instagram Wrapped: Cursor build kit

Everything Cursor needs to build the Instagram Wrapped prototype (native SwiftUI + Supabase).

## Set up (10 minutes)

1. Create an empty repo (e.g. `ig-wrapped`) and copy this whole folder's contents into its root, including the hidden `.cursor/` folder.
2. Install: Xcode 16+, Homebrew `xcodegen`, Supabase CLI, Node 20+, Deno. In Cursor, install the **SweetPad** extension to build and run iOS from Cursor.
3. Take the Instagram reference screenshots listed in `design/reference/instagram/README.md`.
4. Drop the Instagram glyph and wordmark into `ios/IGWrapped/Resources/Brand/` once Step 0 creates it (kept out of git).
5. Open the repo in Cursor, open Agent chat, paste `CURSOR_PROMPT.md`.

## What's inside

```text
CURSOR_PROMPT.md            paste this into Cursor first
.cursor/rules/              always-on project rules + Swift and backend conventions
docs/DECISIONS.md           wins wherever it disagrees with the docs, HTML, or PNGs
docs/01-PRD.md              what and why: 13-screen journey, privacy rules, metrics
docs/02-TRD.md              stack, repo layout, Swift contracts, MUST / MUST NOT
docs/03-APPFLOW.md          every screen and every tap
docs/04-UIUX-BRIEF.md       tokens, type, components, motion, Instagram fidelity spec
docs/05-BACKEND-SCHEMA.md   tables, RLS, auth, exact card payloads
docs/06-IMPLEMENTATION-PLAN.md  25 steps with Done-when checks
design/screens/             19 approved screen PNGs (2x)
design/app-flow-map.png     the full flow on one image
design/source/              HTML source of every design (exact values)
design/photos/              sample photos + PHOTOS.md list of what's still needed
design/fonts/               Archivo variable font
design/reference/instagram/ your real-Instagram screenshots go here
data/personas/maya.json     the demo persona; all on-screen numbers
```

## Tips for driving Cursor
- Let it finish one step and show you the screenshot before saying "next".
- When the shell looks off, send it a fresh screenshot of real Instagram; don't describe it in words.
- If it starts adding things that aren't in the docs, point it back at `.cursor/rules/00-project.mdc`.
