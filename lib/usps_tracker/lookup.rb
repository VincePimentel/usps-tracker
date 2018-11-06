class UspsTracker::Lookup
  attr_accessor :firm_name, :address_1, :address_2, :city, :state, :urbanization, :zip_5, :zip_4, :return_text, :error_number, :error_description

  @@all = Array.new

  def initialize(address_hash)
    address_hash.each do |key, value|
      self.send(("#{key}="), value)
    end
    @@all << self
  end

  def self.all
    @@all
  end
end
