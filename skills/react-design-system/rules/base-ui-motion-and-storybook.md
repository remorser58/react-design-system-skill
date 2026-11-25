# React-Only Base UI, Isolated Motion, Glass, and Storybook Rules

**Purpose**: Enforce React-only implementation on Base UI v1 headless primitives (`useRender`, `Drawer`, `Tabs.Indicator`), isolate motion in a dedicated layer with strict animation budgets, handle Web/Expo Glass safely, and require interactive Storybook + a11y coverage.

## 1. React-Only & Base UI v1 Headless Primitives

- RDS-C-1: **React Only**. Author all design system primitives, patterns, and app UI exclusively in **React 19 + TypeScript** (paired with **Vite** for web, or React Native **Expo** when cross-platform mobile is explicitly in scope). Never introduce Vue, Svelte, Angular, Astro-only islands, jQuery, `@radix-ui/*`, shadcn/ui copies, MUI, AntD, or Chakra.

- RDS-C-2: **Base UI (`@base-ui/react`) as the Single Headless Foundation**. Build every interactive primitive (`Button`, `Dialog`, `BottomSheet` via `@base-ui/react/drawer`, `Menu`, `Select`, `Combobox`, `Tabs`, `Popover`, `Tooltip`, `Switch`, `Checkbox`, `RadioGroup`, `Slider`, `Accordion`, `Collapsible`, `Toast`, `Meter`, `Field`) directly over `@base-ui/react/*`:
  - Use Base UI's `render` prop for composition and `useRender` + `mergeProps` (`@base-ui/react/utils`) for custom polymorphic wrappers so refs, event handlers, and `data-starting-style` / `data-ending-style` / `data-open` / `data-invalid` attributes never drop.
  - Pair centered `Dialog` on desktop with `@base-ui/react/drawer` `BottomSheet` on mobile (`env(safe-area-inset-bottom)` padding + `overscroll-contain` + grabber drag dismissal).
  - Export flat prop types (`Omit<ComponentProps<typeof BasePrimitive>, "className"> & { className?: string }`) and merge with `cn()`.

## 2. Dedicated Motion Layer & Animation Budgets

- RDS-C-3: **Separate Motion Architecture**. Never scatter raw `cubic-bezier(...)` numbers, spring configs, or ad-hoc keyframe names inside feature components. Isolate all motion in `src/design-system/motion/`:
  - **CSS Micro-Interaction & Structural Utilities (`motion.css`)**: Define 3 canonical easings (`--ease-out-quint`, `--ease-emphasized`, `--ease-spring`) and semantic utilities: `motion-colors` (150ms), `motion-press` (150ms `scale(0.97)`), `motion-popup` (200ms in / 130ms out on `data-starting-style`/`data-ending-style`), `motion-fade` (200ms), `motion-collapse` (`--collapsible-panel-height` 240ms), `motion-reveal` / `motion-reveal-x` (`0fr <-> 1fr` with `inert` on collapsed descendants), `motion-swap` (CSS Grid `"swap"` area zero-CLS crossfade), and `motion-indicator` (280ms sliding tabs/segmented controls; enable `animate` 1 frame after mount via `requestAnimationFrame` so indicators never fly from `0,0`).
  - **Choreographed React Motion (`motion/react`)**: Wrap app and Storybook roots in `<MotionConfig reducedMotion="user">` and export reusable primitives (`FadeRise`, `StaggerGroup`, `SharedTabIndicator`, `ScrollReveal`, `HeroHeadlineReveal`) from `src/design-system/motion/primitives.tsx`.

- RDS-C-4: **Motion Budget & GPU-Only Discipline**: Animate only `transform`, `opacity`, and `clip-path` (plus `grid-template-rows`/`--collapsible-panel-height` in dedicated disclosure utilities). Keep feedback at 120–150ms, popups/panels at 180–240ms, sliding indicators at ~280ms, total hero stagger <= 450ms, and <= 3 simultaneous moving groups. Under `@media (prefers-reduced-motion: reduce)`, collapse transitions/animations to `0.01ms` and stop infinite loops.

## 3. Cross-Platform Glass Parity (`LiquidGlass` & `expo-glass-effect`)

- RDS-C-5: **Web `LiquidGlass` + Expo `expo-glass-effect` Rules**:
  - On **React Web**, render `<LiquidGlass />` as the first `aria-hidden` child of a `relative isolate overflow-clip` host using `backdrop-filter: blur(20px) saturate(1.8)` and a 1px masked vertical rim (`mask-image`/`mask-clip`/`mask-composite: exclude` and `-webkit-mask-composite: xor` in longhand CSS so minifiers never drop `exclude`).
  - On **React Native / Expo**, use `expo-glass-effect` (`GlassView`, `GlassContainer`) ONLY after checking both `isLiquidGlassAvailable()` AND `isGlassEffectAPIAvailable()`, plus `!AccessibilityInfo.isReduceTransparencyEnabled()`. Apply `glass.native[scheme].fillOpacity` (`0.75` light / `0.92` dark) on an absolute background wrapper behind children (`pointerEvents="box-none"`), never fading children, and fall back to `glass-fill-frost` + token rim on Android, iOS < 26, or reduced transparency.
  - **Critical `expo-glass-effect` Pitfall**: Never apply `opacity: 0` directly to `GlassView` or any ancestor container — it breaks native `UIVisualEffectView` rendering. Animate via `glassEffectStyle={{ style: "regular", animate: true, animationDuration: 0.2 }}` or transform scale/translation instead.

## 4. Mandatory Storybook Catalog (`@storybook/react-vite`)

- RDS-C-6: **Storybook Coverage & Play/A11y Gates**. Every design-system primitive and pattern must ship with a `*.stories.tsx` file using `assets/templates/storybook-preview.tsx`:
  - `@storybook/addon-a11y` enabled with `test: "error"` (zero critical/serious violations)
  - Global **Light / Dark theme** and **`data-platform` (`web`/`desktop`/`mobile`)** toolbar toggles plus Mobile (`320px`/`375px`), Tablet (`768px`/`1024px`), Desktop (`1280px`/`1440px`) viewports
  - Explicit stories covering `Default`, `Variants & Sizes`, `Interactive States` (`hover`, `focus-visible`, `disabled`, `error`), `Skeleton / Loading`, `Long / Empty Stress Content`, and `play` interaction checks (`storybook/test`) on interactive controls (Dialog, Menu, Tabs, Select, Form validation).

- RDS-C-7: **Zero Hidden Site-Only Controls**. Do not build undocumented one-off UI controls inside app feature folders; promote reusable controls into `src/design-system/` and document them in Storybook first.

- RDS-C-8: **Touch-Safe Coarse Floor**. Always include unlayered `@media (pointer: coarse) { input, textarea, select { font-size: max(16px, 1em); } }` in global design-system CSS so iOS Safari never auto-zooms on focus.

## Sources

> Checked 2026-11-26.

| Claim | Source |
|---|---|
| Base UI wrapping, `LiquidGlass`, `motion-collapse`/`motion-reveal`/`motion-swap`, `useActiveIndicator`, `BottomSheet`, coarse 16px floor | `../references/horon-and-glass-patterns.md`, <https://github.com/horon-ai/design> |
| Base UI v1 `useRender`, `mergeProps`, `data-starting-style` / `data-ending-style` | <https://base-ui.com/react/utils/use-render> |
| `expo-glass-effect` `GlassView`, `GlassContainer`, runtime checks, and `opacity: 0` warning | `../references/horon-and-glass-patterns.md`, <https://docs.expo.dev/versions/latest/sdk/glass-effect/> |
| Storybook React + Vite + `addon-a11y` + play-function catalog blueprint | `../references/react-vite-stack-blueprint.md` |
