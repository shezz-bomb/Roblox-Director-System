-- DirectorExecutor.lua (Generic AI Director System)
-- Executes the selected event and registers it in memory.

local DirectorExecutor = {}
local DirectorMemory = require(script.Parent.DirectorMemory)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- ==================== SAFE MODULE LOADING (OPTIONAL DEPENDENCIES) ====================
local function loadModule(path)
	local success, module = pcall(require, path)
	if not success then
		warn("⚠️ DirectorExecutor: Could not load module:", tostring(path))
	end
	return success and module or nil
end

-- Try to load external managers (stubs or real implementations)
local RelicsMgr = loadModule(script.Parent.Parent.Dependencies.RelicsManager)
local CypherMgr = loadModule(script.Parent.Parent.Dependencies.CypherManager)

-- ==================== COMMUNICATION ====================
local function getDirectorRemote()
	local net = ReplicatedStorage:FindFirstChild("Networking")
	local ce = net and net:FindFirstChild("ClientEvents")
	return ce and ce:FindFirstChild("DirectorMessage")
end

local function broadcast(msg: string, duration: number?)
	local remote = getDirectorRemote()
	if remote then
		remote:FireAllClients(msg, duration or 8)
	else
		-- Fallback for testing (deprecated but works in Studio)
		local m = Instance.new("Message")
		m.Text = msg
		m.Parent = workspace
		task.delay(duration or 8, function()
			if m and m.Parent then m:Destroy() end
		end)
	end
end

-- ==================== REWARD HELPERS ====================
local function rewardSurvivors(eventName: string, amount: number?)
	amount = amount or 1
	if not RelicsMgr then return end

	local survivors = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
			table.insert(survivors, player)
		end
	end

	for _, survivor in ipairs(survivors) do
		pcall(function()
			RelicsMgr:giveRelic(survivor, "DefaultRelic", amount)
		end)
	end

	if #survivors > 0 then
		broadcast(string.format("🏆 %d player(s) survived %s.", #survivors, eventName:upper()), 5)
	end
end

-- ==================== EVENT EXECUTION FUNCTIONS ====================
-- Each event is implemented as a method of DirectorExecutor.
-- Add your own events below following the same pattern.

function DirectorExecutor:defaultEvent()
	broadcast("✨ Default event triggered. Stay alert.", 5)

	-- Example effect: heal all players slightly
	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.Health = math.min(hum.MaxHealth, hum.Health + 20)
			end
		end
	end

	-- Optional: give a small reward
	if RelicsMgr then
		for _, player in ipairs(Players:GetPlayers()) do
			pcall(function()
				RelicsMgr:dropRandom(player, 1)
			end)
		end
	end
end

-- ===== ADD YOUR CUSTOM EVENTS BELOW =====
--[[ EXAMPLE: Meteor Event
function DirectorExecutor:meteorEvent()
	broadcast("☄️ A meteor is incoming! Take cover.", 6)
	
	local players = Players:GetPlayers()
	if #players == 0 then return end
	
	local target = players[math.random(#players)]
	local targetChar = target and target.Character
	local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
	local impactPos = targetRoot and targetRoot.Position or Vector3.new(0, 100, 0)
	
	-- Create meteor
	local meteor = Instance.new("Part")
	meteor.Shape = Enum.PartType.Ball
	meteor.Size = Vector3.new(6, 6, 6)
	meteor.Color = Color3.fromRGB(180, 60, 20)
	meteor.Material = Enum.Material.Neon
	meteor.Anchored = true
	meteor.CanCollide = false
	meteor.Position = impactPos + Vector3.new(0, 150, 0)
	meteor.Parent = workspace
	
	-- Animate fall
	TweenService:Create(meteor, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = impactPos + Vector3.new(0, 3, 0)
	}):Play()
	
	task.delay(2.5, function()
		-- Impact damage in radius
		local impactRadius = 12
		for _, player in ipairs(Players:GetPlayers()) do
			local char = player.Character
			if char then
				local root = char:FindFirstChild("HumanoidRootPart")
				local hum = char:FindFirstChildOfClass("Humanoid")
				if root and hum and hum.Health > 0 then
					local dist = (root.Position - impactPos).Magnitude
					if dist <= impactRadius then
						local dmg = math.floor(60 * (1 - dist/impactRadius))
						hum:TakeDamage(math.max(10, dmg))
					end
				end
			end
		end
		
		-- Visual explosion
		local explosion = Instance.new("Explosion")
		explosion.Position = impactPos
		explosion.BlastRadius = impactRadius
		explosion.BlastPressure = 0
		explosion.DestroyJointRadiusPercent = 0
		explosion.Parent = workspace
		
		meteor:Destroy()
		broadcast("💥 Impact! The meteor has struck.", 5)
	end)
end
--]]

-- ==================== MAIN DISPATCH ====================

function DirectorExecutor:execute(eventName: string)
	print("👁️ Director executing:", eventName)
	workspace:SetAttribute("CurrentDirectorEvent", eventName)
	task.delay(120, function()
		workspace:SetAttribute("CurrentDirectorEvent", "")
	end)

	local ok, err = pcall(function()
		if eventName == "DefaultEvent" then
			self:defaultEvent()
		-- elseif eventName == "YourCustomEvent" then
		--     self:yourCustomEvent()
		else
			warn("DirectorExecutor: Unknown event:", eventName)
		end
	end)

	if ok then
		DirectorMemory:remember(eventName, {})
	else
		warn("DirectorExecutor error in", eventName, ":", err)
	end
end

return DirectorExecutor
