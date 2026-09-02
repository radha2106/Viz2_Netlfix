# 🎬 Netflix Analytics — Users, Viewership & Revenue Dashboard

## 🙋 About This Project
An end-to-end data analytics project simulating a Netflix-style streaming business: synthetic data generation in **Python**, a relational data model in **SQL Server**, and an interactive **Power BI** dashboard tracking subscribers, revenue, and content performance across US regions. Generated a realistic streaming-service dataset, model it properly in a relational database with data-integrity safeguards, and turn it into a report a regional or content lead could actually use.

🔗 **Live Dashboard:** [Live Dashboard](https://app.powerbi.com/view?r=eyJrIjoiYjZiMzVhZmUtNmNiOS00YWEwLWI5ZTItZGUzNTMzNTc3ZmY0IiwidCI6IjQ4MjkzMjgyLTgzMmQtNGQwYi05ZTBmLTVmMmFmYTg5YTFlNCIsImMiOjJ9)

---

## 📊 What the Dashboard Shows

The report has three pages, each answering a different business question:

| Page | What it's for |
|---|---|
| **Overview Summary** | The company-wide snapshot: total revenue, active users, total views, excellent-rating rate, and programs released — each with its year-over-year change. Below that, an active-users map by state and a monthly revenue trend (actual vs. last year). Filterable by year (2020–2025). |
| **All Region KPI Summary** | The same core metrics (revenue, users, views) broken out into four side-by-side panels — Central, North, West, South — each with its own mini state map and a daily-activity bar chart (Mon–Sun), so leadership can compare regional performance at a glance. |
| **All Programs Summary** | The content side of the business: total releases split by Movie vs. Show, releases by category (Reality, Thrillers, Documentaries, etc.), a monthly release trend by type, releases by language, a ratings breakdown (excellent/good/bad/none), and views by day split between bought vs. original content. |

---

## 🧱 How It's Built — Architecture

```
Python (synthetic data)  →  CSV files  →  SQL Server (schema, views, triggers)  →  Power BI (report)
```

Warehouse pattern project: dimension tables (who/what/when) feed fact tables (what actually happened), and SQL views do the regional roll-ups so Power BI stays fast.

### 1. Python — Data Generation (`all_viz2_python_codes.ipynb`)

There's no real subscriber data here — the notebook generates a realistic dataset from scratch, one CSV per business area:

- **Calendar** — a full daily calendar (year, month, week, quarter, week-start/end) built from a date range, plus Spanish month initials. This is the shared date backbone every other table joins to.
- **Programs** — generates 115–130 **(this number can be changed)** movies/shows, each randomly assigned an upload date, language, category, and production type (Movie/Show, Original/Bought). The category, language, and production lists themselves are fixed lookup lists rather than generated.
- **Users** — generates 400,000–800,000 subscribers **(this number can be changed)**, each with a random signup date, state, subscription plan, payment method, and device — using weighted random draws (`np.random.dirichlet`) so the mix isn't perfectly even, the way real customer data never is.
- **Renewals** — the trickiest piece: for every user, decides whether they renewed, how many times, and expands that into one row per renewal period with accurate start/end dates based on their plan's length — modeling a subscriber's full billing history rather than just a single snapshot.
- **Views** — generates 100,000–500,000 viewing events **(this number can be changed)**, matching each view to a user, program, device, and rating. Critically, it checks each event against the program's release date and the user's active subscription window, and drops any view that couldn't have actually happened (e.g. watching a show before it was released) — keeping the simulated data logically consistent.

### 2. SQL Server — Database (`viz2_table.sql`)

This script builds the `netflix` database under the `nfx` schema. In plain terms:

**Dimension tables** (the lookup data): `calendar`, `pays` (payment methods), `languages`, `devices`, `categories`, `plans` (subscription tier, price, and length in days), `production` (Movie/Show, Original/Bought), `rating`, and `states` (state code, name, and region — Central/North/South/West).

**Fact tables** (what actually happened):
- `programs` — one row per movie/show, linked to its language, category, and production type.
- `users` — one row per subscriber, linked to their state, plan, payment method, and device, with an account-status flag.
- `renewals` — one row per billing period per user (start date, end date, renewal status), letting the model track subscriber lifetime rather than just a signup date.
- `viewx` — one row per viewing event, linked to the user, the program watched, the device, and the rating given.

**Triggers** (automatic data-integrity checks on every insert into `viewx`):
- `check_scammer_view` — rolls back any view record where the viewing date is earlier than the program's release date. In other words: nobody can watch something before it exists.
- `scammer_active` — rolls back any view record tied to a user whose account status is inactive. Inactive accounts can't generate viewing activity.

**Views** — the layer Power BI reads from. The script defines the query pattern for the Central region (`central_users`, a per-user revenue/plan rollup, and `central_views`, a views/ratings rollup) and the same pattern is repeated for North, South, and West — giving each region its own pre-aggregated view tables instead of Power BI having to filter the full fact tables live on every click.

### 3. Power BI — Reporting Layer

The model's `Medidas` (Spanish for "Measures") table is where all the business logic lives, and it leans on a Power BI feature worth calling out: **named DAX functions** — real, reusable functions defined once and called everywhere, rather than the "copy-paste and tweak" pattern most DAX models use:

- **`udf.change_pct(measure)`** — takes any measure and returns its percentage change vs. the same period last year (via `SAMEPERIODLASTYEAR`). Every single "Last year change" figure on the dashboard — revenue, users, views, ratings, releases, across all four regions — calls this one function instead of having the year-over-year formula written out 20+ times.
- **`udf.revenue(price_column, start_column)`** — sums revenue using an inactive table relationship (`USERELATIONSHIP`) between the plan's start date and the calendar table, so revenue can be sliced by *when the plan started* without that relationship interfering with the rest of the model's date filtering.
- **`udf.color(measure)`** — returns green for a positive trend and red for a negative one, driving every red/green indicator next to a "last year change" figure.

On top of those functions, the measures table builds each region's numbers (`central_users`, `north_revenue`, `west_exc_rates`, etc.) individually, then rolls them up into company-wide totals (`all_total_users`, `all_total_revenue`, `all_total_views`) by simply adding the four regions together — plus a set of dynamic title measures that change their text depending on whether a specific state is selected or the whole region is being viewed.

---

## 🛠️ Tech Stack

- **Python** (pandas, numpy) — synthetic data generation
- **SQL Server (T-SQL)** — schema design, views, triggers, indexing
- **Power BI** — dashboard, DAX measures, and named functions

---

## 💡 Ideas for Future Enhancements

- **Regional drill-through** — the "Details coming soon" links on the Region KPI page are a natural next step: click into a region and land on a dedicated page with its own program/category breakdown.
- **Churn analysis** — use the `renewals` table's `rnw_status` field to build a churn-rate metric and flag states or plans with above-average cancellation.
- **Cohort retention view** — track how long users stay subscribed based on their signup month.
- **Content ROI** — combine `production` (original vs. bought) with `viewx` ratings to compare performance of in-house vs. licensed content.
- **Device/payment trend page** — a dedicated breakdown of how device and payment-method mix shifts over time.
- **Row-level security** — restrict each regional lead to their own region's data by default.

---

## 📁 Repo Structure

```
├── all_viz2_python_codes.ipynb   # Synthetic data generation (Calendar, Programs, Users, Renewals, Views)
├── viz2_table.sql                # Schema, indexes, triggers, and views (SQL Server)
└── README.md
```

## ⚠️ Known Limitations

This is a portfolio/demo project, so a few things are simplified on purpose:
- All data is synthetic — no real subscriber or viewing data is used.
- The script assumes a `BULK INSERT` step to load the generated CSVs (path left as a placeholder) — swap in your own file paths before running it.
- The North/South/West region views follow the same pattern as the Central region example in the script but need their filter values and table names updated individually.
- File paths in the notebook point to a local folder structure — update them to your own environment before running end to end.

---
