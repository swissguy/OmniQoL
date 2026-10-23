import os
import re
import json
import unittest

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

class TestGen2RunningAndArchitecture(unittest.TestCase):
    def setUp(self):
        self.mods_dir = os.path.join(ROOT_DIR, "mods")
        self.manifest_path = os.path.join(self.mods_dir, "manifest.json")
        self.detector_path = os.path.join(self.mods_dir, "core", "game_detector.lua")
        self.manager_path = os.path.join(self.mods_dir, "core", "module_manager.lua")
        self.running_path = os.path.join(self.mods_dir, "modules", "running.lua")
        self.exp_share_path = os.path.join(self.mods_dir, "modules", "exp_share.lua")
        self.init_path = os.path.join(self.mods_dir, "init.lua")

    def test_game_detector_definitions(self):
        self.assertTrue(os.path.exists(self.detector_path), "game_detector.lua not found")
        with open(self.detector_path, "r", encoding="utf-8") as f:
            content = f.read()

        for g in ["red", "blue", "yellow"]:
            self.assertIn(f"{g} = true", content, f"Gen 1 game {g} not in detector")
        for g in ["gold", "silver", "crystal"]:
            self.assertIn(f"{g} = true", content, f"Gen 2 game {g} not in detector")

        self.assertIn("function GameDetector.detectGame", content)
        self.assertIn("function GameDetector.detectGeneration", content)
        self.assertIn("function GameDetector.isGen1", content)
        self.assertIn("function GameDetector.isGen2", content)

    def test_module_manager_generation_filtering(self):
        self.assertTrue(os.path.exists(self.manager_path), "module_manager.lua not found")
        with open(self.manager_path, "r", encoding="utf-8") as f:
            content = f.read()

        self.assertIn("entry.supportedGenerations", content, "Generation filtering missing from ModuleManager")
        self.assertIn("getGeneration", content, "getGeneration missing from ModuleManager")
        self.assertIn("getGame", content, "getGame missing from ModuleManager")

    def test_running_module_supports_gen1_and_gen2(self):
        self.assertTrue(os.path.exists(self.running_path), "running.lua not found")
        with open(self.running_path, "r", encoding="utf-8") as f:
            content = f.read()

        self.assertIn('supportedGenerations = { "gen1", "gen2" }', content)
        self.assertIn("SPEED_FACTOR = 2", content)
        self.assertIn("isMountedOrSurfingOrSliding", content)
        self.assertIn("isBDown", content)

    def test_exp_share_module_supports_gen1_and_gen2(self):
        self.assertTrue(os.path.exists(self.exp_share_path), "exp_share.lua not found")
        with open(self.exp_share_path, "r", encoding="utf-8") as f:
            content = f.read()

        self.assertIn('supportedGenerations = { "gen1", "gen2" }', content)
        self.assertIn('id = "exp_share"', content)
        self.assertIn('label = "EXP SHARE"', content)

    def test_gen1_modules_gated_to_gen1(self):
        gen1_exclusive = [
            "catch_151.lua",
            "forget_hms.lua",
            "move_relearner.lua",
            "trade_evos.lua"
        ]
        for filename in gen1_exclusive:
            path = os.path.join(self.mods_dir, "modules", filename)
            self.assertTrue(os.path.exists(path), f"{filename} not found")
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
            self.assertIn(
                'supportedGenerations = { "gen1" }',
                content,
                f"Module {filename} must be gated with supportedGenerations = {{ 'gen1' }}"
            )

    def test_init_lua_integrates_detector_and_logging(self):
        self.assertTrue(os.path.exists(self.init_path), "init.lua not found")
        with open(self.init_path, "r", encoding="utf-8") as f:
            content = f.read()

        self.assertIn("core/game_detector.lua", content)
        self.assertIn("ModuleManager.new(mod, GameDetector)", content)
        self.assertIn("gen == \"gen2\"", content)
        self.assertIn("mod.exports = manager", content)

    def test_manifest_version_and_games(self):
        with open(self.manifest_path, "r", encoding="utf-8") as f:
            manifest = json.load(f)

        self.assertEqual(manifest["version"], "0.2.1")
        expected_games = ["gen1", "gen2", "red", "blue", "yellow", "gold", "silver", "crystal"]
        self.assertEqual(manifest["games"], expected_games)

    def test_build_release_targets_cross_gen_zip(self):
        builder_path = os.path.join(ROOT_DIR, "scripts", "build_release.py")
        with open(builder_path, "r", encoding="utf-8") as f:
            content = f.read()

        self.assertIn('omni-qol-v{version}.zip', content)
        self.assertNotIn('omni-qol-gen1-v', content)

if __name__ == "__main__":
    unittest.main()
