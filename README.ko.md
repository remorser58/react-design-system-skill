# React Design System Skill

[English](README.md) | 한국어

코딩 에이전트를 위한 자체 완결형 React 전용 디자인 시스템 및 프론트엔드 아키텍처 스킬입니다. 시각 레퍼런스 분석(파쿠리)부터 컴파일 잠금 토큰, `@base-ui/react` headless 프리미티브, 독립 Motion, Storybook 카탈로그, Safe Area·OpenGraph, Desktop/Tablet/Mobile Visual QA, 무워터폴 React + Vite 데이터 페칭까지 하나로 규율합니다.

## 핵심 원칙

- **4단계 레퍼런스 정량 분해**: **Mobbin**, **UIBowl**, **Figma**, **Dribbble**, **Behance**, **Pinterest**, **21st.dev**(랜딩·소개 페이지)에서 균형 잡힌 레퍼런스를 수집하고 타이포 비율·여백·모션 수치를 정량 추출한 뒤 카드와 그림자를 걷어내 [`horon-ai/design`](https://github.com/horon-ai/design) 구조로 합성합니다.
- **컴파일 수준 무카드·무그림자 표면**: Tailwind v4 `@theme static`(`--shadow-*: initial; --color-*: initial; --radius-*: initial; --text-*: initial;`)로 임의 그림자와 비승인 색상을 컴파일 단계부터 차단하고 여백, 1px 헤어라인, 톤 배경 대비, `LiquidGlass`/`Veil`로 대체합니다.
- **React 전용 Base UI + 독립 Motion + Storybook**: **React 19 + TypeScript**로만 작성하며 **`@base-ui/react`**(`render`, `useRender`/`mergeProps`, `Drawer` 바텀 시트, `Tabs.Indicator`) 위에 구축하고, 모션은 `src/design-system/motion/`(`motion.css` + `motion/react`)에 격리하며, **`@storybook/react-vite`**(`addon-a11y` + play 테스트) 및 [`expo-glass-effect`](https://docs.expo.dev/versions/latest/sdk/glass-effect/) 네이티브 iOS 26+ 패리티(`GlassView`, `GlassContainer`, 런타임 가드, `opacity: 0` 금지)를 준수합니다.
- **Safe Area · 모바일 Viewport · 정적/동적 OpenGraph · Visual QA**: `viewport-fit=cover`, `env(safe-area-inset-*)`, `dvh`, iOS coarse 16px 입력 하한, `.touch-slop`, `index.html` + `@tanstack/react-router` `head()` OpenGraph, `assets/templates/visual-qa-probe.js` 기반 Desktop/Tablet/Mobile Visual QA를 강제합니다.
- **React + Vite 최적화**: 도메인 폴더 구조(`src/app`, `src/design-system`, `src/routes`, `src/features`, `src/shared`), 무워터폴 `@tanstack/react-router` `loader` 프리페치(`defaultPreloadStaleTime: 0`) + `@tanstack/react-query`, URL 동기화 `@tanstack/react-table`, UI 전용 `zustand`, `ky`(`signal` 전파), 정밀 기하학 Zero-CLS **Skeleton UI**를 구현합니다.

## 설치

```sh
git clone https://github.com/remorser58/react-design-system-skill.git
# Antigravity
mkdir -p ~/.gemini/config/skills
cp -R react-design-system-skill/skills/react-design-system ~/.gemini/config/skills/
# Claude Code
mkdir -p ~/.claude/skills
cp -R react-design-system-skill/skills/react-design-system ~/.claude/skills/
# Codex
mkdir -p ~/.codex/skills
cp -R react-design-system-skill/skills/react-design-system ~/.codex/skills/
```

## 감사 스크립트 및 스타터 템플릿

React + Vite 프로젝트에 대해 번들 정적 감사기(`bash 3.2+` 및 `jq` 필요)를 실행합니다:

```sh
bash skills/react-design-system/scripts/audit-react-ds.sh --root /path/to/react-vite-app --strict --json
```

`skills/react-design-system/assets/templates/` 포함 자산:

- `index.html` — Safe Area(`viewport-fit=cover`), 라이트/다크 `theme-color`, Apple 웹 앱 메타, OpenGraph, Twitter Card, FOUC 방지 스크립트
- `glass-and-motion.css` — `@theme static` 잠금, `.liquid-layers` / `.veil-*`, `.touch-slop`, `.pt-safe`/`.pb-safe`/`.px-safe`, coarse 16px 입력 하한, `motion-*` 유틸리티
- `storybook-preview.tsx` — Light/Dark 및 `data-platform` 툴바, Mobile/Tablet/Desktop 뷰포트, `<MotionConfig reducedMotion="user">`, `addon-a11y`
- `visual-qa-probe.js` — 가로 오버플로, 터치 타깃, coarse 입력 글꼴, 비오버레이 그림자, 이미지/버튼 접근성을 검증하는 브라우저 DOM/스타일 프로브

## 저장소 구성

```text
skills/react-design-system/
  SKILL.md, SKILL.ko.md        코어 계약 및 워크플로 (영문/한국어)
  rules/                       규범 규칙 (영문/한국어)
  references/                  horon-ai/expo-glass, 21st.dev 랜딩, React+Vite 청사진 (영문/한국어)
  scripts/audit-react-ds.sh    file:line 위반 리포트를 출력하는 엄격 정적 감사기
  assets/templates/            index.html, glass-and-motion.css, storybook-preview.tsx, visual-qa-probe.js
  assets/evals/                20건의 한/영/혼합 트리거·회귀 평가 케이스
tests/test_skill_package.py    오프라인 패키지 및 스크립트 회귀 테스트
.claude-plugin/                플러그인 및 마켓플레이스 매니페스트
```

## 개발

```sh
python3 -m unittest discover -s tests -p 'test_*.py' -v
```

## 라이선스

[MIT](LICENSE)
