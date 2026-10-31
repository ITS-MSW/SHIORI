# SHIORI web

Single-page TanStack Start landing page using React, TypeScript and Vite.

```sh
bun install
bun run dev
```

Open http://127.0.0.1:3000. Checks: `bun run typecheck` and `bun run lint`.

`src/routes/index.tsx` owns the page. Reusable UI and the three-note preview live in `src/components/`. The note deck mirrors the standard right-edge dock in `../Sources/SHIORI/EdgeDockController.swift`: 224 × 170 cards, 74-point overlap, 168-point hover travel, and native palette and motion timings from `SettingsStore.swift`. It also supports keyboard focus, Escape, touch selection and reduced motion. Checklist changes last for the current page session.

The supplied background is served locally from `public/background.png`. The download button uses the permanent latest-stable DMG URL and remains disabled until that release contains `SHIORI.dmg`. Follow [the release checklist](../docs/releases.md) for the one-time activation. Subsequent releases need no API or website deployment. The footer version is the desktop project's current 1.0.1.
