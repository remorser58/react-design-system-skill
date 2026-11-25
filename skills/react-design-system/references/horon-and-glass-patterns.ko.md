# Horon 디자인 시스템 및 Expo Glass Effect 아키텍처

## 목차

- [1. 토큰 정본 및 `@theme static` 컴파일러 잠금](#1-토큰-정본-및-theme-static-컴파일러-잠금)
- [2. 13단계 타이포그래피 및 플랫폼 모드](#2-13단계-타이포그래피-및-플랫폼-모드)
- [3. Base UI v1 (`useRender`, `Drawer` 바텀 시트, `Tabs.Indicator`)](#3-base-ui-v1-userender-drawer-바텀-시트-tabsindicator)
- [4. 웹 LiquidGlass, Veil 및 `.touch-slop` 재질 명세](#4-웹-liquidglass-veil-및-touch-slop-재질-명세)
- [5. Expo Glass Effect (`expo-glass-effect`) 네이티브 패리티](#5-expo-glass-effect-expo-glass-effect-네이티브-패리티)
- [6. 모션 유틸리티, 디스클로저(`motion-reveal`/`motion-swap`) 및 동작 줄이기](#6-모션-유틸리티-디스클로저motion-revealmotion-swap-및-동작-줄이기)
- [Sources](#sources)

## 1. 토큰 정본 및 `@theme static` 컴파일러 잠금

`https://github.com/horon-ai/design` 핵심 구조 요약:

1. **단일 정본(Single Source of Truth)**: `src/design-system/tokens/`에 `color.ts`, `typography.ts`, `scale.ts`, `glass.ts`, `motion.ts`를 정의합니다.
2. **컴파일러 잠금 `theme.css`**: 토큰 TypeScript 소스에서 `@theme static { ... }` 블록을 생성하고 맨 위에 `--color-*: initial; --radius-*: initial; --text-*: initial; --font-*: initial; --font-weight-*: initial; --shadow-*: initial;`를 선언합니다. 특히 `--shadow-*: initial`은 임의 `shadow-md`/`shadow-xl` 유틸리티가 컴파일조차 되지 않게 막습니다.
3. **플랫폼 및 다크 모드 오버라이드**: `[data-platform="desktop"]`, `[data-platform="mobile"]` 타입 변수 블록과 `.dark { color-scheme: dark; ... }` 오버라이드를 함께 생성합니다.
4. **반경(Radius) 주의점**: Horon 스케일은 `xs: 6px`, `sm: 8px`, `md: 12px`, `lg: 14px`, `xl: 20px`, `2xl: 16px`, `full: 9999px`이므로 이름 순서가 아니라 실제 px 값으로 고릅니다. 알약 컨트롤은 `rounded-full`, 입력/메뉴 행은 `rounded-md`, 다이얼로그·팝오버는 `rounded-xl`을 씁니다.
5. **그림자 규칙**: 인라인 블록에 그림자를 쓰지 않습니다. `--shadow-popover`(`0 8px 24px 0 rgba(10, 13, 15, 0.1)`)와 `--shadow-palette`(`0 16px 40px 0 rgba(10, 13, 15, 0.12)`)는 분리된 불투명 오버레이에만 예외적으로 허용하며, 그 외에는 `LiquidGlass`/`Veil`을 씁니다.

## 2. 13단계 타이포그래피 및 플랫폼 모드

- **서체**: `Pretendard Variable`(`--font-sans`) + `Geist Mono Variable`(`--font-mono`).
- **4종 굵기만 허용**: `400`(regular), `500`(medium), `600`(semibold), `700`(bold). Thin(100~200)과 Light(300)는 쓰지 않습니다.
- **한국어 줄바꿈**: 한국어 본문에 `word-break: keep-all`을 적용해 음절 단위 끊김을 막습니다.
- **13단계 표준 스타일(`size / lineHeight` px, Web / Desktop / Mobile)**:
  - `display-lg` (700, -0.03em): `56/68` (web), `48/58` (desktop), `36/44` (mobile)
  - `display-md` (700, -0.025em): `44/52`, `40/48`, `30/36`
  - `title-lg` (600, -0.02em): `32/40`, `28/36`, `24/32`
  - `title-md` (600, -0.015em): `24/32`, `22/28`, `20/28`
  - `title-sm` (600, -0.01em): `20/28`, `18/26`, `18/26`
  - `body-lg` (400, -0.008em, 문단 간격 0.75em): `18/30`, `16/26`, `17/28`
  - `body-md` (400, -0.005em, 문단 간격 0.75em): `16/26`, `14/22`, `16/26`
  - `body-sm` (400, -0.002em, 문단 간격 0.75em): `14/22`, `13/20`, `14/22`
  - `label-lg` (500, -0.005em): `16/22`, `14/20`, `16/22`
  - `label-md` (500, -0.003em): `14/20`, `13/18`, `14/20`
  - `label-sm` (500, 0em): `12/16`, `11/16`, `12/16`
  - `caption` (400, 0.005em): `12/18`, `11/18`, `12/18`
  - `code` (mono 400, 0em): `14/22`, `13/20`, `13/20`

## 3. Base UI v1 (`useRender`, `Drawer` 바텀 시트, `Tabs.Indicator`)

- **다형성 커스텀 프리미티브 (`useRender` + `mergeProps`)**:

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

- **반응형 `Drawer` 바텀 시트 (`@base-ui/react/drawer`)**: `< 560px` 뷰포트에서는 하단 전체 폭으로 붙고 넓은 화면에서는 `maxWidth: 560` 중앙 정렬하며, `Drawer.Content`에 `pb-[calc(1.5rem+env(safe-area-inset-bottom))]`, `overscroll-contain`, 상단 드래그 그래버를 배치합니다.
- **슬라이딩 인디케이터 (`Tabs.Indicator` & `useActiveIndicator`)**: Base UI 외부 트랙에서는 `useLayoutEffect` 내 `ResizeObserver` + `MutationObserver`로 `[aria-current="page"]` / `[data-pressed]` 위치를 측정하고, 인디케이터가 `(0, 0)`에서 날아오지 않도록 `requestAnimationFrame` 1프레임 뒤 `motion-indicator`를 활성화합니다.

## 4. 웹 LiquidGlass, Veil 및 `.touch-slop` 재질 명세

- **Glass 파라미터 (`glass.ts`)**: `blur: 20`, `saturate: 1.8`, `rimWidth: 1`, `rimMidStop: 0.5`.
  - 등급(`bg-glass-clear`, `bg-glass-regular`, `bg-glass-thick`)은 호스트 채움 클래스가 소유하고, `<LiquidGlass />`는 `relative isolate overflow-clip` 호스트 첫 자식으로 `<span aria-hidden className="liquid-layers" />`를 렌더합니다.
  - CSS 압축기가 `mask` 단축 속성에서 `exclude`를 지우지 않도록 `mask-image`, `mask-clip`, `mask-composite: exclude`, `-webkit-mask-composite: xor`를 개별 속성으로 선언합니다.
  - 폴백: `@media (prefers-reduced-transparency: reduce)` 또는 `backdrop-filter` 미지원 시 배경을 `var(--color-glass-fill-frost)`로 대체합니다.
- **Veil 파라미터 (`veil`)**: `.veil-field`와 `.veil-overlay`용 경량 글래스(`blur: 8`, `saturate: 1.6`, `ringWidth: 1`).
- **Coarse 터치 도달 영역(`.touch-slop`) 및 iOS 입력 하한**:
  - 레이어 밖 `@media (pointer: coarse) { input, textarea, select { font-size: max(16px, 1em); } }` 규칙으로 iOS Safari 포커스 줌을 차단합니다.
  - `.touch-slop`은 `@media (pointer: coarse)`에서 `::after`로 소형 컨트롤의 터치 영역을 `44×44px`로 확장합니다. 이미 `::after`를 소유한 요소나 `position: fixed` / `absolute` 노드에는 절대 붙이지 않습니다.

## 5. Expo Glass Effect (`expo-glass-effect`) 네이티브 패리티

`https://docs.expo.dev/versions/latest/sdk/glass-effect/` 및 `horon-ai/design` `@horon-ai/expo` 패턴:

```tsx
import { StyleSheet, View, type ViewStyle } from "react-native";
import { GlassView, isGlassEffectAPIAvailable, isLiquidGlassAvailable } from "expo-glass-effect";

export function canUseNativeLiquidGlass(reduceTransparency: boolean): boolean {
  try {
    return !reduceTransparency && isLiquidGlassAvailable() && isGlassEffectAPIAvailable();
  } catch {
    return false;
  }
}

// GlassSurface 내부(iOS 26+ 네이티브 분기):
// GlassView 자체에는 opacity < 1이나 opacity: 0을 절대 주지 말고,
// 자식 뒤 절대 위치 래퍼에만 fillOpacity(라이트 0.75 / 다크 0.92)를 적용합니다.
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

- **플랫폼 규칙**: **iOS 26+** 및 tvOS에서 네이티브 동작하며, Android·iOS 26 미만·투명도 줄이기 시 `glass-fill-frost` + 1px 토큰 림(눌림 시 `overlay-ink-8` 워시)으로 폴백합니다.
- **`GlassContainer`**: `spacing?: number`로 인접 `GlassView` 간의 블렌딩 거리를 제어합니다.
- **치명적 주의사항**: `GlassView` 또는 상위 컨테이너에 `opacity: 0`을 주면 네이티브 `UIVisualEffectView`가 깨집니다. 페이드는 `glassEffectStyle={{ style: "regular", animate: true, animationDuration: 0.2 }}` 또는 스케일/이동 변환을 사용합니다.

## 6. 모션 유틸리티, 디스클로저(`motion-reveal`/`motion-swap`) 및 동작 줄이기

- **3종 표준 이징**: `--ease-out-quint: cubic-bezier(0.22, 1, 0.36, 1)`, `--ease-emphasized: cubic-bezier(0.2, 0, 0, 1)`, `--ease-spring: cubic-bezier(0.34, 1.3, 0.64, 1)`.
- **유틸리티** (`assets/templates/glass-and-motion.css`): `motion-colors`(150ms), `motion-press`(150ms `scale(0.97)`), `motion-popup`(200ms in / 130ms out), `motion-fade`(200ms), `motion-collapse`(`--collapsible-panel-height` 240ms), `motion-reveal`(`grid-template-rows: 1fr <-> 0fr`, 접힘 시 `inert`), `motion-swap`(단일 그리드 영역 `"swap"` 무-CLS 아이콘/라벨 전환), `motion-indicator`(280ms).
- **동작 줄이기**: `@media (prefers-reduced-motion: reduce)`에서 전환·애니메이션 지속시간을 `0.01ms !important`, 반복 횟수를 `1 !important`, `scroll-behavior: auto !important`로 축소합니다.

## Sources

> 확인 2026-11-26.

| 근거 항목 | 출처 |
|---|---|
| Horon `@theme static` 생성기, `globals.css`, `tabs.tsx`, `bottom-sheet.tsx`, `use-active-indicator.ts`, `@horon-ai/expo` `glass-surface.tsx` | <https://github.com/horon-ai/design> |
| Base UI v1 `useRender`, `mergeProps`, `data-starting-style` / `data-ending-style` | <https://base-ui.com/react/utils/use-render> |
| `expo-glass-effect` 컴포넌트, 런타임 체크(`isGlassEffectAPIAvailable`, `isLiquidGlassAvailable`), `opacity: 0` 제약 | <https://docs.expo.dev/versions/latest/sdk/glass-effect/> |
