# OmniQoL — All-In-One Quality of Life Mod Suite

<p align="left">
  <a href="https://github.com/bryanthaboi/gen1recomp"><img src="https://img.shields.io/badge/Target%20Engine-bryanthaboi%2Fgen1recomp-2680eb?style=for-the-badge&logo=github&logoColor=white" alt="Target Engine: bryanthaboi/gen1recomp"></a>
  <img src="https://img.shields.io/badge/Mod%20API-v2-00b4d8?style=for-the-badge" alt="API Version">
  <img src="https://img.shields.io/badge/Environment-LÖVE2D%20%2F%20Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white" alt="Lua">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-2ea44f?style=for-the-badge" alt="MIT License"></a>
</p>

**OmniQoL** is a comprehensive, modular Quality of Life (QoL) suite built for Pokémon native engine recreations, targeting **Gen1Recomp / G1R Deluxe** (`bryanthaboi/gen1recomp`) and its subsequent generations.

Every feature is designed as an independent module that can be individually toggled directly within the game's Start Menu, with preferences saved per save file.

---

## 🎮 Per-Module Compatibility Matrix

| Module | Red & Blue<br>*(Gen 1)* | Yellow<br>*(Gen 1)* | Gold & Silver<br>*(Gen 2)* | Crystal<br>*(Gen 2)* | FireRed & LeafGreen<br>*(Gen 3)* | Ruby & Sapphire<br>*(Gen 3)* | Emerald<br>*(Gen 3)* |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **🏃 Running Shoes** | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Next Up](https://img.shields.io/badge/⏳%20Next%20Up-yellow?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) |
| **⚙️ In-Game Mod Menu** | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Next Up](https://img.shields.io/badge/⏳%20Next%20Up-yellow?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) |

<details>
<summary><b>🔍 View detailed status breakdown for Module 1: Running Shoes</b></summary>

| Game Target | Generation | Status | Notes |
| :--- | :---: | :---: | :--- |
| **Pokémon Red & Blue** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Full 2x dash, usable everywhere, native options menu toggle |
| **Pokémon Yellow** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Full 2x dash, Pikachu follower synchronization (8f follow / 4f catch-up), native options menu toggle |
| **Pokémon Gold & Silver** | Gen 2 | ![Next Up](https://img.shields.io/badge/⏳%20Next%20Up-yellow?style=flat-square) | Next target |
| **Pokémon Crystal** | Gen 2 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon FireRed & LeafGreen** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Ruby & Sapphire** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Emerald** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |

</details>

---

## 🗺️ Multi-Game Rollout Roadmap

For each module, development follows a structured multi-generation workflow:
1. **Gen 1**: Pokémon Red & Blue *(Complete)* ➔ Pokémon Yellow *(Complete)*
2. **Gen 2**: Pokémon Gold & Silver *(Next)* ➔ Pokémon Crystal
3. **Gen 3**: Pokémon FireRed & LeafGreen ➔ Pokémon Ruby & Sapphire ➔ Pokémon Emerald

---

## 📦 Repository Structure

```
OmniQoL/
├── mods/
│   ├── gen1/                   # Generation 1: Pokémon Red, Blue & Yellow
│   │   ├── manifest.json       # Mod metadata & loader config (Target: Red, Blue, Yellow)
│   │   ├── init.lua            # Primary entry point
│   │   ├── main.lua            # Compatibility entry shim
│   │   ├── core/
│   │   │   ├── module_manager.lua  # Module registry & per-save state
│   │   │   └── settings_menu.lua   # Options Menu 'OMNIQOL' injection & custom UI
│   │   └── modules/
│   │       └── running.lua         # Running Shoes with Pikachu Follower sync
│   ├── gen2_gold_silver/       # Gen 2 Target (Next)
│   ├── gen2_crystal/
│   ├── gen3_fire_red_leaf_green/
│   ├── gen3_ruby_sapphire/
│   └── gen3_emerald/
└── README.md
```

---

## 🏃 Current Modules

### Module 1: Running Shoes (Pokémon Red, Blue & Yellow)
- **Hold B to Run**: Doubles player walking speed (from 16 to 8 frames/tile), matching the Bicycle.
- **Pikachu Follower Synchronization (Yellow)**: Pikachu automatically matches player speed at 8 frames/tile, and executes a 4 frames/tile catch-up sprint if separated or turning corners.
- **Everywhere**: Fully permitted indoors, outdoors, in caves, and in buildings.
- **Fair Encounters**: Preserves standard wild encounter rates.
- **Cutscene Protection**: Automatically restores normal walking duration when idle and during NPC escort cutscenes (e.g., Professor Oak) to prevent desyncs.
- **Options Menu Integration**: Accessible directly through the native **Options Menu** (`OPTION`), both during gameplay and on the Title Screen, while keeping the overworld Start Menu pure vanilla.


---

## 📄 License
This project is licensed under the [MIT License](LICENSE).

---

## 🤖 AI Disclaimer
Portions of this codebase, architecture, and documentation were developed with the assistance of AI coding tools, paired with and reviewed by human developers. While every module is structured and tested for compatibility with the target recompilation engines, please report any issues or unexpected behaviors.


