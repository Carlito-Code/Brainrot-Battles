--// Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Settings
local AnimationSettings = require(script.Settings)

local random = Random.new()

--// Buttons Variables
local RoationEnabled = AnimationSettings.Roatation.Enabled
local RoationTime = AnimationSettings.Roatation.Duration
local RotationAmount = AnimationSettings.Roatation.Amount
local Spring = require("@self/Spring")
local Signal = require("@self/Signal")

local Roations = {
	-RotationAmount,
	RotationAmount,
}

local ImageDarkerwhenHovering = AnimationSettings.ImageDarkerWhenHovered

local AnimationFunctions = {}
AnimationFunctions.__index = AnimationFunctions

type FrameType = typeof({
	State = false,
	Object = FrameInstance,
	Position = FrameInstance.Position,
	ClosedPosition = UDim2.new(XPosition, YPosition),
	OC = function() end,
	PSpring = Spring.new(YPosition.Scale, AnimationSettings.SpringInfo.Damping, AnimationSettings.SpringInfo.Speed),
	SSpring = Spring.new(
		AnimationSettings.ClosedSize,
		AnimationSettings.SpringInfo.Damping,
		AnimationSettings.SpringInfo.Speed
	),
	OpenSignal = Signal.new(),
	CloseSignal = Signal.new(),
})

local Frames = {} :: { FrameType }
local ButtonsContainer = nil
local Player = Players.LocalPlayer

local CurrentCamera = workspace.CurrentCamera
local CurrentCameraNormalFOV = CurrentCamera.FieldOfView
local NewBlur = nil

local TEXTLABELS_CACHES = {}

function AnimationFunctions:GetTextLabel(labelName: string | TextLabel)
	if labelName:IsA("TextLabel") then
		return labelName
	end
	local label = TEXTLABELS_CACHES[labelName]
	if not label then
		label = ButtonsContainer:FindFirstChild(labelName, true)
		TEXTLABELS_CACHES[labelName] = label
	end
	return label
end

function AnimationFunctions:GetFrame(frameName: string)
	return Frames[frameName].Object
end

function AnimationFunctions:SetText(TextLabelName: string, text: string)
	local label = AnimationFunctions:GetTextLabel(TextLabelName)

	if label then
		TextLabelName.Text = text
	end
end

function AnimationFunctions:HandleButton(instance: GuiButton)
	task.defer(function()
		local ButtonNormalSize = instance.Size
		local ButtonRoation = instance.Rotation

		local LocalRoationEnabled = if instance:GetAttribute("RotationEnabled") == nil
			then RoationEnabled
			else instance:GetAttribute("RotationEnabled")
		local SizeEnabled = if instance:GetAttribute("SizeEnabled") == nil
			then true
			else instance:GetAttribute("SizeEnabled")

		local NormalImageColor = nil

		if instance:IsA("ImageButton") then
			NormalImageColor = instance.ImageColor3
		end

		instance.MouseEnter:Connect(function()
			local ButtonRoation = Roations[random:NextInteger(1, 2)]

			if SizeEnabled then
				local HoverTween = TweenService:Create(
					instance,
					TweenInfo.new(AnimationSettings.HoverDuration, Enum.EasingStyle.Sine),
					{ Size = ButtonNormalSize + AnimationSettings.HoverOffset }
				)
				HoverTween:Play()
			end

			if ImageDarkerwhenHovering == true then
				if instance:IsA("ImageButton") then
					instance.ImageColor3 = instance.ImageColor3:Lerp(Color3.fromRGB(0, 0, 0), 0.3)
				end
			end

			if LocalRoationEnabled == true then
				local RotationTween = TweenService:Create(
					instance,
					TweenInfo.new(RoationTime, Enum.EasingStyle.Sine),
					{ Rotation = ButtonRoation }
				)
				RotationTween:Play()
			end

			if AnimationSettings.HoverSoundEnabled == true and AnimationSettings.HoverSound then
				AnimationSettings.HoverSound:Play()
			else
				if AnimationSettings.Warnings == true then
					warn("HoverSound has not been provided")
				end
			end
		end)

		instance.MouseLeave:Connect(function()
			local HoverFinishTween = TweenService:Create(
				instance,
				TweenInfo.new(AnimationSettings.HoverDuration, Enum.EasingStyle.Sine),
				{ Size = ButtonNormalSize }
			)
			HoverFinishTween:Play()

			if ImageDarkerwhenHovering then
				if instance:IsA("ImageButton") then
					instance.ImageColor3 = NormalImageColor
				end
			end

			if LocalRoationEnabled == true then
				local RotationTween =
					TweenService:Create(instance, TweenInfo.new(RoationTime, Enum.EasingStyle.Sine), { Rotation = 0 })
				RotationTween:Play()
			end
		end)

		instance.MouseButton1Click:Connect(function()
			local ClickTween = TweenService:Create(
				instance,
				TweenInfo.new(AnimationSettings.ClickDuration, Enum.EasingStyle.Sine),
				{ Size = ButtonNormalSize + AnimationSettings.ClickOffset }
			)
			ClickTween:Play()

			ClickTween.Completed:Connect(function()
				local ClickEndTween = TweenService:Create(
					instance,
					TweenInfo.new(AnimationSettings.ClickDuration, Enum.EasingStyle.Sine),
					{ Size = ButtonNormalSize }
				)
				ClickEndTween:Play()
			end)

			if AnimationSettings.ClickSoundEnabled == true and AnimationSettings.ClickSound then
				AnimationSettings.ClickSound:Play()
			else
				if AnimationSettings.Warnings == true then
					warn("ClickSound has not been provided")
				end
			end
		end)
	end)
end

function AnimationFunctions:OpenFrame(FrameInstance)
	AnimationFunctions:CloseAllFrames()

	local Informations = Frames[FrameInstance.Name]

	task.defer(function()
		--// Handling the frame in case it doesn't exist inside of the frames table
		if not Informations then
			Informations = AnimationFunctions:SetupFrameInSelf(FrameInstance)
		end

		if Informations.State == true then
			return
		end

		Informations.State = true

		Informations.OpenSignal:Fire()

		FrameInstance.Visible = true

		--// In case blur is enabled we add a blur effect when opening the frame
		if AnimationSettings.BlurEffect == true then
			local NewBlur = Lighting:FindFirstChild("Blur")

			if not NewBlur then
				NewBlur = Instance.new("BlurEffect")
				NewBlur.Name = "Blur"
				NewBlur.Size = 0
				NewBlur.Parent = Lighting
			end

			NewBlur = NewBlur

			local BlurTween = TweenService:Create(
				NewBlur,
				TweenInfo.new(AnimationSettings.Duration / 2, Enum.EasingStyle.Sine),
				{ Size = 15 }
			)
			BlurTween:Play()
		end

		--// In case camerazoom was enabled the zoom will start working
		if AnimationSettings.CameraZoom.Enabled == true then
			local CameraZoomTween = TweenService:Create(
				CurrentCamera,
				TweenInfo.new(AnimationSettings.CameraZoom.Duration, Enum.EasingStyle.Sine),
				{ FieldOfView = CurrentCameraNormalFOV - AnimationSettings.CameraZoom.Amount }
			)
			CameraZoomTween:Play()
		end

		Informations.PYSpring.Target = Informations.Position.Y.Scale
		Informations.PXSpring.Target = Informations.Position.X.Scale
		Informations.SSpring.Target = 1
	end)
end

function AnimationFunctions:CloseFrame(FrameInstance, CloseBlur)
	if CloseBlur == nil then
		CloseBlur = true
	end

	local Informations = Frames[FrameInstance.Name]

	task.defer(function()
		--// Handling the frame in case it doesn't exist inside of the frames table
		if not Informations then
			Informations = AnimationFunctions:SetupFrameInSelf(FrameInstance)
		end

		if Informations.State == false then
			return
		end

		Informations.CloseSignal:Fire()

		Informations.State = false

		--// In case blur is enabled we add a blur effect when opening the frame
		if CloseBlur == true then
			if NewBlur then
				local BlurTween = TweenService:Create(
					NewBlur,
					TweenInfo.new(AnimationSettings.Duration / 2, Enum.EasingStyle.Sine),
					{ Size = 0 }
				)
				BlurTween:Play()

				NewBlur:Destroy()
			end
		end

		--// In case camerazoom was enabled the zoom will start working
		if CloseBlur == true then
			if AnimationSettings.CameraZoom ~= self.CurrentCameraNormalFOV then
				local CameraZoomTween = TweenService:Create(
					CurrentCamera,
					TweenInfo.new(AnimationSettings.CameraZoom.Duration, Enum.EasingStyle.Sine),
					{ FieldOfView = CurrentCameraNormalFOV }
				)
				CameraZoomTween:Play()
			end
		end

		--// Normal Closing
		Informations.PYSpring.Target = Informations.ClosedPosition.Y.Scale
		Informations.PXSpring.Target = Informations.ClosedPosition.X.Scale
		Informations.SSpring.Target = AnimationSettings.ClosedSize
	end)
end

function AnimationFunctions:CloseAllFrames()
	task.defer(function()
		for name, info in pairs(Frames) do
			if info.State == true then
				AnimationFunctions:CloseFrame(info.Object, false)
			end
		end
	end)
end

function AnimationFunctions:SetupFrameInSelf(FrameInstance, OpeningCallback, OverridePosition)
	print("Setupped")
	local YPosition = nil
	local XPosition = nil

	if not AnimationSettings.FramePositionWhenClosedX then
		XPosition = FrameInstance.Position.X
	else
		XPosition = AnimationSettings.FramePositionWhenClosedX
	end

	if not AnimationSettings.FramePositionWhenClosedY then
		YPosition = FrameInstance.Position.Y
	else
		YPosition = AnimationSettings.FramePositionWhenClosedY
	end

	local FrameSize: UDim2 = FrameInstance.Size

	local info = {
		State = false,
		Object = FrameInstance,
		Position = FrameInstance.Position,
		ClosedPosition = OverridePosition or UDim2.new(XPosition, YPosition),
		OC = OpeningCallback,
		PYSpring = Spring.new(
			YPosition.Scale,
			AnimationSettings.SpringInfo.Damping,
			AnimationSettings.SpringInfo.Speed
		),
		PXSpring = Spring.new(
			XPosition.Scale,
			AnimationSettings.SpringInfo.Damping,
			AnimationSettings.SpringInfo.Speed
		),
		SSpring = Spring.new(
			AnimationSettings.ClosedSize,
			AnimationSettings.SpringInfo.Damping,
			AnimationSettings.SpringInfo.Speed
		),
		OpenSignal = Signal.new(),
		CloseSignal = Signal.new(),
	}

	Frames[FrameInstance.Name] = info

	RunService.RenderStepped:Connect(function()
		FrameInstance.Position = UDim2.fromScale(info.PXSpring.Position, info.PYSpring.Position)
		FrameInstance.Size =
			UDim2.fromScale(FrameSize.X.Scale * info.SSpring.Position, FrameSize.Y.Scale * info.SSpring.Position)
	end)

	return info
end

function AnimationFunctions:BindButtonToFrame(
	buttonInstance: GuiButton,
	FrameInstance: GuiObject
): { BindToOpen: (callback) -> () }
	if not buttonInstance or not FrameInstance then
		error("BindButtonToFrame Function cannot work withouth Buttoninstance or FrameInstance")
		return
	end
	--// Does a default setup and in case of 2 buttons to open a frame it handles both
	if not Frames[FrameInstance.Name] then
		AnimationFunctions:SetupFrameInSelf(FrameInstance)
	end

	buttonInstance.Activated:Connect(function()
		local Frame = Frames[FrameInstance.Name]

		if Frame.State == false then
			AnimationFunctions:CloseAllFrames()
			AnimationFunctions:OpenFrame(FrameInstance)
		else
			AnimationFunctions:CloseFrame(FrameInstance)
		end
	end)

	return {
		BindToOpen = function(callback)
			AnimationFunctions:BindActionToFrameOpen(callback, FrameInstance)
		end,
	}
end

function AnimationFunctions:BindActionToFrameClose(action, frame, argsCallback)
	if not Frames[frame.Name] then
		AnimationFunctions:SetupFrameInSelf(frame)
	end

	local informations = nil
	if typeof(frame) == "string" then
		informations = Frames[frame]
	else
		informations = Frames[frame.Name]
	end

	informations.CloseSignal:Connect(function()
		local args = nil
		if argsCallback then
			args = table.unpack(argsCallback())
		end
		action(args)
	end)
end

function AnimationFunctions:BindActionToFrameOpen(action, frame, argsCallback)
	if not Frames[frame.Name] then
		AnimationFunctions:SetupFrameInSelf(frame)
	end

	if not action or not frame then
		return
	end
	local informations = nil
	if typeof(frame) == "string" then
		informations = Frames[frame]
	else
		informations = Frames[frame.Name]
	end

	informations.OpenSignal:Connect(function()
		local args = nil
		if argsCallback then
			args = table.unpack(argsCallback())
		end
		action(args)
	end)
end

function AnimationFunctions:BindCloseButtonToFrame(buttonInstance: GuiButton, FrameToClose: GuiObject)
	if not buttonInstance then
		warn("Button Instance not provided in cloe button function")
		return
	end

	buttonInstance.MouseButton1Click:Connect(function()
		AnimationFunctions:CloseFrame(FrameToClose)
	end)
end

function AnimationFunctions:Initialize()
	--// Handles all of the buttons animations / sounds
	for _, instance: Instance in pairs(ButtonsContainer:GetDescendants()) do
		if instance:IsA("GuiButton") then
			AnimationFunctions:HandleButton(instance)
		end
	end

	--// In case of any button added it will be handled by this function
	ButtonsContainer.DescendantAdded:Connect(function(InstanceAdded)
		if InstanceAdded:IsA("GuiButton") then
			AnimationFunctions:HandleButton(InstanceAdded)
		end
	end)
end

function AnimationFunctions.new(guiName: string)
	if RunService:IsServer() then
		warn("required on server")
		return
	end

	local self = setmetatable({}, AnimationFunctions)

	--// Variables that will be passed troughout all of the scripts
	ButtonsContainer = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild(guiName)

	--// Initializes the module script withouth the needs of any external scripts
	AnimationFunctions:Initialize()

	return self
end

return AnimationFunctions
