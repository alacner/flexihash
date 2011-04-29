require "print_r"
require "Flexihash"

local flexihash = Flexihash.New()
flexihash:addTarget('a')
flexihash:addTarget('b')
flexihash:addTarget('c')
flexihash:addTarget('d')
flexihash:addTarget('e')
print_r(flexihash:getAllTargets());
local t = flexihash:lookupList('d', 3)
print_r(t)
local t = flexihash:lookupList('f', 3)
print_r(t)
local t = flexihash:lookupList('g', 3)
print_r(t)

local t = flexihash:lookup('h')
print_r(t)
