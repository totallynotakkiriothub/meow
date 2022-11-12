if not game.PlaceId == 10070062081 then
	game.Players.LocalPlayer:Kick("This script is not supported in this game.")
end

local chestfolder = workspace.Loaded.Chests
local Client = game.Players.LocalPlayer
local hatch = game.ReplicatedStorage.RemoteFunctions.ChestOpenFunction
local PlayerData = require(game.ReplicatedStorage.Core.PlayerInfo.PlayerData)
local Player = PlayerData:getLocalPlayerData()
local Inventory = Player.Inventory.Inventory
local ConvertEvent = game.ReplicatedStorage.RemoteFunctions.ChanceMachineFunction
local BreakablesFolder = workspace.Loaded.Breakables
local EnchantEvent = game.ReplicatedStorage.RemoteFunctions.EnchantMinionsFunction
local Click = game.ReplicatedStorage.RemoteEvents.BreakableClickEvent

local chestNames = {}
for _, v in pairs(chestfolder:GetChildren()) do
	table.insert(chestNames, v.Name)
end

local EnchantNames = {}
for _, v in next, require(game.ReplicatedStorage.Core.EnchantmentType).Definitions do
	table.insert(EnchantNames, v.Name)
end

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

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Pikaruru/Scripts/main/decentui.lua"))()

local Window = library:CreateWindow("Minion")
local Autofarm = Window:AddFolder("Autofarm")
local Eggs = Window:AddFolder("Eggs")
local Pets = Window:AddFolder("Pets")
local Misc = Window:AddFolder("Misc")

Autofarm:AddToggle({ text = "Auto Swing", flag = "autoswing" })
Autofarm:AddToggle({ text = "Auto Collect", flag = "autocollect" })
Autofarm:AddToggle({ text = "Multi Farm", flag = "multifarm" })
Eggs:AddList({ text = "Selected Chest", flag = "chest", values = chestNames })
Eggs:AddToggle({ text = "Auto Hatch", flag = "autofarm" })
Pets:AddBox({ text = "Minion Type", flag = "selectedtype", value = "Vampire" })
Pets:AddToggle({ text = "Convert Gold", flag = "convertgold" })
Pets:AddToggle({ text = "Convert Rainbow", flag = "convertrainbow" })
Pets:AddBox({ text = "Minion name", flag = "enchantminion", value = "Vampire" })
Pets:AddToggle({ text = "Auto Enchant", flag = "autoenchant" })
Pets:AddList({ text = "Selected Enchant", flag = "enchant", values = EnchantNames })
Misc:AddButton({
	text = "Stat tracker",
	callback = function()
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
			print(
				"Future-Gems/min: "
					.. perminute.FutureGems
					.. " ("
					.. ConvertNumberToSuffix(perminute.FutureGems)
					.. ")"
			)
			print(
				"Magic-Gems/min: " .. perminute.MagicGems .. " (" .. ConvertNumberToSuffix(perminute.MagicGems) .. ")"
			)
			print("Gems/min: " .. perminute.Gems .. " (" .. ConvertNumberToSuffix(perminute.Gems) .. ")")
		end
	end,
})
Misc:AddButton({
	text = "Convert Info",
	callback = function()
		local Library = loadstring(game:HttpGet("https://www.soggy-ware.cf/Libs/PromptGui.lua"))()
		Library:New({
			Title = "Important",
			Footer = "For enchanting, rename your minion, insert in the textbox",
			Text = "In order for auto convert to work, you have to input the minion type, ex: Hotdog, Vampire, Ragita, Banana, SpiritOfHalloween etc",
			Icon = "http://www.roblox.com/thumbs/asset.ashx?assetid=10010679532&x=100&y=100&format=png",
			Yes = function()
				print("Yes Pressed")
			end,
			Cancel = function()
				print("Cancel Pressed")
			end,
		})
	end,
})
Misc:AddLabel({ text = "Made by kalas#1330" })
library:Init()

task.spawn(function()
	while true do
		task.wait()
		if library.flags.autofarm then
			local selected = library.flags.chest
			hatch:InvokeServer({ ["Name"] = selected })
		end
	end
end)

local function getGold()
	local uuids = {}
	for _, v in pairs(Inventory) do
		if type(v) == "table" then
			if not v.Locked and not v.Rainbow and not v.Golden and v.MinionType == library.flags.selectedtype then
				table.insert(uuids, v.UUID)
			end
		end
	end
	return uuids
end

local function getRainbow()
	local uuids = {}
	for _, v in pairs(Inventory) do
		if type(v) == "table" then
			if not v.Locked and not v.Rainbow and v.Golden and v.MinionType == library.flags.selectedtype then
				table.insert(uuids, v.UUID)
			end
		end
	end
	return uuids
end

local function getUUIDsGold()
	local uuids = {}
	if #getGold() >= 6 then
		for i = 1, 6 do
			table.insert(uuids, getGold()[i])
		end
	end
	return uuids
end

local function getUUIDsRainbow()
	local uuids = {}
	if #getRainbow() >= 6 then
		for i = 1, 6 do
			table.insert(uuids, getRainbow()[i])
		end
	end
	return uuids
end

task.spawn(function()
	while true do
		task.wait()
		if library.flags.convertgold then
			ConvertEvent:InvokeServer("Golden", getUUIDsGold())
		end
	end
end)

task.spawn(function()
	while true do
		task.wait()
		if library.flags.convertrainbow then
			ConvertEvent:InvokeServer("Rainbow", getUUIDsRainbow())
		end
	end
end)

local function getEnchants(pet)
	for _, v in pairs(Inventory) do
		if type(v) == "table" then
			if v.Name == pet then
				return v.Enchantments
			end
		end
	end
end

local function getUuid(pet)
	for _, v in pairs(Inventory) do
		if type(v) == "table" then
			if v.Name == pet then
				return v.UUID
			end
		end
	end
end

task.spawn(function()
	while true do
		task.wait()
		if library.flags.autoenchant then
			local selected = library.flags.enchant
			local pet = library.flags.enchantminion
			local enchants = getEnchants(pet)
			for _, v in pairs(enchants) do
				if v ~= selected then
					EnchantEvent:InvokeServer({ getUuid(pet) })
				end
			end
		end
	end
end)

local function ClosestBreakable(radius)
	local Closest = nil
	local Distance = 9e9
	for _, v in pairs(BreakablesFolder:GetChildren()) do
		if v:FindFirstChild("Main") and v:FindFirstChild("Variant1") then
			if v.Variant1:FindFirstChildOfClass("MeshPart"):GetAttribute("Destroyed") == nil then
				local Magnitude = (v.Main.Position - Client.Character.HumanoidRootPart.Position).Magnitude
				if Magnitude < Distance and Magnitude < radius then
					Closest = v
					Distance = Magnitude
				end
			end
		end
	end
	return Closest
end

task.spawn(function()
	while true do
		task.wait()
		if library.flags.autoswing then
			local Closest = ClosestBreakable(1000)
			if Closest then
				game.ReplicatedStorage.RemoteFunctions.PickaxeBreakableFunction:InvokeServer(Closest.Name)
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait()
		if library.flags.autocollect then
			for _, b in pairs(workspace.Loaded.Drops:GetChildren()) do
				for _, v in pairs(b:GetChildren()) do
					if v.ClassName == "Part" then
						v.CFrame = Client.Character.HumanoidRootPart.CFrame
					end
				end
			end
		end
	end
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

task.spawn(function()
	while true do
		task.wait()
		if library.flags.multifarm then
			local MinionsEquipped = Player.Inventory.Party
			local TotalAmount = #MinionsEquipped
			local Targets = getMultipleClosest(500)
			local TableTargets = {}
			for i = 1, TotalAmount do
				Click:FireServer(Targets[i].Name, false)
				table.insert(TableTargets, Targets[i])
			end
			repeat
				task.wait()
				for i, v in pairs(TableTargets) do
					if v.Variant1:FindFirstChildOfClass("MeshPart"):GetAttribute("Destroyed") ~= nil then
						table.remove(TableTargets, i)
					end
				end
			until #TableTargets == 0 or not library.flags.multifarm
		end
	end
end)
