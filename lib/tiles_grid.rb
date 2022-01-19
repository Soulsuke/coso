=begin
Coso - the exploring thingy
Copyright (C) 2021  Maurizio Oliveri

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see https://www.gnu.org/licenses/gpl-3.0.txt.
=end



=begin
TilesGrid class.

A simple matrix where we can add rows/columns on any side.
=end
class TilesGrid

  #############################################################################
  ### Public methods                                                        ###
  #############################################################################

  # Constructor.
  # Takes as parameter the dimensions.
  def initialize( rows, cols, value: nil )
    @tiles = Array.new( rows ) { Array.new( cols ) { value } }
  end



  # Tile getter.
  def []( row, col )
    return @tiles[ row ][ col ]
  end



  # Tile setter.
  def []=( row, col, elem )
    @tiles[ row ][ col ] = elem
  end



  # Returns the current height.
  def height
    return @tiles.length
  end



  # Returns the current width.
  def width
    return @tiles.first.length
  end



  # Prints out the tiles.
  def inspect
    @tiles.each do |r|
      puts "#{r}"
    end
  end



  # Finds the index of an item.
  def find_index( &block )
    ret = nil

    @tiles.each_with_index do |r, ri|
      ret = r.find_index &block
      unless ret.nil? then
        ret = [ ri, ret ]
        break
      end
      break unless ret.nil?
    end

    return ret
  end



  # Increase the matrix's dimensions.
  def add( position:, value: nil )
    case position
      when :top
        @tiles.unshift( Array.new( width ) { value } )
      when :bottom
        @tiles << ( Array.new( width ) { value } )
      when :right
        height.times do |i|
          @tiles[ i ] << value
        end
      when :left
        height.times do |i|
          @tiles[ i ].unshift value
        end
    end
  end 



  # Iterates over rows.
  def each_row( &block )
    @tiles.each { |r| return r }
    return self
  end



  # Iterates over rows with index.
  def each_row_with_index( &block )
    @tiles.each_with_index { |r, i| yield r, i }
    return self
  end

end

