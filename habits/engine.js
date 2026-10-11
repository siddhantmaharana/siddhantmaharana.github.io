/* Habit math: score, frequency auto-fill and streaks.
   A line-by-line port of habitkit/engine.py, itself a port of Loop Habit Tracker (uhabits-core, GPLv3).
   Pure functions of (habit, raw entries, today); nothing derived is stored.

   Dates are day numbers (days since 1970-01-01, UTC) so arithmetic never trips over time zones or DST.
   Entry values use Loop's encoding. Numerical values are stored x1000 (2.5 mi -> 2500). */
(function (root) {
  'use strict';

  const V = { UNKNOWN: -1, NO: 0, YES_AUTO: 1, YES_MANUAL: 2, SKIP: 3 };
  const MS_DAY = 86400000;

  const toDay = iso => Date.UTC(+iso.slice(0, 4), +iso.slice(5, 7) - 1, +iso.slice(8, 10)) / MS_DAY;
  const toIso = n => new Date(n * MS_DAY).toISOString().slice(0, 10);
  const localToday = () => { const d = new Date(); return Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()) / MS_DAY; };
  const parts = n => { const d = new Date(n * MS_DAY); return { y: d.getUTCFullYear(), m: d.getUTCMonth() + 1, d: d.getUTCDate() }; };
  const monthLen = n => { const p = parts(n); return new Date(Date.UTC(p.y, p.m, 0)).getUTCDate(); };

  /* habit: { type: 'yes_no'|'numerical', freq_num, freq_den, target_type: 'at_least'|'at_most', target_value } */
  function frequency(h) {
    let num = h.freq_num || 1, den = h.freq_den || 1;
    if (num === den) num = den = 1;
    return { num, den };
  }
  const isNumerical = h => h.type === 'numerical';

  // ------------------------------------------------------------------ score

  function computeScore(freq, previous, completion) {
    const m = Math.pow(0.5, Math.sqrt(freq) / 13.0);
    return previous * m + completion * (1.0 - m);
  }

  /* computed: Map(day -> {value, notes}). Returns Float64Array of scores for start..end. */
  function computeScores(h, computed, start, end) {
    if (start > end) return new Float64Array(0);
    let { num, den } = frequency(h);
    const freq = num / den, numerical = isNumerical(h), atMost = h.target_type === 'at_most';
    const target = h.target_value || 0;
    if (!numerical && freq < 1.0) { num *= 2; den *= 2; }

    const n = end - start + 1, values = new Array(n);
    for (let i = 0; i < n; i++) { const e = computed.get(start + i); values[i] = e ? e.value : V.UNKNOWN; }

    const out = new Float64Array(n);
    let rolling = 0, prev = (numerical && atMost) ? 1.0 : 0.0;
    for (let j = 0; j < n; j++) {
      const v = values[j], old = j - den >= 0 ? values[j - den] : null;
      if (numerical) {
        rolling += Math.max(0, v);
        if (old !== null) rolling -= Math.max(0, old);
        const total = rolling / 1000.0;
        if (v !== V.SKIP) {
          let pct;
          if (!atMost) pct = target > 0 ? Math.min(1.0, total / target) : 1.0;
          else if (target > 0) pct = Math.min(1.0, Math.max(0.0, 1.0 - (total - target) / target));
          else pct = total > 0 ? 0.0 : 1.0;
          prev = computeScore(freq, prev, pct);
        }
      } else {
        if (v === V.YES_MANUAL) rolling += 1;
        if (old === V.YES_MANUAL) rolling -= 1;
        if (v !== V.SKIP) prev = computeScore(freq, prev, Math.min(1.0, rolling / num));
      }
      out[j] = prev;
    }
    return out;
  }

  // ------------------------------------------------------------------ auto-fill (non-daily yes/no)

  function buildIntervals(freq, entries) {
    const yes = entries.filter(e => e.value === V.YES_MANUAL).map(e => e.day).sort((a, b) => b - a);
    const { num, den } = freq, out = [];
    for (let i = num - 1; i < yes.length; i++) {
      const begin = yes[i], center = yes[i - num + 1];
      let size = den;
      if (den === 30 || den === 31) size = parts(begin).d === monthLen(begin) ? monthLen(begin + 1) : monthLen(begin);
      if (center - begin < size) out.push({ begin, center, end: begin + size - 1 });
    }
    return out;
  }

  function snapIntervalsTogether(intervals) {
    const iv = intervals.map(x => ({ ...x }));
    for (let i = 1; i < iv.length; i++) {
      const curr = iv[i], next = iv[i - 1], gap = curr.end - next.begin;
      if (gap >= 0) {
        const shift = Math.min(curr.end - curr.center, gap + 1);
        iv[i] = { begin: curr.begin - shift, center: curr.center, end: curr.end - shift };
      }
    }
    return iv;
  }

  function buildEntriesFromIntervals(original, intervals) {
    const result = new Map();
    if (!original.length) return result;
    for (const iv of intervals) for (let d = iv.begin; d <= iv.end; d++) result.set(d, { value: V.YES_AUTO, notes: '' });
    for (const e of original) {
      const cur = result.get(e.day);
      const keep = cur === undefined || e.value === V.SKIP || e.value === V.YES_MANUAL;
      result.set(e.day, { value: keep ? e.value : V.YES_AUTO, notes: e.notes || '' });
    }
    for (const [d, e] of result) if (e.value === V.UNKNOWN && !e.notes) result.delete(d);
    return result;
  }

  /* entries: [{day, value, notes}] -> Map(day -> {value, notes}) with YES_AUTO filled in */
  function computeEntries(h, entries) {
    if (isNumerical(h)) return new Map(entries.map(e => [e.day, { value: e.value, notes: e.notes || '' }]));
    return buildEntriesFromIntervals(entries, snapIntervalsTogether(buildIntervals(frequency(h), entries)));
  }

  // ------------------------------------------------------------------ streaks

  function isSuccess(h, value) {
    if (isNumerical(h)) {
      if (h.target_type !== 'at_most') return value / 1000.0 >= h.target_value;
      return value !== V.UNKNOWN && value / 1000.0 <= h.target_value;
    }
    return value > 0;  // YES_AUTO, YES_MANUAL and SKIP keep a streak alive
  }

  function computeStreaks(h, computed, start, end) {
    const days = [...computed].filter(([d, e]) => d >= start && d <= end && isSuccess(h, e.value))
      .map(([d]) => d).sort((a, b) => b - a);
    if (!days.length) return [];
    const streaks = [];
    let sEnd = days[0], sBegin = days[0];
    for (const d of days.slice(1)) {
      if (d === sBegin - 1) sBegin = d;
      else { streaks.push({ start: sBegin, end: sEnd, length: sEnd - sBegin + 1 }); sBegin = sEnd = d; }
    }
    streaks.push({ start: sBegin, end: sEnd, length: sEnd - sBegin + 1 });
    return streaks;
  }

  // ------------------------------------------------------------------ one-shot analysis

  function analyze(h, entries, today) {
    const computed = computeEntries(h, entries);
    let start = today;
    for (const d of computed.keys()) if (d < start) start = d;
    const scores = computeScores(h, computed, start, today);
    const streaks = computeStreaks(h, computed, start, today);
    const value = d => { const e = computed.get(d); return e ? e.value : V.UNKNOWN; };
    return {
      today, start, computed, streaks, value,
      score: (d = today) => (d < start || d > today) ? 0 : scores[d - start],
      currentStreak: streaks.length && streaks[0].end >= today - 1 ? streaks[0].length : 0,
      bestStreak: streaks.reduce((m, s) => Math.max(m, s.length), 0),
    };
  }

  const api = { V, toDay, toIso, localToday, parts, frequency, isNumerical, computeScore, computeScores,
                computeEntries, computeStreaks, isSuccess, analyze };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.HabitEngine = api;
})(typeof self !== 'undefined' ? self : this);
