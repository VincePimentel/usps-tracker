require "nokogiri"
require "pry"

class UspsTracker::Scraper
  attr_accessor :user_id
  attr_reader :server_url

  def initialize(user_id)
    @user_id = user_id
  end

  def server_url=(server_url)
    @server_url = "https://secure.shippingapis.com/ShippingAPI.dll"
  end

  def valid_user_id?(user_id)
    xml = Nokogiri::XML(open(server_url + '?API=Verify&XML=<AddressValidateRequest USERID=' + @user_id + '></AddressValidateRequest>'))
    binding.pry
  end
end
