# OmniQoL — All-In-One Quality of Life Mod Suite

<p align="left">
  <a href="https://github.com/bryanthaboi/gen1recomp"><img src="https://img.shields.io/badge/Target%20Engine-Gen1Recomp%20%2F%20G1R%20Deluxe-2680eb?style=for-the-badge&logo=nintendogameboy&logoColor=white" alt="Target Engine"></a>
  <img src="https://img.shields.io/badge/Mod%20API-v2-00b4d8?style=for-the-badge" alt="API Version">
  <img src="https://img.shields.io/badge/Environment-LÖVE2D%20%2F%20Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white" alt="Lua">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-2ea44f?style=for-the-badge" alt="MIT License"></a>
</p>

**OmniQoL** is a comprehensive, modular Quality of Life (QoL) suite built for Pokémon native engine recreations, targeting **Gen1Recomp / G1R Deluxe** (`bryanthaboi/gen1recomp`) and its subsequent generations.

Every feature is designed as an independent module that can be individually toggled directly within the game's Start Menu, with preferences saved per save file.

---

## 🎮 Compatibility & Target Matrix

| Generation | Game | Status | Badge |
| :--- | :--- | :---: | :--- |
| **Gen 1** | Pokémon Red & Blue | **Active** | ![Red & Blue](https://img.shields.io/badge/Red%20%26%20Blue-Compatible-brightgreen?style=flat-square) |
| **Gen 1** | Pokémon Yellow | **Next Up** | ![Yellow](https://img.shields.io/badge/Yellow-Planned-yellow?style=flat-square) |
| **Gen 2** | Pokémon Gold & Silver | **Planned** | ![Gold & Silver](https://img.shields.io/badge/Gold%20%26%20Silver-Planned-lightgrey?style=flat-square) |
| **Gen 2** | Pokémon Crystal | **Planned** | ![Crystal](https://img.shields.io/badge/Crystal-Planned-lightgrey?style=flat-square) |
| **Gen 3** | Pokémon FireRed & LeafGreen | **Planned** | ![FireRed & LeafGreen](https://img.shields.io/badge/FR%20%26%20LG-Planned-lightgrey?style=flat-square) |
| **Gen 3** | Pokémon Ruby & Sapphire | **Planned** | ![Ruby & Sapphire](https://img.shields.io/badge/Ruby%20%26%20Sapphire-Planned-lightgrey?style=flat-square) |
| **Gen 3** | Pokémon Emerald | **Planned** | ![Emerald](https://img.shields.io/badge/Emerald-Planned-lightgrey?style=flat-square) |

---

## 🗺️ Multi-Game Rollout Roadmap

For each module, development follows a structured multi-generation workflow:
1. **Gen 1**: Pokémon Red & Blue ➔ Pokémon Yellow
2. **Gen 2**: Pokémon Gold & Silver ➔ Pokémon Crystal
3. **Gen 3**: Pokémon FireRed & LeafGreen ➔ Pokémon Ruby & Sapphire ➔ Pokémon Emerald

---

## 📦 Repository Structure

```
OmniQoL/
├── mods/
│   ├── gen1_red_blue/          # Active Target: Pokémon Red & Blue
│   │   ├── manifest.json       # Mod metadata & loader config
│   │   ├── init.lua            # Entry point
│   │   ├── main.lua            # Compatibility entry shim
│   │   ├── core/
│   │   │   ├── module_manager.lua  # Module registry & per-save state
│   │   │   └── settings_menu.lua   # Start Menu 'MODS' injection & custom UI
│   │   └── modules/
│   │       └── running.lua         # Running Shoes module
│   ├── gen1_yellow/            # Next Target
│   ├── gen2_gold_silver/       # Gen 2 Target
│   ├── gen2_crystal/
│   ├── gen3_fire_red_leaf_green/
│   ├── gen3_ruby_sapphire/
│   └── gen3_emerald/
└── README.md
```

---

## 🏃 Current Modules

### Module 1: Running Shoes (Pokémon Red & Blue)
- **Hold B to Run**: Doubles player walking speed (from 16 to 8 frames/tile), matching the Bicycle.
- **Everywhere**: Fully permitted indoors, outdoors, in caves, and in buildings.
- **Fair Encounters**: Preserves standard wild encounter rates.
- **Cutscene Protection**: Automatically restores normal walking duration when idle and during NPC escort cutscenes (e.g., Professor Oak) to prevent desyncs.
- **In-Game Start Menu**: Injects an interactive `MODS` screen to toggle features on or off per save.

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).

---

## 🤖 AI Disclaimer
Portions of this codebase, architecture, and documentation were developed with the assistance of AI coding tools, paired with and reviewed by human developers. While every module is structured and tested for compatibility with the target recompilation engines, please report any issues or unexpected behaviors.


