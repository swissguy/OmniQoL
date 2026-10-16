# OmniQoL — Pokémon Red & Blue

<p align="left">
  <img src="https://img.shields.io/badge/Game-Pokémon%20Red%20%26%20Blue-red?style=flat-square&logo=nintendogameboy&logoColor=white" alt="Red and Blue">
  <img src="https://img.shields.io/badge/Engine-Gen1Recomp-blue?style=flat-square" alt="Gen1Recomp">
  <img src="https://img.shields.io/badge/Status-Fully%20Functional-brightgreen?style=flat-square" alt="Status">
</p>

## Overview
**OmniQoL** is a modular Quality of Life (QoL) suite built for **Gen1Recomp / G1R Deluxe** (`bryanthaboi/gen1recomp`). It features in-game toggleable modules configured directly from the overworld Start Menu, per-save configuration persistence, and Running Shoes.

---

## Features

### 1. Running Shoes (Module 1)
- **Hold B to Run**: Doubles overworld movement speed (from 16 down to 8 frames per tile, matching Bicycle speed).
- **Usable Everywhere**: Indoors, outdoors, in caves, buildings, and the Safari Zone.
- **Fair Gameplay**: Keeps wild encounter rates identical to vanilla walking (no encounter penalty).
- **Clean Interactions**:
  - Does not accelerate Bicycle or Surfing beyond their natural speeds.
  - Ledges are jumped cleanly at 2x speed when running.
  - Automatically restores normal walking duration during cutscenes/scripted escort movements (e.g., Professor Oak escorting the player to the lab) to prevent NPC desyncs.

### 2. In-Game Mod Menu (`MODS`)
- Injects a **`MODS`** option directly into the main overworld **Start Menu** (positioned right before `OPTION`).
- Selecting `MODS` opens an interactive options screen:
  - **Up / Down**: Navigate through available modules.
  - **A / Left / Right**: Toggle the selected module `[ON ]` or `[OFF]`.
  - **B**: Save and return to the game.
- Settings are saved **per save file** alongside your game save.

---

## Mod Structure
```
mods/gen1_red_blue/
├── manifest.json            # Gen1Recomp API v2 manifest
├── init.lua                 # Primary mod entry point
├── main.lua                 # Fallback compatibility entry shim
├── core/
│   ├── module_manager.lua   # Module registry, lifecycle & per-save storage
│   └── settings_menu.lua    # Start Menu injection & custom UI screen
└── modules/
    └── running.lua          # Running module hooks & speed calculation
```

---

## Installation in Gen1Recomp
1. Copy or symlink the `mods/gen1_red_blue` directory into your `gen1recomp/mods/` folder.
2. Launch Gen1Recomp with a Pokémon Red or Blue ROM.
3. In-game, hold **B** to run, or press **START -> MODS** to configure active modules!
