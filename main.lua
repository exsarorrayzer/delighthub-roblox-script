local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Delight Hub v12",
   LoadingTitle = "Delight Hub | Final Edition",
   LoadingSubtitle = "by Rayzer",
   ConfigurationSaving = { Enabled = true, Folder = "DelightHubConfig" }
})

local LP = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ESP_Enabled = false
local Fly_Enabled, FlySpeed = false, 50
local Noclip_Enabled, InfJump_Enabled, Spider_Enabled = false, false, false
local OldAimbot, NewAimbot, TriggerBot = false, false, false
local KillAura, TeamCheck, WallCheck = false, false, false
local Aimbot_FOV, Hitbox_W, Hitbox_H = 150, 2, 2
local MaxDistance = 500
local Xray_Enabled = false
local RainbowMap_Enabled = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false

local function getChar() return LP.Character or LP.CharacterAdded:Wait() end
local function getHum() return getChar():FindFirstChildOfClass("Humanoid") end

local function getClosest()
    local target = nil
    local dist = Aimbot_FOV
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("HumanoidRootPart") then
            if TeamCheck and v.Team == LP.Team then continue end
            
            local magToPlayer = (getChar().HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if magToPlayer > MaxDistance then continue end

            if WallCheck then
                local ray = Camera:GetPartsObscuringTarget({Camera.CFrame.Position, v.Character.Head.Position}, {getChar(), v.Character})
                if #ray > 0 then continue end
            end

            local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if mag < dist then
                    dist = mag
                    target = v
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    local char = LP.Character
    if not char then return end

    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Radius = Aimbot_FOV

    if OldAimbot then
        local t = getClosest()
        if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position) end
    end

    if NewAimbot then
        local t = getClosest()
        if t then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Character.Head.Position), 0.15) end
    end

    if KillAura then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                if (char.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude < 18 then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end
    end

    if Spider_Enabled then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local ray = Ray.new(root.Position, root.CFrame.LookVector * 3)
            local part = workspace:FindPartOnRay(ray, char)
            if part then root.Velocity = Vector3.new(root.Velocity.X, 30, root.Velocity.Z) end
        end
    end

    if Noclip_Enabled then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    if ESP_Enabled then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local high = p.Character:FindFirstChild("Delight_Highlight") or Instance.new("Highlight", p.Character)
                high.Name = "Delight_Highlight"
                high.FillTransparency = 0.5
                high.OutlineTransparency = 0
                high.Enabled = true
            end
        end
    else
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Delight_Highlight") then
                p.Character.Delight_Highlight:Destroy()
            end
        end
    end
end)

local CombatTab = Window:CreateTab("Combat")
CombatTab:CreateSection("Aimbot Settings")
CombatTab:CreateToggle({Name = "Old Aimbot", CurrentValue = false, Callback = function(v) OldAimbot = v end})
CombatTab:CreateToggle({Name = "New Aimbot", CurrentValue = false, Callback = function(v) NewAimbot = v end})
CombatTab:CreateToggle({Name = "Wall Check", CurrentValue = false, Callback = function(v) WallCheck = v end})
CombatTab:CreateSlider({Name = "Max Distance", Range = {10, 5000}, Increment = 10, CurrentValue = 500, Callback = function(v) MaxDistance = v end})
CombatTab:CreateSlider({Name = "Aimbot FOV", Range = {30, 800}, Increment = 1, CurrentValue = 150, Callback = function(v) Aimbot_FOV = v end})
CombatTab:CreateToggle({Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) FOVCircle.Visible = v end})

local MovementTab = Window:CreateTab("Movement")
MovementTab:CreateSlider({Name = "Speed", Range = {16, 1000}, Increment = 1, CurrentValue = 16, Callback = function(v) getHum().WalkSpeed = v end})
MovementTab:CreateToggle({Name = "Fly", CurrentValue = false, Callback = function(v) 
    Fly_Enabled = v
    if v then
        local bv = Instance.new("BodyVelocity", getChar().PrimaryPart)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Name = "FlyVel"
        task.spawn(function() while Fly_Enabled do bv.Velocity = Camera.CFrame.LookVector * FlySpeed task.wait() end bv:Destroy() end)
    end
end})
MovementTab:CreateSlider({Name = "Fly Speed", Range = {10, 1000}, Increment = 1, CurrentValue = 50, Callback = function(v) FlySpeed = v end})
MovementTab:CreateToggle({Name = "Spider Mode", CurrentValue = false, Callback = function(v) Spider_Enabled = v end})
MovementTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Noclip_Enabled = v end})

local VisualsTab = Window:CreateTab("Visuals")
VisualsTab:CreateToggle({Name = "ESP Highlight", CurrentValue = false, Callback = function(v) ESP_Enabled = v end})
VisualsTab:CreateToggle({Name = "X-Ray", CurrentValue = false, Callback = function(v) 
    Xray_Enabled = v
    for _, obj in pairs(workspace:GetDescendants()) do 
        if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") then 
            obj.LocalTransparencyModifier = v and 0.5 or 0 
        end 
    end 
end})
VisualsTab:CreateToggle({Name = "Rainbow Map", CurrentValue = false, Callback = function(v)
    RainbowMap_Enabled = v
    task.spawn(function()
        while RainbowMap_Enabled do
            game:GetService("Lighting").Ambient = Color3.fromHSV(tick()%5/5,1,1)
            task.wait()
        end
        game:GetService("Lighting").Ambient = Color3.fromRGB(0,0,0)
    end)
end})
VisualsTab:CreateButton({Name = "Full Bright", Callback = function() game:GetService("Lighting").Brightness = 2 end})
