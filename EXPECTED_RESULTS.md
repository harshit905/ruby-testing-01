# Expected SCA results — ground truth

This is what a **correct** SCA run must produce for this repo. Compare your
scan's `final_package_vulnerabilities_result.json` (or the frontend tabs)
against it.

## Summary counts

| bucket | count | packages |
|--------|-------|----------|
| Vulnerable | 2 | `rubyzip@1.2.1`, `rack@2.0.6` |
| Healthy | 1 | `colorize@0.8.1` |
| Unresolved | 0 | — |
| Total registry packages resolved | 3 | rubyzip, rack, colorize |

`local_widget` is a local path gem (the repo's own code), not a registry
dependency. It is sourced from a `path:`, so it is **excluded** from the
resolved-dependency graph and should appear in **none** of the three buckets. If
it shows up anywhere, that is a minor labeling issue, not a generation failure.

## Vulnerabilities — what to expect

- **`rubyzip@1.2.1`** — one advisory: directory traversal, `CVE-2018-1000544`
  (`GHSA-5m2v-hc64-56h6`), fixed in `1.2.2`. Severity high.
- **`rack@2.0.6`** — several advisories, because 2.0.6 is old. Expect multiple
  entries, likely including:
  - `CVE-2019-16782` — timing attack on session id (fixed 2.0.8).
  - `CVE-2020-8161` — directory traversal in `Rack::Directory`.
  - `CVE-2020-8184` — insufficient cookie validation.
  - `CVE-2022-30122` / `CVE-2022-30123` — ReDoS / possible shell escape in
    multipart parsing.

The **exact number** of rack advisories depends on the GitHub Advisory DB at
scan time, so treat "rack shows 3 or more advisories, all for version 2.0.6" as
the pass condition, not a fixed number.

## Healthy — what to expect

- **`colorize@0.8.1`** — the range `~> 0.8.0` resolves to `0.8.1` (the latest
  0.8.x). colorize has no known advisories, so it must appear under Healthy
  Packages at exactly `0.8.1`. This is the check that **range generation works**.

## The pass / fail judgment

**PASS (feature working):**
- `rubyzip@1.2.1` and `rack@2.0.6` appear as vulnerabilities.
- `colorize@0.8.1` appears as healthy.
- No package is reported at an invented version.

**FAIL — generation broke (e.g. the path gem was not copied):**
- Healthy count is `0`.
- `rubyzip`, `rack`, `colorize` all appear as **unresolved** with **no version**.
- **Zero vulnerabilities** are reported — because version-less packages are never
  advisory-checked. This is the important trap: "0 vulnerabilities" here would
  be a **false all-clear**, not a clean repo. A correct SCA must instead show 2
  vulns and 1 healthy.

**FAIL — versions were invented:**
- Any package shown at a version that does not match the rules above (for
  example colorize at something other than `0.8.1`, or a made-up transitive).

## Why this is a "worst case"

- **No committed lock** forces the generation path.
- **A local `path:` gem** would abort `bundle lock` if its directory were not
  copied into the resolver's scratch dir — the exact bug the copytree fix solves.
  If your SCA still resolves the three registry gems, that fix is holding.
- **A mix of exact pins and a range** checks that pins are honored and ranges are
  resolved, not guessed.
- **Two vulnerable + one healthy** checks that the vulnerable/healthy split is
  correct, and that a failed generation cannot masquerade as "all healthy / no
  vulns."
