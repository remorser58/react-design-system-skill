# Reference Mining and No-Card / No-Shadow Surface Rules

**Purpose**: Ground every design system and interface in concrete visual references via a 4-stage deconstruction protocol (Mobbin, UIBowl, Figma, Dribbble, Behance, Pinterest, 21st.dev, `horon-ai/design`) while locking out card-soup and decorative shadows at the CSS compiler layer.

## 1. Four-Stage Reference Deconstruction Protocol ("파쿠리")

- RDS-R-1: **Stage 1 — Harvest Mix**: Before writing JSX, collect a balanced reference set so layout IA and visual craft reinforce each other:
  - **Mobbin & UIBowl (2 UX/IA refs)**: Real shipped product IA, screen transitions, navigation chrome, bottom sheets, filter bars, empty/error/loading states, and mobile ergonomics.
  - **Figma & `horon-ai/design` (1 Token/System ref)**: Semantic Color pairs, Scale, 13-style Typography across Web/Desktop/Mobile, Glass/Veil layers, component slot anatomy, and variant matrices.
  - **Dribbble, Behance & Pinterest (1–2 Editorial/Visual refs)**: Headline-to-body scale ratios, negative-space proportions, asymmetrical grids, tonal ground contrast, and pacing.
  - **21st.dev (Landing/Intro ref)**: Hero archetypes, animated headline reveals, shader/ambient canvas backdrops, tabbed feature showcases, pricing toggles, FAQ accordions, and conversion cadence.

- RDS-R-2: **Stage 2 — Quantitative Extraction Sheet**: Never stop at vague adjectives ("clean", "modern"). Record measurable values from the harvested references: type scale ratio (e.g., `display-lg 56 / body-md 16 = 3.5x`), max prose line measure (`55–70ch`), spacing base unit (`4px`), hairline opacity, tonal step delta, motion duration band, coarse touch target (`44px`), and above-the-fold element count.

- RDS-R-3: **Stage 3 — Originality & Copyright Guard**: Extract layout geometry, proportions, typographic rhythm, and interaction mechanics only. Replace every third-party logo, trademark, mascot, illustration, and proprietary copy with project-owned assets.

## 2. Compiler-Locked No-Card, No-Shadow Surface Discipline

- RDS-R-4: **No Card-Soup (`<Card>` elimination)**. Never wrap page sections, KPIs, settings groups, feature items, pricing columns, or list rows in generic boxed `<Card>` / `<CardHeader>` / `<CardContent>` containers. Apply these flat replacements:
  - KPI strip -> `divide-x divide-border-default` with `tabular-nums`
  - Feature grid -> 1px hairline matrix (`border-t border-l` parent + `border-r border-b` cells) or open whitespace grid
  - Pricing columns -> vertical hairline dividers + subtle `bg-bg-subtle` tonal shift and 1px brand top hairline on featured tier
  - Settings / Activity / Table -> `divide-y divide-border-default` rows with generous padding and typography hierarchy

- RDS-R-5: **No Decorative Box Shadows (`box-shadow` elimination)**. Forbid `shadow-sm`, `shadow-md`, `shadow-lg`, `shadow-xl`, `shadow-2xl`, and ad-hoc `box-shadow` declarations on inline content, feature lists, pricing columns, hero product frames, or data tables.

- RDS-R-6: **Stage 4 — Compiler-Level `@theme static` Token Locking**. In Tailwind v4 CSS (`assets/templates/glass-and-motion.css`), reset default utilities inside `@theme static` with `--color-*: initial; --radius-*: initial; --text-*: initial; --shadow-*: initial;` so unapproved colors and Tailwind drop shadows fail to emit CSS at compile time.

- RDS-R-7: **Glass & Veil Overlays Instead of Heavy Drop Shadows**. Floating surfaces (top bar, sticky tab tray, menus, popovers, dialogs, command palettes) use `LiquidGlass` (20px blur, 1.8x saturate, 1px masked vertical rim gradient) or `Veil` (8px blur, 1.6x saturate, 1px ring), falling back cleanly to `glass-fill-frost` under `prefers-reduced-transparency: reduce` or missing `backdrop-filter`. Detached opaque overlays (account menu, command palette) may use only token-defined `--shadow-popover` / `--shadow-palette`.

- RDS-R-8: **Layout-Only Caller `className`**. Visual values live exclusively in design tokens. Caller `className` props on design-system components are restricted to layout placement (margin, width, flex/grid alignment, sticky positioning, responsive visibility) — never override colors, padding, radii, or shadows inline.

## Sources

> Checked 2026-11-26.

| Claim | Source |
|---|---|
| `@theme static` resets, no arbitrary `box-shadow`, `LiquidGlass` / `Veil` glass layers, layout-only `className` | `../references/horon-and-glass-patterns.md`, <https://github.com/horon-ai/design> |
| 4-stage reference deconstruction and no-card / no-shadow adaptation from `21st.dev` | `../references/landing-21st-dev-patterns.md`, <https://21st.dev/> |
