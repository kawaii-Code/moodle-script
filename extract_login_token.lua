local s = arg[1] or io.read('a')

local firstQuote = string.find(s, 'value="')
firstQuote = firstQuote + string.len('value="')
local lastQuote = string.find(s, '"', firstQuote)
lastQuote = lastQuote - 1

print(string.sub(s, firstQuote, lastQuote))
