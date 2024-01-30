local s = arg[1] or io.read('a')

local itemid = string.find(s, 'itemid=')
itemid = itemid + string.len('itemid=')
local itemend = string.find(s, '&', itemid)
itemend = itemend - 1

print(string.sub(s, itemid, itemend))
