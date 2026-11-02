local home = os.getenv("USERPROFILE")
local dir  = home .. "\\.config\\fastfetch\\"

local function plain_replace(s, find, rep)
  local i, j = s:find(find, 1, true)
  if not i then return s end
  return s:sub(1, i - 1) .. rep .. s:sub(j + 1)
end

local h = tonumber(os.date("%H"))
local sun, moon = "\xEF\x86\x85", "\xEF\x86\x86"
local g
if     h >= 5  and h < 12 then g = sun  .. "  Good morning"
elseif h >= 12 and h < 17 then g = sun  .. "  Good afternoon"
elseif h >= 17 and h < 21 then g = moon .. "  Good evening"
else                           g = moon .. "  Good night" end
g = g .. ", " .. (os.getenv("USERNAME") or "user")

local quotes = {}
local qf = io.open(dir .. "quotes.txt", "r")
if qf then
  for line in qf:lines() do
    line = line:gsub("^\239\187\191", ""):gsub("%s+$", "")
    if #line > 0 then table.insert(quotes, line) end
  end
  qf:close()
end
math.randomseed(os.time())
local q = #quotes > 0 and quotes[math.random(#quotes)] or "Hello, World!"
q = q:gsub("\\", "\\\\"):gsub('"', '\\"')

local tf = io.open(dir .. "template.jsonc", "r")
if tf then
  local t = tf:read("*a"); tf:close()
  t = plain_replace(t, "__GREET__", g)
  t = plain_replace(t, "__QUOTE__", q)
  local tmp = os.getenv("TEMP") .. "\\fastfetch-cmd.jsonc"
  local out = io.open(tmp, "w"); out:write(t); out:close()
  os.execute("cls")
  os.execute('fastfetch -c "' .. tmp .. '"')
end