# Lock-less on purpose: there is NO Gemfile.lock committed, so the SCA scanner
# must GENERATE one (`bundle lock`) to learn exact versions and transitives.
source "https://rubygems.org"

# Exact pin to a KNOWN-VULNERABLE version (directory traversal). Zero runtime deps.
# Expected: reported as a VULNERABILITY, production scope.
gem "rubyzip", "1.2.1"

# Exact pin to a KNOWN-VULNERABLE version (several advisories). Zero runtime deps.
# Expected: reported as a VULNERABILITY (multiple CVEs), production scope.
gem "rack", "2.0.6"

# A RANGE (not an exact pin). Generation must resolve it to the latest 0.8.x
# (0.8.1), which has no known advisories. Zero runtime deps.
# Expected: reported as HEALTHY at version 0.8.1.
gem "colorize", "~> 0.8.0"

# WORST CASE: a development/test-group gem that is ALSO vulnerable. A correct SCA
# must resolve it AND classify it as a development dependency, not production.
# rake 12.3.0 has CVE-2020-8130 (command injection), fixed in 12.3.3. Zero deps.
group :development, :test do
  gem "rake", "12.3.0"
end


# New edge case: a `require: false` gem must still be resolved and scanned.
gem "dotenv", "2.7.0", require: false

# WORST CASE: a local `path:` gem. Its directory MUST be copied into the
# resolver's scratch dir or `bundle lock` aborts and the WHOLE generation fails.
# The gem is local code, not a registry dependency.
gem "local_widget", path: "vendor/local_widget"

# ---- Round 2 edge cases ----

# `ruby` directive with a requirement operator. Must not break `bundle lock`.
ruby ">= 2.5.0"

# KNOWN-VULNERABLE gem that pulls TRANSITIVES, one of which is ALSO vulnerable:
# rack-protection 2.0.0 (CVE-2018-1000119). Also pulls mustermann, tilt, and
# ruby2_keywords (all healthy). rack ~> 2.0 is satisfied by the pinned 2.0.6.
gem "sinatra", "2.0.0"

# Inline `group:` syntax (not a block). Healthy, zero deps, no Ruby upper
# bound (minitest 5.14.0 declared `ruby ~> 2.2`, which makes Bundler on Ruby 3.x
# refuse to resolve the WHOLE Gemfile). Must be classified DEV.
gem "diff-lcs", "1.5.0", group: :test

# Platform-restricted gem: skipped on Linux MRI. Must not break generation and
# must not be reported as unresolved.
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# ---- Round 3: dev-only transitives ----

# Test-group gem whose whole tree (rspec-core, rspec-expectations, rspec-mocks,
# rspec-support) is reachable from no production gem: every one must be DEV.
gem "rspec", "3.9.0", group: :test

# Test-group gem whose only dependency (rack) is ALSO a production gem: rack
# must stay PROD because a production dependency reaches it.
gem "rack-test", "0.6.3", group: :test
