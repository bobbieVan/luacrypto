#!/usr/local/bin/lua50

--[[
-- $Id: test.lua,v 1.4 2006-09-04 20:32:57 nezroy Exp $
-- See Copyright Notice in license.html
--]]

require("crypto")
local evp = crypto.evp
local hmac = crypto.hmac

md5_KNOWN = "09920f6f666f8e7b09a8d00bd4d06873"
sha1_KNOWN = "d6ed6e26ebeb37ba0792ec75a3d0b4dcec279d25"
hmac_KNOWN = "70a7ea81a287d094c534cdd67be82e85066e13be"

print("LuaCrypto version: " .. crypto._VERSION)
print("LuaCrypto engine: " .. crypto._ENGINE)
print("")

function report(w, s, F, t)
  print(w, s .. "  " .. F)
  assert(s == _G[t .. "_KNOWN"])
end

F = arg[1]
for i, t in ipairs({"sha1", "md5", "sha1", "hmac"}) do
  print("testing " .. t)
  local d
  if (t == "hmac") then
    d = hmac.new("sha1", "luacrypto")
  else
    d = evp.new(t)
  end
  
  assert(io.input(F))
  report("all", d:digest(io.read("*all")), F, t)
  
  d:reset(d)
  
  assert(io.input(F))
  while true do
   local c = io.read(1)
   if c == nil then break end
   d:update(c)
  end
  report("loop", d:digest(), F, t)
  if (t ~= "hmac") then
    report("again", d:digest(), F, t)
    assert(io.input(F))
    report("alone", evp.digest(t, io.read("*all")), F, t)
  else
    assert(io.input(F))
    report("alone", hmac.digest("sha1", io.read("*all"), "luacrypto"), F, t);
  end
  
  assert(io.input(F))
  d:reset()
  while true do
   local c = io.read(math.random(1, 16))
   if c == nil then break end
   d:update(c)
  end
  report("reset", d:digest(d), F, t)
  report("known", _G[t .. "_KNOWN"], F, t)
  print("")
end

print("all tests passed")
