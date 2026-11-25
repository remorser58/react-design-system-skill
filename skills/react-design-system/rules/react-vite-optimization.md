# React + Vite Frontend Optimization and Stack Architecture Rules

**Purpose**: Minimize database/API round-trips, align TanStack Router preloading with TanStack Query freshness ownership, enforce a scalable React + Vite folder architecture, standardize on TanStack Table + Zustand + ky, and ship exact-geometry Skeleton UI.

## 1. Standard React + Vite Stack & Folder Architecture

- RDS-O-1: **Required React + Vite Library Stack**:
  - **`@tanstack/react-query`**: Single owner of server state, caching, background revalidation, query key factories, `keepPreviousData`, and optimistic mutations.
  - **`@tanstack/react-router`**: Type-safe routing, `validateSearch` URL state, dynamic `head()` OpenGraph, and route-level `loader` prefetching.
  - **`@tanstack/react-table`**: Headless table state (URL-synced sorting, filtering, cursor/page pagination, column visibility, row selection) rendered with flat 1px hairline dividers instead of heavy boxed cards.
  - **`zustand`**: Minimal client-only UI state (sidebar collapsed, active modal/drawer, density preference) — never duplicate server cache from TanStack Query inside Zustand.
  - **`ky`**: Configured HTTP client (`prefixUrl`, timeout, retry rules, `beforeRequest` auth hook, `afterResponse` error normalization, and `signal` cancellation forwarding).

- RDS-O-2: **Domain-Oriented Folder Structure**:
  - `src/app/` — App bootstrap, `QueryClient`, `createRouter`, `MotionConfig`, root error/suspense boundaries.
  - `src/design-system/` — `tokens/`, `primitives/` (`@base-ui/react`), `motion/` (`motion.css` + `motion/react`), `patterns/` (`DataTable`, `Skeleton`, `LiquidGlass`), `stories/` (`*.stories.tsx`).
  - `src/routes/` — TanStack Router route definitions with `validateSearch`, parallel `loader` prefetching, `pendingComponent`, and `head()`.
  - `src/features/<domain>/` — Co-located `api.ts` (`ky`), `queries.ts` (`queryOptions` + key factories), `components/`, `stores/` (`zustand` UI-only if needed), `types.ts`.
  - `src/shared/` — `lib/http.ts` (`ky` instance), `lib/cn.ts`, generic hooks, constants.

## 2. Router + Query Freshness Ownership & DB Round-Trip Minimization

- RDS-O-3: **Single Freshness Authority (`defaultPreloadStaleTime: 0`)**. Configure `createRouter({ defaultPreload: "intent", defaultPreloadStaleTime: 0, context: { queryClient } })` so TanStack Router never holds stale cache locks separately from TanStack Query. Inside route `loader`:
  - `await Promise.all([context.queryClient.ensureQueryData(...), ...])` for critical above-the-fold data (eliminates serial `useEffect` fetch waterfalls).
  - Fire unawaited `void context.queryClient.prefetchQuery(...)` for secondary below-the-fold panels so primary rendering is never blocked.

- RDS-O-4: **Cache Volatility Policy**:

| Data Volatility | `staleTime` | `gcTime` | Strategy |
|---|---|---|---|
| Reference / Taxonomy / Metadata | `10 * 60_000` (10m) | `30 * 60_000` | Reuse across route transitions without DB hits |
| Standard Lists & Tables | `60_000` (60s) | `10 * 60_000` | `placeholderData: keepPreviousData` on filter/page changes |
| Live Transactional / Counts | `5_000–15_000` | `5 * 60_000` | Targeted `invalidateQueries` on mutation settle |

- RDS-O-5: **Minimize DB Round-Trips at the API Boundary**:
  - Prefer aggregated BFF/page endpoints (1 request returning screen-ready DTOs) over chatty per-widget REST calls and N+1 list-item detail fetches.
  - Pass explicit field projections (`fields`/`select`), cursor-based pagination, and server-side filter/sort params for `@tanstack/react-table` rather than fetching full collections.
  - Always forward TanStack Query's `signal` to `ky(..., { signal })` so aborted navigations and fast filter typing cancel stale in-flight requests.
  - Use optimistic updates (`onMutate`: `cancelQueries` + snapshot + optimistic `setQueryData` -> `onError`: rollback -> `onSettled`: targeted `invalidateQueries`) for zero-latency perceived mutations.

## 3. URL-Synced Table, Suspense Boundaries & Exact-Geometry Skeleton UI

- RDS-O-6: **URL-Synced `@tanstack/react-table`**. Bind table `sorting`, `columnFilters`, and `pagination` state to TanStack Router `validateSearch` params (`manualSorting`, `manualFiltering`, `manualPagination`) with `keepPreviousData` so filtered links are shareable and page switches never flash empty states.

- RDS-O-7: **Exact-Geometry, Zero-CLS Skeleton UI & Granular Boundaries**. Keep static navigation shells outside loading gates; pair route `pendingComponent` and section `<Suspense>` + `<ErrorBoundary>` with design-system `Skeleton` compositions (`Skeleton`, `SkeletonRow`, `SkeletonTable`, `SkeletonText`) matching final heights, line counts, avatar sizes, and `max-sm:max-w-full`. Never replace whole layouts with jumping spinners.

- RDS-O-8: **Bundle & Render Hygiene**. Lazy-split heavy routes and optional charts/dialogs (`React.lazy` / TanStack Router `lazyRouteComponent`), virtualize large `@tanstack/react-table` row sets when exceeding ~100 visible rows, and keep Storybook/dev mocks strictly out of production bundles.

## Sources

> Checked 2026-11-26.

| Claim | Source |
|---|---|
| TanStack Router `defaultPreloadStaleTime: 0`, `ensureQueryData`, and `head()` integration | <https://tanstack.com/router/latest/docs/framework/react/guide/external-data-loading> |
| React + Vite folder layout, `ky` client, TanStack Query/Table, Zustand, Skeleton UI | `../references/react-vite-stack-blueprint.md` |
| Skeleton geometry matching and `@tanstack/react-table` flat design pattern | `../references/horon-and-glass-patterns.md`, <https://github.com/horon-ai/design> |
