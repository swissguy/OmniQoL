#!/usr/bin/env python3
"""
OmniQoL Release Archive Builder
Packages the Gen 1 mod suite into a distributable .zip archive formatted
for Gen1Recomp / G1R Deluxe.
"""

import os
import json
import zipfile

def build():
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    manifest_path = os.path.join(root_dir, "mods", "gen1", "manifest.json")
    
    with open(manifest_path, "r", encoding="utf-8") as f:
        manifest = json.load(f)
        
    version = manifest.get("version", "0.1.1-alpha")
    archive_name = f"omni-qol-gen1-v{version}.zip"
    archive_path = os.path.join(root_dir, archive_name)
    source_dir = os.path.join(root_dir, "mods", "gen1")

    print(f"[OmniQoL] Building release archive: {archive_name}")
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

    # Synchronize to local game installation if present
    appdata = os.environ.get("APPDATA")
    if appdata:
        target_mod_dir = os.path.join(appdata, "pokemon-love2d", "mods", "omni_qol")
        if os.path.exists(os.path.dirname(target_mod_dir)):
            import shutil
            print(f"[OmniQoL] Synchronizing mod files to {target_mod_dir}...")
            os.makedirs(target_mod_dir, exist_ok=True)
            for root, dirs, files in os.walk(source_dir):
                rel = os.path.relpath(root, source_dir)
                dest_dir = os.path.join(target_mod_dir, rel) if rel != "." else target_mod_dir
                os.makedirs(dest_dir, exist_ok=True)
                for f in files:
                    src_file = os.path.join(root, f)
                    dest_file = os.path.join(dest_dir, f)
                    shutil.copy2(src_file, dest_file)
            print("[OmniQoL] Successfully synchronized active mod files!")

if __name__ == "__main__":
    build()
