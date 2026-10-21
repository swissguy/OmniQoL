#!/usr/bin/env python3
"""
GitHub Release Publisher for OmniQoL
Retrieves authentication token from Git Credential Manager,
creates a formal GitHub Release for the tag, and uploads the release .zip asset.
"""

import os
import sys
import json
import urllib.request
import urllib.error
import subprocess

def get_token():
    proc = subprocess.Popen(
        ["git", "credential", "fill"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    stdout, _ = proc.communicate("protocol=https\nhost=github.com\n")
    creds = dict(line.split("=", 1) for line in stdout.strip().splitlines() if "=" in line)
    return creds.get("password")

def publish(tag="v0.2.0-alpha", version="0.2.0-alpha"):
    token = get_token()
    if not token:
        print("[Error] Could not retrieve GitHub credentials from Git Credential Manager.")
        sys.exit(1)

    repo = "swissguy/OmniQoL"
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    zip_name = f"omni-qol-gen1-v{version}.zip"
    zip_path = os.path.join(root_dir, zip_name)

    if not os.path.exists(zip_path):
        print(f"[Error] Release archive not found at: {zip_path}")
        sys.exit(1)

    print(f"[Release] Publishing {tag} to GitHub ({repo})...")

    # Release Notes
    body = f"""## 🌟 OmniQoL v{version} — Early Kanto Routes, 100% Version Parity & Test Suite

### 🗺️ Standardized Early Kanto Routes (Red, Blue & Yellow)
Every route has been rebalanced for **100% Cross-Version Parity** across Pokémon Red, Blue, and Yellow:
- ✅ **Route 1**: Vanilla verified (Pidgey Lv 2–5, Rattata Lv 2–4).
- ✅ **Route 2**: Uniform 20% distribution across Pidgey, Rattata, Weedle, Caterpie, and wild **Bulbasaur** (Lv 2–5).
- ✅ **Route 22**: Uniform 20% distribution across Rattata, Spearow, Nidoran♀, Nidoran♂, and early **Mankey** (Lv 2–5).
- ✅ **Viridian Forest**: 8 species total—7 base species at ~13.3% each (Caterpie, Metapod, Weedle, Kakuna, Pidgey, Pikachu, **Bulbasaur**) and rare **Pidgeotto** (Lv 9) at ~6.7%.
- ✅ **Route 3**: Uniform ~16.7% distribution across Pidgey, Spearow, Jigglypuff, Mankey, Sandshrew, and wild **Charmander** (Lv 6–10).
- ✅ **Mt. Moon (1F–B2F)**: Uniform 25% distribution across Zubat, Geodude, Paras, and **Clefairy** with vertical progression (1F: Lv 7–10, B1F: Lv 8–11, B2F: Lv 9–12).
- ✅ **Route 4**: Uniform ~16.7% distribution across Rattata, Spearow, Ekans, Sandshrew, Mankey, and wild **Charmander** (Lv 8–12).

---

### 🧪 Automated Quality Assurance
- **Comprehensive Test Suite**: 24 unit tests covering Manifest schemas, encounter distribution math, cross-version parity, guide synchronization, trade evolution level gating, Move Relearner / TM tutor rules, and HM deletion.
- **Pre-Build Gate**: `scripts/build_release.py` automatically validates the test suite before packaging.
- **Continuous Integration**: GitHub Actions CI workflow running multi-version matrix tests across Python 3.10, 3.11, and 3.12.

---

### 📦 Installation
1. Download `omni-qol-gen1-v{version}.zip` below.
2. Extract the `omni_qol` folder into your game's `mods` directory (e.g. `%APPDATA%\\pokemon-love2d\\mods\\omni_qol`).
3. Launch Pokémon Red, Blue, or Yellow on Gen1Recomp!
"""

    release_payload = {
        "tag_name": tag,
        "target_commitish": "main",
        "name": f"v{version}: Early Kanto Route Balancing, 100% Parity & Test Suite",
        "body": body,
        "draft": False,
        "prerelease": True,
    }

    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "OmniQoL-Release-Script",
    }

    # 1. Create Release
    req = urllib.request.Request(
        f"https://api.github.com/repos/{repo}/releases",
        data=json.dumps(release_payload).encode("utf-8"),
        headers={**headers, "Content-Type": "application/json"},
        method="POST",
    )

    try:
        with urllib.request.urlopen(req) as resp:
            release_data = json.loads(resp.read().decode("utf-8"))
            print(f"[Release] Created release #{release_data['id']}: {release_data['html_url']}")
    except urllib.error.HTTPError as e:
        err_body = e.read().decode("utf-8")
        print(f"[Error] Failed to create release: HTTP {e.code} - {err_body}")
        # If release already exists for tag, try to fetch it
        if "already_exists" in err_body:
            req_get = urllib.request.Request(
                f"https://api.github.com/repos/{repo}/releases/tags/{tag}",
                headers=headers,
            )
            with urllib.request.urlopen(req_get) as resp_get:
                release_data = json.loads(resp_get.read().decode("utf-8"))
                print(f"[Release] Using existing release: {release_data['html_url']}")
        else:
            sys.exit(1)

    # 2. Upload Binary Asset (.zip)
    upload_url = release_data.get("upload_url", "").replace("{?name,label}", "")
    with open(zip_path, "rb") as f:
        zip_bytes = f.read()

    asset_url = f"{upload_url}?name={zip_name}"
    req_upload = urllib.request.Request(
        asset_url,
        data=zip_bytes,
        headers={
            **headers,
            "Content-Type": "application/zip",
        },
        method="POST",
    )

    print(f"[Release] Uploading {zip_name} ({len(zip_bytes) / 1024:.1f} KB)...")
    try:
        with urllib.request.urlopen(req_upload) as resp_upload:
            asset_data = json.loads(resp_upload.read().decode("utf-8"))
            print(f"[Release] Successfully uploaded asset: {asset_data['browser_download_url']}")
    except urllib.error.HTTPError as e:
        err_body = e.read().decode("utf-8")
        print(f"[Warning] Asset upload response: HTTP {e.code} - {err_body}")

    print(f"\n[SUCCESS] Published GitHub Release: {release_data['html_url']}")

if __name__ == "__main__":
    publish()
