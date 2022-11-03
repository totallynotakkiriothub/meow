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
	function() --// Basically wallb my beloved, you can only fire the remote once per instance, so this is the best way i found for it to work, but i hope it's possible some other way sicne this shit is laggy ong
		while true do
			task.wait()
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

local function ConvertNumberToSuffix(number)
	local format = { "K", "M", "B", "T", "Q" }
	local suffix = ""
	local i = 1
	while number >= 1000 do
		number = number / 1000
		suffix = format[i]
		i = i + 1
	end
	return string.format("%.1f", number) .. suffix
end

local function getPerMinute()
	local current = {
		Gold = Player.Currency.Gold,
		CandyCorn = Player.Currency.CandyCorn,
		FireGems = Player.Currency.FireGems,
		FutureGems = Player.Currency.FutureGems,
		MagicGems = Player.Currency.MagicGems,
		Gems = Player.Currency.Gems,
	}
	while task.wait(60) do
		local new = {
			Gold = Player.Currency.Gold,
			CandyCorn = Player.Currency.CandyCorn,
			FireGems = Player.Currency.FireGems,
			FutureGems = Player.Currency.FutureGems,
			MagicGems = Player.Currency.MagicGems,
			Gems = Player.Currency.Gems,
		}
		local perminute = {
			Gold = new.Gold - current.Gold,
			CandyCorn = new.CandyCorn - current.CandyCorn,
			FireGems = new.FireGems - current.FireGems,
			FutureGems = new.FutureGems - current.FutureGems,
			MagicGems = new.MagicGems - current.MagicGems,
			Gems = new.Gems - current.Gems,
		}
		current = new
		print("--//     " .. os.date("%X") .. "     //--")
		print("Gold/min: " .. perminute.Gold .. " (" .. ConvertNumberToSuffix(perminute.Gold) .. ")")
		print("Candy/min: " .. perminute.CandyCorn .. " (" .. ConvertNumberToSuffix(perminute.CandyCorn) .. ")")
		print("Fire-Gems/min: " .. perminute.FireGems .. " (" .. ConvertNumberToSuffix(perminute.FireGems) .. ")")
		print("Future-Gems/min: " .. perminute.FutureGems .. " (" .. ConvertNumberToSuffix(perminute.FutureGems) .. ")")
		print("Magic-Gems/min: " .. perminute.MagicGems .. " (" .. ConvertNumberToSuffix(perminute.MagicGems) .. ")")
		print("Gems/min: " .. perminute.Gems .. " (" .. ConvertNumberToSuffix(perminute.Gems) .. ")")
	end
end

getPerMinute()
