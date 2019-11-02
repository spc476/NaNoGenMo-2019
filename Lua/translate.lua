
local lpeg = require "lpeg"

local DICT,LIST do
  local word = lpeg.C(lpeg.R"az"^1) * (lpeg.P" or " * lpeg.C(lpeg.R"az"^1))^-1
  DICT = {}
  LIST = {}
  
  local f = io.open("../data/dictionary.txt","r")
  while true do
    local toki  = f:read("l")
    if not toki then break end
    local w1,w2 = word:match(toki)
    
    local function getdef(res)
      local line = f:read("l")
      if line == "" then
        return table.concat(res,"\n")
      end
      table.insert(res,line)
      return getdef(res)
    end
    
    local def = getdef{}
    table.insert(LIST,w1)
    DICT[w1] = def
    if w2 then
      table.insert(LIST,w2)
      DICT[w2] = def
    end
  end
  
  table.sort(LIST)
end

local TRANS do
  local word    = lpeg.C(lpeg.R"az"^1)
                + lpeg.P"\n"  * lpeg.Cc""
  local nonword = -lpeg.R"az" * lpeg.C(lpeg.R("AZ","az")^1)
  local punct   = lpeg.S".,?"
  local space   = lpeg.P" "
  local parse   = lpeg.Ct((word + nonword + punct + space)^1)
  
  local f = io.open("../data/prayer.txt","r")
  TRANS   = parse:match(f:read("a"))
  f:close()
end

for _,toki in ipairs(TRANS) do
  if toki == "" then
    print()
    print("------")
    print()
  elseif not DICT[toki] then
    print(toki)
  else
    print(toki)
    print(DICT[toki])
    print()
  end
end
