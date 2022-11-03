-- cant be bothered obfuscating it
local PlayerData = require(game.ReplicatedStorage.Core.PlayerInfo.PlayerData)
local Player = PlayerData:getLocalPlayerData()
local Click = game.ReplicatedStorage.RemoteEvents.BreakableClickEvent
local Client = game.Players.LocalPlayer
local BreakablesFolder = workspace.Loaded.Breakables
local UserInputService = game:GetService("UserInputService")
local Enabled = false

local a = require(game:GetService("ReplicatedStorage").Core.BreakableData.UpdateBreakable)

local old
old = hookfunction(a.displayParticles, function(...)
	return nil
end)

local old2
old2 = hookfunction(a.displayBonusParticles, function(...)
	return nil
end)

local function getMultipleClosest(radius)
	local breakables = {}
	for _, v in pairs(BreakablesFolder:GetChildren()) do
		if v:FindFirstChild("Main") and v.Main:GetAttribute("Destroyed") == nil then
			local dist = (v.Main.Position - Client.Character.HumanoidRootPart.Position).Magnitude
			if dist < radius then
				table.insert(breakables, v)
				-- sort by distance
				table.sort(breakables, function(a, b)
					return (a.Main.Position - Client.Character.HumanoidRootPart.Position).Magnitude
						< (b.Main.Position - Client.Character.HumanoidRootPart.Position).Magnitude
				end)
			end
		end
	end
	return breakables
end

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.X then
		Enabled = not Enabled
	end
end)

task.spawn(
	function()
		while true do
			task.wait(0.5)
			if Enabled then
				local MinionsEquipped = Player.Inventory.Party
				local TotalAmount = #MinionsEquipped
				local Targets = getMultipleClosest(500)
				local TableTargets = {}
				pcall(function()
					for i = 1, TotalAmount do
						Click:FireServer(Targets[i].Name, false)
						table.insert(TableTargets, Targets[i])
					end
				end)
				repeat
					task.wait()
					for i, v in pairs(TableTargets) do
						if v.Variant1:FindFirstChildOfClass("MeshPart"):GetAttribute("Destroyed") ~= nil then
							table.remove(TableTargets, i)
						end
					end
				until #TableTargets == 0 or not Enabled
			end
		end
	end
)

workspace.Loaded.Drops.DescendantAdded:Connect(function(v)
	if v.ClassName == "ImageLabel" then
		v.Visible = false
	end
end)

workspace.Loaded.Drops.DescendantAdded:Connect(function(v)
	if v.ClassName == "Part" then
		v.CFrame = Client.Character.HumanoidRootPart.CFrame
	end
end)
