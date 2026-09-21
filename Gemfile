# Lock-less on purpose: there is NO Gemfile.lock committed, so the SCA scanner
# must GENERATE one (`bundle lock`) to learn exact versions and transitives.
source "https://rubygems.org"

# Exact pin to a KNOWN-VULNERABLE version (directory traversal). Zero runtime deps.
# Expected: reported as a VULNERABILITY, not healthy.
gem "rubyzip", "1.2.1"

# Exact pin to a KNOWN-VULNERABLE version (several advisories). Zero runtime deps.
# Expected: reported as a VULNERABILITY (multiple CVEs), not healthy.
gem "rack", "2.0.6"

# A RANGE (not an exact pin). Generation must resolve it to the latest 0.8.x
# (0.8.1), which has no known advisories. Zero runtime deps.
# Expected: reported as HEALTHY at version 0.8.1.
gem "colorize", "~> 0.8.0"

# WORST CASE: a local `path:` gem. Its directory MUST be copied into the
# resolver's scratch dir or `bundle lock` aborts with "the path does not exist"
# and the WHOLE generation fails. This is exactly the edge the copytree fix
# handles. The gem is local code, not a registry dependency.
gem "local_widget", path: "vendor/local_widget"
