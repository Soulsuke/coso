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



require "ruby2d"



=begin
Renderer class.

Renders the various components.
=end
class Renderer

  #############################################################################
  ### Attributes                                                            ###
  #############################################################################

  # Rendering settings:
  attr_reader :settings

  # Required window width:
  attr_reader :width

  # Required window height:
  attr_reader :height

  # Background color:
  attr_reader :background

  # Vertical map offset:
  attr_reader :vertical_map_offset

  # Area map width:
  attr_reader :area_width

  # Area map height:
  attr_reader :area_height

  # Explorer's map offset:
  attr_reader :explorer_map_offset

  # Area to render:
  attr_reader :area



  #############################################################################
  ### Public methods                                                        ###
  #############################################################################

  # Constructor.
  # Takes as parameter the rendering settings and the area to render.
  def initialize( settings, area )
    # Store the settings:
    @settings = settings
    @area = area

    # Background color:
    @background = settings[ :background ]
    settings.delete :background

    # Area dimensions:
    @area_width = area.width * settings[ :tile ][ :width ]
    @area_height = area.height * settings[ :tile ][ :height ]

    # Offsets:
    @explorer_map_offset = @area_width + settings[ :map_spacing ]
    @vertical_map_offset = settings[ :text ][ :size ] +
      settings[ :text ][ :padding ] * 2

    # Total window dimensions:
    @width = @area_width + @explorer_map_offset
    @height = @area_height + @vertical_map_offset
  end



  # Renders the initial frame.
  def start
    # Add in some texts:
    Text.new "Area map:",
      y: @settings[ :tile ][ :padding ],
      x: 0,
      size: @settings[ :tile ][ :size ],
      color: @settings[ :text ][ :color ]
    
    Text.new "Explorer's map:",
      y: @settings[ :tile ][ :padding ],
      x: @explorer_map_offset,
      size: @settings[ :tile ][ :size ],
      color: @settings[ :text ][ :color ]

    # Draw the starting area:
    draw_map @area&.map, :area
  end



  # Ticks everything.
  def tick
    # Do nothing if the area hasn't been initialized:
    return if @area.nil?

    # Area tick result:
    result = @area.tick

    # Upate the area map accordingly:
    update_map result[ :coordinates ], :area

    # If the explorer map's proportions have changed, we gotta draw it anew:
    if result[ :explored_map_expanded ] then
      draw_map @area.explorer.map, :explorer

    # Else, we just gotta update the explorers proximity:
    else
      # 3 rows proximity:
      [ -1, 0, 1 ].each do |r|
        # Row to use:
        row = @area.explorer.position[ 0 ] + r

        # Ignore non existing rows:
        next if row < 0 or row == @area.explorer.map.height

        # 3 columns proximity:
        [ -1, 0, 1 ].each do |c|
          # Column to use:
          col = @area.explorer.position[ 1 ] + c

          # Ignore nil tiles, which includes out of bound ones:
          next if @area.explorer.map.tiles[ row, col ].nil?

          # Draw the tile:
          draw_tile [ row, col ], :explorer
        end
      end
    end
  end



  #############################################################################
  ### Private methods                                                       ###
  #############################################################################

  private



  ### Generic
  #############################################################################

  # Draws a single tile.
  def draw_tile( coord, type )
    # X offset to use:
    offset_x = 0

    # If we're processing an area map tile:
    if :area == type then
      # If the explorer is there, use its color::
      if @area.explorer_position == coord then
        color = @area.explorer.color
      # Else use the tile's one:
      else
        color = @area.map.tiles[ *coord ][ :color ]
      end

    # If we're processing an explorer map tile:
    else
      # Set the right offset:
      offset_x = @explorer_map_offset

      # If it's an empty tile, we gotta blank it:
      if @area.explorer.map.tiles[ *coord ].nil? then
        color = @background

      # Else, render it accordingly:
      else
        # If the explorer is there, use its color:
        if @area.explorer.position == coord then
          color = @area.explorer.color
        # If its an explored tile, use the adeguate color:
        elsif @area.explorer.map.tiles[ *coord ][ :explored ] then
          color = @area.explorer.explored_color
        # # Else use the tile's one:
        else
          color = @area.explorer.map.tiles[ *coord ][ :color ]
        end
      end
    end

    # Add in the tile:
    Rectangle.new color: color,
      y: @settings[ :tile ][ :height ] * coord[ 0 ] + @vertical_map_offset,
      x: @settings[ :tile ][ :width ] * coord[ 1 ] + offset_x,
      width: @settings[ :tile ][ :width ],
      height: @settings[ :tile ][ :height ] 
  end



  # Completely draws a map.
  def draw_map( map, type )
    # Do nothing if the map is nil:
    return if map.nil?

    # Draw the initial map:
    map.height.times do |row|
      map.width.times do |col|
        draw_tile [ row, col ], type
      end
    end   
  end



  # Updates only the given coordinates of the given map type.
  def update_map( coords, type )
    # Update all the given coordinates:
    coords.each do |coord|
      # Draw the single tile:
      draw_tile coord, type
    end
  end

end

