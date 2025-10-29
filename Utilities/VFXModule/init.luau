local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local SERVER_RUNTIME = RunService:IsServer()


local rng = Random.new()

local vfxRemote = ReplicatedStorage.Remotes.VFX
local vfxHandlers = {} :: { [string] : (worldPosition: Vector3) -> () }

local worldVFXContainer: BasePart? = nil


local VFXModule = {}

function VFXModule.PlayVFX(...)
	if SERVER_RUNTIME then
		vfxRemote:FireAllClients("PlayVFX", ...)
		return
	end

	local vfxName: string, worldPosition: Vector3? = ...

	local vfxHandler: ModuleScript = vfxHandlers[vfxName] or script.Handlers:FindFirstChild(vfxName)
	if typeof(vfxHandler) == "Instance" then
		if not vfxHandler:IsA("ModuleScript") then
			warn(`VFX Handler {vfxName} not found`)
			return 
		end
		
		vfxHandler = require(vfxHandler)
		vfxHandlers[vfxName] = vfxHandler
	end
	
	if typeof(vfxHandler) ~= "function" then return end

	if worldPosition ~= nil and typeof(worldPosition) ~= "Vector3" then
		warn(`Attempt VFX "{vfxName}" failed, worldPosition is expected to be nil or Vector3`)
		return
	end

	local args = { ... } -- capture varargs
	table.remove(args, 1) -- rm vfxName
	table.remove(args, 1) -- rm worldPosition

	task.spawn(vfxHandler, worldPosition, unpack(args))
end


if not SERVER_RUNTIME then
	worldVFXContainer = Instance.new("Part")
	worldVFXContainer.Name = "VFX_CONTAINER"
	worldVFXContainer.Transparency = 1
	worldVFXContainer.CanCollide = false
	worldVFXContainer.CanQuery = false
	worldVFXContainer.Anchored = true
	worldVFXContainer.Parent = workspace


	vfxRemote.OnClientEvent:Connect(function(funcName: string, ...)
		local func = VFXModule[funcName]
		if func then
			func(...)
		end
	end)
end

return VFXModule