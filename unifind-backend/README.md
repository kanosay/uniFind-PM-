# UniFind – backend skeleton

Node.js + Express microservices behind an API gateway, PostgreSQL database seeded from the
Prague universities data set (26 universities, 141 faculties / academic units).
Implements PBS tasks 4.2 (backend skeleton), 4.4 (DB setup), 7.2–7.3 (models + seed) and the
foundations of 5 (auth), 6 (audit), 8–9, 11, 12.

## Quick start
```bash
docker compose up -d            # PostgreSQL 16 (or use your own and set DATABASE_URL)
cp .env.example .env
npm install
npm run db:migrate              # creates the schema
npm run db:seed                 # loads db/data/prague_universities_en.json (idempotent)
npm run dev                     # gateway :3000 + 6 services :3001–3006, auto-reload
npm test                        # end-to-end smoke test against the running stack
```
Set `ADMIN_EMAIL` / `ADMIN_PASSWORD` in `.env` before seeding to get a local admin account.
`npm run db:reset` drops everything and rebuilds.

## Structure
```
gateway/                 public entry point, /api/* → owning service (port 3000)
services/
  auth-service/          register, login, me, (google = 501)               :3001
  university-service/    list+filter+sort, detail, search, compare          :3002
  rating-service/        GET /university/:id/rating, reviews                :3003
  test-service/          major finder – SKELETON (501)                      :3004
  blog-service/          blog + comments – SKELETON (501)                   :3005
  audit-service/         GET /audit/list (admin)                            :3006
shared/                  config, db pool, errors, JWT auth/roles, audit writer, service bootstrap
db/                      migrations/, seed.js, migrate.js, data/ (source JSON)
```
Each service follows `routes.js` (HTTP) → `dao/*.js` (SQL) → `index.js` (bootstrap).

## Endpoints (all via gateway, prefix `/api`)
| Method | Path | Notes |
|---|---|---|
| GET | `/university/list` | `q, type, category, city, major, language, maxFee, sort=name\|units\|rating\|ranking, order, page, pageSize` |
| GET | `/university/:id` | with faculties/units and majors |
| GET | `/university/search?q=` | name, abbreviation, faculty or major |
| GET | `/university/compare?ids=1,2,3` | 2–4 universities side by side |
| GET | `/university/:id/rating` | global rankings + average rating (`rankedGlobally`, `reviewCount`) |
| GET | `/review/list?universityId=` | |
| POST | `/review/create` | auth; 1 review per user per university; audited |
| POST | `/auth/register`, `/auth/login` · GET `/auth/me` | JWT bearer; registration always creates a `student` |
| GET | `/audit/list` | admin only |
| GET | `/health` | aggregated service health |

Errors are always `{ "error": { "code", "message", "details?" } }`.

## Not done yet (stubbed or empty by design)
- **Google OAuth** (`GET /auth/google` → 501) – PBS 5.3.
- **Majors**: the data set has faculties, not study programmes, so table `major` is empty.
  Major / language / fee filters work but match nothing until it is filled (PBS 7.1).
- **Rankings**: sources QS/THE/ARWU are seeded, `ranking_entry` is empty (PBS 11.1/11.3).
  Until then `rankedGlobally` is false for everyone.
- **Test and blog services**: tables exist, routes return 501 (PBS 13, 14).
- Audit logging exists for register and review; add `writeAudit()` to future create/update/delete actions.

## Design notes
- Services share one PostgreSQL database for simplicity (the MVP is small). Each service only
  touches its own tables, apart from read-only joins for list sorting/rating; split the DB later if needed.
- Every service validates the JWT itself with the shared secret, so no service trusts the gateway blindly.
- `ranking` sort uses the best rank across sources (they are not strictly comparable) – revisit once data exists.
