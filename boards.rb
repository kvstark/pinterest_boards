require 'uri'
require 'net/http'
require 'debugger'
require 'open-uri'
require 'hpricot'

#Get ids of all pins on a board
def get_pin_ids(board)
    source_pin_ids = []
    doc = Hpricot(open(board))
    total_pins = get_board_pin_count(doc)
    pinIDs = doc.search("a.pinImageWrapper")
    pinIDs.each do |id|
        string = id.to_html()
        source_pin_ids << string.match("[0-9]+")[0]
    end

    if pinIDs.size != total_pins
        puts "Unable to scrape all of the pin ids."
    end
    print "Total pins on board:" + total_pins.to_s()
    puts " Total pins scraped: " + pinIDs.size.to_s()

    source_pin_ids
end

#Get total number of pins on a board
def get_board_pin_count(doc)
    #for normal boards
    pins = doc.search("div.PinCount").inner_html()

    #for place boards
    # if the highest class div class="App full AppBase Module" also has
    #showingPlaceBoard at the end, it's  place board
    #TODO: Hack; find the way to check if the showingPlaceBoard tag exists
    if pins == ""
        pins = doc.search("div.pinsAndFollowerCount .pinCount").inner_html()
    end
    #format data into a number
    pins = pins.strip.match("[0-9]+")[0].to_i()
    pins
end

def get_boards_for_pin(pin_number)
    url = "http://www.pinterest.com/pin/" + pin_number.to_s()
    doc = Hpricot(open(url))
    boards = doc.search("//a[@class='boardLinkWrapper']")
    array = []
    boards_urls = []
    boards.each do |board|
        string = board.to_html()
        array = string.partition("\"")
        array = array[2].partition("\"")
        boards_urls << array[0]
    end
    boards_urls
end

##
# MAIN PART OF CODE
##

board_hash = {}
contain_all_pins = []

puts "Which board contains the set of pins to search for?"
source_board_url = gets.chomp

#TODO: Error checking on the source url.
#It must be of the format /<username>/<board name>
#Board names only contain alphanumeric characters not including _
#or a -.  Unclear the rules for usernames.

source_board_url = "http://www.pinterest.com/" + source_board_url
source_board_pins = get_pin_ids(source_board_url)

#For each pin in the set..
source_board_pins.each do |pin|

    #Get all boards that contain that pin
    boards = get_boards_for_pin(pin)

    #For each board that contains that pin, add
    #a hash table entry for that board.
    boards.each do |board|

        if !board_hash[board]
            board_hash[board] = []
        end

        board_hash[board].push(pin)
    end
end

#print out boards with more than one pin in common
board_hash.each_key do |url|
    if board_hash[url].size > 1
        puts url + " has " + board_hash[url].size.to_s() + " pins in common."
    end
end
