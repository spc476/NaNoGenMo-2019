-- ***************************************************************
--
-- Copyright 2019 by Sean Conner.  All Rights Reserved.
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or (at your
-- option) any later version.
--
-- This library is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
-- License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this library; if not, see <http://www.gnu.org/licenses/>.
--
-- Comments, questions and criticisms can be sent to: sean@conman.org
--
-- ********************************************************************
-- luacheck: globals lxpath xml
-- luacheck: ignore 611

local lpeg = require "lpeg"
             require "LuaXml"
             
-- **********************************************************************
-- the following is the high level view of the LPeg code that follows it.
-- If I could do folding captures with this, I would, but I can't so I
-- won't.  The two folding captures are marked though.
-- **********************************************************************

--[[

path            <- segment+     -- this is a folding capture
segment         <- {: '/' ID
                      ( '[' S attribute (S ',' S attribute)* S ']')* :}
attribute       <- {: S '@' S ID S '=' S value :}
                    -- this too is a folding capture
value           <- '"' text '"'
text            <- { [^"]+ }
ID              <- { [A-Za-z0-9_-]+ }
S               <- %s*

]]

-- *********************************************************************

local function doset(t,i,v)
  v = v or {}
  t[i] = v
  t[#t+1] = i
  return t
end

local S,P, R     = lpeg.S, lpeg.P,  lpeg.R
local C,Ct,Cf,Cg = lpeg.C, lpeg.Ct, lpeg.Cf, lpeg.Cg

local WS        = S(" \t")^0
local ID        = C(R("AZ","az","09","__","--")^1)
local text      = C((P(1) - P'"')^1)
local value     = P'"' * text * P'"'
local attribute = Cf(Ct("") * Cg(WS * P"@" * WS * ID * WS * P"=" * WS * value),doset)
local segment   = Cg(P"/" * ID * (P"[" * WS * attribute * (WS * P"," * WS * attribute)^0 * WS * P"]")^0)
local path      = Cf(Ct("") * segment^1,doset)

-- *******************************************************************

function lxpath(doc,loc)
  local segments = path:match(loc)
  assert(segments)
  
  local function cmp_attr(document,attr)
    for i = 1 , #attr do
      local name = attr[i]
      local val  = attr[name]
      if document[name] ~= val then return false end
    end
    return true
  end
  
  local function isnode(document,tag,attr)
    if document[0] == tag and cmp_attr(document,attr) then
      return true
    end
    return false
  end
  
  local function find(document,sidx)
    if sidx > #segments then
      return document
    end
    
    for i = 1 , #document do
      if isnode(document[i],segments[sidx],segments[segments[sidx]]) then
        return find(document[i],sidx+1)
      end
    end
    
    return xml.append(document,segments[sidx])
  end
  
  if not isnode(doc,segments[1],segments[segments[1]]) then
    return nil
  end
  
  return find(doc,2)
end

-- *****************************************************************
