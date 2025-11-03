local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Brainrots = require(ReplicatedStorage.Configurations.Brainrots)

local ViewportHandler = {}

function ViewportHandler.ProcessBrainrotViewport(viewport: ViewportFrame, brainrotName: string)
    local brainrotInfo = Brainrots[brainrotName]
    local viewportModel = ReplicatedStorage.Assets.Brainrots:FindFirstChild(brainrotName)
    local camera

    if not viewport:FindFirstChild("Camera") then
        camera = Instance.new("Camera")
        camera.Name = "Camera"
        camera.Parent = viewport

        viewport.CurrentCamera = camera
    else
        camera = viewport:FindFirstChild("Camera")
    end

    local oldModel = viewport:FindFirstChild("Model")
    if oldModel then
        oldModel:Destroy()
    end

    if not viewportModel then
        return
    end

    local model = viewportModel:Clone()
    model.Name = "Model"
    model.Parent = viewport

    if brainrotInfo.viewportCFrame then
        brainrotInfo.viewportCFrame(model, camera)
    else
        local extentsSize = model:GetExtentsSize()
        local height = extentsSize.Y / 2 + 0.5
        
        camera.CFrame = CFrame.lookAt((model:GetPivot() * CFrame.new(-5, height, -extentsSize.Z / 2 - 1)).Position, model:GetPivot().Position + Vector3.new(0, 2, 0))
        camera.CameraType = Enum.CameraType.Scriptable
        camera.FieldOfView = 70
    end
end

return ViewportHandler