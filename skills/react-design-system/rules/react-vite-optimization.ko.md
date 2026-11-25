# React + Vite 프론트엔드 최적화 및 스택 아키텍처 규칙

**목적**: 데이터베이스/API 왕복 횟수를 최소화하고, TanStack Router 프리로딩과 TanStack Query 신선도 소유권을 일치시키며, 확장 가능한 React + Vite 폴더 구조·TanStack Table·Zustand·ky·정밀 기하학 Skeleton UI를 구현합니다.

## 1. 표준 React + Vite 스택 및 폴더 아키텍처

- RDS-O-1: **필수 React + Vite 라이브러리 스택**:
  - **`@tanstack/react-query`**: 서버 상태, 캐싱, 백그라운드 재검증, 쿼리 키 팩토리, `keepPreviousData`, 낙관적 업데이트의 단일 소유자.
  - **`@tanstack/react-router`**: 타입 안전 라우팅, `validateSearch` URL 상태, 동적 `head()` OpenGraph, 라우트 단위 `loader` 프리페치.
  - **`@tanstack/react-table`**: Headless 테이블 상태(URL 동기화 정렬, 필터, 커서/페이지네이션, 열 표시, 행 선택)를 박스형 카드 대신 평탄한 1px 헤어라인 구분선으로 렌더링.
  - **`zustand`**: 최소한의 클라이언트 전용 UI 상태(사이드바 접힘, 모달/드로어 열림, 밀도 설정) — TanStack Query 서버 캐시를 Zustand에 절대 복제하지 않음.
  - **`ky`**: 공통 설정된 HTTP 클라이언트(`prefixUrl`, 타임아웃, 재시도 정책, `beforeRequest` 인증 훅, `afterResponse` 에러 정규화, `signal` 취소 전파).

- RDS-O-2: **도메인 중심 폴더 구조**:
  - `src/app/` — 앱 부트스트랩, `QueryClient`, `createRouter`, `MotionConfig`, 루트 에러/서스펜스 경계.
  - `src/design-system/` — `tokens/`, `primitives/` (`@base-ui/react`), `motion/` (`motion.css` + `motion/react`), `patterns/` (`DataTable`, `Skeleton`, `LiquidGlass`), `stories/` (`*.stories.tsx`).
  - `src/routes/` — `validateSearch`, 병렬 `loader` 프리페치, `pendingComponent`, `head()`를 포함한 TanStack Router 라우트 정의.
  - `src/features/<domain>/` — 도메인별 `api.ts`(`ky`), `queries.ts`(`queryOptions` + 키 팩토리), `components/`, `stores/`(필요 시 UI 전용 `zustand`), `types.ts`.
  - `src/shared/` — `lib/http.ts`(`ky` 인스턴스), `lib/cn.ts`, 공용 훅, 상수.

## 2. Router + Query 신선도 소유권 및 DB 왕복 횟수 최소화

- RDS-O-3: **단일 신선도 소유권 (`defaultPreloadStaleTime: 0`)**. `createRouter({ defaultPreload: "intent", defaultPreloadStaleTime: 0, context: { queryClient } })`를 설정해 TanStack Router가 TanStack Query와 별도로 낡은 캐시를 잠그지 않도록 합니다. 라우트 `loader` 내부에서는:
  - 첫 화면 핵심 데이터는 `await Promise.all([context.queryClient.ensureQueryData(...), ...])`로 병렬 페치해 직렬 `useEffect` 워터폴을 제거합니다.
  - 스크롤 아래 보조 패널 데이터는 `await` 없이 `void context.queryClient.prefetchQuery(...)`를 호출해 초기 렌더링을 막지 않습니다.

- RDS-O-4: **캐시 변동성 정책**:

| 데이터 변동성 | `staleTime` | `gcTime` | 전략 |
|---|---|---|---|
| 기준 정보 / 분류 / 메타데이터 | `10 * 60_000` (10분) | `30 * 60_000` | 라우트 이동 간 DB 재조회 없이 캐시 재사용 |
| 일반 목록 및 테이블 | `60_000` (60초) | `10 * 60_000` | 필터·페이지 전환 시 `placeholderData: keepPreviousData` |
| 실시간 트랜잭션 / 카운트 | `5_000–15_000` | `5 * 60_000` | 뮤테이션 완료 시 표적 `invalidateQueries` |

- RDS-O-5: **API 경계에서의 DB 왕복 최소화**:
  - 위젯별 개별 REST 호출이나 목록 행마다 상세 API를 쏘는 N+1 패턴 대신 화면 단위 집계 BFF 응답(1회 요청으로 화면용 DTO 반환)을 우선합니다.
  - 전체 컬렉션을 내려받지 말고 `@tanstack/react-table`용 필드 프로젝션(`fields`/`select`), 커서 기반 페이지네이션, 서버 측 필터/정렬 파라미터를 전달합니다.
  - 화면 이탈이나 빠른 필터 입력 시 진행 중인 구형 요청이 취소되도록 TanStack Query의 `signal`을 항상 `ky(..., { signal })`에 전달합니다.
  - 즉각적인 체감 성능을 위해 낙관적 업데이트(`onMutate`: `cancelQueries` + 스냅샷 + 낙관적 `setQueryData` -> `onError`: 롤백 -> `onSettled`: 표적 `invalidateQueries`)를 적용합니다.

## 3. URL 동기화 테이블, Suspense 경계 및 정밀 Skeleton UI

- RDS-O-6: **URL 동기화 `@tanstack/react-table`**. 테이블의 `sorting`, `columnFilters`, `pagination` 상태를 TanStack Router `validateSearch`와 연결하고(`manualSorting`, `manualFiltering`, `manualPagination` + `keepPreviousData`), 필터가 적용된 URL 공유와 깜빡임 없는 페이지 전환을 보장합니다.

- RDS-O-7: **정밀 기하학, Zero-CLS Skeleton UI 및 세분화된 경계**. 정적 내비게이션 셸은 로딩 경계 밖에 두어 즉시 렌더링하고, 라우트 `pendingComponent`와 섹션별 `<Suspense>` + `<ErrorBoundary>`에 실제 높이·줄 수·아바타 크기·`max-sm:max-w-full`과 일치하는 디자인 시스템 `Skeleton` 조합(`Skeleton`, `SkeletonRow`, `SkeletonTable`, `SkeletonText`)을 연결합니다. 레이아웃 시프트(CLS)를 유발하는 스피너 전체 교체를 금지합니다.

- RDS-O-8: **번들 및 렌더링 위생**. 무거운 라우트와 선택적 차트/다이얼로그는 지연 분할(`React.lazy` / TanStack Router `lazyRouteComponent`)하고, `@tanstack/react-table`이 약 100행 이상을 한 번에 렌더할 때는 가상화(virtualization)를 적용하며, Storybook/개발용 목업은 프로덕션 번들에서 배제합니다.

## Sources

> 확인 2026-11-26.

| 근거 항목 | 출처 |
|---|---|
| TanStack Router `defaultPreloadStaleTime: 0`, `ensureQueryData` 및 `head()` 통합 | <https://tanstack.com/router/latest/docs/framework/react/guide/external-data-loading> |
| React + Vite 폴더 구조, `ky` 클라이언트, TanStack Query/Table, Zustand, Skeleton UI | `../references/react-vite-stack-blueprint.ko.md` |
| Skeleton 기하학 일치 및 `@tanstack/react-table` 플랫 디자인 패턴 | `../references/horon-and-glass-patterns.ko.md`, <https://github.com/horon-ai/design> |
