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



require_relative "explorer.rb"
require_relative "map.rb"



=begin
Area class.  

Represents an explorable area.
=end
class Area

  #############################################################################
  ### Attributes                                                            ###
  #############################################################################

  # Biome:
  attr_reader :biome

  # Map:
  attr_reader :map

  # Explorer:
  attr_reader :explorer

  # Width:
  attr_reader :width

  # Height:
  attr_reader :height

  # Explorer's position:
  attr_reader :explorer_position



  #############################################################################
  ### Public methods                                                        ###
  #############################################################################

  # Constructor.
  def initialize( data )
    @biome = data[ :biome ]
    @width = data[ :width ]
    @height = data[ :height ]
    data.delete :biome
    @map = Map.new data, biome
    @explorer = Explorer.new data[ :explorer ], data[ :spawn_tile ]
    @explorer_position = @map.spawn
  end



  # Add an explorer to the area.
  def tick
    # This is the area the explorer should evaluate for his next move:
    surroundings = @map.surrounding_area @explorer_position

    # Save the old position:
    old_position = @explorer_position.clone

    # Move the explorer:
    data = @explorer.move @map.surrounding_area @explorer_position

    # Update the explorer's position:
    2.times do |idx|
      @explorer_position[ idx ] += data[ :coords ][ idx ]
    end

    # Return the data to render:
    return {
      status: @explorer.status,
      coordinates: [ old_position, @explorer_position ],
      explored_map_expanded: data[ :expanded ]
    }
  end

end

