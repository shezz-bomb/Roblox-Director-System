-- DirectorDecider.lua (Generic AI Director System)
-- Weighted event selection based on metrics and anger level.
-- Prevents repetition and respects cooldowns.

local DirectorDecider = {}
local DirectorMemory = require(script.Parent.DirectorMemory)

-- ==================== CONFIGURATION ====================
-- Cooldowns per event (in seconds)
local EVENT_COOLDOWNS = {
	DefaultEvent = 120,
	-- Add your custom event cooldowns here:
	-- MyCustomEvent = 180,
}

-- ==================== INTERNAL STATE ====================
local lastExecuted = {}

-- ==================== HELPER FUNCTIONS ====================

local function onCooldown(name)
	local last = lastExecuted[name]
	if not last then return false end
	return (tick() - last) < (EVENT_COOLDOWNS[name] or 60)
end

local function getMetric(metrics, key, default)
	local val = metrics[key]
	if type(val) == "boolean" then return default end
	if val == nil then return default end
	return val
end

local function shouldAvoid(eventName)
	-- Avoid if occurred in last 45 seconds
	if DirectorMemory:hasHappenedRecentlySeconds(eventName, 45) then
		return true
	end
	-- Avoid if on a streak of 2 or more
	if DirectorMemory:isOnStreak(eventName, 2) then
		return true
	end
	return false
end

-- ==================== EVENT OPTIONS ====================
-- Each event must have a 'name' and a 'condition' function.
-- The condition receives (metrics, anger) and returns a numeric score.
-- Return 0 if the event is unavailable.

local EVENT_OPTIONS = {
	{
		name = "DefaultEvent",
		condition = function(metrics, anger)
			if onCooldown("DefaultEvent") or shouldAvoid("DefaultEvent") then
				return 0
			end
			-- Base score + modifiers
			local timeFactor = math.min(metrics.timeSinceLastEvent / 30, 2)
			local killBonus = getMetric(metrics, "globalKillRate", 0) * 0.5
			return 10 + (timeFactor * 15) + (metrics.totalPlayers * 5) + killBonus
		end
	},

	-- ===== ADD YOUR CUSTOM EVENTS BELOW =====
	--[[ EXAMPLE:
	{
		name = "MyCustomEvent",
		condition = function(metrics, anger)
			if onCooldown("MyCustomEvent") or shouldAvoid("MyCustomEvent") then
				return 0
			end
			-- Only available when anger > 40 and at least 3 players
			if anger < 40 or metrics.totalPlayers < 3 then
				return 0
			end
			return anger * 1.2 + (metrics.globalKillRate or 0) * 5
		end
	},
	--]]
}

-- ==================== WEIGHTED SELECTION ====================

local function weightedSelect(options, context)
	local candidates = {}
	local totalWeight = 0

	for _, opt in ipairs(options) do
		local score = opt.condition(context.metrics, context.anger)
		if type(score) == "number" and score > 0 then
			table.insert(candidates, { opt = opt, score = score })
			totalWeight = totalWeight + score
		end
	end

	if totalWeight <= 0 or #candidates == 0 then
		return nil, 0
	end

	local roll = math.random() * totalWeight
	local cumulative = 0
	for _, c in ipairs(candidates) do
		cumulative = cumulative + c.score
		if roll <= cumulative then
			return c.opt, c.score
		end
	end

	return candidates[#candidates].opt, candidates[#candidates].score
end

-- ==================== MAIN DECISION METHOD ====================

function DirectorDecider:decide(metrics, anger)
	local context = { metrics = metrics, anger = anger }
	local best, score = weightedSelect(EVENT_OPTIONS, context)

	if not best or score <= 0 then
		return nil
	end

	lastExecuted[best.name] = tick()
	print(string.format("👁️ Director decided: %s (score: %.1f | anger: %.1f)", best.name, score, anger))
	return best.name
end

return DirectorDecider
