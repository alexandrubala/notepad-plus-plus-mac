#!/bin/bash
# Package Notepad++.app into a simple DMG (unsigned; notarization optional with Developer ID)
set -euo pipefail

APP="${1:?Usage: package-dmg.sh path/to/Notepad++.app output.dmg}"
DMG="${2:?Usage: package-dmg.sh path/to/Notepad++.app output.dmg}"
STAGE="$(mktemp -d)/dmgroot"

mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"

# Optional README in DMG
cat > "$STAGE/README.txt" <<'EOF'
Notepad++ for macOS (native Apple Silicon / Universal)

1. Drag Notepad++ to Applications
2. On first launch, right-click → Open if Gatekeeper blocks unsigned builds
3. Plugins: ~/Library/Application Support/Notepad++/plugins/*.dylib

GPL-3.0 — based on Notepad++ by Don Ho, Scintilla by Neil Hodgson.
EOF

rm -f "$DMG"
hdiutil create -volname "Notepad++" -srcfolder "$STAGE" -ov -format UDZO "$DMG"
echo "Created $DMG"
rm -rf "$(dirname "$STAGE")"
