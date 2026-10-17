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

if __name__ == "__main__":
    build()
