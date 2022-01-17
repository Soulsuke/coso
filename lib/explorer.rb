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



require_relative "map.rb"



=begin
Explorer class.  

Represents an explorer who will have to move within an explorable area.
=end
class Explorer

  #############################################################################
  ### Attributes                                                            ###
  #############################################################################

  # Current status:
  attr_reader :status

  # Map:
  attr_reader :map

  # Color:
  attr_reader :color

  # Position on own map:
  attr_reader :position

  # Last movement performed:
  attr_reader :last_movement

  # Explored tile color:
  attr_reader :explored_color


  #############################################################################
  ### Public methods                                                        ###
  #############################################################################

  # Constructor.
  def initialize( explorer_data, spawn_tile )
    @color = explorer_data[ :color ]
    @explored_color = explorer_data[ :explored_tile_color ]
    @map = Map.new spawn_tile.merge( explored: true )
    @position = [ 0, 0 ]
    @status = :exploring
    @last_movement = nil
  end



  # Moves in the given proximity.
  # Returns a movement vector and if the map has been expanded.
  def move( proximity )
    # Return value container:
    ret = {
      coords: [ 0, 0 ],
      expanded: false
    }

    # Do nothing if we're done:
    return ret if @status != :exploring

    # Save this old info:
    ret[ :expanded ] = [ @map.height, @map.width ]

    # Update the explorer's map with the given proximity:
    add_to_map proximity

    # Update ret's value:
    ret[ :expanded ] = ret[ :expanded ] != [ @map.height, @map.width ]

    # Process the proximity data a little:
    3.times do |r|
      3.times do |c|
        unless proximity[ r, c ].nil? then
          # Blank diagonal tiles and obstacles:
          if (r + c) % 2 == 0 or proximity[ r, c ][ :obstacle ] then
            proximity[ r, c ] = nil

          # For each remanining available tile, add in the right explored
          # value from the map:
          else
            proximity[ r, c ] = proximity[ r, c ].merge(
              {
                explored: @map
                  .tiles[ @position[ 0 ] + r - 1, @position[ 1 ] + c - 1 ][
                    :explored
                  ]
              }
            )
          end
        end
      end
    end

    # Check if the exit is in proximity, and if so move in there:
    found_exit = proximity.find_index { |m| !m.nil? and m[ :type ] == :exit }

    # If we've found it, move on there:
    if !found_exit.nil? then
      @status = :found_exit
      ret[ :coords ] = move_to_proximity found_exit

    # This only happens at the very first movement attempt:
    elsif @last_movement.nil? then
      # Attempt to find a tile where we can move to:
      tile = proximity.find_index { |m| !m.nil? }

      # If this is true, it means we're already stuck:
      if tile.nil? then
        @status = :stuck

      # Else, move once:
      else
        ret[ :coords ] = move_to_proximity tile
      end

    # If we're moving normally:
    else

      # Attempt to find the first unexplored tile:
      tile = proximity.find_index do |m|
        !m.nil? and m[ :explored ] == false
      end

      # If we've found one, move in there:
      if !tile.nil? then
        ret[ :coords ] = move_to_proximity tile

      # Else we gotta understand what to do:
      else
        # Backtrack tile to avoid:
        back_coords = @last_movement.map { |e| (e - 1).abs }
        back_tile = proximity[ *back_coords ].clone
        proximity[ *back_coords ] = nil

        # Attempt to move forward without backtracking:
        tile = proximity.find_index { |m| !m.nil? }

        # If we didn't find anything, we gotta go back:
        if tile.nil? then
          ret[ :coords ] = move_to_proximity back_coords

        # Else, keep going:
        else
          ret[ :coords ] = move_to_proximity tile
        end
      end
    end

    # Finally, return ret:
    return ret
  end



  #############################################################################
  ### Private methods                                                       ###
  #############################################################################

  private



  # Updates the map using the given proximity data.
  def add_to_map( proximity )
    # Process every row:
    proximity.row_vectors.each_with_index do |row, row_idx|
      # Map row to update:
      map_row = @position[ 0 ] + row_idx - 1

      # Process every column:
      row.each_with_index do |col, col_idx|
        next if proximity[ row_idx, col_idx ].nil?

        # Map column to update:
        map_col = @position[ 1 ] + col_idx - 1

        # Check if we have to add in a new top row:
        if map_row < 0 then
          @map.tiles = Matrix.rows(
            @map.tiles.to_a.insert( 0, [ nil ] * @map.width )
          )

          # Also update the current position to keep it within the bounds:
          @position[ 0 ] += 1
          map_row += 1

        # Check if we have to add a new bottom row:
        elsif map_row == @map.height then
          @map.tiles = Matrix.rows(
            @map.tiles.to_a << [ nil ] * @map.width
          )
        end

        # Check if we have to add a new left column:
        if map_col < 0 then
          # Add in the new column:
          @map.tiles = Matrix.columns(
            @map.tiles.column_vectors.insert( 0, [ nil ] * @map.height )
          )

          # Also update the current position to keep it within the bounds:
          @position[ 1 ] += 1
          map_col += 1

        # Or if we have to add a new right column:
        elsif map_col == @map.width then
          @map.tiles = Matrix.columns(
             @map.tiles.column_vectors << [ nil ] * @map.height
          )
        end

        # Add in the tile only if we should:
        if !proximity[ row_idx, col_idx ].nil? and
           @map.tiles[ map_row, map_col ].nil? then
          @map.tiles[ map_row, map_col ] = proximity[ row_idx, col_idx ]
            .merge( { explored: false } )
        end
      end
    end
  end



  # Moves the bot to the given proximity location.
  # Returns a movement vector.
  def move_to_proximity( coords )
    # Return value container:
    ret = Array.new

    # Turn the coordinates into movement ones:
    ret = coords.map { |e| e - 1 }

    # Update the current position accordingly:
    2.times do |idx|
      @position[ idx ] += ret[ idx ]
    end

    # Mark down this movement:
    @last_movement = ret

    # Update the new tile as explored:
    @map.tiles[ *@position ][ :explored ] = true

    # Finally, return ret:
    return ret
  end

end

