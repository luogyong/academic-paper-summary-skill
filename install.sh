#!/bin/bash
# Install academic-paper-summary skill to Claude Code
# Run this script after git pull to keep the installed skill in sync

set -e

SKILL_DIR="$HOME/.claude/agents"
COMMANDS_DIR="$HOME/.claude/commands"
SKILL_FILE="$SKILL_DIR/academic-paper-summary.md"
SLASH_CMD="$COMMANDS_DIR/summarize-paper.md"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$SCRIPT_DIR/SKILL.md"

echo "=== Academic Paper Summary Skill - Install ==="

# 1. Install subagent
mkdir -p "$SKILL_DIR"
cp "$SOURCE" "$SKILL_FILE"
echo "✓ Subagent installed: $SKILL_FILE"

# 2. Install slash command
mkdir -p "$COMMANDS_DIR"
cat > "$SLASH_CMD" <<'CMDEOF'
Use the academic-paper-summary agent to process this request.

$ARGUMENTS
CMDEOF
echo "✓ Slash command installed: $SLASH_CMD"

# 3. Verify
if [ -f "$SKILL_FILE" ]; then
    SIZE=$(wc -c < "$SKILL_FILE")
    echo "✓ Verified: $SIZE bytes"
else
    echo "✗ Failed to install"
    exit 1
fi

echo
echo "=== Done ==="
echo "Restart Claude Code to apply changes."
echo "Triggers: /summarize-paper | 总结论文 | 学术论文分析"
