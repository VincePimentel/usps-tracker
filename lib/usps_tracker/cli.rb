class UspsTracker::CLI
  def spacer
    puts ""
  end

  def border
    puts "=" * 44
  end

  def top_border_spacer
    spacer
    border
  end

  def bottom_border_spacer
    border
    spacer
  end

  def full_border_spacer
    spacer
    border
    spacer
  end

  def login
    top_border_spacer
    puts "United States Postal Service Package Tracker"
    bottom_border_spacer
    puts "To use the tracker, you must be a registered user."
    puts "Please enter your user ID or any options below to proceed:"
    spacer
    puts "    info : Get information on how to request a user ID."
    puts "    exit : Terminate the program."
    spacer
    @option = gets.strip.upcase

    case @option
    when "INFO" then info
    when "EXIT" then exit
    else menu
    end
  end

  def info
    full_border_spacer
    puts "Please visit http://www.usps.com/webtools/"
    puts "Follow the instructions to register for the APIs and get a Web Tools User ID."
    spacer
    puts "Upon completion of the registration process,"
    puts "your user ID will be sent via e-mail to the address specified in the registration."
    spacer
    puts "You will be immediately granted access to the production server for the price calculators,"
    puts "package tracking, address information and service standards and commitments APIs."
    @option = ""

    until @option == "LOGIN" || @option == "EXIT"
      spacer
      puts "What would you like to do?"
      spacer
      puts "    login : Return to the option prompt."
      puts "    exit : Terminate the program"
      spacer
      @option = gets.strip.upcase
    end

    case @option
    when "LOGIN" then login
    when "EXIT" then exit
    end
  end

  def menu
    user_id = @option
    user = user_id.gsub(/\d/, "").capitalize
    Scraper.new(253VINCE6398)
    @option = ""

    until @option == "TRACK" || @option == "LOOKUP" || @option == "EXIT"
      full_border_spacer
      puts "Welcome, #{user}! What would you like to do today?"
      spacer
      puts "    track : Track a package via a tracking number."
      puts "    lookup : Correct address errors or find a city/state/ZIP given an incomplete address information."
      puts "    exit : Terminate the program"
      spacer
      @option = gets.strip.upcase
    end

    case @option
    when "TRACK" then puts "TRACK"
    when "LOOKUP" then puts "LOOKUP"
    when "EXIT" then exit
    end
  end

  def exit
    spacer
    puts "Goodbye! Have a nice day!"
    spacer
  end
end
