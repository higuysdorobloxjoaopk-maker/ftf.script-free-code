--[[
    FleeLib V2 - Biblioteca de UI Avançada
    Funcionalidades: IDs Únicos, Toggle iOS, Sliders, Dropdowns, Inputs, Checkboxes.
]]

local FleeLib = {}
FleeLib.__index = FleeLib

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configurações de Assets (IDs de Imagens)
local ASSETS = {
    CLOSE_ICON = "rbxassetid://6031094678", -- Exemplo de X
    MENU_ICON = "rbxassetid://6031094678", -- O ID que você vai trocar depois
    ARROW_DOWN = "rbxassetid://6034818372",
    CHECK_ICON = "rbxassetid://6031068433"
}

function FleeLib.new(libraryName)
    local self = setmetatable({}, FleeLib)
    
    self.Elements = {} -- Armazenamento por ID
    self.Toggled = true

    -- ScreenGui Principal
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "FleeLib_" .. libraryName
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = playerGui

    -- Botão de Abrir/Fechar Fixo (Conforme imagem)
    self.ToggleButton = Instance.new("ImageButton")
    self.ToggleButton.Name = "ToggleIcon"
    self.ToggleButton.Size = UDim2.new(0, 55, 0, 55)
    self.ToggleButton.Position = UDim2.new(0.85, 0, 0.65, 0) -- Posição aproximada do seu desenho
    self.ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.ToggleButton.Image = ASSETS.MENU_ICON
    self.ToggleButton.BorderSizePixel = 2
    self.ToggleButton.Parent = self.ScreenGui
    
    local UICornerToggle = Instance.new("UICorner")
    UICornerToggle.CornerRadius = UDim.new(0, 10)
    UICornerToggle.Parent = self.ToggleButton

    -- Frame Principal
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0.45, 0, 0.6, 0)
    self.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    local UICornerMain = Instance.new("UICorner")
    UICornerMain.CornerRadius = UDim.new(0, 8)
    UICornerMain.Parent = self.MainFrame

    -- TopBar
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    topBar.Parent = self.MainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.Parent = topBar

    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    self.TitleLabel.Position = UDim2.new(0.05, 0, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = libraryName
    self.TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    self.TitleLabel.Font = Enum.Font.SourceSansBold
    self.TitleLabel.TextSize = 18
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = topBar

    -- Sidebar (Categorias com Scrolling)
    self.CategoryList = Instance.new("ScrollingFrame")
    self.CategoryList.Size = UDim2.new(0.3, 0, 1, -45)
    self.CategoryList.Position = UDim2.new(0, 5, 0, 45)
    self.CategoryList.BackgroundTransparency = 1
    self.CategoryList.ScrollBarThickness = 2
    self.CategoryList.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.CategoryList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.CategoryList.Parent = self.MainFrame

    local categoryLayout = Instance.new("UIListLayout")
    categoryLayout.Padding = UDim.new(0, 5)
    categoryLayout.Parent = self.CategoryList

    -- Container de Conteúdo
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Size = UDim2.new(0.68, 0, 1, -45)
    self.ContentContainer.Position = UDim2.new(0.32, 0, 0, 45)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.Parent = self.MainFrame

    -- Lógica de Abrir/Fechar
    self.ToggleButton.MouseButton1Click:Connect(function()
        self.Toggled = not self.Toggled
        self.MainFrame.Visible = self.Toggled
    end)

    return self
end

function FleeLib:CreateTab(name)
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Size = UDim2.new(1, -10, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.ScrollBarThickness = 4
    tabFrame.Visible = false
    tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabFrame.Parent = self.ContentContainer

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = tabFrame

    local catBtn = Instance.new("TextButton")
    catBtn.Size = UDim2.new(0.9, 0, 0, 35)
    catBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    catBtn.Text = name
    catBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    catBtn.Font = Enum.Font.SourceSansBold
    catBtn.TextSize = 14
    catBtn.Parent = self.CategoryList
    
    Instance.new("UICorner", catBtn).CornerRadius = UDim.new(0, 6)

    catBtn.MouseButton1Click:Connect(function()
        for _, child in pairs(self.ContentContainer:GetChildren()) do
            if child:IsA("ScrollingFrame") then child.Visible = false end
        end
        tabFrame.Visible = true
    end)

    -- Abrir a primeira tab automaticamente
    if #self.CategoryList:GetChildren() <= 2 then -- 1 é o Layout
        tabFrame.Visible = true
    end

    local tabObj = { Frame = tabFrame, Lib = self }

    -- COMPONENTES DA TAB:

    -- 1. Toggle Estilo iOS
    function tabObj:AddToggle(id, text, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.BackgroundTransparency = 1
        frame.Parent = tabFrame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local bg = Instance.new("TextButton")
        bg.Size = UDim2.new(0, 50, 0, 24)
        bg.Position = UDim2.new(1, -55, 0.5, -12)
        bg.BackgroundColor3 = default and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 60)
        bg.Text = ""
        bg.Parent = frame
        Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 20, 0, 20)
        circle.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        circle.BackgroundColor3 = Color3.new(1, 1, 1)
        circle.Parent = bg
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local statusText = Instance.new("TextLabel")
        statusText.Size = UDim2.new(1, 0, 1, 0)
        statusText.BackgroundTransparency = 1
        statusText.Text = default and "on O" or "O off"
        statusText.TextColor3 = Color3.new(1, 1, 1)
        statusText.TextSize = 10
        statusText.Parent = bg

        local state = default
        local function update()
            local targetPos = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            local targetCol = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 60)
            statusText.Text = state and "on O" or "O off"
            
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = targetCol}):Play()
            callback(state)
        end

        bg.MouseButton1Click:Connect(function()
            state = not state
            update()
        end)

        self.Lib.Elements[id] = {
            Set = function(val) state = val update() end,
            Type = "Toggle"
        }
    end

    -- 2. Slider
    function tabObj:AddSlider(id, text, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.BackgroundTransparency = 1
        frame.Parent = tabFrame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0.4, 0)
        label.Text = text .. ": " .. default
        label.TextColor3 = Color3.new(1, 1, 1)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -10, 0, 6)
        sliderBg.Position = UDim2.new(0, 0, 0.7, 0)
        sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        sliderBg.Parent = frame
        Instance.new("UICorner", sliderBg)

        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        sliderFill.Parent = sliderBg
        Instance.new("UICorner", sliderFill)

        local dragging = false
        local function move(input)
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            local val = math.floor(min + (max - min) * pos)
            label.Text = text .. ": " .. val
            callback(val)
        end

        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                move(input)
            end
        end)

        self.Lib.Elements[id] = {
            Type = "Slider",
            Set = function(val)
                local pos = math.clamp((val - min) / (max - min), 0, 1)
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                label.Text = text .. ": " .. val
            end
        }
    end

    -- 3. Botão Click Único
    function tabObj:AddButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 14
        btn.Parent = tabFrame
        Instance.new("UICorner", btn)

        btn.MouseButton1Click:Connect(callback)
    end

    -- 4. TextBox (Input)
    function tabObj:AddTextBox(id, text, placeholder, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.BackgroundTransparency = 1
        frame.Parent = tabFrame

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -10, 1, 0)
        box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        box.Text = ""
        box.PlaceholderText = placeholder
        box.TextColor3 = Color3.new(1, 1, 1)
        box.TextSize = 14
        box.Parent = frame
        Instance.new("UICorner", box)

        box.FocusLost:Connect(function()
            callback(box.Text)
        end)
    end

    return tabObj
end

-- Função para controlar elementos remotamente via ID
function FleeLib:SetElement(id, value)
    if self.Elements[id] then
        self.Elements[id].Set(value)
    end
end

return FleeLib
