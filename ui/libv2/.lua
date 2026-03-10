-- ModuleScript: FleeMenuLib
-- Uso: local FleeMenuLib = require(path.to.FleeMenuLib)
-- local menu = FleeMenuLib:CreateMenu({ Title = "Meu Menu", OpenButtonImage = "rbxassetid://<IMAGE_ID_HERE>" })

local FleeMenuLib = {}
FleeMenuLib.__index = FleeMenuLib

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local function newId()
	-- cria ID simples único
	return HttpService:GenerateGUID(false)
end

-- Utility small helpers
local function setProps(inst, props)
	for k,v in pairs(props or {}) do
		pcall(function() inst[k] = v end)
	end
end

local function makeRoundFrame(parent, size, pos, anchor)
	local f = Instance.new("Frame")
	f.Size = size
	f.Position = pos or UDim2.new(0,0,0,0)
	if anchor then f.AnchorPoint = anchor end
	f.BackgroundColor3 = Color3.fromRGB(40,40,40)
	f.BorderSizePixel = 0
	f.Parent = parent
	return f
end

-- Create main menu GUI
function FleeMenuLib:CreateMenu(opts)
	opts = opts or {}
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local menu = {}
	setmetatable(menu, FleeMenuLib)

	menu._player = player
	menu._playerGui = playerGui
	menu._elements = {} -- id -> {inst, type, value, ...}
	menu._tabs = {} -- tabName -> tabFrame
	menu._open = true
	menu._minimized = false
	menu._counter = 0

	-- Configs
	menu.Title = opts.Title or "Menu"
	menu.OpenButtonImage = opts.OpenButtonImage or "rbxassetid://<IMAGE_ID_HERE>"
	menu.IconImage = opts.IconImage or nil

	-- Build ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = opts.ScreenGuiName or "FleeMenuAdvancedLib"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	menu._screenGui = screenGui

	-- Main frame (center-ish)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0.42,0,0.62,0)
	mainFrame.Position = UDim2.new(0.5,0,0.5,0)
	mainFrame.AnchorPoint = Vector2.new(0.5,0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	menu._mainFrame = mainFrame

	-- TopBar
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1,0,0,42)
	topBar.BackgroundColor3 = Color3.fromRGB(24,24,24)
	topBar.BorderSizePixel = 0
	topBar.Parent = mainFrame

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Name = "Title"
	titleLbl.Size = UDim2.new(0.75,0,1,0)
	titleLbl.Position = UDim2.new(0.02,0,0,0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = menu.Title
	titleLbl.TextColor3 = Color3.new(1,1,1)
	titleLbl.TextScaled = true
	titleLbl.Font = Enum.Font.SourceSansBold
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = topBar
	menu._titleLbl = titleLbl

	-- Minimize button (inside topbar)
	local minBtn = Instance.new("TextButton")
	minBtn.Name = "Minimize"
	minBtn.Size = UDim2.new(0,38,0,30)
	minBtn.Position = UDim2.new(1,-86,0.5,-15)
	minBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
	minBtn.BorderSizePixel = 0
	minBtn.Text = "—"
	minBtn.TextColor3 = Color3.new(1,1,1)
	minBtn.Font = Enum.Font.SourceSansBold
	minBtn.TextScaled = true
	minBtn.Parent = topBar
	menu._minBtn = minBtn

	-- Close button (inside topbar)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "Close"
	closeBtn.Size = UDim2.new(0,38,0,30)
	closeBtn.Position = UDim2.new(1,-40,0.5,-15)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
	closeBtn.BorderSizePixel = 0
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.new(1,1,1)
	closeBtn.Font = Enum.Font.SourceSansBold
	closeBtn.TextScaled = true
	closeBtn.Parent = topBar
	menu._closeBtn = closeBtn

	-- Side tabs area (left)
	local tabsFrame = Instance.new("Frame")
	tabsFrame.Name = "Tabs"
	tabsFrame.Size = UDim2.new(0.22,0,1,-50)
	tabsFrame.Position = UDim2.new(0,0,0,42)
	tabsFrame.BackgroundTransparency = 1
	tabsFrame.Parent = mainFrame
	menu._tabsFrame = tabsFrame

	local tabsLayout = Instance.new("UIListLayout")
	tabsLayout.FillDirection = Enum.FillDirection.Vertical
	tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabsLayout.Padding = UDim.new(0,6)
	tabsLayout.Parent = tabsFrame

	-- Content area (right)
	local contentArea = Instance.new("Frame")
	contentArea.Name = "Content"
	contentArea.Size = UDim2.new(0.78,0,1,-50)
	contentArea.Position = UDim2.new(0.22,0,0,42)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = mainFrame
	menu._contentArea = contentArea

	-- Basic function: addTab
	function menu:AddTab(name)
		if self._tabs[name] then return self._tabs[name].id end

		-- tab button
		local tabBtn = Instance.new("ImageButton")
		tabBtn.Name = "TabBtn_"..name
		tabBtn.Size = UDim2.new(1, -10, 0, 60)
		tabBtn.Position = UDim2.new(0,5,0,0)
		tabBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
		tabBtn.BorderSizePixel = 0
		tabBtn.Parent = tabsFrame

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1,0,1,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = name
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.TextScaled = true
		lbl.Font = Enum.Font.SourceSansBold
		lbl.Parent = tabBtn

		-- Create scrolling content for this tab (but not visible until selected)
		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = "Scroll_"..name
		scroll.Size = UDim2.new(1, -10, 1, -10)
		scroll.Position = UDim2.new(0,5,0,5)
		scroll.BackgroundTransparency = 1
		scroll.ScrollBarThickness = 6
		scroll.Visible = false
		scroll.Parent = contentArea
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.CanvasSize = UDim2.new(0,0,0,0)

		local list = Instance.new("UIListLayout")
		list.Padding = UDim.new(0,6)
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Parent = scroll

		list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scroll.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y + 10)
		end)

		local tabInfo = { id = newId(), name = name, btn = tabBtn, scroll = scroll, layout = list }
		self._tabs[name] = tabInfo

		-- Select tab on click
		tabBtn.MouseButton1Click:Connect(function()
			self:SelectTab(name)
		end)

		-- If first tab, select
		if not self._selectedTab then
			self:SelectTab(name)
		end

		return tabInfo.id
	end

	function menu:SelectTab(name)
		if not self._tabs[name] then return end
		-- hide all
		for k,v in pairs(self._tabs) do
			v.scroll.Visible = false
		end
		self._tabs[name].scroll.Visible = true
		self._selectedTab = name
	end

	-- internal helper to register element
	function menu:_registerElement(inst, typ, metadata)
		local id = newId()
		self._elements[id] = {
			inst = inst,
			type = typ,
			meta = metadata or {},
			value = metadata and metadata.default or nil,
		}
		return id
	end

	-- Create generic Entry container used by all widgets
	local function createEntry(parent)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1,0,0,48)
		frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
		frame.BorderSizePixel = 0
		frame.Parent = parent
		return frame
	end

	-- Add Button
	function menu:AddButton(tabName, text, callback)
		local tab = self._tabs[tabName]
		if not tab then tab = self:AddTab(tabName) tab = self._tabs[tabName] end

		local fr = createEntry(tab.scroll)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.75, -10,1,0)
		lbl.Position = UDim2.new(0,10,0,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text or "Button"
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.TextScaled = true
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = fr

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.24, -10, 0.8, 0)
		btn.Position = UDim2.new(0.76, -10, 0.1, 0)
		btn.BackgroundColor3 = Color3.fromRGB(90,90,90)
		btn.BorderSizePixel = 0
		btn.Text = "Click"
		btn.Font = Enum.Font.SourceSansBold
		btn.TextScaled = true
		btn.Parent = fr

		local id = self:_registerElement(fr, "button", {tab=tabName, text=text})
		self._elements[id].button = btn
		btn.MouseButton1Click:Connect(function()
			if callback then
				pcall(callback, id)
			end
		end)
		return id
	end

	-- Add Toggle (IOS style)
	function menu:AddToggle(tabName, text, default, callback)
		local tab = self._tabs[tabName]
		if not tab then tab = self:AddTab(tabName) tab = self._tabs[tabName] end

		local fr = createEntry(tab.scroll)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.6, -10,1,0)
		lbl.Position = UDim2.new(0,10,0,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text or "Toggle"
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.TextScaled = true
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = fr

		-- container for toggle visual
		local holder = Instance.new("Frame")
		holder.Size = UDim2.new(0.35, -10,0.7,0)
		holder.Position = UDim2.new(0.62, 0, 0.15, 0)
		holder.BackgroundTransparency = 1
		holder.Parent = fr

		local offLabel = Instance.new("TextLabel")
		offLabel.Size = UDim2.new(0.5,0,1,0)
		offLabel.Position = UDim2.new(0,0,0,0)
		offLabel.BackgroundTransparency = 1
		offLabel.Text = "[0 off]"
		offLabel.TextScaled = true
		offLabel.Font = Enum.Font.SourceSans
		offLabel.TextColor3 = Color3.new(1,1,1)
		offLabel.TextXAlignment = Enum.TextXAlignment.Right
		offLabel.Parent = holder

		local onLabel = Instance.new("TextLabel")
		onLabel.Size = UDim2.new(0.5,0,1,0)
		onLabel.Position = UDim2.new(0.5,0,0,0)
		onLabel.BackgroundTransparency = 1
		onLabel.Text = "[on 0]"
		onLabel.TextScaled = true
		onLabel.Font = Enum.Font.SourceSansBold
		onLabel.TextColor3 = Color3.new(1,1,1)
		onLabel.TextXAlignment = Enum.TextXAlignment.Left
		onLabel.Parent = holder

		local state = default and true or false
		local id = self:_registerElement(fr, "toggle", {tab=tabName, text=text, default=default})
		self._elements[id].state = state
		self._elements[id].offLabel = offLabel
		self._elements[id].onLabel = onLabel

		local function updateVisual()
			if self._elements[id].state then
				onLabel.TextTransparency = 0
				offLabel.TextTransparency = 0.7
			else
				onLabel.TextTransparency = 0.7
				offLabel.TextTransparency = 0
			end
		end
		updateVisual()

		local clickable = Instance.new("TextButton")
		clickable.Size = UDim2.new(1,0,1,0)
		clickable.BackgroundTransparency = 1
		clickable.Text = ""
		clickable.Parent = fr

		clickable.MouseButton1Click:Connect(function()
			self._elements[id].state = not self._elements[id].state
			updateVisual()
			if callback then
				pcall(callback, self._elements[id].state, id)
			end
		end)

		return id
	end

	-- Add Slider
	function menu:AddSlider(tabName, text, min, max, default, callback)
		min = min or 0
		max = max or 100
		default = default or min
		local tab = self._tabs[tabName]
		if not tab then tab = self:AddTab(tabName) tab = self._tabs[tabName] end

		local fr = createEntry(tab.scroll)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.45, -10,1,0)
		lbl.Position = UDim2.new(0,10,0,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text or "Slider"
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.TextScaled = true
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = fr

		local valLbl = Instance.new("TextLabel")
		valLbl.Size = UDim2.new(0.18, -10,1,0)
		valLbl.Position = UDim2.new(0.64, 0,0,0)
		valLbl.BackgroundTransparency = 1
		valLbl.Text = tostring(default)
		valLbl.TextColor3 = Color3.new(1,1,1)
		valLbl.TextScaled = true
		valLbl.Parent = fr

		local barBg = Instance.new("Frame")
		barBg.Size = UDim2.new(0.95, -10,0,10)
		barBg.Position = UDim2.new(0,10,0.55,0)
		barBg.AnchorPoint = Vector2.new(0,0)
		barBg.BackgroundColor3 = Color3.fromRGB(80,80,80)
		barBg.BorderSizePixel = 0
		barBg.Parent = fr

		local barFill = Instance.new("Frame")
		barFill.Size = UDim2.new( (default-min)/(max-min), 0, 1, 0)
		barFill.BackgroundColor3 = Color3.fromRGB(130,130,130)
		barFill.BorderSizePixel = 0
		barFill.Parent = barBg

		local dragging = false
		local id = self:_registerElement(fr, "slider", {tab=tabName, text=text, min=min, max=max})
		self._elements[id].min = min
		self._elements[id].max = max
		self._elements[id].value = default
		self._elements[id].fill = barFill
		self._elements[id].valLbl = valLbl

		barBg.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				local function move(input2)
					local absPos = input2.Position.X - barBg.AbsolutePosition.X
					local pct = math.clamp(absPos / barBg.AbsoluteSize.X, 0, 1)
					local value = min + (max - min) * pct
					value = math.floor(value) -- integer slider (change if want decimal)
					self._elements[id].value = value
					barFill.Size = UDim2.new(pct,0,1,0)
					valLbl.Text = tostring(value)
					if callback then pcall(callback, value, id) end
				end
				local conn; conn = game:GetService("UserInputService").InputChanged:Connect(function(i)
					if dragging and i.UserInputType ~= Enum.UserInputType.MouseMovement then
						-- for touch events, InputChanged may not be MouseMovement; still rely on AbsolutePosition via i.Position if available
					end
					if dragging then
						local pt = i.Position or i
						move(i)
					end
				end)
				local upConn; upConn = game:GetService("UserInputService").InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
						dragging = false
						conn:Disconnect()
						upConn:Disconnect()
					end
				end)
			end
		end)

		return id
	end

	-- Add Dropdown
	function menu:AddDropdown(tabName, text, options, defaultIndex, callback)
		local tab = self._tabs[tabName]
		if not tab then tab = self:AddTab(tabName) tab = self._tabs[tabName] end
		options = options or {}
		defaultIndex = defaultIndex or 1

		local fr = createEntry(tab.scroll)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.45, -10,1,0)
		lbl.Position = UDim2.new(0,10,0,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text or "Dropdown"
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.TextScaled = true
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = fr

		local ddBtn = Instance.new("TextButton")
		ddBtn.Size = UDim2.new(0.45, -10,0.9,0)
		ddBtn.Position = UDim2.new(0.5, 0, 0.05, 0)
		ddBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
		ddBtn.BorderSizePixel = 0
		ddBtn.Text = options[defaultIndex] or "Select"
		ddBtn.TextColor3 = Color3.new(1,1,1)
		ddBtn.TextScaled = true
		ddBtn.Parent = fr

		-- popup list (Frame)
		local popup = Instance.new("Frame")
		popup.Size = UDim2.new(0.45, -10,0,0)
		popup.Position = UDim2.new(0.5,0,1,4)
		popup.BackgroundColor3 = Color3.fromRGB(60,60,60)
		popup.BorderSizePixel = 0
		popup.Visible = false
		popup.Parent = fr

		local popupList = Instance.new("UIListLayout")
		popupList.Parent = popup
		popupList.SortOrder = Enum.SortOrder.LayoutOrder

		local ddId = self:_registerElement(fr, "dropdown", {tab=tabName, text=text, options=options})
		self._elements[ddId].options = options
		self._elements[ddId].selectedIndex = defaultIndex
		self._elements[ddId].button = ddBtn
		self._elements[ddId].popup = popup

		local function rebuildPopup()
			for _,c in pairs(popup:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
			local height = 0
			for i,opt in ipairs(self._elements[ddId].options) do
				local b = Instance.new("TextButton")
				b.Size = UDim2.new(1,0,0,36)
				b.BackgroundTransparency = 0
				b.BackgroundColor3 = Color3.fromRGB(80,80,80)
				b.BorderSizePixel = 0
				b.Text = opt
				b.TextColor3 = Color3.new(1,1,1)
				b.TextScaled = true
				b.Parent = popup
				height = height + 36
				b.MouseButton1Click:Connect(function()
					self._elements[ddId].selectedIndex = i
					ddBtn.Text = opt
					popup.Visible = false
					if callback then pcall(callback, opt, i, ddId) end
				end)
			end
			popup.Size = UDim2.new(popup.Size.X.Scale, popup.Size.X.Offset, 0, height)
		end
		rebuildPopup()

		ddBtn.MouseButton1Click:Connect(function()
			popup.Visible = not popup.Visible
		end)

		return ddId
	end

	-- Add TextBox
	function menu:AddTextBox(tabName, text, default, callback)
		local tab = self._tabs[tabName]
		if not tab then tab = self:AddTab(tabName) tab = self._tabs[tabName] end

		local fr = createEntry(tab.scroll)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.32, -10,1,0)
		lbl.Position = UDim2.new(0,10,0,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text or "Text"
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.TextScaled = true
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = fr

		local tb = Instance.new("TextBox")
		tb.Size = UDim2.new(0.64, -10,0.8,0)
		tb.Position = UDim2.new(0.34, 0, 0.1, 0)
		tb.BackgroundColor3 = Color3.fromRGB(80,80,80)
		tb.Text = default or ""
		tb.ClearTextOnFocus = false
		tb.TextColor3 = Color3.new(1,1,1)
		tb.Font = Enum.Font.SourceSans
		tb.TextScaled = true
		tb.Parent = fr

		local id = self:_registerElement(fr, "textbox", {tab=tabName, text=text, default=default})
		self._elements[id].textbox = tb

		tb.FocusLost:Connect(function(enterPressed)
			if callback then pcall(callback, tb.Text, id) end
		end)

		return id
	end

	-- Add Checkbox (small)
	function menu:AddCheckbox(tabName, text, default, callback)
		local tab = self._tabs[tabName]
		if not tab then tab = self:AddTab(tabName) tab = self._tabs[tabName] end

		local fr = createEntry(tab.scroll)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.72, -10,1,0)
		lbl.Position = UDim2.new(0,10,0,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text or "Check"
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.TextScaled = true
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = fr

		local box = Instance.new("TextButton")
		box.Size = UDim2.new(0.15, -10,0.7,0)
		box.Position = UDim2.new(0.82, 0, 0.15, 0)
		box.BackgroundColor3 = default and Color3.fromRGB(120,200,120) or Color3.fromRGB(100,100,100)
		box.BorderSizePixel = 0
		box.Text = default and "✓" or ""
		box.TextScaled = true
		box.Parent = fr

		local id = self:_registerElement(fr, "checkbox", {tab=tabName, text=text, default=default})
		self._elements[id].checked = default and true or false
		self._elements[id].box = box

		box.MouseButton1Click:Connect(function()
			self._elements[id].checked = not self._elements[id].checked
			box.BackgroundColor3 = self._elements[id].checked and Color3.fromRGB(120,200,120) or Color3.fromRGB(100,100,100)
			box.Text = self._elements[id].checked and "✓" or ""
			if callback then pcall(callback, self._elements[id].checked, id) end
		end)

		return id
	end

    -- Value getters/setters
	function menu:GetValue(id)
		local e = self._elements[id]
		if not e then return nil end
		if e.type == "toggle" then return e.state end
		if e.type == "slider" then return e.value end
		if e.type == "dropdown" then return e.options and e.options[e.selectedIndex] or nil end
		if e.type == "textbox" then return e.textbox and e.textbox.Text or nil end
		if e.type == "checkbox" then return e.checked end
		if e.type == "button" then return nil end
		return e.value
	end

	function menu:SetValue(id, val)
		local e = self._elements[id]
		if not e then return false end
		if e.type == "toggle" then
			e.state = not not val
			if e.onLabel and e.offLabel then
				e.onLabel.TextTransparency = e.state and 0 or 0.7
				e.offLabel.TextTransparency = e.state and 0.7 or 0
			end
			return true
		end
		if e.type == "slider" then
			e.value = math.clamp(math.floor(val), e.min, e.max)
			local pct = (e.value - e.min) / (e.max - e.min)
			if e.fill then e.fill.Size = UDim2.new(pct,0,1,0) end
			if e.valLbl then e.valLbl.Text = tostring(e.value) end
			return true
		end
		if e.type == "dropdown" then
			for i,opt in ipairs(e.options) do
				if opt == val then
					e.selectedIndex = i
					if e.button then e.button.Text = val end
					return true
				end
			end
			return false
		end
		if e.type == "textbox" then
			if e.textbox then e.textbox.Text = tostring(val) end
			return true
		end
		if e.type == "checkbox" then
			e.checked = not not val
			if e.box then
				e.box.BackgroundColor3 = e.checked and Color3.fromRGB(120,200,120) or Color3.fromRGB(100,100,100)
				e.box.Text = e.checked and "✓" or ""
			end
			return true
		end
		return false
	end

	function menu:SetEnabled(id, enabled)
		local e = self._elements[id]
		if not e then return false end
		if e.inst then
			e.inst.Visible = enabled and true or false
			return true
		end
		return false
	end

	function menu:DestroyElement(id)
		local e = self._elements[id]
		if not e then return false end
		if e.inst then
			pcall(function() e.inst:Destroy() end)
		end
		self._elements[id] = nil
		return true
	end

	-- Minimize / Restore handling
	local function doMinimize()
		if menu._minimized then
			-- restore
			mainFrame.Size = UDim2.new(0.42,0,0.62,0)
			menu._minimized = false
		else
			mainFrame.Size = UDim2.new(0.42,0,0,42) -- only top bar visible
			menu._minimized = true
		end
	end

	minBtn.MouseButton1Click:Connect(function()
		doMinimize()
	end)

	closeBtn.MouseButton1Click:Connect(function()
		mainFrame.Visible = false
		menu._open = false
	end)

	-- External floating open/close button (fixed)
	local floatBtn = Instance.new("ImageButton")
	floatBtn.Name = "FloatOpen"
	floatBtn.Size = UDim2.new(0,60,0,60)
	floatBtn.Position = UDim2.new(1,-70,0.6,0)
	floatBtn.AnchorPoint = Vector2.new(0,0.5)
	floatBtn.BackgroundColor3 = Color3.fromRGB(55,55,55)
	floatBtn.BorderSizePixel = 0
	floatBtn.Image = menu.OpenButtonImage
	floatBtn.Parent = screenGui
	menu._floatBtn = floatBtn

	floatBtn.MouseButton1Click:Connect(function()
		if mainFrame.Visible then
			mainFrame.Visible = false
			menu._open = false
		else
			mainFrame.Visible = true
			menu._open = true
		end
	end)

	-- API: SetTitle / SetOpenImage
	function menu:SetTitle(txt)
		self.Title = tostring(txt)
		self._titleLbl.Text = self.Title
	end
	function menu:SetOpenButtonImage(image)
		self.OpenButtonImage = image
		self._floatBtn.Image = image
	end

	-- final: return menu
	return menu
end

return FleeMenuLib
