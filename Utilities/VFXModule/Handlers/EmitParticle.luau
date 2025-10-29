local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

return function(worldPosition: Vector3, particleName: string)
	local particle: ParticleEmitter = ReplicatedStorage.Assets.Particles:FindFirstChild(particleName)
	if not particle then return end
	
	local att= Instance.new("Attachment")
	att.Parent = workspace.VFX_CONTAINER
	att.Position = worldPosition
	
	particle = particle:Clone()
	particle.Parent = att
	particle:Emit(50)
	
	Debris:AddItem(particle, particle.Lifetime.Max)
end