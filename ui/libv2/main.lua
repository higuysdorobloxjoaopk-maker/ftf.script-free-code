--// =========================
--// CONFIGURAÇÃO DA LIB
--// =========================

local UILib = {}

UILib.Images = {
    OpenButton = "rbxassetid://0", -- botão abrir (trocar depois)
    MinimizeButton = "rbxassetid://0"
}

UILib.Objects = {}

--// =========================
--// SERVIÇOS
--// =========================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "UILibrary"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

--// =========================
--// BOTÃO FIXO DE ABRIR
--// =========================

local openBtn = Instance.new("ImageButton")
openBtn.Size = UDim2.new(0,60,0,60)
openBtn.Position = UDim2.new(1,-80,0.5,-30)
openBtn.Image = UILib.Images.OpenButton
openBtn.BackgroundTransparency = 1
openBtn.Parent = gui

--// =========================
--// JANELA PRINCIPAL
--// =========================

local main = Instance.new("Frame")
main.Size = UDim2.new(0.4,0,0.55,0)
main.Position = UDim2.new(0.5,0,0.5,0)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Color3.fromRGB(35,35,35)
main.Visible = false
main.Parent = gui

-- Top bar
local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,40)
top.BackgroundColor3 = Color3.fromRGB(20,20,20)
top.Parent = main

-- Botão minimizar
local minimize = Instance.new("ImageButton")
minimize.Size = UDim2.new(0,35,0,35)
minimize.Position = UDim2.new(1,-40,0.5,-17)
minimize.Image = UILib.Images.MinimizeButton
minimize.BackgroundTransparency = 1
minimize.Parent = top

--// =========================
--// ÁREA DE ABAS
--// =========================

local tabButtons = Instance.new("Frame")
tabButtons.Size = UDim2.new(1,0,0,40)
tabButtons.Position = UDim2.new(0,0,0,40)
tabButtons.BackgroundTransparency = 1
tabButtons.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Parent = tabButtons

--// =========================
--// CONTEÚDO DAS ABAS
--// =========================

local pages = Instance.new("Frame")
pages.Size = UDim2.new(1,0,1,-80)
pages.Position = UDim2.new(0,0,0,80)
pages.BackgroundTransparency = 1
pages.Parent = main

--// =========================
--// FUNÇÃO CRIAR ABA
--// =========================

function UILib:CreateTab(name)

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0,120,1,0)
    tabBtn.Text = name
    tabBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    tabBtn.TextColor3 = Color3.new(1,1,1)
    tabBtn.Parent = tabButtons

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 6
    page.Visible = false
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Parent = pages

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0,6)
    list.Parent = page

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y + 50)
    end)

    tabBtn.MouseButton1Click:Connect(function()

        for _,v in pairs(pages:GetChildren()) do
            if v:IsA("ScrollingFrame") then
                v.Visible = false
            end
        end

        page.Visible = true
    end)

    local Tab = {}

--// =========================
--// TOGGLE IOS
--// =========================

function Tab:Toggle(id,text,default,callback)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-10,0,40)
    frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    frame.Parent = page

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,80,0,30)
    btn.Position = UDim2.new(1,-90,0.5,-15)
    btn.Parent = frame

    local state = default or false

    local function update()

        if state then
            btn.Text = "[ON 0]"
            btn.BackgroundColor3 = Color3.fromRGB(0,200,0)
        else
            btn.Text = "[0 OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(200,0,0)
        end

        if callback then
            callback(state)
        end

    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        update()
    end)

    update()

    UILib.Objects[id] = {
        Set = function(v)
            state = v
            update()
        end
    }

end

--// =========================
--// BOTÃO
--// =========================

function Tab:Button(id,text,callback)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,40)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = page

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    UILib.Objects[id] = btn

end

--// =========================
--// TEXTBOX
--// =========================

function Tab:Textbox(id,text,callback)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-10,0,40)
    box.PlaceholderText = text
    box.BackgroundColor3 = Color3.fromRGB(60,60,60)
    box.TextColor3 = Color3.new(1,1,1)
    box.Parent = page

    box.FocusLost:Connect(function()
        if callback then callback(box.Text) end
    end)

    UILib.Objects[id] = box

end

--// =========================
--// CHECKBOX
--// =========================

function Tab:Checkbox(id,text,callback)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,40)
    btn.Text = "[ ] "..text
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = page

    local state = false

    btn.MouseButton1Click:Connect(function()

        state = not state

        if state then
            btn.Text = "[X] "..text
        else
            btn.Text = "[ ] "..text
        end

        if callback then callback(state) end

    end)

    UILib.Objects[id] = btn

end

--// =========================
--// DROPDOWN
--// =========================

function Tab:Dropdown(id,text,list,callback)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,40)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = page

    btn.MouseButton1Click:Connect(function()

        local choice = list[math.random(1,#list)]
        btn.Text = choice

        if callback then
            callback(choice)
        end

    end)

end

--// =========================
--// SLIDER
--// =========================

function Tab:Slider(id,text,min,max,callback)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-10,0,40)
    frame.BackgroundColor3 = Color3.fromRGB(60,60,60)
    frame.Parent = page

    local value = min

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text.." : "..value
    label.TextColor3 = Color3.new(1,1,1)
    label.Parent = frame

    frame.InputBegan:Connect(function()

        value = math.random(min,max)
        label.Text = text.." : "..value

        if callback then
            callback(value)
        end

    end)

end

return UILib
