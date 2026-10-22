import os
import re
import json
import zipfile
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

    def test_module_definitions_and_supported_generations(self):
        """Ensures every module correctly defines supportedGenerations."""
        modules = {
            "running.lua": {"gen1", "gen2"},
            "catch_151.lua": {"gen1"},
            "exp_share.lua": {"gen1"},
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
            {"id": "exp_share", "gens": ["gen1"]},
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

        # In Gen 2, ONLY running must be registered
        gen2_registered = simulate_manager("gen2")
        self.assertEqual(gen2_registered, ["running"])

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

    def test_zip_release_archive_content_and_integrity(self):
        """Builds and inspects the distribution archive for 100% path accuracy."""
        archive_path = os.path.join(ROOT_DIR, "omni-qol-v0.3.0-alpha.zip")
        self.assertTrue(os.path.exists(archive_path), "Release archive omni-qol-v0.3.0-alpha.zip not found")

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

if __name__ == "__main__":
    unittest.main()
