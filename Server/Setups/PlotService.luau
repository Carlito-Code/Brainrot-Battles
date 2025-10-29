local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

local plotContainer = game.Workspace.Plots

local utilities = replicatedStorage.Utilities
local sharedModules = replicatedStorage.SharedModules

local janitor = require(utilities.Janitor)
local signals = require(sharedModules.Signals)
local remotes = require(sharedModules.Remotes)
local promise = require(utilities.Promise)

local plotService = {}
local metaPlots = {} :: { [Model]: { owner: Player, j: janitor.Janitor } }

local function getAvailablePlots()
	local availablePlots = {}
	for _, plot in pairs(plotContainer:GetChildren()) do
		local ownerName = plot:GetAttribute("Owner")
		if ownerName == nil then
			table.insert(availablePlots, plot)
		else
			local claimedPlayer = players:FindFirstChild(ownerName)
			if not claimedPlayer then
				plotService.Release(plot)
				table.insert(availablePlots, plot)
			end
		end
	end
	return availablePlots
end

function plotService.Release(plot: Model)
	plot:SetAttribute("Owner", false)
	local metaData = metaPlots[plot]
	if metaData then
		signals.PLOT_RELEASED:Fire(plot)
		metaData.j:Destroy()
		metaData[plot] = nil
	end
end

function plotService.Claim(plr: Player, plot: Model)
	plot:SetAttribute("Owner", plr.Name)

	local newJanitor = janitor.new()
	metaPlots[plot] = { owner = plr, j = newJanitor }

	signals.CLAIMED_PLOT:Fire(plr, plot, newJanitor)

	local char = plr.Character
	if char then
		char:PivotTo(plot.TeleportPart.CFrame)
	end

	plr.CharacterAdded:Connect(function(char)
		char:PivotTo(plot.TeleportPart.CFrame)
	end)

	plr.AncestryChanged:Connect(function()
		plotService.Release(plot)
	end)

	return plot
end

function plotService.getPlot(plr: Player)
	for plot, informations in metaPlots do
		if informations.owner == plr then
			return plot, informations
		end
	end

	plotService.awaitAsync(plr)

	return plotService.getPlot(plr)
end

function plotService.awaitAsync(plr: Player)
	local current = coroutine.running()
	signals.CLAIMED_PLOT:Connect(function(player, plot)
		if player == plr then
			coroutine.resume(current)
		end
	end)
	return coroutine.yield()
end

function plotService.safeClaim(plr: Player)
	print("Initializing plot service for player: " .. plr.Name)
	promise
		.new(function(resolve, deny)
			local availableplots = getAvailablePlots()
			local randomizedPlot = availableplots[math.random(1, #availableplots)]
			local plot = plotService.Claim(plr, randomizedPlot)
			resolve(plot)
		end)
		:andThen(function(plot, resolve, reject)
			local claimed = false
			for _, v in pairs(plotContainer:GetChildren()) do
				if v:GetAttribute("Owner") == plr.Name then
					claimed = true
				end
			end
			if not claimed or not plot then
				plr:Kick("Plot was unsuccesfully claimed, please rejoin.")
			end
			print("[DEBUG]: Succesfully claimed plot for: " .. plr.Name)
		end)
end

function plotService.Init()
	remotes.GetPlot.OnServerInvoke = plotService.getPlot

	for _, plr: Player in players:GetPlayers() do
		plotService.safeClaim(plr)
	end
	players.PlayerAdded:Connect(function(plr: Player)
		plotService.safeClaim(plr)
	end)
end

return plotService
