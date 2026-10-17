# OmniQoL — Pokémon Red, Blue & Yellow (Generation 1)

<p align="left">
  <img src="https://img.shields.io/badge/Game-Pokémon%20Red%20%7C%20Blue%20%7C%20Yellow-red?style=flat-square&logo=nintendogameboy&logoColor=white" alt="Red, Blue & Yellow">
  <a href="https://github.com/bryanthaboi/gen1recomp"><img src="https://img.shields.io/badge/Engine-bryanthaboi%2Fgen1recomp-blue?style=flat-square&logo=github&logoColor=white" alt="bryanthaboi/gen1recomp"></a>
  <img src="https://img.shields.io/badge/Status-Fully%20Functional-brightgreen?style=flat-square" alt="Status">
</p>

## Overview
**OmniQoL** is a modular Quality of Life (QoL) suite built for **Gen1Recomp / G1R Deluxe** (`bryanthaboi/gen1recomp`). This unified Generation 1 edition works natively across **Pokémon Red**, **Pokémon Blue**, and **Pokémon Yellow**, featuring toggleable Running Shoes, Pikachu follower synchronization, and native Options Menu integration.

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
mods/gen1/
├── manifest.json            # Gen1Recomp API v2 manifest (games: ["red", "blue", "yellow"])
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
1. Copy or extract the `omni_qol` folder into your `gen1recomp/mods/` directory (or use the packaged `omni_qol.zip`).
2. Launch Gen1Recomp with a Pokémon Red, Blue, or Yellow ROM.
3. In-game, hold **B** while moving to dash, or open **START ➔ OPTION ➔ OMNIQOL** to configure active modules!
