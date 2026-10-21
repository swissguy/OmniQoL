import os
import json
import unittest

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

class TestManifest(unittest.TestCase):
    def setUp(self):
        self.manifest_path = os.path.join(ROOT_DIR, "mods", "gen1", "manifest.json")
        self.assertTrue(os.path.exists(self.manifest_path), "manifest.json does not exist")
        with open(self.manifest_path, "r", encoding="utf-8") as f:
            self.manifest = json.load(f)

    def test_required_fields(self):
        required_keys = ["id", "name", "version", "entry", "api", "games", "priority", "description"]
        for key in required_keys:
            self.assertIn(key, self.manifest, f"Missing required key in manifest: {key}")

    def test_metadata_values(self):
        self.assertEqual(self.manifest["id"], "omni_qol")
        self.assertEqual(self.manifest["name"], "OmniQoL")
        self.assertRegex(self.manifest["version"], r"^\d+\.\d+\.\d+(-[a-zA-Z0-9]+)?$")
        self.assertEqual(self.manifest["games"], ["red", "blue", "yellow"])
        self.assertEqual(self.manifest["api"], 2)

    def test_entry_files_exist(self):
        gen1_dir = os.path.join(ROOT_DIR, "mods", "gen1")
        entry_file = os.path.join(gen1_dir, self.manifest["entry"])
        self.assertTrue(os.path.exists(entry_file), f"Entry point {self.manifest['entry']} not found")
        main_shim = os.path.join(gen1_dir, "main.lua")
        self.assertTrue(os.path.exists(main_shim), "main.lua loader shim not found")

if __name__ == "__main__":
    unittest.main()
