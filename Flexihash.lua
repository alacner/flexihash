--Copyright (c) 2011-2015 Zhihua Zhang (alacner@gmail.com)

--Flexihash - A simple consistent hashing implementation for Lua.

local nix = require "nix"

module('Flexihash', package.seeall)

Flexihash_Crc32Hasher = {
	hash = function(string) return nix.crc32(string) end
}

Flexihash_Md5Hasher = {
	hash = function(string) return string.sub(nix.md5(string), 0, 8) end -- 8 hexits = 32bit
}

local function array_keys_values(tbl)
	local keys, values = {}, {}
	for k,v in pairs(tbl) do
		table.insert(keys, k)
		table.insert(values, v)
	end
	return keys, values
end

local function __toString(this)
end

--[[
-- Sorts the internal mapping (positions to targets) by position
--]]
local function _sortPositionTargets(this)
	-- sort by key (position) if not already
	if not this._positionToTargetSorted then
		this._sortedPositions = array_keys_values(this._positionToTarget)
		table.sort(this._sortedPositions)
		this._positionToTargetSorted = true
	end
end

--[[
-- Add a target.
-- @param string target
--]]
local function addTarget(this, target)
	if this._targetToPositions[target] then
		return false, "Target '" .. target .."' already exists."
	end

	this._targetToPositions[target] = {}

	-- hash the target into multiple positions
	for i = 0, this._replicas-1 do
		local position = this._hasher(target .. i)
		this._positionToTarget[position] = target -- lookup
		table.insert(this._targetToPositions[target], position) -- target removal
	end

	this._positionToTargetSorted = false;
	this._targetCount = this._targetCount + 1
	return this
end

--[[
-- Add a list of targets.
--@param table targets
--]]
local function addTargets(this, targets)
	for k,target in pairs(targets) do
		addTarget(this, target)
	end
	return this
end

--[[
-- Remove a target.
-- @param string target
--]]
local function removeTarget(this, target)
	if not this._targetToPositions[target] then
		return false, "Target '" .. target .. "' does not exist."
	end

	for k,position in pairs(this._targetToPositions[target]) do
		if this._positionToTarget[position] then
			this._positionToTarget[position] = nil
		end
	end

	this._targetToPositions[target] = nil
	this._targetCount = this._targetCount - 1

	return this
end

--[[
-- A list of all potential targets
-- @return array
--]]
local function getAllTargets(this)
	local targets = {}
	for target,v in pairs(this._targetToPositions) do
		table.insert(targets, target)
	end
	return targets
end

--[[
-- Get a list of targets for the resource, in order of precedence.
-- Up to $requestedCount targets are returned, less if there are fewer in total.
--
-- @param string resource
-- @param int requestedCount The length of the list to return
-- @return table List of targets
--]]
local function lookupList(this, resource, requestedCount)
	if tonumber(requestedCount) == 0 then
		return {}, 'Invalid count requested'
	end

	-- handle no targets
	if this._targetCount == 0 then
		return {}
	end

	-- optimize single target
	if this._targetCount == 1 then
		local keys, values = array_keys_values(this._positionToTarget)
		return {values[1]}
	end

	-- hash resource to a position
	local resourcePosition = this._hasher(resource)

	local results, _results = {}, {}
	local collect = false;

	this._sortPositionTargets(this)

	-- search values above the resourcePosition
	for i,key in ipairs(this._sortedPositions) do
		-- start collecting targets after passing resource position
		if (not collect) and key > resourcePosition then
			collect = true
		end

		value = this._positionToTarget[key]

		-- only collect the first instance of any target
		if collect and (not _results[value]) then
			table.insert(results, value)
			_results[value] = true
		end
		-- return when enough results, or list exhausted
		if #results == requestedCount or #results == this._targetCount then
			return results
		end
	end

	-- loop to start - search values below the resourcePosition
	for i,key in ipairs(this._sortedPositions) do
		value = this._positionToTarget[key]

		if not _results[value] then
			table.insert(results, value)
			_results[value] = true
		end
		-- return when enough results, or list exhausted
		if #results == requestedCount or #results == this._targetCount then
			return results
		end
	end

	-- return results after iterating through both "parts"
	return results
end

--[[
-- Looks up the target for the given resource.
-- @param string resource
-- @return string
--]]
local function lookup(this, resource)
	targets = this.lookupList(this, resource, 1)
	if not #targets == 0 then
		return false, 'No targets exist'
	end
	return targets[1]
end

function New(...)
	local hasher, replicas = ...

	if type(hasher) ~= 'function' then
		hasher = hasher or Flexihash_Crc32Hasher.hash
	end

	replicas = replicas or 64

	local this = {
		_replicas = replicas, --The number of positions to hash each target to.
		_hasher = hasher, --The hash algorithm, encapsulated in a Flexihash_Hasher implementation.
		_targetCount = 0, --Internal counter for current number of targets.
		_positionToTarget = {}, --Internal map of positions (hash outputs) to targets @var array { position => target, ... }
		_targetToPositions = {}, --Internal map of targets to lists of positions that target is hashed to. @var array { target => [ position, position, ... ], ... }
		_sortedPositions = {},
		_positionToTargetSorted = false, --Whether the internal map of positions to targets is already sorted.
		_sortPositionTargets = _sortPositionTargets,
		addTarget = addTarget,
		addTargets = addTargets,
		removeTarget = removeTarget,
		getAllTargets = getAllTargets,
		lookupList = lookupList,
		lookup = lookup
	}

	return this
end
