# React 전용 Base UI, 독립 Motion, Glass 및 Storybook 규칙

**목적**: Base UI v1 headless 프리미티브(`useRender`, `Drawer`, `Tabs.Indicator`) 기반의 React 전용 구현, 엄격한 애니메이션 예산을 갖춘 독립 Motion 레이어, 웹/Expo Glass 안전 처리, 인터랙티브 Storybook + a11y 커버리지를 강제합니다.

## 1. React 전용 및 Base UI v1 Headless 프리미티브

- RDS-C-1: **React 전용(React Only)**. 모든 디자인 시스템 프리미티브, 패턴, 앱 UI는 오직 **React 19 + TypeScript**(웹은 **Vite**, 크로스 플랫폼 모바일 병행 시 React Native **Expo**)로만 작성합니다. Vue, Svelte, Angular, Astro 전용 아일랜드, jQuery, `@radix-ui/*`, shadcn/ui 복제본, MUI, AntD, Chakra를 혼용하지 않습니다.

- RDS-C-2: **유일한 Headless 기반으로서의 Base UI (`@base-ui/react`)**. 모든 인터랙티브 프리미티브(`Button`, `Dialog`, `@base-ui/react/drawer` 기반 `BottomSheet`, `Menu`, `Select`, `Combobox`, `Tabs`, `Popover`, `Tooltip`, `Switch`, `Checkbox`, `RadioGroup`, `Slider`, `Accordion`, `Collapsible`, `Toast`, `Meter`, `Field`)는 `@base-ui/react/*` 위에 직접 구축합니다:
  - 합성에는 Base UI `render` prop을, 다형성 커스텀 래퍼에는 `useRender` + `mergeProps`(`@base-ui/react/utils`)를 사용해 ref, 이벤트 핸들러, `data-starting-style` / `data-ending-style` / `data-open` / `data-invalid` 속성이 유실되지 않게 합니다.
  - 데스크톱 중앙 `Dialog`와 모바일 `@base-ui/react/drawer` `BottomSheet`(`env(safe-area-inset-bottom)` 패딩 + `overscroll-contain` + 그래버 드래그 닫기)를 짝지어 제공합니다.
  - 평탄한 prop 타입(`Omit<ComponentProps<typeof BasePrimitive>, "className"> & { className?: string }`)을 내보내고 `cn()`으로 병합합니다.

## 2. 분리된 Motion 레이어 및 애니메이션 예산

- RDS-C-3: **Motion 아키텍처 분리**. 피처 컴포넌트 내부에 `cubic-bezier(...)` 숫자, 스프링 설정, 임의 키프레임을 흩뿌리지 않고 모든 모션을 `src/design-system/motion/`에 격리합니다:
  - **CSS 마이크로 인터랙션·구조 유틸리티 (`motion.css`)**: 3종 표준 이징(`--ease-out-quint`, `--ease-emphasized`, `--ease-spring`)과 시맨틱 유틸리티(`motion-colors` 150ms, `motion-press` 150ms `scale(0.97)`, `motion-popup` `data-starting-style`/`data-ending-style` 200ms in / 130ms out, `motion-fade` 200ms, `motion-collapse` `--collapsible-panel-height` 240ms, 접힌 하위 요소 `inert`를 동반하는 `motion-reveal`/`motion-reveal-x` `0fr <-> 1fr`, CSS Grid `"swap"` 영역 무-CLS 크로스페이드 `motion-swap`, `motion-indicator` 280ms 슬라이딩 표시기 — `0,0`에서 날아오지 않도록 `requestAnimationFrame` 1프레임 후 `animate` 활성화)를 정의합니다.
  - **연출형 React 모션 (`motion/react`)**: 앱과 Storybook 루트를 `<MotionConfig reducedMotion="user">`로 감싸고 재사용 프리미티브(`FadeRise`, `StaggerGroup`, `SharedTabIndicator`, `ScrollReveal`, `HeroHeadlineReveal`)를 `src/design-system/motion/primitives.tsx`에서 내보냅니다.

- RDS-C-4: **모션 예산 및 GPU 전용 규율**: `transform`, `opacity`, `clip-path`(및 전용 디스클로저 유틸의 `grid-template-rows`/`--collapsible-panel-height`)만 애니메이션합니다. 피드백 120~150ms, 팝업·패널 180~240ms, 슬라이딩 인디케이터 ~280ms, 히어로 총 스태거 `<= 450ms`, 동시 이동 그룹 `<= 3개`를 지킵니다. `@media (prefers-reduced-motion: reduce)`에서는 모든 전환/애니메이션을 `0.01ms`로 축소하고 무한 반복을 중단합니다.

## 3. 크로스 플랫폼 Glass 패리티 (`LiquidGlass` & `expo-glass-effect`)

- RDS-C-5: **React 웹 `LiquidGlass` + Expo `expo-glass-effect` 규칙**:
  - **React 웹**에서는 `relative isolate overflow-clip` 호스트의 첫 번째 `aria-hidden` 자식으로 `<LiquidGlass />`를 렌더링하며 `backdrop-filter: blur(20px) saturate(1.8)`과 1px 마스크 수직 림 그라데이션을 사용합니다(CSS 압축기가 `exclude`를 날리지 않도록 `mask-image`/`mask-clip`/`mask-composite: exclude` 및 `-webkit-mask-composite: xor`를 개별 속성으로 선언).
  - **React Native / Expo**에서는 반드시 `isLiquidGlassAvailable()`과 `isGlassEffectAPIAvailable()`이 모두 참이고 `!AccessibilityInfo.isReduceTransparencyEnabled()`일 때만 `expo-glass-effect`(`GlassView`, `GlassContainer`)를 사용합니다. 자식 뷰가 흐려지지 않도록 `pointerEvents="box-none"`인 절대 위치 배경 래퍼에만 `glass.native[scheme].fillOpacity`(라이트 `0.75` / 다크 `0.92`)를 적용하고, Android·iOS 26 미만·투명도 줄이기 활성 시에는 `glass-fill-frost` + 토큰 림으로 폴백합니다.
  - **치명적 `expo-glass-effect` 함정**: `GlassView` 또는 상위 컨테이너에 직접 `opacity: 0`을 주면 네이티브 `UIVisualEffectView` 렌더링이 깨집니다. 페이드·등장 애니메이션은 `glassEffectStyle={{ style: "regular", animate: true, animationDuration: 0.2 }}` 또는 스케일/이동 변환을 사용합니다.

## 4. 필수 Storybook 카탈로그 (`@storybook/react-vite`)

- RDS-C-6: **Storybook 커버리지 및 Play/A11y 게이트**. 모든 디자인 시스템 프리미티브와 패턴은 `assets/templates/storybook-preview.tsx` 구성을 따르는 `*.stories.tsx` 파일을 포함해야 합니다:
  - `test: "error"` 수준의 `@storybook/addon-a11y` 활성화(치명적/심각 접근성 위반 0건)
  - 전역 **Light / Dark 테마** 및 **`data-platform`(`web`/`desktop`/`mobile`)** 툴바 토글 + Mobile(`320px`/`375px`), Tablet(`768px`/`1024px`), Desktop(`1280px`/`1440px`) 뷰포트
  - `Default`, `Variants & Sizes`, `Interactive States`(`hover`, `focus-visible`, `disabled`, `error`), `Skeleton / Loading`, `Long / Empty Stress Content` 및 인터랙티브 컨트롤(Dialog, Menu, Tabs, Select, Form 검증)의 `play` 상호작용 테스트(`storybook/test`)

- RDS-C-7: **문서화되지 않은 앱 전용 UI 컨트롤 금지**. 앱 피처 폴더에 일회성 기본 컨트롤을 숨겨 만들지 말고 `src/design-system/`으로 승격해 Storybook에 먼저 등록합니다.

- RDS-C-8: **터치 안전 포커스 줌 방지**. 전역 디자인 시스템 CSS에 레이어 밖 `@media (pointer: coarse) { input, textarea, select { font-size: max(16px, 1em); } }`를 반드시 포함해 iOS Safari 포커스 자동 확대를 차단합니다.

## Sources

> 확인 2026-11-26.

| 근거 항목 | 출처 |
|---|---|
| Base UI 래핑, `LiquidGlass`, `motion-collapse`/`motion-reveal`/`motion-swap`, `useActiveIndicator`, `BottomSheet`, coarse 16px 하한 | `../references/horon-and-glass-patterns.ko.md`, <https://github.com/horon-ai/design> |
| Base UI v1 `useRender`, `mergeProps`, `data-starting-style` / `data-ending-style` | <https://base-ui.com/react/utils/use-render> |
| `expo-glass-effect` `GlassView`, `GlassContainer`, 런타임 가드 및 `opacity: 0` 주의사항 | `../references/horon-and-glass-patterns.ko.md`, <https://docs.expo.dev/versions/latest/sdk/glass-effect/> |
| Storybook React + Vite + `addon-a11y` + play 함수 카탈로그 청사진 | `../references/react-vite-stack-blueprint.ko.md` |
