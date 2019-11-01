
local xml      = require("LuaXML_lib")
local _G       = _G
local _VERSION = _VERSION

if _VERSION == "Lua 5.1" then
  module("xml")
else
  _ENV = {}
end

-- symbolic name for tag index, this allows accessing the tag by var[xml.TAG]
TAG = 0

-- sets or returns tag of a LuaXML object
function tag(var,tag)
  if _G.type(var)~="table" then return end
  if _G.type(tag)=="nil" then 
    return var[TAG]
  end
  var[TAG] = tag
end

-- creates a new LuaXML object either by setting the metatable of an existing Lua table or by setting its tag
function new(arg)
  if _G.type(arg)=="table" then 
    _G.setmetatable(arg,{__index=xml, __tostring=xml.str})
	return arg
  end
  local var={}
  _G.setmetatable(var,{__index=xml, __tostring=xml.str})
  if _G.type(arg)=="string" then var[TAG]=arg end
  return var
end

-- appends a new subordinate LuaXML object to an existing one, optionally sets tag
function append(var,tag)
  if _G.type(var)~="table" then return end
  local newVar = new(tag)
  var[#var+1] = newVar
  return newVar
end

-- converts any Lua var into an XML string
function str(var,indent,tagValue)
  if _G.type(var)=="nil" then return end
  local indent = indent or 0
  local indentStr=""
  for i = 1,indent do indentStr=indentStr.."  " end
  local tableStr=""
  
  if _G.type(var)=="table" then
    local tag = var[0] or tagValue or _G.type(var)
    local s = indentStr.."<"..tag
    for k,v in _G.pairs(var) do -- attributes 
      if _G.type(k)=="string" then
        if _G.type(v)=="table" and k~="_M" then --  otherwise recursiveness imminent
          tableStr = tableStr..str(v,indent+1,k)
        else
          s = s.." "..k.."=\""..encode(_G.tostring(v)).."\""
        end
      end
    end
    if #var==0 and #tableStr==0 then
      s = s.." />\n"
    elseif #var==1 and _G.type(var[1])~="table" and #tableStr==0 then -- single element
      s = s..">"..encode(_G.tostring(var[1])).."</"..tag..">\n"
    else
      s = s..">\n"
      for k,v in _G.ipairs(var) do -- elements
        if _G.type(v)=="string" then
          s = s..indentStr.."  "..encode(v).." \n"
        else
          s = s..str(v,indent+1)
        end
      end
      s=s..tableStr..indentStr.."</"..tag..">\n"
    end
    return s
  else
    local tag = _G.type(var)
    return indentStr.."<"..tag.."> "..encode(_G.tostring(var)).." </"..tag..">\n"
  end
end


-- saves a Lua var as xml file
function save(var,filename)
  if not var then return end
  if not filename or #filename==0 then return end
  local file = _G.io.open(filename,"w")
  file:write("<?xml version=\"1.0\"?>\n<!-- file \"",filename, "\", generated by LuaXML -->\n\n")
  file:write(str(var))
  _G.io.close(file)
end


-- recursively parses a Lua table for a substatement fitting to the provided tag and attribute
function find(var, tag, attributeKey,attributeValue)
  -- check input:
  if _G.type(var)~="table" then return end
  if _G.type(tag)=="string" and #tag==0 then tag=nil end
  if _G.type(attributeKey)~="string" or #attributeKey==0 then attributeKey=nil end
  if _G.type(attributeValue)=="string" and #attributeValue==0 then attributeValue=nil end
  -- compare this table:
  if tag~=nil then
    if var[0]==tag and ( attributeValue == nil or var[attributeKey]==attributeValue ) then
      _G.setmetatable(var,{__index=xml, __tostring=xml.str})
      return var
    end
  else
    if attributeValue == nil or var[attributeKey]==attributeValue then
      _G.setmetatable(var,{__index=xml, __tostring=xml.str})
      return var
    end
  end
  -- recursively parse subtags:
  for k,v in _G.ipairs(var) do
    if _G.type(v)=="table" then
      local ret = find(v, tag, attributeKey,attributeValue)
      if ret ~= nil then return ret end
    end
  end
end

if _VERSION >= "Lua 5.2" then
  return _ENV
end
