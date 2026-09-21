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

# WORST CASE: a local `path:` gem. Its directory MUST be copied into the
# resolver's scratch dir or `bundle lock` aborts and the WHOLE generation fails.
# The gem is local code, not a registry dependency.
gem "local_widget", path: "vendor/local_widget"
