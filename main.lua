local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Delight Hub",
   LoadingTitle = "Delight Hub v9 | Combat Master",
   LoadingSubtitle = "by Rayzer",
   ConfigurationSaving = { Enabled = true, Folder = "DelightHubConfig" }
})

local ESP_Enabled = false
local ESP_Color = Color3.fromRGB(0, 255, 255)
local InfJump, Noclip, Fly, MoonWalk = false, false, false, false
local AutoClicker, SpinBot = false, false
local Aimbot, AimAssist, TeamCheck, WallCheck, KillAura = false, false, false, false, false
local FlySpeed, Aimbot_FOV, Hitbox_Size = 50, 90, 2

local function updateESP()
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer and player.Character then
            local char = player.Character
            local highlight = char:FindFirstChild("Delight_Highlight")
            if ESP_Enabled then
                if not highlight then
                    highlight = Instance.new("Highlight", char)
                    highlight.Name = "Delight_Highlight"
                end
                highlight.FillColor = ESP_Color
            elseif highlight then
                highlight:Destroy()
            end
        end
    end
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Aimbot_FOV
    local Camera = workspace.CurrentCamera

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if TeamCheck and player.Team == game.Players.LocalPlayer.Team then continue end
            
            local head = player.Character.Head
            local screenPoint, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                if WallCheck then
                    local parts = Camera:GetPartsObscuringTarget({Camera.CFrame.Position, head.Position}, {game.Players.LocalPlayer.Character, player.Character})
                    if #parts > 0 then continue end
                end

                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - game:GetService("UserInputService"):GetMouseLocation()).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

game:GetService("RunService").RenderStepped:Connect(function()
    if Aimbot or AimAssist then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local lookAt = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.Head.Position)
            if Aimbot then
                workspace.CurrentCamera.CFrame = lookAt
            else
                workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(lookAt, 0.1)
            end
        end
    end
    
    if KillAura then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < 20 then
                    local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end
    end

    if Noclip and game.Players.LocalPlayer.Character then
        for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    if MoonWalk and game.Players.LocalPlayer.Character then
        local char = game.Players.LocalPlayer.Character
        if char.Humanoid.MoveDirection.Magnitude > 0 then
            char:SetPrimaryPartCFrame(char.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(180), 0))
        end
    end
end)

local CombatTab = Window:CreateTab("Combat")
CombatTab:CreateToggle({Name = "Aimbot", CurrentValue = false, Callback = function(v) Aimbot = v end})
CombatTab:CreateToggle({Name = "Aim Assist (Legit)", CurrentValue = false, Callback = function(v) AimAssist = v end})
CombatTab:CreateToggle({Name = "Team Check", CurrentValue = false, Callback = function(v) TeamCheck = v end})
CombatTab:CreateToggle({Name = "Wall Check", CurrentValue = false, Callback = function(v) WallCheck = v end})
CombatTab:CreateSlider({Name = "Aimbot FOV", Range = {30, 500}, Increment = 1, CurrentValue = 90, Callback = function(v) Aimbot_FOV = v end})
CombatTab:CreateSection("Hitbox & Melee")
CombatTab:CreateToggle({Name = "Kill Aura", CurrentValue = false, Callback = function(v) KillAura = v end})
CombatTab:CreateSlider({Name = "Hitbox Expander", Range = {2, 50}, Increment = 1, CurrentValue = 2, Callback = function(v)
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Size = Vector3.new(v, v, v)
            player.Character.HumanoidRootPart.Transparency = 0.7
            player.Character.HumanoidRootPart.CanCollide = false
        end
    end
end})

local VisualsTab = Window:CreateTab("Visuals")
VisualsTab:CreateToggle({Name = "ESP Highlight", CurrentValue = false, Callback = function(v) ESP_Enabled = v task.spawn(function() while ESP_Enabled do updateESP() task.wait(1) end end) end})
VisualsTab:CreateColorPicker({Name = "ESP Color", Color = Color3.fromRGB(0, 255, 255), Callback = function(v) ESP_Color = v end})
VisualsTab:CreateSlider({Name = "FOV Changer", Range = {70, 120}, Increment = 1, CurrentValue = 70, Callback = function(v) game.Workspace.CurrentCamera.FieldOfView = v end})
VisualsTab:CreateButton({Name = "No Fog & Full Bright", Callback = function() game:GetService("Lighting").FogEnd = 100000 game:GetService("Lighting").Brightness = 2 game:GetService("Lighting").ClockTime = 14 end})

local MovementTab = Window:CreateTab("Movement")
MovementTab:CreateSlider({Name = "Speed", Range = {16, 1000}, Increment = 1, CurrentValue = 16, Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end})
MovementTab:CreateSlider({Name = "Jump", Range = {50, 1000}, Increment = 1, CurrentValue = 50, Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true game.Players.LocalPlayer.Character.Humanoid.JumpPower = v end})
MovementTab:CreateToggle({Name = "Fly", CurrentValue = false, Callback = function(v) 
    Fly = v
    if v then
        local bv = Instance.new("BodyVelocity", game.Players.LocalPlayer.Character.PrimaryPart)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Name = "FlyVel"
        task.spawn(function() while Fly do bv.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * FlySpeed task.wait() end bv:Destroy() end)
    end
end})
MovementTab:CreateSlider({Name = "Fly Speed", Range = {10, 1000}, Increment = 1, CurrentValue = 50, Callback = function(v) FlySpeed = v end})
MovementTab:CreateToggle({Name = "Moon Walk", CurrentValue = false, Callback = function(v) MoonWalk = v end})
MovementTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) InfJump = v end})

local MiscTab = Window:CreateTab("Misc")
MiscTab:CreateButton({Name = "Click TP (Ctrl+Click)", Callback = function() Rayfield:Notify({Title="Ready", Content="Hold Ctrl and Click!"}) end})
MiscTab:CreateButton({Name = "Give BTools", Callback = function() Instance.new("HopperBin", game.Players.LocalPlayer.Backpack).BinType = "Hammer" Instance.new("HopperBin", game.Players.LocalPlayer.Backpack).BinType = "Clone" Instance.new("HopperBin", game.Players.LocalPlayer.Backpack).BinType = "Grab" end})
MiscTab:CreateButton({Name = "Anti-AFK", Callback = function() game.Players.LocalPlayer.Idled:Connect(function() game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame) task.wait(1) game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) end) end})
MiscTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Noclip = v end})
