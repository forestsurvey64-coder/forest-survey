# FOREST Survey — Implementation Plan

## What We're Building

Internal webapp for FOREST (hotel linen supplier) to replace a Google Sheet. Vendors generate pre-filled Tally form links to send to hotel clients via WhatsApp for satisfaction surveys. The app enforces a "don't contact before 6 months" rule.

**Not in scope:** receiving responses, computing metrics, authentication.

---

## Stack

- Elixir 1.17+ / Phoenix 1.7+ with LiveView
- Ash Framework 3.x (all domain logic)
- AshPostgres → **Neon** (free-tier PostgreSQL)
- AshPhoenix (LiveView form integration)
- Tailwind CSS + DaisyUI 4.x
- No authentication (internal tool)

---

## Domain Model

| Resource | Table | Key fields |
|---|---|---|
| `Surveys.Vendor` | `vendors` | name, team, email, whatsapp, active |
| `Surveys.Client` | `clients` | name, zone, main_contact, whatsapp, active |
| `Surveys.GeneratedLink` | `generated_links` | full_url, status (pending/sent/responded/dismissed), sent_at, vendor_id, client_id |
| `Surveys.Config` | `survey_configs` | tally_base_url, min_recontact_months (default 6) |

### 6-Month Rule
Before generating a link, check the most recent `GeneratedLink` for that client:
- No previous link → **allowed** (first contact)
- Link exists, months elapsed ≥ `min_recontact_months` → **allowed**
- Link exists, months elapsed < threshold → **blocked** (show wait message)

### URL Generation
```
{tally_base_url}?agent={URI.encode_www_form(vendor.name)}&client={URI.encode_www_form(client.name)}
```

---

## Routes

```
GET  /                          GeneratorLive     (main page)
GET  /history                   HistoryLive       (all generated links)
GET  /admin/vendors             VendorsLive
GET  /admin/vendors/new         VendorsLive :new
GET  /admin/vendors/:id/edit    VendorsLive :edit
GET  /admin/clients             ClientsLive
GET  /admin/clients/new         ClientsLive :new
GET  /admin/clients/:id/edit    ClientsLive :edit
GET  /admin/config              ConfigLive
```

---

## UI

- **Theme:** DaisyUI custom theme "forest" — primary `#1FB5C0` (teal), success/info `#4DBFA8` (mint), error `#E97A6D` (coral)
- **Fonts:** Cormorant Garamond (headings, serif) + Inter (body)
- **Navbar:** FOREST logo + nav links (Home · History · Vendors · Clients · Config)
- **Mobile-first:** vendors use it from phones during client visits

### Generator Page States

| State | Condition | UI |
|---|---|---|
| A — First contact | No previous link | ✅ green card, "Generar link" button |
| B — Allowed (6+ months) | Last link ≥ threshold months ago | ✅ green card, shows last contact date |
| C — Blocked | Last link < threshold months ago | 🚫 red card, shows wait time and available date |

Link is created in DB **only when user clicks "Generar link"** (not on select change).

---

## Implementation Progress

### Phase 1 — Ash Domain & Resources ✅
- [x] `lib/forest_survey/surveys/surveys.ex` — Ash.Domain (with AshPhoenix extension)
- [x] `lib/forest_survey/surveys/vendor.ex`
- [x] `lib/forest_survey/surveys/client.ex`
- [x] `lib/forest_survey/surveys/generated_link.ex`
- [x] `lib/forest_survey/surveys/config.ex`
- [x] Register domain in `config/config.exs`
- [x] `lib/forest_survey/repo.ex` — AshPostgres with `min_pg_version` and `installed_extensions`

### Phase 2 — Migrations ✅
- [x] Run `mix ash.codegen initial_surveys_domain` (migrations generated)
- [ ] Run `mix ash_postgres.create && mix ash_postgres.migrate` (run when DB is available)

### Phase 3 — Seeds ✅
- [x] `priv/repo/seeds.exs` — 5 vendors, 15 hotel clients, 1 Config row

### Phase 4 — Router ✅
- [x] LiveView routes added
- [x] React/RPC scaffolding routes removed

### Phase 5 — Layout & Theme ✅
- [x] Google Fonts (Cormorant Garamond + Inter) in `root.html.heex`
- [x] FOREST Navbar + Footer in `layouts.ex` (responsive drawer)
- [x] DaisyUI "forest" theme in `app.css`

### Phase 6 — LiveViews ✅
- [x] `GeneratorLive` — vendor/client selects, A/B/C result card, "Generar link" button, CopyToClipboard hook
- [x] `HistoryLive` — table with filters and pagination
- [x] `VendorsLive` — CRUD with modal (AshPhoenix.Form)
- [x] `ClientsLive` — CRUD with modal (AshPhoenix.Form)
- [x] `ConfigLive` — singleton form

### Phase 7 — Tests ✅
- [x] `test/forest_survey/surveys/six_month_rule_test.exs`
  - Client with no history → allowed (first contact)
  - Client with 7-month-old link → allowed
  - Client with 3-month-old link → blocked
  - Custom `min_recontact_months` respected

### Phase 8 — Verify
- [x] `mix compile` — clean, no errors
- [ ] `mix ash_postgres.create && mix ash_postgres.migrate`
- [ ] `mix run priv/repo/seeds.exs`
- [ ] `mix test`
- [ ] `mix phx.server` — smoke test all pages

---

## Key Files

| File | Purpose |
|---|---|
| `lib/forest_survey/surveys/` | All Ash resources + domain |
| `lib/forest_survey_web/live/` | All LiveView pages |
| `assets/css/app.css` | DaisyUI theme |
| `assets/js/hooks/copy_to_clipboard.js` | JS clipboard hook |
| `priv/repo/seeds.exs` | Seed data |
| `config/runtime.exs` | `DATABASE_URL` for Neon in prod |

---

## Environment Variables (Production)

| Variable | Description |
|---|---|
| `DATABASE_URL` | Neon connection string (postgres://...) |
| `SECRET_KEY_BASE` | Phoenix secret (generate with `mix phx.gen.secret`) |
| `PHX_HOST` | Production hostname |
| `PORT` | HTTP port (default 4000) |
