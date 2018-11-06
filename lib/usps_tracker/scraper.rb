class UspsTracker::Scraper
  attr_accessor :user_id
  #attr_reader :host, :xml, :lookup_validate, :lookup_validate_end, :lookup_zip_code, :lookup_zip_code_end, :lookup_city_state, :lookup_city_state_end, :track_number, :track_number_end, :track_email, :track_email_end

  def initialize(user_id)
    @host = "https://secure.shippingapis.com/ShippingAPI.dll?API="
    @xml = "&XML="
    @user_id = "USERID='#{user_id}'"

    #API SIGNATURE FORMAT - <Host><API><XML><API Request><User>DATA</API Request>
    @lookup_validate_api = "AddressValidateRequest"
    @lookup_validate_start = "#{@host}Verify#{@xml}<#{@lookup_validate_api} #{@user_id}>"
    @lookup_validate_end = "</#{@lookup_validate_api}>"
    #https://secure.shippingapis.com/ShippingAPI.dll?API=Verify&XML=<AddressValidateRequest USERID=”user_id”>DATA</AddressValidateRequest>

    @lookup_zip_code_api = "ZipCodeLookupRequest"
    @lookup_zip_code_start = "#{@host}#{@lookup_zip_code_api.gsub("Request", "")}#{@xml}<#{@lookup_zip_code_api} #{@user_id}>"
    @lookup_zip_code_end = "</#{@lookup_zip_code_api}>"
    #https://secure.shippingapis.com/ShippingAPI.dll?API=ZipCodeLookup&XML=<ZipCodeLookupRequest USERID=”user_id”>DATA</ZipCodeLookupRequest>

    @lookup_city_state_api = "CityStateLookupRequest"
    @lookup_city_state_start = "#{@host}#{@lookup_city_state_api.gsub("Request", "")}#{@xml}<#{@lookup_city_state_api} #{@user_id}>"
    @lookup_city_state_end = "</#{@lookup_city_state_api}>"
    #https://secure.shippingapis.com/ShippingAPI.dll?API=CityStateLookup&XML=<CityStateLookupRequest USERID=”user_id”>DATA</CityStateLookupRequest>

    @track_request_api = "TrackRequest"
    @track_request_start = "#{@host}TrackV2#{@xml}<#{@track_request_api} #{@user_id}>"
    @track_request_end = "</#{@track_request_api}>"
    #https://stg-secure.shippingapis.com/ShippingAPI.dll?API=TrackV2&XML=<TrackRequest USERID=”user_id”>DATA</TrackRequest>

    @track_fields_api = ""
    @track_fields_start = ""
    @track_fields_end = ""
    #https://secure.shippingapis.com/ShippingAPI.dll?API=TrackV2&XML=<TrackFieldRequest USERID=”user_id”>DATA</TrackFieldRequest>

    @track_email_api = ""
    @track_email_start = "PTSEmail#{@xml}<PTSEmailRequest #{@user_id}>"
    @track_email_end = "</PTSEmailRequest>"
    #https://secure.shippingapis.com/ShippingAPI.dll?API=PTSEmail&XML=<PTSEmailRequest USERID=”user_id”>DATA</PTSEmailRequest>
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
  def address_validate(firm_name, address_1, address_2, city, state, urbanization, zip_5, zip_4)
    address_xml = Nokogiri::XML(open(
      @host + @lookup_validate + @user_id + "
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
      " + @lookup_validate_end
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
