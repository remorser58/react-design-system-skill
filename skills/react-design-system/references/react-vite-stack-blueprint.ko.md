# React + Vite 스택 청사진 (Safe Area, OpenGraph, TanStack, Zustand, ky, Skeleton, Storybook)

## 목차

- [1. 표준 React + Vite 폴더 구조](#1-표준-react--vite-폴더-구조)
- [2. 정적 `index.html` 및 라우트별 동적 `head()` OpenGraph + Safe Area](#2-정적-indexhtml-및-라우트별-동적-head-opengraph--safe-area)
- [3. `ky` 클라이언트, 라우터 `defaultPreloadStaleTime: 0` 및 무워터폴 로더](#3-ky-클라이언트-라우터-defaultpreloadstaletime-0-및-무워터폴-로더)
- [4. URL 동기화 `@tanstack/react-table`, 낙관적 업데이트 및 Zustand UI 스토어](#4-url-동기화-tanstackreact-table-낙관적-업데이트-및-zustand-ui-스토어)
- [5. 정밀 기하학 Skeleton UI 및 Storybook Play/A11y 청사진](#5-정밀-기하학-skeleton-ui-및-storybook-playa11y-청사진)
- [Sources](#sources)

## 1. 표준 React + Vite 폴더 구조

```text
src/
  app/
    providers.tsx            # QueryClientProvider, MotionConfig reducedMotion="user", ToastProvider
    router.tsx               # createRouter({ routeTree, context: { queryClient }, defaultPreload: "intent", defaultPreloadStaleTime: 0 })
  design-system/
    tokens/                  # color.ts, typography.ts, scale.ts, glass.ts, motion.ts -> theme.css
    motion/
      motion.css             # assets/templates/glass-and-motion.css 기반
      primitives.tsx         # MotionConfig + FadeRise, StaggerGroup, HeroHeadlineReveal
    primitives/              # @base-ui/react 래퍼 (useRender, Drawer BottomSheet, Tabs, Dialog, ...)
    patterns/                # data-table.tsx, skeleton.tsx, liquid-glass.tsx, page-header.tsx
    stories/                 # a11y + play 함수 포함 *.stories.tsx
  routes/
    __root.tsx               # <HeadContent /> + 상하단 Safe Area 크롬 + <Outlet />
    index.tsx                # loader 프리페치 및 head() 포함 랜딩/홈 라우트
    projects.tsx             # validateSearch + 병렬 loader + head() + pendingComponent
  features/
    <domain>/
      api.ts                 # ky 엔드포인트 (signal 전파, 필드 프로젝션)
      queries.ts             # queryKey 팩토리 + queryOptions + 낙관적 뮤테이션
      stores/ui-store.ts     # Zustand 클라이언트 전용 UI 상태 (서버 캐시 저장 금지)
      components/
      types.ts
  shared/
    lib/http.ts              # 공통 설정된 ky 인스턴스
    lib/cn.ts                # clsx + tailwind-merge
    hooks/                   # useMediaQuery, useActiveIndicator, useCopyToClipboard
```

## 2. 정적 `index.html` 및 라우트별 동적 `head()` OpenGraph + Safe Area

정적 폴백 메타(`viewport-fit=cover`, 라이트/다크 `theme-color`, `og:*`, `twitter:card`, canonical, FOUC 방지 스크립트)는 `assets/templates/index.html`을 사용하고, `.pt-safe` / `.pb-safe` / `.px-safe` 및 레이어 밖 coarse 포인터 16px 입력 규칙은 `assets/templates/glass-and-motion.css`를 사용합니다.

라우트별 동적 제목, 설명, canonical 링크, OpenGraph 카드는 TanStack Router의 `head()`로 정의하고 `__root.tsx`에 `<HeadContent />`를 마운트합니다:

```tsx
// src/routes/__root.tsx
import { HeadContent, Outlet, createRootRouteWithContext } from "@tanstack/react-router";
import type { QueryClient } from "@tanstack/react-query";

export const Route = createRootRouteWithContext<{ queryClient: QueryClient }>()({
  component: () => (
    <>
      <HeadContent />
      <Outlet />
    </>
  ),
});
```

## 3. `ky` 클라이언트, 라우터 `defaultPreloadStaleTime: 0` 및 무워터폴 로더

```ts
// src/shared/lib/http.ts
import ky from "ky";

export const http = ky.create({
  prefixUrl: import.meta.env.VITE_API_BASE_URL,
  timeout: 10_000,
  retry: { limit: 2, methods: ["get", "head"], statusCodes: [408, 429, 502, 503, 504] },
  hooks: {
    beforeRequest: [
      (request) => {
        const token = sessionStorage.getItem("access_token");
        if (token) request.headers.set("Authorization", `Bearer ${token}`);
      },
    ],
  },
});

// src/app/router.tsx — TanStack Query가 캐시 신선도를 단독 소유(defaultPreloadStaleTime: 0)
import { QueryClient } from "@tanstack/react-query";
import { createRouter } from "@tanstack/react-router";
import { routeTree } from "../routeTree.gen";

export const queryClient = new QueryClient({
  defaultOptions: { queries: { staleTime: 60_000, gcTime: 10 * 60_000, retry: 1 } },
});

export const router = createRouter({
  routeTree,
  context: { queryClient },
  defaultPreload: "intent",
  defaultPreloadStaleTime: 0,
});
```

## 4. URL 동기화 `@tanstack/react-table`, 낙관적 업데이트 및 Zustand UI 스토어

```tsx
// src/features/projects/queries.ts
import { keepPreviousData, queryOptions, useMutation, useQueryClient } from "@tanstack/react-query";
import { http } from "@/shared/lib/http";

export const projectKeys = {
  all: ["projects"] as const,
  list: (filters: { cursor?: string; q?: string; sort?: string }) =>
    [...projectKeys.all, "list", filters] as const,
};

export const projectListOptions = (filters: { cursor?: string; q?: string; sort?: string }) =>
  queryOptions({
    queryKey: projectKeys.list(filters),
    queryFn: ({ signal }) =>
      http.get("projects", { searchParams: { ...filters, fields: "id,name,status,updatedAt" }, signal }).json(),
    placeholderData: keepPreviousData,
    staleTime: 60_000,
  });

// 낙관적 업데이트: 결정적 롤백을 포함한 즉각적 UI 반영
export function useRenameProject(filters: { cursor?: string; q?: string; sort?: string }) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, name }: { id: string; name: string }) =>
      http.patch(`projects/${id}`, { json: { name } }).json(),
    onMutate: async ({ id, name }) => {
      await qc.cancelQueries({ queryKey: projectKeys.list(filters) });
      const prev = qc.getQueryData(projectKeys.list(filters));
      qc.setQueryData(projectKeys.list(filters), (old: any) =>
        old ? { ...old, items: old.items.map((p: any) => (p.id === id ? { ...p, name } : p)) } : old,
      );
      return { prev };
    },
    onError: (_err, _vars, ctx) => {
      if (ctx?.prev) qc.setQueryData(projectKeys.list(filters), ctx.prev);
    },
    onSettled: () => qc.invalidateQueries({ queryKey: projectKeys.all }),
  });
}
```

- **Zustand UI 스토어**: 휘발성 UI 상태(`sidebarOpen`, `density`, `activeInspectorId`)만 저장하고 세분화된 셀렉터(`useUiStore((s) => s.sidebarOpen)`)로 구독합니다. API 응답을 Zustand에 복제하지 않습니다.
- **라우트 로더 + 테이블 동기화**: `validateSearch`로 `cursor`, `q`, `sort`를 검증하고 `loaderDeps`를 통해 `loader`(`Promise.all([ensureQueryData(...), ...])` + 스크롤 아래 보조 패널용 비대기 `void prefetchQuery(...)`)로 전달한 뒤 `overflow-x-auto` 1px 헤어라인 표면 위 `@tanstack/react-table`(`manualSorting` / `manualPagination`)과 연결합니다.

## 5. 정밀 기하학 Skeleton UI 및 Storybook Play/A11y 청사진

- **Skeleton UI**: 최종 타이포 줄 높이와 행 높이(`body-sm`은 `h-4`, 테이블 행은 `h-11`, `rounded-xs` / `rounded-full`)를 일치시키고 `aria-busy="true"`와 `max-sm:max-w-full`을 부여하며 `prefers-reduced-motion`을 준수합니다.
- **Storybook (`assets/templates/storybook-preview.tsx`)**: Light/Dark 및 `data-platform` 툴바, Mobile/Tablet/Desktop 뷰포트, `@storybook/addon-a11y`, 인터랙티브 스토리용 `play` 테스트(`storybook/test`)를 구성합니다.

## Sources

> 확인 2026-11-26.

| 근거 항목 | 출처 |
|---|---|
| `viewport-fit=cover`, Safe Area `env()`, `dvh`, iOS `16px` 포커스 줌 방지, Skeleton 기하학 | `../references/horon-and-glass-patterns.ko.md`, <https://github.com/horon-ai/design> |
| TanStack Router `defaultPreloadStaleTime: 0`, `ensureQueryData`, `head()` 동적 OpenGraph | <https://tanstack.com/router/latest/docs/framework/react/guide/document-head-management> |
| 스타터 템플릿(`index.html`, `glass-and-motion.css`, `storybook-preview.tsx`, `visual-qa-probe.js`) | `../assets/templates/index.html`, `../assets/templates/storybook-preview.tsx` |
