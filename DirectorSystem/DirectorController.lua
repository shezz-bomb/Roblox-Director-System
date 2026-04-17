-- DirectorController.lua (Generic AI Director System)
-- Main loop that orchestrates the decision cycle.
-- Requires the other Director modules to be in the same folder.

local DirectorMonitor = require(script.Parent.DirectorMonitor)
local DirectorDecider = require(script.Parent.DirectorDecider)
local DirectorExecutor = require(script.Parent.DirectorExecutor)
local DirectorMemory = require(script.Parent.DirectorMemory)

local DirectorController = {}
local isRunning = false
local loopThread = nil

local DEFAULT_INTERVAL = 30 -- seconds between decisions

-- ==================== MAIN LOOP ====================

function DirectorController:start(interval)
	if isRunning then
		warn("DirectorController is already running.")
		return
	end

	isRunning = true
	interval = interval or DEFAULT_INTERVAL

	print("👁️ DirectorController started. Interval:", interval, "s")
	print("📅 Current day:", DirectorMemory:getCurrentDay(), "| Chaos multiplier: x" .. DirectorMemory:getChaosMultiplier())

	loopThread = task.spawn(function()
		while isRunning do
			-- 1. Get current world state
			local metrics = DirectorMonitor:getCurrentMetrics()
			local anger = DirectorMonitor:calculateAnger()

			-- 2. Decide next event
			local eventName = DirectorDecider:decide(metrics, anger)

			-- 3. Execute if an event was selected
			if eventName then
				DirectorExecutor:execute(eventName)
				DirectorMonitor:reportEvent(eventName)
			end

			-- 4. Wait for next cycle
			task.wait(interval)
		end
	end)
end

function DirectorController:stop()
	if not isRunning then return end

	isRunning = false
	if loopThread then
		task.cancel(loopThread)
		loopThread = nil
	end
	print("👁️ DirectorController stopped.")
end

function DirectorController:isRunning()
	return isRunning
end

return DirectorController
