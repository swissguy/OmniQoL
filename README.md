# G1R Deluxe — Quality of Life Mod Suite

**G1R Deluxe** is a modular, high-performance Quality of Life (QoL) suite built for Pokémon engine recreations, targeting **Gen1Recomp** (`bryanthaboi/gen1recomp`) and its subsequent generations.

Each feature is built as an independent, toggleable module configured directly within the game via the Start Menu and saved per-save file.

---

## 🗺️ Roadmap & Target Workflow

For every module, development follows a strict multi-generation workflow:
1. **Gen 1**: Pokémon Red & Blue ➔ Pokémon Yellow
2. **Gen 2**: Pokémon Gold & Silver ➔ Pokémon Crystal
3. **Gen 3**: Pokémon FireRed & LeafGreen ➔ Pokémon Ruby & Sapphire ➔ Pokémon Emerald

---

## 📦 Repository Structure

```
G1R/
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
- **Fair Encounters**: Preserves vanilla wild encounter calculations.
- **Cutscene Protection**: Automatically restores standard step duration when idle and during NPC escorts (e.g., Professor Oak) to prevent cutscene desyncs.
- **Start Menu Integration**: Injects an interactive `MODS` menu into the Start Menu to toggle features on or off at any time.
