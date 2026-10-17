# OmniQoL — Pokémon Yellow

<p align="left">
  <img src="https://img.shields.io/badge/Game-Pokémon%20Yellow-yellow?style=flat-square&logo=nintendogameboy&logoColor=black" alt="Yellow">
  <a href="https://github.com/bryanthaboi/gen1recomp"><img src="https://img.shields.io/badge/Engine-bryanthaboi%2Fgen1recomp-blue?style=flat-square&logo=github&logoColor=white" alt="bryanthaboi/gen1recomp"></a>
  <img src="https://img.shields.io/badge/Status-Fully%20Functional-brightgreen?style=flat-square" alt="Status">
</p>

## Overview
**OmniQoL** is a modular Quality of Life (QoL) suite built for **Gen1Recomp / G1R Deluxe** (`bryanthaboi/gen1recomp`). This edition is specifically tailored for **Pokémon Yellow**, featuring seamless Pikachu follower synchronization, native Options menu integration, per-save configuration persistence, and toggleable Running Shoes.

---

## Features

### 1. Running Shoes with Pikachu Follower Support (Module 1)
- **Hold B to Run**: Doubles overworld movement speed (from 16 down to 8 frames per tile, matching Bicycle speed).
- **Pikachu Follower Synchronization**:
  - Pikachu automatically scales its follow speed (8 frames per tile) to stay right by your side.
  - If separated or turning corners, Pikachu's catch-up dash (`FastPikachuFollow`) activates at 4 frames per tile.
  - Pikachu happiness and mood step counters function normally with zero penalties.
- **Usable Everywhere**: Indoors, outdoors, in caves, buildings, and the Safari Zone.
- **Fair Gameplay**: Keeps wild encounter rates identical to vanilla walking (no encounter penalty).
- **Clean Interactions**:
  - Does not accelerate Bicycle or Surfing beyond their natural speeds.
  - In vanilla Yellow, mounting a bike or surfing cleanly tucks Pikachu away; our guards preserve this behavior.
  - Ledges are jumped cleanly at 2x speed when running.
  - Automatically restores normal walking duration during cutscenes/scripted escort movements (e.g., Professor Oak escorting the player to the lab) to prevent NPC desyncs.

### 2. Options Menu Integration (`OMNIQOL`)
- Injects an **`OMNIQOL`** row directly into the native **Options Menu** (`OPTION`).
- Accessible both in the overworld (Start Menu ➔ `OPTION`) and on the Title Screen (`OPTION`).
- Selecting `OMNIQOL` opens the pixel-perfect module management screen:
  - **Up / Down**: Navigate through available modules.
  - **A / Left / Right**: Toggle the selected module `[ON ]` or `[OFF]`.
  - **B**: Save and return to the game.
- Leaves the overworld Start Menu pure vanilla.
- Settings are saved **per save file** during gameplay, and saved as **global defaults** when configured from the Title Screen.

---

## Mod Structure
```
mods/gen1_yellow/
├── manifest.json            # Gen1Recomp API v2 manifest (games: ["yellow"])
├── init.lua                 # Primary mod entry point
├── main.lua                 # Fallback compatibility entry shim
├── core/
│   ├── module_manager.lua   # Module registry, lifecycle & persistence
│   └── settings_menu.lua    # Options Menu injection & custom UI screen
└── modules/
    └── running.lua          # Running module hooks & Pikachu synchronization
```

---

## Installation in Gen1Recomp
1. Copy or extract the `mods/gen1_yellow` folder into your `gen1recomp/mods/` directory (or use the packaged zip file `omni_qol_yellow.zip`).
2. Launch Gen1Recomp with a Pokémon Yellow ROM.
3. In-game, hold **B** while moving to dash alongside Pikachu, or open **START ➔ OPTION ➔ OMNIQOL** to configure active modules!
