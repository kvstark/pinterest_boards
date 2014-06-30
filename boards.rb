require 'uri'
require 'net/http'
require 'debugger'
require 'open-uri'
require 'hpricot'

#Get ids of all pins on a board
def get_pin_ids()
    board = "http://www.pinterest.com/kvstark/jokes"
    source_pin_ids = []
    doc = Hpricot(open(board))

    total_pins = get_board_pin_count(doc)
    pinIDs = doc.search("a.pinImageWrapper")
    pinIDs.each do |id|
        string = id.to_html()
        source_pin_ids << string[14,18]     #HACK!  Fix this with a regular expression
    end

    if pinIDs.size != total_pins
        puts "Unable to scrape all of the pin ids."
    end

    source_pin_ids
end

#Get total number of pins on a board
def get_board_pin_count(doc)
    #find the PinCount element and get its value.
    pins = doc.search("div.PinCount").inner_html()

    #format data into a number
    pins = pins.strip.match("[0-9]+")[0].to_i()
    pins
end

def get_boards_for_pin(pin_number)
    url = "http://www.pinterest.com/pin/" + pin_number.to_s
    doc = Hpricot(open(url))
    boards = doc.search("//a[@class='boardLinkWrapper']")
    #pinBoardsElement
    #print "For pin "
    #print pin_number
    #print " a total of "
    #print boards.size.to_s
    #print " were found.\n"
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

contain_all_pins = []
kvstark_learn_pins = get_pin_ids()
print "Number of pin ids found " + kvstark_learn_pins.size.to_s()
puts()

board_hash = {}
#board_hash.store(key, value)

#For each pin in the set..
kvstark_learn_pins.each do |pin|

    #Get all boards that contain that pin
    boards = get_boards_for_pin(pin)

    #For each board that contains that pin, add
    #a hash table entry for that board.
    boards.each do |board|

        if board_hash[board]
            board_hash[board].push(pin)
        
        else
            board_hash[board] = []
            board_hash[board].push(pin)

        end
    #TODO
    #If the hash table already contains an entry for a board,
    #increment the number of pins that match and update the array of pins to contain the numbers of both pins.

    end
end

#debugger
#board_hash.each_value do |pins|
#    if pins.size > 1
#        puts "Boards with more than one pin:"
#        puts board_hash.key(pins)
#    end
#end

board_hash.each_key do |url|
    if board_hash[url].size > 1
        puts url + " " + board_hash[url].size.to_s()
    end

end
