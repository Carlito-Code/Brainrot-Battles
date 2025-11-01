local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.SharedModules.Remotes)

local DEFAULT_SPEED_MULTIPLIERS = { 1, 1.5, 2 }
local player = Players.LocalPlayer

local Top = {}

local function bindClick(parentFrame: Frame, instance: Instance?, handler: (frame: Frame, button: GuiButton) -> ())
	if not instance or not instance:IsA("GuiButton") then
		warn("[Top] Unable to bind click handler; instance was nil or not a GuiButton.")
		return
	end

	instance.MouseButton1Click:Connect(function()
		handler(parentFrame, instance)
	end)
end

local function setupConnections(frame: Frame)
	bindClick(frame, frame:FindFirstChild("AutoButton"), Top.OnAutoButtonClicked)
	bindClick(frame, frame:FindFirstChild("StartButton"), Top.OnStartButtonClicked)
	bindClick(frame, frame:FindFirstChild("StopButton"), Top.OnStopButtonClicked)
	bindClick(frame, frame:FindFirstChild("WaveSpeedMultiplier"), Top.OnWaveSpeedMultiplierClicked)
end

function Top.OnAutoButtonClicked(parentFrame: Frame?, button: GuiButton)
	local autoSpawnActive = player:GetAttribute("autoSpawn")

	if autoSpawnActive then
		button.ActiveIcon.Visible = false
		button.InactiveIcon.Visible = true
	else
		button.ActiveIcon.Visible = true
		button.InactiveIcon.Visible = false
	end

	Remotes.ToggleAutoSpawn:FireServer(player)
end

function Top.OnStartButtonClicked(parentFrame: Frame?, button: GuiButton)
	local player = Players.LocalPlayer
	if not player then
		warn("[Top] StartButton clicked but LocalPlayer was unavailable.")
		return
	end

	Remotes.StartWaveSystem:FireServer(player)
end

function Top.OnStopButtonClicked(parentFrame: Frame?, button: GuiButton)
	local player = Players.LocalPlayer
	if not player then
		warn("[Top] StopButton clicked but LocalPlayer was unavailable.")
		return
	end

	Remotes.StopWaveSystem:FireServer(player)
end

function Top.OnWaveSpeedMultiplierClicked(parentFrame: Frame?, button: GuiButton) end

function Top.Init(topContainer: Frame)
	-- frame:SetAttribute("WaveConfigurationsLoaded", typeof(WavesConfiguration) == "table")
	setupConnections(topContainer)

	Remotes.StopWaveSystem.OnClientEvent:Connect(function()
		topContainer.StopButton.Visible = false
		topContainer.StartButton.Visible = true

		player.PlayerGui.MainGui.Bottom.Inventory.Visible = true
		player.PlayerGui.MainGui.Bottom.DefenderSlot.Visible = false
		player.PlayerGui.MainGui.Bottom.EnergySlot.Visible = false
	end)

	Remotes.StartWaveSystem.OnClientEvent:Connect(function()
		topContainer.StartButton.Visible = false
		topContainer.StopButton.Visible = true

		player.PlayerGui.MainGui.Bottom.Inventory.Visible = false
		player.PlayerGui.MainGui.Bottom.DefenderSlot.Visible = true
		player.PlayerGui.MainGui.Bottom.EnergySlot.Visible = true
	end)
end

return Top
