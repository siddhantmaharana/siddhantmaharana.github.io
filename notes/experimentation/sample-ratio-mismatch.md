---
title: Sample Ratio Mismatch
topic: experimentation
tags: [ab-testing, stats]
date: 2026-07-16
draft: true
summary: What SRM is, why it happens, and why it invalidates a test before you even look at results.
---

Sample Ratio Mismatch (SRM) is when the observed split of users across experiment
arms deviates from the intended split (e.g. 48/52 instead of 50/50) by more than
chance would explain.

Why it matters: if the randomization itself is broken, any downstream metric
comparison is suspect — you're no longer comparing like-for-like populations,
regardless of what the p-value on the primary metric says.

Common causes:
- Bucketing logic bug (e.g. hashing on a non-uniform key)
- Bot/crawler traffic hitting one arm disproportionately
- Client-side assignment with a leaky redirect or caching layer

Check with a simple chi-squared goodness-of-fit test against the expected ratio.
See also [[Chi-Squared Test for Proportions]] for the mechanics.

This is one of the first things I check before trusting any experiment readout —
related to [[Why I Distrust Day-One Experiment Results]].
