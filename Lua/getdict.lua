-- ***********************************************************************
--
-- Copyright 2019 by Sean Conner.
--
-- This program is free software: you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the
-- Free Software Foundation, either version 3 of the License, or (at your
-- option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
-- Public License for more details.
--
-- You should have received a copy of the GNU General Public License along
-- with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Comments, questions and criticisms can be sent to: sean@conman.org
--
-- ***********************************************************************
-- luacheck: ignore 611

local dump   = require "org.conman.table".dump
local xml    = require "LuaXML_lib"
local lxpath = require "lxpath"

local function totext(master)
  for _,node in ipairs(master) do
    local res = ""
    for _,s in ipairs(node) do
      if type(s) == 'string' then
        res = res .. s
      else
        res = res .. " "
      end
    end
    print(res)
  end
end

local f = io.open("../data/pona.xml","r")
local contents = f:read("*a")

f:close()

local doc = xml.eval(contents)
local x   = lxpath(doc,"/office:document-content/office:body/office:spreadsheet/table:table")

for i = 3 , #x do
  for j = 1 , #x[i] do
    totext(x[i][j])
  end
  print()
end
