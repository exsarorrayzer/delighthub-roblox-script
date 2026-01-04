local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Delight Hub",
   LoadingTitle = "Delight Hub v3",
   LoadingSubtitle = "by Rayzer",
   ConfigurationSaving = { Enabled = true, Folder = "DelightHubConfig" }
})

local ESP_Enabled = false
local ESP_Color = Color3.fromRGB(0, 255, 255)
local InfJump_Enabled = false
local Noclip_Enabled = false
local Fly_Enabled = false
local FlySpeed = 50
local WalkSpeed_Val = 16
local JumpPower_Val = 50

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

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfJump_Enabled then
        game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

game:GetService("RunService").Stepped:Connect(function()
    if Noclip_Enabled and game.Players.LocalPlayer.Character then
        for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

local VisualsTab = Window:CreateTab("Visuals")

VisualsTab:CreateToggle({
   Name = "ESP Highlight",
   CurrentValue = false,
   Callback = function(v)
      ESP_Enabled = v
      task.spawn(function() while ESP_Enabled do updateESP() task.wait(1) end end)
   end
})

VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(0, 255, 255),
    Callback = function(v) ESP_Color = v end
})

VisualsTab:CreateButton({
   Name = "Full Bright",
   Callback = function()
      game:GetService("Lighting").Brightness = 2
      game:GetService("Lighting").ClockTime = 14
      game:GetService("Lighting").GlobalShadows = false
   end
})

local MovementTab = Window:CreateTab("Movement")

MovementTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 1000},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) 
      WalkSpeed_Val = v 
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v 
   end
})

MovementTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 1000},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(v) 
      JumpPower_Val = v
      game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
      game.Players.LocalPlayer.Character.Humanoid.JumpPower = v 
   end
})

MovementTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 1000},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(v) FlySpeed = v end
})

MovementTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Callback = function(v)
      Fly_Enabled = v
      local char = game.Players.LocalPlayer.Character
      if v then
         local bv = Instance.new("BodyVelocity", char.PrimaryPart)
         bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
         bv.Velocity = Vector3.new(0,0,0)
         bv.Name = "FlyVelocity"
         task.spawn(function()
            while Fly_Enabled do
               bv.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * FlySpeed
               task.wait()
            end
            bv:Destroy()
         end)
      end
   end
})

MovementTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(v) InfJump_Enabled = v end
})

MovementTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Callback = function(v) Noclip_Enabled = v end
})
