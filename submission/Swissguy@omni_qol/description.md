# OmniQoL

**OmniQoL** is an all-in-one, cross-generation Quality of Life (QoL) suite built for Pokémon engine recreations, targeting [bryanthaboi/gen1recomp](https://github.com/bryanthaboi/gen1recomp). A single unified release works natively across both **Generation 1** (Red, Blue, Yellow) and **Generation 2** (Gold, Silver, Crystal).

Every feature is designed as an independent module that can be turned on or off directly within the game's Options menu (`OMNIQOL`), with preferences saved per save file.

---

### 🏃 Module 1: Running Shoes (Gen 1 & Gen 2)
- **Hold B to Run**: Doubles player overworld movement speed (from 16 to 8 frames per tile, matching the Bicycle).
- **Cross-Generation Support**: Fully functional across Pokémon Red, Blue, Yellow, Gold, Silver, and Crystal.
- **Pikachu Follower Synchronization (Yellow)**: Pikachu automatically matches player running speed (8 frames/tile), with a 4 frames/tile catch-up sprint if separated or turning corners. Happiness and mood step tracking function normally.
- **Usable Everywhere**: Full movement freedom indoors, outdoors, in caves, buildings, and the Safari Zone.
- **Fair Encounter Rates**: Standard walking encounter rates are preserved (no extra encounter penalty).
- **Scripted Cutscene & Escort Protection**: Automatically restores vanilla step duration when idle and during NPC escorts (e.g., Professor Oak escorting the player to the lab) to prevent cutscene desyncs.
- **State Preservation**: Normal Bicycle and Surfing speeds are preserved, as well as authentic Gen 2 Ice Path puzzle sliding physics.

### 🎓 Module 2: EXP Share (Gen 1 & Gen 2)
- **Modern Gen 6+ EXP Distribution**: Active battlers receive a full 100% EXP share each (Gen 8+ style, no switching dilution), while non-fainted benched party members receive 50% EXP. Fainted Pokémon receive 0 EXP.
- **Cross-Generation Support**: Fully functional across Pokémon Red, Blue, Yellow, Gold, Silver, and Crystal.
- **Full Stat EXP (Gen 6+ style)**: All party members earning EXP receive 100% of the defeated enemy's base stats as Stat EXP across all stats.
- **Streamlined Announcements**: Active battlers display standard dialogue; benched party members are cleanly announced via a single consolidated prompt (`"The rest of the team gained EXP!"`), eliminating repetitive dialogue boxes.
- **Native Level-Up Sequencing**: Any Pokémon that levels up immediately triggers its level-up fanfare, stat growth box, and move-learning dialogue.
- **Pure Software Toggle**: Enabled by default, occupying 0 Bag inventory slots; supersedes vanilla Gen 2 held Exp. Share while active.

### 🔄 Module 3: Trade Evolutions (Gen 1)
- **Level 40 Evolution**: Kadabra, Machoke, Graveler, and Haunter evolve naturally into Alakazam, Machamp, Golem, and Gengar upon reaching or gaining a level at Level 40+.
- **Level 100 Support (Gen 8+ Style)**: Using a Rare Candy on a Level 100 Pokémon triggers the evolution sequence without exceeding Level 100.
- **B-Button Cancellation**: Preserves authentic level-up behavior; players can cancel the evolution by pressing B during the sequence.
- **Trade Coexistence**: Traditional link-trading continues to trigger evolution normally.
- **Vanilla NPC Trades**: In-game NPC trades (e.g., Machoke in Pokémon Blue/Yellow) do not immediately auto-evolve upon receipt; they evolve upon their next level-up to 40+.

### ✨ Module 4: Catch All 151 Pokémon (Gen 1)
- **Wild Starters**: Bulbasaur (Route 2 & Viridian Forest), Charmander (Routes 3 & 4), and Squirtle (Routes 24 & 25) appear in the wild in thematic habitats across Kanto.
- **Cross-Version Exclusives**: All missing and version-exclusive Pokémon from Red, Blue, and Yellow are catchable across all three games in counterpart routes.
- **Safari Zone Exclusives Outside Safari Zone**: Chansey, Kangaskhan, Tauros, Scyther, Pinsir, Dratini, and Tangela spawn in overworld routes for standard battles and captures with regular Pokéballs.
- **Mutually Exclusive & Single-Choice Pokémon**: Wild encounters for unchosen fossils (Omanyte/Kabuto), Dojo fighters (Hitmonlee/Hitmonchan on Route 10 & Victory Road), wild Eevee (Routes 25, 8 & 17, enabling all 3 Eeveelutions), and trade-only species (Jynx, Farfetch'd, Mr. Mime, Lickitung, Porygon).
- **Immediate Legendary & Snorlax Respawns**: Articuno, Zapdos, Moltres, Mewtwo, and Snorlax immediately respawn upon exiting and re-entering their room or map if defeated or fled without catching.
- **Mythical Mew Encounter**: Stationary interactable Lv. 50 Mew rests on the deepest floor of Cerulean Cave (Unknown Dungeon B1F) with authentic cry and battle sequence, respawning on room re-entry if not caught.
- **Celadon Department Store Moon Stone**: Sold on 4F (Wiseman Gifts) alongside Fire, Water, Thunder, and Leaf Stones at standard ¥2,100 with infinite stock, ensuring Moon Stone evolutions are never blocked.
- **Options Menu Integration**: Toggleable on/off anytime under `OPTION ➔ OMNIQOL` (`CATCH 151`), enabled by default.

### 🧠 Module 5: Move Relearner (Gen 1)
- **Every Pokémon Center Across Kanto**: A distinguished Gentleman Move Reminder NPC appears in the lobby of all 12 Pokémon Centers (Viridian, Pewter, Cerulean, Vermilion, Lavender, Celadon, Fuchsia, Saffron, Cinnabar, Indigo Plateau, Route 4, and Route 10).
- **Free to Use**: Zero Pokédollar or item cost (Sword & Shield style).
- **Missed Pre-Evolution Moves**: Any Pokémon can relearn all level-up moves their current species and any earlier stages in their evolutionary line could have learned up to their current level (remedying early stone/trade evolutions).
- **Level 1 Base / Starting Moves**: Relearn any initial starting move at any level.
- **TM Tutor Mode (`RELEARN + TMS`)**: Teaches any compatible TM01–TM50 moves, including inherited compatibility from pre-evolutions.
  - HM moves (Cut, Fly, Surf, Strength, Flash) remain excluded from TM tutoring.
- **Interactive Move Replacement**: Teaches directly if fewer than 4 moves are known, or opens an interactive replacement screen.
- **Scrollable Party & Move Lists**: Full 6-Pokémon party support and move lists with windowed scrolling and indicator arrows.
- **3-Way Options Menu Integration**: Toggled directly under `OPTION ➔ OMNIQOL` (`RELEARNER`):
  - `[OFF]`: Disabled.
  - `[RELEARN]`: Natural level-up moves and pre-evolution moves.
  - `[REL+TMS]`: Natural level-up moves + all compatible TM01–TM50 moves.

### ✂️ Module 6: Forget HM Moves (Gen 1)
- **Freely Overwrite HM Moves**: Allows overwriting and forgetting HM moves (Cut, Fly, Surf, Strength, Flash) whenever learning any new move (via Level Up, TM items, or Move Relearner).
- **Eliminates Trapped Movesets**: Removes the permanent HM lock present in vanilla Gen 1.
- **Dedicated Toggle**: Separately toggleable under `OPTION ➔ OMNIQOL` (`FORGET HMS`), enabled by default.

### 🎒 Module 7: Improved Inventory (Gen 1)
- **99 Unique Bag Items**: Expands player inventory capacity from 20 up to 99 unique item slots, preserving standard 99 quantity stacks.
- **99 Unique PC Storage Items**: Expands PC Item Storage capacity from 50 up to 99 unique item slots to match the Bag and prevent storage bottlenecks.
- **Automatic Organization**: Regular items and Key Items are always kept strictly sorted in alphabetical order (A–Z), followed by TMs (`TM01`–`TM50`) and HMs (`HM01`–`HM05`) grouped in numerical sequence.
- **Page-Jumping Ergonomics**: Press Left or Right D-Pad while browsing Bag or PC Item lists to jump by 5 items per press, while keeping `SELECT` and standard inputs intact.
- **Safe Toggle-OFF Guard**: Toggling OFF in the Options menu automatically deposits excess items (>20) to PC Item Storage; if PC storage is full and cannot fit all excess items, disabling is safely blocked to protect player items against data loss.
- **Dedicated Toggle**: Separately toggleable under `OPTION ➔ OMNIQOL` (`INVENTORY`), enabled by default.

### ⚙️ Native Options Menu Integration (`OMNIQOL`)
- Injects an `OMNIQOL` entry directly into the native **Options Menu** (`OPTION`), accessible both in the overworld and on the Title Screen.
- Custom interactive UI screen allows cycling module values (e.g., `[ON ]`/`[OFF]` or `[RELEARN]`/`[REL+TMS]`/`[OFF]`) with an authentic Pokémon arrow cursor.
- Leaves the overworld Start Menu pure vanilla.
- Dynamically displays available modules based on the active game generation (e.g. `RUNNING` & `EXP SHARE` in Gen 2; all 7 modules in Gen 1).
- Settings are saved **per save file** during gameplay, and saved as **global defaults** when configured from the Title Screen.

---

### 🗺️ Multi-Game Rollout Roadmap
For each module, development follows a structured multi-generation sequence:
- [x] **Gen 1**: Pokémon Red & Blue *(Complete)*
- [x] **Gen 1**: Pokémon Yellow *(Complete)*
- [x] **Gen 2**: Pokémon Gold, Silver & Crystal *(Running Shoes & EXP Share Complete; remainder in progress)*
- [ ] **Gen 3**: Pokémon FireRed & LeafGreen ➔ Pokémon Ruby & Sapphire ➔ Pokémon Emerald

---

### 🔗 Links & Source Code
- **Repository**: [https://github.com/swissguy/OmniQoL](https://github.com/swissguy/OmniQoL)
- **Releases**: [https://github.com/swissguy/OmniQoL/releases](https://github.com/swissguy/OmniQoL/releases)
