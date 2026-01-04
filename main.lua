local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Delight Hub v10",
   LoadingTitle = "Delight Hub | Rayzer Edition",
   LoadingSubtitle = "by Rayzer",
   ConfigurationSaving = { Enabled = true, Folder = "DelightHubConfig" }
})

local LP = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ESP_Enabled = false
local ESP_Color = Color3.fromRGB(0, 255, 255)
local Fly_Enabled, FlySpeed = false, 50
local Noclip_Enabled, MoonWalk_Enabled = false, false
local InfJump_Enabled, AutoClicker_Enabled = false, false
local OldAimbot, NewAimbot, TriggerBot = false, false, false
local KillAura, TeamCheck, WallCheck = false, false, false
local Aimbot_FOV, Hitbox_Size = 150, 2

local function getChar() return LP.Character or LP.CharacterAdded:Wait() end
local function getHum() return getChar():FindFirstChildOfClass("Humanoid") end

local function updateESP()
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= LP and player.Character then
            local highlight = player.Character:FindFirstChild("Delight_Highlight")
            if ESP_Enabled then
                if not highlight then
                    highlight = Instance.new("Highlight", player.Character)
                    highlight.Name = "Delight_Highlight"
                end
                highlight.FillColor = ESP_Color
            elseif highlight then
                highlight:Destroy()
            end
        end
    end
end

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
                if TeamCheck and p.Team == LP.Team then else
                    mouse1click()
                end
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

    if Noclip_Enabled then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    if MoonWalk_Enabled and getHum().MoveDirection.Magnitude > 0 then
        char:SetPrimaryPartCFrame(char.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(180), 0))
    end
end)

UIS.JumpRequest:Connect(function()
    if InfJump_Enabled then
        getHum():ChangeState("Jumping")
    end
end)

local CombatTab = Window:CreateTab("Combat")
CombatTab:CreateToggle({Name = "Old Aimbot (Hard)", CurrentValue = false, Callback = function(v) OldAimbot = v end})
CombatTab:CreateToggle({Name = "New Aimbot (Smooth)", CurrentValue = false, Callback = function(v) NewAimbot = v end})
CombatTab:CreateToggle({Name = "Triggerbot", CurrentValue = false, Callback = function(v) TriggerBot = v end})
CombatTab:CreateToggle({Name = "Kill Aura", CurrentValue = false, Callback = function(v) KillAura = v end})
CombatTab:CreateToggle({Name = "Wall Check", CurrentValue = false, Callback = function(v) WallCheck = v end})
CombatTab:CreateToggle({Name = "Team Check", CurrentValue = false, Callback = function(v) TeamCheck = v end})
CombatTab:CreateSlider({Name = "Aimbot FOV", Range = {50, 800}, Increment = 1, CurrentValue = 150, Callback = function(v) Aimbot_FOV = v end})

local MovementTab = Window:CreateTab("Movement")
MovementTab:CreateSlider({Name = "WalkSpeed", Range = {16, 1000}, Increment = 1, CurrentValue = 16, Callback = function(v) getHum().WalkSpeed = v end})
MovementTab:CreateSlider({Name = "JumpPower", Range = {50, 1000}, Increment = 1, CurrentValue = 50, Callback = function(v) getHum().UseJumpPower = true getHum().JumpPower = v end})
MovementTab:CreateToggle({Name = "Fly", CurrentValue = false, Callback = function(v) 
    Fly_Enabled = v
    if v then
        local bv = Instance.new("BodyVelocity", LP.Character.PrimaryPart)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Name = "FlyVel"
        task.spawn(function() while Fly_Enabled do bv.Velocity = Camera.CFrame.LookVector * FlySpeed task.wait() end bv:Destroy() end)
    end
end})
MovementTab:CreateSlider({Name = "Fly Speed", Range = {10, 1000}, Increment = 1, CurrentValue = 50, Callback = function(v) FlySpeed = v end})
MovementTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Noclip_Enabled = v end})
MovementTab:CreateToggle({Name = "Moon Walk", CurrentValue = false, Callback = function(v) MoonWalk_Enabled = v end})
MovementTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) InfJump_Enabled = v end})

local VisualsTab = Window:CreateTab("Visuals")
VisualsTab:CreateToggle({Name = "ESP Highlight", CurrentValue = false, Callback = function(v) ESP_Enabled = v task.spawn(function() while ESP_Enabled do updateESP() task.wait(1) end end) end})
VisualsTab:CreateButton({Name = "No Fog & Full Bright", Callback = function() game:GetService("Lighting").FogEnd = 100000 game:GetService("Lighting").Brightness = 2 end})

local MiscTab = Window:CreateTab("Misc")
MiscTab:CreateButton({Name = "Give BTools", Callback = function() Instance.new("HopperBin", LP.Backpack).BinType = "Hammer" Instance.new("HopperBin", LP.Backpack).BinType = "Clone" Instance.new("HopperBin", LP.Backpack).BinType = "Grab" end})
MiscTab:CreateButton({Name = "Anti-AFK", Callback = function() LP.Idled:Connect(function() game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),Camera.CFrame) task.wait(1) game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),Camera.CFrame) end) end})
