local SoundService = game:GetService("SoundService") --// Used to store sound Replace this to your sound directory otherwise
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Spring = require(script.Parent.Spring)

--// Easy Animations Settings [ BY CARLITO AND SYM]
local Settings = {
	HoverOffset = UDim2.fromOffset(7, 7), --// Offset when a button is hovered
	HoverDuration = 0.1, --// Hover Tween Duration for both entering and exiting

	ClickOffset = UDim2.fromOffset(-7, -7), --// Offset when button is clicked
	ClickDuration = 0.1, --// Click Tween Duration for both entering and exiting

	HoverSoundEnabled = true, --// Enables / Disables the hover sound effect, if hoversound doesn't exist it will not work anyways
	HoverSound = SoundService["Hover"], --// Replace HoverSound with the hover sound name that you are using

	ClickSoundEnabled = true, --// Enables / Disables the click sound effect, if no clicksound then it will not work
	ClickSound = SoundService["Click"], --// Replace ClickSound with the click sound name that you are using

	Roatation = {
		Enabled = false, --// Enables / Disables the roation of buttosn when hovered
		--// The enabled can be set for specified buttons using an attribute called "RotationEnabled" Withouth that the default value will be used
		Amount = 1, --// The amount of rotation when hovered
		Duration = 0.2, --// Time that it takes to rotate
	},

	ImageDarkerWhenHovered = false, --// if enabled when hovering over a image button the image will become darker

	BlurEffect = false, --// Enables / Disables blur once opening a frame

	CameraZoom = {
		Amount = 20, --// The amount of zoom when opening a frame
		Enabled = false, --// Enables / Disables the camera zoom once opening a frame
		Duration = 0.4, --// Time that it takes to zome
	},

	--// Both of these need to be Udim.new() or nil
	FramePositionWhenClosedX = nil, --// X Position when the frame is closed (if nil the normal x position of the frame will be kept)
	FramePositionWhenClosedY = UDim.new(2.5, 0), --// Y Position when the frame is closed (if nil the normal y position of the frame will be kept)

	ClosedSize = 0.5,
	Duration = 0.7,
	SpringInfo = {
		Damping = 0.72,
		Speed = 17
	},

	Warnings = false,
}

return Settings
