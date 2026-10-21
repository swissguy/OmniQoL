import os
import re
import unittest

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_PATH = os.path.join(ROOT_DIR, "mods", "gen1", "modules", "relearner_data.lua")

def load_data_tables():
    with open(DATA_PATH, "r", encoding="utf-8") as f:
        content = f.read()

    # Parse Ancestry
    ancestry_match = re.search(r"RelearnerData\.ANCESTRY = \{(.*?)\n\}", content, re.DOTALL)
    assert ancestry_match, "Ancestry table not found"
    ancestry_text = ancestry_match.group(1)
    ancestry = {}
    for line in ancestry_text.strip().splitlines():
        line = line.strip()
        m = re.match(r'([A-Z0-9_]+)\s*=\s*\{\s*(.*?)\s*\},?', line)
        if m:
            species = m.group(1)
            raw_anc = m.group(2)
            ancestors = [x.strip().strip('"').strip("'") for x in raw_anc.split(",") if x.strip()]
            ancestry[species] = ancestors

    # Parse Learnsets
    learnsets_match = re.search(r"RelearnerData\.LEARNSETS = \{(.*?)\n\}", content, re.DOTALL)
    assert learnsets_match, "Learnsets table not found"
    learnsets_text = learnsets_match.group(1)

    learnsets = {}
    current_species = None
    current_entries = []

    for line in learnsets_text.splitlines():
        sm = re.match(r'^\s*([A-Z0-9_]+)\s*=\s*\{', line)
        if sm:
            if current_species:
                learnsets[current_species] = current_entries
            current_species = sm.group(1)
            current_entries = []
            continue

        em = re.search(r'\{\s*level\s*=\s*(\d+),\s*move\s*=\s*"([A-Z0-9_]+)"\s*\}', line)
        if em and current_species:
            current_entries.append({"level": int(em.group(1)), "move": em.group(2)})

    if current_species:
        learnsets[current_species] = current_entries

    # Parse HM moves
    hm_match = re.search(r"RelearnerData\.HM_MOVES = \{(.*?)\n\}", content, re.DOTALL)
    assert hm_match, "HM_MOVES not found"
    hm_moves = set(re.findall(r'([A-Z0-9_]+)\s*=\s*true', hm_match.group(1)))

    # Parse TM_MOVES
    tm_match = re.search(r"RelearnerData\.TM_MOVES = \{(.*?)\n\}", content, re.DOTALL)
    assert tm_match, "TM_MOVES not found"
    tm_moves = dict(re.findall(r'([A-Z0-9_]+)\s*=\s*"(TM\d+)"', tm_match.group(1)))

    # Parse TMHM_LEARNSETS
    tmhm_match = re.search(r"RelearnerData\.TMHM_LEARNSETS = \{(.*?)\n\}", content, re.DOTALL)
    assert tmhm_match, "TMHM_LEARNSETS not found"
    tmhm_sets = {}
    for line in tmhm_match.group(1).splitlines():
        sm = re.match(r'^\s*([A-Z0-9_]+)\s*=\s*\{\s*(.*?)\s*\},?', line)
        if sm:
            sp = sm.group(1)
            mvs = [x.strip().strip('"') for x in sm.group(2).split(",") if x.strip()]
            tmhm_sets[sp] = mvs

    return ancestry, learnsets, hm_moves, tm_moves, tmhm_sets

def simulate_get_eligible_moves(mon, ancestry_map, learnsets_map, hm_moves, tm_moves, tmhm_sets, mode="RELEARN"):
    mode = mode.upper()
    if mode == "OFF":
        return []

    species = mon["species"].upper()
    level = mon.get("level", 100)
    known = set(mon.get("moves", []))

    stages = [species] + ancestry_map.get(species, [])
    eligible = []
    seen = set()

    # 1. Level-up
    for st in stages:
        ls = learnsets_map.get(st, [])
        for entry in ls:
            req_lvl = entry["level"]
            mv = entry["move"]
            if (req_lvl <= level or req_lvl == 1) and mv not in known and mv not in seen:
                seen.add(mv)
                eligible.append({
                    "name": mv,
                    "level": req_lvl,
                    "badge": "Lv 1" if req_lvl == 1 else f"Lv {req_lvl}",
                    "isTM": False,
                    "fromStage": st,
                })

    # 2. TMs if mode == "RELEARN+TMS"
    if "TM" in mode:
        tm_candidates = []
        for st in stages:
            tms = tmhm_sets.get(st, [])
            for mv in tms:
                tm_code = tm_moves.get(mv)
                if tm_code and mv not in hm_moves and mv not in known and mv not in seen:
                    seen.add(mv)
                    tm_candidates.append({
                        "name": mv,
                        "tmCode": tm_code,
                        "badge": tm_code,
                        "isTM": True,
                        "fromStage": st,
                    })

        tm_candidates.sort(key=lambda x: int(x["tmCode"].replace("TM", "")))
        eligible.extend(tm_candidates)

    return eligible

class TestMoveRelearner(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.ancestry, cls.learnsets, cls.hm_moves, cls.tm_moves, cls.tmhm_sets = load_data_tables()

    def test_hm_moves_classification(self):
        expected_hms = {"CUT", "FLY", "SURF", "STRENGTH", "FLASH"}
        self.assertEqual(self.hm_moves, expected_hms, f"HM mismatch: {self.hm_moves} vs {expected_hms}")

    def test_tm_moves_count_and_mapping(self):
        self.assertEqual(len(self.tm_moves), 50, f"Expected 50 TMs, found {len(self.tm_moves)}")
        self.assertEqual(self.tm_moves["MEGA_PUNCH"], "TM01")
        self.assertEqual(self.tm_moves["THUNDERBOLT"], "TM24")
        self.assertEqual(self.tm_moves["SUBSTITUTE"], "TM50")
        for hm in self.hm_moves:
            self.assertNotIn(hm, self.tm_moves, f"HM {hm} must not be in TM_MOVES table")

    def test_raichu_stone_evolution_relearn(self):
        raichu = {"species": "RAICHU", "level": 45, "moves": ["THUNDERSHOCK", "GROWL"]}
        eligible = simulate_get_eligible_moves(raichu, self.ancestry, self.learnsets, self.hm_moves, self.tm_moves, self.tmhm_sets, "RELEARN")
        move_names = {x["name"] for x in eligible}

        self.assertIn("THUNDERBOLT", move_names, "Raichu at Lv 45 should relearn Thunderbolt from Pikachu")
        self.assertIn("AGILITY", move_names)
        self.assertIn("THUNDER", move_names)
        self.assertTrue(all(not x["isTM"] for x in eligible), "RELEARN mode must not contain TMs")

    def test_level_gating_and_tm_unlock(self):
        raichu_low = {"species": "RAICHU", "level": 20, "moves": []}
        low_relearn = simulate_get_eligible_moves(raichu_low, self.ancestry, self.learnsets, self.hm_moves, self.tm_moves, self.tmhm_sets, "RELEARN")
        low_relearn_names = {x["name"] for x in low_relearn}
        self.assertNotIn("THUNDER", low_relearn_names, "Thunder should be level-gated at Lv 20 in RELEARN mode")

        low_tms = simulate_get_eligible_moves(raichu_low, self.ancestry, self.learnsets, self.hm_moves, self.tm_moves, self.tmhm_sets, "RELEARN+TMS")
        low_tm_dict = {x["name"]: x for x in low_tms}
        self.assertIn("THUNDER", low_tm_dict, "Thunder should be unlocked as TM25 in RELEARN+TMS mode")
        self.assertEqual(low_tm_dict["THUNDER"]["badge"], "TM25")
        self.assertTrue(low_tm_dict["THUNDER"]["isTM"])
        self.assertIn("THUNDERBOLT", low_tm_dict)
        self.assertNotIn("FLASH", low_tm_dict, "Flash is an HM and must never be taught by TM tutor")
        self.assertNotIn("SURF", low_tm_dict)

    def test_move_deduplication_and_badge_priority(self):
        raichu_high = {"species": "RAICHU", "level": 50, "moves": []}
        high_tms = simulate_get_eligible_moves(raichu_high, self.ancestry, self.learnsets, self.hm_moves, self.tm_moves, self.tmhm_sets, "RELEARN+TMS")
        high_names = [x["name"] for x in high_tms]

        self.assertEqual(high_names.count("THUNDERBOLT"), 1, "Thunderbolt must appear exactly once")
        tb_move = [x for x in high_tms if x["name"] == "THUNDERBOLT"][0]
        self.assertFalse(tb_move["isTM"], "Natural level-up move should prioritize level badge over TM badge")
        self.assertIn("Lv", tb_move["badge"])

        self.assertIn("SEISMIC_TOSS", high_names)
        st_move = [x for x in high_tms if x["name"] == "SEISMIC_TOSS"][0]
        self.assertEqual(st_move["badge"], "TM19")
        self.assertTrue(st_move["isTM"])

    def test_off_mode(self):
        raichu = {"species": "RAICHU", "level": 50, "moves": []}
        off_moves = simulate_get_eligible_moves(raichu, self.ancestry, self.learnsets, self.hm_moves, self.tm_moves, self.tmhm_sets, "OFF")
        self.assertEqual(len(off_moves), 0, "OFF mode must return empty list")

    def test_no_tm_pokemon(self):
        caterpie = {"species": "CATERPIE", "level": 15, "moves": []}
        cat_moves = simulate_get_eligible_moves(caterpie, self.ancestry, self.learnsets, self.hm_moves, self.tm_moves, self.tmhm_sets, "RELEARN+TMS")
        self.assertTrue(all(not x["isTM"] for x in cat_moves), "Caterpie has no compatible TMs")

    def test_pre_evo_tm_inheritance_and_hm_exclusion(self):
        charizard = {"species": "CHARIZARD", "level": 40, "moves": []}
        char_tms = simulate_get_eligible_moves(charizard, self.ancestry, self.learnsets, self.hm_moves, self.tm_moves, self.tmhm_sets, "RELEARN+TMS")
        char_names = {x["name"] for x in char_tms}
        self.assertIn("FIRE_BLAST", char_names)
        self.assertIn("DIG", char_names)
        self.assertNotIn("CUT", char_names, "HM Cut must be excluded")
        self.assertNotIn("STRENGTH", char_names, "HM Strength must be excluded")

if __name__ == "__main__":
    unittest.main()
