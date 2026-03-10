-- FleeUI v0.1 – Biblioteca simples de interface para Flee the Facility / jogos similares
-- Uso exemplo no final do script

local FleeUI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ────────────────────────────────────────────────
-- Configuração inicial da GUI
-- ────────────────────────────────────────────────

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FleeUI_Lib"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0.38, 0, 0.62, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0, -20, 0, -20)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6014261993" -- sombra preta suave (mude se quiser)
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49,49,450,450)
shadow.Parent = mainFrame
shadow.ZIndex = -1

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1,0,0,42)
topBar.BackgroundColor3 = Color3.fromRGB(18,18,18)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.6,0,1,0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Flee Menu"
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextXOffset = 16
titleLabel.Parent = topBar

-- Botão minimizar / maximizar (ícone circular fixo)
local minimizeBtn = Instance.new("ImageButton")
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.Size = UDim2.new(0,38,0,38)
minimizeBtn.Position = UDim2.new(1,-46,0.5,0)
minimizeBtn.AnchorPoint = Vector2.new(1,0.5)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Image = "rbxassetid://7072718362" -- ícone de menos / quadrado (você troca depois)
minimizeBtn.ImageColor3 = Color3.fromRGB(180,180,180)
minimizeBtn.Parent = topBar

local minBtnCorner = Instance.new("UICorner")
minBtnCorner.CornerRadius = UDim.new(1,0)
minBtnCorner.Parent = minimizeBtn

local minBtnStroke = Instance.new("UIStroke")
minBtnStroke.Color = Color3.fromRGB(90,90,90)
minBtnStroke.Thickness = 1.5
minBtnStroke.Transparency = 0.4
minBtnStroke.Parent = minimizeBtn

-- Estado minimizado
local minimized = false
local originalSize = mainFrame.Size

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        mainFrame:TweenSize(UDim2.new(0.12,0,0.08,0), "Out", "Quad", 0.35, true)
        minimizeBtn.Image = "rbxassetid://7072721037" -- ícone de expandir (troque)
    else
        mainFrame:TweenSize(originalSize, "Out", "Quad", 0.35, true)
        minimizeBtn.Image = "rbxassetid://7072718362" -- ícone de minimizar
    end
end)

-- Conteúdo principal (onde ficam as abas)
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1,0,1,-50)
content.Position = UDim2.new(0,0,0,50)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local tabButtonsHolder = Instance.new("Frame")
tabButtonsHolder.Size = UDim2.new(1,0,0,40)
tabButtonsHolder.BackgroundTransparency = 1
tabButtonsHolder.Parent = content

local tabContent = Instance.new("ScrollingFrame")
tabContent.Name = "TabContent"
tabContent.Size = UDim2.new(1,-16,1,-48)
tabContent.Position = UDim2.new(0,8,0,44)
tabContent.BackgroundTransparency = 1
tabContent.ScrollBarThickness = 5
tabContent.ScrollBarImageColor3 = Color3.fromRGB(80,80,80)
tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabContent.CanvasSize = UDim2.new(0,0,0,0)
tabContent.Parent = content

local tabList = Instance.new("UIListLayout")
tabList.Padding = UDim.new(0,8)
tabList.FillDirection = Enum.FillDirection.Vertical
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Parent = tabContent

-- ────────────────────────────────────────────────
-- Funções de criação de elementos
-- ────────────────────────────────────────────────

local elementCounter = 0

local function createElementWrapper(name, parent)
    elementCounter += 1
    local id = "elem_" .. elementCounter

    local frame = Instance.new("Frame")
    frame.Name = name .. "_" .. id
    frame.Size = UDim2.new(1,0,0,54)
    frame.BackgroundColor3 = Color3.fromRGB(38,38,38)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.58,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(0.95,0.95,0.95)
    label.TextScaled = true
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextXOffset = 16
    label.Parent = frame

    local obj = { Id = id, Frame = frame, Label = label }

    function obj:SetLabel(text)
        label.Text = text
    end

    return obj, frame
end

-- Toggle estilo iOS
function FleeUI:CreateToggle(parent, name, default, callback)
    local obj, frame = createElementWrapper(name, parent)

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0,54,0,28)
    track.Position = UDim2.new(1,-70,0.5,0)
    track.AnchorPoint = Vector2.new(1,0.5)
    track.BackgroundColor3 = default and Color3.fromRGB(0,170,100) or Color3.fromRGB(70,70,70)
    track.BorderSizePixel = 0
    track.Parent = frame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1,0)
    trackCorner.Parent = track

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,24,0,24)
    knob.Position = UDim2.new(0,2,0.5,0)
    knob.AnchorPoint = Vector2.new(0,0.5)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.Parent = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1,0)
    knobCorner.Parent = knob

    local state = default or false

    local function update()
        if state then
            track.BackgroundColor3 = Color3.fromRGB(0,170,100)
            TweenService:Create(knob, TweenInfo.new(0.22,Enum.EasingStyle.Quad), {Position = UDim2.new(0,28,0.5,0)}):Play()
        else
            track.BackgroundColor3 = Color3.fromRGB(70,70,70)
            TweenService:Create(knob, TweenInfo.new(0.22,Enum.EasingStyle.Quad), {Position = UDim2.new(0,2,0.5,0)}):Play()
        end
    end

    update()

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state = not state
            update()
            if callback then callback(state) end
        end
    end)

    function obj:Set(value)
        state = value
        update()
        if callback then callback(state) end
    end

    function obj:Get()
        return state
    end

    return obj
end

-- Button simples (clique único)
function FleeUI:CreateButton(parent, name, callback)
    local obj, frame = createElementWrapper(name, parent)
    frame.Size = UDim2.new(1,0,0,48)
    frame.BackgroundColor3 = Color3.fromRGB(0, 120, 215)

    obj.Label.TextColor3 = Color3.new(1,1,1)
    obj.Label.TextXAlignment = Enum.TextXAlignment.Center
    obj.Label.TextXOffset = 0

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if callback then callback() end
        end
    end)

    return obj
end

-- Checkbox
function FleeUI:CreateCheckbox(parent, name, default, callback)
    local obj, frame = createElementWrapper(name, parent)

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0,26,0,26)
    box.Position = UDim2.new(1,-42,0.5,0)
    box.AnchorPoint = Vector2.new(1,0.5)
    box.BackgroundColor3 = default and Color3.fromRGB(40,180,90) or Color3.fromRGB(60,60,60)
    box.Parent = frame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0,6)
    boxCorner.Parent = box

    local check = Instance.new("TextLabel")
    check.Size = UDim2.new(1,0,1,0)
    check.BackgroundTransparency = 1
    check.Text = "✓"
    check.TextColor3 = Color3.new(1,1,1)
    check.TextScaled = true
    check.Font = Enum.Font.GothamBold
    check.Visible = default
    check.Parent = box

    local state = default or false

    local function update()
        box.BackgroundColor3 = state and Color3.fromRGB(40,180,90) or Color3.fromRGB(60,60,60)
        check.Visible = state
    end
    update()

    box.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state = not state
            update()
            if callback then callback(state) end
        end
    end)

    function obj:Set(value)
        state = value
        update()
        if callback then callback(state) end
    end

    return obj
end

-- Slider (básico)
function FleeUI:CreateSlider(parent, name, min, max, default, callback)
    local obj, frame = createElementWrapper(name, parent)
    frame.Size = UDim2.new(1,0,0,64)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3,0,0.4,0)
    valueLabel.Position = UDim2.new(1,-10,0.1,0)
    valueLabel.AnchorPoint = Vector2.new(1,0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(200,200,255)
    valueLabel.TextScaled = true
    valueLabel.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0.9,0,0,8)
    bar.Position = UDim2.new(0.05,0,0.65,0)
    bar.BackgroundColor3 = Color3.fromRGB(50,50,50)
    bar.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.5,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(100,160,255)
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1,0)
    fillCorner.Parent = fill

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1,0)
    barCorner.Parent = bar

    local dragging = false

    local function update(percent)
        local val = math.floor(min + (max - min) * percent + 0.5)
        valueLabel.Text = tostring(val)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        if callback then callback(val) end
    end

    local startPercent = (default - min) / (max - min)
    update(math.clamp(startPercent, 0, 1))

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position.X
            local barAbs = bar.AbsolutePosition.X
            local barSize = bar.AbsoluteSize.X
            local rel = math.clamp((mousePos - barAbs) / barSize, 0, 1)
            update(rel)
        end
    end)

    function obj:Set(value)
        local clamped = math.clamp(value, min, max)
        local percent = (clamped - min) / (max - min)
        update(percent)
    end

    return obj
end

-- Dropdown e Textbox deixei como exercício / próximos passos (mais complexos)
-- Se quiser posso implementar depois

-- ────────────────────────────────────────────────
-- Sistema de abas
-- ────────────────────────────────────────────────

local currentTab = nil
local tabFrames = {}

function FleeUI:CreateTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.24,0,1,-6)
    tabBtn.Position = UDim2.new(0,0,0,3)
    tabBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.new(0.9,0.9,0.9)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextScaled = true
    tabBtn.Parent = tabButtonsHolder

    local tabFrame = Instance.new("Frame")
    tabFrame.Name = name .. "Tab"
    tabFrame.Size = UDim2.new(1,0,1,0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = false
    tabFrame.Parent = tabContent

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0,8)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.Parent = tabFrame

    tabFrames[name] = tabFrame

    local function selectTab()
        if currentTab then
            currentTab.Visible = false
        end
        tabFrame.Visible = true
        currentTab = tabFrame

        for _,btn in tabButtonsHolder:GetChildren() do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = (btn == tabBtn) and Color3.fromRGB(65,65,65) or Color3.fromRGB(45,45,45)
            end
        end
    end

    tabBtn.MouseButton1Click:Connect(selectTab)

    -- Abre a primeira aba automaticamente
    if not currentTab then selectTab() end

    return tabFrame
end

-- Fecha / abre janela inteira
function FleeUI:Toggle()
    mainFrame.Visible = not mainFrame.Visible
end

function FleeUI:SetTitle(text)
    titleLabel.Text = text
end

-- Exemplo de uso
do
    local tab1 = FleeUI:CreateTab("Principal")
    local tab2 = FleeUI:CreateTab("Visual")
    local tab3 = FleeUI:CreateTab("Outros")

    local tog1 = FleeUI:CreateToggle(tab1, "Speed Hack", false, function(state)
        print("Speed →", state)
    end)

    FleeUI:CreateCheckbox(tab1, "No Clip", false, function(v)
        print("NoClip:", v)
    end)

    FleeUI:CreateButton(tab1, "Teleport to Exit", function()
        print("Teleport acionado!")
    end)

    FleeUI:CreateSlider(tab1, "WalkSpeed", 16, 120, 40, function(val)
        print("WalkSpeed definido para:", val)
    end)

    -- Você pode guardar os objetos e modificar depois
    -- tog1:Set(true)   -- liga o toggle
    -- tog1:SetLabel("Super Speed")
end

return FleeUI
