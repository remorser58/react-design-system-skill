#!/usr/bin/env bash
# Static auditor for React + Vite design system projects.
# Checks Safe Area, mobile viewport, OpenGraph, no-card/no-shadow discipline,
# Base UI, dedicated Motion, Storybook, Expo Glass pitfalls, and TanStack/Zustand/ky stack.
set -uo pipefail

ROOT_DIR="."
JSON_OUT=0
STRICT=0
HELP=0

print_help() {
  cat <<'EOF'
Usage: bash scripts/audit-react-ds.sh [--root <project-dir>] [--strict] [--json] [--help]

Audits a React + Vite (or paired Expo) project against the react-design-system contract.
  --root <dir>  Target project directory (defaults to current directory)
  --strict      Promote missing Safe Area CSS, dvh, coarse 16px floor, reduced-motion,
                dedicated motion dir, Skeleton UI, Storybook stories, and useEffect fetch
                warnings to error severity
  --json        Emit structured JSON output
  --help        Show this help

Requires bash 3.2+ and jq.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --root)
      if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
        printf '{"ok":false,"error":"--root requires a directory path"}\n' >&2
        exit 2
      fi
      ROOT_DIR="$2"
      shift 2
      ;;
    --strict)
      STRICT=1
      shift
      ;;
    --json)
      JSON_OUT=1
      shift
      ;;
    --help|-h)
      HELP=1
      shift
      ;;
    *)
      printf '{"ok":false,"error":"Unknown argument: %s"}\n' "$1" >&2
      exit 2
      ;;
  esac
done

if [ "$HELP" -eq 1 ]; then
  print_help
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  printf '{"ok":false,"error":"jq is required"}\n' >&2
  exit 2
fi

if [ ! -d "$ROOT_DIR" ]; then
  printf '{"ok":false,"error":"Root directory not found: %s"}\n' "$ROOT_DIR" >&2
  exit 2
fi

WORK=$(mktemp -d "${TMPDIR:-/tmp}/audit-react-ds.XXXXXX") || exit 2
trap 'rm -rf "$WORK"' EXIT INT TERM
VIOLATIONS_FILE="$WORK/violations.jsonl"
: > "$VIOLATIONS_FILE"

ROOT_ABS=$(CDPATH='' cd -- "$ROOT_DIR" && pwd -P)

HTML_FILE=""
HTML_REL=""
if [ -f "$ROOT_ABS/index.html" ]; then
  HTML_FILE="$ROOT_ABS/index.html"
  HTML_REL="index.html"
elif [ -f "$ROOT_ABS/public/index.html" ]; then
  HTML_FILE="$ROOT_ABS/public/index.html"
  HTML_REL="public/index.html"
fi

PKG_FILE=""
if [ -f "$ROOT_ABS/package.json" ]; then
  PKG_FILE="$ROOT_ABS/package.json"
fi

strict_sev() {
  if [ "$STRICT" -eq 1 ]; then printf 'error'; else printf 'warning'; fi
}

add_violation() {
  local code=$1 severity=$2 file=$3 line=$4 message=$5
  jq -cn \
    --arg code "$code" \
    --arg severity "$severity" \
    --arg file "$file" \
    --argjson line "$line" \
    --arg message "$message" \
    '{code: $code, severity: $severity, file: $file, line: $line, message: $message}' >> "$VIOLATIONS_FILE"
}

has_pattern_in_file() {
  local pat=$1 file=$2
  [ -n "$file" ] && [ -f "$file" ] && grep -qiE "$pat" "$file"
}

has_pattern_in_src() {
  local pat=$1
  if [ -d "$ROOT_ABS/src" ]; then
    grep -rqE --include="*.ts" --include="*.tsx" --include="*.css" "$pat" "$ROOT_ABS/src" 2>/dev/null
  else
    return 1
  fi
}

scan_src_violations() {
  local code=$1 severity=$2 pat=$3 msg=$4 exclude_pat=${5:-}
  local count=0 matches_file="$WORK/matches.txt"
  : > "$matches_file"
  if [ -d "$ROOT_ABS/src" ]; then
    (grep -rnE --include="*.ts" --include="*.tsx" --include="*.css" "$pat" "$ROOT_ABS/src" 2>/dev/null || true) > "$matches_file"
  fi
  while IFS= read -r hit; do
    [ -n "$hit" ] || continue
    local fpath rest lno rel
    fpath=${hit%%:*}
    rest=${hit#*:}
    lno=${rest%%:*}
    rel=${fpath#"$ROOT_ABS"/}
    if [ -n "$exclude_pat" ] && printf '%s' "$rel" | grep -qE "$exclude_pat"; then
      continue
    fi
    count=$((count + 1))
    add_violation "$code" "$severity" "$rel" "$lno" "$msg"
  done < "$matches_file"
  printf '%s' "$count"
}

pkg_has_dep() {
  local dep=$1
  [ -n "$PKG_FILE" ] && jq -e --arg d "$dep" '((.dependencies // {}) + (.devDependencies // {}) + (.peerDependencies // {})) | has($d)' "$PKG_FILE" >/dev/null 2>&1
}

pkg_has_prefix_dep() {
  local prefix=$1
  [ -n "$PKG_FILE" ] && jq -e --arg p "$prefix" '((.dependencies // {}) + (.devDependencies // {}) + (.peerDependencies // {})) | keys | any(startswith($p))' "$PKG_FILE" >/dev/null 2>&1
}

# 1. HTML & Head checks
html_present=false
viewport_fit_cover=false
no_zoom_lock=true
og_title=false
og_description=false
og_image=false
twitter_card=false
theme_color=false

if [ -n "$HTML_FILE" ]; then
  html_present=true
  if has_pattern_in_file 'viewport-fit=cover' "$HTML_FILE"; then
    viewport_fit_cover=true
  else
    add_violation "HEAD_VIEWPORT_FIT_MISSING" "error" "$HTML_REL" 1 "Missing viewport-fit=cover in viewport meta tag"
  fi
  if has_pattern_in_file 'user-scalable=no|maximum-scale=1([.,;"'\'' ]|$)' "$HTML_FILE"; then
    no_zoom_lock=false
    add_violation "HEAD_ZOOM_LOCK" "error" "$HTML_REL" 1 "Forbidden pinch-zoom lock (user-scalable=no or maximum-scale=1)"
  fi
  has_pattern_in_file 'property=["'\'']og:title["'\'']' "$HTML_FILE" && og_title=true
  has_pattern_in_file 'property=["'\'']og:description["'\'']' "$HTML_FILE" && og_description=true
  has_pattern_in_file 'property=["'\'']og:image["'\'']' "$HTML_FILE" && og_image=true
  if [ "$og_title" != "true" ] || [ "$og_description" != "true" ] || [ "$og_image" != "true" ]; then
    add_violation "HEAD_OG_MISSING" "error" "$HTML_REL" 1 "Missing required OpenGraph tags (og:title, og:description, og:image)"
  fi
  if has_pattern_in_file 'name=["'\'']twitter:card["'\'']' "$HTML_FILE"; then
    twitter_card=true
  else
    add_violation "HEAD_TWITTER_MISSING" "error" "$HTML_REL" 1 "Missing twitter:card meta tag"
  fi
  if has_pattern_in_file 'name=["'\'']theme-color["'\'']' "$HTML_FILE"; then
    theme_color=true
  else
    add_violation "HEAD_THEME_COLOR_MISSING" "error" "$HTML_REL" 1 "Missing theme-color meta tag"
  fi
else
  add_violation "HEAD_MISSING" "error" "index.html" 0 "Missing index.html or public/index.html"
fi

# 2. CSS / TSX Surface, Responsive & Motion checks
safe_area_css=false
dvh_used=false
coarse_16px_floor=false
reduced_motion_css=false

if has_pattern_in_src 'env\(safe-area-inset-'; then
  safe_area_css=true
else
  add_violation "SAFE_AREA_CSS_MISSING" "$(strict_sev)" "src" 0 "No env(safe-area-inset-*) utilities found in src/"
fi

if has_pattern_in_src '(min-h-dvh|100dvh|dvh)' || has_pattern_in_file '(min-h-dvh|100dvh)' "$HTML_FILE"; then
  dvh_used=true
else
  add_violation "DVH_MISSING" "$(strict_sev)" "src" 0 "No dynamic viewport height (dvh / min-h-dvh) usage found"
fi

if has_pattern_in_src 'max\(16px'; then
  coarse_16px_floor=true
else
  add_violation "COARSE_16PX_FLOOR_MISSING" "$(strict_sev)" "src" 0 "Missing coarse-pointer 16px input font-size floor (max(16px, 1em))"
fi

if has_pattern_in_src 'prefers-reduced-motion'; then
  reduced_motion_css=true
else
  add_violation "REDUCED_MOTION_MISSING" "$(strict_sev)" "src" 0 "Missing prefers-reduced-motion fallback in src/"
fi

shadow_violations=$(scan_src_violations "SURFACE_SHADOW_UTILITY" "error" '(^|[^A-Za-z0-9_-])shadow-(sm|md|lg|xl|2xl)([^A-Za-z0-9_-]|$)' "Decorative Tailwind shadow-* utility violates no-shadow rule")
inline_box_shadow_violations=$(scan_src_violations "SURFACE_INLINE_BOX_SHADOW" "error" 'box-shadow[[:space:]]*:' "Ad-hoc box-shadow outside tokens/glass/motion CSS violates no-shadow rule" '(tokens/|glass|motion)')
card_soup_violations=$(scan_src_violations "SURFACE_CARD_SOUP" "error" '<Card(Header|Content|Footer|Title|Description)?([^A-Za-z0-9_]|>)' "Generic <Card> wrapper violates no-card surface rule")
glass_opacity_zero=$(scan_src_violations "GLASS_OPACITY_ZERO" "error" 'GlassView[^>]*opacity:[[:space:]]*0' "Setting opacity: 0 on GlassView breaks native UIVisualEffectView rendering")
raw_100vh_violations=$(scan_src_violations "RAW_100VH_WITHOUT_DVH" "$(strict_sev)" '(^|[^A-Za-z0-9_-])(100vh|h-screen|min-h-screen)([^A-Za-z0-9_-]|$)' "Static 100vh/h-screen risks mobile address-bar clipping; prefer dvh/min-h-dvh")

# 3. useEffect fetch waterfall scan (4-line window around useEffect)
effect_waterfall_hits=0
if [ -d "$ROOT_ABS/src" ]; then
  EFFECT_FILE="$WORK/effect.txt"
  : > "$EFFECT_FILE"
  find "$ROOT_ABS/src" -type f \( -name "*.ts" -o -name "*.tsx" \) -print 2>/dev/null | LC_ALL=C sort | while IFS= read -r f; do
    awk -v root="$ROOT_ABS" -v file="$f" '
      /useEffect[[:space:]]*\(/ { win = 4; start = NR }
      win > 0 {
        if ($0 ~ /(fetch\(|ky\.|http\.(get|post)|axios\.)/) {
          rel = substr(file, length(root) + 2)
          printf "%s\t%d\n", rel, NR
          win = 0
        } else {
          win--
        }
      }
    ' "$f"
  done > "$EFFECT_FILE"
  while IFS=$'\t' read -r rel lno; do
    [ -n "$rel" ] || continue
    effect_waterfall_hits=$((effect_waterfall_hits + 1))
    add_violation "PERF_EFFECT_FETCH_WATERFALL" "$(strict_sev)" "$rel" "$lno" "Avoid fetching inside useEffect; prefetch via TanStack Router loader + ensureQueryData"
  done < "$EFFECT_FILE"
fi

# 4. Package & Architecture checks
dep_react=false
dep_vite=false
dep_base_ui=false
dep_motion=false
dep_tanstack_query=false
dep_tanstack_router=false
dep_tanstack_table=false
dep_zustand=false
dep_ky=false
storybook_present=false
motion_dir_present=false
skeleton_present=false
stories_count=0
forbidden_framework=false
forbidden_ui_kit=false

check_dep() {
  local dep=$1 varname=$2
  if pkg_has_dep "$dep"; then
    eval "$varname=true"
  else
    add_violation "STACK_MISSING_DEP" "error" "package.json" 1 "Missing required stack dependency: $dep"
  fi
}

check_dep "react" dep_react
check_dep "vite" dep_vite
check_dep "@base-ui/react" dep_base_ui
check_dep "@tanstack/react-query" dep_tanstack_query
check_dep "@tanstack/react-router" dep_tanstack_router
check_dep "@tanstack/react-table" dep_tanstack_table
check_dep "zustand" dep_zustand
check_dep "ky" dep_ky

if pkg_has_dep "motion" || pkg_has_dep "framer-motion"; then
  dep_motion=true
else
  add_violation "STACK_MISSING_DEP" "$(strict_sev)" "package.json" 1 "Missing dedicated motion package (motion)"
fi

if pkg_has_dep "vue" || pkg_has_dep "svelte" || pkg_has_dep "@angular/core"; then
  forbidden_framework=true
  add_violation "STACK_FORBIDDEN_FRAMEWORK" "error" "package.json" 1 "Non-React framework dependency violates React-only rule"
fi

if pkg_has_prefix_dep "@radix-ui/" || pkg_has_prefix_dep "@mui/" || pkg_has_dep "antd" || pkg_has_prefix_dep "@chakra-ui/"; then
  forbidden_ui_kit=true
  add_violation "STACK_FORBIDDEN_UI_KIT" "error" "package.json" 1 "Forbidden UI kit detected; build primitives on @base-ui/react"
fi
if [ -d "$ROOT_ABS/src" ]; then
  radix_src=$(scan_src_violations "STACK_FORBIDDEN_UI_KIT" "error" 'from[[:space:]]+["'\''](@radix-ui/|@mui/|antd|@chakra-ui/)' "Forbidden UI kit import in src/; use @base-ui/react")
  if [ "$radix_src" -gt 0 ]; then forbidden_ui_kit=true; fi
fi

if [ -d "$ROOT_ABS/.storybook" ] || pkg_has_dep "@storybook/react-vite"; then
  storybook_present=true
else
  add_violation "STACK_MISSING_DEP" "error" "package.json" 1 "Missing Storybook (@storybook/react-vite or .storybook/)"
fi

if [ -d "$ROOT_ABS/src/design-system/motion" ] || [ -d "$ROOT_ABS/src/motion" ]; then
  motion_dir_present=true
else
  add_violation "MOTION_LAYER_MISSING" "$(strict_sev)" "src" 0 "Missing dedicated motion folder (src/design-system/motion or src/motion)"
fi

if [ -d "$ROOT_ABS/src" ]; then
  if find "$ROOT_ABS/src" -type f -iname '*skeleton*' 2>/dev/null | grep -q .; then
    skeleton_present=true
  fi
  stories_count=$(find "$ROOT_ABS/src" -type f \( -name '*.stories.tsx' -o -name '*.stories.ts' \) 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "$skeleton_present" != "true" ]; then
  add_violation "SKELETON_MISSING" "$(strict_sev)" "src" 0 "No Skeleton UI component found under src/"
fi
if [ "$stories_count" -eq 0 ]; then
  add_violation "STORIES_MISSING" "$(strict_sev)" "src" 0 "No Storybook *.stories.tsx files found under src/"
fi

error_count=$(jq -s '[.[] | select(.severity == "error")] | length' "$VIOLATIONS_FILE")
warning_count=$(jq -s '[.[] | select(.severity == "warning")] | length' "$VIOLATIONS_FILE")
total_violations=$(jq -s 'length' "$VIOLATIONS_FILE")
violations_json=$(jq -s -c '.[:50]' "$VIOLATIONS_FILE")

all_ok=true
if [ "$error_count" -gt 0 ]; then
  all_ok=false
fi

report_json=$(jq -cn \
  --arg root "$ROOT_ABS" \
  --argjson strict "$( [ "$STRICT" -eq 1 ] && printf 'true' || printf 'false' )" \
  --argjson ok "$all_ok" \
  --argjson errors "$error_count" \
  --argjson warnings "$warning_count" \
  --argjson total "$total_violations" \
  --argjson violations "$violations_json" \
  --argjson htmlPresent "$html_present" \
  --argjson viewportFitCover "$viewport_fit_cover" \
  --argjson noZoomLock "$no_zoom_lock" \
  --argjson ogTitle "$og_title" \
  --argjson ogDescription "$og_description" \
  --argjson ogImage "$og_image" \
  --argjson twitterCard "$twitter_card" \
  --argjson themeColor "$theme_color" \
  --argjson safeAreaCss "$safe_area_css" \
  --argjson dvhUsed "$dvh_used" \
  --argjson coarse16pxFloor "$coarse_16px_floor" \
  --argjson reducedMotionCss "$reduced_motion_css" \
  --argjson shadowViolations "$shadow_violations" \
  --argjson inlineBoxShadowViolations "$inline_box_shadow_violations" \
  --argjson cardSoupViolations "$card_soup_violations" \
  --argjson glassOpacityZero "$glass_opacity_zero" \
  --argjson raw100vhViolations "$raw_100vh_violations" \
  --argjson effectWaterfallHits "$effect_waterfall_hits" \
  --argjson depReact "$dep_react" \
  --argjson depVite "$dep_vite" \
  --argjson depBaseUi "$dep_base_ui" \
  --argjson depMotion "$dep_motion" \
  --argjson depTanstackQuery "$dep_tanstack_query" \
  --argjson depTanstackRouter "$dep_tanstack_router" \
  --argjson depTanstackTable "$dep_tanstack_table" \
  --argjson depZustand "$dep_zustand" \
  --argjson depKy "$dep_ky" \
  --argjson storybookPresent "$storybook_present" \
  --argjson motionDirPresent "$motion_dir_present" \
  --argjson skeletonPresent "$skeleton_present" \
  --argjson storiesCount "$stories_count" \
  --argjson forbiddenFramework "$forbidden_framework" \
  --argjson forbiddenUiKit "$forbidden_ui_kit" \
  '{
    ok: $ok,
    strict: $strict,
    root: $root,
    summary: {
      errors: $errors,
      warnings: $warnings,
      totalViolations: $total
    },
    violations: $violations,
    head: {
      htmlPresent: $htmlPresent,
      viewportFitCover: $viewportFitCover,
      noZoomLock: $noZoomLock,
      ogTitle: $ogTitle,
      ogDescription: $ogDescription,
      ogImage: $ogImage,
      twitterCard: $twitterCard,
      themeColor: $themeColor
    },
    surfaceAndResponsive: {
      safeAreaCss: $safeAreaCss,
      dvhUsed: $dvhUsed,
      coarse16pxFloor: $coarse16pxFloor,
      reducedMotionCss: $reducedMotionCss,
      shadowViolations: $shadowViolations,
      inlineBoxShadowViolations: $inlineBoxShadowViolations,
      cardSoupViolations: $cardSoupViolations,
      glassOpacityZero: $glassOpacityZero,
      raw100vhViolations: $raw100vhViolations,
      effectWaterfallHits: $effectWaterfallHits
    },
    stack: {
      react: $depReact,
      vite: $depVite,
      baseUi: $depBaseUi,
      motion: $depMotion,
      tanstackQuery: $depTanstackQuery,
      tanstackRouter: $depTanstackRouter,
      tanstackTable: $depTanstackTable,
      zustand: $depZustand,
      ky: $depKy,
      storybook: $storybookPresent,
      motionDirPresent: $motionDirPresent,
      skeletonPresent: $skeletonPresent,
      storiesCount: $storiesCount,
      forbiddenFramework: $forbiddenFramework,
      forbiddenUiKit: $forbiddenUiKit
    }
  }')

if [ "$JSON_OUT" -eq 1 ]; then
  printf '%s\n' "$report_json"
else
  printf 'Audit root: %s (ok=%s, errors=%s, warnings=%s)\n' "$ROOT_ABS" "$all_ok" "$error_count" "$warning_count"
  jq -r '.violations[] | "[\(.severity)] \(.code) \(.file):\(.line) — \(.message)"' <<< "$report_json"
fi
