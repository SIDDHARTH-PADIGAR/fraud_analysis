# Case File: Synthetic Betting Platform (59K users)

Not a report. A log of what I looked at, what surprised me, and what I still can't explain.

---

## First thing I checked: email domains

Expected. Disposable domains (mailnesia.com, tempmail.io) → 37% fraud.
Normal domains (gmail, yahoo) → ~1%. 40x gap.

This is the obvious signal. Anyone would find it first. Moving on.

## Second thing I checked: payment method

Went in expecting one method to be a red flag.
It isn't. Decline rates are flat: ~3.8% across card, UPI, bank, Apple Pay.

Spent 20 min on this before realizing the signal isn't the METHOD.
It's the COUNT of failed attempts in the first 24h. (See queries.sql, q06.)

Dead end. But a useful one — confirmed that method alone isn't a deployable rule.

## Third thing I checked: device sharing

This is where it gets interesting.

| Accounts per device | Fraud rate |
|---|---|
| 1 | 1.0% |
| 2 | 0.9% |
| 3-4 | 39.0% |
| 5+ | 92.3% |

The cliff is at 3. Below 3: normal (family, work/personal phone).
At 3+: it's a ring. The jump from 0.9% → 39% is the threshold.

My call: hard cap at 2. 3rd attempt on same device → block, not "review."
39% is too high to monitor. If I'm wrong, it's a one-line config change.

## Fourth thing I checked: speed to first deposit

| Time since signup | Fraud rate |
|---|---|
| < 1 hour | 7.07% |
| 1-6 hours | 2.08% |
| 6-24 hours | 0.99% |
| > 24 hours | 2.85% |

Fast = fraud. Makes sense. Fraudsters test the account immediately.

**But the >24h bucket is elevated (2.85%) and I don't know why.**
It breaks the pattern. My hypothesis: dormant account takeover.
Someone buys a real account that's been sitting for weeks, then activates it.
Can't confirm with this dataset — no per-transaction IP or device data.
Leaving it open. (See open_threads.md)

## Fifth thing I checked: bonus dollars

2.9% of all bonus money ($25,075 of $856,920) went to confirmed fraud accounts.
Pattern: claim promo → one tiny entry → withdraw → gone.

Fix: require a successful deposit before promo claim is unlocked.
One-line gate. Would have blocked most of the $25K.

---

## What I'd do with a real dataset (like CRED's)

Week 1: Run these same 5 checks against 90 days of actual signups.
See which signals are already covered by existing rules. Find the gaps.

Week 2: Pick the highest-impact gap. Ship a detection rule with eng.
Measure precision/recall against confirmed fraud. Tune threshold.
Target: <1% false positive rate on the new rule.

---

## What I got wrong

Payment method. I went in expecting it to matter. It doesn't.
The signal is attempt velocity, not payment channel.
Would've checked device sharing first. That's the highest-signal,
lowest-effort query. I did it third. Should've been first.   
