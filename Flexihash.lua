--Copyright (c) 2011-2015 Zhihua Zhang (alacner@gmail.com)

--Flexihash - A simple consistent hashing implementation for Lua.

module('Flexihash', package.seeall)

function New()
	local hasher, replicas = ...
	--The number of positions to hash each target to.
	local replicas = 64

	--The hash algorithm, encapsulated in a Flexihash_Hasher implementation.
	local hasher

	--Internal counter for current number of targets.
	local targetCount = 0

	--Internal map of positions (hash outputs) to targets
	--@var array { position => target, ... }
	local positionToTarget = {}

	--Internal map of targets to lists of positions that target is hashed to.
	--@var array { target => [ position, position, ... ], ... }
	local targetToPositions = {}

	--Whether the internal map of positions to targets is already sorted.
	--@var boolean
	local positionToTargetSorted = false
end
