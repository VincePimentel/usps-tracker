class UspsTracker::Lookup
  attr_accessor :firm_name, :address_1, :address_2, :city, :state, :urbanization, :zip_5, :zip_4, :return_text

  @@all = Array.new

  def initialize(xml_request)

  end
end
