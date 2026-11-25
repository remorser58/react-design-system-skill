---
name: "react-design-system"
description: "Use this skill when building or refactoring a React-only design system, component library, Storybook catalog, landing page, or responsive React + Vite frontend from visual references (Mobbin, UIBowl, Figma, Dribbble, Behance, Pinterest, 21st.dev, horon-ai/design) with Base UI headless primitives, compiler-locked no-card/no-shadow surfaces, a dedicated Motion layer, Safe Area + mobile viewport + static/dynamic OpenGraph setup, Desktop/Tablet/Mobile Visual QA, and TanStack Query/Router/Table + Zustand + ky optimization. Do not use for non-React frameworks, backend-only APIs, or standalone docs."
compatibility: "Needs file read, search, and edit on the target React + Vite or Expo project, plus shell execution for typecheck, build, Storybook, and `scripts/audit-react-ds.sh` (bash 3.2+ and jq). Uses an available browser capability with `assets/templates/visual-qa-probe.js` for responsive Visual QA and reports static-only when absent."
---

Open the rules below as needed. Resolve bundled paths from this skill directory and project paths from the target workspace.

- [rules/reference-mining-and-surface.md](rules/reference-mining-and-surface.md)
- [rules/base-ui-motion-and-storybook.md](rules/base-ui-motion-and-storybook.md)
- [rules/responsive-safe-area-and-visual-qa.md](rules/responsive-safe-area-and-visual-qa.md)
- [rules/react-vite-optimization.md](rules/react-vite-optimization.md)

# React Design System

> Mine references quantitatively, lock out cards and drop shadows at the Tailwind `@theme static` layer, build React-only Base UI primitives with isolated Motion and Storybook, enforce Safe Area and static/dynamic OpenGraph, prove Desktop/Tablet/Mobile via Visual QA probes, and eliminate DB/API waterfalls with TanStack + Zustand + ky.

- **Purpose**: Design and implement cohesive React-only design systems, Storybook catalogs, landing/intro pages, and production React + Vite apps grounded in a 4-stage reference deconstruction protocol and strict surface, motion, responsive, and data-fetching contracts.
- **Do not use when**: Building Vue/Svelte/Angular/Astro-only apps, backend-only endpoints or database migrations without UI, or standalone prose/brand copy without React code.
- **Input**: Target React + Vite (or paired Expo glass) codebase, product screens or landing requirements, and visual reference sources.
- **Output**: Tokenized React + Base UI design system (`@theme static`), dedicated Motion layer, Storybook stories with play/a11y checks, Safe Area + static/dynamic OpenGraph, TanStack/Zustand/ky architecture + Skeleton UI, and `audit-react-ds.sh --strict` + Visual QA proof.

<output_language>

Default all user-facing summaries, design briefs, audit notes, and verification reports to Korean while preserving code identifiers, React/TSX syntax, CSS variables, CLI commands, URLs, file paths, and package names in their original language.

</output_language>

<purpose>

- Run a **4-stage reference deconstruction protocol** (Harvest -> Quantitative Extraction -> Card/Shadow Strip -> Token/Base UI Synthesis) across **Mobbin**, **UIBowl**, **Figma**, **Dribbble**, **Behance**, **Pinterest**, and **21st.dev** (landing & intro pages), grounded in **`horon-ai/design`** and **`expo-glass-effect`** (`GlassView` / `GlassContainer` for native iOS 26+ parity).
- Enforce a **compiler-locked, no-card, no-shadow** surface discipline (`@theme static` resetting `--shadow-*: initial; --color-*: initial; --radius-*: initial; --text-*: initial;`): replace boxed `<Card>` wrappers and `box-shadow` with whitespace, 1px hairline dividers, tonal ground shifts, typographic hierarchy, and `LiquidGlass` / `Veil` surfaces.
- Build **React-only** components exclusively over **Base UI (`@base-ui/react`)** (`render` + `useRender` / `mergeProps`, `Drawer` BottomSheet, `Tabs.Indicator`), documented in **Storybook** (`@storybook/react-vite` + `@storybook/addon-a11y` + play functions), animated through an isolated **Motion** layer (`motion.css` + `motion/react`).
- Guarantee **Safe Area** (`viewport-fit=cover`, `env(safe-area-inset-*)`, `dvh`, iOS coarse 16px input floor, `.touch-slop`), static `index.html` + per-route `@tanstack/react-router` `head()` OpenGraph, and **Desktop / Tablet / Mobile** responsive **Visual QA** (`assets/templates/visual-qa-probe.js`).
- Optimize frontend architecture and database/API round-trips around **React + Vite + `@tanstack/react-query` + `@tanstack/react-router` + `@tanstack/react-table` + `zustand` + `ky`**, complete with exact-geometry **Skeleton UI**.

</purpose>

<routing_rule>

Use this skill when the deliverable is a React design system, Storybook component catalog, Base UI primitive set, 21st.dev-inspired React landing/intro page, or React + Vite frontend UI architecture and visual QA pass.

Do not use when:

- the deliverable uses non-React frameworks (Vue, Svelte, Angular, plain static HTML) with no React migration goal
- the deliverable is backend-only API, SQL, or infrastructure code with zero UI surface
- the deliverable is a standalone prose document, PRD, or raw image generation with no React component or styling code

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | Deliver a React-only, token-locked design system and optimized React + Vite UI grounded in mined references without cards, arbitrary shadows, or fetch waterfalls. |
| Trigger | Requests to design/build React UI, component libraries, Storybook catalogs, landing/intro pages, responsive/safe-area/OpenGraph fixes, or TanStack/Zustand/ky frontend architecture. |
| Scope | Covers 4-stage reference deconstruction, `@theme static` tokens, Base UI `useRender` primitives, dedicated Motion module, Storybook + play/a11y, `index.html` + `head()` Safe Area/OpenGraph, responsive Visual QA, and React + Vite folder/data/Skeleton architecture. Excludes backend DB schema edits and git commits unless requested. |
| Authority | User requirements and project `DESIGN.md`/tokens outrank skill defaults; mined references (Mobbin, UIBowl, Figma, Dribbble, Behance, Pinterest, 21st.dev, `horon-ai/design`) are structural/quantitative evidence to adapt, never raw assets to copy verbatim. |
| Evidence | Verify statically via `scripts/audit-react-ds.sh --strict --json`, TypeScript/Vite/Storybook builds, and visually across Desktop, Tablet, and Mobile viewports using `assets/templates/visual-qa-probe.js`. |
| Tools | File read/write/edit, shell commands (`tsc`, `vite build`, `storybook`, `scripts/audit-react-ds.sh` needing bash 3.2+ and jq), and available browser automation; mark browser checks `not_verified` if no browser exists. |
| Loop | Bounded UI/QA repair loop: run probe/capture -> apply minimal token/layout/a11y fix -> re-render and re-audit. Cap at 2 repair passes per viewport/surface before reporting blockers. |
| Output | Token files, `@base-ui/react` primitives, `motion/` utilities, `.stories.tsx`, `index.html` + `head()` Safe Area/OpenGraph, TanStack/Zustand/ky feature structure + Skeleton UI, and Korean verification summary. |
| Verification | `audit-react-ds.sh --strict --json` pass (`errors == 0`), `visual-qa-probe.js` pass across `320px`/`375px`/`768px`/`1280px`/`1440px`, 44px touch targets, Safe Area insets, Storybook a11y/play pass, parallel route prefetch check, and zero console errors. |
| Stop condition | Finish only when all mandatory surface, Base UI, Motion, Storybook, Safe Area/OpenGraph, responsive Visual QA, and TanStack/Zustand/ky checks pass or explicit blockers are documented. |

</instruction_contract>

<activation_examples>

Positive:
- "Mobbin, UIBowl, Figma 레퍼런스 참고해서 카드랑 shadow 빼고 Base UI 위에 React 디자인 시스템 + Storybook 세팅해줘."
- "Build a landing and intro page inspired by 21st.dev using React + Vite, Base UI, isolated motion/react animations, no cards/shadows, and full OpenGraph + mobile safe-area support."
- "React Vite 프론트엔드 아키텍처를 TanStack Query/Router/Table + Zustand + ky로 잡고 Skeleton UI랑 DB 왕복 최적화까지 해서 Desktop/Tablet/Mobile Visual QA 돌려줘."

Negative / Boundary:
- "Build a Vue 3 + Nuxt dashboard with PrimeVue." -> React-only boundary; out of scope unless migrating to React.
- "Optimize these PostgreSQL indexes and write a Go gRPC microservice." -> backend-only without React UI surface.
- "Write a plain text marketing blog post about design systems." -> prose-only deliverable with no React code.

</activation_examples>

<trigger_conditions>

| Situation | Mode |
|---|---|
| New React + Vite design system, `@theme static` tokens, Base UI primitives, Storybook | `system-create` |
| Landing / intro page from `21st.dev` + 4-stage visual references without cards/shadows | `landing-build` |
| Existing React UI needs Safe Area, viewport, static/dynamic OpenGraph, responsive Visual QA | `responsive-audit-fix` |
| React + Vite app needs folder structure, TanStack/Zustand/ky, Skeleton UI, round-trip optimization | `vite-architecture` |

</trigger_conditions>

<skill_architecture>

- Core (`SKILL.md` / `SKILL.ko.md`): non-negotiable rules, routing, workflow, and verification gate.
- Policies (`rules/`): `reference-mining-and-surface.md`, `base-ui-motion-and-storybook.md`, `responsive-safe-area-and-visual-qa.md`, `react-vite-optimization.md`.
- Deep Specs (`references/`): `horon-and-glass-patterns.md` (`horon-ai/design` + `expo-glass-effect`), `landing-21st-dev-patterns.md` (`21st.dev` + Mobbin/UIBowl/Figma/Dribbble/Behance/Pinterest), `react-vite-stack-blueprint.md` (TanStack/Zustand/ky + `index.html` + `head()` + Safe Area + Skeleton + Storybook).
- Starter Assets & Scripts: `assets/templates/index.html`, `assets/templates/glass-and-motion.css`, `assets/templates/storybook-preview.tsx`, `assets/templates/visual-qa-probe.js`, `scripts/audit-react-ds.sh` (`--strict --json`), and `assets/evals/react-design-system-cases.jsonl`.

</skill_architecture>

<loop_policy>

Use single-pass implementation for scaffolding tokens, starter templates, folder structure, and head metadata verified directly by `scripts/audit-react-ds.sh --strict` and `vite build`. Use a bounded 2-pass Visual QA loop for rendered Desktop, Tablet, and Mobile checks with `assets/templates/visual-qa-probe.js`: fix only measured layout, Safe Area, contrast, or state defects, then re-verify. Never loop indefinitely or alter acceptance thresholds to pass.

</loop_policy>

<language_and_translation_default>

Canonical skill documentation is authored in English (`SKILL.md`, `rules/*.md`, `references/*.md`) with structurally aligned Korean siblings (`*.ko.md`). Deliverables produced for users (summaries, design rationale, QA reports) default to Korean while keeping code, token names, and package identifiers in English.

</language_and_translation_default>

<reference_routing>

Read bundled references and templates selectively by task phase:

- `references/horon-and-glass-patterns.md` and `assets/templates/glass-and-motion.css` when defining `@theme static` tokens, 13-style typography, Base UI `useRender` / `Drawer` / `Tabs.Indicator`, `LiquidGlass`/`Veil` CSS, or React Native `expo-glass-effect` (`GlassView`, `GlassContainer`, `isGlassEffectAPIAvailable()`).
- `references/landing-21st-dev-patterns.md` when executing the 4-stage reference deconstruction across Mobbin/UIBowl/Figma/Dribbble/Behance/Pinterest or adapting `21st.dev` landing/intro sections onto flat/hairline/glass React + Base UI surfaces.
- `references/react-vite-stack-blueprint.md`, `assets/templates/index.html`, `assets/templates/storybook-preview.tsx`, and `assets/templates/visual-qa-probe.js` when scaffolding React + Vite folders, Safe Area + static/dynamic OpenGraph, `ky` client, TanStack Router `loader`/`head()`, TanStack Query, TanStack Table, Zustand, Skeleton UI, Storybook, or Visual QA.

</reference_routing>

<support_file_read_order>

1. Target project `package.json`, `index.html`, `src/` layout, and any existing `DESIGN.md` or token files.
2. `rules/reference-mining-and-surface.md` and `rules/base-ui-motion-and-storybook.md` before designing tokens or components.
3. `rules/responsive-safe-area-and-visual-qa.md` and `rules/react-vite-optimization.md` before writing routes, data hooks, or head metadata.
4. Matching files in `references/` and `assets/templates/`, followed by `scripts/audit-react-ds.sh --root <project> --strict --json`.

</support_file_read_order>

<workflow>

| Step | Action | Done when | Why not skip |
|---|---|---|---|
| 1 | Audit existing React + Vite repo (`scripts/audit-react-ds.sh --strict --json`) and run 4-stage reference deconstruction | Violations list (`file:line`) and quantitative extraction sheet (Mobbin/UIBowl/Figma/Dribbble/Behance/Pinterest/21st.dev) recorded | Prevents blind copying or breaking existing tokens |
| 2 | Define `@theme static` tokens (Color, 13-style Type, Radius, Glass/Veil, 3 Easings, `--shadow-*: initial`) inspired by `horon-ai/design` | Single source of truth in `src/design-system/tokens/` with light/dark + `data-platform` modes | Blocks one-off hex/px/shadow literals at compile time |
| 3 | Build React-only `@base-ui/react` (`useRender`, `Drawer`, `Tabs.Indicator`) primitives, dedicated `motion/` layer, Skeleton UI, and Storybook stories | Zero non-React UI kits, zero card/shadow soup, all states + a11y + play functions in Storybook | Ensures accessibility, motion isolation, and visual testability |
| 4 | Configure `index.html` (`viewport-fit=cover`, static OpenGraph, Twitter, `theme-color`), router `head()` dynamic OG, and Safe Area/coarse CSS | `audit-react-ds.sh --strict` reports zero head, Safe Area, zoom-lock, or `dvh` violations | Avoids iOS notch clipping, Safari focus zoom, and broken social previews |
| 5 | Implement React + Vite architecture (`@tanstack/react-router` `defaultPreloadStaleTime: 0` loaders + `@tanstack/react-query` + URL-synced `@tanstack/react-table` + `zustand` + `ky`) | Parallel route prefetching eliminates waterfalls; DB/API round-trips minimized; Skeletons match final geometry | Guarantees fast first render and zero CLS |
| 6 | Execute Desktop, Tablet, and Mobile Visual QA using `assets/templates/visual-qa-probe.js` (Light/Dark, Loaded/Skeleton/Empty/Error/Focus, Storybook a11y) | Probe returns `ok: true`, zero overflow at 320px+, 44px touch targets, contrast >= 4.5:1, typecheck & build green | Proves real-browser fidelity across every device class |

</workflow>

<required>

| Area | Non-Negotiable Requirement |
|---|---|
| Stack | React-only UI (`react` + `vite` + TypeScript) built on `@base-ui/react` (`useRender` / `Drawer` / `Tabs`) + **Storybook** (`@storybook/react-vite` + `addon-a11y`) |
| References | Execute 4-stage mining across **Mobbin**, **UIBowl**, **Figma**, **Dribbble**, **Behance**, **Pinterest**, **`horon-ai/design`**, **`expo-glass-effect`**, and **`21st.dev`** (landing/intro pages) |
| Surface & Motion | Compiler-locked `@theme static` (`--shadow-*: initial`), **no `<Card>` soup, no decorative `box-shadow`**; separate **Motion** layer (`motion.css` + `motion/react`) with `prefers-reduced-motion` |
| Safe Area & Head | Audit & implement `viewport-fit=cover`, `env(safe-area-inset-*)`, `.touch-slop`, `dvh`, iOS 16px coarse floor, `theme-color`, and static + per-route `head()` **OpenGraph** |
| Optimization & QA | **TanStack Query + TanStack Router + TanStack Table + Zustand + ky**, domain folder structure, exact-geometry **Skeleton UI**, minimal DB round-trips, and **Desktop / Tablet / Mobile Visual QA** (`visual-qa-probe.js`) |

</required>

<forbidden>

| Area | Forbidden Practice |
|---|---|
| Frameworks & Kits | Using Vue, Svelte, Angular, Astro-only UI, jQuery, `@radix-ui/*`, shadcn/ui, MUI, or AntD instead of React + `@base-ui/react` |
| Surface & Motion | Wrapping sections in boxed `<Card>` containers, using `shadow-sm/md/lg/xl/2xl` or arbitrary `box-shadow`, scattering inline animation curves, putting `.touch-slop` on elements with `::after`, or setting `opacity: 0` on `expo-glass-effect` `GlassView` |
| Mobile & Head | Omitting `viewport-fit=cover` or `env(safe-area-inset-*)`, disabling pinch zoom (`user-scalable=no` / `maximum-scale=1`), using `100vh` without `dvh`, or shipping missing `og:*` tags |
| Data & State | Serial `useEffect` fetch waterfalls, N+1 API loops, storing server cache in Zustand, mismatched Router/Query stale ownership, or layout-jumping spinners instead of Skeleton UI |

</forbidden>

<validation>

- [ ] `scripts/audit-react-ds.sh --root <target-project> --strict --json` returns `"ok": true` with `summary.errors == 0`.
- [ ] `tsc --noEmit`, `vite build`, and Storybook build (`storybook build`) succeed with zero errors.
- [ ] Desktop (`1280px`/`1440px`), Tablet (`768px`/`1024px`), and Mobile (`320px`/`375px`) Visual QA (`visual-qa-probe.js`) confirms zero horizontal overflow, Safe Area clearance, 44px touch targets, Light/Dark parity, and all Skeleton/Empty/Error/Focus states.
- [ ] Network trace / route loaders confirm parallel prefetching and minimal DB/API round-trips via `@tanstack/react-router` + `@tanstack/react-query` + `ky`.

</validation>

## Sources

> Checked 2026-11-26.

| Claim | Source |
|---|---|
| Horon `@theme static` tokens, Base UI components, `LiquidGlass`/`Veil`, `.touch-slop`, motion utilities, and `horon-ai/design` architecture | `references/horon-and-glass-patterns.md`, <https://github.com/horon-ai/design> |
| Base UI v1 `useRender`, `mergeProps`, `data-starting-style` / `data-ending-style` | <https://base-ui.com/react/utils/use-render> |
| Native iOS 26+ `GlassView`, `GlassContainer`, runtime guards, and `opacity: 0` constraint | `references/horon-and-glass-patterns.md`, <https://docs.expo.dev/versions/latest/sdk/glass-effect/> |
| Landing/intro hero, section cadence, shader/motion patterns, and 4-stage reference mining | `references/landing-21st-dev-patterns.md`, <https://21st.dev/> |
| React + Vite folder structure, Safe Area, static/dynamic OpenGraph (`head()`), TanStack Query/Router/Table, Zustand, ky, Skeleton UI, Storybook | `references/react-vite-stack-blueprint.md` |
