# React Design System Skill

English | [한국어](README.ko.md)

A self-contained, React-only design system and frontend architecture skill for coding agents. It turns visual reference mining into compiler-locked tokens, `@base-ui/react` headless primitives, isolated Motion, Storybook catalogs, Safe Area + OpenGraph setup, Desktop/Tablet/Mobile Visual QA, and zero-waterfall React + Vite data fetching.

## Core Principles

- **4-Stage Reference Deconstruction**: Harvest balanced references from **Mobbin**, **UIBowl**, **Figma**, **Dribbble**, **Behance**, **Pinterest**, and **21st.dev** (landing/intro pages), extract quantitative type/spacing/timing ratios, strip boxed cards/shadows, and synthesize tokens inspired by [`horon-ai/design`](https://github.com/horon-ai/design).
- **Compiler-Locked No-Card, No-Shadow Surfaces**: Reset Tailwind v4 `@theme static` (`--shadow-*: initial; --color-*: initial; --radius-*: initial; --text-*: initial;`). Replace `<Card>` soup and drop shadows with whitespace, 1px hairline dividers, tonal shifts, and `LiquidGlass` / `Veil` surfaces.
- **React-Only Base UI + Isolated Motion + Storybook**: Build exclusively with **React 19 + TypeScript** over **`@base-ui/react`** (`render`, `useRender`/`mergeProps`, `Drawer` BottomSheet, `Tabs.Indicator`), isolate animations in `src/design-system/motion/` (`motion.css` + `motion/react`), ship **`@storybook/react-vite`** stories (`addon-a11y` + play checks), and support native iOS 26+ parity via [`expo-glass-effect`](https://docs.expo.dev/versions/latest/sdk/glass-effect/) (`GlassView`, `GlassContainer`, runtime guards, zero `opacity: 0`).
- **Safe Area, Mobile Viewport, Static/Dynamic OpenGraph & Visual QA**: Audit and enforce `viewport-fit=cover`, `env(safe-area-inset-*)`, `dvh`, iOS coarse-pointer 16px input floor, `.touch-slop`, `index.html` + `@tanstack/react-router` `head()` OpenGraph, and automated browser verification across Desktop, Tablet, and Mobile via `assets/templates/visual-qa-probe.js`.
- **React + Vite Optimization**: Domain folder layout (`src/app`, `src/design-system`, `src/routes`, `src/features`, `src/shared`), zero-waterfall `@tanstack/react-router` `loader` prefetch (`defaultPreloadStaleTime: 0`) + `@tanstack/react-query`, URL-synced `@tanstack/react-table`, UI-only `zustand`, `ky` (`signal` propagation), and exact-geometry Zero-CLS **Skeleton UI**.

## Install

Download versioned archives (`react-design-system.zip` + `SHA256SUMS.txt` + `release-manifest.json`, published automatically from `main` via `.github/workflows/release.yml` matching `VERSION`) from [GitHub Releases](https://github.com/remorser58/react-design-system-skill/releases), or clone directly:

```sh
git clone https://github.com/remorser58/react-design-system-skill.git
# Antigravity
mkdir -p ~/.gemini/config/skills
cp -R react-design-system-skill/skills/react-design-system ~/.gemini/config/skills/
# Claude Code
mkdir -p ~/.claude/skills
cp -R react-design-system-skill/skills/react-design-system ~/.claude/skills/
# Codex
mkdir -p ~/.codex/skills
cp -R react-design-system-skill/skills/react-design-system ~/.codex/skills/
```

## Audit Script & Starter Assets

Run the bundled static auditor (requires `bash 3.2+` and `jq`) against any React + Vite repository:

```sh
bash skills/react-design-system/scripts/audit-react-ds.sh --root /path/to/react-vite-app --strict --json
```

Starter templates included under `skills/react-design-system/assets/templates/`:

- `index.html` — Safe Area (`viewport-fit=cover`), light/dark `theme-color`, Apple web app tags, OpenGraph, Twitter Card, and no-FOUC script
- `glass-and-motion.css` — `@theme static` locks, `.liquid-layers` / `.veil-*`, `.touch-slop`, `.pt-safe`/`.pb-safe`/`.px-safe`, coarse 16px floor, and `motion-*` utilities
- `storybook-preview.tsx` — Light/Dark & `data-platform` toolbars, Mobile/Tablet/Desktop viewports, `<MotionConfig reducedMotion="user">`, and `addon-a11y`
- `visual-qa-probe.js` — Browser DOM/style probe for overflow, touch targets, coarse input font sizes, non-overlay shadows, and image/button accessibility

## Repository Layout

```text
skills/react-design-system/
  SKILL.md, SKILL.ko.md        Core contract & workflow (EN/KO)
  rules/                       Normative policy rules (EN/KO)
  references/                  horon-ai/expo-glass, 21st.dev landing, React+Vite blueprint (EN/KO)
  scripts/audit-react-ds.sh    Strict static auditor with file:line violations
  assets/templates/            Drop-in index.html, glass-and-motion.css, storybook-preview.tsx, visual-qa-probe.js
  assets/evals/                20 bilingual/mixed trigger & regression eval cases
tests/test_skill_package.py    Offline package & script regression tests
.claude-plugin/                Plugin & marketplace manifests
```

## Development

```sh
python3 -m unittest discover -s tests -p 'test_*.py' -v
```

## License

[MIT](LICENSE)
