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



require "matrix"



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

  # Current width:
  attr_reader :width

  # Current height:
  attr_reader :height



  #############################################################################
  ### Public methods                                                        ###
  #############################################################################

  # Constructor.
  def initialize( data, biome = nil )
    # If no biome has been given, init the explorer's map:
    if biome.nil? then
      @tiles = Matrix[ [ data ] ]
      @width = 1
      @height = 1

    # Else, create a randomly generated map:
    else
      @width = data[ :width ]
      @height = data[ :height ]

      # Set a dummy tiles matrix:
      @tiles = Matrix[
        *data[ :height ].times.map { [ nil ] * data[ :width ] }
      ]

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
            biome_chances.find do |c|
              c[ :start ] <= pick and c[ :end ] >= pick
            end[ :idx ]
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



  # Returns a 3x3 submap of the surroinding to the given coordinates.
  def surrounding_area( coords )
    # Return value container:
    ret = Matrix[ *3.times.map { [ nil ] * 3 } ]

    # Let's create the submap:
    [ -1, 0, 1 ].each_with_index do |r, ri|
      [ -1, 0, 1 ].each_with_index do |c, ci|
        row = coords[ 0 ] + r
        col = coords[ 1 ] + c
        if row < 0 or row >= @height or col < 0 or col >= @width then
          ret[ ri, ci ] = nil
        else
          ret[ ri, ci ] = @tiles[ coords[ 0 ] + r, coords[ 1 ] + c ]
        end
      end
    end

    # Finally, return ret:
    return ret
  end



  # Custom tiles updater.
  def tiles=( tiles )
    @tiles = tiles
    @width = @tiles.column_vectors.size
    @height = @tiles.row_vectors.size
  end

end

