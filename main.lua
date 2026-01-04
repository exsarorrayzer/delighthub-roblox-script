local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Delight Hub",
   LoadingTitle = "Delight Hub v6",
   LoadingSubtitle = "by Rayzer",
   ConfigurationSaving = { Enabled = true, Folder = "DelightHubConfig" }
})

local ESP_Enabled = false
local ESP_Color = Color3.fromRGB(0, 255, 255)
local InfJump_Enabled = false
local Noclip_Enabled = false
local Fly_Enabled = false
local FlySpeed = 50
local MoonWalk_Enabled = false

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

game:GetService("RunService").Stepped:Connect(function()
    if Noclip_Enabled and game.Players.LocalPlayer.Character then
        for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
    if MoonWalk_Enabled and game.Players.LocalPlayer.Character then
        local char = game.Players.LocalPlayer.Character
        if char:FindFirstChild("Humanoid") and char.Humanoid.MoveDirection.Magnitude > 0 then
            char:SetPrimaryPartCFrame(char.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(180), 0))
        end
    end
end)

local VisualsTab = Window:CreateTab("Visuals")
VisualsTab:CreateToggle({Name = "ESP Highlight", CurrentValue = false, Callback = function(v) ESP_Enabled = v task.spawn(function() while ESP_Enabled do updateESP() task.wait(1) end end) end})
VisualsTab:CreateButton({Name = "Full Bright & No Fog", Callback = function() game:GetService("Lighting").Brightness = 2 game:GetService("Lighting").ClockTime = 14 game:GetService("Lighting").FogEnd = 100000 end})

local MovementTab = Window:CreateTab("Movement")
MovementTab:CreateSlider({Name = "Speed", Range = {16, 1000}, Increment = 1, CurrentValue = 16, Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end})
MovementTab:CreateSlider({Name = "Jump", Range = {50, 1000}, Increment = 1, CurrentValue = 50, Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true game.Players.LocalPlayer.Character.Humanoid.JumpPower = v end})
MovementTab:CreateToggle({Name = "Moon Walk", CurrentValue = false, Callback = function(v) MoonWalk_Enabled = v end})
MovementTab:CreateToggle({Name = "Fly", CurrentValue = false, Callback = function(v) 
    Fly_Enabled = v
    if v then
        local bv = Instance.new("BodyVelocity", game.Players.LocalPlayer.Character.PrimaryPart)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Name = "FlyVel"
        task.spawn(function() while Fly_Enabled do bv.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * FlySpeed task.wait() end bv:Destroy() end)
    end
end})
MovementTab:CreateSlider({Name = "Fly Speed", Range = {10, 1000}, Increment = 1, CurrentValue = 50, Callback = function(v) FlySpeed = v end})

local MiscTab = Window:CreateTab("Misc")
MiscTab:CreateButton({
   Name = "Give BTools",
   Callback = function()
      local tool1 = Instance.new("HopperBin", game.Players.LocalPlayer.Backpack) tool1.BinType = "Hammer"
      local tool2 = Instance.new("HopperBin", game.Players.LocalPlayer.Backpack) tool2.BinType = "Clone"
      local tool3 = Instance.new("HopperBin", game.Players.LocalPlayer.Backpack) tool3.BinType = "Grab"
   end
})
MiscTab:CreateButton({
   Name = "Enable Anti-AFK",
   Callback = function()
      local vu = game:GetService("VirtualUser")
      game.Players.LocalPlayer.Idled:Connect(function()
         vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
         task.wait(1)
         vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
      end)
   end
})
MiscTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Noclip_Enabled = v end})
MiscTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) InfJump_Enabled = v end})
