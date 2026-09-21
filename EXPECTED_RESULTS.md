# Expected SCA results — ground truth (Ruby, richer worst case)

Lock-less (no `Gemfile.lock`), so the scanner must generate one with `bundle
lock`. Every gem has a predictable outcome.

## Summary

| bucket | packages |
|--------|----------|
| Vulnerable | `rubyzip@1.2.1`, `rack@2.0.6`, `rake@12.3.0` (dev-scoped) |
| Healthy | `colorize@0.8.1` |
| Unresolved | none |

`local_widget` is a local `path:` gem (the repo's own code) and is excluded from
the resolved graph.

## Vulnerabilities
- **`rubyzip@1.2.1`** — directory traversal, `CVE-2018-1000544`, plus a second
  advisory. Production scope.
- **`rack@2.0.6`** — old, several advisories (timing attack, directory traversal,
  ReDoS, etc.). Production scope. Treat "3 or more, all for 2.0.6" as the pass.
- **`rake@12.3.0`** — command injection via `Rake::FileList`, `CVE-2020-8130`,
  fixed in 12.3.3. **Development scope** (see the classification test below).

## Healthy
- **`colorize@0.8.1`** — the range `~> 0.8.0` resolves to `0.8.1`, no advisories.

## Worst-case feature 1 — dev-group classification (the new thing to analyze)
`rake 12.3.0` sits in `group :development, :test`. A correct SCA must:
- resolve it and flag `CVE-2020-8130`, AND
- mark its `dependency_type` / scope as **DEV** (development), not production.

Watch the scope field on `rake`. If it says production/PROD, that is a
classification finding.

## Worst-case feature 2 — the local `path:` gem
`local_widget` lives under `vendor/local_widget`. Generation must copy it; if the
resolver skips it, `bundle lock` fails and every range-declared gem (colorize)
falls to **unresolved** with **0 vulnerabilities** — a false all-clear.

## Pass / fail
- PASS: rubyzip, rack, and rake vulnerable; rake marked DEV; colorize healthy at
  0.8.1; 0 unresolved.
- FINDINGS to flag: rake marked production, colorize unresolved (generation
  failed), 0 vulns (false all-clear), or any invented version.
