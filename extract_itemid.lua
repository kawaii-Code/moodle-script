local s = arg[1]

local sesskeyBegin = string.find(s, 'itemid=')
sesskeyBegin = sesskeyBegin + string.len('itemid=')
local sesskeyEnd = string.find(s, '&', sesskeyBegin)
sesskeyEnd = sesskeyEnd - 1

print(string.sub(s, sesskeyBegin, sesskeyEnd))
