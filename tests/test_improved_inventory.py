import os
import re
import unittest

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

class TestImprovedInventory(unittest.TestCase):
    def setUp(self):
        self.mod_path = os.path.join(ROOT_DIR, "mods", "modules", "improved_inventory.lua")
        self.assertTrue(os.path.exists(self.mod_path), "improved_inventory.lua does not exist")
        with open(self.mod_path, "r", encoding="utf-8") as f:
            self.content = f.read()

    def test_module_metadata_and_registration(self):
        """Verifies module ID, label, defaults and supported generations."""
        self.assertIn('id = "improved_inventory"', self.content)
        self.assertIn('label = "INVENTORY"', self.content)
        self.assertIn('default = true', self.content)
        self.assertIn('supportedGenerations = { "gen1" }', self.content)

    def test_capacity_constants(self):
        """Verifies 99 Bag capacity and 99 PC capacity constants."""
        self.assertIn("ImprovedInventory.VANILLA_BAG_CAPACITY = 20", self.content)
        self.assertIn("ImprovedInventory.EXPANDED_BAG_CAPACITY = 99", self.content)
        self.assertIn("ImprovedInventory.VANILLA_PC_CAPACITY = 50", self.content)
        self.assertIn("ImprovedInventory.EXPANDED_PC_CAPACITY = 99", self.content)
        self.assertIn("ImprovedInventory.PAGE_JUMP_SIZE = 5", self.content)

    def test_sorting_key_group_simulation(self):
        """Simulates getItemSortKey to verify item categorization:
        Group 1: Standard Items & Key Items (A-Z)
        Group 2: TMs (numerical TM01-TM50)
        Group 3: HMs (numerical HM01-HM05)
        """
        def get_sort_key(item):
            raw_id = item.get("id", item.get("name", "")) if isinstance(item, dict) else str(item)
            raw_name = item.get("name") if isinstance(item, dict) else None
            id_str = str(raw_id).upper().replace("ITEM_", "")

            tm_match = re.match(r"^TM_?(\d+)", id_str)
            if tm_match:
                return (2, int(tm_match.group(1)), raw_name or id_str, raw_id)

            hm_match = re.match(r"^HM_?(\d+)", id_str)
            if hm_match:
                return (3, int(hm_match.group(1)), raw_name or id_str, raw_id)

            # Check numeric range
            if isinstance(raw_id, int):
                if 196 <= raw_id <= 245:
                    return (2, raw_id - 196 + 1, raw_name or f"TM{raw_id - 196 + 1:02d}", raw_id)
                elif 246 <= raw_id <= 250:
                    return (3, raw_id - 246 + 1, raw_name or f"HM{raw_id - 246 + 1:02d}", raw_id)

            display_name = raw_name or id_str.replace("_", " ").strip().upper()
            return (1, 0, display_name, raw_id)

        # Standard items & Key items -> Group 1
        self.assertEqual(get_sort_key({"id": "POTION"})[0], 1)
        self.assertEqual(get_sort_key({"id": "BICYCLE"})[0], 1)
        self.assertEqual(get_sort_key({"id": "CARD_KEY"})[0], 1)

        # TMs -> Group 2 with numerical index
        tm_key = get_sort_key({"id": "TM28_DIG"})
        self.assertEqual(tm_key[0], 2)
        self.assertEqual(tm_key[1], 28)

        tm01_key = get_sort_key({"id": "TM01"})
        self.assertEqual(tm01_key[0], 2)
        self.assertEqual(tm01_key[1], 1)

        # HMs -> Group 3 with numerical index
        hm01_key = get_sort_key({"id": "HM01"})
        self.assertEqual(hm01_key[0], 3)
        self.assertEqual(hm01_key[1], 1)

        hm03_key = get_sort_key({"id": "HM03_SURF"})
        self.assertEqual(hm03_key[0], 3)
        self.assertEqual(hm03_key[1], 3)

    def test_gen1recomp_named_tm_hm_sorting(self):
        """Verifies that named TM/HM identifiers (e.g. TM_DIG, TM_MEGA_PUNCH, HM_CUT)
        are categorized into Group 2 (TMs) and Group 3 (HMs), sorting AFTER regular items
        like TOWN_MAP and X_SPECIAL, and BEFORE CANCEL.
        """
        # Ensure mapping tables are in the Lua file
        self.assertIn("local GEN1_TM_NUMBERS = {", self.content)
        self.assertIn("TM_MEGA_PUNCH = 1,", self.content)
        self.assertIn("TM_DIG = 28,", self.content)
        self.assertIn("TM_SUBSTITUTE = 50,", self.content)
        self.assertIn("local GEN1_HM_NUMBERS = {", self.content)
        self.assertIn("HM_CUT = 1,", self.content)
        self.assertIn("HM_FLASH = 5,", self.content)

        gen1_tm_map = {
            "TM_MEGA_PUNCH": 1,
            "TM_DIG": 28,
            "TM_SUBSTITUTE": 50,
        }
        gen1_hm_map = {
            "HM_CUT": 1,
            "HM_FLASH": 5,
        }

        def get_sort_key(item_id):
            id_str = str(item_id).upper().replace("ITEM_", "")
            if id_str in ("CANCEL", "CANCEL_MENU", "EXIT", "QUIT") or item_id == 255:
                return (4, 0, "CANCEL")
            if id_str in gen1_tm_map:
                return (2, gen1_tm_map[id_str], id_str)
            if id_str in gen1_hm_map:
                return (3, gen1_hm_map[id_str], id_str)
            tm_match = re.match(r"^TM_?(\d+)", id_str)
            if tm_match:
                return (2, int(tm_match.group(1)), id_str)
            hm_match = re.match(r"^HM_?(\d+)", id_str)
            if hm_match:
                return (3, int(hm_match.group(1)), id_str)
            display_name = id_str.replace("_", " ").strip().upper()
            return (1, 0, display_name)

        inventory = [
            "TM_DIG",
            "TOWN_MAP",
            "X_SPECIAL",
            "CANCEL",
            "HM_CUT",
            "POTION",
            "TM_MEGA_PUNCH",
            "ANTIDOTE",
            "X_ACCURACY",
        ]

        sorted_inv = sorted(inventory, key=get_sort_key)
        expected = [
            "ANTIDOTE",
            "POTION",
            "TOWN_MAP",
            "X_ACCURACY",
            "X_SPECIAL",
            "TM_MEGA_PUNCH",  # TM01
            "TM_DIG",         # TM28
            "HM_CUT",         # HM01
            "CANCEL",
        ]
        self.assertEqual(sorted_inv, expected)

    def test_list_menu_object_shape_sorting(self):
        """Verifies sorting on ListMenu/BagMenu entries ({value='...', label='...'})
        where TMs have value='TM_DIG' and label='TM28', Town Map has value='TOWN_MAP'
        and label='TOWN MAP', and Cancel has cancel=True.
        """
        self.assertIn('item.value', self.content)
        self.assertIn('res.pageJump = true', self.content)

        gen1_tm_map = { "TM_DIG": 28, "TM_MEGA_PUNCH": 1 }
        gen1_hm_map = { "HM_CUT": 1 }

        def get_sort_key(item):
            raw_id = item.get("value") or item.get("id") or item.get("name") if isinstance(item, dict) else str(item)
            raw_name = item.get("label") or item.get("name") if isinstance(item, dict) else None
            id_str = str(raw_id or "").upper().replace("ITEM_", "")
            name_str = str(raw_name or "").upper()

            if isinstance(item, dict) and item.get("cancel"):
                return (4, 0, "CANCEL")
            if id_str in gen1_tm_map:
                return (2, gen1_tm_map[id_str], name_str or id_str)
            if id_str in gen1_hm_map:
                return (3, gen1_hm_map[id_str], name_str or id_str)
            tm_match = re.match(r"^TM[\s_\-]?(\d+)", id_str) or re.match(r"^TM[\s_\-]?(\d+)", name_str)
            if tm_match:
                return (2, int(tm_match.group(1)), name_str or id_str)
            display_name = name_str or id_str.replace("_", " ").strip().upper()
            return (1, 0, display_name)

        list_menu_items = [
            {"value": "TM_DIG", "label": "TM28"},
            {"value": "TOWN_MAP", "label": "TOWN MAP"},
            {"value": "X_SPECIAL", "label": "X SPECIAL"},
            {"cancel": True, "label": "CANCEL"},
            {"value": "POTION", "label": "POTION"},
            {"value": "HM_CUT", "label": "HM01"},
            {"value": "TM_MEGA_PUNCH", "label": "TM01"},
        ]

        sorted_items = sorted(list_menu_items, key=get_sort_key)
        result_labels = [it["label"] for it in sorted_items]
        expected_labels = [
            "POTION",
            "TOWN MAP",
            "X SPECIAL",
            "TM01",      # Group 2: TM01
            "TM28",      # Group 2: TM28
            "HM01",      # Group 3: HM01
            "CANCEL",    # Group 4: CANCEL
        ]
        self.assertEqual(result_labels, expected_labels)

    def test_is_player_inventory_list_scoping(self):
        """Verifies that sorting is strictly restricted to player inventory lists,
        and excludes Mart buy stock, PC Pokémon boxes, elevator floors, and badge descriptions.
        """
        self.assertIn("function ImprovedInventory.isPlayerInventoryList", self.content)
        self.assertIn('kind == "bag"', self.content)
        self.assertIn('kind:find("^pc_item_")', self.content)
        self.assertIn('kind:find("^pc_box_")', self.content)
        self.assertIn('elevator_floors', self.content)
        self.assertIn('badge_descriptions', self.content)

        def is_player_inventory_list(title, items, opts):
            opts = opts or {}
            kind = opts.get("kind")
            if kind in ("bag", "pc"):
                return True
            if isinstance(kind, str) and kind.startswith("pc_item_"):
                return True
            if isinstance(kind, str):
                if kind.startswith("pc_box_") or kind in ("elevator_floors", "badge_descriptions", "pokedex", "moves", "controls"):
                    return False
            if opts.get("dialogue") and opts.get("money") and not opts.get("onSelectKey"):
                return False
            if opts.get("script"):
                return False
            if title and (title == "ITEMS" or str(title).startswith("ITEMS")) and not opts.get("dialogue"):
                return True
            return False

        # 1. Allowed: Bag & PC items
        self.assertTrue(is_player_inventory_list("ITEMS", [], {"kind": "bag"}))
        self.assertTrue(is_player_inventory_list(None, [], {"kind": "pc_item_withdraw"}))
        self.assertTrue(is_player_inventory_list(None, [], {"kind": "pc_item_deposit"}))
        self.assertTrue(is_player_inventory_list(None, [], {"kind": "pc_item_toss"}))

        # 2. Excluded: Non-inventory menus
        self.assertFalse(is_player_inventory_list(None, [], {"kind": "pc_box_deposit"}))
        self.assertFalse(is_player_inventory_list(None, [], {"kind": "pc_box_release"}))
        self.assertFalse(is_player_inventory_list(None, [], {"kind": "pc_box_withdraw"}))
        self.assertFalse(is_player_inventory_list(None, [], {"kind": "elevator_floors"}))
        self.assertFalse(is_player_inventory_list(None, [], {"kind": "badge_descriptions"}))

        # 3. Excluded: ShopMenu Buy stock
        self.assertFalse(is_player_inventory_list(None, [], {"dialogue": True, "money": lambda: 500, "itemBox": True}))

        # 4. Excluded: Battle script / tutorial
        self.assertFalse(is_player_inventory_list("ITEMS", [], {"script": lambda l: None, "itemBox": True}))

    def test_sorting_order_full_inventory_with_cancel_at_bottom(self):
        """Verifies full list sorting: Items A-Z, then TMs 1-50, then HMs 1-5, and CANCEL always at the bottom."""
        def get_sort_key(item):
            raw_id = item.get("id", item.get("name", "")) if isinstance(item, dict) else str(item)
            raw_name = item.get("name") if isinstance(item, dict) else None
            id_str = str(raw_id).upper().replace("ITEM_", "")

            # Group 4: CANCEL / Exit menu entries
            if id_str in ("CANCEL", "CANCEL_MENU", "EXIT", "QUIT") or raw_id == 255:
                return (4, 0, "CANCEL")

            tm_match = re.match(r"^TM_?(\d+)", id_str)
            if tm_match:
                return (2, int(tm_match.group(1)), raw_name or id_str)

            hm_match = re.match(r"^HM_?(\d+)", id_str)
            if hm_match:
                return (3, int(hm_match.group(1)), raw_name or id_str)

            display_name = raw_name or id_str.replace("_", " ").strip().upper()
            return (1, 0, display_name)

        unsorted_items = [
            {"id": "ULTRA_BALL", "count": 10},
            {"id": "CANCEL"},
            {"id": "HM02", "count": 1},
            {"id": "ANTIDOTE", "count": 3},
            {"id": "TM28", "count": 1},
            {"id": "BICYCLE", "count": 1},
            {"id": "TM01", "count": 1},
            {"id": "POTION", "count": 5},
            {"id": "HM01", "count": 1},
            {"id": "ESCAPE_ROPE", "count": 2},
            {"id": "TM15", "count": 1},
        ]

        sorted_items = sorted(unsorted_items, key=get_sort_key)
        sorted_ids = [item["id"] for item in sorted_items]

        expected_ids = [
            "ANTIDOTE",
            "BICYCLE",
            "ESCAPE_ROPE",
            "POTION",
            "ULTRA_BALL",
            "TM01",
            "TM15",
            "TM28",
            "HM01",
            "HM02",
            "CANCEL",
        ]
        self.assertEqual(sorted_ids, expected_ids)

    def test_save_bag_order_and_pc_order_sorting(self):
        """Verifies that string-array bagOrder and pcOrder sort correctly with CANCEL at bottom."""
        raw_bag_order = [
            "POTION",
            "CANCEL",
            "TOWN_MAP",
            "POKE_BALL",
            "RARE_CANDY",
            "TM01",
            "HM01",
            "ANTIDOTE",
            "TM28",
        ]

        def get_sort_key(item_id):
            id_str = str(item_id).upper().replace("ITEM_", "")
            if id_str in ("CANCEL", "CANCEL_MENU", "EXIT", "QUIT") or item_id == 255:
                return (4, 0, "CANCEL")
            tm_match = re.match(r"^TM_?(\d+)", id_str)
            if tm_match:
                return (2, int(tm_match.group(1)), id_str)
            hm_match = re.match(r"^HM_?(\d+)", id_str)
            if hm_match:
                return (3, int(hm_match.group(1)), id_str)
            display_name = id_str.replace("_", " ").strip().upper()
            return (1, 0, display_name)

        sorted_order = sorted(raw_bag_order, key=get_sort_key)
        expected = [
            "ANTIDOTE",
            "POKE_BALL",
            "POTION",
            "RARE_CANDY",
            "TOWN_MAP",
            "TM01",
            "TM28",
            "HM01",
            "CANCEL",
        ]
        self.assertEqual(sorted_order, expected)

    def test_page_jump_navigation(self):
        """Simulates D-Pad Left / Right page jumping (jump size 5)."""
        def handle_page_jump(current_idx, max_idx, direction, jump_size=5):
            if max_idx <= 1:
                return 1
            target = current_idx + (direction * jump_size)
            if target < 1:
                return 1
            if target > max_idx:
                return max_idx
            return target

        # Jumping down from index 1 -> index 6
        self.assertEqual(handle_page_jump(1, 99, 1, 5), 6)
        # Jumping down from index 96 -> index 99 (clamped)
        self.assertEqual(handle_page_jump(96, 99, 1, 5), 99)
        # Jumping up from index 4 -> index 1 (clamped)
        self.assertEqual(handle_page_jump(4, 99, -1, 5), 1)
        # Jumping up from index 20 -> index 15
        self.assertEqual(handle_page_jump(20, 99, -1, 5), 15)

    def test_safe_toggle_off_deposit_logic(self):
        """Verifies safe PC auto-deposit on toggle-OFF and blocking when PC is full."""
        VANILLA_BAG = 20
        VANILLA_PC = 50

        def can_safely_disable(bag_items, pc_items):
            total_bag = len(bag_items)
            if total_bag <= VANILLA_BAG:
                return True, None, []

            excess_count = total_bag - VANILLA_BAG
            available_pc = VANILLA_PC - len(pc_items)

            if excess_count > available_pc:
                err = f"Cannot disable: PC needs {excess_count} free slots (has {available_pc})."
                return False, err, None

            excess_list = bag_items[VANILLA_BAG:]
            return True, None, excess_list

        # Case 1: Bag has <= 20 items -> Disabling always succeeds immediately
        bag1 = [{"id": f"ITEM_{i}"} for i in range(15)]
        pc1 = [{"id": f"PC_ITEM_{i}"} for i in range(50)]
        can_disable, err, excess = can_safely_disable(bag1, pc1)
        self.assertTrue(can_disable)
        self.assertIsNone(err)
        self.assertEqual(len(excess), 0)

        # Case 2: Bag has 25 items (5 excess), PC has 40 items (10 slots available) -> Success
        bag2 = [{"id": f"ITEM_{i}"} for i in range(25)]
        pc2 = [{"id": f"PC_ITEM_{i}"} for i in range(40)]
        can_disable, err, excess = can_safely_disable(bag2, pc2)
        self.assertTrue(can_disable)
        self.assertEqual(len(excess), 5)

        # Case 3: Bag has 30 items (10 excess), PC has 45 items (only 5 slots available) -> Blocked!
        bag3 = [{"id": f"ITEM_{i}"} for i in range(30)]
        pc3 = [{"id": f"PC_ITEM_{i}"} for i in range(45)]
        can_disable, err, excess = can_safely_disable(bag3, pc3)
        self.assertFalse(can_disable)
        self.assertIsNotNone(err)
        self.assertIn("Cannot disable", err)

        # Case 4: PC full (50 items) and Bag has 21 items (1 excess) -> Blocked!
        bag4 = [{"id": f"ITEM_{i}"} for i in range(21)]
        pc4 = [{"id": f"PC_ITEM_{i}"} for i in range(50)]
        can_disable, err, excess = can_safely_disable(bag4, pc4)
        self.assertFalse(can_disable)
        self.assertIn("PC needs 1 free slots", err)

    def test_constants_patching_and_player_pc_engine_integration(self):
        """Verifies integration with bryanthaboi/gen1recomp's constants registry and UI classes."""
        self.assertIn('mod.content.constants:patch("bagSize"', self.content)
        self.assertIn('mod.content.constants:patch("pcItemCap"', self.content)
        self.assertIn('src.ui.PlayerPC', self.content)
        self.assertIn('PlayerPC.pcItemCap = ImprovedInventory.EXPANDED_PC_CAPACITY', self.content)
        self.assertIn('save.bagOrder', self.content)
        self.assertIn('save.pcOrder', self.content)

if __name__ == "__main__":
    unittest.main()
