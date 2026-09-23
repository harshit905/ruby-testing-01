# Expected SCA results — ground truth (Ruby, richer worst case)

Lock-less (no `Gemfile.lock`), so the scanner must generate one with `bundle
lock`. Every gem has a predictable outcome.

## Summary

| bucket | packages |
|--------|----------|
| Vulnerable | `rubyzip@1.2.1`, `rack@2.0.6`, `rake@12.3.0` (dev-scoped), `sinatra@2.0.0`, `rack-protection@2.0.0` (transitive) |
| Healthy | `colorize@0.8.1`, `dotenv@2.7.0`, `diff-lcs@1.5.0` (dev), `mustermann@1.1.2`, `ruby2_keywords@0.0.5`, `tilt@2.x` (transitives) |
| Unresolved | none |

`tzinfo-data` is platform-restricted (Windows/JRuby) and is absent from the
resolved specs on Linux (or healthy if listed from DEPENDENCIES; either is fine).

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

## New edge case (regression re-test) — `require: false` gem
The Gemfile adds `gem "dotenv", "2.7.0", require: false`.
- **PASS:** `dotenv@2.7.0` is resolved and healthy (the `require: false` modifier
  does not stop it being scanned).

## Round 2 edge cases

### A. Vulnerable gem with a vulnerable transitive (`sinatra 2.0.0`)
- **`sinatra@2.0.0`** — direct, vulnerable (`CVE-2018-7212` path traversal and
  `CVE-2018-11627` XSS, fixed 2.0.2; `CVE-2022-29970`, fixed 2.2.0;
  `CVE-2022-45442`, fixed 3.0.4).
- **`rack-protection@2.0.0`** — pinned `= 2.0.0` by sinatra, transitive,
  vulnerable (`CVE-2018-1000119` timing attack, fixed 2.0.1).
- **`mustermann@1.1.2`**, **`ruby2_keywords@0.0.5`**, **`tilt@2.x`** — healthy
  transitives. (`rack ~> 2.0` is satisfied by the existing `rack@2.0.6`.)
- **PASS:** sinatra AND rack-protection vulnerable; rack-protection marked
  transitive; the three healthy transitives present.
- **FAIL:** rack-protection missing (no transitive discovery) or healthy.

### B. Inline group syntax (`gem "diff-lcs", "1.5.0", group: :test`)
- **PASS:** `diff-lcs@1.5.0` healthy, scope **DEV**.
- **FAIL:** marked production (only the block form of `group` is parsed).

Note (Sep 23 2026 scan): the first round-2 push used `minitest 5.14.0`, whose
gemspec requires `ruby ~> 2.2`. On the scanner's Ruby 3.3 Bundler refuses to
resolve the whole Gemfile, so every range fell to unresolved and no transitives
appeared. That was a fixture bug, replaced by diff-lcs. It did expose two scanner
behaviours: a failed `bundle lock` is silent (stderr is not logged), and the
textual fallback classifies an inline `group: :test` gem as PROD.

### C. Platform-restricted gem (`tzinfo-data`, Windows/JRuby only)
- **PASS:** generation succeeds; tzinfo-data absent or healthy; never
  unresolved.
- **FAIL:** whole generation fails, or tzinfo-data reported unresolved.

### D. `ruby ">= 2.5.0"` directive
- **PASS:** ignored by the scanner, `bundle lock` succeeds.
- **FAIL:** generation fails on the directive (e.g. the resolver's Ruby is
  rejected), giving 0 healthy / unresolved ranges / 0 vulns.

### Round 2 pass / fail (combined)
- PASS: 5 vulnerable (rubyzip, rack, rake dev, sinatra, rack-protection
  transitive); colorize, dotenv, diff-lcs dev, mustermann, ruby2_keywords, tilt
  healthy; 0 unresolved.

## Round 3 edge cases — dev-only transitives

### A. Transitives only a test-group gem pulls in (`rspec 3.9.0`, test)
- **PASS:** `rspec@3.9.0` healthy **DEV** direct; `rspec-core@3.9.x`,
  `rspec-expectations@3.9.x`, `rspec-mocks@3.9.x`, `rspec-support@3.9.x` healthy
  **DEV** transitives.
- **FAIL:** any rspec-* transitive marked PROD.

### B. A transitive shared with a production gem (`rack-test 0.6.3`, test)
`rack-test` (dev) depends on `rack`, which is also a production gem.
- **PASS:** `rack-test@0.6.3` healthy **DEV** direct; `rack@2.0.6` stays
  **PROD** (a production dependency reaches it).
- **FAIL:** `rack` flips to DEV.
