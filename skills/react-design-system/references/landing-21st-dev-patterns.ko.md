# 랜딩 및 소개 페이지 패턴 (`21st.dev`) 및 4단계 시각 레퍼런스 분해 가이드

## 목차

- [1. 크로스 플랫폼 레퍼런스 분해 매트릭스](#1-크로스-플랫폼-레퍼런스-분해-매트릭스)
- [2. 정량 레퍼런스 추출 시트 (2단계)](#2-정량-레퍼런스-추출-시트-2단계)
- [3. `21st.dev` 랜딩·소개 아키텍처 및 셰이더 가드레일](#3-21stdev-랜딩소개-아키텍처-및-셰이더-가드레일)
- [4. 구체적 Before -> After 무카드·무그림자 변환 레시피](#4-구체적-before---after-무카드무그림자-변환-레시피)
- [5. 랜딩 페이지 전용 Motion 안무(Choreography)](#5-랜딩-페이지-전용-motion-안무choreography)
- [Sources](#sources)

## 1. 크로스 플랫폼 레퍼런스 분해 매트릭스

UX/IA 레퍼런스 2건(Mobbin/UIBowl) + 토큰/시스템 1건(Figma/`horon-ai/design`) + 시각/에디토리얼 1~2건(Dribbble/Behance/Pinterest) + 랜딩용 `21st.dev`를 조합해 추출합니다:

| 출처 | 분석 대상 | React + Base UI 변환 방식 | 절대 복제 금지 항목 |
|---|---|---|---|
| **Mobbin** | 실제 출시된 웹/앱 플로우, 온보딩, 내비게이션 바, 바텀 시트, 빈/오류 상태 | 화면 IA -> `@tanstack/react-router` 라우트 트리 + Base UI `BottomSheet` / `Dialog` / `Tabs` | 브랜드 컬러, 고유 마스코트, 무거운 그림자 박스 셀 |
| **UIBowl** | 한국어 모바일 프로덕트 패턴, 핀테크/커머스 정보 밀도, 필터 바, 액션 행 | 간결한 한국어 마이크로카피 리듬, `keep-all` 줄바꿈, 44px 스티키 터치 액션 바 | 모든 목록 행을 감싸는 카드 테두리 |
| **Figma** | 토큰 변수 컬렉션(Color, Scale, Type, Glass), 오토 레이아웃 간격, variant prop | `src/design-system/tokens/*.ts` + `@theme static`으로 직접 매핑 | 반응형 제약 없는 고정 픽셀 프레임(`390px` 고정) |
| **Dribbble** | 디스플레이 타이포 대비, 에디토리얼 비대칭, 미세한 톤 배경 전환 | 헤드라인-본문 비율과 넉넉한 네거티브 스페이스 재현 | 가독성 떨어지는 Thin 굵기(<400) 또는 비반응형 아트보드 |
| **Behance** | 스토리텔링 리듬, 챕터 전환, 케이스 스터디 호흡 | 소개 페이지를 풀블리드/에디토리얼 그리드 챕터로 구성 | 네이티브 스크롤이나 `prefers-reduced-motion`을 깨는 과도한 스크롤 재킹 |
| **Pinterest** | 컬러 무드 보드, 그리드 비율, 에디토리얼 배치 | 1px 헤어라인으로 구분된 12열 CSS Grid로 치환 | 장식용 드롭 섀도우와 카드 안의 카드 중첩 |
| **21st.dev** | 히어로 섹션, 애니메이션 텍스트 리빌, 셰이더/오로라 배경, 탭형 기능 소개, 요금제 토글, FAQ | React + Vite + `@base-ui/react` + 독립 `motion/react` + 플랫/글래스 표면으로 이식 | Next.js 전용 `next/link`·`next/image`, `@radix-ui/*` / shadcn 래퍼, `shadow-lg` 카드 |

## 2. 정량 레퍼런스 추출 시트 (2단계)

토큰이나 JSX 작성 전 아래 정량 시트를 먼저 채웁니다:

| 측정 항목 | 추출 수치 (예시) | 대상 토큰 / CSS 매핑 |
|---|---|---|
| 타입 스케일 비율 (`display-lg / body-md`) | `56 / 16 = 3.5x` (모바일 `36 / 16 = 2.25x`) | `--text-display-lg`, `--text-body-md` |
| 본문 줄 길이(Measure) | 최대 `62ch` | `max-w-[62ch]` |
| 간격 리듬 | `4px` 기본; 섹션 간격 `48px~96px` | `gap-6`, `py-16 md:py-24` |
| 표면 분리 방식 | `1px` 헤어라인 + `bg-bg-subtle` (`#f3f4f5` vs `#ffffff`) | `border-border-default`, `divide-y` |
| 모션 시간대 | 프레스 `150ms`, 팝업 `200ms`, 히어로 스태거 `<= 450ms` | `motion-press`, `HeroHeadlineReveal` |
| Coarse 터치 타깃 높이 | `>= 44px` | `pointer-coarse:h-11` / `.touch-slop` |

## 3. `21st.dev` 랜딩·소개 아키텍처 및 셰이더 가드레일

`https://21st.dev/` (`hero`, `animated-hero`, `features`, `pricing-section`, `templates`, `shaders`) 구조 분석:

1. **텍스트 중심 에디토리얼 히어로**: 컴팩트 공지 필(글래스 또는 1px 헤어라인) -> 고대비 `display-lg`(`-0.03em`) -> 1~2줄 `body-lg` 리드 -> 주 CTA + `glass`/`link` 보조 CTA -> 로고 스트립.
2. **좌우 분할 카피 + 라이브 인터랙티브 데모**: 좌측(`lg:col-span-5`) 아이브로우, 핵심 가치, CTA 2개, `tabular-nums` 지표 3개; 우측(`lg:col-span-7`) 1px 헤어라인 또는 `LiquidGlass` 프레임 안에 배치한 라이브 React 인터랙티브 프리뷰.
3. **풀블리드 앰비언트 / 셰이더 히어로 가드레일**:
   - WebGL/Canvas 해상도 배율 상한을 `Math.min(window.devicePixelRatio, 1.5)`로 제한합니다.
   - `IntersectionObserver`로 화면 이탈 시 애니메이션 루프를 정지합니다.
   - `prefers-reduced-motion: reduce`에서는 정적 고대비 프레임을 렌더하고, 배경 위 텍스트 명도비 `>= 4.5:1`을 보장합니다.
4. **표준 섹션 리듬**: 스티키 `LiquidGlass` 탑바(`pt-safe`) -> 히어로 -> 로고 스트립 -> 탭형 인터랙티브 기능 소개(`@base-ui/react/tabs`) -> 헤어라인 지표/비교 표(`@tanstack/react-table` 또는 CSS Grid) -> 월간/연간 토글 요금제(`@base-ui/react/switch`) -> 후기 스트립 -> FAQ(`@base-ui/react/accordion`) -> 최종 CTA -> 정적 푸터(`pb-safe`).

## 4. 구체적 Before -> After 무카드·무그림자 변환 레시피

### A. 기능 그리드 (박스형 카드 -> 1px 헤어라인 매트릭스)
```tsx
{/* BEFORE (금지): <div className="grid gap-6 md:grid-cols-3">{items.map(i => <Card className="p-6 shadow-md">...</Card>)}</div> */}
{/* AFTER: 카드 0개, 그림자 0개, 1px 헤어라인 격자 */}
<div className="grid grid-cols-1 border-t border-l border-border-default md:grid-cols-3">
  {items.map((item) => (
    <div key={item.id} className="border-r border-b border-border-default p-6 md:p-8">
      <h3 className="text-title-sm text-text-primary">{item.title}</h3>
      <p className="mt-2 text-body-sm text-text-secondary">{item.description}</p>
    </div>
  ))}
</div>
```

### B. 요금제 열 (띄운 그림자 카드 -> 수직 헤어라인 열 + 톤 배경)
```tsx
{/* BEFORE (금지): <Card className="shadow-xl scale-105 border-2">...</Card> */}
{/* AFTER: 수직 1px 헤어라인 구분 + 추천 플랜에만 미세 톤 대비 */}
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

### C. Vite 정제 체크리스트
`"use client"`, `@radix-ui/*`, `next/image`, `next/link`, `next-themes`를 제거하고 표준 `<img>`(`loading="lazy"`, `width`/`height`, `alt`), `@tanstack/react-router` `<Link>`, 토큰 테마 훅으로 교체합니다.

## 5. 랜딩 페이지 전용 Motion 안무(Choreography)

모든 랜딩 애니메이션은 `src/design-system/motion/primitives.tsx`에 격리합니다(`<MotionConfig reducedMotion="user">` 필수):
- `HeroHeadlineReveal`: `--ease-out-quint`(`[0.22, 1, 0.36, 1]`) 기반 마스크 `y: 16 -> 0`, `opacity: 0 -> 1`, `once: true`.
- `StaggerGroup`: 50~70ms 스태거(총 지연 `<= 450ms`).
- `SharedTabIndicator`: Base UI `Tabs.Indicator` + CSS `motion-indicator`(280ms `--ease-emphasized`).
- `ScrollReveal`: `viewport={{ once: true, amount: 0.2 }}`에서 `opacity`와 `transform`만 사용.

## Sources

> 확인 2026-11-26.

| 근거 항목 | 출처 |
|---|---|
| `21st.dev` 히어로, 애니메이션 히어로, 기능, 요금제, 셰이더, 템플릿 패턴 | <https://21st.dev/> |
| 무카드·무그림자 Base UI 변환, `LiquidGlass`, `@theme static` 통합 | `../references/horon-and-glass-patterns.ko.md`, <https://github.com/horon-ai/design> |
