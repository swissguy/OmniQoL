#!/usr/bin/env python3
"""
OmniQoL Release Archive Builder
Packages the unified cross-generation mod suite into a distributable .zip archive
formatted for Gen1Recomp and Gen2Recomp.
"""

import os
import sys
import json
import zipfile
import shutil

# Add scripts directory to path to import run_tests
SCRIPTS_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPTS_DIR not in sys.path:
    sys.path.insert(0, SCRIPTS_DIR)
from run_tests import run as run_tests

def build():
    if "--skip-tests" not in sys.argv:
        print("[OmniQoL] Running test suite prior to release packaging...")
        exit_code = run_tests()
        if exit_code != 0:
            print("[OmniQoL] Test suite failed! Release packaging aborted.")
            sys.exit(exit_code)
    else:
        print("[OmniQoL] Skipping tests (--skip-tests flag passed).")

    root_dir = os.path.dirname(SCRIPTS_DIR)
    manifest_path = os.path.join(root_dir, "mods", "manifest.json")

    with open(manifest_path, "r", encoding="utf-8") as f:
        manifest = json.load(f)

    version = manifest.get("version", "0.2.2")
    archive_name = f"omni-qol-v{version}.zip"
    archive_path = os.path.join(root_dir, archive_name)
    source_dir = os.path.join(root_dir, "mods")

    print(f"\n[OmniQoL] Building release archive: {archive_name}")
    with zipfile.ZipFile(archive_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(source_dir):
            dirs.sort()
            files.sort()
            for d in dirs:
                rel = os.path.relpath(os.path.join(root, d), source_dir).replace("\\", "/")
                zf.write(os.path.join(root, d), f"omni_qol/{rel}/")
            for f in files:
                full = os.path.join(root, f)
                rel = os.path.relpath(full, source_dir).replace("\\", "/")
                zf.write(full, f"omni_qol/{rel}")

    size_kb = os.path.getsize(archive_path) / 1024
    print(f"[OmniQoL] Successfully built {archive_name} ({size_kb:.1f} KB)")

    # Synchronize to local game installations if present
    appdata = os.environ.get("APPDATA")
    if appdata:
        potential_targets = [
            os.path.join(appdata, "pokemon-love2d", "mods", "omni_qol"),
            os.path.join(appdata, "pokemon-crystal-love2d", "mods", "omni_qol"),
            os.path.join(appdata, "gen2recomp", "mods", "omni_qol"),
        ]
        for target_mod_dir in potential_targets:
            parent_dir = os.path.dirname(target_mod_dir)
            if os.path.exists(parent_dir):
                print(f"[OmniQoL] Synchronizing mod files to {target_mod_dir}...")
                try:
                    os.makedirs(target_mod_dir, exist_ok=True)
                    for root, dirs, files in os.walk(source_dir):
                        rel = os.path.relpath(root, source_dir)
                        dest_dir = os.path.join(target_mod_dir, rel) if rel != "." else target_mod_dir
                        os.makedirs(dest_dir, exist_ok=True)
                        for f in files:
                            src_file = os.path.join(root, f)
                            dest_file = os.path.join(dest_dir, f)
                            shutil.copy2(src_file, dest_file)
                    print(f"[OmniQoL] Successfully synchronized to {target_mod_dir}!")
                except OSError as e:
                    print(f"[OmniQoL] Note: Could not synchronize to {target_mod_dir} ({e}).")

if __name__ == "__main__":
    build()
