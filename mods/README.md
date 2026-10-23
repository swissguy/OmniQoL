# OmniQoL — All-In-One Cross-Generation Mod Suite (Gen 1 & Gen 2)

<p align="left">
  <img src="https://img.shields.io/badge/Gen%201-Red%20%7C%20Blue%20%7C%20Yellow-red?style=flat-square&logo=nintendogameboy&logoColor=white" alt="Red, Blue & Yellow">
  <img src="https://img.shields.io/badge/Gen%202-Gold%20%7C%20Silver%20%7C%20Crystal-gold?style=flat-square&logo=nintendogameboy&logoColor=white" alt="Gold, Silver & Crystal">
  <img src="https://img.shields.io/badge/Status-Fully%20Functional-brightgreen?style=flat-square" alt="Status">
</p>

## Overview
**OmniQoL** is a modular Quality of Life (QoL) suite built for native Pokémon engine recreations, targeting **Gen1Recomp / G1R Deluxe** (`bryanthaboi/gen1recomp`). A single `.zip` distribution archive provides native, plug-and-play support for **Pokémon Red, Blue, Yellow, Gold, Silver, and Crystal**, dynamically detecting the active game generation at runtime.

---

## Features

### 1. Running Shoes (Module 1) — Gen 1 & Gen 2
- **Hold B to Run**: Doubles overworld movement speed (from 16 down to 8 frames per tile, matching Bicycle speed).
- **Cross-Generation Support**: Fully functional across Pokémon Red, Blue, Yellow, Gold, Silver, and Crystal.
- **Pikachu Follower Synchronization (Yellow)**:
  - Pikachu automatically synchronizes its movement speed (8 frames/tile) to match the running player.
  - When turning corners or separated, Pikachu's catch-up dash (`FastPikachuFollow`) activates at 4 frames per tile.
- **Usable Everywhere**: Indoors, outdoors, in caves, buildings, and the Safari Zone.
- **Fair Gameplay**: Keeps wild encounter rates identical to vanilla walking (no encounter penalty).
- **Clean Interactions**:
  - Does not accelerate Bicycle or Surfing beyond their natural speeds.
  - Preserves authentic Gen 2 Ice Path sliding puzzle physics.
  - Ledges are jumped cleanly at 2x speed when running.
  - Automatically restores normal walking duration during cutscenes/scripted escort movements to prevent NPC desyncs.

### 2. EXP Share (Module 2) — Gen 1 & Gen 2
- **Modern Gen 6+ EXP Distribution**: 100% EXP to active battlers, 50% EXP to benched party members.
- **Cross-Generation Support**: Fully functional across Pokémon Red, Blue, Yellow, Gold, Silver, and Crystal.
- **Full Stat EXP**: All party members receiving EXP also gain 100% of the defeated Pokémon's base stats as Stat EXP across all stats.
- **Clean Single Team Notification**: Displays a single `"The rest of the team gained EXP!"` message for benched members.
- **Instant Level-Up Sequencing**: Any Pokémon that levels up immediately triggers its fanfare, stat box, and move learning prompt.
- **Pure Software Toggle**: Enabled by default, occupying 0 Bag inventory slots; supersedes vanilla Gen 2 held Exp. Share while active.

### 3. Trade Evolutions (Module 3) — Gen 1
- **Level 40 Evolution**: Kadabra, Machoke, Graveler, and Haunter evolve naturally at Level 40+.
- **Level 100 Rare Candy Support**: Using a Rare Candy on a Lv. 100 Pokémon triggers the evolution sequence (Gen 8+ style).
- **Authentic B-Cancel**: Standard Pokémon behavior is preserved; players can cancel evolution with B.
- **Trade Coexistence**: Link trades still trigger evolution as normal.
- **Vanilla NPC Trades**: In-game NPC trades do not immediately auto-evolve upon receipt.

### 4. Catch All 151 Pokémon (Module 4) — Gen 1
- **Wild Starters**: Bulbasaur (Viridian Forest, Route 2), Charmander (Routes 3 & 4), and Squirtle (Routes 24 & 25) can be caught in the wild in authentic thematic habitats.
- **Version Exclusives & Missing Pokémon**: Cross-pollinates Red, Blue, and Yellow version exclusives across all three games (e.g. Ekans/Arbok, Sandshrew/Sandslash, Oddish/Bellsprout, Meowth/Mankey, Vulpix/Growlithe, Koffing, Weedle line in Yellow, Electabuzz, Magmar, and wild Raichu).
- **Safari Exclusives Outside Safari Zone**: Chansey, Kangaskhan, Tauros, Scyther, Pinsir, Dratini, and Tangela spawn in overworld routes so players can battle and catch them with normal Pokéballs without fleeing mechanics.
- **Mutually Exclusive & Single-Choice Lines**: Omanyte & Kabuto (Seafoam Islands water), Hitmonlee & Hitmonchan (Victory Road / Route 10), and wild Eevee (Routes 25, 8 & 17) allowing all three Eeveelutions on a single save file. Trade-only species (Jynx, Farfetch'd, Mr. Mime, Lickitung, Porygon) also spawn in the wild.
- **Immediate Legendary Respawns**: Articuno, Zapdos, Moltres, Mewtwo, and Snorlax immediately respawn upon leaving and re-entering the map or room if defeated or fled without catching.
- **Mythical Mew Encounter**: Encounter a stationary Lv. 50 Mew on the deepest floor of Cerulean Cave (Unknown Dungeon B1F) with authentic cry and battle sequencing.

### 5. Move Relearner & Pre-Evolution Move Recovery (Module 5) — Gen 1
- **Pokémon Center Reminder**: An authentic Move Relearner NPC in every Pokémon Center lobby.
- **Full Historical Relearning**: Relearn all naturally learned level-up moves up to the Pokémon's current level, including Level 1 starting moves and pre-evolution moves (e.g. Raichu can relearn Pikachu's moves, Arcanine can relearn Growlithe's moves).

### 6. Forget HM Moves (Module 6) — Gen 1
- **Replace HMs Freely**: Overwrite Cut, Fly, Surf, Strength, and Flash during normal level-up move learning, TM teaching, or Move Relearner sessions without needing a Move Deleter.

---

## In-Game Configuration & Options Menu
Every module can be individually customized directly within the game's native **OPTIONS** menu (`OMNIQOL` entry), with settings saved per save file.

## Inter-Mod API
OmniQoL exposes its active manager instance through `mod.exports` adhering to the official Gen1Recomp API 2 specification. Other mods can query active features via:
```lua
local omni = mod.find and mod.find("omni_qol")
if omni and omni.exports then
  local isRunning = omni.exports:isEnabled("running")
end
```
