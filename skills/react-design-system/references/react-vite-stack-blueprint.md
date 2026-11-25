# React + Vite Stack Blueprint (Safe Area, OpenGraph, TanStack, Zustand, ky, Skeleton, Storybook)

## Contents

- [1. Canonical React + Vite Folder Structure](#1-canonical-react--vite-folder-structure)
- [2. Static `index.html` & Dynamic Route `head()` OpenGraph + Safe Area](#2-static-indexhtml--dynamic-route-head-opengraph--safe-area)
- [3. `ky` Client, Router `defaultPreloadStaleTime: 0`, and Zero-Waterfall Loaders](#3-ky-client-router-defaultpreloadstaletime-0-and-zero-waterfall-loaders)
- [4. URL-Synced `@tanstack/react-table` & Optimistic Mutations + Zustand UI Store](#4-url-synced-tanstackreact-table--optimistic-mutations--zustand-ui-store)
- [5. Exact-Geometry Skeleton UI & Storybook Play/A11y Blueprint](#5-exact-geometry-skeleton-ui--storybook-playa11y-blueprint)
- [Sources](#sources)

## 1. Canonical React + Vite Folder Structure

```text
src/
  app/
    providers.tsx            # QueryClientProvider, MotionConfig reducedMotion="user", ToastProvider
    router.tsx               # createRouter({ routeTree, context: { queryClient }, defaultPreload: "intent", defaultPreloadStaleTime: 0 })
  design-system/
    tokens/                  # color.ts, typography.ts, scale.ts, glass.ts, motion.ts -> theme.css
    motion/
      motion.css             # From assets/templates/glass-and-motion.css
      primitives.tsx         # MotionConfig + FadeRise, StaggerGroup, HeroHeadlineReveal
    primitives/              # @base-ui/react wrappers (useRender, Drawer BottomSheet, Tabs, Dialog, ...)
    patterns/                # data-table.tsx, skeleton.tsx, liquid-glass.tsx, page-header.tsx
    stories/                 # *.stories.tsx with a11y + play functions
  routes/
    __root.tsx               # <HeadContent /> + safe-area top/bottom chrome + <Outlet />
    index.tsx                # Landing/Home route with loader prefetch & head()
    projects.tsx             # validateSearch + parallel loader + head() + pendingComponent
  features/
    <domain>/
      api.ts                 # ky endpoints (signal forwarding, field projection)
      queries.ts             # queryKey factory + queryOptions + optimistic mutations
      stores/ui-store.ts     # Zustand client-only UI state (never server cache)
      components/
      types.ts
  shared/
    lib/http.ts              # Configured ky instance
    lib/cn.ts                # clsx + tailwind-merge
    hooks/                   # useMediaQuery, useActiveIndicator, useCopyToClipboard
```

## 2. Static `index.html` & Dynamic Route `head()` OpenGraph + Safe Area

Use `assets/templates/index.html` for static fallback meta (`viewport-fit=cover`, light/dark `theme-color`, `og:*`, `twitter:card`, canonical, no-FOUC script) and `assets/templates/glass-and-motion.css` for `.pt-safe` / `.pb-safe` / `.px-safe` and unlayered coarse-pointer 16px input rules.

For dynamic per-route titles, descriptions, canonical links, and OpenGraph cards, define `head()` on TanStack Router routes and render `<HeadContent />` in `__root.tsx`:

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

## 3. `ky` Client, Router `defaultPreloadStaleTime: 0`, and Zero-Waterfall Loaders

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

// src/app/router.tsx — TanStack Query owns cache freshness (defaultPreloadStaleTime: 0)
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

## 4. URL-Synced `@tanstack/react-table` & Optimistic Mutations + Zustand UI Store

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

// Optimistic update: zero-latency UI with deterministic rollback
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

- **Zustand UI Store**: Keep only ephemeral UI state (`sidebarOpen`, `density`, `activeInspectorId`) with granular selectors (`useUiStore((s) => s.sidebarOpen)`). Never copy API responses into Zustand.
- **Route Loader + Table Sync**: Validate `cursor`, `q`, `sort` in `validateSearch`, pass them via `loaderDeps` to `loader` (`Promise.all([ensureQueryData(...), ...])` for critical data + `void prefetchQuery(...)` for secondary below-the-fold data), and wire `@tanstack/react-table` with `manualSorting` / `manualPagination` on a flat 1px hairline `overflow-x-auto` surface.

## 5. Exact-Geometry Skeleton UI & Storybook Play/A11y Blueprint

- **Skeleton UI**: Match final typography line-heights and row heights (`h-4` for `body-sm`, `h-11` for table rows, `rounded-xs` / `rounded-full`), wrap with `aria-busy="true"` and `max-sm:max-w-full`, and respect `prefers-reduced-motion`.
- **Storybook (`assets/templates/storybook-preview.tsx`)**: Configure Light/Dark & `data-platform` toolbars, Mobile/Tablet/Desktop viewports, `@storybook/addon-a11y`, and `play` interaction checks (`storybook/test`) on interactive stories.

## Sources

> Checked 2026-11-26.

| Claim | Source |
|---|---|
| `viewport-fit=cover`, Safe Area `env()`, `dvh`, iOS `16px` focus-zoom prevention, and Skeleton geometry | `../references/horon-and-glass-patterns.md`, <https://github.com/horon-ai/design> |
| TanStack Router `defaultPreloadStaleTime: 0`, `ensureQueryData`, and `head()` dynamic OpenGraph | <https://tanstack.com/router/latest/docs/framework/react/guide/document-head-management> |
| Starter templates (`index.html`, `glass-and-motion.css`, `storybook-preview.tsx`, `visual-qa-probe.js`) | `../assets/templates/index.html`, `../assets/templates/storybook-preview.tsx` |
