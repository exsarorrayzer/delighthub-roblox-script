local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Delight Hub v11",
   LoadingTitle = "Delight Hub | Ultimate Combat",
   LoadingSubtitle = "by Rayzer",
   ConfigurationSaving = { Enabled = true, Folder = "DelightHubConfig" }
})

local LP = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ESP_Enabled = false
local Fly_Enabled, FlySpeed = false, 50
local Noclip_Enabled, MoonWalk_Enabled, InfJump_Enabled = false, false, false
local OldAimbot, NewAimbot, TriggerBot, SilentAim = false, false, false, false
local KillAura, TeamCheck, WallCheck, NoRecoil = false, false, false, false
local Aimbot_FOV, Hitbox_W, Hitbox_H = 150, 2, 2

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Visible = false

local function getChar() return LP.Character or LP.CharacterAdded:Wait() end
local function getHum() return getChar():FindFirstChildOfClass("Humanoid") end

local function getClosest()
    local target = nil
    local dist = Aimbot_FOV
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Head") then
            if TeamCheck and v.Team == LP.Team then continue end
            local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if mag < dist then
                    if WallCheck then
                        local ray = Camera:GetPartsObscuringTarget({Camera.CFrame.Position, v.Character.Head.Position}, {getChar(), v.Character})
                        if #ray > 0 then continue end
                    end
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

    if TriggerBot then
        local target = LP:GetMouse().Target
        if target and target.Parent:FindFirstChild("Humanoid") then
            local p = game.Players:GetPlayerFromCharacter(target.Parent)
            if p and p ~= LP then
                if not (TeamCheck and p.Team == LP.Team) then mouse1click() end
            end
        end
    end

    if KillAura then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local d = (char.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if d < 18 then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end
    end

    if NoRecoil then
        local localScript = char:FindFirstChildOfClass("LocalScript")
        if localScript then
            local env = getfenv(localScript)
            if env.Recoil then env.Recoil = 0 end
        end
    end

    if Noclip_Enabled then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if InfJump_Enabled then getHum():ChangeState("Jumping") end
end)

local CombatTab = Window:CreateTab("Combat")
CombatTab:CreateToggle({Name = "Old Aimbot (Hard)", CurrentValue = false, Callback = function(v) OldAimbot = v end})
CombatTab:CreateToggle({Name = "New Aimbot (Smooth)", CurrentValue = false, Callback = function(v) NewAimbot = v end})
CombatTab:CreateToggle({Name = "Triggerbot", CurrentValue = false, Callback = function(v) TriggerBot = v end})
CombatTab:CreateToggle({Name = "Kill Aura", CurrentValue = false, Callback = function(v) KillAura = v end})
CombatTab:CreateToggle({Name = "No Recoil", CurrentValue = false, Callback = function(v) NoRecoil = v end})
CombatTab:CreateToggle({Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) FOVCircle.Visible = v end})
CombatTab:CreateSlider({Name = "Aimbot FOV", Range = {30, 800}, Increment = 1, CurrentValue = 150, Callback = function(v) Aimbot_FOV = v end})

CombatTab:CreateSection("Hitbox Customizer")
CombatTab:CreateSlider({Name = "Hitbox Width (W)", Range = {2, 50}, Increment = 1, CurrentValue = 2, Callback = function(v)
    Hitbox_W = v
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.Size = Vector3.new(v, Hitbox_H, v)
            p.Character.HumanoidRootPart.Transparency = 0.7
            p.Character.HumanoidRootPart.CanCollide = false
        end
    end
end})
CombatTab:CreateSlider({Name = "Hitbox Height (H)", Range = {2, 50}, Increment = 1, CurrentValue = 2, Callback = function(v)
    Hitbox_H = v
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.Size = Vector3.new(Hitbox_W, v, Hitbox_W)
            p.Character.HumanoidRootPart.Transparency = 0.7
            p.Character.HumanoidRootPart.CanCollide = false
        end
    end
end})

local MovementTab = Window:CreateTab("Movement")
MovementTab:CreateSlider({Name = "WalkSpeed", Range = {16, 1000}, Increment = 1, CurrentValue = 16, Callback = function(v) getHum().WalkSpeed = v end})
MovementTab:CreateSlider({Name = "JumpPower", Range = {50, 1000}, Increment = 1, CurrentValue = 50, Callback = function(v) getHum().UseJumpPower = true getHum().JumpPower = v end})
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
MovementTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Noclip_Enabled = v end})
MovementTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) InfJump_Enabled = v end})

local VisualsTab = Window:CreateTab("Visuals")
VisualsTab:CreateToggle({Name = "ESP Highlight", CurrentValue = false, Callback = function(v) ESP_Enabled = v end})
VisualsTab:CreateButton({Name = "Full Bright", Callback = function() game:GetService("Lighting").Brightness = 2 end})
