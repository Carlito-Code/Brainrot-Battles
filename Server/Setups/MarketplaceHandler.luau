local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.SharedModules.Remotes)
local DataService = require(ReplicatedStorage.Utilities.DataService)

local DevProducts = {
	[0] = function(plr) end,
}

local MarketplaceHandler = {}

function MarketplaceHandler.Init()
	MarketplaceService.ProcessReceipt = function(ProcessReceipt)
		local Player = Players:GetPlayerByUserId(ProcessReceipt.PlayerId)
		if Player then
			local devProductFunction = DevProducts[ProcessReceipt.ProductId]
			if devProductFunction then
				devProductFunction(Player)
			end
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(a0: Player, a1: number, a2: boolean)
		if a2 then
			Remotes.PurchaseEnded:FireClient(a0)
			DataService.server:set(a0, { "gamepasses", a1 }, true)
		end
	end)

	Remotes.PromptPurchase.OnServerInvoke = function(Player, IsGamepass, Id)
		if IsGamepass then
			MarketplaceService:PromptGamePassPurchase(Player, Id)
		else
			MarketplaceService:PromptProductPurchase(Player, Id)
		end

		Remotes.PurchaseStarted:FireClient(Player)
	end
end

return MarketplaceHandler
