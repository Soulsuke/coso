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



require_relative 'tiles_grid'



=begin
Map class.  

Represents a map, be it full or partial.
=end
class Map

  #############################################################################
  ### Attributes                                                            ###
  #############################################################################

  # Map's tiles:
  attr_reader :tiles

  # Spawn tile coordinates:
  attr_reader :spawn



  #############################################################################
  ### Public methods                                                        ###
  #############################################################################

  # Constructor.
  def initialize( data, biome: nil )
    # If no biome has been given, init the explorer's map which stats as a
    # 1x1 matrix containing the lone cell specified within data:
    if biome.nil? then
      @tiles = TilesGrid.new 1, 1, value: data

    # Else, create a randomly generated map:
    else
      # Create an empty matrix:
      @tiles = TilesGrid.new data[ :height ], data[ :width ],
        value: nil

      # Compose chances data:
      chances_total = biome.map { |b| b[ :chance ] }.sum
      biome_chances = Array.new
      normalizer = 0
      biome.each_with_index do |b, idx|
        biome_chances << {
          idx: idx,
          start: normalizer,
          end: normalizer += b[ :chance ]
        }
      end

      # Compose the map:
      data[ :height ].times do |h|
        data[ :width ].times do |w|
          # Pick a random tile:
          pick = rand chances_total
          @tiles[ h, w ] = biome[
            biome_chances
              .find { |b| b[ :start ] <= pick and b[ :end ] >= pick }[ :idx ]
          ]
        end
      end

      # Set a random starting and ending tile:
      [ :spawn_tile, :exit_tile ].each do |tile|
        row = rand data[ :height ]
        col = rand data[ :width ]
        @tiles[ row, col ] = data[ tile ]
        if :spawn_tile == tile then
          @spawn = [ row, col ]
        end
      end
    end
  end



  # Returns the map's height.
  def height
    return @tiles.height
  end



  # Returns the map's width.
  def width
    return @tiles.width
  end



  # Increase the matrix's dimensions.
  def add( position )
    @tiles.add position: position, value: nil
  end



  # Returns a 3x3 submap of the surroinding to the given coordinates.
  def surrounding_area( coords )
    # Return value container:
    ret = TilesGrid.new 3, 3, value: nil

    # Let's create the submap:
    (-1..1).each_with_index do |r, ri|
      (-1..1).each_with_index do |c, ci|
        row = coords[ 0 ] + r
        col = coords[ 1 ] + c

        # Only copy data if we are within the map's bounds:
        if (0..height-1).include? row and (0..width-1).include? col then
          ret[ ri, ci ] = @tiles[ row, col ].clone
        end
      end
    end

    # Finally, return ret:
    return ret
  end

end

