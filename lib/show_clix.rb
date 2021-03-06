require "date"
require "json"
require "curb"
require "nokogiri"

class ShowClix
  Event = Struct.new(:date, :time, :status, :url, :available_tickets) do
    # "on_sale" -> "on sale"
    def pretty_status
      status.gsub(/_/, " ")
    end

    def on_sale?
      status == "on_sale"
    end
  end

  HOST = "www.showclix.com"

  def initialize(event)
    @event = event
  end

  def events
    multi = Curl::Multi.new

    results = []
    schedule.each do |date|
      path = "/event/#{@event}/recurring-event-times"
      query = "date=#{date.strftime("%B+%d%%2C+%Y")}"

      curl = Curl::Easy.new("#{HOST}#{path}?#{query}")
      curl.on_success do |easy|
        results << JSON.parse(easy.body_str)["times"].map do |time|
          event = Event.new
          event.date = date
          event.time = time["time"]
          event.status = time["event_status"]
          event.url = "http://#{HOST}#{time["uri"]}"

          # If the event is on sale, see how many tickets we can purchase.
          if event.on_sale?
            event_curl = Curl::Easy.new(event.url)
            event_curl.on_success do |event_easy|
              event.available_tickets = parse_tickets_available(event_easy.body_str)
            end
            multi.add event_curl
          end

          event
        end
      end

      multi.add curl
    end

    multi.perform

    results.flatten!
    results.sort! { |x, y| x.date <=> y.date }

    results
  end

  def schedule
    doc = Nokogiri::HTML(Curl.get("#{HOST}/event/#{@event}").body_str)
    script = doc.css("script").find { |s| s.content =~ /dates_avail/ }.content

    # Extract dates available from javascript which resembles:
    # var dates_avail =
    #                   {"2015-04-21":"style1","2015-04-22":"style1"}                    ;
    datesjs = script.match(/dates_avail =\s*(.*?);/m)[1]
    dates = datesjs.split(",").map do |i|
      Date.parse(i.split(":")[0].gsub(/[^0-9-]/, ""))
    end

    dates
  end

  private
    def parse_tickets_available(body_str)
      doc = Nokogiri::HTML(body_str)

      doc.css(".ticket-select option").map do |option|
        option["value"].to_i
      end.max
    end
end
