class UspsTracker::Scraper
  HOST = "https://secure.shippingapis.com/ShippingAPI.dll?API=".freeze
  XML = "&XML=".freeze
  ID = "USERID=".freeze

  #API SIGNATURE FORMAT - <Host><API><XML><API-Request User>DATA</API-Request>

  #https://secure.shippingapis.com/ShippingAPI.dll?API=Verify&XML=<AddressValidateRequest USERID=”user_id”>DATA</AddressValidateRequest>
  L_VALIDATE_API = "AddressValidateRequest".freeze
  L_VALIDATE_START = "#{HOST}Verify#{XML}<#{L_VALIDATE_API} #{ID}".freeze
  L_VALIDATE_END = "</#{L_VALIDATE_API}>".freeze

  #https://secure.shippingapis.com/ShippingAPI.dll?API=ZipCodeLookup&XML=<ZipCodeLookupRequest USERID=”userid”>DATA</ZipCodeLookupRequest>
  L_ZIP_API = "ZipCodeLookup".freeze
  L_ZIP_START = "#{HOST}#{L_ZIP_API}#{XML}<#{L_ZIP_API}Request #{ID}".freeze
  L_ZIP_END = "</#{L_ZIP_API}Request>".freeze

  #https://secure.shippingapis.com/ShippingAPI.dll?API=CityStateLookup&XML=<CityStateLookupRequest USERID=”user_id”>DATA</CityStateLookupRequest>
  L_CSTATE_API = "CityStateLookup".freeze
  L_CSTATE_START = "#{HOST}#{L_CSTATE_API}#{XML}<#{L_CSTATE_API}Request #{ID}".freeze
  L_CSTATE_END = "</#{L_CSTATE_API}Request>".freeze

  #https://secure.shippingapis.com/ShippingAPI.dll?API=TrackV2&XML=<TrackRequest USERID=”user_id”>DATA</TrackRequest>
  T_REQUEST_API = "TrackRequest".freeze
  T_REQUEST_START = "#{HOST}TrackV2#{XML}<#{T_REQUEST_API} #{ID}".freeze
  T_REQUEST_END = "</#{T_REQUEST_API}>".freeze

  #https://secure.shippingapis.com/ShippingAPI.dll?API=TrackV2&XML=<TrackFieldRequest USERID=”user_id”>DATA</TrackFieldRequest>
  T_FIELD_API = "TrackField".freeze
  T_FIELD_START = "#{HOST}TrackV2#{XML}<#{T_FIELD_API}Request #{ID}".freeze
  T_FIELD_END = "</#{T_FIELD_API}Request>".freeze

  #https://secure.shippingapis.com/ShippingAPI.dll?API=PTSEmail&XML=<PTSEmailRequest USERID=”user_id”>DATA</PTSEmailRequest>
  T_EMAIL_API = "PTSEmail".freeze
  T_EMAIL_START = "#{HOST}#{T_EMAIL_API}#{XML}<#{T_EMAIL_API}Request #{ID}".freeze
  T_EMAIL_END = "</#{T_EMAIL_API}Request>".freeze

  attr_reader :user_id

  def initialize(user_id)
    @user_id = user_id
  end

  def valid_user?
    !Nokogiri::XML(open(
      L_CSTATE_START + "'#{@user_id}'>" + "
      <ZipCode ID='0'>
        <Zip5>90210</Zip5>
      </ZipCode>
      " + L_CSTATE_END
      )).text.include?("80040B1A")
    #If document includes the error code "80040B1A", then not a valid user.
  end

  #LOOKUP METHODS
  def address_validate(firm_name, address_1, address_2, city, state, urbanization, zip_5, zip_4)
    address_xml = Nokogiri::XML(open(
      "#{L_VALIDATE_START}'#{@user_id}'>" + "
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
      " + "#{L_VALIDATE_END}"
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
  end

  def us_states
    x = Nokogiri::HTML(open("https://gist.githubusercontent.com/mshafrir/2646763/raw/8b0dbb93521f5d6889502305335104218454c2bf/states_hash.json"))
  end

  def syntax_check
    #Must return all TRUE
    test = [
      L_VALIDATE_START + "'#{@user_id}'>" + L_VALIDATE_END == "https://secure.shippingapis.com/ShippingAPI.dll?API=Verify&XML=<AddressValidateRequest USERID=''></AddressValidateRequest>",
      L_ZIP_START + "'#{@user_id}'>" + L_ZIP_END == "https://secure.shippingapis.com/ShippingAPI.dll?API=ZipCodeLookup&XML=<ZipCodeLookupRequest USERID=''></ZipCodeLookupRequest>",
      L_CSTATE_START + "'#{@user_id}'>" + L_CSTATE_END == "https://secure.shippingapis.com/ShippingAPI.dll?API=CityStateLookup&XML=<CityStateLookupRequest USERID=''></CityStateLookupRequest>",
      T_REQUEST_START + "'#{@user_id}'>" + T_REQUEST_END == "https://secure.shippingapis.com/ShippingAPI.dll?API=TrackV2&XML=<TrackRequest USERID=''></TrackRequest>",
      T_FIELD_START + "'#{@user_id}'>" + T_FIELD_END == "https://secure.shippingapis.com/ShippingAPI.dll?API=TrackV2&XML=<TrackFieldRequest USERID=''></TrackFieldRequest>",
      T_EMAIL_START + "'#{@user_id}'>" + T_EMAIL_END == "https://secure.shippingapis.com/ShippingAPI.dll?API=PTSEmail&XML=<PTSEmailRequest USERID=''></PTSEmailRequest>"
    ]
  end
end
