local s = arg[1]

local sesskeyBegin = string.find(s, 'sesskey=')
sesskeyBegin = sesskeyBegin + string.len('sesskey=')
local sesskeyEnd = string.find(s, '"', sesskeyBegin)
sesskeyEnd = sesskeyEnd - 1

print(string.sub(s, sesskeyBegin, sesskeyEnd))
