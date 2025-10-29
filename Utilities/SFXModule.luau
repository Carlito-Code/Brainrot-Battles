local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local SERVER_RUNTIME = RunService:IsServer()


local rng = Random.new()
local loops = {} :: {[string] : Sound}

local soundRemote = ReplicatedStorage.Remotes.SFX
local worldSoundContainer: BasePart? = nil


local SoundModule = {}


function SoundModule.StopLoop(loopId: string)
	local sound = loops[loopId]
	if loops[loopId] == nil then return end
	
	
	if sound.Parent == nil then
		-- sound is no longer parented to anything, destroyed
		loops[loopId] = nil
	elseif sound.Parent == script then
		-- sound has no container/has no world position, destroy sound only
		sound:Destroy()
	else
		-- sound is in a container, destroy container
		sound.Parent:Destroy()
	end
end

function SoundModule.PlaySFX(...)
	if SERVER_RUNTIME then
		local args = {...}
		local target = table.remove(args,1)
		
		if target == "ALL" then
			soundRemote:FireAllClients("PlaySFX", unpack(args))
		elseif typeof(target) == "Instance" and target:IsA("Player") then
			soundRemote:FireClient(target, "PlaySFX", unpack(args))
		elseif typeof(target) == "table" then
			for i, v in pairs(target) do
				soundRemote:FireClient(v, "PlaySFX", unpack(args))
			end
		end
		
		return
	end
	
	local soundName: string, looped: boolean?, worldPosition: Vector3?, pitchUniqueness: number? = ...
	
	local sound: Sound? = SoundService.SFX:FindFirstChild(soundName)
	if sound == nil then warn(`{sound.Name} was not found`) return end
	
	local soundContainer = script

	sound = sound:Clone()
	sound.Looped = looped
	
	
	if typeof(worldPosition) == "Vector3" then
		soundContainer = Instance.new("Attachment")
		soundContainer.Position = worldPosition
		soundContainer.Parent = worldSoundContainer
	end
	
	if typeof(pitchUniqueness) == "number" then
		local shift = Instance.new("PitchShiftSoundEffect")
		shift.Octave = 1 + rng:NextNumber(-pitchUniqueness, pitchUniqueness)
		shift.Parent = sound
	end
	
	sound.Parent = soundContainer
	sound:Play()
	
	if not looped then
		task.delay(sound.TimeLength / sound.PlaybackSpeed, function()
			if soundContainer ~= script then
				soundContainer:Destroy()
			else
				sound:Destroy()
			end
		end)
		return
	end
	
	-- Keep track of this looped audio
	local loopId = HttpService:GenerateGUID(false)
	loops[loopId] = sound
	
	return loopId
end


if not SERVER_RUNTIME then
	worldSoundContainer = Instance.new("Part")
	worldSoundContainer.Name = "SOUND_CONTAINER"
	worldSoundContainer.Transparency = 1
	worldSoundContainer.CanCollide = false
	worldSoundContainer.CanQuery = false
	worldSoundContainer.Anchored = true
	worldSoundContainer.Parent = workspace
	

	soundRemote.OnClientEvent:Connect(function(funcName: string, ...)
		local func = SoundModule[funcName]
		if func then
			func(...)
		end
	end)
end

return SoundModule