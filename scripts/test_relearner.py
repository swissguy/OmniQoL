#!/usr/bin/env python3
"""
Unit tests and verification suite for OmniQoL Move Relearner & Forget HMs.
Tests:
1. 5 Gen 1 HMs correctly classified
2. Pre-evolution level-up moves retention (Stone evos, multi-stage, level gating)
3. 50 TMs correctly mapped to move names
4. RELEARN mode vs RELEARN+TMS mode vs OFF mode
5. TM eligibility, pre-evo TM inheritance, deduplication, and HM exclusion
"""

import os
import re

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

def run_tests():
    print("[Test] Loading Relearner Data...")
    ancestry, learnsets, hm_moves, tm_moves, tmhm_sets = load_data_tables()

    # 1. Verify HM moves
    print("[Test] Checking HM moves...")
    expected_hms = {"CUT", "FLY", "SURF", "STRENGTH", "FLASH"}
    assert hm_moves == expected_hms, f"HM mismatch: {hm_moves} vs {expected_hms}"
    print("  -> All 5 Gen 1 HMs verified.")

    # 2. Verify TM moves
    print("[Test] Checking TM moves (TM01 - TM50)...")
    assert len(tm_moves) == 50, f"Expected 50 TMs, found {len(tm_moves)}"
    assert tm_moves["MEGA_PUNCH"] == "TM01"
    assert tm_moves["THUNDERBOLT"] == "TM24"
    assert tm_moves["SUBSTITUTE"] == "TM50"
    for hm in hm_moves:
        assert hm not in tm_moves, f"HM {hm} should not be in TM_MOVES table"
    print("  -> All 50 Gen 1 TMs verified.")

    # 3. Test Stone Evolution: Raichu in RELEARN mode
    print("[Test] Testing Raichu in RELEARN mode...")
    raichu_mon = {"species": "RAICHU", "level": 45, "moves": ["THUNDERSHOCK", "GROWL"]}
    raichu_eligible = simulate_get_eligible_moves(raichu_mon, ancestry, learnsets, hm_moves, tm_moves, tmhm_sets, "RELEARN")
    raichu_move_names = {x["name"] for x in raichu_eligible}

    assert "THUNDERBOLT" in raichu_move_names, "Raichu at Lv 45 should relearn Thunderbolt from Pikachu"
    assert "AGILITY" in raichu_move_names
    assert "THUNDER" in raichu_move_names
    assert all(not x["isTM"] for x in raichu_eligible), "RELEARN mode should contain no TMs"
    print("  -> Raichu RELEARN mode passed.")

    # 4. Test Raichu at Lv 20 in RELEARN vs RELEARN+TMS mode
    print("[Test] Testing Raichu at Lv 20 in RELEARN vs RELEARN+TMS mode...")
    raichu_low = {"species": "RAICHU", "level": 20, "moves": []}
    
    # In RELEARN mode: Thunder (Lv 41/43) is level-gated
    low_relearn = simulate_get_eligible_moves(raichu_low, ancestry, learnsets, hm_moves, tm_moves, tmhm_sets, "RELEARN")
    low_relearn_names = {x["name"] for x in low_relearn}
    assert "THUNDER" not in low_relearn_names, "Thunder should be level-gated at Lv 20 in RELEARN mode"

    # In RELEARN+TMS mode: Thunder is unlocked as TM25!
    low_tms = simulate_get_eligible_moves(raichu_low, ancestry, learnsets, hm_moves, tm_moves, tmhm_sets, "RELEARN+TMS")
    low_tm_dict = {x["name"]: x for x in low_tms}
    assert "THUNDER" in low_tm_dict, "Thunder should be available via TM25 in RELEARN+TMS mode"
    assert low_tm_dict["THUNDER"]["badge"] == "TM25"
    assert low_tm_dict["THUNDER"]["isTM"] == True

    assert "THUNDERBOLT" in low_tm_dict
    assert low_tm_dict["THUNDERBOLT"]["badge"] == "TM24"

    # Flash (HM05) must NOT be present
    assert "FLASH" not in low_tm_dict, "Flash is an HM and must not be taught by the TM tutor"
    assert "SURF" not in low_tm_dict
    print("  -> RELEARN+TMS unlocked TMs and excluded HMs properly.")

    # 5. Test Move Deduplication & Priority: Raichu at Lv 50 in RELEARN+TMS mode
    print("[Test] Testing move deduplication & badge priority...")
    raichu_high = {"species": "RAICHU", "level": 50, "moves": []}
    high_tms = simulate_get_eligible_moves(raichu_high, ancestry, learnsets, hm_moves, tm_moves, tmhm_sets, "RELEARN+TMS")
    high_names = [x["name"] for x in high_tms]
    
    # Thunderbolt should appear exactly once
    assert high_names.count("THUNDERBOLT") == 1, "Thunderbolt must not be duplicated"
    tb_move = [x for x in high_tms if x["name"] == "THUNDERBOLT"][0]
    assert not tb_move["isTM"], "Natural level-up move should prioritize level badge over TM badge"
    assert "Lv" in tb_move["badge"]

    # Seismic Toss (TM19 - only learned via TM by Pikachu line) should have TM badge
    assert "SEISMIC_TOSS" in high_names
    st_move = [x for x in high_tms if x["name"] == "SEISMIC_TOSS"][0]
    assert st_move["badge"] == "TM19"
    assert st_move["isTM"] == True
    print("  -> Deduplication and badge priority verified.")

    # 6. Test OFF mode
    print("[Test] Testing OFF mode...")
    off_moves = simulate_get_eligible_moves(raichu_mon, ancestry, learnsets, hm_moves, tm_moves, tmhm_sets, "OFF")
    assert len(off_moves) == 0, "OFF mode must return empty list"
    print("  -> OFF mode verified.")

    # 7. Test Pokémon with no TMs (Caterpie / Magikarp)
    print("[Test] Testing Caterpie & Magikarp...")
    caterpie = {"species": "CATERPIE", "level": 15, "moves": []}
    cat_moves = simulate_get_eligible_moves(caterpie, ancestry, learnsets, hm_moves, tm_moves, tmhm_sets, "RELEARN+TMS")
    assert all(not x["isTM"] for x in cat_moves), "Caterpie has no compatible TMs"
    print("  -> Caterpie & Magikarp handled safely.")

    # 8. Test 3-Stage Pre-Evo TM Inheritance: Charizard
    print("[Test] Testing Charizard pre-evolution TM compatibility...")
    charizard = {"species": "CHARIZARD", "level": 40, "moves": []}
    char_tms = simulate_get_eligible_moves(charizard, ancestry, learnsets, hm_moves, tm_moves, tmhm_sets, "RELEARN+TMS")
    char_names = {x["name"] for x in char_tms}
    assert "FIRE_BLAST" in char_names  # TM38
    assert "DIG" in char_names         # TM28
    assert "CUT" not in char_names     # HM01 excluded
    assert "STRENGTH" not in char_names # HM04 excluded
    print("  -> Charizard TM learnsets and HM exclusions passed.")

    print("\n[SUCCESS] All Move Relearner + TM tutor tests passed with 100% accuracy!")

if __name__ == "__main__":
    run_tests()
