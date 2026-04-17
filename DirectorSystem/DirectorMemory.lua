-- DirectorMemory.lua (Generic AI Director System)
-- Persistent memory, event history, streak detection, and special day modifiers.

local DirectorMemory = {}

-- ==================== CONFIGURATION ====================
local MEMORY_DURATION = 3600  -- 1 hour in seconds
local MAX_HISTORY = 200       -- Maximum history entries

-- Day effects (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
local DAY_EFFECTS = {
	[0] = { name = "SUNDAY_CHAOS",    chaosMultiplier = 1.5, description = "The end of the week brings unrest." },
	[1] = { name = "MONDAY_SLOW",     chaosMultiplier = 1.2, description = "A sluggish start." },
	[2] = { name = "TUESDAY_FRENZY",  chaosMultiplier = 3.0, description = "Madness takes hold." },
	[3] = { name = "WEDNESDAY_SILENT", chaosMultiplier = 1.0, description = "An eerie calm." },
	[4] = { name = "THURSDAY_HUNGER", chaosMultiplier = 1.8, description = "Hunger sharpens the senses." },
	[5] = { name = "FRIDAY_ONSLAUGHT", chaosMultiplier = 2.0, description = "The storm approaches." },
	[6] = { name = "SATURDAY_BLITZ",  chaosMultiplier = 3.0, description = "Absolute pandemonium." },
}

-- ==================== INTERNAL STATE ====================
local memory = {}           -- Array of events: {type, time, data}
local eventCounters = {}    -- { [eventType] = totalCount }
local lastEventOfType = {}  -- { [eventType] = timestamp }
local streakCounter = {}    -- { currentEventType, count }

-- ==================== PUBLIC METHODS ====================

-- Register an event in memory
function DirectorMemory:remember(eventType, data)
	self:cleanup()

	eventCounters[eventType] = (eventCounters[eventType] or 0) + 1
	lastEventOfType[eventType] = tick()

	if streakCounter.current == eventType then
		streakCounter.count = (streakCounter.count or 0) + 1
	else
		streakCounter.current = eventType
		streakCounter.count = 1
	end

	table.insert(memory, {
		type = eventType,
		time = tick(),
		data = data or {}
	})

	while #memory > MAX_HISTORY do
		table.remove(memory, 1)
	end
end

-- Remove entries older than MEMORY_DURATION
function DirectorMemory:cleanup()
	local cutoff = tick() - MEMORY_DURATION
	for i = #memory, 1, -1 do
		if memory[i].time < cutoff then
			table.remove(memory, i)
		end
	end
end

-- Check if an event occurred within the last X minutes
function DirectorMemory:hasHappenedRecently(eventType, minutes)
	local cutoff = tick() - (minutes * 60)
	for _, entry in ipairs(memory) do
		if entry.type == eventType and entry.time > cutoff then
			return true
		end
	end
	return false
end

-- Check if an event occurred within the last X seconds (more precise)
function DirectorMemory:hasHappenedRecentlySeconds(eventType, seconds)
	local cutoff = tick() - seconds
	for _, entry in ipairs(memory) do
		if entry.type == eventType and entry.time > cutoff then
			return true
		end
	end
	return false
end

-- Get the current day's effect name
function DirectorMemory:getCurrentDay()
	local weekday = tonumber(os.date("%w"))
	local effect = DAY_EFFECTS[weekday] or DAY_EFFECTS[0]
	return effect.name
end

-- Check if today is a "holy day" (high chaos multiplier)
function DirectorMemory:isHolyDay()
	local weekday = tonumber(os.date("%w"))
	local effect = DAY_EFFECTS[weekday]
	return effect ~= nil and effect.chaosMultiplier >= 2.0
end

-- Get the chaos multiplier for the current day
function DirectorMemory:getChaosMultiplier()
	local weekday = tonumber(os.date("%w"))
	local effect = DAY_EFFECTS[weekday] or DAY_EFFECTS[0]
	return effect.chaosMultiplier
end

-- Get the description for the current day
function DirectorMemory:getDayDescription()
	local weekday = tonumber(os.date("%w"))
	local effect = DAY_EFFECTS[weekday] or DAY_EFFECTS[0]
	return effect.description
end

-- ==================== ADVANCED MEMORY METHODS ====================

-- Total occurrences of an event since server start
function DirectorMemory:getEventCount(eventType)
	return eventCounters[eventType] or 0
end

-- Seconds elapsed since the last occurrence of an event
function DirectorMemory:timeSinceLastEvent(eventType)
	local last = lastEventOfType[eventType]
	if not last then return math.huge end
	return tick() - last
end

-- Check if the same event has repeated X times in a row
function DirectorMemory:isOnStreak(eventType, minCount)
	return streakCounter.current == eventType and (streakCounter.count or 0) >= minCount
end

-- Get the current streak (event name and count)
function DirectorMemory:getCurrentStreak()
	return streakCounter.current, streakCounter.count or 0
end

-- Recommendation: should we avoid this event to prevent annoyance?
function DirectorMemory:shouldAvoidEvent(eventType, avoidSeconds)
	if self:hasHappenedRecentlySeconds(eventType, avoidSeconds) then
		return true, "occurred too recently"
	end
	if self:isOnStreak(eventType, 2) then
		return true, "is on a repeat streak"
	end
	return false
end

-- Get the last N events (for debugging or narrative)
function DirectorMemory:getLastEvents(n)
	n = math.min(n, #memory)
	local result = {}
	for i = #memory - n + 1, #memory do
		if memory[i] then
			table.insert(result, memory[i])
		end
	end
	return result
end

-- Get full statistics (for debugging or admin UI)
function DirectorMemory:getStats()
	local stats = {
		totalEvents = #memory,
		eventCounts = eventCounters,
		lastEvent = memory[#memory],
		currentStreak = { event = streakCounter.current, count = streakCounter.count },
		currentDay = self:getCurrentDay(),
		chaosMultiplier = self:getChaosMultiplier(),
		dayDescription = self:getDayDescription(),
	}
	return stats
end

-- Reset memory (useful for server reboots or testing)
function DirectorMemory:reset()
	memory = {}
	eventCounters = {}
	lastEventOfType = {}
	streakCounter = {}
	print("🧠 DirectorMemory: Memory reset.")
end

-- ==================== INITIALIZATION ====================
local function init()
	print(string.format("📅 DirectorMemory: %s | %s (Chaos x%.1f)", 
		DirectorMemory:getCurrentDay(), 
		DirectorMemory:getDayDescription(), 
		DirectorMemory:getChaosMultiplier()))
end
init()

return DirectorMemory
