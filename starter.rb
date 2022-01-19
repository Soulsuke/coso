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



require 'ruby2d'
require 'yaml'
require_relative 'lib/area'
require_relative 'lib/renderer'

# License output:
puts 'Coso - the exploring thingy Copyright (C) 2021  Maurizio Oliveri'
puts 'This program comes with ABSOLUTELY NO WARRANTY.'
puts 'This is free software, and you are welcome to redistribute it'
puts 'under certain conditions. Check LICENSE for details.'

# Load config file:
config = YAML.load_file 'resources/config.yml'

# Quit on SIGINT:
Signal.trap "INT" do
  close
end

# Set the process name:
Process.setproctitle config[ :name ].scan( /[A-z0-9]*/ ).reject( &:empty? )
  .join '_'

# Renderer init:
renderer = Renderer.new config[ :renderer ],
  Area.new( config[ :area ] )

# Set window properties:
set title: config[ :name ],
  background: renderer.background,
  width: renderer.width,
  height: renderer.height

# Render the initial window:
renderer.start

# Update the map status:
tick = 1
update do
  if tick % 30 == 0 then
    renderer.tick
    tick = 0
  end
  tick += 1
end

# Show the window:
show

