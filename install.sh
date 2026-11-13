#!/bin/bash
# Підключає плагін code-skills-test до Claude Code (десктопна апка / CLI) з автооновленням.
# macOS / Linux. Запуск:
#   curl -fsSL https://raw.githubusercontent.com/YuraKolyada/code-skills-test-marketplace/main/install.sh | bash
set -euo pipefail

REPO="${CODE_HELPER_REPO:-YuraKolyada/code-skills-test-marketplace}"
SETTINGS="$HOME/.claude/settings.json"

mkdir -p "$HOME/.claude"
if [ -f "$SETTINGS" ]; then
  cp "$SETTINGS" "$SETTINGS.backup-$(date +%Y%m%d-%H%M%S)"
fi

# Логіка однакова для обох гілок: дописати ключі, нічого не видаляючи.
JS_CORE='
function patch(text, repo) {
  var s = {};
  if (text && text.trim()) { s = JSON.parse(text); }
  s.extraKnownMarketplaces = s.extraKnownMarketplaces || {};
  s.extraKnownMarketplaces["lineup-tools"] = {
    source: { source: "github", repo: repo },
    autoUpdate: true
  };
  s.enabledPlugins = s.enabledPlugins || {};
  s.enabledPlugins["code-skills-test@lineup-tools"] = true;
  return JSON.stringify(s, null, 2) + "\n";
}'

if [ "$(uname)" = "Darwin" ]; then
  # macOS: вбудований JavaScript for Automation, нічого встановлювати не треба.
  osascript -l JavaScript - "$SETTINGS" "$REPO" <<EOF
ObjC.import("Foundation");
$JS_CORE
function run(argv) {
  var path = argv[0], repo = argv[1];
  var fm = \$.NSFileManager.defaultManager;
  var text = "";
  if (fm.fileExistsAtPath(path)) {
    text = ObjC.unwrap(\$.NSString.stringWithContentsOfFileEncodingError(path, \$.NSUTF8StringEncoding, null)) || "";
  }
  var out = patch(text, repo);
  \$(out).writeToFileAtomicallyEncodingError(path, true, \$.NSUTF8StringEncoding, null);
  return "ok";
}
EOF
elif command -v python3 >/dev/null 2>&1; then
  python3 - "$SETTINGS" "$REPO" <<'EOF'
import json, os, sys
path, repo = sys.argv[1], sys.argv[2]
s = {}
if os.path.exists(path):
    t = open(path, encoding="utf-8").read()
    if t.strip():
        s = json.loads(t)
s.setdefault("extraKnownMarketplaces", {})["lineup-tools"] = {
    "source": {"source": "github", "repo": repo}, "autoUpdate": True}
s.setdefault("enabledPlugins", {})["code-skills-test@lineup-tools"] = True
open(path, "w", encoding="utf-8").write(json.dumps(s, indent=2, ensure_ascii=False) + "\n")
EOF
else
  echo "Не знайдено python3. Попросіть допомоги в розробника." >&2
  exit 1
fi

echo ""
echo "✅ Готово! Плагін code-skills-test підключено."
echo "   Перезапустіть Claude (повністю закрийте й відкрийте апку)."
echo "   Потім у вкладці Code напишіть: перевір мої зміни"
