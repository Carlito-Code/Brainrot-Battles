local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Remotes = require(ReplicatedStorage.SharedModules.Remotes)
local Shop = {}

local TweenInformations = TweenInfo.new(0.1, Enum.EasingStyle.Sine)

function Shop.ShowGui(Container)
	TweenService:Create(Container, TweenInformations, { GroupTransparency = 0 }):Play()
end

function Shop.HideGui(Container)
	TweenService:Create(Container, TweenInformations, { GroupTransparency = 1 }):Play()
end

function Shop.Init(FramesContainer: Folder)
	local Frame = FramesContainer:FindFirstChild("Shop")
	if Frame then
		for _, descendent in Frame:GetDescendants() do
			if descendent:HasTag("Gamepass") then
				Remotes.PromptPurchase:InvokeServer(true, descendent:GetAttribute("Id"))
			elseif descendent:HasTag("DevProduct") then
				Remotes.PromptPurchase:InvokeServer(false, descendent:GetAttribute("Id"))
			end
		end
	end

	local Container = Players.LocalPlayer.PlayerGui:FindFirstChild("PurchaseScreen"):FindFirstChild("Container")
	Remotes.PurchaseStarted.OnClientEvent:Connect(function(...: any)
		Shop.ShowGui(Container)
	end)

	Remotes.PurchaseEnded.OnClientEvent:Connect(function(...: any)
		Shop.HideGui(Container)
	end)
end

return Shop
