#!/usr/bin/env python3
"""
Unit tests and verification suite for OmniQoL Move Relearner & Forget HMs.
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

    # Parse Learnsets properly handling nested braces
    learnsets_match = re.search(r"RelearnerData\.LEARNSETS = \{(.*?)\n\}", content, re.DOTALL)
    assert learnsets_match, "Learnsets table not found"
    learnsets_text = learnsets_match.group(1)

    learnsets = {}
    current_species = None
    current_entries = []

    for line in learnsets_text.splitlines():
        # Match species header: "  BULBASAUR = {"
        sm = re.match(r'^\s*([A-Z0-9_]+)\s*=\s*\{', line)
        if sm:
            if current_species:
                learnsets[current_species] = current_entries
            current_species = sm.group(1)
            current_entries = []
            continue

        # Match move entry: "{ level = 1, move = "TACKLE" },"
        em = re.search(r'\{\s*level\s*=\s*(\d+),\s*move\s*=\s*"([A-Z0-9_]+)"\s*\}', line)
        if em and current_species:
            current_entries.append({"level": int(em.group(1)), "move": em.group(2)})

    if current_species:
        learnsets[current_species] = current_entries

    # Parse HM moves
    hm_match = re.search(r"RelearnerData\.HM_MOVES = \{(.*?)\n\}", content, re.DOTALL)
    assert hm_match, "HM_MOVES not found"
    hm_moves = set(re.findall(r'([A-Z0-9_]+)\s*=\s*true', hm_match.group(1)))

    return ancestry, learnsets, hm_moves

def simulate_get_eligible_moves(mon, ancestry_map, learnsets_map):
    species = mon["species"].upper()
    level = mon.get("level", 100)
    known = set(mon.get("moves", []))

    stages = [species] + ancestry_map.get(species, [])
    eligible = []
    seen = set()

    for st in stages:
        ls = learnsets_map.get(st, [])
        for entry in ls:
            req_lvl = entry["level"]
            mv = entry["move"]
            if (req_lvl <= level or req_lvl == 1) and mv not in known and mv not in seen:
                seen.add(mv)
                eligible.append({"name": mv, "level": req_lvl, "fromStage": st})
    return eligible

def run_tests():
    print("[Test] Loading Relearner Data...")
    ancestry, learnsets, hm_moves = load_data_tables()

    # 1. Verify HM moves
    print("[Test] Checking HM moves...")
    expected_hms = {"CUT", "FLY", "SURF", "STRENGTH", "FLASH"}
    assert hm_moves == expected_hms, f"HM mismatch: {hm_moves} vs {expected_hms}"
    print("  -> All 5 Gen 1 HMs verified.")

    # 2. Test Stone Evolution: Raichu
    print("[Test] Testing Stone Evolution: Raichu...")
    assert "PIKACHU" in ancestry["RAICHU"], "Pikachu must be ancestor of Raichu"
    
    # Raichu evolved early at Lv 10, now Lv 45, knows THUNDERSHOCK, GROWL
    raichu_mon = {"species": "RAICHU", "level": 45, "moves": ["THUNDERSHOCK", "GROWL"]}
    raichu_eligible = simulate_get_eligible_moves(raichu_mon, ancestry, learnsets)
    raichu_move_names = {x["name"] for x in raichu_eligible}

    assert "THUNDERBOLT" in raichu_move_names, "Raichu at Lv 45 should be able to relearn Thunderbolt from Pikachu"
    assert "AGILITY" in raichu_move_names, "Raichu at Lv 45 should be able to relearn Agility from Pikachu"
    assert "THUNDER" in raichu_move_names, "Raichu at Lv 45 should be able to relearn Thunder from Pikachu"
    assert "THUNDERSHOCK" not in raichu_move_names, "Known moves should not be eligible"
    assert "GROWL" not in raichu_move_names, "Known moves should not be eligible"
    print("  -> Raichu pre-evolution moves passed.")

    # Raichu at Lv 20 should NOT learn Thunder (Lv 41/43 in Pikachu)
    raichu_low = {"species": "RAICHU", "level": 20, "moves": []}
    raichu_low_eligible = simulate_get_eligible_moves(raichu_low, ancestry, learnsets)
    raichu_low_names = {x["name"] for x in raichu_low_eligible}
    assert "THUNDER" not in raichu_low_names, "Level-gating failed: Thunder should not be eligible at Lv 20"
    assert "SLAM" in raichu_low_names, "Slam (Lv 20) should be eligible at Lv 20"
    print("  -> Level-gating check passed.")

    # 3. Test Stone Evolution: Arcanine
    print("[Test] Testing Stone Evolution: Arcanine...")
    assert "GROWLITHE" in ancestry["ARCANINE"]
    arcanine_mon = {"species": "ARCANINE", "level": 50, "moves": ["BITE", "ROAR"]}
    arcanine_moves = {x["name"] for x in simulate_get_eligible_moves(arcanine_mon, ancestry, learnsets)}
    assert "FLAMETHROWER" in arcanine_moves, "Arcanine at Lv 50 should relearn Flamethrower"
    assert "AGILITY" in arcanine_moves, "Arcanine at Lv 50 should relearn Agility"
    assert "TAKE_DOWN" in arcanine_moves, "Arcanine at Lv 50 should relearn Take Down"
    print("  -> Arcanine pre-evolution moves passed.")

    # 4. Test 3-Stage Evolution: Venusaur & Charizard
    print("[Test] Testing 3-Stage Lines: Charizard & Venusaur...")
    assert ancestry["CHARIZARD"] == ["CHARMELEON", "CHARMANDER"]
    charizard_mon = {"species": "CHARIZARD", "level": 36, "moves": ["FIRE_SPIN"]}
    charizard_moves = {x["name"] for x in simulate_get_eligible_moves(charizard_mon, ancestry, learnsets)}
    assert "SLASH" in charizard_moves, "Charizard at Lv 36 should relearn Slash"
    assert "FLAMETHROWER" not in charizard_moves, "Flamethrower (Lv 46/42) should be level-gated at Lv 36"
    assert "SCRATCH" in charizard_moves, "Level 1 base move Scratch should be relearnable"
    print("  -> 3-Stage lines and base moves passed.")

    # 5. Test Stone Evolution: Vileplume
    print("[Test] Testing Stone Evolution: Vileplume...")
    assert ancestry["VILEPLUME"] == ["GLOOM", "ODDISH"]
    vileplume_mon = {"species": "VILEPLUME", "level": 38, "moves": ["ACID"]}
    vileplume_moves = {x["name"] for x in simulate_get_eligible_moves(vileplume_mon, ancestry, learnsets)}
    assert "PETAL_DANCE" in vileplume_moves
    assert "SLEEP_POWDER" in vileplume_moves
    assert "SOLARBEAM" not in vileplume_moves  # Solarbeam is Lv 46/52
    print("  -> Vileplume ancestors and learnsets passed.")

    # 6. Test Eeveelutions
    print("[Test] Testing Eevee line...")
    assert ancestry["VAPOREON"] == ["EEVEE"]
    assert ancestry["JOLTEON"] == ["EEVEE"]
    assert ancestry["FLAREON"] == ["EEVEE"]
    vaporeon_mon = {"species": "VAPOREON", "level": 54, "moves": ["SURF"]}
    vap_moves = {x["name"] for x in simulate_get_eligible_moves(vaporeon_mon, ancestry, learnsets)}
    assert "HYDRO_PUMP" in vap_moves
    assert "TAKE_DOWN" in vap_moves  # from Eevee
    print("  -> Eevee evolutions passed.")

    print("\n[SUCCESS] All Move Relearner logic and test suites passed with 100% accuracy!")

if __name__ == "__main__":
    run_tests()
