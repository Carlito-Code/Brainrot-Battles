-- DATA CONTAINER --
local function toAnimationString(s) return "rbxassetid://" .. s end
local Data = {
	["67"] = {
		DisplayName = "67",
		AttackAnimation = toAnimationString(0),
		WalkingAnimation = toAnimationString(0),
		AttackDmg = 15,
		Health = 100,
		Rarity = "Legendary",
		SpawnPrice = 0,
		EnergyCost = 10,
		viewportCFrame = function(model: Model, cam: Camera)
			local extentsSize = model:GetExtentsSize()

			cam.CFrame = CFrame.lookAt((model.HumanoidRootPart.CFrame * CFrame.new(8, extentsSize.Y / 3, -extentsSize.Z * 4)).Position, model.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
			cam.FieldOfView = 50
		end
	},
	BallerinaCappuccina = {
		DisplayName = "Ballerina Cappuccina",
		AttackAnimation = toAnimationString(0),
		WalkingAnimation = toAnimationString(0),
		AttackDmg = 15,
		Health = 100,
		Rarity = "Common",
		SpawnPrice = 0,
		EnergyCost = 10,
		viewportCFrame = function(model: Model, cam: Camera)
			local extentsSize = model:GetExtentsSize()

			cam.CFrame = CFrame.lookAt((model.HumanoidRootPart.CFrame * CFrame.new(0, 7, -extentsSize.Z*1.1)).Position, model.HumanoidRootPart.Position + Vector3.new(0, 7, 0))
		end
	},
	BombardiroCrocodilo = {
		DisplayName = "Bombardiro Crocodilo",
		AttackAnimation = toAnimationString(0),
		WalkingAnimation = toAnimationString(0),
		AttackDmg = 15,
		Health = 100,
		Rarity = "Legendary",
		SpawnPrice = 0,
		EnergyCost = 10,
		viewportCFrame = function(model: Model, cam: Camera)
			local extentsSize = model:GetExtentsSize()

			cam.CFrame = CFrame.lookAt((model.HumanoidRootPart.CFrame * CFrame.new(7, extentsSize.Y * 1.4, -extentsSize.Z/1.2)).Position, model.HumanoidRootPart.Position + Vector3.new(-4, -1.5, 0)) * CFrame.Angles(0, 0, math.rad(-15))
			cam.FieldOfView = 50
		end
	},
	BrrBrrPapatim = {
		DisplayName = "Brr Brr Papatim",
		AttackAnimation = toAnimationString(0),
		WalkingAnimation = toAnimationString(0),
		AttackDmg = 15,
		Health = 100,
		Rarity = "Common",
		SpawnPrice = 0,
		EnergyCost = 10,
		viewportCFrame = function(model: Model, cam: Camera)
			local extentsSize = model:GetExtentsSize()

			cam.CFrame = CFrame.lookAt((model.HumanoidRootPart.CFrame * CFrame.new(0, 5, -extentsSize.Z*1.25)).Position, model.HumanoidRootPart.Position + Vector3.new(0, 4.5, 0))
		end
	},
	CanneloniDragon = {
		DisplayName = "Canneloni Dragon",
		AttackAnimation = toAnimationString(0),
		WalkingAnimation = toAnimationString(0),
		AttackDmg = 15,
		Health = 100,
		Rarity = "Secret",
		SpawnPrice = 0,
		EnergyCost = 10,
		viewportCFrame = function(model: Model, cam: Camera)
			local extentsSize = model:GetExtentsSize()

			cam.CFrame = CFrame.lookAt((model.HumanoidRootPart.CFrame * CFrame.new(5, -2, -extentsSize.Z/1.25)).Position, model.HumanoidRootPart.Position + Vector3.new(0, 2.5, 0))
		end
	},
	CappuccinoAssassino = {
		DisplayName = "Cappuccino Assassino",
		AttackAnimation = toAnimationString(0),
		WalkingAnimation = toAnimationString(0),
		AttackDmg = 15,
		Health = 100,
		Rarity = "Common",
		SpawnPrice = 0,
		EnergyCost = 10,
		viewportCFrame = function(model: Model, cam: Camera)
			local extentsSize = model:GetExtentsSize()

			cam.CFrame = model.HumanoidRootPart.CFrame * CFrame.new(0, extentsSize.Y / 4, -extentsSize.Z / 2 - 2.5) * CFrame.Angles(math.rad(-5), math.rad(180), math.rad(-3))
		end
	},
	LaGrandeCombination = {
		DisplayName = "La Grande Combination",
		AttackAnimation = toAnimationString(0),
		WalkingAnimation = toAnimationString(0),
		AttackDmg = 15,
		Health = 100,
		Rarity = "Legendary",
		SpawnPrice = 0,
		EnergyCost = 10,
		viewportCFrame = function(model: Model, cam: Camera)
			local extentsSize = model:GetExtentsSize()

			cam.CFrame = CFrame.lookAt((model.HumanoidRootPart.CFrame * CFrame.new(0, 9, -extentsSize.Z)).Position, model.HumanoidRootPart.Position + Vector3.new(0, 9, 0))
		end
	},
	LiriliLarila = {
		DisplayName = "Lirili Larila",
		AttackAnimation = toAnimationString(0),
		WalkingAnimation = toAnimationString(0),
		AttackDmg = 15,
		Health = 100,
		Rarity = "Rare",
		SpawnPrice = 0,
		EnergyCost = 10,
		viewportCFrame = function(model: Model, cam: Camera)
			local extentsSize = model:GetExtentsSize()

			cam.CFrame = CFrame.lookAt((model.HumanoidRootPart.CFrame * CFrame.new(10, -2, -extentsSize.Z * 1.5)).Position, model.HumanoidRootPart.Position + Vector3.new(0, 3.5, 0))
		end
	},
	NoobiniPizzanini = {
		DisplayName = "Noobini Pizzanini",
		AttackAnimation = toAnimationString(0),
		WalkingAnimation = toAnimationString(0),
		AttackDmg = 15,
		Health = 100,
		Rarity = "Common",
		SpawnPrice = 0,
		EnergyCost = 10,
		viewportCFrame = function(model: Model, cam: Camera)
			local extentsSize = model:GetExtentsSize()

			cam.CFrame = CFrame.lookAt((model.HumanoidRootPart.CFrame * CFrame.new(0, 11, -extentsSize.Z*1.67)).Position, model.HumanoidRootPart.Position + Vector3.new(0, 11, 0))
		end
	},
	OdinDinDinDun = {
		DisplayName = "Odin Din Din Dun",
		AttackAnimation = toAnimationString(0),
		WalkingAnimation = toAnimationString(0),
		AttackDmg = 15,
		Health = 100,
		Rarity = "Epic",
		SpawnPrice = 0,
		EnergyCost = 10,
		viewportCFrame = function(model: Model, cam: Camera)
			local extentsSize = model:GetExtentsSize()

			cam.CFrame = CFrame.lookAt((model.HumanoidRootPart.CFrame * CFrame.new(0, extentsSize.Y / 1.8, -extentsSize.Z * 1.75)).Position, model.HumanoidRootPart.Position + Vector3.new(0, 8, 0))
		end
	},
	OrcaleroOrcala = {
		DisplayName = "Orcalero Orcala",
		AttackAnimation = toAnimationString(0),
		WalkingAnimation = toAnimationString(0),
		AttackDmg = 15,
		Health = 100,
		Rarity = "Common",
		SpawnPrice = 0,
		EnergyCost = 10,
		viewportCFrame = function(model: Model, cam: Camera)
			local extentsSize = model:GetExtentsSize()

			cam.CFrame = CFrame.lookAt((model.HumanoidRootPart.CFrame * CFrame.new(-10, 3, -extentsSize.Z/1.5)).Position, model.HumanoidRootPart.Position + Vector3.new(3,5,0))
		end
	},
	ToToToSahur = {
		DisplayName = "To To To Sahur",
		AttackAnimation = toAnimationString(0),
		WalkingAnimation = toAnimationString(0),
		AttackDmg = 15,
		Health = 100,
		Rarity = "Common",
		SpawnPrice = 0,
		EnergyCost = 10,
		viewportCFrame = function(model: Model, cam: Camera)
			local extentsSize = model:GetExtentsSize()

			cam.CFrame = CFrame.lookAt((model.HumanoidRootPart.CFrame * CFrame.new(0, 7, -extentsSize.Z/2.5)).Position, model.HumanoidRootPart.Position + Vector3.new(0, 4.5, 0))
		end
	},
	TralaleroTralala = {
		DisplayName = "Tralalero Tralala",
		AttackAnimation = toAnimationString(0),
		WalkingAnimation = toAnimationString(0),
		AttackDmg = 15,
		Health = 100,
		Rarity = "Common",
		SpawnPrice = 0,
		EnergyCost = 10,
		viewportCFrame = function(model: Model, cam: Camera)
			local extentsSize = model:GetExtentsSize()

			cam.CFrame = CFrame.lookAt((model.HumanoidRootPart.CFrame * CFrame.new(-10, 3, -extentsSize.Z/1.5)).Position, model.HumanoidRootPart.Position + Vector3.new(3,5,0))
		end
	},
	TrippiTroppi = {
		DisplayName = "Trippi Troppi",
		AttackAnimation = toAnimationString(0),
		WalkingAnimation = toAnimationString(0),
		AttackDmg = 15,
		Health = 100,
		Rarity = "Rare",
		SpawnPrice = 0,
		EnergyCost = 10,
		viewportCFrame = function(model: Model, cam: Camera)
			local extentsSize = model:GetExtentsSize()

			cam.CFrame = CFrame.lookAt((model.HumanoidRootPart.CFrame * CFrame.new(0, 1, -extentsSize.Z/1.25)).Position, model.HumanoidRootPart.Position + Vector3.new(0, 1, 0))
		end
	}
}

export type Brainrot = {
	DisplayName: string,
	AttackAnimation: string,
	WalkingAnimation: string,
	AttackDmg: number,
	Health: number,
	Rarity: string,
	SpawnPrice: number,
	EnergyCost: number,
}

export type Data = typeof(Data)

return Data