import os
import re
import unittest

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

class TestTradeEvos(unittest.TestCase):
    def setUp(self):
        self.file_path = os.path.join(ROOT_DIR, "mods", "gen1", "modules", "trade_evos.lua")
        self.assertTrue(os.path.exists(self.file_path), "trade_evos.lua does not exist")
        with open(self.file_path, "r", encoding="utf-8") as f:
            self.content = f.read()

    def test_evolution_level(self):
        match = re.search(r"local\s+EVOLUTION_LEVEL\s*=\s*(\d+)", self.content)
        self.assertIsNotNone(match, "EVOLUTION_LEVEL constant not found")
        level = int(match.group(1))
        self.assertEqual(level, 40, f"Expected trade evolution level to be 40, got {level}")

    def test_trade_species_mapping(self):
        match = re.search(r"local\s+TRADE_SPECIES\s*=\s*\{(.*?)\}", self.content, re.DOTALL)
        self.assertIsNotNone(match, "TRADE_SPECIES table not found")
        species_text = match.group(1)
        mappings = dict(re.findall(r'([A-Z0-9_]+)\s*=\s*"([A-Z0-9_]+)"', species_text))

        expected = {
            "KADABRA": "ALAKAZAM",
            "MACHOKE": "MACHAMP",
            "GRAVELER": "GOLEM",
            "HAUNTER": "GENGAR",
        }
        self.assertEqual(mappings, expected, f"Trade species mapping mismatch: {mappings}")

    def test_module_registration(self):
        self.assertIn('id = "trade_evos"', self.content)
        self.assertIn('label = "TRADE EVOS"', self.content)
        self.assertIn('default = true', self.content)

if __name__ == "__main__":
    unittest.main()
