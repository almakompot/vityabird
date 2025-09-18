# Viktor Orbán: Endless Escape

> *A satirical endless-runner inspired by Zombie Tsunami and Jetpack Joyride where a caricatured Viktor Orbán sprints, slides, and jetpacks through an escalating police chase while the world closes in on his questionable legacy.*

## Concept Overview
- **Genre:** Side-scrolling endless runner with light base-building and narrative collectibles.
- **Tone:** Cartoonish political satire. Every gag is an exaggerated fiction riffing on real-world controversies, keeping references clever rather than defamatory.
- **Core Fantasy:** Players embody a fictionalized Orbán analogue desperately outrunning squads of bumbling Interpol officers, drone paparazzi, and an ever-growing crowd of protestors. The longer you survive, the more secrets spill onto the screen.
- **Replay Hook:** Procedurally remixed segments, evolving chase intensity, and collectible “headline” snippets that gently lampoon alleged abuses of power.

## Target Platforms & Technology
| Platform | Delivery | Notes |
| --- | --- | --- |
| **Mobile (iOS & Android)** | Native builds exported from Godot 4 | Touch-first controls, haptics, ad-ready.
| **Web (Desktop & Mobile Browsers)** | Godot WebGL export hosted via static site | Quick demo access with leaderboard sync.
| **Backend Services** | Lightweight serverless functions (Cloudflare Workers/AWS Lambda) with FaunaDB or Supabase | Stores player ghost data, leaderboards, narrative unlocks.

**Primary Stack**
- **Engine:** Godot 4 (GDScript) for rapid 2D iteration, deterministic physics, and one-click exports to WebGL and mobile.
- **Art Pipeline:** Aseprite for pixel art spritesheets; Spine for subtle character animations; Audacity + freesound.org assets for SFX.
- **Tooling:** Git for version control, Git LFS for large art/audio, Godot’s built-in scene system for modular level chunks.

## Story, Setting & Satirical References
- **Opening Cinematic:** Orbán emerges from a secretive football stadium bunker, briefcase overflowing with “consultancy fees,” as news drones broadcast breaking corruption leaks.
- **Setting Beats:**
  - **“Charity” Fundraiser Strip:** Neon billboards flicker with slogans about NGO crackdowns, while donors lob champagne corks that become obstacles.
  - **Media Monopoly Alley:** TV vans spew propaganda tapes; collecting them grants the “Spin Shield” power-up that deflects bad press for a few seconds.
  - **Border Fence Sprint:** A nod to migration policies—barbed-wire mini-games challenge players to time jumps before riot vans box them in.
  - **Panama Plaza:** Offshore bank vaults pop open, releasing coin showers labeled “Consultancy Fees.” Greedy grabs slow Orbán, hinting at the cost of corruption.
- **Police Antagonists:** A multinational task force whose dialogue bubbles poke fun at shelved investigations, doctored tenders, and conveniently timed parliamentary votes.
- **Narrative Collectibles:** Satirical “leaked memos” that, when assembled, unlock tongue-in-cheek dossier entries referencing accusations of cronyism, media capture, and misuse of EU funds.

## Game Structure & Systems
1. **Interactive Cold Open (Tutorial)**
   - Quick-time escape from the stadium establishes swipe/tap/hold mechanics.
   - Players choose one of three alibis that influence the first power-up.
2. **Endless City Run**
   - Modular city blocks stitched procedurally with increasing heat levels.
   - Dynamic day/night cycle triggers different hazards (e.g., midnight audits, dawn protests).
3. **Chase Escalation Meter**
   - Heat rises as the police collect evidence. Reaching thresholds spawns tougher pursuit vehicles (armored limos, propaganda blimps, oligarch yachts on wheels).
4. **Power-Up System**
   - **“Public Works Jetpack”** – repurposed EU-funded project grants temporary flight.
   - **“Friends-and-Family Motorcade”** – summon aides who form a shield wall but siphon coins.
   - **“Nationalized Media Megaphone”** – slows the chase by drowning officers in spin.
5. **Underground Bonus Runs**
   - Hidden trapdoors lead to a metro of shredded documents; snagging enough pieces unlocks cosmetic disguises.
6. **Base Building: The Safehouse**
   - Between runs, spend ill-gotten gains on secret rooms (propaganda studio, stadium lounge) that deliver passive buffs and new narrative cutscenes.
7. **Community & Competition**
   - Async ghost races against friends, rotating “scandal seasons” with themed modifiers, and weekly leaderboards ranked by how long the chase was delayed.

## Content Pipeline
- **Art & Animation:** Stylized pixel art to keep satire light-hearted; caricatures avoid realism.
- **Music & Audio:** Balkan-electro chase tracks; slapstick SFX for pratfalls and police banter.
- **Writing:** Short quips and collectibles curated to allude to alleged wrongdoings (media capture, crony contracts, lavish stadium spending) without explicit accusations.

## Implementation Roadmap
| Phase | Duration | Focus |
| --- | --- | --- |
| **Pre-Production** | 2 weeks | Finalize satirical script, storyboard cinematics, prototype feel in Godot.
| **Vertical Slice** | 6 weeks | Build core runner mechanics, 3 environment tilesets, 4 power-ups, one scandal season.
| **Content Expansion** | 8 weeks | Add safehouse meta, underground bonus level, polish UI/UX, integrate backend leaderboards.
| **Launch Prep** | 4 weeks | QA across browsers and mobile devices, compliance checks, deploy marketing microsite.

## Feasibility Statement
Yes—the project is implementable with the outlined stack. Godot’s export pipeline supports simultaneous WebGL and mobile builds, and the scope fits an indie-sized team. By keeping assets stylized and systems modular, we can incrementally deliver content while testing satire balance with closed beta feedback.

## Repository Expectations
This repository will eventually contain:
- `/game` – Godot project files (scenes, scripts, assets).
- `/assets` – Source art/audio with LFS pointers.
- `/docs` – Narrative bible, quest scripts, localization tables.
- `/backend` – Serverless functions and schema definitions for online features.

Until code is added, this README serves as the authoritative concept document.

## Satire & Disclaimer
This game is a work of fiction for comedic and critical commentary. Any resemblance to real events is intentionally exaggerated for satire and does not assert factual claims beyond widely reported public controversies.
