# fraud-case-file

5 signals. 1 dead end. 1 thing I can't explain.

Synthetic betting platform, 59K users. I ran 5 SQL queries to find fraud signals. Here's the map:

| Signal | Fraud rate | Status |
|---|---|---|
| Disposable email domain | 37% | deployable |
| 5+ accounts per device | 92% | deployable |
| First deposit <1hr after signup | 7% | deployable |
| 2.9% of bonus $ → fraud | $25K leak | one-line fix |
| Payment method | flat (~3.8%) | dead end |
| First deposit >24h after signup | 2.85% | unexplained |

---

**Files:**
- [`case_file.md`](case_file.md) — the full log, in order, with the reasoning
- [`open_threads.md`](open_threads.md) — what I don't know yet and what I'd need to confirm it
- [`queries.sql`](queries.sql) — the 5 queries, with why I ran each one

---

*I got payment method wrong. Spent 20 min on it. The signal was attempt count, not channel. Would've checked device first.*   
