require 'uri'
require 'net/http'
require 'debugger'
require 'open-uri'
require 'hpricot'

# Want to create a hash table where the key is the board (username/name/url) and the value is the count of pins found on that board as well as the exact pin #s.

#Each time we find a new board that contains one of the pins we care about, add it to the hash set.

#Get all pins on a board
def get_pin_nums()
    source_board = "http://www.pinterest.com/kvstark/jokes"
    source_pin_nums = []
    doc = Hpricot(open(source_board))
    pinNumbersElement = doc.search("//a[@class='pinImageWrapper']")
    pinNumbersElement.each do |element|
        string = element.to_html()
        source_pin_nums << string[14,18]
    end
    source_pin_nums
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
kvstark_learn_pins = get_pin_nums()
print "Number of pins on source board " + kvstark_learn_pins.size.to_s()
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
