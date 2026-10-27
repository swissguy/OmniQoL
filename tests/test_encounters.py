import os
import re
import unittest

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CATCH_151_PATH = os.path.join(ROOT_DIR, "mods", "modules", "catch_151.lua")
GUIDE_PATH = os.path.join(ROOT_DIR, "POKEDEX_151_GUIDE.md")

def parse_route_rosters(content):
    content = content.replace("\r\n", "\n")
    rosters_match = re.search(r"local\s+ROUTE_ROSTERS\s*=\s*\{(.*?)\n\}\n\n--", content, re.DOTALL)
    assert rosters_match, "ROUTE_ROSTERS table not found in catch_151.lua"
    rosters_text = rosters_match.group(1)

    rosters = {}
    route_blocks = re.findall(r'([A-Z0-9_]+)\s*=\s*\{\s*mode\s*=\s*"([^"]+)",\s*(?:--[^\n]*\n\s*)?grass\s*=\s*\{(.*?)\},\s*\},?', rosters_text, re.DOTALL)
    for route_name, mode, grass_body in route_blocks:
        entries = []
        for line in grass_body.strip().splitlines():
            line = line.strip()
            if not line or line.startswith("--"):
                continue
            sm = re.search(r'species\s*=\s*"([A-Z0-9_]+)"', line)
            min_lvl = re.search(r'minLevel\s*=\s*(\d+)', line)
            max_lvl = re.search(r'maxLevel\s*=\s*(\d+)', line)
            weight_m = re.search(r'weight\s*=\s*(\d+(?:\.\d+)?)', line)

            if sm and min_lvl and max_lvl:
                entries.append({
                    "species": sm.group(1),
                    "minLevel": int(min_lvl.group(1)),
                    "maxLevel": int(max_lvl.group(1)),
                    "weight": float(weight_m.group(1)) if weight_m else None,
                    "raw_line": line,
                })
        rosters[route_name] = {
            "mode": mode,
            "grass": entries,
        }
    return rosters

def parse_wild_additions(content):
    content = content.replace("\r\n", "\n")
    match = re.search(r"local\s+WILD_ADDITIONS\s*=\s*\{(.*?)\n\}\n\n", content, re.DOTALL)
    if not match:
        return {}
    res = {}
    for block in re.finditer(r'([A-Z0-9_]+)\s*=\s*\{(.*?)\},', match.group(1), re.DOTALL):
        rname = block.group(1)
        terrains = set(re.findall(r'type\s*=\s*["\']([^"\']+)["\']', block.group(2)))
        res[rname] = terrains
    return res

def parse_completed_guide_routes(guide_text):
    completed = []
    lines = guide_text.replace("\r\n", "\n").splitlines()
    for line in lines:
        if line.startswith("| ✅"):
            parts = [p.strip() for p in line.split("|")[1:-1]]
            if len(parts) >= 3:
                raw_loc = parts[0]
                terrain = parts[1]
                mon_str = parts[2]
                completed.append({
                    "raw_location": raw_loc,
                    "terrain": terrain,
                    "pokemon_str": mon_str,
                })
    return completed

class TestEncounters(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        with open(CATCH_151_PATH, "r", encoding="utf-8") as f:
            cls.lua_content = f.read()
        with open(GUIDE_PATH, "r", encoding="utf-8") as f:
            cls.guide_content = f.read()

        cls.rosters = parse_route_rosters(cls.lua_content)
        cls.wild_additions_terrains = parse_wild_additions(cls.lua_content)
        cls.completed_routes = parse_completed_guide_routes(cls.guide_content)

    def test_rosters_parsed_successfully(self):
        self.assertGreater(len(self.rosters), 0, "No rosters found in ROUTE_ROSTERS")
        expected_routes = ["ROUTE_2", "ROUTE_22", "VIRIDIAN_FOREST", "ROUTE_3", "MT_MOON_1F", "MT_MOON_B1F", "MT_MOON_B2F", "ROUTE_4", "ROUTE_24", "ROUTE_25", "ROUTE_5", "ROUTE_6", "ROUTE_11", "ROUTE_9", "ROUTE_10", "ROCK_TUNNEL_1F", "ROCK_TUNNEL_B1F", "ROUTE_8"]
        for r in expected_routes:
            self.assertIn(r, self.rosters, f"Expected {r} in ROUTE_ROSTERS")

    def test_roster_schema_and_level_bounds(self):
        for route_name, data in self.rosters.items():
            mode = data["mode"]
            self.assertIn(mode, ["uniform", "weighted"], f"{route_name}: Invalid mode '{mode}'")
            entries = data["grass"]
            self.assertGreater(len(entries), 0, f"{route_name}: Roster cannot be empty")

            for entry in entries:
                sp = entry["species"]
                min_l = entry["minLevel"]
                max_l = entry["maxLevel"]

                self.assertTrue(sp.isupper(), f"{route_name}: Species '{sp}' must be uppercase")
                self.assertGreaterEqual(min_l, 1, f"{route_name}: minLevel for {sp} must be >= 1")
                self.assertLessEqual(max_l, 100, f"{route_name}: maxLevel for {sp} must be <= 100")
                self.assertLessEqual(min_l, max_l, f"{route_name}: minLevel {min_l} exceeds maxLevel {max_l} for {sp}")

                if mode == "weighted":
                    self.assertIsNotNone(entry["weight"], f"{route_name}: {sp} must have weight in 'weighted' mode")
                    self.assertGreater(entry["weight"], 0, f"{route_name}: {sp} weight must be > 0")

    def test_roster_probability_distribution(self):
        for route_name, data in self.rosters.items():
            mode = data["mode"]
            entries = data["grass"]
            n = len(entries)

            if mode == "uniform":
                probabilities = [1.0 / n] * n
                total_prob = sum(probabilities)
                self.assertAlmostEqual(total_prob, 1.0, places=4, msg=f"{route_name}: Total uniform probability != 1.0")
            elif mode == "weighted":
                total_weight = sum(e["weight"] for e in entries)
                self.assertGreater(total_weight, 0)
                probabilities = [e["weight"] / total_weight for e in entries]
                total_prob = sum(probabilities)
                self.assertAlmostEqual(total_prob, 1.0, places=4, msg=f"{route_name}: Total weighted probability != 1.0")

    def test_cross_version_parity_no_game_restrictions(self):
        for route_name, data in self.rosters.items():
            for entry in data["grass"]:
                raw = entry["raw_line"]
                self.assertNotIn("game =", raw, f"{route_name}: Version parity violation in {raw}")

    def test_no_conflicting_wild_additions_for_completed_routes(self):
        for route_name in self.rosters.keys():
            legacy_terrains = self.wild_additions_terrains.get(route_name, set())
            self.assertNotIn("grass", legacy_terrains,
                             f"{route_name} is defined in ROUTE_ROSTERS (grass) but still has legacy 'grass' in WILD_ADDITIONS")

    def test_guide_synchronization_for_completed_routes(self):
        guide_to_roster_keys = {
            "Route 2": ["ROUTE_2"],
            "Route 22": ["ROUTE_22"],
            "Viridian Forest": ["VIRIDIAN_FOREST"],
            "Route 3": ["ROUTE_3"],
            "Mt. Moon (1F–B2F)": ["MT_MOON_1F", "MT_MOON_B1F", "MT_MOON_B2F"],
            "Route 4": ["ROUTE_4"],
            "Route 24": ["ROUTE_24"],
            "Route 25": ["ROUTE_25"],
            "Route 5": ["ROUTE_5"],
            "Route 6": ["ROUTE_6"],
            "Route 11": ["ROUTE_11"],
            "Route 9": ["ROUTE_9"],
            "Route 10": ["ROUTE_10"],
            "Rock Tunnel (1F & B1F)": ["ROCK_TUNNEL_1F", "ROCK_TUNNEL_B1F"],
            "Route 8": ["ROUTE_8"],
        }

        for comp in self.completed_routes:
            loc_text = comp["raw_location"]
            name_match = re.search(r"\*\*(.*?)\*\*", loc_text)
            if not name_match:
                continue
            name = name_match.group(1).strip()
            if name in ["Route 1", "Diglett's Cave", "Pokémon Tower"]:
                continue

            self.assertIn(name, guide_to_roster_keys, f"Completed route '{name}' has no known roster mapping")
            keys = guide_to_roster_keys[name]
            for key in keys:
                self.assertIn(key, self.rosters, f"Completed route {name} ({key}) missing from ROUTE_ROSTERS")

if __name__ == "__main__":
    unittest.main()
