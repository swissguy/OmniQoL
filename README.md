# OmniQoL — All-In-One Quality of Life Mod Suite

**OmniQoL** is a comprehensive, modular Quality of Life (QoL) suite built for Pokémon engine recreations, targeting **Gen1Recomp / G1R Deluxe** (`bryanthaboi/gen1recomp`) and its subsequent generations.

Every feature is designed as an independent module that can be individually toggled directly within the game's Start Menu, with preferences saved per save file.

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


