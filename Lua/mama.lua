
             require "org.conman.math".randomseed()
local lpeg = require "lpeg"

local mama =
{
  "parent",
  "ancestor",
  "creator",
  "originator",
  "caretaker",
  "sustainer",
}

local pi =
{
  "of",
}

local mi =
{
  "I",
  "me",
  "we",
  "us",
}

local mute =
{
  "many",
  "a lot",
  "more",
  "much",
  "several",
  "very",
}

local o = 
{
  "hey!",
  "O!",
}

local sina =
{
  "you",
}

local lon =
{
  "located at",
  "present at",
  "real",
  "true",
  "existing",
}

local sewi =
{
  "awe-inspiring",
  "divine",
  "sacred",
  "supernatural",
}

local kon =
{
  "air",
  "breath",
  "essence",
  "spirit",
  "hidden reality",
  "unseen agent",
}

local our_father =
{
  { word = mama },
  { word = pi } ,
  { word = mi },
  { word = mute } ,
  { word = o },
  { word = sina },
  { word = lon },
  { word = sewi },
  { word = kon },
}

local function generate(list,idx,acc,translations)
  if idx > #list then
    table.insert(translations,table.concat(acc," "))
  else
    for i = 1 , #list[idx].word do
      acc[idx] = list[idx].word[i]
      generate(list,idx+1,acc,translations)
    end
  end
end

local wordcount do
  local word  = lpeg.R"!~"^1 * lpeg.Cc(1)
  local space = lpeg.P" "    * lpeg.Cc(0)
  wordcount   = lpeg.Cf(
                  lpeg.Cc(0) * (word + space)^1,
                  function(a,b) return a + b end
                )
end

local count = 0 
local LIST  = {}
generate(our_father,1,{},LIST)

while count < 50000 do
  local line = LIST[math.random(#LIST)]
  print(line)
  count = count + wordcount:match(line)
end
