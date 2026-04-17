-- DirectorMonitor.lua (Generic AI Director System)
-- Collects game metrics and calculates the anger level using multiple weighted factors.
-- NEVER uses Heartbeat. Reacts only to game events (kills, ability usage, duels, etc.)

local DirectorMonitor = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ==================== INTERNAL STATE ====================
local state = {
	angerLevel = 0,
	lastEventTime = 0,
	lastRecalcTime = 0,
	metrics = {},
	-- History for trend detection
	metricHistory = {},
	-- Counters for rate calculations
	lastTotalKills = 0,
	lastTotalPowerUses = 0,
	lastTotalDuels = 0,
	lastTimestamp = 0,
}

-- ==================== CONFIGURATION ====================
local ANGER_CONFIG = {
	HEALTH_FACTOR_MAX      = 50,   -- Max points if average health is 0
	TIME_FACTOR_MAX        = 50,   -- Max points if 5 minutes without events
	DOMINANCE_FACTOR_MAX   = 60,   -- Max points if one team/class >80%
	BOREDOM_FACTOR_MAX     = 30,   -- Max points if less than 3 players
	KILL_RATE_FACTOR_MAX   = 40,   -- Max points if kill rate >10 per minute
	POWER_USAGE_FACTOR_MAX = 30,   -- Max points if power usage is high
	STREAK_FACTOR_MAX      = 35,   -- Max points for high kill streaks
	DUEL_FACTOR_MAX        = 25,   -- Max points for many active duels
}

-- ==================== ADVANCED METRICS ====================

function DirectorMonitor:getMetrics()
	local now = tick()
	local timeDelta = math.max(0.1, now - (state.lastRecalcTime or now))

	local metrics = {
		totalPlayers = 0,
		averageHealth = 0,
		teamCount = {},          -- generic: count per team/class/type
		timeSinceLastEvent = tick() - state.lastEventTime,
		topPlayer = nil,
		topPlayerKills = 0,
		topPlayerStreak = 0,
		noobPlayers = {},        -- players with low kills
		-- Advanced metrics
		globalKillRate = 0,
		powerUsageRate = 0,
		avgStreak = 0,
		totalActiveDuels = 0,
		highestStreak = 0,
		dominantTeam = nil,
		dominanceRatio = 0,
	}

	local healthSum = 0
	local playerCount = 0
	local totalKills = 0
	local totalStreaks = 0
	local totalPowerUses = 0
	local totalActiveDuels = 0

	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				healthSum += hum.Health
				playerCount += 1

				-- Team/class identification (generic: use "Team" attribute or fallback)
				local team = player:GetAttribute("Team") or player.Team and player.Team.Name or "Default"
				metrics.teamCount[team] = (metrics.teamCount[team] or 0) + 1

				local kills = player:GetAttribute("Kills") or 0
				local streak = player:GetAttribute("Streak") or 0
				local powerUses = player:GetAttribute("PowerUses") or 0

				totalKills += kills
				totalStreaks += streak
				totalPowerUses += powerUses

				if kills > metrics.topPlayerKills then
					metrics.topPlayerKills = kills
					metrics.topPlayer = player
					metrics.topPlayerStreak = streak
				end

				if streak > metrics.highestStreak then
					metrics.highestStreak = streak
				end

				if kills <= 2 then
					table.insert(metrics.noobPlayers, player)
				end

				if player:GetAttribute("InDuel") then
					totalActiveDuels += 1
				end
			end
		end
	end

	metrics.totalPlayers = playerCount
	if playerCount > 0 then
		metrics.averageHealth = healthSum / playerCount
		metrics.avgStreak = totalStreaks / playerCount
	else
		metrics.averageHealth = 100
	end
	metrics.totalActiveDuels = totalActiveDuels

	-- Calculate rates (kills and power uses per minute)
	if state.lastTimestamp > 0 and timeDelta > 0 then
		local killsDelta = totalKills - state.lastTotalKills
		local powerDelta = totalPowerUses - state.lastTotalPowerUses
		metrics.globalKillRate = (killsDelta / timeDelta) * 60
		metrics.powerUsageRate = (powerDelta / timeDelta) * 60
	end

	-- Update state for next time
	state.lastTotalKills = totalKills
	state.lastTotalPowerUses = totalPowerUses
	state.lastTotalDuels = totalActiveDuels
	state.lastTimestamp = now
	state.lastRecalcTime = now

	-- Identify dominant team/class
	local maxCount = 0
	for team, count in pairs(metrics.teamCount) do
		if count > maxCount then
			maxCount = count
			metrics.dominantTeam = team
		end
	end
	if playerCount > 0 then
		metrics.dominanceRatio = maxCount / playerCount
	end

	state.metrics = metrics

	-- Store in history (last 10 entries)
	table.insert(state.metricHistory, {
		time = now,
		killRate = metrics.globalKillRate,
		anger = state.angerLevel,
		averageHealth = metrics.averageHealth
	})
	while #state.metricHistory > 10 do table.remove(state.metricHistory, 1) end

	return metrics
end

-- ==================== ANGER CALCULATION ====================

function DirectorMonitor:calculateAnger()
	local metrics = self:getMetrics()

	-- 1. Health factor (lower health = more anger)
	local healthFactor = (100 - metrics.averageHealth) * (ANGER_CONFIG.HEALTH_FACTOR_MAX / 100)

	-- 2. Time without events (boredom)
	local timeSinceLast = math.min(metrics.timeSinceLastEvent, 300) -- max 5 min
	local timeFactor = (timeSinceLast / 300) * ANGER_CONFIG.TIME_FACTOR_MAX

	-- 3. Dominance factor (if one team >60%)
	local dominanceFactor = 0
	if metrics.dominanceRatio > 0.6 then
		local excess = metrics.dominanceRatio - 0.6
		dominanceFactor = math.min(excess * 100, 1) * ANGER_CONFIG.DOMINANCE_FACTOR_MAX
	end

	-- 4. Boredom factor (few players)
	local boredomFactor = 0
	if metrics.totalPlayers < 3 then
		boredomFactor = ANGER_CONFIG.BOREDOM_FACTOR_MAX
	elseif metrics.totalPlayers < 5 then
		boredomFactor = ANGER_CONFIG.BOREDOM_FACTOR_MAX * 0.5
	end

	-- 5. Kill rate factor
	local killRateFactor = 0
	if metrics.globalKillRate > 0 then
		killRateFactor = math.min(metrics.globalKillRate / 10, 1) * ANGER_CONFIG.KILL_RATE_FACTOR_MAX
	end

	-- 6. Power usage factor
	local powerFactor = 0
	if metrics.powerUsageRate > 0 then
		powerFactor = math.min(metrics.powerUsageRate / 20, 1) * ANGER_CONFIG.POWER_USAGE_FACTOR_MAX
	end

	-- 7. Streak factor
	local streakFactor = 0
	if metrics.highestStreak >= 10 then
		streakFactor = ANGER_CONFIG.STREAK_FACTOR_MAX
	elseif metrics.highestStreak >= 5 then
		streakFactor = ANGER_CONFIG.STREAK_FACTOR_MAX * 0.6
	elseif metrics.highestStreak >= 3 then
		streakFactor = ANGER_CONFIG.STREAK_FACTOR_MAX * 0.3
	end

	-- 8. Duel factor
	local duelFactor = math.min(metrics.totalActiveDuels, 5) / 5 * ANGER_CONFIG.DUEL_FACTOR_MAX

	local anger = healthFactor + timeFactor + dominanceFactor + boredomFactor
		+ killRateFactor + powerFactor + streakFactor + duelFactor

	-- Apply day multiplier (optional, requires DirectorMemory)
	local success, DirectorMemory = pcall(require, script.Parent.DirectorMemory)
	if success and DirectorMemory.getChaosMultiplier then
		anger = anger * DirectorMemory:getChaosMultiplier()
	end

	state.angerLevel = math.clamp(anger, 0, 100)

	-- Debug output (uncomment if needed)
	-- print(string.format("📊 Anger: %.1f | health=%.1f time=%.1f dom=%.1f kills=%.1f power=%.1f streak=%.1f duel=%.1f",
	--	state.angerLevel, healthFactor, timeFactor, dominanceFactor, killRateFactor, powerFactor, streakFactor, duelFactor))

	return state.angerLevel
end

-- ==================== EVENT HOOKS (call these from your game) ====================

-- Called when a kill occurs
function DirectorMonitor:onKill(killer, victim)
	self:calculateAnger()
end

-- Called when a player uses an ability/power
function DirectorMonitor:onPowerUsed(player)
	local current = player:GetAttribute("PowerUses") or 0
	player:SetAttribute("PowerUses", current + 1)
end

-- Called on slot rotation (if you have a manager that rotates abilities)
function DirectorMonitor:onSlotRotation()
	self:getMetrics()
	self:calculateAnger()

	-- Optional: integrate with CalendarService (generic)
	local success, CalendarService = pcall(require, script.Parent.Parent.Dependencies.CalendarService)
	if success then
		local metrics = state.metrics
		if metrics.topPlayer then
			CalendarService:punishDominant(metrics.topPlayer, metrics.topPlayerKills)
		end
		for _, noob in ipairs(metrics.noobPlayers) do
			CalendarService:rewardNoob(noob, noob:GetAttribute("Kills") or 0)
		end
	end
end

-- Duel hooks
function DirectorMonitor:onDuelStart(player)
	player:SetAttribute("InDuel", true)
	self:calculateAnger()
end

function DirectorMonitor:onDuelEnd(player)
	player:SetAttribute("InDuel", nil)
	self:calculateAnger()
end

-- Report that a Director event has occurred (resets idle timer)
function DirectorMonitor:reportEvent(eventType)
	state.lastEventTime = tick()
	self:calculateAnger()
end

-- ==================== QUERY METHODS ====================

function DirectorMonitor:getCurrentAnger()
	return state.angerLevel
end

function DirectorMonitor:getCurrentMetrics()
	return state.metrics
end

function DirectorMonitor:getMetricHistory()
	return state.metricHistory
end

function DirectorMonitor:forceRecalculation()
	self:getMetrics()
	self:calculateAnger()
	print("🔄 DirectorMonitor: Forced recalculation. Current anger:", state.angerLevel)
end

-- ==================== INITIALIZATION ====================
local function setupEventListeners()
	-- Listen for kills via DamageEvent (if present)
	local damageEvent = ReplicatedStorage:FindFirstChild("DamageEvent")
	if damageEvent then
		damageEvent.OnServerEvent:Connect(function(player, data)
			if data and data.action == "kill" then
				DirectorMonitor:onKill(player, data.target)
			end
		end)
	end

	-- Listen for power usage (if present)
	local powerUsedEvent = ReplicatedStorage:FindFirstChild("PowerUsedEvent")
	if powerUsedEvent then
		powerUsedEvent.OnServerEvent:Connect(function(player)
			DirectorMonitor:onPowerUsed(player)
		end)
	end
end

state.lastRecalcTime = tick()
state.lastEventTime = tick()
setupEventListeners()

print("📊 DirectorMonitor initialized. Waiting for game events...")

return DirectorMonitor
