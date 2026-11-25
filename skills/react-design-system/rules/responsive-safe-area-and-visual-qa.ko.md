# 반응형 레이아웃, Safe Area, 모바일 메타, OpenGraph 및 Visual QA 규칙

**목적**: 모든 React + Vite 앱이 모바일 Safe Area, 정적 및 라우트별 동적 OpenGraph 메타데이터, Desktop/Tablet/Mobile 반응형 대응, `.touch-slop` 터치 인체공학, 자동화된 Visual QA 프로브 점검을 결함 없이 충족하도록 보장합니다.

## 1. Safe Area 및 모바일 Viewport 설정 (점검 후 미적용 시 즉시 보완)

- RDS-V-1: **선 점검, 즉시 보완**. 기존 프로젝트를 감사하거나 새 프로젝트를 스캐폴딩할 때 반드시 `index.html`과 루트 CSS의 Safe Area 적용 여부를 확인하고, 누락 시 완료 전 즉시 구현합니다:
  - `index.html`에 `<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />`를 반드시 포함합니다. 접근성을 해치는 `maximum-scale=1`이나 `user-scalable=no`는 절대 넣지 않습니다.
  - Safe Area CSS 유틸리티/변수(`env(safe-area-inset-top)`, `env(safe-area-inset-right)`, `env(safe-area-inset-bottom)`, `env(safe-area-inset-left)`)를 정의해 고정/스티키 상단 바, 하단 내비게이션 바, 플로팅 액션 바, 바텀 시트, 토스트 컨테이너에 적용합니다.
  - 모바일 브라우저 주소창에 의해 하단 컨트롤이 잘리지 않도록 `100vh` 대신 동적 뷰포트 단위(`min-h-dvh`, `100dvh`, `max-h-[calc(100dvh-2rem)]`)를 사용합니다.
  - 웹과 함께 React Native / Expo를 구성할 때는 루트를 `SafeAreaProvider`로 감싸고 `react-native-safe-area-context`의 `useSafeAreaInsets()`를 사용합니다.

## 2. 모바일 Head, Theme Color 및 정적·동적 OpenGraph

- RDS-V-2: **정적 `index.html` 폴백 Head**. `assets/templates/index.html`을 기준으로 다음을 설정합니다:
  - `--color-bg-default`와 일치하는 라이트/다크 `<meta name="theme-color">` (`media="(prefers-color-scheme: light)"` 및 `media="(prefers-color-scheme: dark)"`)와 첫 페인트 전 FOUC를 막는 인라인 테마 초기화 스크립트.
  - 모바일 웹 앱 메타(`apple-mobile-web-app-capable`, `apple-mobile-web-app-status-bar-style`, `format-detection`), canonical `<link rel="canonical">`, favicon SVG/ICO, `apple-touch-icon`(180×180), 웹 매니페스트.
  - 완전한 **OpenGraph** 태그(`og:type`, `og:url`, `og:title`, `og:description`, 1200×630 `og:image`, `og:image:width`, `og:image:height`, `og:image:alt`, `og:site_name`, `og:locale`) 및 **Twitter Card** 태그(`twitter:card="summary_large_image"`, `twitter:title`, `twitter:description`, `twitter:image`).

- RDS-V-3: **TanStack Router `head()` 기반 라우트별 동적 OpenGraph**. 상세/랜딩 라우트에서는 `head({ loaderData })`로 동적 `meta`(`title`, `description`, `og:title`, `og:description`, `og:url`, `og:image`, `twitter:*`)와 canonical `links`를 반환하고 `__root.tsx`에 `<HeadContent />`를 마운트해 클라이언트 내비게이션과 SSR/프리렌더가 일관되게 동작하게 합니다.

## 3. Desktop, Tablet, Mobile 반응형 및 `.touch-slop` 인체공학

- RDS-V-4: **모바일 우선 브레이크포인트 매트릭스**:
  - **Mobile (`320px–767px`, `320×568` 및 `375×812` 검증)**: 단일 열 흐름, 접이식 드로어 또는 `@base-ui/react/drawer` `BottomSheet`, 넓은 표와 코드 블록에만 자체 가로 스크롤(`overflow-x-auto`) 허용 — 페이지 단위 가로 스크롤 0건.
  - **Tablet (`768px–1023px`, `768×1024` 및 `1024×768` 검증)**: 2열 적응형 그리드, 상단 섹션 내비 노출, 데스크톱 사이드바 압박 없는 터치 친화 간격.
  - **Desktop (`1024px+`, `1280×800` 및 `1440×900` 검증)**: 고정 240px 사이드바(`lg`), 스티키 200px 목차 또는 인스펙터(`xl`), `max-w-225`~`max-w-7xl` 가독 폭 제한.

- RDS-V-5: **Coarse 터치 타깃 및 `.touch-slop` 주의사항**. `pointer: coarse` 환경에서 모든 인터랙티브 컨트롤은 최소 `44×44px` 도달 영역(텍스트 컨트롤은 `pointer-coarse:h-11`, 시각 크기를 유지하는 스위치·체크박스·라디오·달력 화살표는 `.touch-slop` `::after` 의사 요소)을 확보해야 합니다. **주의**: 이미 `::after`를 소유한 요소(토스트 닫기 버튼, 밑줄 행)나 `position: fixed`/`absolute` 노드에 `.touch-slop`을 붙이지 말고 별도 래퍼를 둡니다. `pointer: fine`에서는 `32px / 40px / 48px` 밀도를 유지하고 `320px` / `200%` 확대에서도 읽기 순서를 검증합니다.

## 4. 자동화된 Visual QA 프로토콜

- RDS-V-6: **다중 뷰포트 및 다중 상태 캡처 매트릭스**. UI 완료를 선언하기 전 다음 조합으로 Visual QA를 수행합니다:
  - **디바이스**: Mobile(`320×568` 오버플로 확인 + `375×812`), Tablet(`768×1024` + `1024×768`), Desktop(`1280×800` + `1440×900`)
  - **테마**: Light 모드 및 Dark 모드
  - **상태**: 초기 Skeleton 로딩, 실제 데이터 로드, 긴 문자열/줄바꿈 스트레스(`keep-all` / `truncate`), Empty 상태, 유효성/API Error 상태, `focus-visible` 키보드 링, 열린 오버레이(Dialog/Menu/BottomSheet)

- RDS-V-7: **자동화된 DOM 프로브 검증**. 각 뷰포트와 테마의 라이브 브라우저 세션에서 `assets/templates/visual-qa-probe.js`를 실행해 `ok: true`(`horizontalOverflow: false`, `viewportFitCover: true`, `zoomLockViolation: false`, `coarseTouchTargetFailures: []`, `coarseInputFontFailures: []`, `nonOverlayShadowHits: []`, `missingAltImages: []`, `unnamedButtons: []`), WCAG 2.2 AA 명도비(텍스트 `>= 4.5:1`, UI `>= 3:1`), 콘솔/페이지 에러 0건을 확인합니다.

- RDS-V-8: **정직한 미검증 표기**. 세션에 브라우저 도구가 없으면 `scripts/audit-react-ds.sh --strict --json`과 `vite build`를 실행하고, 렌더링 및 프로브 검증 항목은 추측하지 말고 `not_verified`로 명시합니다.

## Sources

> 확인 2026-11-26.

| 근거 항목 | 출처 |
|---|---|
| 반응형 브레이크포인트, `pointer: coarse` 44px `.touch-slop` 규칙 및 `::after` 주의사항, 200% 확대, 테마 초기화 | `../references/horon-and-glass-patterns.ko.md`, <https://github.com/horon-ai/design> |
| TanStack Router `head()` 동적 메타/OpenGraph 및 `<HeadContent />` | <https://tanstack.com/router/latest/docs/framework/react/guide/document-head-management> |
| `index.html` Safe Area, OpenGraph 및 `visual-qa-probe.js` 체크리스트 | `../references/react-vite-stack-blueprint.ko.md`, `../assets/templates/visual-qa-probe.js` |
