require "date"
require "json"
require "net/http"
require "nokogiri"

class ShowClix
  HOST = "www.showclix.com"

  def initialize(event)
    @event = event
    @http = Net::HTTP.new(HOST)
  end

  def events
    schedule.map { |date| event_status(date) }.flatten
  end

  def schedule
    doc = Nokogiri::HTML(@http.get("/event/#{@event}").body)
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
    def event_status(date)
      path = "/event/#{@event}/recurring-event-times"
      query = "date=#{date.strftime("%B+%d%%2C+%Y")}"
      json = JSON.parse(@http.get("#{path}?#{query}").body)
      json["times"].map do |time|
        { date: date,
          time: time["time"],
          status: time["event_status"],
          url: "http://#{HOST}#{time["uri"]}" }
      end
    end
end
