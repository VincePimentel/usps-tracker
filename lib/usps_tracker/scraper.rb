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

  def self.valid_user_id?(user_id)
    user_id = Nokogiri::XML(open("#{@url}" + '?API=Verify&XML=<AddressValidateRequest USERID=' + "\"#{@user_id}\"" + '></AddressValidateRequest>'))
    puts user_id
  end
end
