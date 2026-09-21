# SCA test repo #1 — Ruby, lock-less, worst case

A **controlled** test for the SCA lock-generation feature. It is deliberately
lock-less (no `Gemfile.lock`), so the scanner must generate one with `bundle
lock`. Every dependency is chosen to have a **predictable** outcome, so you can
compare your SCA's output against a known answer.

## What it declares (`Gemfile`)

| gem | spec | why it's here | expected outcome |
|-----|------|---------------|------------------|
| `rubyzip` | `1.2.1` (exact) | known-vulnerable, zero deps | **VULNERABLE** |
| `rack` | `2.0.6` (exact) | known-vulnerable, zero deps | **VULNERABLE** (multiple CVEs) |
| `colorize` | `~> 0.8.0` (range) | tests range resolution, zero deps | **HEALTHY** at `0.8.1` |
| `local_widget` | `path: vendor/local_widget` | worst case: local path gem | not a registry dep; must not break generation |

The three registry gems have **no runtime dependencies**, so the generated
`Gemfile.lock` has exactly those three and no transitive fan-out. That is what
makes the expected result exact.

See `EXPECTED_RESULTS.md` for the full ground truth and pass/fail criteria.

## How to run it

1. Create a new empty GitHub repo under your account, e.g. `harshit905/sca-test-ruby`.
2. From this folder: `git remote add origin <that repo URL>` then `git push -u origin main`.
3. Scan it in CodeAnt like your other forks.
4. Compare the SCA result against `EXPECTED_RESULTS.md`.

Do **not** commit a `Gemfile.lock`; the whole point is to test generation.
