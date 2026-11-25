# 레퍼런스 분해 및 무카드·무그림자 표면 규칙

**목적**: 4단계 레퍼런스 분해 프로토콜(Mobbin, UIBowl, Figma, Dribbble, Behance, Pinterest, 21st.dev, `horon-ai/design`)을 통해 모든 디자인 시스템과 UI를 실전 근거 위에 구축하되, CSS 컴파일러 수준에서 카드 남발과 장식용 그림자를 원천 차단합니다.

## 1. 4단계 레퍼런스 분해 프로토콜 ("파쿠리" 원칙)

- RDS-R-1: **1단계 — 출처 조합 수집(Harvest Mix)**: JSX를 작성하기 전 레이아웃 IA와 시각 완성도를 함께 확보하도록 출처 조합을 수집합니다:
  - **Mobbin & UIBowl (UX/IA 레퍼런스 2건)**: 실제 출시 앱의 정보 구조(IA), 화면 전환, 내비게이션 크롬, 바텀 시트, 필터 바, 빈/오류/로딩 상태, 모바일 조작감.
  - **Figma & `horon-ai/design` (토큰/시스템 레퍼런스 1건)**: 시맨틱 Color 쌍, Scale, Web/Desktop/Mobile 13단계 Typography, Glass/Veil 레이어, 컴포넌트 슬롯 해부도, variant 매트릭스.
  - **Dribbble, Behance & Pinterest (에디토리얼/시각 레퍼런스 1~2건)**: 헤드라인-본문 크기 비율, 네거티브 스페이스 비례, 비대칭 그리드, 톤 배경 대비, 챕터 호흡.
  - **21st.dev (랜딩/소개 레퍼런스)**: 히어로 아키타입, 애니메이션 헤드라인 리빌, 셰이더/앰비언트 캔버스 배경, 탭형 기능 소개, 요금제 토글, FAQ 아코디언, 전환 리듬.

- RDS-R-2: **2단계 — 정량 추출 시트(Quantitative Extraction Sheet)**: "깔끔함", "모던함" 같은 추상 형용사로 끝내지 않고 실측 수치를 기록합니다: 타입 스케일 비율(예: `display-lg 56 / body-md 16 = 3.5x`), 본문 최대 줄 길이(`55~70ch`), 간격 기본 단위(`4px`), 헤어라인 불투명도, 톤 배경 대비 차이, 모션 시간대, 터치 타깃 높이(`44px`), 첫 화면 요소 밀도.

- RDS-R-3: **3단계 — 저작권 및 독창성 가드**: 레이아웃 기하, 비례, 타이포 리듬, 인터랙션 메커니즘만 추상화합니다. 제3자 로고, 상표, 마스코트, 일러스트, 고유 카피는 모두 프로젝트 자체 자산으로 대체합니다.

## 2. 컴파일 잠금 기반 무카드·무그림자 표면 규율

- RDS-R-4: **카드 남발 금지(`Card` 제거)**. 페이지 섹션, KPI, 설정 그룹, 기능 항목, 요금제 열, 목록 행을 박스형 `<Card>` / `<CardHeader>` / `<CardContent>`로 감싸지 않고 다음 플랫 구조로 치환합니다:
  - KPI 스트립 -> `divide-x divide-border-default` + `tabular-nums`
  - 기능 그리드 -> 1px 헤어라인 격자(`border-t border-l` 부모 + `border-r border-b` 셀) 또는 오픈 여백 그리드
  - 요금제 열 -> 수직 1px 헤어라인 구분 + 추천 플랜에만 미세한 `bg-bg-subtle` 톤 전환 및 상단 1px 브랜드 헤어라인
  - 설정 / 활동 내역 / 테이블 -> `divide-y divide-border-default` 행과 충분한 여백·타이포 위계

- RDS-R-5: **장식용 그림자 금지(`box-shadow` 제거)**. 인라인 콘텐츠, 기능 목록, 요금제 열, 히어로 제품 데모 프레임, 데이터 테이블에 `shadow-sm`, `shadow-md`, `shadow-lg`, `shadow-xl`, `shadow-2xl` 및 임의 `box-shadow`를 사용하지 않습니다.

- RDS-R-6: **4단계 — 컴파일러 수준 `@theme static` 토큰 잠금**. Tailwind v4 CSS(`assets/templates/glass-and-motion.css`)의 `@theme static` 블록에서 `--color-*: initial; --radius-*: initial; --text-*: initial; --shadow-*: initial;`를 선언해 비승인 색상이나 Tailwind 기본 드롭 섀도우가 컴파일 단계에서 생성되지 않게 잠급니다.

- RDS-R-7: **드롭 섀도우 대신 Glass & Veil 오버레이**. 떠 있는 표면(탑바, 스티키 탭 트레이, 메뉴, 팝오버, 다이얼로그, 커맨드 팔레트)은 `LiquidGlass`(20px 블러, 1.8x 채도, 1px 마스크 수직 그라데이션 림) 또는 `Veil`(8px 블러, 1.6x 채도, 1px 링)을 사용하며 `prefers-reduced-transparency: reduce` 또는 `backdrop-filter` 미지원 시 `glass-fill-frost`로 폴백합니다. 분리된 불투명 오버레이(계정 메뉴, 커맨드 팔레트)에만 토큰 `--shadow-popover` / `--shadow-palette`를 예외적으로 허용합니다.

- RDS-R-8: **레이아웃 전용 호출부 `className`**. 시각 값은 디자인 토큰 한 곳에만 둡니다. 호출부의 `className`은 마진, 너비, flex/grid 배치, sticky 위치, 반응형 표시(`hidden md:flex`) 등 레이아웃 배치에만 사용하며 색·패딩·반경·그림자를 인라인으로 덮어쓰지 않습니다.

## Sources

> 확인 2026-11-26.

| 근거 항목 | 출처 |
|---|---|
| `@theme static` 리셋, 임의 `box-shadow` 금지, `LiquidGlass` / `Veil` 유리 레이어, 레이아웃 전용 `className` | `../references/horon-and-glass-patterns.ko.md`, <https://github.com/horon-ai/design> |
| 4단계 레퍼런스 분해 및 `21st.dev` 무카드·무그림자 변환 | `../references/landing-21st-dev-patterns.ko.md`, <https://21st.dev/> |
