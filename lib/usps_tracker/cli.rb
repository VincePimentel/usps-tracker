class UspsTracker::CLI
  def initialize
    reset
  end

  def start
    banner("United States Postal Service Package Tracker")
    #display_date
    puts "To use the tracker, you must be a registered user."
    puts "Please enter your user ID:"
    commands_option
    puts "    info : Get information on how to request a user ID."
    exit_option
    puts "    REMOVE ME: 253VINCE6398"
    spacer
    @option = gets.strip.upcase

    case @option
    when "INFO" then info
    when "EXIT" then exit
    when "" then @option = "253VINCE6398"; validate_user#REMOVE ME
    else validate_user
    end
  end

  def info
    @current_menu = "info"
    @option = ""

    banner("INFORMATION")
    puts "Please visit http://www.usps.com/webtools/"
    puts "Follow the instructions to register for the APIs and get a Web Tools User ID."
    spacer
    puts "Your user ID will be sent via e-mail to the address specified in the registration."
    spacer
    puts "You will be immediately granted access to the production server for the price calculators,"
    puts "package tracking, address information and service standards and commitments APIs."

    until @option == "LOGIN" || @option == "BACK" || @option == "EXIT"
      spacer
      puts "What would you like to do?"
      spacer
      back_option
      exit_option
      spacer
      @option = gets.strip.upcase
    end

    case @option
    when "BACK" then back
    when "EXIT" then exit
    end
  end

  def validate_user
    @current_menu = "validate_user"
    until UspsTracker::Scraper.new(@option).valid_user? || @option == "INFO" || @option == "BACK" || @option == "EXIT"
      banner("AUTHORIZATION FAILURE")
      puts "User ID, #{@option}, is incorrect or does not exist. Please try again:"
      commands_option
      puts "    info : Get information on how to request a user ID."
      back_option
      exit_option
      spacer
      @option = gets.strip.upcase
    end

    case @option
    when "INFO" then info
    when "BACK" then back
    when "EXIT" then exit
    else menu
    end
  end

  def menu
    @current_menu = "menu"
    user_id = @option
    user = @option.gsub(/\d/, "").capitalize
    @option = ""

    until @option == "TRACK" || @option == "LOOKUP" || @option == "EXIT"
      banner("MENU")
      puts "Welcome, #{user}! What would you like to do today?"
      spacer
      puts "    track : Track a package via a tracking number."
      puts "    lookup : Correct address errors or find a city/state/ZIP given an incomplete address information."
      exit_option
      spacer
      @option = gets.strip.upcase
    end

    case @option
    when "TRACK" then puts "TRACK"
    when "LOOKUP" then lookup
    when "EXIT" then exit
    end
  end

  def lookup
    @current_menu = "lookup"
    @option = ""

    until @option == "CLEANSE" || @option == "CITY" || @option == "STATE" || @option == "ZIP" || @option == "BACK" || @option == "EXIT"
      banner("City/State/ZIP Code Lookup and Address Standardization Tool")
      puts "What would you like to do or look up today?"
      spacer
      puts "    cleanse : Corrects a given street, city and state and supplies ZIP codes."
      puts "    city -OR- state : Returns the city and state corresponding to the given ZIP Code."
      puts "    zip : Returns the ZIP Code and ZIP Code + 4 corresponding to the given address, city, and state."
      back_option
      exit_option
      spacer
      @option = gets.strip.upcase
    end

    case @option
    when "CLEANSE" then cleanse
    when "CITY" then puts "CITY WIP"
    when "STATE" then puts "STATE WIP"
    when "ZIP" then puts "ZIP WIP"
    when "BACK" then back
    when "EXIT" then exit
    else lookup
    end
  end

  def cleanse
    @current_menu = "cleanse"
    @option = ""

    banner("Address Standardization Tool")
    puts "Corrects errors in street addresses, including abbreviations and missing information, and supplies ZIP Codes and ZIP Codes + 4."
    commands_option
    undo_option
    back_option
    exit_option
    puts "    REMOVE ME: skip"
    spacer

    get_address_1
    get_address_2
    get_city
    get_state
    #get_zip_5
    #get_zip_4

    correct_entry?
  end

  def address_hash
    {
      firm_name: @firm_name,
      address_1: @address_1,
      address_2: @address_2,
      city: @city,
      state: @state,
      urbanization: @urbanization,
      zip_5: @zip_5,
      zip_4: @zip_4
    }.delete_if { |key, value| value.empty? || value.nil? }
  end

  def create_new_address
    UspsTracker::Lookup.new(address_hash)
  end

  def skip
    #FOR TESTING PURPOSES(SKIPPING MANUAL ENTRY OF ADDRESS
    #ADDRESS POINTS TO BOBA GUYS
    @address_2 = "3491 19th"
    @city = "San Francisco"
    @state = "CA"
    @zip_5 = "94110"

    create_new_address
  end

  def get_address_1
    @address_1 = ""
    puts "Enter Apartment/Suite Number (if applicable):"
    @address_1 = gets.strip.upcase
    spacer

    case @address_1
    when "SKIP" then skip#REMOVE ME
    when "BACK" then back
    when "EXIT" then exit
    when "UNDO" then get_address_1; get_address_2
    end
  end

  def get_address_2
    @address_2 = ""
    until @address_2 == "BACK" || @address_2 == "EXIT" || @address_2 == "UNDO" || @address_2.length >= 3
      puts "Enter Street Address:"
      @address_2 = gets.strip.upcase
      spacer
    end

    case @address_2
    when "BACK" then back
    when "EXIT" then exit
    when "UNDO" then get_address_1; get_address_2
    end
  end

  def get_city
    @city = ""
    until @city == "BACK" || @city == "EXIT" || @city == "UNDO" || @city.length >= 3
      puts "Enter City:"
      @city = gets.strip.upcase
      spacer
    end

    case @city
    when "BACK" then back
    when "EXIT" then exit
    when "UNDO" then get_address_2; get_city
    end
  end

  def get_state
    @state = ""
    until @state == "BACK" || @state == "EXIT" || @state == "UNDO" || @state.length >= 2
      puts "Enter State:"
      @state = gets.strip.upcase
      spacer
    end

    case @state
    when "BACK" then back
    when "EXIT" then exit
    when "UNDO" then get_city; get_state
    end
  end

  def get_zip_5
  end

  def get_zip_4
  end

  def get_urbanization

  end

  def correct_entry?
    @option = ""

    until @option == "Y" || @option == "N"
      puts "Is this correct? (y/n)"
      spacer

      address_hash.each do |key, value|
        case key.to_s
        when "address_1"
          key = "apt / suite #".to_sym
        when "address_2"
          key = "street".to_sym
        when "zip_5"
          key = "z i p code".to_sym
        when "zip_4"
          key = "z i p code_+_4".to_sym
        end
        puts "    #{key.to_s.split.map(&:capitalize).join.gsub("_", " ")}: #{value}"
      end

      spacer
      @option = gets.strip.upcase
    end

    case @option
    when "Y" then create_new_address
    when "N" then cleanse
    end
  end

  def reset
    @option = ""
    @current_menu = ""
    @firm_name = ""
    @address_1 = ""
    @address_2 = ""
    @city = ""
    @state = ""
    @urbanization = ""
    @zip_5 = ""
    @zip_4 = ""
  end

  #UI Methods
  def display_date

  end

  def commands_option
    spacer
    puts "Additional commands:"
    spacer
  end

  def undo_option
    puts "    undo : Make a change to the last entry."
  end

  def back
    case @current_menu
    when "info" then start
    #when "track"
    when "lookup" then menu
    when "cleanse" then lookup
    #when "city|state" then lookup
    #when "zip" then lookup
    end

    reset
  end

  def back_option
    puts "    back : Returns to the previous menu."
  end

  def exit
    reset
    banner("Goodbye! Have a nice day!")
  end

  def exit_option
    puts "    exit : Terminates the program."
  end

  def banner(message)
    top_border_spacer(message.length)
    puts message
    bottom_border_spacer(message.length)
  end

  def spacer
    puts ""
  end

  def border(length = 1)
    puts "=" * length
  end

  def top_border_spacer(length = 1)
    spacer
    border(length)
  end

  def bottom_border_spacer(length = 1)
    border(length)
    spacer
  end

  def full_border_spacer(length = 1)
    spacer
    border(length)
    spacer
  end
end
