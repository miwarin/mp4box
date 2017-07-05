require 'pp'

$boxtypes = %Q{ ftyp, moov, mdat }

class Box
 attr_accessor :size, :type, :data
 def initialize
   @size = 0
   @type = ''
   @data ||= []
 end
end

def analyze( data, length )
 boxes ||= []
 i = 0
 while i < length
   type = data[ i..i+3 ]

   unless $boxtypes.include?( type )
     i += 4
   else
     box = Box.new
     box.type = type
     box.size =
       (data[i-4] << 24) +
       (data[i-3] << 16) +
       (data[i-2] << 8) +
       (data[i-1])
     i += 4
     if box.size == 1
       # Extended Size
       box.size =
         (data[ i ] << 56) +
         (data[ i+1 ] << 48) +
         (data[ i+2 ] << 40) +
         (data[ i+3 ] << 32) +
         (data[ i+4 ] << 24) +
         (data[ i+5 ] << 16) +
         (data[ i+6 ] << 8) +
         (data[ i+7 ])
       i += 8
     end

     for d in data[i..i + (box.size - 4)]
       box.data << d
     end
     i += (box.size - 4)
     boxes << box
   end
 end
 
 return boxes
end


def main( argv )
 filepath = argv[ 0 ]
 data = File.open( filepath, 'rb' ).read
 
 boxes = analyze( data, data.length )
 boxes.each {|box|
   puts "box type: #{box.type} size: #{box.size}"
 }
 
end

main(ARGV)
