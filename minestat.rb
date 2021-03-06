# $Id$
# minestat.rb - A Minecraft server status checker
# Copyright (C) 2014 Lloyd Dilley
# http://www.devux.org/projects/minestat/
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

require 'socket'

class MineStat
  NUM_FIELDS = 6         # number of values expected from server

  def initialize(address, port)
    @address = address
    @port = port
    @online              # online or offline?
    @version             # Minecraft server version
    @motd                # message of the day
    @current_players     # current number of players online
    @max_players         # maximum player capacity

    begin
      server = TCPSocket.new(address, port)
      server.write("\xFE\x01")
      data=server.gets()
      server.close()
    rescue Errno::ECONNREFUSED => e
      @online = false
    rescue => e
      @online = false
    end

    if data == nil || data.empty?
      @online = false
    else
      server_info = data.split("\x00\x00\x00")
      if server_info != nil && server_info.length >= NUM_FIELDS
        @online = true
        @version = server_info[2]
        @motd = server_info[3]
        @current_players = server_info[4]
        @max_players = server_info[5]
      else
        @online = false
      end
    end
  end

  attr_reader :address, :port, :online, :version, :motd, :current_players, :max_players
end
