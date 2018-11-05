class UspsTracker::CLI
  def start
    banner("United States Postal Service Package Tracker")
    puts "To use the tracker, you must be a registered user."
    puts "Please enter your user ID or any options below to proceed:"
    spacer
    puts "    info : Get information on how to request a user ID."
    exit_option
    puts "    REMOVE ME: 253VINCE6398"
    spacer
    @option = gets.strip.upcase

    case @option
    when "INFO" then info
    when "EXIT" then exit
    else user_check
    end
  end

  def info
    banner("INFORMATION")
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
      puts "    login : Return to the initial screen."
      exit_option
      spacer
      @option = gets.strip.upcase
    end

    case @option
    when "LOGIN" then start
    when "EXIT" then exit
    end
  end

  def user_check
    until UspsTracker::Scraper.new(@option).valid_user? || @option == "INFO" || @option == "EXIT"
      banner("AUTHORIZATION FAILURE")
      puts "Username is incorrect or does not exist. Please try again or any options below to proceed:"
      spacer
      puts "    info : Get information on how to request a user ID."
      exit_option
      spacer
      @option = gets.strip.upcase
    end

    case @option
    when "INFO" then info
    when "EXIT" then exit
    else menu
    end
  end

  def menu
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
    when "LOOKUP" then puts "LOOKUP"
    when "EXIT" then exit
    end
  end

  def exit
    banner("Goodbye! Have a nice day!")
  end

  def exit_option
    puts "    exit : Terminate the program."
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
