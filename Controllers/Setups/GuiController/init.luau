local players = game:GetService("Players")
local collectionService = game:GetService("CollectionService")
local replicatedFirst = game:GetService("ReplicatedFirst")
local replicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(replicatedStorage.Utilities.DataService).client

local lPlayer = players.LocalPlayer
local gui = lPlayer.PlayerGui:WaitForChild("MainGui")
local animationsHandler = require(replicatedFirst.Controllers.Bindings.Animations).new("MainGui")
local registry = require(script.Registry)
local bottom = require(script.Bottom)
local top = require(script.Top)
local plots = require(script.Parent.Plots)

local guiHandler = {}
local framesContainer = gui.Frames
local xButtonName = "X"

function guiHandler.handleFrame(frame: Frame)
	local closeButton = frame:FindFirstChild(xButtonName, true)
	local updateCallback = nil
	local referenceModule = replicatedFirst.Controllers.Frames:FindFirstChild(frame.Name .. "Frame")
	if registry[frame.Name] then
		animationsHandler:SetupFrameInSelf(frame, nil, registry[frame.Name])
	end
	if referenceModule then
		local success, returnfunction = pcall(function()
			local r = require(referenceModule)
			if typeof(r["Update"]) == "function" then
				updateCallback = r["Update"]
			end
		end)
		if not success then
			warn(returnfunction)
		end
	end

	for _, v in collectionService:GetTagged(frame.Name) do
		animationsHandler:BindButtonToFrame(v, frame)
	end

	animationsHandler:BindActionToFrameOpen(updateCallback, frame)

	if closeButton then
		animationsHandler:BindCloseButtonToFrame(closeButton, frame)
	end

	print(frame.Name .. " Has been handled")
end

function guiHandler.init()
	DataService:init()

	for _, frame in framesContainer:GetChildren() do
		guiHandler.handleFrame(frame)
	end

	for _, v in pairs(replicatedFirst.Controllers.Frames:GetChildren()) do
		if v:IsA("ModuleScript") then
			local success, errorMsg = pcall(function()
				local r = require(v)
				if r["Init"] then
					r["Init"](framesContainer)
				end
			end)
			if not success then
				warn(errorMsg)
			end
		end
	end

	bottom.Init(gui.Bottom)
	top.Init(gui.Top)
	plots.Init()
end

return guiHandler
