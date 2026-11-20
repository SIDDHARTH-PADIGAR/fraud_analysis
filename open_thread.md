## Things I don't know yet

1. The >24h anomaly
   2.85% fraud rate, higher than the 1-6h bucket.
   Hypothesis: dormant account takeover.
   What I'd need to confirm: per-transaction IP + device data,
   account age distribution of the flagged users,
   whether the first transaction after dormancy is a withdrawal or a deposit.

2. The 3-4 device bucket (39%)
   Is it all fraud? Or is some of it "power users" who share a family tablet?
   What I'd need: account age, geographic spread of the accounts on one device.
   If all accounts on one device are in the same city → likely fraud.
   If spread across 3 states → probably a shared household device.

3. Chargeback timing
   I haven't looked at the time gap between deposit and chargeback.
   Instant chargeback (same hour) = "I didn't do this."
   Delayed chargeback (3-7 days) = "the goods didn't arrive."
   Different fraud types. Haven't split them yet.   
