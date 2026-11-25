# Horon Design System & Expo Glass Effect Architecture

## Contents

- [1. Token Authority & `@theme static` Compiler Locking](#1-token-authority--theme-static-compiler-locking)
- [2. 13-Style Typography & Platform Modes](#2-13-style-typography--platform-modes)
- [3. Base UI v1 (`useRender`, `Drawer` BottomSheet, `Tabs.Indicator`)](#3-base-ui-v1-userender-drawer-bottomsheet-tabsindicator)
- [4. LiquidGlass, Veil & `.touch-slop` Material Specification (Web)](#4-liquidglass-veil--touch-slop-material-specification-web)
- [5. Expo Glass Effect (`expo-glass-effect`) Native Parity](#5-expo-glass-effect-expo-glass-effect-native-parity)
- [6. Motion Utilities, Disclosure (`motion-reveal`/`motion-swap`) & Reduced Motion](#6-motion-utilities-disclosure-motion-revealmotion-swap--reduced-motion)
- [Sources](#sources)

## 1. Token Authority & `@theme static` Compiler Locking

Distilled from `https://github.com/horon-ai/design`:

1. **Single Source of Truth**: Define raw and semantic values (`color.ts`, `typography.ts`, `scale.ts`, `glass.ts`, `motion.ts`) in `src/design-system/tokens/`.
2. **Compiler-Locked `theme.css`**: Emit `theme.css` from token TypeScript sources inside `@theme static { ... }`, starting with `--color-*: initial; --radius-*: initial; --text-*: initial; --font-*: initial; --font-weight-*: initial; --shadow-*: initial;`. Resetting `--shadow-*: initial` ensures rogue `shadow-md`/`shadow-xl` utilities cannot even emit CSS.
3. **Platform & Dark Overrides**: Emit `[data-platform="desktop"]` and `[data-platform="mobile"]` type variable blocks plus `.dark { color-scheme: dark; ... }` overrides.
4. **Radius Watch-Out**: In Horon's scale, `xs: 6px`, `sm: 8px`, `md: 12px`, `lg: 14px`, `xl: 20px`, `2xl: 16px`, `full: 9999px` (pick by pixel value, not label). Use `rounded-full` for pill controls, `rounded-md` for inputs/menu rows, and `rounded-xl` for dialogs/popovers only.
5. **Shadow Rule**: Never apply shadows to inline blocks. Reserve `--shadow-popover` (`0 8px 24px 0 rgba(10, 13, 15, 0.1)`) and `--shadow-palette` (`0 16px 40px 0 rgba(10, 13, 15, 0.12)`) exclusively for detached opaque overlays, or use `LiquidGlass`/`Veil` instead.

## 2. 13-Style Typography & Platform Modes

- **Fonts**: `Pretendard Variable` (`--font-sans`) + `Geist Mono Variable` (`--font-mono`).
- **Four Weights Only**: `400` (regular), `500` (medium), `600` (semibold), `700` (bold). No Thin (100–200) or Light (300).
- **Korean Wrapping**: Apply `word-break: keep-all` on Korean body text so words do not split mid-syllable.
- **13 Canonical Styles (`size / lineHeight` in px across Web / Desktop / Mobile)**:
  - `display-lg` (700, -0.03em): `56/68` (web), `48/58` (desktop), `36/44` (mobile)
  - `display-md` (700, -0.025em): `44/52`, `40/48`, `30/36`
  - `title-lg` (600, -0.02em): `32/40`, `28/36`, `24/32`
  - `title-md` (600, -0.015em): `24/32`, `22/28`, `20/28`
  - `title-sm` (600, -0.01em): `20/28`, `18/26`, `18/26`
  - `body-lg` (400, -0.008em, 0.75em paragraph gap): `18/30`, `16/26`, `17/28`
  - `body-md` (400, -0.005em, 0.75em paragraph gap): `16/26`, `14/22`, `16/26`
  - `body-sm` (400, -0.002em, 0.75em paragraph gap): `14/22`, `13/20`, `14/22`
  - `label-lg` (500, -0.005em): `16/22`, `14/20`, `16/22`
  - `label-md` (500, -0.003em): `14/20`, `13/18`, `14/20`
  - `label-sm` (500, 0em): `12/16`, `11/16`, `12/16`
  - `caption` (400, 0.005em): `12/18`, `11/18`, `12/18`
  - `code` (mono 400, 0em): `14/22`, `13/20`, `13/20`

## 3. Base UI v1 (`useRender`, `Drawer` BottomSheet, `Tabs.Indicator`)

- **Polymorphic Custom Primitives (`useRender` + `mergeProps`)**:

```tsx
import { mergeProps, useRender } from "@base-ui/react/utils";
import { forwardRef, type ForwardedRef } from "react";

export interface ActionRowProps extends useRender.ComponentProps<"button"> {
  active?: boolean;
}

export const ActionRow = forwardRef(function ActionRow(
  { render, active, className, ...props }: ActionRowProps,
  ref: ForwardedRef<HTMLButtonElement>,
) {
  return useRender({
    defaultTagName: "button",
    render,
    ref,
    props: mergeProps<"button">(
      { className: `motion-colors ${className ?? ""}`, "data-active": active || undefined },
      props,
    ),
  });
});
```

- **Responsive `Drawer` BottomSheet (`@base-ui/react/drawer`)**: Dock flush to bottom on `< 560px` viewports and center at `maxWidth: 560` on wider screens; apply `pb-[calc(1.5rem+env(safe-area-inset-bottom))]` and `overscroll-contain` inside `Drawer.Content` plus a top drag grabber.
- **Sliding Indicators (`Tabs.Indicator` & `useActiveIndicator`)**: For custom non-Base-UI tracks, measure `[aria-current="page"]` / `[data-pressed]` via `ResizeObserver` + `MutationObserver` in `useLayoutEffect`, and enable `motion-indicator` 1 frame later via `requestAnimationFrame` so the indicator lands cleanly instead of flying in from `(0, 0)`.

## 4. LiquidGlass, Veil & `.touch-slop` Material Specification (Web)

- **Glass Parameters (`glass.ts`)**: `blur: 20`, `saturate: 1.8`, `rimWidth: 1`, `rimMidStop: 0.5`.
  - Tiers belong on the host fill (`bg-glass-clear`, `bg-glass-regular`, `bg-glass-thick`), while `<LiquidGlass />` renders `<span aria-hidden className="liquid-layers" />` as the first child of a `relative isolate overflow-clip` host.
  - Longhand CSS mask (`mask-image`, `mask-clip`, `mask-composite: exclude`, `-webkit-mask-composite: xor`) draws the 1px vertical gradient rim so minifiers never drop `exclude`.
  - Fallback: under `@media (prefers-reduced-transparency: reduce)` or `@supports not (backdrop-filter: blur(1px))`, swap background to `var(--color-glass-fill-frost)`.
- **Veil Parameters (`veil`)**: `blur: 8`, `saturate: 1.6`, `ringWidth: 1` for `.veil-field` and `.veil-overlay`.
- **Coarse Touch Reach (`.touch-slop`) & iOS Input Floor**:
  - Unlayered `@media (pointer: coarse) { input, textarea, select { font-size: max(16px, 1em); } }` stops iOS Safari auto-zoom on focus.
  - `.touch-slop` expands a compact control's hit target to `44×44px` via `::after` under `@media (pointer: coarse)`. Never apply `.touch-slop` to an element that already owns `::after` or has `position: fixed` / `absolute`.

## 5. Expo Glass Effect (`expo-glass-effect`) Native Parity

From `https://docs.expo.dev/versions/latest/sdk/glass-effect/` and `horon-ai/design` `@horon-ai/expo`:

```tsx
import { StyleSheet, View, type StyleProp, type ViewStyle } from "react-native";
import { GlassView, isGlassEffectAPIAvailable, isLiquidGlassAvailable } from "expo-glass-effect";

export function canUseNativeLiquidGlass(reduceTransparency: boolean): boolean {
  try {
    return !reduceTransparency && isLiquidGlassAvailable() && isGlassEffectAPIAvailable();
  } catch {
    return false;
  }
}

// Inside GlassSurface (iOS 26+ native branch):
// Never put opacity < 1 or opacity: 0 on GlassView itself; fade only the background wrapper
// to native fillOpacity (0.75 light / 0.92 dark) while children remain crisp above it.
export function NativeGlassBackdrop({
  scheme,
  tintColor,
  interactive,
  radius,
}: {
  scheme: "light" | "dark";
  tintColor?: string;
  interactive?: boolean;
  radius: number;
}) {
  const fillOpacity = scheme === "dark" ? 0.92 : 0.75;
  const shape: ViewStyle = radius ? { borderRadius: radius, borderCurve: "continuous" } : { borderCurve: "continuous" };
  return (
    <View pointerEvents="box-none" style={[StyleSheet.absoluteFill, { opacity: fillOpacity }]}>
      <GlassView
        glassEffectStyle="regular"
        tintColor={tintColor}
        colorScheme={scheme}
        isInteractive={interactive}
        style={[StyleSheet.absoluteFill, shape]}
      />
    </View>
  );
}
```

- **Platform Rules**: Works natively on **iOS 26+** and tvOS; falls back to `glass-fill-frost` + 1px token rim (plus `overlay-ink-8` wash when `pressed`) on Android, iOS < 26, or Reduce Transparency.
- **`GlassContainer`**: Accepts `spacing?: number` to blend multiple nearby `GlassView` siblings.
- **CRITICAL GOTCHA**: Never set `opacity: 0` on `GlassView` or any parent container — it breaks native `UIVisualEffectView` rendering. Use `glassEffectStyle={{ style: "regular", animate: true, animationDuration: 0.2 }}` or scale/translate animations instead.

## 6. Motion Utilities, Disclosure (`motion-reveal`/`motion-swap`) & Reduced Motion

- **3 Canonical Easings**: `--ease-out-quint: cubic-bezier(0.22, 1, 0.36, 1)`, `--ease-emphasized: cubic-bezier(0.2, 0, 0, 1)`, `--ease-spring: cubic-bezier(0.34, 1.3, 0.64, 1)`.
- **Utilities** (`assets/templates/glass-and-motion.css`): `motion-colors` (150ms), `motion-press` (150ms `scale(0.97)`), `motion-popup` (200ms in / 130ms out), `motion-fade` (200ms), `motion-collapse` (`--collapsible-panel-height` 240ms), `motion-reveal` (`grid-template-rows: 1fr <-> 0fr` with `inert` when collapsed), `motion-swap` (single grid-area `"swap"` zero-CLS icon/label crossfade), and `motion-indicator` (280ms).
- **Reduced Motion**: Under `@media (prefers-reduced-motion: reduce)`, collapse durations to `0.01ms !important`, limit iteration count to `1 !important`, and set `scroll-behavior: auto !important`.

## Sources

> Checked 2026-11-26.

| Claim | Source |
|---|---|
| Horon `@theme static` generator, `globals.css`, `tabs.tsx`, `bottom-sheet.tsx`, `use-active-indicator.ts`, and `@horon-ai/expo` `glass-surface.tsx` | <https://github.com/horon-ai/design> |
| Base UI v1 `useRender`, `mergeProps`, and `data-starting-style` / `data-ending-style` | <https://base-ui.com/react/utils/use-render> |
| `expo-glass-effect` components, runtime checks (`isGlassEffectAPIAvailable`, `isLiquidGlassAvailable`), and `opacity: 0` constraint | <https://docs.expo.dev/versions/latest/sdk/glass-effect/> |
