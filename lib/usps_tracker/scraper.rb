require "pry"

class UspsTracker::Scraper
  attr_accessor :user_id
  attr_reader :server_url

  def initialize(user_id)
    @user_id = user_id
    @server_url = "https://secure.shippingapis.com/ShippingAPI.dll"
  end

  def city_state_lookup

  end

  def valid_user?
    !Nokogiri::XML(open("#{self.server_url}?API=CityStateLookup&XML=<CityStateLookupRequest USERID='#{self.user_id}'><ZipCode ID='0'><Zip5>90210</Zip5></ZipCode></CityStateLookupRequest>")).text.include?("80040B1A")
    #If document includes the error code "80040B1A", then not a valid user.
  end
end
