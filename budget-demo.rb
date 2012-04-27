#!/usr/bin/env ruby
# Just a simple demo on how to use SODA 2.0 to access data from a Socrata data site
#
# CAVEAT: As of April 2012, SODA 2.0 is still is in beta, so some functionality may not work yet

require 'net/http'
require 'uri'
require 'json'
require 'cgi'
require 'pp'

# Just a helper class
class Socrata
  def initialize(domain = "opendata.socrata.com", app_token)
    @domain = domain
    @app_token = app_token
  end

  def get(url, params = {})
    # Create query string of escaped key, value pairs
    query = params.collect{ |key, val| "#{key}=#{CGI::escape(val)}" }.join("&")

    puts "Query: #{query}"

    # Create our request
    request = Net::HTTP::Get.new(url + "?" + query)
    request.add_field("X-App-Token", @app_token)

    # BAM!
    response = Net::HTTP.start(@domain, 80) { |http| http.request(request) }

    # Check our response code
    if response.code != "200"
      raise "Error querying SODA API: #{response.body}"
    else
      return JSON::parse(response.body)
    end
  end
end

########
# Config
DOMAIN = "data.seattle.gov"
APP_TOKEN = ARGV.shift

# Set up our client
socrata = Socrata.new(DOMAIN, APP_TOKEN)

# Run a few simple queries
pp socrata.get("/resource/budget-2012.json", {"department" => "Department of Information Technology"})

puts "===================="

pp socrata.get("/resource/budget-2012.json", {"$where" => "expenditure_allowance < 50000", "$select" => "expenditure_allowance"})
