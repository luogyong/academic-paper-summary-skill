#!/bin/bash
# One-time setup: install post-merge hook for auto-sync
# After running this, every git pull will auto-update the installed skill

HOOK_FILE="$(cd "$(dirname "$0")" && pwd)/.git/hooks/post-merge"

cat > "$HOOK_FILE" <<'EOF'
#!/bin/bash
# Auto-sync installed skill after git pull
cd "$(dirname "$0")/../.." && bash install.sh
EOF

chmod +x "$HOOK_FILE"
echo "✓ post-merge hook installed"
echo "  From now on, 'git pull' will auto-run install.sh"
