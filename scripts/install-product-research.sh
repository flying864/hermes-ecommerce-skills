#!/usr/bin/env bash
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/flying864/hermes-ecommerce-skills/main"
SKILL_URL="$REPO_RAW/ecommerce/amazon-product-research-assistant/SKILL.md"
BUNDLE_URL="$REPO_RAW/bundles/product-research.yaml"
PROFILE=""
HERMES_HOME_OVERRIDE=""

usage() {
  cat <<'EOF'
安装 Hermes Ecommerce Skills 的 /product-research bundle。

用法：
  install-product-research.sh [--profile PROFILE_NAME] [--hermes-home PATH]

示例：
  # 默认 Hermes profile
  bash scripts/install-product-research.sh

  # 指定 profile
  bash scripts/install-product-research.sh --profile xiaosun

  # 指定 HERMES_HOME
  bash scripts/install-product-research.sh --hermes-home /path/to/hermes-home
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile|-p)
      PROFILE="${2:-}"
      [[ -n "$PROFILE" ]] || { echo "错误：--profile 需要 profile 名称" >&2; exit 1; }
      shift 2
      ;;
    --hermes-home)
      HERMES_HOME_OVERRIDE="${2:-}"
      [[ -n "$HERMES_HOME_OVERRIDE" ]] || { echo "错误：--hermes-home 需要路径" >&2; exit 1; }
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "未知参数：$1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -n "$HERMES_HOME_OVERRIDE" ]]; then
  TARGET_HOME="$HERMES_HOME_OVERRIDE"
elif [[ -n "$PROFILE" ]]; then
  TARGET_HOME="$HOME/.hermes/profiles/$PROFILE"
else
  TARGET_HOME="$HOME/.hermes"
fi

BUNDLE_DIR="$TARGET_HOME/skill-bundles"
BUNDLE_PATH="$BUNDLE_DIR/product-research.yaml"

if ! command -v curl >/dev/null 2>&1; then
  echo "错误：需要 curl 命令" >&2
  exit 1
fi

if ! command -v hermes >/dev/null 2>&1; then
  echo "警告：未找到 hermes 命令。将只下载 bundle；skill 安装请在 Hermes 可用后手动执行。" >&2
else
  echo "==> 安装核心电商 skill: amazon-product-research-assistant"
  hermes skills install "$SKILL_URL" || {
    echo "警告：hermes skills install 失败。你可以稍后手动执行：" >&2
    echo "  hermes skills install $SKILL_URL" >&2
  }
fi

echo "==> 安装 bundle 到：$BUNDLE_PATH"
mkdir -p "$BUNDLE_DIR"
curl -fsSL "$BUNDLE_URL" -o "$BUNDLE_PATH"

if [[ ! -s "$BUNDLE_PATH" ]]; then
  echo "错误：bundle 下载失败或文件为空：$BUNDLE_PATH" >&2
  exit 1
fi

echo "==> 检查 bundle 内容"
if ! grep -q "name: product-research" "$BUNDLE_PATH"; then
  echo "错误：bundle 文件内容异常：$BUNDLE_PATH" >&2
  exit 1
fi

cat <<EOF

✅ /product-research bundle 已安装

安装位置：
  $BUNDLE_PATH

下一步，在 Hermes / Telegram / Discord 等会话中使用：
  /product-research bowl covers
  /product-research garlic press，目标美国站，重点看竞争和利润
  /product-research https://www.amazon.com/dp/B0XXXXXXX 深度分析这个 ASIN 是否值得做

注意：/product-research 还依赖 Hermes 通用 skills：
  - subagent-driven-development
  - youtube-content
  - html-artifact-generation

这些通用 skill 不由本仓库维护。如果缺失，请用 Hermes 的 skills search/install 能力安装，或参考 Hermes 官方文档。
EOF
