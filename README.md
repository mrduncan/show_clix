# ShowClix
I wrote this to see ticket availability for The Daily Show but it should work for most other recurring events on ShowClix.

Search for events at [ShowClix](http://www.showclix.com/) and pass the script the event name from the url.  For example, `TheDailyShowwithJonStewart` from http://www.showclix.com/event/TheDailyShowwithJonStewart.

## Usage
    $ bundle exec ruby -Ilib bin/show_clix.rb TheDailyShowwithJonStewart
    2015-04-21 at 6:00pm is sold out.
    2015-04-22 at 6:00pm is sold out.
    ...
    2015-05-14 at 6:00pm is sold out.
