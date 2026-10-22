import os
import re
import unittest

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

class TestHMsAndCore(unittest.TestCase):
    def test_forget_hms_contains_all_five_hms(self):
        path = os.path.join(ROOT_DIR, "mods", "modules", "forget_hms.lua")
        self.assertTrue(os.path.exists(path), "forget_hms.lua not found")
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()

        match = re.search(r"local\s+HM_MOVES\s*=\s*\{(.*?)\}", content, re.DOTALL)
        self.assertIsNotNone(match, "HM_MOVES table not found in forget_hms.lua")
        hms = set(re.findall(r'([A-Z0-9_]+)\s*=\s*true', match.group(1)))
        expected = {"CUT", "FLY", "SURF", "STRENGTH", "FLASH"}
        self.assertEqual(hms, expected, f"HM mismatch in forget_hms.lua: {hms} vs {expected}")

    def test_running_shoes_configuration(self):
        path = os.path.join(ROOT_DIR, "mods", "modules", "running.lua")
        self.assertTrue(os.path.exists(path), "running.lua not found")
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()

        self.assertIn('id = "running"', content)
        self.assertIn('label = "RUNNING"', content)
        self.assertIn("SPEED_FACTOR = 2", content)

    def test_exp_share_configuration(self):
        path = os.path.join(ROOT_DIR, "mods", "modules", "exp_share.lua")
        self.assertTrue(os.path.exists(path), "exp_share.lua not found")
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()

        self.assertIn('id = "exp_share"', content)
        self.assertIn('label = "EXP SHARE"', content)

    def test_all_modules_registered_in_init(self):
        path = os.path.join(ROOT_DIR, "mods", "init.lua")
        self.assertTrue(os.path.exists(path), "init.lua not found")
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()

        expected_modules = [
            "modules/running.lua",
            "modules/exp_share.lua",
            "modules/trade_evos.lua",
            "modules/catch_151.lua",
            "modules/move_relearner.lua",
            "modules/forget_hms.lua",
        ]
        for mod in expected_modules:
            self.assertIn(mod, content, f"Module {mod} not registered in init.lua")

if __name__ == "__main__":
    unittest.main()
