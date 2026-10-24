# OmniQoL — All-In-One Cross-Generation Quality of Life Mod Suite

<p align="left">
  <a href="https://github.com/bryanthaboi/gen1recomp"><img src="https://img.shields.io/badge/Target%20Engine-bryanthaboi%2Fgen1recomp-2680eb?style=for-the-badge&logo=github&logoColor=white" alt="Target Engine: bryanthaboi/gen1recomp"></a>
  <img src="https://img.shields.io/badge/Mod%20API-v2-00b4d8?style=for-the-badge" alt="API Version">
  <img src="https://img.shields.io/badge/Environment-LÖVE2D%20%2F%20Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white" alt="Lua">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-2ea44f?style=for-the-badge" alt="MIT License"></a>
</p>

**OmniQoL** is a comprehensive, modular Quality of Life (QoL) suite built for Pokémon native engine recreations, targeting **Gen1Recomp / G1R Deluxe** (`bryanthaboi/gen1recomp`). A single `.zip` distribution archive provides unified, plug-and-play support across **Generation 1 (Red, Blue, Yellow)** and **Generation 2 (Gold, Silver, Crystal)**, dynamically evaluating the active game generation at runtime.

Every feature is designed as an independent module that can be individually toggled directly within the game's native Options Menu (`OPTION`), with preferences saved per save file.

---

## 🎮 Per-Module Compatibility Matrix

| Module | Red & Blue<br>*(Gen 1)* | Yellow<br>*(Gen 1)* | Gold & Silver<br>*(Gen 2)* | Crystal<br>*(Gen 2)* | FireRed & LeafGreen<br>*(Gen 3)* | Ruby & Sapphire<br>*(Gen 3)* | Emerald<br>*(Gen 3)* |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **🏃 Running Shoes** | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) |
| **🎓 EXP Share** | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) |
| **🔄 Trade Evolutions** | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Next Up](https://img.shields.io/badge/⏳%20Next%20Up-yellow?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) |
| **✨ Catch All 151 / 251** | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Next Up](https://img.shields.io/badge/⏳%20Next%20Up-yellow?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) |
| **🧠 Move Relearner** | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Next Up](https://img.shields.io/badge/⏳%20Next%20Up-yellow?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) |
| **✂️ Forget HM Moves** | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Next Up](https://img.shields.io/badge/⏳%20Next%20Up-yellow?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) |
| **🎒 Improved Inventory** | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Next Up](https://img.shields.io/badge/⏳%20Next%20Up-yellow?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) |
| **⚙️ In-Game Mod Menu** | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) |

<details>
<summary><b>🔍 View detailed status breakdown for Module 1: Running Shoes</b></summary>

| Game Target | Generation | Status | Notes |
| :--- | :---: | :---: | :--- |
| **Pokémon Red & Blue** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Full 2x dash, usable everywhere, native options menu toggle |
| **Pokémon Yellow** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Full 2x dash, Pikachu follower synchronization (8f follow / 4f catch-up), native options menu toggle |
| **Pokémon Gold & Silver** | Gen 2 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Full 2x dash, usable everywhere, bike/surf/ice sliding preserved, native options menu toggle |
| **Pokémon Crystal** | Gen 2 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Full 2x dash, usable everywhere, bike/surf/ice sliding preserved, native options menu toggle |
| **Pokémon FireRed & LeafGreen** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Ruby & Sapphire** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Emerald** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |

</details>

<details>
<summary><b>🔍 View detailed status breakdown for Module 2: EXP Share</b></summary>

| Game Target | Generation | Status | Notes |
| :--- | :---: | :---: | :--- |
| **Pokémon Red & Blue** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Modern Gen 6+ EXP (100% active battlers / 50% bench), 100% Stat EXP, clean single team notification, options menu toggle |
| **Pokémon Yellow** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Full EXP Share support with Pikachu happiness on level-up, options menu toggle |
| **Pokémon Gold & Silver** | Gen 2 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Modern Gen 6+ EXP (100% active battlers / 50% bench), 100% Stat EXP, clean single team notification, options menu toggle, supersedes held Exp. Share |
| **Pokémon Crystal** | Gen 2 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Modern Gen 6+ EXP (100% active battlers / 50% bench), 100% Stat EXP, clean single team notification, options menu toggle, supersedes held Exp. Share |
| **Pokémon FireRed & LeafGreen** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Ruby & Sapphire** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Emerald** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |

</details>

<details>
<summary><b>🔍 View detailed status breakdown for Module 3: Trade Evolutions</b></summary>

| Game Target | Generation | Status | Notes |
| :--- | :---: | :---: | :--- |
| **Pokémon Red & Blue** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Kadabra, Machoke, Graveler & Haunter evolve at Lv. 40, Gen 8+ Lv. 100 Rare Candy support, B-cancel, options menu toggle |
| **Pokémon Yellow** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Full Lv. 40 trade evolution support, NPC trade preservation, options menu toggle |
| **Pokémon Gold & Silver** | Gen 2 | ![Next Up](https://img.shields.io/badge/⏳%20Next%20Up-yellow?style=flat-square) | Next target (including item trade evos) |
| **Pokémon Crystal** | Gen 2 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon FireRed & LeafGreen** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Ruby & Sapphire** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Emerald** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |

</details>

<details>
<summary><b>🔍 View detailed status breakdown for Module 4: Catch All 151 / 251</b></summary>

| Game Target | Generation | Status | Notes |
| :--- | :---: | :---: | :--- |
| **Pokémon Red & Blue** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Wild starters, version exclusives, Safari mons outside Safari, mutually exclusive fossils & Hitmons, wild Eevee, room-reentry legendary respawns & Mew #151 |
| **Pokémon Yellow** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Full 151 wild availability, Weedle/Koffing/Meowth/Magmar/Electabuzz restorations, wild Raichu, room-reentry legendary respawns & Mew #151 |
| **Pokémon Gold & Silver** | Gen 2 | ![Next Up](https://img.shields.io/badge/⏳%20Next%20Up-yellow?style=flat-square) | Next target (Gen 2 starters, version exclusives & Celebi #251) |
| **Pokémon Crystal** | Gen 2 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon FireRed & LeafGreen** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Ruby & Sapphire** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Emerald** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |

</details>

<details>
<summary><b>🔍 View detailed status breakdown for Module 5: Move Relearner</b></summary>

| Game Target | Generation | Status | Notes |
| :--- | :---: | :---: | :--- |
| **Pokémon Red & Blue** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Free Move Reminder in every Pokémon Center lobby, pre-evolution moves up to current level (remedying early stone/trade evos), Level 1 starting moves, full move replacement UI, options menu toggle |
| **Pokémon Yellow** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Free Move Reminder in every Pokémon Center lobby, Yellow-adjusted learnsets, pre-evolution moves up to current level, options menu toggle |
| **Pokémon Gold & Silver** | Gen 2 | ![Next Up](https://img.shields.io/badge/⏳%20Next%20Up-yellow?style=flat-square) | Next target (Gen 2 Pokémon Center integration & learnsets) |
| **Pokémon Crystal** | Gen 2 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon FireRed & LeafGreen** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Ruby & Sapphire** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Emerald** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |

</details>

<details>
<summary><b>🔍 View detailed status breakdown for Module 6: Forget HM Moves</b></summary>

| Game Target | Generation | Status | Notes |
| :--- | :---: | :---: | :--- |
| **Pokémon Red & Blue** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Freely replace and forget HM moves (Cut, Fly, Surf, Strength, Flash) whenever learning any move via Level Up, TM, or Move Relearner; separate options menu toggle |
| **Pokémon Yellow** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | Freely replace and forget HM moves whenever learning any move via Level Up, TM, or Move Relearner; separate options menu toggle |
| **Pokémon Gold & Silver** | Gen 2 | ![Next Up](https://img.shields.io/badge/⏳%20Next%20Up-yellow?style=flat-square) | Next target (Cut, Fly, Surf, Strength, Flash, Whirlpool, Waterfall) |
| **Pokémon Crystal** | Gen 2 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon FireRed & LeafGreen** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Ruby & Sapphire** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Emerald** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |

</details>

<details>
<summary><b>🔍 View detailed status breakdown for Module 7: Improved Inventory</b></summary>

| Game Target | Generation | Status | Notes |
| :--- | :---: | :---: | :--- |
| **Pokémon Red & Blue** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | 99-item Bag & PC Storage, Left/Right D-pad page jumping, auto-sorting A-Z & TMs numerically, safe PC deposit on disable |
| **Pokémon Yellow** | Gen 1 | ![Supported](https://img.shields.io/badge/✓%20Supported-brightgreen?style=flat-square) | 99-item Bag & PC Storage, Left/Right D-pad page jumping, auto-sorting A-Z & TMs numerically, safe PC deposit on disable |
| **Pokémon Gold & Silver** | Gen 2 | ![Next Up](https://img.shields.io/badge/⏳%20Next%20Up-yellow?style=flat-square) | Next target (expansion for Gen 2 Items pocket) |
| **Pokémon Crystal** | Gen 2 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon FireRed & LeafGreen** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Ruby & Sapphire** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |
| **Pokémon Emerald** | Gen 3 | ![Planned](https://img.shields.io/badge/Planned-lightgrey?style=flat-square) | Planned |

</details>

---

## 🗺️ Multi-Game Rollout Roadmap

For each module, development follows a structured multi-generation workflow:
1. **Gen 1**: Pokémon Red & Blue *(Complete)* ➔ Pokémon Yellow *(Complete)*
2. **Gen 2**: Pokémon Gold, Silver & Crystal *(Running Shoes & EXP Share complete, remainder Next Up)*
3. **Gen 3**: Pokémon FireRed & LeafGreen ➔ Pokémon Ruby & Sapphire ➔ Pokémon Emerald

---

## 📦 Repository Structure

```
OmniQoL/
├── mods/                       # Unified mod source directory (Gen 1 & Gen 2)
│   ├── manifest.json           # Mod metadata & loader config (API v2; Gen 1 & Gen 2)
│   ├── init.lua                # Primary entry point (loads core & modules)
│   ├── main.lua                # Compatibility entry shim
│   ├── README.md               # Mod directory documentation
│   ├── core/
│   │   ├── game_detector.lua   # Runtime game & generation detector
│   │   ├── module_manager.lua  # Module registry, per-save state & generation filtering
│   │   └── settings_menu.lua   # Options Menu 'OMNIQOL' injection & custom UI
│   └── modules/
│       ├── running.lua         # Running Shoes (Gen 1 & Gen 2; Pikachu sync in Yellow)
│       ├── exp_share.lua       # Modern EXP Share (Gen 6+ style, 100% Stat EXP; Gen 1 & Gen 2)
│       ├── trade_evos.lua      # Trade Evolutions at Lv. 40 + Lv. 100 Rare Candy
│       ├── catch_151.lua       # Catch All 151 Pokémon, wild starters, respawns & Mew
│       ├── forget_hms.lua      # Forget & overwrite HM moves freely
│       ├── relearner_data.lua  # 151 learnsets, starting moves & evolution ancestry
│       ├── move_relearner.lua  # Move Reminder NPC in all Pokémon Centers
│       └── improved_inventory.lua # 99-item Bag & PC storage, page navigation & auto-sorting
├── scripts/
│   ├── build_release.py        # Automated release packager (with pre-build test gate)
│   ├── publish_release.py      # Automated GitHub release publisher
│   ├── generate_relearner_data.py # Data compiler for 151 learnsets
│   └── run_tests.py            # Unified cross-generation test suite runner
├── submission/
│   └── Swissguy@omni_qol/      # Official mod index submission directory
│       ├── meta.json           # Index metadata & compatibility schema
│       ├── description.md      # Public mod description
│       └── thumbnail.png       # Mod artwork thumbnail
├── tests/                      # Automated test suite (Python unittest, 48 tests)
│   ├── test_manifest.py        # Metadata & config validation
│   ├── test_gen2_running.py    # Gen 2 compatibility, detection & Running module tests
│   ├── test_runtime_simulation.py # End-to-end engine mock, syntax & speed math tests
│   ├── test_encounters.py      # Encounter table & version parity verification
│   ├── test_trade_evos.py      # Trade evolution rules & level gating
│   ├── test_relearner.py       # Move relearner, learnsets, TM & HM rules
│   ├── test_hms_and_core.py    # HM deletion, Running shoes & module lifecycle
│   └── test_improved_inventory.py # 99-item bag/PC capacity, sorting & toggle-off safety
├── POKEDEX_151_GUIDE.md        # Comprehensive 151 Pokémon & Area-by-Area guide
└── README.md
```

---

## 🏃 Current Modules

### Module 1: Running Shoes (Gen 1 & Gen 2)
- **Hold B to Run**: Doubles player walking speed (from 16 to 8 frames/tile), matching the Bicycle.
- **Cross-Generation Support**: Fully functional across Pokémon Red, Blue, Yellow, Gold, Silver, and Crystal.
- **Pikachu Follower Synchronization (Yellow)**: Pikachu automatically matches player speed at 8 frames/tile, and executes a 4 frames/tile catch-up sprint if separated or turning corners.
- **Usable Everywhere**: Fully permitted indoors, outdoors, in caves, and in buildings.
- **Fair Encounters**: Preserves standard wild encounter rates.
- **Overworld Safety Guards**: Preserves normal Bicycle and Surf speeds, preserves authentic Gen 2 Ice Path sliding momentum, and automatically restores normal walking duration during NPC escort cutscenes (e.g., Professor Oak) to prevent desyncs.
- **Options Menu Integration**: Accessible directly through the native **Options Menu** (`OPTION`), both during gameplay and on the Title Screen, while keeping the overworld Start Menu pure vanilla.

### Module 2: EXP Share (Gen 1 & Gen 2)
- **Modern Gen 6+ EXP Distribution**: Active battlers receive a full 100% EXP share each (Gen 8+ style, no switching penalty), while non-fainted party members on the bench receive 50% EXP. Fainted Pokémon receive 0 EXP.
- **Cross-Generation Support**: Fully functional across Pokémon Red, Blue, Yellow, Gold, Silver, and Crystal.
- **Full Stat EXP (Gen 6+ style)**: All party members that receive EXP also gain 100% of the defeated enemy's base stats as Stat EXP across all stats.
- **Streamlined Battle Text**: Active battlers display their standard EXP gain dialogue, followed by a single clean consolidated message (`"The rest of the team gained EXP!"`) for benched Pokémon, completely eliminating dialogue spam.
- **Immediate Level-Up Flow**: Any Pokémon that levels up immediately plays its level-up fanfare, displays its stat growth box, and prompts for new moves in sequence.
- **Pure Software Toggle**: Available immediately from the start of the game, toggled ON/OFF in the `OMNIQOL` Options Menu, occupying 0 Bag inventory slots. Supersedes vanilla Gen 2 held Exp. Share while active, cleanly restoring vanilla item mechanics when toggled OFF.

### Module 3: Trade Evolutions (Gen 1)
- **Level 40 Evolution**: Kadabra, Machoke, Graveler, and Haunter evolve naturally into Alakazam, Machamp, Golem, and Gengar upon reaching or gaining any level at or above Level 40.
- **Level 100 Rare Candy Support (Gen 8+ Style)**: Using a Rare Candy on a Level 100 Pokémon triggers the evolution sequence without exceeding Level 100.
- **Authentic B-Cancel**: Standard Pokémon behavior is preserved; players can cancel the evolution sequence at any point by pressing B.
- **Link Trade Coexistence**: Normal link-cable trading continues to function as an alternative trigger.
- **Vanilla NPC Trades**: In-game NPC trades (e.g., Machoke in Underground Path/Route 11) do not auto-evolve immediately upon receipt, evolving on their subsequent level-up instead.
- **Options Menu Integration**: Toggleable on/off anytime under `OPTION ➔ OMNIQOL` (`TRADE EVOS`), enabled by default.

### Module 4: Catch All 151 Pokémon (Gen 1)
- **Wild Starters**: Bulbasaur (Route 2 & Viridian Forest), Charmander (Routes 3 & 4), and Squirtle (Routes 24 & 25) can be encountered and caught in the wild across thematic Kanto routes.
- **Version Exclusives & Missing Pokémon**: All version-locked Pokémon from Red, Blue, and Yellow are cross-available in counterpart wild habitats.
- **Safari Zone Exclusives Outside Safari Zone**: Chansey, Kangaskhan, Tauros, Scyther, Pinsir, Dratini, and Tangela spawn in overworld routes, allowing conventional battle and capture without fleeing or Safari Balls.
- **Mutually Exclusive & Single-Choice Lines**: Wild encounters for unchosen fossils (Omanyte & Kabuto in Seafoam Islands water), Fighting Dojo fighters (Hitmonlee & Hitmonchan in Victory Road and Route 10), and wild Eevee (Routes 25, 8 & 17, allowing all three Eeveelutions on a single save file). In-game trade-only mons (Jynx, Farfetch'd, Mr. Mime, Lickitung, Porygon) also spawn in the wild.
- **Immediate Legendary & Snorlax Respawns**: Articuno, Zapdos, Moltres, Mewtwo, and Snorlax immediately respawn upon exiting and re-entering their map/room if defeated or fled without catching.
- **Mythical Mew Encounter**: Stationary interactable Lv. 50 Mew rests on the deepest floor of Cerulean Cave (Unknown Dungeon B1F) with authentic cry and battle sequencing, respawning on room re-entry if not caught.
- **Celadon Department Store Moon Stone**: Sold on 4F (Wiseman Gifts) alongside Fire, Water, Thunder, and Leaf Stones at standard ¥2,100 with infinite stock, ensuring Moon Stone evolutions are never blocked.
- **Options Menu Integration**: Toggleable on/off anytime under `OPTION ➔ OMNIQOL` (`CATCH 151`), enabled by default.
- 📖 **Comprehensive Guide**: View the full 151 encounter directory in [`POKEDEX_151_GUIDE.md`](POKEDEX_151_GUIDE.md).

### Module 5: Move Relearner (Gen 1)
- **Every Pokémon Center Across Kanto**: A distinguished Gentleman Move Reminder NPC appears in the lobby of all 12 Pokémon Centers (Viridian, Pewter, Cerulean, Vermilion, Lavender, Celadon, Fuchsia, Saffron, Cinnabar, Indigo Plateau, Route 4, and Route 10).
- **Free to Use (Sword & Shield Style)**: No Pokédollars, Heart Scales, or mushrooms required — accessible from early game to postgame.
- **Missed Pre-Evolution Moves Restored**: Pokémon can relearn all natural level-up moves their current species **and** all prior evolutionary stages in their line could have learned up to their current level.
  - Fixes early stone evolution lockouts (e.g. Raichu evolving early can relearn Thunderbolt/Agility from Pikachu; Arcanine can relearn Flamethrower from Growlithe; Vileplume/Victreebel/Cloyster/Starmie/Nidoking/Nidoqueen never miss key moves).
- **Level 1 Base / Starting Moves**: Relearn any initial starting move (e.g., Charizard's Slash/Scratch/Ember, Blastoise's Bubble/Water Gun) at any level.
- **TM Tutor Mode (`RELEARN + TMS`)**: In addition to natural level-up moves, the Move Reminder can teach any compatible TM from TM01 to TM50 that the Pokémon (or any prior evolutionary stage in its evolutionary line) can learn.
  - HM moves (Cut, Fly, Surf, Strength, Flash) remain excluded from the TM tutor pool.
- **Move Replacement Flow**: Teaches directly if fewer than 4 moves are known, or opens an interactive selection screen to replace an existing move when at the 4-move limit.
- **Scrollable Party & Move Lists**: Seamlessly browse full 6-Pokémon parties and extensive move candidate lists with windowed scrolling and authentic direction indicators.
- **3-Way Options Menu Integration**: Configurable anytime under `OPTION ➔ OMNIQOL` (`RELEARNER`):
  - `[OFF]`: Move Relearner NPC is disabled.
  - `[RELEARN]`: Relearn natural level-up and missed pre-evolution moves.
  - `[REL+TMS]`: Relearn natural level-up moves + teach any compatible TM01–TM50 moves.

### Module 6: Forget HM Moves (Gen 1)
- **Freely Overwrite HM Moves**: Overwrites and replaces HM moves (Cut, Fly, Surf, Strength, Flash) whenever learning any new move (whether through Level-Up, TM items, or the Move Relearner).
- **No More Trapped Movesets**: Removes the permanent HM lock present in vanilla Gen 1, eliminating the need to save/carry dedicated HM slaves.
- **Dedicated Independent Toggle**: Separately toggleable under `OPTION ➔ OMNIQOL` (`FORGET HMS`), enabled by default.

### Module 7: Improved Inventory (Gen 1)
- **Expanded Bag Capacity**: Holds up to 99 unique items (expanded from vanilla 20), preserving standard 99 quantity stacks.
- **Expanded PC Item Storage**: Holds up to 99 unique items (expanded from vanilla 50), preventing storage bottlenecks when depositing items from the Bag.
- **Deterministic Automatic Sorting**:
  - Regular items and Key Items are always kept cleanly sorted in alphabetical order (A–Z).
  - TMs (`TM01` through `TM50`) and HMs (`HM01` through `HM05`) are grouped together at the bottom and sorted numerically.
- **Page-Jumping Navigation**: Press Left or Right on the D-Pad while browsing Bag or PC Item lists to jump by 5 items per press for rapid scrolling, preserving `SELECT` and standard controls.
- **Safe Toggle-OFF Protection**: Toggling OFF in the Options menu (`INVENTORY`) automatically deposits excess items (>20) to PC Item Storage. If PC storage cannot fit all excess items, disabling is safely blocked with a notification to prevent any item loss.

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).

---

## 🤖 AI Disclaimer
Portions of this codebase, architecture, and documentation were developed with the assistance of AI coding tools, paired with and reviewed by human developers. While every module is structured and tested for compatibility with the target recompilation engines, please report any issues or unexpected behaviors.
