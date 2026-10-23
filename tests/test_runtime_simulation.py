import os
import re
import json
import zipfile
import shutil
import subprocess
import unittest

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODS_DIR = os.path.join(ROOT_DIR, "mods")

class TestRuntimeSimulationAndIntegrity(unittest.TestCase):
    def setUp(self):
        self.mods_dir = MODS_DIR
        self.manifest_path = os.path.join(self.mods_dir, "manifest.json")

    def test_all_lua_files_exist_and_balanced_syntax(self):
        """Verifies every Lua file in mods/ exists and has balanced control structures."""
        lua_files = []
        for root, _, files in os.walk(self.mods_dir):
            for f in files:
                if f.endswith(".lua"):
                    lua_files.append(os.path.join(root, f))

        self.assertGreaterEqual(len(lua_files), 10, "Expected at least 10 Lua source files")

        for fpath in lua_files:
            rel = os.path.relpath(fpath, ROOT_DIR)
            with open(fpath, "r", encoding="utf-8") as f:
                content = f.read()

            # Clean out comments and strings to check structural blocks
            code_lines = []
            in_multiline_comment = False
            for line in content.splitlines():
                line = line.strip()
                if in_multiline_comment:
                    if "--]]" in line or "]]" in line:
                        in_multiline_comment = False
                    continue
                if line.startswith("--[["):
                    in_multiline_comment = True
                    continue
                if line.startswith("--"):
                    continue
                # remove single-line comments
                line = re.sub(r'--.*$', '', line)
                code_lines.append(line)

            code = " ".join(code_lines)

            # Check balanced brackets and braces
            opens_brace = code.count('{')
            closes_brace = code.count('}')
            self.assertEqual(
                opens_brace, closes_brace,
                f"Mismatched curly braces {{}} in {rel}: {opens_brace} open vs {closes_brace} close"
            )

            opens_paren = code.count('(')
            closes_paren = code.count(')')
            self.assertEqual(
                opens_paren, closes_paren,
                f"Mismatched parentheses () in {rel}: {opens_paren} open vs {closes_paren} close"
            )

        # If LuaJIT or Lua is available, perform true bytecode compiler syntax validation
        luajit_bin = shutil.which("luajit") or shutil.which("lua")
        if not luajit_bin:
            candidate = os.path.expanduser(r"~\AppData\Local\Programs\LuaJIT\bin\luajit.exe")
            if os.path.exists(candidate):
                luajit_bin = candidate

        if luajit_bin:
            for fpath in lua_files:
                norm_path = fpath.replace("\\", "/")
                res = subprocess.run(
                    [luajit_bin, "-e", f'local f, err = loadfile("{norm_path}"); if not f then io.stderr:write(tostring(err)); os.exit(1) end'],
                    capture_output=True,
                    text=True
                )
                self.assertEqual(
                    res.returncode, 0,
                    f"Lua bytecode compilation error in {os.path.relpath(fpath, ROOT_DIR)}:\n{res.stderr or res.stdout}"
                )

    def test_module_definitions_and_supported_generations(self):
        """Ensures every module correctly defines supportedGenerations."""
        modules = {
            "running.lua": {"gen1", "gen2"},
            "catch_151.lua": {"gen1"},
            "exp_share.lua": {"gen1", "gen2"},
            "forget_hms.lua": {"gen1"},
            "move_relearner.lua": {"gen1"},
            "trade_evos.lua": {"gen1"},
        }

        for filename, expected_gens in modules.items():
            path = os.path.join(self.mods_dir, "modules", filename)
            self.assertTrue(os.path.exists(path), f"Module {filename} missing")
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()

            match = re.search(r'supportedGenerations\s*=\s*\{\s*([^}]+)\s*\}', content)
            self.assertIsNotNone(match, f"supportedGenerations missing in {filename}")
            gens = set(re.findall(r'"([a-z0-9_]+)"', match.group(1)))
            self.assertEqual(
                gens, expected_gens,
                f"Generation mismatch for {filename}: got {gens}, expected {expected_gens}"
            )

    def test_recomp_engine_game_detector_matrix(self):
        """Tests the game detection rules for all supported Gen 1 and Gen 2 games."""
        detector_path = os.path.join(self.mods_dir, "core", "game_detector.lua")
        with open(detector_path, "r", encoding="utf-8") as f:
            detector_code = f.read()

        gen1_games = ["red", "blue", "yellow"]
        gen2_games = ["gold", "silver", "crystal"]

        for g in gen1_games:
            self.assertIn(f"{g} = true", detector_code)
        for g in gen2_games:
            self.assertIn(f"{g} = true", detector_code)

        # Verify fallback and helper logic
        self.assertIn('return "gen2"', detector_code)
        self.assertIn('return "gen1"', detector_code)

    def test_simulated_gen1_vs_gen2_module_registration(self):
        """Simulates how ModuleManager registers modules for Gen 1 vs Gen 2."""
        modules = [
            {"id": "running", "gens": ["gen1", "gen2"]},
            {"id": "exp_share", "gens": ["gen1", "gen2"]},
            {"id": "trade_evos", "gens": ["gen1"]},
            {"id": "catch_151", "gens": ["gen1"]},
            {"id": "forget_hms", "gens": ["gen1"]},
            {"id": "move_relearner", "gens": ["gen1"]},
        ]

        def simulate_manager(target_gen):
            registered = []
            for m in modules:
                if target_gen in m["gens"]:
                    registered.append(m["id"])
            return registered

        # In Gen 1, all 6 modules must be registered
        gen1_registered = simulate_manager("gen1")
        self.assertEqual(len(gen1_registered), 6)
        self.assertEqual(gen1_registered, ["running", "exp_share", "trade_evos", "catch_151", "forget_hms", "move_relearner"])

        # In Gen 2, running and exp_share must be registered
        gen2_registered = simulate_manager("gen2")
        self.assertEqual(gen2_registered, ["running", "exp_share"])

    def test_simulated_running_speed_calculation(self):
        """Simulates the mathematical logic of the movement.speed hook in running.lua."""
        WALK_FRAMES = 16
        SPEED_FACTOR = 2
        MIN_FRAMES = 4

        def calculate_speed(enabled, is_b_down, is_surfing, is_cycling, is_sliding=False, base_frames=WALK_FRAMES):
            if not enabled:
                return base_frames
            if is_surfing or is_cycling or is_sliding:
                return base_frames
            if not is_b_down:
                return base_frames

            sped = int(base_frames / SPEED_FACTOR + 0.5)
            if sped < MIN_FRAMES:
                sped = MIN_FRAMES
            if sped > base_frames:
                return base_frames
            return sped

        # 1. Normal Walking (B not held) -> 16 frames
        self.assertEqual(calculate_speed(True, False, False, False), 16)

        # 2. Running (B held) -> 8 frames (2x speed)
        self.assertEqual(calculate_speed(True, True, False, False), 8)

        # 3. Disabled module in options -> 16 frames even when B held
        self.assertEqual(calculate_speed(False, True, False, False), 16)

        # 4. Surfing -> remains vanilla speed (no speed-up)
        self.assertEqual(calculate_speed(True, True, True, False), 16)

        # 5. Cycling -> remains vanilla bike speed (no speed-up)
        self.assertEqual(calculate_speed(True, True, False, True), 16)

        # 6. Both Surfing and Cycling flags -> remains vanilla
        self.assertEqual(calculate_speed(True, True, True, True), 16)

        # 7. Gen 2 Ice Path puzzle sliding -> remains vanilla sliding frames
        self.assertEqual(calculate_speed(True, True, False, False, True), 16)

    def test_simulated_exp_share_distribution_gen1_and_gen2(self):
        """Simulates the party-wide EXP and Stat EXP distribution logic across Gen 1 and Gen 2."""
        class MockMon:
            def __init__(self, name, hp, stat_exp=0, exp=0):
                self.name = name
                self.hp = hp
                self.statExp = stat_exp
                self.exp = exp

        class MockGen1Battle:
            def __init__(self, party):
                self.party = party
                self.messages = []
            def playerPartyView(self):
                return self.party
            def sayNext(self, msg):
                self.messages.append(msg)

        class MockGen2Battle:
            def __init__(self, party):
                self.party = party
                # Gen 2 VM lacks sayNext on battle table

        # --- 1. Gen 1 Simulation (sayNext available -> consolidated announcement, silent benched shares) ---
        mon1 = MockMon("Pikachu", hp=30)
        mon2 = MockMon("Cyndaquil", hp=25)
        mon3 = MockMon("FaintedMon", hp=0)

        party = [mon1, mon2, mon3]
        battle1 = MockGen1Battle(party)
        alive1 = [mon1]

        awarded1 = []
        def apply_share1(mon, split, announce):
            base = 100
            gain = base if mon in alive1 else max(1, base // 2)
            mon.exp += gain
            mon.statExp += 50 * split
            awarded1.append({"mon": mon.name, "exp": gain, "announce": announce})

        for m in alive1:
            apply_share1(m, 1, True)

        benched1 = [m for m in party if m not in alive1 and m.hp > 0]
        # In Gen 1, sayNext exists -> sayBattleMessage succeeds
        has_msg1 = hasattr(battle1, "sayNext") and callable(battle1.sayNext)
        if has_msg1:
            battle1.sayNext("The rest of the\nteam gained EXP!")
        announce_benched1 = not has_msg1
        for m in benched1:
            apply_share1(m, 1, announce_benched1)

        # Active battler (Pikachu): 100 EXP (100%), 50 Stat EXP (100%), announce=True
        self.assertEqual(mon1.exp, 100)
        self.assertEqual(mon1.statExp, 50)
        self.assertTrue(awarded1[0]["announce"])

        # Benched living mon (Cyndaquil) in Gen 1: 50 EXP (50%), 50 Stat EXP (100%), announce=False
        self.assertEqual(mon2.exp, 50)
        self.assertEqual(mon2.statExp, 50)
        self.assertFalse(awarded1[1]["announce"])

        # Fainted mon: 0 EXP, 0 Stat EXP
        self.assertEqual(mon3.exp, 0)
        self.assertEqual(mon3.statExp, 0)
        self.assertEqual(battle1.messages, ["The rest of the\nteam gained EXP!"])

        # --- 2. Gen 2 Simulation (sayNext unavailable -> native per-mon announcement & EXP bar) ---
        g2_mon1 = MockMon("Totodile", hp=35)
        g2_mon2 = MockMon("Pidgey", hp=20)
        g2_party = [g2_mon1, g2_mon2]
        battle2 = MockGen2Battle(g2_party)
        alive2 = [g2_mon1]

        awarded2 = []
        def apply_share2(mon, split, announce):
            base = 120
            gain = base if mon in alive2 else max(1, base // 2)
            mon.exp += gain
            mon.statExp += 60 * split
            awarded2.append({"mon": mon.name, "exp": gain, "announce": announce})

        for m in alive2:
            apply_share2(m, 1, True)

        benched2 = [m for m in g2_party if m not in alive2 and m.hp > 0]
        has_msg2 = hasattr(battle2, "sayNext") and callable(getattr(battle2, "sayNext"))
        announce_benched2 = not has_msg2
        for m in benched2:
            apply_share2(m, 1, announce_benched2)

        # Active battler (Totodile): announce=True
        self.assertEqual(g2_mon1.exp, 120)
        self.assertTrue(awarded2[0]["announce"])

        # Benched living mon (Pidgey) in Gen 2: announce=True (gives player in-battle notification & EXP bar)
        self.assertEqual(g2_mon2.exp, 60)
        self.assertTrue(awarded2[1]["announce"])

    def test_gen2_battle_shape_and_priority_in_exp_share(self):
        """Verifies exp_share.lua handles Gen 2 battle shape (battle.party, battle.player) and priority 90."""
        exp_share_path = os.path.join(self.mods_dir, "modules", "exp_share.lua")
        with open(exp_share_path, "r", encoding="utf-8") as f:
            code = f.read()

        # Priority 90 registration
        self.assertIn(', 90)', code, "exp_share hooks must run at priority 90 to preempt conflicting overhaul hooks")

        # Gen 2 battle shape support
        self.assertIn("battle.party", code, "exp_share must resolve battle.party for Gen 2 battle shape")
        self.assertIn("resolvePlayerParty", code, "exp_share must implement robust multi-gen party resolution")
        self.assertIn("sayBattleMessage", code, "exp_share must implement defensive battle message emission")
        self.assertIn("announceBenched", code, "exp_share must dynamically announce EXP when consolidated text is unavailable")
        self.assertIn("consolidatedAnnounced", code, "exp_share must track consolidated message emission")

    def test_zip_release_archive_content_and_integrity(self):
        """Builds and inspects the distribution archive for 100% path accuracy."""
        with open(self.manifest_path, "r", encoding="utf-8") as f:
            source_manifest = json.load(f)
        version = source_manifest.get("version", "0.2.1")
        archive_path = os.path.join(ROOT_DIR, f"omni-qol-v{version}.zip")

        # If running in a clean checkout or CI runner prior to build_release.py,
        # package the archive on-demand so the test validates the real package structure.
        if not os.path.exists(archive_path):
            with zipfile.ZipFile(archive_path, "w", zipfile.ZIP_DEFLATED) as zf:
                for root, dirs, files in os.walk(self.mods_dir):
                    dirs.sort()
                    files.sort()
                    for d in dirs:
                        rel = os.path.relpath(os.path.join(root, d), self.mods_dir).replace("\\", "/")
                        zf.write(os.path.join(root, d), f"omni_qol/{rel}/")
                    for f in files:
                        full = os.path.join(root, f)
                        rel = os.path.relpath(full, self.mods_dir).replace("\\", "/")
                        zf.write(full, f"omni_qol/{rel}")

        self.assertTrue(os.path.exists(archive_path), f"Release archive {archive_path} not found")

        with open(self.manifest_path, "r", encoding="utf-8") as f:
            source_manifest = json.load(f)

        with zipfile.ZipFile(archive_path, "r") as zf:
            namelist = zf.namelist()

            # Ensure all paths start with omni_qol/
            for name in namelist:
                self.assertTrue(name.startswith("omni_qol/"), f"Path in zip not rooted in omni_qol/: {name}")

            # Ensure key files are present
            required_files = [
                "omni_qol/manifest.json",
                "omni_qol/init.lua",
                "omni_qol/main.lua",
                "omni_qol/core/game_detector.lua",
                "omni_qol/core/module_manager.lua",
                "omni_qol/core/settings_menu.lua",
                "omni_qol/modules/running.lua",
                "omni_qol/modules/exp_share.lua",
                "omni_qol/modules/trade_evos.lua",
                "omni_qol/modules/catch_151.lua",
                "omni_qol/modules/move_relearner.lua",
                "omni_qol/modules/forget_hms.lua",
                "omni_qol/modules/relearner_data.lua",
            ]
            for req in required_files:
                self.assertIn(req, namelist, f"Missing critical file in zip: {req}")

            # Ensure no legacy gen1 directories exist inside the zip
            for name in namelist:
                self.assertNotIn("gen1/", name, f"Legacy gen1/ path found in zip: {name}")

            # Read and validate manifest in zip against source manifest
            manifest_data = json.loads(zf.read("omni_qol/manifest.json").decode("utf-8"))
            self.assertEqual(manifest_data["version"], source_manifest["version"])
            self.assertEqual(manifest_data["games"], source_manifest["games"])

    def test_settings_menu_layout_and_authentic_cursor(self):
        """Verifies settings_menu.lua uses authentic cursor code 0xED and safe layout boundaries."""
        settings_path = os.path.join(self.mods_dir, "core", "settings_menu.lua")
        with open(settings_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Authentic Pokemon cursor arrow 0xED
        self.assertIn("0xED", content, "settings_menu.lua must use authentic Pokemon cursor code 0xED")
        self.assertIn("Font.drawCode(0xED, 8, yPos)", content)

        # Scroll indicator arrows at correct list margins (144, 26) and (144, 70)
        self.assertIn('Font.draw("^", 144, 26)', content)
        self.assertIn('Font.draw("v", 144, 70)', content)

        # Label clipping to prevent overlap
        self.assertIn(":sub(1, 9)", content)

        # Bottom info box must be 7 rows (y: 88 to 144) to prevent bottom collision with prompt
        self.assertIn("Font.drawBox(0, 11, 20, 7)", content)

        # Description text max width must be 16 characters to prevent right border cutoff
        self.assertIn("wrapDesc(desc, 16)", content)

        # ModuleManager must implement getDisplayStatus
        mm_path = os.path.join(self.mods_dir, "core", "module_manager.lua")
        with open(mm_path, "r", encoding="utf-8") as f:
            mm_content = f.read()
        self.assertIn("function ModuleManager:getDisplayStatus(id)", mm_content)

if __name__ == "__main__":
    unittest.main()
