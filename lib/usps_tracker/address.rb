class UspsTracker::Address
  attr_accessor :firm_name, :address_1, :address_2, :city, :state, :urbanization, :zip_5, :zip_4, :return_text, :error_number, :error_description, #:user_id

  @@all = Array.new
  @@current_search = Hash.new

  def initialize(address_hash = {})
    #@user_id = user_id
    address_hash.each do |key, value|
      self.send(("#{key}="), value)
    end
    @@all << self
    @@search = address_hash
  end

  def validated_address
    self.new()
  end

  def self.all
    @@all
  end

  def self.current_search
    @@current_search
  end
end
