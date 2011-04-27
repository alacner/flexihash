require "print_r"
require "Flexihash"

local flexihash = Flexihash.New()
flexihash:addTarget('love')
flexihash:addTarget('fuck')
flexihash:addTarget('hate')
flexihash:addTarget('sock')
flexihash:addTarget('cao')
print_r(flexihash:getAllTargets());
local t = flexihash:lookupList('loveme', 3)
print_r(t)
local t = flexihash:lookupList('tloveme', 3)
print_r(t)
local t = flexihash:lookupList('iloveme', 3)
print_r(t)

local t = flexihash:lookup('iloveme')
print_r(t)
