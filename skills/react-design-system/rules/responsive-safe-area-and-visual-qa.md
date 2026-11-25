# Responsive Layout, Safe Area, Mobile Metadata, OpenGraph, and Visual QA Rules

**Purpose**: Ensure every React + Vite app handles mobile Safe Areas, static and per-route OpenGraph metadata, Desktop/Tablet/Mobile responsiveness, `.touch-slop` ergonomics, and automated Visual QA probe checks without regressions.

## 1. Safe Area & Mobile Viewport Setup (Audit & Auto-Fix)

- RDS-V-1: **Audit First, Fix Immediately**. Whenever inspecting an existing project or scaffolding a new one, check `index.html` and root CSS for Safe Area coverage. If any piece is missing, implement it before finishing:
  - `index.html` must include `<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />`. Never add `maximum-scale=1` or `user-scalable=no` (accessibility violation).
  - Define Safe Area CSS utilities/variables (`env(safe-area-inset-top)`, `env(safe-area-inset-right)`, `env(safe-area-inset-bottom)`, `env(safe-area-inset-left)`) and apply them to fixed/sticky top bars, bottom navigation bars, floating action bars, bottom sheets, and toast containers.
  - Use dynamic viewport units (`min-h-dvh`, `100dvh`, `max-h-[calc(100dvh-2rem)]`) instead of raw `100vh` so mobile browser address bars never clip bottom controls.
  - When React Native / Expo is present alongside web, wrap the app root in `SafeAreaProvider` and consume `useSafeAreaInsets()` from `react-native-safe-area-context`.

## 2. Mobile Head, Theme Color, and Static + Dynamic OpenGraph

- RDS-V-2: **Static `index.html` Fallback Head**. Start from `assets/templates/index.html` to configure:
  - Light & dark `<meta name="theme-color">` matching `--color-bg-default` (`media="(prefers-color-scheme: light)"` and `media="(prefers-color-scheme: dark)"`), plus an inline pre-paint theme script to prevent FOUC.
  - Mobile web app tags (`apple-mobile-web-app-capable`, `apple-mobile-web-app-status-bar-style`, `format-detection`), canonical `<link rel="canonical">`, favicon SVG/ICO, `apple-touch-icon` (180×180), and web manifest.
  - Complete **OpenGraph** tags (`og:type`, `og:url`, `og:title`, `og:description`, `og:image` at 1200×630, `og:image:width`, `og:image:height`, `og:image:alt`, `og:site_name`, `og:locale`) and **Twitter Card** tags (`twitter:card="summary_large_image"`, `twitter:title`, `twitter:description`, `twitter:image`).

- RDS-V-3: **Per-Route Dynamic OpenGraph via TanStack Router `head()`**. For detail/landing routes, define route `head({ loaderData })` returning dynamic `meta` (`title`, `description`, `og:title`, `og:description`, `og:url`, `og:image`, `twitter:*`) and canonical `links`, and mount `<HeadContent />` in `__root.tsx` so client navigation and SSR/prerendering stay synchronized.

## 3. Desktop, Tablet, Mobile Responsive & `.touch-slop` Ergonomics

- RDS-V-4: **Mobile-First Breakpoint Matrix**:
  - **Mobile (`320px–767px`, test at `320×568` & `375×812`)**: Single-column flow, collapsible drawer or `@base-ui/react/drawer` `BottomSheet`, horizontal scroll confined to wide tables/code blocks (`overflow-x-auto`) — zero page-level horizontal overflow.
  - **Tablet (`768px–1023px`, test at `768×1024` & `1024×768`)**: Two-column adaptive grids, top section nav visible, touch-friendly spacing without desktop sidebar crowding.
  - **Desktop (`1024px+`, test at `1280×800` & `1440×900`)**: Persistent 240px sidebar (`lg`), sticky 200px table of contents or inspector (`xl`), `max-w-225`–`max-w-7xl` readable container bounds.

- RDS-V-5: **Coarse Touch Targets & `.touch-slop` Pitfall Rule**. On `pointer: coarse`, every interactive control must expose at least a `44×44px` hit target (`pointer-coarse:h-11` for text controls, `.touch-slop` `::after` pseudo-element for compact switches, checkboxes, radios, and calendar arrows whose visual size stays fixed). **Pitfall**: Never put `.touch-slop` on elements that already use `::after` (e.g., toast close or underlined rows) or on `position: fixed`/`absolute` nodes — attach a dedicated hit wrapper instead. Preserve `32px / 40px / 48px` density on `pointer: fine`, and verify `320px` / `200%` zoom reflow.

## 4. Automated Visual QA Protocol

- RDS-V-6: **Multi-Viewport & Multi-State Capture Matrix**. Before claiming UI completion, run Visual QA across:
  - **Devices**: Mobile (`320×568` overflow check + `375×812`), Tablet (`768×1024` + `1024×768`), Desktop (`1280×800` + `1440×900`)
  - **Themes**: Light mode and Dark mode
  - **States**: Initial Skeleton loading, Loaded real content, Long/unbroken string stress (`keep-all` / `truncate`), Empty state, Validation/API Error state, `focus-visible` keyboard ring, and Open overlay (Dialog/Menu/BottomSheet)

- RDS-V-7: **Automated DOM Probe Verification**. Inside the live browser session on each viewport and theme, execute `assets/templates/visual-qa-probe.js` and require `ok: true` (`horizontalOverflow: false`, `viewportFitCover: true`, `zoomLockViolation: false`, `coarseTouchTargetFailures: []`, `coarseInputFontFailures: []`, `nonOverlayShadowHits: []`, `missingAltImages: []`, `unnamedButtons: []`) alongside WCAG 2.2 AA contrast (`>= 4.5:1` text, `>= 3:1` UI) and zero console/page errors.

- RDS-V-8: **Honest Degradation**. If no live browser tool is available in the session, run `scripts/audit-react-ds.sh --strict --json` and `vite build`, and explicitly mark rendered browser & probe checks as `not_verified` rather than guessing.

## Sources

> Checked 2026-11-26.

| Claim | Source |
|---|---|
| Responsive breakpoints, `pointer: coarse` 44px `.touch-slop` rule and `::after` caveat, 200% zoom, theme init | `../references/horon-and-glass-patterns.md`, <https://github.com/horon-ai/design> |
| TanStack Router `head()` dynamic meta/OpenGraph + `<HeadContent />` | <https://tanstack.com/router/latest/docs/framework/react/guide/document-head-management> |
| `index.html` Safe Area, OpenGraph, and `visual-qa-probe.js` checklist | `../references/react-vite-stack-blueprint.md`, `../assets/templates/visual-qa-probe.js` |
