---
name: "react-design-system"
description: "Mobbin, UIBowl, Figma, Dribbble, Behance, Pinterest, 21st.dev, horon-ai/design 레퍼런스를 4단계로 정량 분해하고 @theme static으로 카드와 그림자를 컴파일 단계부터 차단하며, Base UI headless 컴포넌트(useRender/Drawer/Tabs), 분리된 Motion 레이어, Storybook(a11y/play), Safe Area·모바일 viewport·정적/동적 OpenGraph, Desktop/Tablet/Mobile Visual QA 프로브, React + Vite(TanStack Query/Router/Table + Zustand + ky + Skeleton UI + DB 왕복 최적화) 기반 React 전용 디자인 시스템과 UI를 구축할 때 사용합니다. 비-React 프레임워크, UI 없는 백엔드 API, 일반 문서 작업에는 사용하지 마십시오."
compatibility: "대상 React + Vite(또는 Expo 병행) 프로젝트의 파일 읽기/검색/수정과 typecheck, build, Storybook, `scripts/audit-react-ds.sh`(bash 3.2+ 및 jq 필요) 실행 권한이 필요합니다. 반응형 Visual QA에는 사용 가능한 브라우저 도구와 `assets/templates/visual-qa-probe.js`를 사용하며, 브라우저가 없으면 정적 검증만 보고합니다."
---

필요에 따라 아래 규칙 파일을 엽니다. 번들 경로는 이 스킬 디렉터리 기준, 프로젝트 경로는 대상 워크스페이스 기준으로 해석합니다.

- [rules/reference-mining-and-surface.ko.md](rules/reference-mining-and-surface.ko.md)
- [rules/base-ui-motion-and-storybook.ko.md](rules/base-ui-motion-and-storybook.ko.md)
- [rules/responsive-safe-area-and-visual-qa.ko.md](rules/responsive-safe-area-and-visual-qa.ko.md)
- [rules/react-vite-optimization.ko.md](rules/react-vite-optimization.ko.md)

# React Design System

> 레퍼런스를 정량적으로 파쿠리해 분해하고, Tailwind `@theme static` 수준에서 카드와 그림자를 잠근 뒤, React 전용 Base UI 프리미티브·독립 Motion·Storybook·Safe Area·정적/동적 OpenGraph·전 디바이스 Visual QA 프로브·무워터폴 TanStack + Zustand + ky 스택으로 완성합니다.

- **목적**: 4단계 레퍼런스 분해 프로토콜과 엄격한 표면·모션·반응형·데이터 페칭 계약을 바탕으로 일관된 React 전용 디자인 시스템, Storybook 카탈로그, 랜딩/소개 페이지, 프로덕션 React + Vite 앱을 설계·구현합니다.
- **사용 금지**: Vue/Svelte/Angular/Astro 전용 앱, UI 표면이 없는 백엔드 API·DB 마이그레이션, React 코드가 없는 단순 산문·브랜드 문안 작성.
- **입력**: 대상 React + Vite(또는 병행 Expo 글래스) 코드베이스, 제품 화면 또는 랜딩 요구사항, 시각 레퍼런스 출처.
- **출력**: `@theme static` 토큰 기반 React + Base UI 디자인 시스템, 독립 Motion 레이어, play/a11y 포함 Storybook 스토리, Safe Area + 정적/동적 OpenGraph, TanStack/Zustand/ky 아키텍처 + Skeleton UI, `audit-react-ds.sh --strict` 및 Visual QA 증빙.

<output_language>

모든 사용자 대상 요약, 디자인 브리프, 감사 노트, 검증 리포트는 한국어를 기본으로 작성하며, 코드 식별자, React/TSX 구문, CSS 변수, CLI 명령, URL, 파일 경로, 패키지 이름은 원문 언어를 유지합니다.

</output_language>

<purpose>

- **Mobbin**, **UIBowl**, **Figma**, **Dribbble**, **Behance**, **Pinterest**, **21st.dev**(랜딩 및 소개 페이지)를 **4단계 레퍼런스 분해 프로토콜**(수집 -> 정량 추출 -> 카드·그림자 제거 -> 토큰·Base UI 합성)로 분석하고, **`horon-ai/design`**과 **`expo-glass-effect`**(`GlassView` / `GlassContainer` 네이티브 iOS 26+ 패리티)를 반영합니다.
- **컴파일 수준 무카드·무그림자 표면 규율**(`@theme static`으로 `--shadow-*: initial; --color-*: initial; --radius-*: initial; --text-*: initial;` 리셋)을 강제해 박스형 `<Card>`와 `box-shadow` 대신 여백, 1px 헤어라인, 톤 배경 대비, 타이포그래피 위계, `LiquidGlass` / `Veil`을 사용합니다.
- **React 전용** 컴포넌트를 오직 **Base UI (`@base-ui/react`)**(`render` + `useRender` / `mergeProps`, `Drawer` 바텀 시트, `Tabs.Indicator`) 위에 구축하고 **Storybook**(`@storybook/react-vite` + `@storybook/addon-a11y` + play 함수)과 분리된 **Motion** 레이어(`motion.css` + `motion/react`)로 관리합니다.
- **Safe Area**(`viewport-fit=cover`, `env(safe-area-inset-*)`, `dvh`, iOS coarse 16px 입력 하한, `.touch-slop`), 정적 `index.html` + `@tanstack/react-router` 라우트별 `head()` OpenGraph, **Desktop / Tablet / Mobile** 반응형 **Visual QA**(`assets/templates/visual-qa-probe.js`)를 완비합니다.
- **React + Vite + `@tanstack/react-query` + `@tanstack/react-router` + `@tanstack/react-table` + `zustand` + `ky`** 기반 폴더 아키텍처, 정밀 기하학 **Skeleton UI**, 데이터베이스/API 왕복 횟수 최소화를 구현합니다.

</purpose>

<routing_rule>

결과물이 React 디자인 시스템, Storybook 컴포넌트 카탈로그, Base UI 프리미티브 세트, `21st.dev` 기반 React 랜딩/소개 페이지, 또는 React + Vite 프론트엔드 UI 아키텍처 및 Visual QA 작업일 때 이 스킬을 사용합니다.

다음 경우에는 사용하지 않습니다:

- React 전환 목적이 없는 비-React 프레임워크(Vue, Svelte, Angular, 순수 정적 HTML) 산출물
- UI 표면이 전혀 없는 백엔드 API, SQL, 인프라 전용 산출물
- React 컴포넌트나 스타일 코드가 포함되지 않은 일반 산문 문서, PRD, 단순 이미지 생성 산출물

</routing_rule>

<instruction_contract>

| 항목 | 계약 |
|---|---|
| 의도 | 카드와 임의 그림자, 페치 워터폴 없이 레퍼런스에 기반한 React 전용 토큰 잠금 디자인 시스템과 최적화된 React + Vite UI를 제공합니다. |
| 트리거 | React UI·컴포넌트 라이브러리·Storybook·랜딩/소개 페이지·반응형/Safe Area/OpenGraph 보완·TanStack/Zustand/ky 프론트엔드 아키텍처 요청. |
| 범위 | 4단계 레퍼런스 분해, `@theme static` 토큰, Base UI `useRender` 프리미티브, 독립 Motion 모듈, Storybook + play/a11y, `index.html` + `head()` Safe Area/OpenGraph, 반응형 Visual QA, React + Vite 폴더/데이터/Skeleton 구조를 다룹니다. 별도 요청 없는 백엔드 DB 스키마 변경과 git 커밋은 제외합니다. |
| 권한 | 사용자 요구사항과 프로젝트 `DESIGN.md`/토큰이 스킬 기본값보다 우선합니다. 수집한 레퍼런스(Mobbin, UIBowl, Figma, Dribbble, Behance, Pinterest, 21st.dev, `horon-ai/design`)는 그대로 복제할 자산이 아니라 구조·정량 비율 근거로만 활용합니다. |
| 근거 | `scripts/audit-react-ds.sh --strict --json`, TypeScript/Vite/Storybook 빌드, 그리고 `assets/templates/visual-qa-probe.js`를 이용한 Desktop/Tablet/Mobile 실제 렌더링 결과로 검증합니다. |
| 도구 | 파일 읽기/쓰기/편집, 셸 명령(`tsc`, `vite build`, `storybook`, bash 3.2+ 및 jq가 필요한 `scripts/audit-react-ds.sh`), 사용 가능한 브라우저 자동화 도구(브라우저 부재 시 `not_verified`로 명시). |
| 루프 | 제한된 UI/QA 수정 루프: 프로브/캡처 실행 -> 최소 토큰/레이아웃/접근성 수정 -> 재렌더링 및 재감사. 차단 사유 보고 전 뷰포트/표면당 최대 2회 수정으로 제한합니다. |
| 산출물 | 토큰 파일, `@base-ui/react` 프리미티브, `motion/` 유틸리티, `.stories.tsx`, `index.html` + `head()` Safe Area/OpenGraph, TanStack/Zustand/ky 피처 구조 + Skeleton UI, 한국어 검증 요약. |
| 검증 | `audit-react-ds.sh --strict --json` 통과(`errors == 0`), `320px`/`375px`/`768px`/`1280px`/`1440px` 대상 `visual-qa-probe.js` 통과, 44px 터치 타깃, Safe Area 여백, Storybook a11y/play 통과, 라우트 병렬 프리페치 확인, 콘솔 에러 0건. |
| 종료 조건 | 표면, Base UI, Motion, Storybook, Safe Area/OpenGraph, 반응형 Visual QA, TanStack/Zustand/ky 검증이 모두 통과하거나 명확한 차단 사유를 기록했을 때만 종료합니다. |

</instruction_contract>

<activation_examples>

긍정 예시:
- "Mobbin, UIBowl, Figma 레퍼런스 참고해서 카드랑 shadow 빼고 Base UI 위에 React 디자인 시스템 + Storybook 세팅해줘."
- "Build a landing and intro page inspired by 21st.dev using React + Vite, Base UI, isolated motion/react animations, no cards/shadows, and full OpenGraph + mobile safe-area support."
- "React Vite 프론트엔드 아키텍처를 TanStack Query/Router/Table + Zustand + ky로 잡고 Skeleton UI랑 DB 왕복 최적화까지 해서 Desktop/Tablet/Mobile Visual QA 돌려줘."

부정 / 경계 예시:
- "Build a Vue 3 + Nuxt dashboard with PrimeVue." -> React 전용 경계 위반; React 마이그레이션이 아니면 범위 밖.
- "Optimize these PostgreSQL indexes and write a Go gRPC microservice." -> React UI 표면이 없는 백엔드 전용 작업.
- "Write a plain text marketing blog post about design systems." -> React 코드가 없는 일반 텍스트 산출물.

</activation_examples>

<trigger_conditions>

| 상황 | 모드 |
|---|---|
| 신규 React + Vite 디자인 시스템, `@theme static` 토큰, Base UI 프리미티브, Storybook 구축 | `system-create` |
| `21st.dev` 및 4단계 시각 레퍼런스 기반 무카드·무그림자 랜딩/소개 페이지 구축 | `landing-build` |
| 기존 React UI의 Safe Area, viewport, 정적/동적 OpenGraph, 반응형 Visual QA 점검·수정 | `responsive-audit-fix` |
| React + Vite 폴더 구조, TanStack/Zustand/ky, Skeleton UI, DB 왕복 최적화 | `vite-architecture` |

</trigger_conditions>

<skill_architecture>

- 코어 (`SKILL.md` / `SKILL.ko.md`): 필수 원칙, 라우팅, 워크플로, 검증 게이트.
- 규칙 (`rules/`): `reference-mining-and-surface.ko.md`, `base-ui-motion-and-storybook.ko.md`, `responsive-safe-area-and-visual-qa.ko.md`, `react-vite-optimization.ko.md`.
- 상세 명세 (`references/`): `horon-and-glass-patterns.ko.md` (`horon-ai/design` + `expo-glass-effect`), `landing-21st-dev-patterns.ko.md` (`21st.dev` + Mobbin/UIBowl/Figma/Dribbble/Behance/Pinterest), `react-vite-stack-blueprint.ko.md` (TanStack/Zustand/ky + `index.html` + `head()` + Safe Area + Skeleton + Storybook).
- 스타터 자산 및 감사 도구: `assets/templates/index.html`, `assets/templates/glass-and-motion.css`, `assets/templates/storybook-preview.tsx`, `assets/templates/visual-qa-probe.js`, `scripts/audit-react-ds.sh` (`--strict --json`), `assets/evals/react-design-system-cases.jsonl`.

</skill_architecture>

<loop_policy>

토큰, 스타터 템플릿, 폴더 구조, 헤드 메타데이터 스캐폴딩처럼 결정적인 작업은 단일 패스로 구현한 뒤 `scripts/audit-react-ds.sh --strict`와 `vite build`로 즉시 검증합니다. 렌더링된 Desktop, Tablet, Mobile Visual QA는 `assets/templates/visual-qa-probe.js` 기반 최대 2회 제한 수정 루프를 사용하며, 실측된 레이아웃·Safe Area·대비·상태 결함만 수정한 뒤 재검증합니다. 통과를 위해 검증 기준을 임의로 완화하지 않습니다.

</loop_policy>

<language_and_translation_default>

정본 스킬 문서는 영문(`SKILL.md`, `rules/*.md`, `references/*.md`)으로 작성하고 구조가 일치하는 한국어 형제 파일(`*.ko.md`)을 유지합니다. 스킬 실행으로 생성하는 사용자 대상 산출물(요약, 설계 근거, QA 리포트)은 한국어를 기본으로 하며 코드, 토큰명, 패키지 식별자는 영문을 유지합니다.

</language_and_translation_default>

<reference_routing>

작업 단계에 맞춰 번들 레퍼런스와 템플릿을 선택적으로 읽습니다:

- `@theme static` 토큰, 13단계 타이포그래피, Base UI `useRender` / `Drawer` / `Tabs.Indicator`, `LiquidGlass`/`Veil` CSS, 또는 React Native `expo-glass-effect` (`GlassView`, `GlassContainer`, `isGlassEffectAPIAvailable()`)를 정의할 때는 `references/horon-and-glass-patterns.ko.md`와 `assets/templates/glass-and-motion.css`를 읽습니다.
- Mobbin/UIBowl/Figma/Dribbble/Behance/Pinterest 4단계 레퍼런스 분해를 수행하거나 `21st.dev` 랜딩·소개 섹션을 무카드/헤어라인/글래스 React + Base UI 표면으로 재구성할 때는 `references/landing-21st-dev-patterns.ko.md`를 읽습니다.
- React + Vite 폴더 구조, Safe Area + 정적/동적 OpenGraph, `ky` 클라이언트, TanStack Router `loader`/`head()`, TanStack Query, TanStack Table, Zustand, Skeleton UI, Storybook, Visual QA를 구성할 때는 `references/react-vite-stack-blueprint.ko.md`, `assets/templates/index.html`, `assets/templates/storybook-preview.tsx`, `assets/templates/visual-qa-probe.js`를 읽습니다.

</reference_routing>

<support_file_read_order>

1. 대상 프로젝트의 `package.json`, `index.html`, `src/` 구조, 기존 `DESIGN.md` 또는 토큰 파일 확인.
2. 토큰이나 컴포넌트 설계 전 `rules/reference-mining-and-surface.ko.md`와 `rules/base-ui-motion-and-storybook.ko.md` 읽기.
3. 라우트, 데이터 훅, 헤드 메타 작성 전 `rules/responsive-safe-area-and-visual-qa.ko.md`와 `rules/react-vite-optimization.ko.md` 읽기.
4. 필요한 `references/*.ko.md` 및 `assets/templates/*` 확인 후 `scripts/audit-react-ds.sh --root <project> --strict --json` 실행.

</support_file_read_order>

<workflow>

| 단계 | 수행 작업 | 완료 기준 | 생략 불가 이유 |
|---|---|---|---|
| 1 | 기존 React + Vite 저장소 감사(`scripts/audit-react-ds.sh --strict --json`) 및 4단계 레퍼런스 분해 실행 | `file:line` 위반 목록 및 정량 추출표(Mobbin/UIBowl/Figma/Dribbble/Behance/Pinterest/21st.dev) 기록 | 맹목적 복제나 기존 토큰 손상을 방지함 |
| 2 | `horon-ai/design` 참조 `@theme static` 토큰(Color, 13단계 Type, Radius, Glass/Veil, 3종 Easing, `--shadow-*: initial`) 정의 | `src/design-system/tokens/` 단일 정본 + 라이트/다크 + `data-platform` 모드 구축 | 컴파일 단계에서 일회성 hex/px/그림자 차단 |
| 3 | React 전용 `@base-ui/react` (`useRender`, `Drawer`, `Tabs.Indicator`) 프리미티브, 독립 `motion/` 레이어, Skeleton UI, Storybook 스토리 구현 | 비-React UI 키트 0건, 카드/그림자 0건, 모든 상태 + a11y + play 함수가 Storybook에 노출됨 | 접근성, 모션 격리, 컴포넌트 시각 검증 보장 |
| 4 | `index.html`(`viewport-fit=cover`, 정적 OpenGraph, Twitter, `theme-color`), 라우터 `head()` 동적 OG, Safe Area/coarse CSS 적용 | `audit-react-ds.sh --strict`에서 헤드·Safe Area·줌잠금·`dvh` 위반 0건 | iOS 노치 침범, Safari 포커스 줌, 공유 미리보기 깨짐 방지 |
| 5 | React + Vite 아키텍처(`@tanstack/react-router` `defaultPreloadStaleTime: 0` 로더 + `@tanstack/react-query` + URL 동기화 `@tanstack/react-table` + `zustand` + `ky`) 구축 | 라우트 병렬 프리페치로 워터폴 제거, DB/API 왕복 최소화, 최종 기하와 일치하는 Skeleton 적용 | 빠른 초기 렌더링과 CLS 0 보장 |
| 6 | `assets/templates/visual-qa-probe.js`로 Desktop, Tablet, Mobile Visual QA 실행(Light/Dark, Loaded/Skeleton/Empty/Error/Focus, Storybook a11y) | 프로브 `ok: true`, 320px+ 가로 스크롤 0, 44px 터치 타깃, 명도비 >= 4.5:1, typecheck 및 build 통과 | 모든 디바이스 환경에서의 실제 화면 품질 입증 |

</workflow>

<required>

| 영역 | 필수 요구사항 |
|---|---|
| 스택 | `@base-ui/react` (`useRender` / `Drawer` / `Tabs`) + **Storybook** (`@storybook/react-vite` + `addon-a11y`) 기반 **React 전용** UI (`react` + `vite` + TypeScript) |
| 레퍼런스 | **Mobbin**, **UIBowl**, **Figma**, **Dribbble**, **Behance**, **Pinterest**, **`horon-ai/design`**, **`expo-glass-effect`**, **`21st.dev`**(랜딩/소개 페이지) 4단계 분석 및 활용 |
| 표면 & 모션 | `@theme static` 컴파일 잠금(`--shadow-*: initial`), **카드 남발(`<Card>`) 금지 및 장식용 `box-shadow` 제거**; `prefers-reduced-motion`을 준수하는 독립 **Motion** 레이어(`motion.css` + `motion/react`) |
| Safe Area & 헤드 | `viewport-fit=cover`, `env(safe-area-inset-*)`, `.touch-slop`, `dvh`, iOS coarse 16px 입력 하한, `theme-color`, 정적 + 라우트별 `head()` **OpenGraph** |
| 최적화 & QA | **TanStack Query + TanStack Router + TanStack Table + Zustand + ky**, 도메인 폴더 구조, 정밀 **Skeleton UI**, DB 왕복 최소화, **Desktop / Tablet / Mobile Visual QA** (`visual-qa-probe.js`) |

</required>

<forbidden>

| 영역 | 금지 사항 |
|---|---|
| 프레임워크 & 키트 | React + `@base-ui/react` 대신 Vue, Svelte, Angular, Astro 전용 UI, jQuery, `@radix-ui/*`, shadcn/ui, MUI, AntD 사용 |
| 표면 & 모션 | 섹션을 박스형 `<Card>`로 감싸기, `shadow-sm/md/lg/xl/2xl` 또는 임의 `box-shadow` 사용, 컴포넌트 내 인라인 모션 상수 산재, `::after`를 이미 쓰는 요소에 `.touch-slop` 적용, `expo-glass-effect` `GlassView`에 `opacity: 0` 적용 |
| 모바일 & 헤드 | `viewport-fit=cover` 또는 `env(safe-area-inset-*)` 누락, 핀치 줌 차단(`user-scalable=no` / `maximum-scale=1`), `dvh` 없는 `100vh`, `og:*` 태그 누락 |
| 데이터 & 상태 | 직렬 `useEffect` 페치 워터폴, N+1 API 호출, Zustand에 서버 캐시 복제, Router/Query 캐시 소유권 충돌, Skeleton UI 대신 레이아웃이 튀는 스피너 사용 |

</forbidden>

<validation>

- [ ] `scripts/audit-react-ds.sh --root <target-project> --strict --json` 실행 결과가 `"ok": true`이고 `summary.errors == 0`임.
- [ ] `tsc --noEmit`, `vite build`, Storybook 빌드(`storybook build`)가 오류 없이 성공함.
- [ ] Desktop(`1280px`/`1440px`), Tablet(`768px`/`1024px`), Mobile(`320px`/`375px`) Visual QA(`visual-qa-probe.js`)에서 가로 스크롤 0건, Safe Area 확보, 44px 터치 타깃, Light/Dark 일관성, Skeleton/Empty/Error/Focus 상태가 모두 확인됨.
- [ ] 네트워크 트레이스 및 라우트 로더 점검에서 `@tanstack/react-router` + `@tanstack/react-query` + `ky`를 통한 병렬 프리페치와 DB/API 왕복 최소화가 확인됨.

</validation>

## Sources

> 확인 2026-11-26.

| 근거 항목 | 출처 |
|---|---|
| Horon `@theme static` 토큰, Base UI 컴포넌트, `LiquidGlass`/`Veil`, `.touch-slop`, 모션 유틸리티 및 `horon-ai/design` 구조 | `references/horon-and-glass-patterns.ko.md`, <https://github.com/horon-ai/design> |
| Base UI v1 `useRender`, `mergeProps`, `data-starting-style` / `data-ending-style` | <https://base-ui.com/react/utils/use-render> |
| 네이티브 iOS 26+ `GlassView`, `GlassContainer`, 런타임 가드 및 `opacity: 0` 제약 | `references/horon-and-glass-patterns.ko.md`, <https://docs.expo.dev/versions/latest/sdk/glass-effect/> |
| 랜딩/소개 페이지 히어로, 섹션 리듬, 셰이더/모션 패턴 및 4단계 레퍼런스 분석 | `references/landing-21st-dev-patterns.ko.md`, <https://21st.dev/> |
| React + Vite 폴더 구조, Safe Area, 정적/동적 OpenGraph (`head()`), TanStack Query/Router/Table, Zustand, ky, Skeleton UI, Storybook | `references/react-vite-stack-blueprint.ko.md` |
