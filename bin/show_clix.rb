require "show_clix"

unless ARGV[0]
  puts "No event specified."
  puts
  puts "Search for an event at http://www.showclix.com/"
  puts "Or, try one of the following:"
  puts "  TheDailyShowwithJonStewart"
  puts "  TheNightlyShowwithLarryWilmore"
  puts "  thetonightshowstarringjimmyfallon"
  puts "  latenightseth"
  exit 1
end

ShowClix.new(ARGV[0]).events.each do |event|
  puts "#{event.date} at #{event.time} is #{event.pretty_status}."
  if event.on_sale?
    puts "  #{event.available_tickets} ticket(s) available: #{event.url}"
  end
end
