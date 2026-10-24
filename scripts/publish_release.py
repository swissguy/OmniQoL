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

def publish(tag="v0.2.3", version="0.2.3"):
    token = get_token()
    if not token:
        print("[Error] Could not retrieve GitHub credentials from Git Credential Manager.")
        sys.exit(1)

    repo = "swissguy/OmniQoL"
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    zip_name = f"omni-qol-v{version}.zip"
    zip_path = os.path.join(root_dir, zip_name)
    if not os.path.exists(zip_path):
        legacy_name = f"omni-qol-gen1-v{version}.zip"
        if os.path.exists(os.path.join(root_dir, legacy_name)):
            zip_name = legacy_name
            zip_path = os.path.join(root_dir, zip_name)

    if not os.path.exists(zip_path):
        print(f"[Error] Release archive not found at: {zip_path}")
        sys.exit(1)

    print(f"[Release] Publishing {tag} to GitHub ({repo})...")

    # Release Notes
    body = f"""## 🌟 OmniQoL v{version}

### 📋 What's Changed
- **🎒 Improved Inventory (Module 7)**: 99-item Bag & PC capacity, D-Pad Left/Right page-jump navigation, deterministic auto-sorting (A–Z items, TMs 01–50, HMs 01–05, Cancel anchored at bottom), and safe PC deposit on toggle-off.
- **🎓 Gen 2 EXP Share**: Enabled modern Gen 6+ EXP Share and 100% Stat EXP distribution across Pokémon Gold, Silver, and Crystal with consolidated benched dialogue.
- **✨ Encounter Restorations**: Expanded wild uniform rosters across Routes 5, 6, 9, 10, 11, Diglett's Cave, and Rock Tunnel for 151 Pokédex completion.
- **🧪 Documentation & Verification**: 51 automated unit tests and synchronized guide documentation.

**Full Changelog**: https://github.com/swissguy/OmniQoL/compare/v0.2.1...v{version}

---

### 📦 Installation
1. Download `{zip_name}` below.
2. Extract the `omni_qol` folder into your game's `mods` directory (e.g. `%APPDATA%\pokemon-love2d\mods\omni_qol` or `%APPDATA%\pokemon-crystal-love2d\mods\omni_qol`).
3. Launch Pokémon Red, Blue, Yellow, Gold, Silver, or Crystal!
"""

    release_payload = {
        "tag_name": tag,
        "target_commitish": "main",
        "name": f"v{version}",
        "body": body,
        "draft": False,
        "prerelease": False,
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
        if "already_exists" in err_body:
            print(f"[Release] Release {tag} already exists. Fetching existing release...")
            get_req = urllib.request.Request(
                f"https://api.github.com/repos/{repo}/releases/tags/{tag}",
                headers=headers,
            )
            with urllib.request.urlopen(get_req) as get_resp:
                release_data = json.loads(get_resp.read().decode("utf-8"))
        else:
            print(f"[Error] Failed to create release: {e.code} {e.reason}\n{err_body}")
            sys.exit(1)

    upload_url = release_data["upload_url"].split("{")[0]
    upload_url += f"?name={zip_name}"

    # Check if asset already exists and delete it if needed
    for asset in release_data.get("assets", []):
        if asset["name"] == zip_name:
            print(f"[Release] Deleting pre-existing asset #{asset['id']} ({zip_name})...")
            del_req = urllib.request.Request(
                asset["url"],
                headers=headers,
                method="DELETE",
            )
            urllib.request.urlopen(del_req)
            break

    print(f"[Release] Uploading asset {zip_name} ({os.path.getsize(zip_path) / 1024:.1f} KB)...")
    with open(zip_path, "rb") as f:
        zip_bytes = f.read()

    upload_headers = {
        **headers,
        "Content-Type": "application/zip",
        "Content-Length": str(len(zip_bytes)),
    }
    upload_req = urllib.request.Request(
        upload_url,
        data=zip_bytes,
        headers=upload_headers,
        method="POST",
    )

    try:
        with urllib.request.urlopen(upload_req) as upload_resp:
            asset_data = json.loads(upload_resp.read().decode("utf-8"))
            print(f"[Release] Successfully uploaded asset: {asset_data['browser_download_url']}")
    except urllib.error.HTTPError as e:
        print(f"[Error] Failed to upload asset: {e.code} {e.reason}\n{e.read().decode('utf-8')}")
        sys.exit(1)

    print(f"\n[OmniQoL] Successfully published {tag} to GitHub!")

if __name__ == "__main__":
    v = "0.2.3"
    t = f"v{v}"
    if len(sys.argv) > 1:
        t = sys.argv[1]
    if len(sys.argv) > 2:
        v = sys.argv[2]
    publish(tag=t, version=v)
