--[[
    jumpindex.lua
    - ∞ OFF: clicar ⬆ = 1 pulo normal
    - ∞ ON: SEGURAR ⬆ = pula infinitamente / soltar = para
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local antiga = playerGui:FindFirstChild("BotaoPularGui")
if antiga then antiga:Destroy() end

------------------------------------------------------------
-- SCREEN GUI
------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BotaoPularGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = playerGui

------------------------------------------------------------
-- FRAME PAI
------------------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 60, 0, 90)
mainFrame.Position = UDim2.new(1, -80, 0, 20)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

------------------------------------------------------------
-- BOTÃO ⬆
------------------------------------------------------------
local container = Instance.new("Frame")
container.Name = "ContainerBotao"
container.Size = UDim2.new(0, 50, 0, 50)
container.Position = UDim2.new(0, 5, 0, 0)
container.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
container.BorderSizePixel = 0
container.Parent = mainFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = container

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 2
stroke.Transparency = 0.5
stroke.Parent = container

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 160, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 80, 200))
})
gradient.Rotation = 90
gradient.Parent = container

local botao = Instance.new("TextButton")
botao.Name = "BtnPular"
botao.Size = UDim2.new(1, 0, 1, 0)
botao.BackgroundTransparency = 1
botao.Text = "⬆"
botao.TextColor3 = Color3.fromRGB(255, 255, 255)
botao.TextScaled = true
botao.Font = Enum.Font.GothamBold
botao.AutoButtonColor = false
botao.Active = true
botao.Parent = container

local textSize = Instance.new("UITextSizeConstraint")
textSize.MaxTextSize = 30
textSize.Parent = botao

------------------------------------------------------------
-- TOGGLE ∞
------------------------------------------------------------
local toggleContainer = Instance.new("Frame")
toggleContainer.Name = "ContainerToggle"
toggleContainer.Size = UDim2.new(0, 50, 0, 22)
toggleContainer.Position = UDim2.new(0, 5, 0, 60)
toggleContainer.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
toggleContainer.BorderSizePixel = 0
toggleContainer.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleContainer

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(80, 130, 220)
toggleStroke.Thickness = 1.5
toggleStroke.Parent = toggleContainer

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "BtnToggle"
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = "∞ OFF"
toggleBtn.TextColor3 = Color3.fromRGB(180, 200, 230)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.AutoButtonColor = false
toggleBtn.Active = true
toggleBtn.Parent = toggleContainer

local toggleTextSize = Instance.new("UITextSizeConstraint")
toggleTextSize.MaxTextSize = 13
toggleTextSize.Parent = toggleBtn

------------------------------------------------------------
-- ESTADOS
------------------------------------------------------------
local infiniteArmado = false
local segurando      = false

------------------------------------------------------------
-- VISUAIS
------------------------------------------------------------
local function atualizarToggle()
    if infiniteArmado then
        toggleBtn.Text = "∞ ON"
        toggleBtn.TextColor3 = Color3.fromRGB(120, 255, 160)
        toggleStroke.Color = Color3.fromRGB(80, 255, 130)
        toggleContainer.BackgroundColor3 = Color3.fromRGB(25, 70, 40)
    else
        toggleBtn.Text = "∞ OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(180, 200, 230)
        toggleStroke.Color = Color3.fromRGB(80, 130, 220)
        toggleContainer.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
    end
end

local function atualizarVisualBotao()
    if segurando then
        container.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 255, 160)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 140, 60))
        })
    elseif infiniteArmado then
        container.BackgroundColor3 = Color3.fromRGB(40, 110, 70)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 160, 100)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 80, 50))
        })
    else
        container.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 160, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 80, 200))
        })
    end
end

------------------------------------------------------------
-- TOGGLE
------------------------------------------------------------
toggleBtn.MouseButton1Click:Connect(function()
    infiniteArmado = not infiniteArmado
    if not infiniteArmado then
        segurando = false
    end
    atualizarToggle()
    atualizarVisualBotao()
    print("[jumpindex] Toggle: " .. (infiniteArmado and "ON" or "OFF"))
end)

------------------------------------------------------------
-- PULO NORMAL
------------------------------------------------------------
local ultimoPulo = 0

local function pularNormal()
    local agora = tick()
    if agora - ultimoPulo < 0.25 then return end

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local estado = humanoid:GetState()
    if estado == Enum.HumanoidStateType.Jumping
       or estado == Enum.HumanoidStateType.Freefall then
        return
    end
    if humanoid.FloorMaterial == Enum.Material.Air then return end

    ultimoPulo = agora

    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end

------------------------------------------------------------
-- DETECÇÃO DE POSIÇÃO
------------------------------------------------------------
local function estaDentroDoBotao(posicao)
    local absPos  = container.AbsolutePosition
    local absSize = container.AbsoluteSize
    return posicao.X >= absPos.X and posicao.X <= absPos.X + absSize.X
       and posicao.Y >= absPos.Y and posicao.Y <= absPos.Y + absSize.Y
end

------------------------------------------------------------
-- INPUT GLOBAL
------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, processado)
    if processado then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        if estaDentroDoBotao(input.Position) then
            print("[jumpindex] Pressionou ⬆ | ∞ = " .. tostring(infiniteArmado))

            if infiniteArmado then
                segurando = true
                atualizarVisualBotao()
            else
                pularNormal()
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        if segurando then
            segurando = false
            atualizarVisualBotao()
            print("[jumpindex] Soltou ⬆")
        end
    end
end)

------------------------------------------------------------
-- LOOP: pula infinito enquanto armado E segurando
------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not (infiniteArmado and segurando) then return end

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end)

------------------------------------------------------------
-- INICIALIZAR
------------------------------------------------------------
atualizarToggle()
atualizarVisualBotao()
print("[jumpindex] Carregado!")
