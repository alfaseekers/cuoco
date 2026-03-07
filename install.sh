#!/usr/bin/env bash
set -euo pipefail

CUOCO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Parse flags
FORCE=false
TARGET_DIR=""
for arg in "$@"; do
  case "$arg" in
    -f|--force) FORCE=true ;;
    -*) echo "Unknown option: $arg" >&2; exit 1 ;;
    *) TARGET_DIR="$arg" ;;
  esac
done

TARGET_DIR="${TARGET_DIR:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

if [ "$CUOCO_DIR" = "$TARGET_DIR" ]; then
  echo "Error: target directory is the cuoco repo itself." >&2
  exit 1
fi

if [ ! -d "$TARGET_DIR/.git" ]; then
  echo "Error: $TARGET_DIR is not a git repository." >&2
  exit 1
fi

echo "Installing cuoco into $TARGET_DIR"
echo ""

# 1. CLAUDE.md
if [ -f "$TARGET_DIR/CLAUDE.md" ] && [ "$FORCE" = false ]; then
  echo "  SKIP  CLAUDE.md (already exists — use --force to overwrite)"
else
  cp "$CUOCO_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
  echo "  COPY  CLAUDE.md"
fi

# 2. Slash commands
mkdir -p "$TARGET_DIR/.claude/commands/cuoco"
for cmd in setup.md f-recipe.md f-cook.md; do
  cp "$CUOCO_DIR/.claude/commands/cuoco/$cmd" "$TARGET_DIR/.claude/commands/cuoco/$cmd"
  echo "  COPY  .claude/commands/cuoco/$cmd"
done

# 3. Code style guides
mkdir -p "$TARGET_DIR/code-style"
for guide in "$CUOCO_DIR/code-style/"*.md; do
  name="$(basename "$guide")"
  cp "$guide" "$TARGET_DIR/code-style/$name"
  echo "  COPY  code-style/$name"
done

echo ""
echo "Done! Run /cuoco:setup in Claude Code to initialise your project."
