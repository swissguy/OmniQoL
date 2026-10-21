# OmniQoL — Pokémon Red, Blue & Yellow (Generation 1)

<p align="left">
  <img src="https://img.shields.io/badge/Game-Pokémon%20Red%20%7C%20Blue%20%7C%20Yellow-red?style=flat-square&logo=nintendogameboy&logoColor=white" alt="Red, Blue & Yellow">
  <a href="https://github.com/bryanthaboi/gen1recomp"><img src="https://img.shields.io/badge/Engine-bryanthaboi%2Fgen1recomp-blue?style=flat-square&logo=github&logoColor=white" alt="bryanthaboi/gen1recomp"></a>
  <img src="https://img.shields.io/badge/Status-Fully%20Functional-brightgreen?style=flat-square" alt="Status">
</p>

## Overview
**OmniQoL** is a modular Quality of Life (QoL) suite built for **Gen1Recomp / G1R Deluxe** (`bryanthaboi/gen1recomp`). This unified Generation 1 edition works natively across **Pokémon Red**, **Pokémon Blue**, and **Pokémon Yellow**, featuring toggleable Running Shoes, Pikachu follower synchronization, modern EXP Share, Trade Evolutions at Lv. 40, Catch All 151 Pokémon, and native Options Menu integration.

---

## Features

### 1. Running Shoes (Module 1)
- **Hold B to Run**: Doubles overworld movement speed (from 16 down to 8 frames per tile, matching Bicycle speed).
- **Pikachu Follower Synchronization (Yellow)**:
  - Pikachu automatically synchronizes its movement speed (8 frames/tile) to match the running player.
  - When turning corners or separated, Pikachu's catch-up dash (`FastPikachuFollow`) activates at 4 frames per tile.
  - Happiness and mood step counter ticks function normally with zero penalties.
- **Usable Everywhere**: Indoors, outdoors, in caves, buildings, and the Safari Zone.
- **Fair Gameplay**: Keeps wild encounter rates identical to vanilla walking (no encounter penalty).
- **Clean Interactions**:
  - Does not accelerate Bicycle or Surfing beyond their natural speeds.
  - In vanilla Yellow, mounting a bike or surfing cleanly tucks Pikachu away; our guards preserve this behavior.
  - Ledges are jumped cleanly at 2x speed when running.
  - Automatically restores normal walking duration during cutscenes/scripted escort movements (e.g., Professor Oak escorting the player to the lab) to prevent NPC desyncs.

### 2. EXP Share (Module 2)
- **Modern Gen 6+ EXP Distribution**: 100% EXP to active battlers, 50% EXP to benched party members.
- **Full Stat EXP**: All party members receiving EXP also gain 100% of the defeated Pokémon's base stats as Stat EXP.
- **Clean Single Team Notification**: Displays a single `"The rest of the team gained EXP!"` message for benched members.
- **Instant Level-Up Sequencing**: Any Pokémon that levels up immediately triggers its fanfare, stat box, and move learning prompt.
- **Pure Software Toggle**: Enabled by default, occupying 0 Bag inventory slots.

### 3. Trade Evolutions (Module 3)
- **Level 40 Evolution**: Kadabra, Machoke, Graveler, and Haunter evolve naturally at Level 40+.
- **Level 100 Rare Candy Support**: Using a Rare Candy on a Lv. 100 Pokémon triggers the evolution sequence (Gen 8+ style).
- **Authentic B-Cancel**: Standard Pokémon behavior is preserved; players can cancel evolution with B.
- **Trade Coexistence**: Link trades still trigger evolution as normal.
- **Vanilla NPC Trades**: In-game NPC trades do not immediately auto-evolve upon receipt.

### 4. Catch All 151 Pokémon (Module 4)
- **Wild Starters**: Bulbasaur (Viridian Forest, Route 2), Charmander (Route 3, Rock Tunnel), and Squirtle (Routes 24 & 25) can be caught in the wild in authentic thematic habitats.
- **Version Exclusives & Missing Pokémon**: Cross-pollinates Red, Blue, and Yellow version exclusives across all three games (e.g. Ekans/Arbok, Sandshrew/Sandslash, Oddish/Bellsprout, Meowth/Mankey, Vulpix/Growlithe, Koffing, Weedle line in Yellow, Electabuzz, Magmar, and wild Raichu).
- **Safari Exclusives Outside Safari Zone**: Chansey, Kangaskhan, Tauros, Scyther, Pinsir, Dratini, and Tangela spawn in overworld routes so players can battle and catch them with normal Pokéballs without fleeing mechanics.
- **Mutually Exclusive & Single-Choice Lines**: Omanyte & Kabuto (Seafoam Islands water), Hitmonlee & Hitmonchan (Victory Road / Route 10), and wild Eevee (Routes 8 & 17) allowing all three Eeveelutions on a single save file. Trade-only species (Jynx, Farfetch'd, Mr. Mime, Lickitung, Porygon) also spawn in the wild.
- **Immediate Legendary Respawns**: Articuno, Zapdos, Moltres, Mewtwo, and Snorlax immediately respawn upon leaving and re-entering the map or room if defeated or fled without catching.
- **Mythical Mew Encounter**: Encounter a stationary Lv. 50 Mew on the deepest floor of Cerulean Cave (Unknown Dungeon B1F) with authentic cry and battle sequencing, sharing the room re-entry respawn rule if not caught.
- **Celadon Department Store Moon Stone**: Sold on 4F (Wiseman Gifts) alongside Fire, Water, Thunder, and Leaf Stones at standard ¥2,100 with infinite stock, ensuring Moon Stone evolutions are never blocked.
- **Options Menu Integration**: Toggled directly in `OMNIQOL` Options Menu (`CATCH 151`), enabled by default.

### 5. Move Relearner (Module 5)
- **Every Pokémon Center Across Kanto**: A distinguished Gentleman Move Reminder NPC is present in the lobby of all 12 Pokémon Centers.
- **Free to Use**: Zero Pokédollar or item cost (Sword & Shield style).
- **Missed Pre-Evolution Moves**: Any Pokémon can relearn all level-up moves their current species and any earlier stages in their evolutionary line could have learned up to their current level.
  - Fixes early stone evolution lockouts (e.g. Raichu evolving early can relearn Thunderbolt/Agility from Pikachu; Arcanine can relearn Flamethrower from Growlithe; Vileplume/Victreebel/Cloyster/Starmie/Nidoking/Nidoqueen never miss key moves).
- **Level 1 Base / Starting Moves**: Relearn any initial starting move at any level.
- **TM Tutor Mode (`RELEARN + TMS`)**: Teaches any compatible TM01–TM50 moves, including inherited compatibility from pre-evolutions.
  - HM moves (Cut, Fly, Surf, Strength, Flash) remain excluded from TM tutoring.
- **Move Replacement**: Teaches directly if fewer than 4 moves known, or opens an interactive selection screen to replace an existing move when at the 4-move limit.
- **Scrollable Party & Move Lists**: Full 6-member party support and move lists with windowed scrolling and indicator arrows.
- **3-Way Options Menu Integration**: Toggled directly under `OPTION ➔ OMNIQOL` (`RELEARNER`):
  - `[OFF]`: Disabled.
  - `[RELEARN]`: Natural level-up moves and pre-evolution moves.
  - `[REL+TMS]`: Natural level-up moves + all compatible TM01–TM50 moves.

### 6. Forget HM Moves (Module 6)
- **Freely Overwrite HM Moves**: Allows overwriting and forgetting HM moves (Cut, Fly, Surf, Strength, Flash) whenever learning any new move (via Level Up, TM items, or Move Relearner).
- **Eliminates Trapped Movesets**: Removes the permanent HM lock present in vanilla Gen 1.
- **Dedicated Toggle**: Separately toggleable under `OPTION ➔ OMNIQOL` (`FORGET HMS`), enabled by default.

### 7. Options Menu Integration (`OMNIQOL`)
- Injects an **`OMNIQOL`** row directly into the native **Options Menu** (`OPTION`).
- Accessible both in the overworld (Start Menu ➔ `OPTION`) and on the Title Screen (`OPTION`).
- Selecting `OMNIQOL` opens the pixel-perfect module management screen:
  - **Up / Down**: Navigate through available modules with automatic windowed scrolling.
  - **A / Left / Right**: Cycle module values (e.g., `[ON ]`/`[OFF]` or `[RELEARN]`/`[REL+TMS]`/`[OFF]`).
  - **B**: Save and return to the game.
- Leaves the overworld Start Menu pure vanilla.
- Settings are saved **per save file** during gameplay, and saved as **global defaults** when configured from the Title Screen.

---

## Mod Structure
```
mods/gen1/
├── manifest.json            # Gen1Recomp API v2 manifest (games: ["red", "blue", "yellow"])
├── init.lua                 # Primary mod entry point
├── main.lua                 # Fallback compatibility entry shim
├── core/
│   ├── module_manager.lua   # Module registry, lifecycle & persistence
│   └── settings_menu.lua    # Options Menu injection, scroll handling & custom UI screen
└── modules/
    ├── running.lua          # Running module hooks & Pikachu synchronization
    ├── exp_share.lua        # Modern Gen 6+ EXP Share
    ├── trade_evos.lua       # Trade evolutions at Lv. 40 + Lv. 100 Rare Candy
    ├── catch_151.lua        # Catch all 151 Pokémon, wild starters, respawns & Mew
    ├── forget_hms.lua       # Forget & overwrite HM moves freely
    ├── relearner_data.lua   # 151 learnsets, starting moves & evolution ancestry
    └── move_relearner.lua   # Move Reminder NPC in all Pokémon Centers
```

---

## Installation in Gen1Recomp
1. Copy or extract the `omni_qol` folder into your `gen1recomp/mods/` directory (or use the packaged `omni_qol.zip`).
2. Launch Gen1Recomp with a Pokémon Red, Blue, or Yellow ROM.
3. In-game, hold **B** while moving to dash, or open **START ➔ OPTION ➔ OMNIQOL** to configure active modules!
