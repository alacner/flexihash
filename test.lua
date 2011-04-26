require "print_r"
require "Flexihash"

local flexihash = Flexihash.New()
flexihash:addTarget('love')
flexihash:addTarget('fuck')
flexihash:addTarget('hate')
flexihash:addTarget('sock')
print_r(flexihash:getAllTargets());
local t = flexihash:lookupList('loveme', 1)
print_r(t)
--print_r(flexhash:addTargets{'love', 'me', 'i'}:removeTarget('me'))
--print_r(flexhash:removeTarget('me'))
--print_r(flexhash:getAllTargets())
--print_r(flexhash:lookupList('im', 1))
