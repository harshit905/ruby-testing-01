# A trivial entry point so the repo looks real and (if reachability is checked)
# rubyzip, rack, and sinatra are imported while colorize is not.
require "zip"   # the require name for the `rubyzip` gem
require "rack"
require "sinatra/base"

module App
  def self.run
    puts "sca test app"
  end
end
