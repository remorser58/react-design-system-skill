# Landing / Intro Page Patterns (`21st.dev`) & 4-Stage Visual Reference Mining

## Contents

- [1. Cross-Platform Reference Mining Matrix](#1-cross-platform-reference-mining-matrix)
- [2. Quantitative Reference Extraction Sheet (Stage 2)](#2-quantitative-reference-extraction-sheet-stage-2)
- [3. `21st.dev` Landing & Intro Archetypes + Shader Guardrails](#3-21stdev-landing--intro-archetypes--shader-guardrails)
- [4. Concrete Before -> After No-Card / No-Shadow Refactor Recipes](#4-concrete-before---after-no-card--no-shadow-refactor-recipes)
- [5. Dedicated Motion Choreography for Landing Pages](#5-dedicated-motion-choreography-for-landing-pages)
- [Sources](#sources)

## 1. Cross-Platform Reference Mining Matrix

Combine 2 UX/IA refs (Mobbin/UIBowl) + 1 Token/System ref (Figma/`horon-ai/design`) + 1–2 Craft refs (Dribbble/Behance/Pinterest) + `21st.dev` for landing/intro:

| Source | What to Mine | How to Translate to React + Base UI | What Never to Copy |
|---|---|---|---|
| **Mobbin** | Production mobile/web flows, onboarding sequences, navigation bars, bottom sheets, empty/error states | Map screen IA -> `@tanstack/react-router` route tree + Base UI `BottomSheet` / `Dialog` / `Tabs` | Brand colors, proprietary mascots, boxed iOS table cells with heavy shadows |
| **UIBowl** | Korean mobile product patterns, fintech/commerce density, filter bars, action rows | Adopt concise Korean microcopy rhythm, `keep-all` wrapping, sticky 44px touch action bars | Stacked card borders around every list item |
| **Figma** | Design token collections (Color, Scale, Type, Glass), auto-layout spacing, component variant props | Export directly into `src/design-system/tokens/*.ts` + `@theme static` | Hardcoded pixel frames (`390px` fixed width) without responsive fluid bounds |
| **Dribbble** | Display typography contrast, editorial asymmetry, subtle tonal canvas shifts | Replicate headline-to-body scale ratios and open negative space | Unreadable ultra-thin weights (<400) or non-responsive fixed artboards |
| **Behance** | Storytelling cadence, chapter transitions, case-study visual pacing | Structure intro pages into alternating full-bleed / editorial grid chapters | Heavy scroll-jacking that breaks native scrolling or `prefers-reduced-motion` |
| **Pinterest** | Color mood boards, grid proportions, editorial composition | Translate into clean 12-column CSS Grid separated by 1px hairlines | Decorative drop shadows and cluttered card-inside-card nesting |
| **21st.dev** | Hero sections, animated text reveals, shader/aurora backdrops, interactive feature tabs, pricing toggles, FAQ | Port to React + Vite + `@base-ui/react` + isolated `motion/react` + flat/glass surfaces | Next.js-only `next/link` / `next/image`, `@radix-ui/*` / shadcn wrappers, `shadow-lg` cards |

## 2. Quantitative Reference Extraction Sheet (Stage 2)

Fill this concrete sheet before authoring tokens or JSX:

| Dimension | Extracted Value (Example) | Target Token / CSS Mapping |
|---|---|---|
| Type Scale Ratio (`display-lg / body-md`) | `56 / 16 = 3.5x` (Mobile `36 / 16 = 2.25x`) | `--text-display-lg`, `--text-body-md` |
| Prose Line Measure | `62ch` max | `max-w-[62ch]` |
| Spacing Rhythm | `4px` base; `48px–96px` section gaps | `gap-6`, `py-16 md:py-24` |
| Surface Separation | `1px` hairline + `bg-bg-subtle` (`#f3f4f5` vs `#ffffff`) | `border-border-default`, `divide-y` |
| Motion Timing Band | `150ms` press, `200ms` popup, `<= 450ms` hero stagger | `motion-press`, `HeroHeadlineReveal` |
| Coarse Touch Height | `>= 44px` | `pointer-coarse:h-11` / `.touch-slop` |

## 3. `21st.dev` Landing & Intro Archetypes + Shader Guardrails

Analysis of `https://21st.dev/` (`hero`, `animated-hero`, `features`, `pricing-section`, `templates`, `shaders`):

1. **Text-Forward Editorial Hero**: Compact announcement pill (glass or 1px hairline border) -> high-contrast `display-lg` (`-0.03em`) -> 1–2 line `body-lg` lead -> primary CTA + `glass`/`link` secondary CTA -> logo strip.
2. **Split Copy + Live Interactive Product Stage**: Left (`lg:col-span-5`) eyebrow, value prop, 2 CTAs, 3 `tabular-nums` proof metrics; right (`lg:col-span-7`) live React interactive preview framed only by a 1px hairline or `LiquidGlass` frame.
3. **Full-Bleed Ambient / Shader Hero Guardrails**:
   - Cap WebGL/Canvas devicePixelRatio at `Math.min(window.devicePixelRatio, 1.5)`.
   - Pause animation loop when offscreen via `IntersectionObserver`.
   - Render a static high-contrast frame when `prefers-reduced-motion: reduce` is active, and ensure `>= 4.5:1` text contrast over any animated backdrop.
4. **Canonical Section Cadence**: Sticky `LiquidGlass` top bar (`pt-safe`) -> Hero -> Client Strip -> Tabbed Interactive Features (`@base-ui/react/tabs`) -> Hairline Metrics / Comparison Table (`@tanstack/react-table` or CSS Grid) -> Pricing Columns with Monthly/Annual Toggle (`@base-ui/react/switch`) -> Testimonials Strip -> FAQ (`@base-ui/react/accordion`) -> Final CTA -> Static Footer (`pb-safe`).

## 4. Concrete Before -> After No-Card / No-Shadow Refactor Recipes

### A. Feature Grid (Boxed Cards -> 1px Hairline Matrix)
```tsx
{/* BEFORE (Forbidden): <div className="grid gap-6 md:grid-cols-3">{items.map(i => <Card className="p-6 shadow-md">...</Card>)}</div> */}
{/* AFTER: 1px hairline matrix with zero cards and zero box-shadow */}
<div className="grid grid-cols-1 border-t border-l border-border-default md:grid-cols-3">
  {items.map((item) => (
    <div key={item.id} className="border-r border-b border-border-default p-6 md:p-8">
      <h3 className="text-title-sm text-text-primary">{item.title}</h3>
      <p className="mt-2 text-body-sm text-text-secondary">{item.description}</p>
    </div>
  ))}
</div>
```

### B. Pricing Tiers (Lifted Shadow Card -> Flat Hairline Columns + Tonal Highlight)
```tsx
{/* BEFORE (Forbidden): <Card className="shadow-xl scale-105 border-2">...</Card> */}
{/* AFTER: Flat vertical hairline separation + subtle tonal shift on featured tier */}
<div className="grid grid-cols-1 divide-y divide-border-default border-y border-border-default md:grid-cols-3 md:divide-x md:divide-y-0">
  {plans.map((plan) => (
    <div
      key={plan.id}
      className={cn(
        "flex flex-col justify-between p-6 md:p-8",
        plan.featured ? "border-t-2 border-t-text-brand bg-bg-subtle" : "bg-bg-default",
      )}
    >
      <div>
        <span className="text-label-sm text-text-secondary">{plan.name}</span>
        <div className="mt-3 text-display-md tabular-nums text-text-primary">{plan.price}</div>
      </div>
      <Button variant={plan.featured ? "primary" : "solid"} className="mt-8 w-full">
        {plan.cta}
      </Button>
    </div>
  ))}
</div>
```

### C. Vite Cleanup Checklist
Strip `"use client"`, `@radix-ui/*`, `next/image`, `next/link`, and `next-themes`. Use standard `<img>` (`loading="lazy"`, explicit `width`/`height`, `alt`), `@tanstack/react-router` `<Link>`, and your token theme hook.

## 5. Dedicated Motion Choreography for Landing Pages

Keep all landing animations inside `src/design-system/motion/primitives.tsx` (`<MotionConfig reducedMotion="user">`):
- `HeroHeadlineReveal`: masked `y: 16 -> 0`, `opacity: 0 -> 1` with `--ease-out-quint` (`[0.22, 1, 0.36, 1]`), `once: true`.
- `StaggerGroup`: 50–70ms stagger (`<= 450ms` total reveal delay).
- `SharedTabIndicator`: Base UI `Tabs.Indicator` with CSS `motion-indicator` (280ms `--ease-emphasized`).
- `ScrollReveal`: `viewport={{ once: true, amount: 0.2 }}` using only `opacity` and `transform`.

## Sources

> Checked 2026-11-26.

| Claim | Source |
|---|---|
| `21st.dev` hero, animated-hero, features, pricing-section, shader, and template patterns | <https://21st.dev/> |
| No-card / no-shadow Base UI adaptation, `LiquidGlass`, and `@theme static` integration | `../references/horon-and-glass-patterns.md`, <https://github.com/horon-ai/design> |
