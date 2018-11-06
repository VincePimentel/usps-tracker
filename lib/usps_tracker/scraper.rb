class UspsTracker::Scraper
  attr_accessor :user_id
  #attr_reader :host, :xml, :lookup_verify, :lookup_verify_end, :lookup_zip_code, :lookup_zip_code_end, :lookup_city_state, :lookup_city_state_end, :track_number, :track_number_end, :track_email, :track_email_end

  def initialize(user_id)
    @user_id = " USERID='#{user_id}'>"
    @host = "https://secure.shippingapis.com/ShippingAPI.dll?API="
    @xml = "&XML=<"
    @lookup_verify = "Verify#{@xml}AddressValidateRequest"
    @lookup_verify_end = "</AddressValidateRequest>"
    @lookup_zip_code = "ZipCodeLookup#{@xml}ZipCodeLookupRequest"
    @lookup_zip_code_end = "</ZipCodeLookupRequest>"
    @lookup_city_state = "CityStateLookup#{@xml}CityStateLookupRequest"
    @lookup_city_state_end = "</CityStateLookupRequest>"
    @track_number = "TrackV2#{@xml}TrackFieldRequest"
    @track_number_end = "</TrackFieldRequest>"
    @track_email = "PTSEmail#{@xml}PTSEmailRequest"
    @track_email_end = "</PTSEmailRequest>"
  end

  def valid_user?
    !Nokogiri::XML(open(
      @host + @lookup_city_state + @user_id + "
      <ZipCode ID='0'>
        <Zip5>90210</Zip5>
      </ZipCode>
      " + @lookup_city_state_end
    )).text.include?("80040B1A")
    #If document includes the error code "80040B1A", then not a valid user.
  end

  #LOOKUP METHODS
  def address_verify(firm_name, address_1, address_2, city, state, urbanization, zip_5, zip_4)
    address_xml = Nokogiri::XML(open(
      @host + @lookup_verify + @user_id + "
      <Address ID='0'>
        <FirmName>#{firm_name}</FirmName>
        <Address1>#{address_1}</Address1>
        <Address2>#{address_2}</Address2>
        <City>#{city}</City>
        <State>#{state}</State>
        <Urbanization>#{urbanization}</Urbanization>
        <Zip5>#{zip_5}</Zip5>
        <Zip4>#{zip_4}</Zip4>
      </Address>
      " + @lookup_verify_end
      ))

    address = {
      firm_name: address_xml.css("FirmName").text,
      address_1: address_xml.css("Address1").text,
      address_2: address_xml.css("Address2").text,
      city: address_xml.css("City").text,
      state: address_xml.css("State").text,
      urbanization: address_xml.css("Urbanization").text,
      zip_5: address_xml.css("Zip5").text,
      zip_4: address_xml.css("Zip4").text,
      return_text: address_xml.css("ReturnText").text,
      error_number: address_xml.css("Number").text,
      error_description: address_xml.css("Description").text,
    }.delete_if { |name, text| name.empty? || name.nil? || text.empty? || text.nil? }

    address

    binding.pry
  end
end
