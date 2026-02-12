--[[
    Made by mrfridgebeater
]]

local players = game:GetService('Players')
local runService = game:GetService('RunService')
local textService = game:GetService('TextService')
local httpService = game:GetService('HttpService')
local tweenService = game:GetService('TweenService')
local userInputService = game:GetService('UserInputService')
local lighting = game:GetService('Lighting')

local localEntity = players.LocalPlayer

if localEntity.PlayerGui:FindFirstChild('ScreenGuiHS') then
	localEntity.PlayerGui.ScreenGuiHS:Destroy()
end
if lighting:FindFirstChild('GuiBlur') then
	lighting.GuiBlur:Destroy()
end

local screenGui = Instance.new('ScreenGui')
screenGui.Name = 'ScreenGuiHS'
screenGui.Parent = localEntity.PlayerGui
screenGui.ResetOnSpawn = false
local clickGui = Instance.new('Frame')
clickGui.Parent = screenGui
clickGui.Size = UDim2.fromScale(1, 1)
clickGui.BackgroundTransparency = 1
local blur = Instance.new('BlurEffect')
blur.Name = 'GuiBlur'
blur.Size = 20
blur.Parent = lighting
local arrayList = Instance.new('Frame')
arrayList.Parent = screenGui
arrayList.Position = UDim2.new(1, -10, 0, -40) 
arrayList.Size = UDim2.new(0, 200, 1, 0)
arrayList.AnchorPoint = Vector2.new(1, 0)
arrayList.BackgroundTransparency = 1
arrayList.Visible = false

local mobileToggleButton = Instance.new('TextButton')
mobileToggleButton.Name = 'MobileToggle'
mobileToggleButton.Parent = screenGui
mobileToggleButton.Size = UDim2.fromOffset(100, 42)
mobileToggleButton.Position = UDim2.new(0, 25, 0, 0)
mobileToggleButton.BackgroundColor3 = Color3.fromRGB(15,15,15)
mobileToggleButton.Text = ""
mobileToggleButton.AutoButtonColor = false
mobileToggleButton.Visible = userInputService.TouchEnabled

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = mobileToggleButton

local textLabel = Instance.new("TextLabel")
textLabel.Name = "GradientText"
textLabel.Parent = mobileToggleButton
textLabel.Size = UDim2.fromScale(1, 1)
textLabel.BackgroundTransparency = 1
textLabel.Text = "HAZE"
textLabel.Font = Enum.Font.BuilderSansExtraBold
textLabel.TextSize = 24
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

local textGradient = Instance.new("UIGradient")
textGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(66, 245, 108)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(66, 245, 108))
})
textGradient.Rotation = 0
textGradient.Parent = textLabel

local textStroke = Instance.new("UIStroke")
textStroke.Thickness = 1
textStroke.Color = Color3.fromRGB(66, 245, 108)
textStroke.Transparency = 0.8
textStroke.Parent = textLabel

task.spawn(function()
	while true do
		textGradient.Offset = Vector2.new(-1, 0)
		local tween = tweenService:Create(textGradient, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
			Offset = Vector2.new(1, 0)
		})
		tween:Play()
		tween.Completed:Wait()

		task.wait(0.5)
	end
end)

mobileToggleButton.MouseButton1Click:Connect(function()
	local shrink = tweenService:Create(mobileToggleButton, TweenInfo.new(0.1), {Size = UDim2.fromOffset(95, 38)})
	shrink:Play()
	shrink.Completed:Wait()
	tweenService:Create(mobileToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {Size = UDim2.fromOffset(100, 42)}):Play()
	clickGui.Visible = not clickGui.Visible
	local targetBlur = clickGui.Visible and 20 or 0
	tweenService:Create(blur, TweenInfo.new(0.3), {Size = targetBlur}):Play()
end)

local dragging, dragInput, dragStart, startPos

mobileToggleButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mobileToggleButton.Position
	end
end)

userInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mobileToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

userInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

local arraylistSort = Instance.new('UIListLayout')
arraylistSort.Parent = arrayList
arraylistSort.SortOrder = Enum.SortOrder.LayoutOrder
arraylistSort.HorizontalAlignment = Enum.HorizontalAlignment.Right
arraylistSort.Padding = UDim.new(0, 2)

local logoFrame = Instance.new('Frame')
logoFrame.Parent = arrayList
logoFrame.Size = UDim2.new(1, 0, 0, 60)
logoFrame.BackgroundTransparency = 1
logoFrame.LayoutOrder = -1

local logoText = Instance.new('TextLabel')
logoText.Parent = logoFrame
logoText.Size = UDim2.fromScale(1, 1)
logoText.Position = UDim2.fromOffset(-10, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "HAZE"
logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
logoText.TextSize = 45
logoText.Font = Enum.Font.BuilderSansExtraBold
logoText.TextXAlignment = Enum.TextXAlignment.Right
logoText.RichText = true

local uiStroke = Instance.new("UIStroke")
uiStroke.Parent = logoText
uiStroke.Thickness = 2
uiStroke.Transparency = 0.8
uiStroke.Color = Color3.fromRGB(0, 0, 0)

local uiScale = Instance.new('UIScale')
uiScale.Parent = screenGui
uiScale.Scale = math.clamp(screenGui.AbsoluteSize.X / 1920, 0.8, 1.2)

local function updateScale()
	uiScale.Scale = math.clamp(screenGui.AbsoluteSize.X / 1920, 0.5, 1.2)
end
screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScale)
updateScale()

if not runService:IsStudio() then
	local folders = {'Haze', 'Haze/configs', 'Haze/libraries'}

	for i,v in folders do
		if not isfolder(v) then
			makefolder(v)
		end
	end

	if not isfile('Haze/config.txt') then
		writefile('Haze/config.txt', 'Default')
	end
end

local guiLibrary = {
	Info = {
		Name = 'Haze',
		Ver = 'BETA',
	},
	Pallete = {
		Main = Color3.fromRGB(66, 245, 108),
		Changed = Instance.new('BindableEvent'),
	},
	Collection = {},
	Windows = {},
	Config = {},
	CfgName = readfile and readfile('Haze/config.txt') or 'Default',
}

table.insert(guiLibrary.Collection, userInputService.InputBegan:Connect(function(Input: InputObject)
	if not userInputService:GetFocusedTextBox() and Input.KeyCode == Enum.KeyCode.RightShift then
		clickGui.Visible = not clickGui.Visible
		local targetBlur = clickGui.Visible and 20 or 0
		tweenService:Create(blur, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetBlur}):Play()
	end
end))

local aids = {}
function addToArray(Name: string, ExtraText)
	local Obj = Instance.new('Frame')
	Obj.Name = Name
	Obj.Parent = arrayList
	Obj.BorderSizePixel = 0
	Obj.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Obj.BackgroundTransparency = (ArrayBackground and ArrayBackground.value / 100 or 0.5)
	Obj.Size = UDim2.new(0, 0, 0, 28)
	Obj.ClipsDescendants = false

	local SideLine = Instance.new('Frame')
	SideLine.Parent = Obj
	SideLine.Position = UDim2.fromScale(1, 0)
	SideLine.AnchorPoint = Vector2.new(1, 0)
	SideLine.Size = UDim2.new(0, 3, 1, 0)
	SideLine.BorderSizePixel = 0
	SideLine.BackgroundColor3 = guiLibrary.Pallete.Main

	local ModuleText = Instance.new('TextLabel')
	ModuleText.Parent = Obj
	ModuleText.Size = UDim2.new(1, -10, 1, 0)
	ModuleText.Position = UDim2.fromScale(0, 0)
	ModuleText.BackgroundTransparency = 1
	ModuleText.TextColor3 = Color3.fromRGB(255, 255, 255)
	ModuleText.TextSize = 17
	ModuleText.Font = Enum.Font.BuilderSans
	ModuleText.TextXAlignment = Enum.TextXAlignment.Right
	ModuleText.RichText = true

	local aider = guiLibrary.Pallete.Changed.Event:Connect(function()
		SideLine.BackgroundColor3 = guiLibrary.Pallete.changeColor(guiLibrary.Pallete.Main, 0.7)
	end)

	task.spawn(function()
		repeat
			task.wait()
			local textContent = Name
			local pureText = Name
			if ExtraText and typeof(ExtraText()) == 'string' then
				textContent = Name .. ' <font color="rgb(180,180,180)">' .. ExtraText() .. '</font>'
				pureText = Name .. " " .. ExtraText()
			end

			ModuleText.Text = textContent
			local textSize = textService:GetTextSize(pureText, ModuleText.TextSize, ModuleText.Font, Vector2.new(1000, 1000))
			tweenService:Create(Obj, TweenInfo.new(0.2), {Size = UDim2.fromOffset(textSize.X + 18, 28)}):Play()
		until Obj == nil or Obj:GetAttribute('Destroying')
	end)

	Obj.Destroying:Once(function() aider:Disconnect() end)
	table.insert(aids, Obj)
	table.sort(aids, function(a, b)
		return a.Size.X.Offset > b.Size.X.Offset
	end)

	for i, v in ipairs(aids) do v.LayoutOrder = i end
end

local function removeFromArray(Name: string)
	for i,v in aids do
		if v.Name == Name then
			table.remove(aids, i)
			tweenService:Create(v, TweenInfo.new(0.15), {
				Transparency = 1
				--Size = UDim2.fromOffset(0, 30)
			}):Play()
			v:SetAttribute('Destroying', true)

			task.delay(0.1, function()
				tweenService:Create(v.Frame, TweenInfo.new(0.05), {Transparency = 1}):Play()
			end)

			task.delay(0.15, function()
				v:Destroy()
			end)
		end
	end
end

function guiLibrary.saveCFG(Name: string)
	if runService:IsStudio() then return end

	writefile('Haze/configs/'..game.PlaceId..'.json', httpService:JSONEncode(guiLibrary.Config))
end

function guiLibrary.loadCFG(Name: string)
	if runService:IsStudio() then return end

	if isfile('Haze/configs/'..game.PlaceId..'.json') then
		guiLibrary.Config = httpService:JSONDecode(readfile('Haze/configs/'..game.PlaceId..'.json'))
	end
end

function guiLibrary.Pallete.changeColor(Color: Color3, Decided: number)
	assert(typeof(Color) == 'Color3', 'Color sent is not valid Color3 Value.')
	assert(typeof(Decided) == 'number', 'Change value is not number.')

	local R = math.round(Color.R * 255) * Decided
	local G = math.round(Color.G * 255) * Decided
	local B = math.round(Color.B * 255) * Decided

	return Color3.fromRGB(R, G, B)
end

local aidedFrame = 0
function guiLibrary:getWindow(Name: string)
	assert(typeof(Name) == 'string', 'Name variable is not string')

	return self.Windows[Name] or {}
end
local function makeDraggable(topbarobject, object, name)
	local dragging = false
	local dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		local targetPos = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X, 
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
		tweenService:Create(object, TweenInfo.new(0.05), {Position = targetPos}):Play()
	end

	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false

					if not guiLibrary.Config.WindowPositions then 
						guiLibrary.Config.WindowPositions = {} 
					end

					guiLibrary.Config.WindowPositions[name] = {
						X = object.Position.X.Offset,
						Y = object.Position.Y.Offset
					}

					guiLibrary.saveCFG(guiLibrary.CfgName)
				end
			end)
		end
	end)

	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	userInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end
function guiLibrary:createWindow(Name: string)
	assert(typeof(Name) == 'string', 'Name variable is not string')

	local Frame = Instance.new('Frame')
	Frame.Parent = clickGui

	if guiLibrary.Config.WindowPositions and guiLibrary.Config.WindowPositions[Name] then
		local saved = guiLibrary.Config.WindowPositions[Name]
		Frame.Position = UDim2.fromOffset(saved.X, saved.Y)
	else
		Frame.Position = UDim2.fromOffset(75 + (aidedFrame * 190), 75)
	end

	Frame.Size = UDim2.fromOffset(185, 35)
	Frame.BorderSizePixel = 0
	Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	makeDraggable(Frame, Frame, Name)
	local Label = Instance.new('TextLabel')
	Label.Parent = Frame
	Label.Position = UDim2.fromOffset(8, 0)
	Label.Size = UDim2.fromScale(1, 1)
	Label.BackgroundTransparency = 1
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 18
	Label.Text = Name
	Label.Font = Enum.Font.BuilderSansMedium
	local Modules = Instance.new('Frame')
	Modules.Parent = Frame
	Modules.Position = UDim2.fromScale(0, 1)
	Modules.Size = UDim2.fromScale(1, 0)
	Modules.AutomaticSize = Enum.AutomaticSize.Y
	Modules.BackgroundTransparency = 1
	local collapsed = false
	Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			collapsed = not collapsed
			local easingStyle = collapsed and Enum.EasingStyle.Quart or Enum.EasingStyle.Back
			local duration = 0.3

			if collapsed then
				Modules.AutomaticSize = Enum.AutomaticSize.None
				Modules.ClipsDescendants = true

				tweenService:Create(Modules, TweenInfo.new(duration, easingStyle, Enum.EasingDirection.In), {
					Size = UDim2.new(1, 0, 0, 0)
				}):Play()

				for _, child in ipairs(Modules:GetChildren()) do
					if child:IsA("Frame") then
						tweenService:Create(child, TweenInfo.new(duration/2), {BackgroundTransparency = 1}):Play()
					end
				end

				task.delay(duration, function() 
					if collapsed then Modules.Visible = false end 
				end)
			else
				Modules.Visible = true
				Modules.Size = UDim2.new(1, 0, 0, 0)

				for _, child in ipairs(Modules:GetChildren()) do
					if child:IsA("Frame") then
						child.BackgroundTransparency = 1
						tweenService:Create(child, TweenInfo.new(duration), {BackgroundTransparency = 0}):Play()
					end
				end

				local tween = tweenService:Create(Modules, TweenInfo.new(duration, easingStyle, Enum.EasingDirection.Out), {
					Size = UDim2.new(1, 0, 0, 150)
				})
				tween:Play()

				tween.Completed:Once(function()
					if not collapsed then
						Modules.AutomaticSize = Enum.AutomaticSize.Y
					end
				end)
			end
		end
	end)
	local ModulesSort = Instance.new('UIListLayout')
	ModulesSort.Parent = Modules
	ModulesSort.SortOrder = Enum.SortOrder.LayoutOrder

	aidedFrame += 1

	self.Windows[Name] = {
		modules = {},
		createModule = function(self, Table)
			assert(typeof(Table) == 'table', 'Variable Table is not table type')
			assert(typeof(Table.Name) == 'string', 'Name variable is not string')

			if not guiLibrary.Config[Table.Name] then
				guiLibrary.Config[Table.Name] = {
					enabled = false,
					keybind = 'Unknown',
					toggles = {},
					sliders = {},
					selectors = {},
				}
			end

			local ModuleFrame = Instance.new('Frame')
			ModuleFrame.Parent = Modules
			ModuleFrame.Size = UDim2.new(1, 0, 0, 35)
			ModuleFrame.BorderSizePixel = 0
			ModuleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			local ModuleLabel = Instance.new('TextButton')
			ModuleLabel.Parent = ModuleFrame
			ModuleLabel.Position = UDim2.fromOffset(8, 0)
			ModuleLabel.Size = UDim2.fromScale(1, 1)
			ModuleLabel.BackgroundTransparency = 1
			ModuleLabel.TextXAlignment = Enum.TextXAlignment.Left
			ModuleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			ModuleLabel.TextSize = 17
			ModuleLabel.Font = Enum.Font.BuilderSans
			ModuleLabel.RichText = true
			local ModuleDots = Instance.new('ImageButton')
			ModuleDots.Parent = ModuleFrame
			ModuleDots.AnchorPoint = Vector2.new(0.5, 0.5)
			ModuleDots.Position = UDim2.fromScale(0.92, 0.5)
			ModuleDots.Size = UDim2.fromOffset(24, 25)
			ModuleDots.Image = 'rbxassetid://12974354280'
			ModuleDots.BackgroundTransparency = 1
			local ModuleSide = Instance.new('Frame')
			ModuleSide.Parent = ModuleFrame
			ModuleSide.Size = UDim2.new(0, 3, 1, 0)
			ModuleSide.BorderSizePixel = 0
			ModuleSide.BackgroundColor3 = guiLibrary.Pallete.changeColor(guiLibrary.Pallete.Main, 0.7)
			ModuleSide.BackgroundTransparency = 1
			local Dropdown = Instance.new('Frame')
			Dropdown.Parent = Modules
			Dropdown.Size = UDim2.fromScale(1, 0)
			Dropdown.AutomaticSize = Enum.AutomaticSize.Y
			Dropdown.BackgroundTransparency =1 
			Dropdown.Visible = false
			local DropdownSort = Instance.new('UIListLayout')
			DropdownSort.Parent = Dropdown
			DropdownSort.SortOrder = Enum.SortOrder.LayoutOrder
			local HideModule

			if guiLibrary.Config[Table.Name].keybind ~= 'Unknown' then
				ModuleLabel.Text = '<font color="rgb(200,200,200)">['..guiLibrary.Config[Table.Name].keybind..']</font> ' .. Table.Name
			else
				ModuleLabel.Text = Table.Name
			end

			if Table.Description then
				local Description = Instance.new('TextLabel')
				Description.Parent = screenGui
				Description.Position = UDim2.fromOffset(userInputService:GetMouseLocation().X, userInputService:GetMouseLocation().Y)
				Description.BorderSizePixel = 0
				Description.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				Description.TextColor3 = Color3.fromRGB(255,255,255)
				Description.TextSize = 13
				Description.Text = Table.Description
				Description.Font = Enum.Font.BuilderSans
				Description.Size = UDim2.new(0, textService:GetTextSize('  ' .. Table.Description .. '  ', Description.TextSize, Description.Font, Vector2.zero).X, 0, 20)
				Description.Visible = false
				Description.AnchorPoint = Vector2.new(-0.5, 0.5)

				local isHovering = false
				table.insert(guiLibrary.Collection, ModuleFrame.MouseEnter:Connect(function()
					isHovering = true
					Description.Visible = true

					repeat
						task.wait()
						local pos = UDim2.fromOffset(userInputService:GetMouseLocation().X + 10, userInputService:GetMouseLocation().Y)

						tweenService:Create(Description, TweenInfo.new(0.15), {Position = pos}):Play()
					until not isHovering
				end))
				table.insert(guiLibrary.Collection, ModuleFrame.MouseLeave:Connect(function()
					isHovering = false
					Description.Visible = false
				end))
			end

			local ModuleReturn = {enabled = false, collection = {}}
			function ModuleReturn:Clean(v1, v2)
				task.spawn(function()
					if typeof(v1) == 'function' then
						table.insert(self.collection, runService.Heartbeat:Connect(v1))
					elseif v1 and v2 and typeof(v2) == 'function' then
						table.insert(self.collection, v1:Connect(v2))
					elseif v1 then
						table.insert(self.collection, v1)
					end
				end)
			end
			function ModuleReturn:CleanTable()
				for i,v in self.collection do
					if typeof(v) == 'RBXScriptConnection' then
						v:Disconnect()
					elseif typeof(v) == 'Instance' then
						v:Destroy()
					end
					table.remove(self.collection, i)
				end
			end
			function ModuleReturn:toggle(silent: boolean)
				self.enabled = not self.enabled
				guiLibrary.Config[Table.Name].enabled = self.enabled

				tweenService:Create(ModuleSide, TweenInfo.new(0.15), {BackgroundTransparency = self.enabled and 0 or 1}):Play()
				tweenService:Create(ModuleLabel, TweenInfo.new(0.15), {TextColor3 = self.enabled and guiLibrary.Pallete.Main or Color3.fromRGB(200,200,200)}):Play()

				if not self.enabled then
					self:CleanTable()
				end

				if Table.Function then
					task.spawn(pcall, function()
						Table.Function(self.enabled)
					end)
				end

				if self.enabled then
					addToArray(Table.Name, Table.ExtraText or nil)
				else
					removeFromArray(Table.Name)
				end

				guiLibrary.saveCFG(guiLibrary.CfgName)
			end

			ModuleReturn.toggles = {}
			function ModuleReturn.toggles.new(Tab)
				if not guiLibrary.Config[Table.Name].toggles[Tab.Name] then
					guiLibrary.Config[Table.Name].toggles[Tab.Name] = {enabled = false}
				end

				local ToggleFrame = Instance.new('Frame')
				ToggleFrame.Parent = Dropdown
				ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
				ToggleFrame.BorderSizePixel = 0
				ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
				local ToggleLabel = Instance.new('TextButton')
				ToggleLabel.Parent = ToggleFrame
				ToggleLabel.Position = UDim2.fromOffset(8, 0)
				ToggleLabel.Size = UDim2.fromScale(1, 1)
				ToggleLabel.BackgroundTransparency = 1
				ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
				ToggleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
				ToggleLabel.TextSize = 16
				ToggleLabel.Text = Tab.Name
				ToggleLabel.Font = Enum.Font.BuilderSans
				local ToggleSide = Instance.new('Frame')
				ToggleSide.Parent = ToggleFrame
				ToggleSide.Size = UDim2.new(0, 3, 1, 0)
				ToggleSide.BorderSizePixel = 0
				ToggleSide.BackgroundColor3 = guiLibrary.Pallete.changeColor(guiLibrary.Pallete.Main, 0.7)

				local ToggleReturn = {enabled = false, inst = ToggleFrame}
				function ToggleReturn:toggle()
					self.enabled = not self.enabled
					guiLibrary.Config[Table.Name].toggles[Tab.Name].enabled = self.enabled

					tweenService:Create(ToggleLabel, TweenInfo.new(0.15), {TextColor3 = self.enabled and guiLibrary.Pallete.changeColor(guiLibrary.Pallete.Main, 0.7) or Color3.fromRGB(150, 150, 150)}):Play()

					if Tab.Function then
						task.spawn(pcall, function()
							Tab.Function(self.enabled)
						end)
					end

					guiLibrary.saveCFG(guiLibrary.CfgName)
				end

				table.insert(guiLibrary.Collection, ToggleLabel.MouseButton1Down:Connect(function()
					ToggleReturn:toggle()
				end))
				table.insert(guiLibrary.Collection, guiLibrary.Pallete.Changed.Event:Connect(function()
					ToggleSide.BackgroundColor3 = guiLibrary.Pallete.changeColor(guiLibrary.Pallete.Main, 0.7)

					if ToggleReturn.enabled then
						ToggleLabel.TextColor3 = guiLibrary.Pallete.Main
					end
				end))

				if guiLibrary.Config[Table.Name].toggles[Tab.Name].enabled then
					task.delay(0.1, function()
						ToggleReturn:toggle()
					end)
				end

				return ToggleReturn
			end

			ModuleReturn.selectors = {}
			function ModuleReturn.selectors.new(Tab)
				if not guiLibrary.Config[Table.Name].selectors[Tab.Name] then
					guiLibrary.Config[Table.Name].selectors[Tab.Name] = {value = Tab.Default or Tab.Selections[1] or 'nil'}
				end

				local SelectorFrame = Instance.new('Frame')
				SelectorFrame.Parent = Dropdown
				SelectorFrame.Size = UDim2.new(1, 0, 0, 30)
				SelectorFrame.BorderSizePixel = 0
				SelectorFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
				local SelectorLabel = Instance.new('TextButton')
				SelectorLabel.Parent = SelectorFrame
				SelectorLabel.Position = UDim2.fromOffset(8, 0)
				SelectorLabel.Size = UDim2.fromScale(1, 1)
				SelectorLabel.BackgroundTransparency = 1
				SelectorLabel.TextXAlignment = Enum.TextXAlignment.Left
				SelectorLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
				SelectorLabel.TextSize = 16
				SelectorLabel.Text = Tab.Name
				SelectorLabel.Font = Enum.Font.BuilderSans
				local SelectedLabel = Instance.new('TextLabel')
				SelectedLabel.Parent = SelectorFrame
				SelectedLabel.Position = UDim2.fromOffset(-8, 0)
				SelectedLabel.Size = UDim2.fromScale(1, 1)
				SelectedLabel.BackgroundTransparency = 1
				SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
				SelectedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				SelectedLabel.TextSize = 16
				SelectedLabel.Text = 'cooked'
				SelectedLabel.Font = Enum.Font.BuilderSans
				local SelectorSide = Instance.new('Frame')
				SelectorSide.Parent = SelectorFrame
				SelectorSide.Size = UDim2.new(0, 3, 1, 0)
				SelectorSide.BorderSizePixel = 0
				SelectorSide.BackgroundColor3 = guiLibrary.Pallete.changeColor(guiLibrary.Pallete.Main, 0.7)

				local SelectorReturn = {value = guiLibrary.Config[Table.Name].selectors[Tab.Name].value, inst = SelectorFrame}
				function SelectorReturn:select(Name: string)
					self.value = Name
					guiLibrary.Config[Table.Name].selectors[Tab.Name].value = self.value

					SelectedLabel.Text = self.value

					if Tab.Function then
						task.spawn(pcall, function()
							Tab.Function(self.value)
						end)
					end

					guiLibrary.saveCFG(guiLibrary.CfgName)
				end

				local Index = 1
				for i,v in Tab.Selections do
					if v == SelectorReturn.value then
						Index = i
					end
				end
				table.insert(guiLibrary.Collection, SelectorLabel.MouseButton1Down:Connect(function()
					Index += 1
					if Index > #Tab.Selections then
						Index = 1
					end

					SelectorReturn:select(Tab.Selections[Index])
				end))
				table.insert(guiLibrary.Collection, SelectorLabel.MouseButton2Down:Connect(function()
					Index -= 1
					if Index < 1 then
						Index = #Tab.Selections
					end

					SelectorReturn:select(Tab.Selections[Index])
				end))
				table.insert(guiLibrary.Collection, guiLibrary.Pallete.Changed.Event:Connect(function()
					SelectorSide.BackgroundColor3 = guiLibrary.Pallete.changeColor(guiLibrary.Pallete.Main, 0.7)
				end))

				SelectorReturn:select(SelectorReturn.value)

				return SelectorReturn
			end

			ModuleReturn.textboxes = {}
			function ModuleReturn.textboxes.new(Tab)
				if not guiLibrary.Config[Table.Name].textboxes then guiLibrary.Config[Table.Name].textboxes = {} end
				if not guiLibrary.Config[Table.Name].textboxes[Tab.Name] then
					guiLibrary.Config[Table.Name].textboxes[Tab.Name] = {value = Tab.Default or ""}
				end

				local BoxFrame = Instance.new('Frame')
				BoxFrame.Parent = Dropdown
				BoxFrame.Size = UDim2.new(1, 0, 0, 35)
				BoxFrame.BorderSizePixel = 0
				BoxFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

				local BoxLabel = Instance.new('TextLabel')
				BoxLabel.Parent = BoxFrame
				BoxLabel.Position = UDim2.fromOffset(8, 0)
				BoxLabel.Size = UDim2.new(0.4, 0, 1, 0)
				BoxLabel.BackgroundTransparency = 1
				BoxLabel.TextXAlignment = Enum.TextXAlignment.Left
				BoxLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
				BoxLabel.TextSize = 16
				BoxLabel.Text = Tab.Name
				BoxLabel.Font = Enum.Font.BuilderSans

				local TextBox = Instance.new('TextBox')
				TextBox.Parent = BoxFrame
				TextBox.Size = UDim2.new(0.5, 0, 0.7, 0)
				TextBox.Position = UDim2.fromScale(0.45, 0.15)
				TextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				TextBox.Text = guiLibrary.Config[Table.Name].textboxes[Tab.Name].value
				TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextBox.TextSize = 14
				TextBox.Font = Enum.Font.BuilderSans
				TextBox.PlaceholderText = "..."

				local BoxSide = Instance.new('Frame')
				BoxSide.Parent = BoxFrame
				BoxSide.Size = UDim2.new(0, 3, 1, 0)
				BoxSide.BorderSizePixel = 0
				BoxSide.BackgroundColor3 = guiLibrary.Pallete.changeColor(guiLibrary.Pallete.Main, 0.7)

				local BoxReturn = {value = TextBox.Text, inst = BoxFrame}

				TextBox.FocusLost:Connect(function(enterPressed)
					BoxReturn.value = TextBox.Text
					guiLibrary.Config[Table.Name].textboxes[Tab.Name].value = TextBox.Text
					if Tab.Function then
						task.spawn(pcall, function() Tab.Function(TextBox.Text) end)
					end
					guiLibrary.saveCFG(guiLibrary.CfgName)
				end)

				return BoxReturn
			end
			ModuleReturn.sliders = {}

		function ModuleReturn.sliders.new(Tab)
			if not guiLibrary.Config[Table.Name].sliders[Tab.Name] then
				guiLibrary.Config[Table.Name].sliders[Tab.Name] = {value = (Tab.Default or Tab.Maximum)}
			end

			Tab.Step = Tab.Step or 1

			local SliderFrame = Instance.new('Frame')
			SliderFrame.Parent = Dropdown
			SliderFrame.Size = UDim2.new(1, 0, 0, 42)
			SliderFrame.BorderSizePixel = 0
			SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

			local SliderLabel = Instance.new('TextLabel')
			SliderLabel.Parent = SliderFrame
			SliderLabel.Position = UDim2.fromOffset(8, 0)
			SliderLabel.Size = UDim2.new(1, 0, 0, 30)
			SliderLabel.BackgroundTransparency = 1
			SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
			SliderLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
			SliderLabel.TextSize = 16
			SliderLabel.Text = Tab.Name .. ' <font color="rgb(200,200,200)">(' .. (Tab.Default or Tab.Maximum) .. ')</font>'
			SliderLabel.Font = Enum.Font.BuilderSans
			SliderLabel.RichText = true

			local SliderSide = Instance.new('Frame')
			SliderSide.Parent = SliderFrame
			SliderSide.Size = UDim2.new(0, 3, 1, 0)
			SliderSide.BorderSizePixel = 0
			SliderSide.BackgroundColor3 = guiLibrary.Pallete.changeColor(guiLibrary.Pallete.Main, 0.7)

			local SliderBG = Instance.new('TextButton')
			SliderBG.Parent = SliderFrame
			SliderBG.Position = UDim2.fromOffset(8, 29)
			SliderBG.Size = UDim2.new(1, -16, 0, 7)
			SliderBG.BorderSizePixel = 0
			SliderBG.BackgroundColor3 = guiLibrary.Pallete.changeColor(guiLibrary.Pallete.Main, 0.7)
			SliderBG.Text = ''
			SliderBG.AutoButtonColor = false

			local SliderInvis = Instance.new('Frame')
			SliderInvis.Parent = SliderBG
			SliderInvis.Size = UDim2.fromScale(0.5, 1)
			SliderInvis.BorderSizePixel = 0
			SliderInvis.BackgroundColor3 = guiLibrary.Pallete.Main

			local SliderCircle = Instance.new('Frame')
			SliderCircle.Parent = SliderInvis
			SliderCircle.Size = UDim2.fromOffset(9, 9)
			SliderCircle.BackgroundColor3 = Color3.fromRGB(66, 245, 108)
			SliderCircle.Position = UDim2.fromScale(1, 0.5)
			SliderCircle.AnchorPoint = Vector2.new(0.5, 0.5)

			Instance.new('UICorner', SliderBG).CornerRadius = UDim.new(1, 0)
			Instance.new('UICorner', SliderInvis).CornerRadius = UDim.new(1, 0)
			Instance.new('UICorner', SliderCircle).CornerRadius = UDim.new(1, 0)

			local function snap(v)
				return math.clamp(math.round(v / Tab.Step) * Tab.Step, Tab.Minimum, Tab.Maximum)
			end

			local function setValue(v)
				v = snap(v)
				local pct = (v - Tab.Minimum) / (Tab.Maximum - Tab.Minimum)
				guiLibrary.Config[Table.Name].sliders[Tab.Name].value = v

				tweenService:Create(SliderInvis, TweenInfo.new(0.15), {Size = UDim2.fromScale(pct, 1)}):Play()

				SliderLabel.Text = Tab.Name .. ' <font color="rgb(200,200,200)">(' .. v .. ')</font>'
				if Tab.Function then
					Tab.Function(v)
				end
				guiLibrary.saveCFG(guiLibrary.CfgName)
			end

			local dragging = false
			
			local function updateInput(input)
				local pos = input.Position.X
				local rel = math.clamp((pos - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
				setValue(Tab.Minimum + (Tab.Maximum - Tab.Minimum) * rel)
			end

			-- MOBILE & PC SUPPORTED CONNECTIONS
			table.insert(guiLibrary.Collection, SliderBG.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					updateInput(i)
				end
			end))

			table.insert(guiLibrary.Collection, userInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end))

			table.insert(guiLibrary.Collection, userInputService.InputChanged:Connect(function(i)
				if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
					updateInput(i)
				end
			end))

			table.insert(guiLibrary.Collection, guiLibrary.Pallete.Changed.Event:Connect(function()
				SliderInvis.BackgroundColor3 = guiLibrary.Pallete.Main
				SliderSide.BackgroundColor3 = guiLibrary.Pallete.changeColor(guiLibrary.Pallete.Main, 0.7)
				SliderBG.BackgroundColor3 = guiLibrary.Pallete.changeColor(guiLibrary.Pallete.Main, 0.7)
			end))

			local SliderReturn = {value = guiLibrary.Config[Table.Name].sliders[Tab.Name].value, inst = SliderFrame}
			
			function SliderReturn:set(val)
				val = snap(val)
				self.value = val
				SliderInvis.Size = UDim2.fromScale((val - Tab.Minimum) / (Tab.Maximum - Tab.Minimum), 1)
				SliderLabel.Text = Tab.Name .. ' <font color="rgb(200,200,200)">(' .. val .. ')</font>'
				if Tab.Function then
					Tab.Function(val)
				end
			end

			task.delay(0.2, function()
				SliderReturn:set(SliderReturn.value)
			end)

			return SliderReturn
		end

			HideModule = ModuleReturn.toggles.new({
				['Name'] = 'HideModule',
				['Function'] = function(called)
					for i,v in aids do
						if v.Name == Table.Name then
							v.Visible = not called
						end
					end
				end,
			})

			local Hovering = false
			table.insert(guiLibrary.Collection, guiLibrary.Pallete.Changed.Event:Connect(function()
				if ModuleReturn.enabled then
					ModuleLabel.TextColor3 = guiLibrary.Pallete.Main
				end

				ModuleSide.BackgroundColor3 = guiLibrary.Pallete.changeColor(guiLibrary.Pallete.Main, 0.7)
			end))
			table.insert(guiLibrary.Collection, ModuleFrame.MouseEnter:Connect(function()
				Hovering = true
			end))
			table.insert(guiLibrary.Collection, ModuleFrame.MouseLeave:Connect(function()
				Hovering = false
			end))
			table.insert(guiLibrary.Collection, ModuleLabel.MouseButton1Down:Connect(function()
				ModuleReturn:toggle(false)
			end))
			table.insert(guiLibrary.Collection, ModuleDots.MouseButton1Down:Connect(function()
				Dropdown.Visible = not Dropdown.Visible
			end))
			table.insert(guiLibrary.Collection, ModuleLabel.MouseButton2Down:Connect(function()
				Dropdown.Visible = not Dropdown.Visible
			end))
			table.insert(guiLibrary.Collection, userInputService.InputBegan:Connect(function(Input: InputObject)
				if Input.UserInputType == Enum.UserInputType.MouseButton3 and Hovering then
					userInputService.InputBegan:Once(function(Input: InputObject)
						task.wait()
						if Input.KeyCode.Name ~= 'Unknown' and not userInputService:GetFocusedTextBox() then
							if guiLibrary.Config[Table.Name].keybind == Input.KeyCode.Name then
								guiLibrary.Config[Table.Name].keybind = 'Unknown'
							else
								guiLibrary.Config[Table.Name].keybind = Input.KeyCode.Name
							end

							if guiLibrary.Config[Table.Name].keybind ~= 'Unknown' then
								ModuleLabel.Text = '<font color="rgb(200,200,200)">['..guiLibrary.Config[Table.Name].keybind..']</font> ' .. Table.Name
							else
								ModuleLabel.Text = Table.Name
							end

							guiLibrary.saveCFG(guiLibrary.CfgName)
						end
					end)
				end
				if not userInputService:GetFocusedTextBox() and Input.KeyCode.Name == guiLibrary.Config[Table.Name].keybind and Input.KeyCode.Name ~= 'Unknown' then
					ModuleReturn:toggle(false)
				end
			end))

			if guiLibrary.Config[Table.Name].enabled then
				ModuleReturn:toggle(true)
			end

			ModuleReturn.inst = ModuleFrame

			return ModuleReturn
		end,
	}

	return self.Windows[Name]
end

guiLibrary.loadCFG(guiLibrary.CfgName)

guiLibrary:createWindow('Combat')
guiLibrary:createWindow('Movement')
guiLibrary:createWindow('Utility')
guiLibrary:createWindow('Visuals')
guiLibrary:createWindow('Extra')

local function getColorFixed(numb)
	return math.round(numb * 255)
end
--185, 75, 255
Interface = guiLibrary.Windows.Visuals:createModule({
	['Name'] = 'Interface',
	['Function'] = function(called)
		if not called then
			guiLibrary.Pallete.Main = Color3.fromRGB(66, 245, 108)
			guiLibrary.Pallete.Changed:Fire()
		else
			if CustomColor.enabled then
				task.delay(0.2, function()
					guiLibrary.Pallete.Main = Color3.fromRGB(InterfaceColorR, InterfaceColorG.value, InterfaceColorB.value)
					guiLibrary.Pallete.Changed:Fire()
				end)
			end
		end
	end,
})
CustomColor = Interface.toggles.new({
	['Name'] = 'Custom Color',
	['Function'] = function(called)
		InterfaceColorR.inst.Visible = called
		InterfaceColorG.inst.Visible = called
		InterfaceColorB.inst.Visible = called

		if not called then
			guiLibrary.Pallete.Main = Color3.fromRGB(66, 245, 108)
			guiLibrary.Pallete.Changed:Fire()
		else
			task.delay(0.2, function()
				guiLibrary.Pallete.Main = Color3.fromRGB(InterfaceColorR.value, InterfaceColorG.value, InterfaceColorB.value)
				guiLibrary.Pallete.Changed:Fire()
			end)
		end
	end,
})
InterfaceColorR = Interface.sliders.new({
	['Name'] = 'R',
	['Minimum'] = 0,
	['Maximum'] = 255,
	['Default'] = 185,
	['Function'] = function(val)
		if not Interface.enabled or not CustomColor.enabled then
			return
		end

		guiLibrary.Pallete.Main = Color3.fromRGB(val, getColorFixed(guiLibrary.Pallete.Main.G), getColorFixed(guiLibrary.Pallete.Main.B))
		guiLibrary.Pallete.Changed:Fire()
	end,
})
InterfaceColorG = Interface.sliders.new({
	['Name'] = 'G',
	['Minimum'] = 0,
	['Maximum'] = 255,
	['Default'] = 185,
	['Function'] = function(val)
		if not Interface.enabled or not CustomColor.enabled then
			return
		end

		guiLibrary.Pallete.Main = Color3.fromRGB(getColorFixed(guiLibrary.Pallete.Main.R), val, getColorFixed(guiLibrary.Pallete.Main.B))
		guiLibrary.Pallete.Changed:Fire()
	end,
})
InterfaceColorB = Interface.sliders.new({
	['Name'] = 'B',
	['Minimum'] = 0,
	['Maximum'] = 255,
	['Default'] = 185,
	['Function'] = function(val)
		if not Interface.enabled or not CustomColor.enabled then
			return
		end

		guiLibrary.Pallete.Main = Color3.fromRGB(getColorFixed(guiLibrary.Pallete.Main.R), getColorFixed(guiLibrary.Pallete.Main.G), val)
		guiLibrary.Pallete.Changed:Fire()
	end,
})

InterfaceColorR.inst.Visible = false
InterfaceColorG.inst.Visible = false
InterfaceColorB.inst.Visible = false

Arraylist = guiLibrary.Windows.Visuals:createModule({
	['Name'] = 'Arraylist',
	['Function'] = function(called)
		arrayList.Visible = called
	end,
})
ArrayBackground = Arraylist.sliders.new({
	['Name'] = 'Background',
	['Minimum'] = 0,
	['Maximum'] = 100,
	['Default'] = 50,
	['Function'] = function(val)
		for i,v in aids do
			v.BackgroundTransparency = (val / 100)
		end
	end,
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local WCam = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

--[[ Libraries ]]
local LocalLibrary = "Haze/libraries"
local modules = {
    Whitelist = loadfile(LocalLibrary .. "/Whitelist.lua")(),
    Notifications = loadfile(LocalLibrary .. "/Notifications.lua")(),
    FlyController = loadfile(LocalLibrary .. "/modules/FlyController.lua")(),
    ESPController = loadfile(LocalLibrary .. "/modules/EspController.lua")(),
	Discord = loadfile(LocalLibrary .. "/discord.lua")()
}

modules.Notifications:Notify("HAZE", "Welcome " .. LocalPlayer.Name .. ".", 5)

local DiscordModule
DiscordModule = guiLibrary.Windows.Extra:createModule({
	["Name"] = "Discord",
	["Function"] = function(state)
		if not state then return end

		modules.Discord:Join("https://discord.gg/W92SXVmB5X")
		modules.Discord:Copy("https://discord.gg/W92SXVmB5X")

		task.defer(function()
			if DiscordModule.enabled then
				DiscordModule:toggle(true)
			end
		end)
	end
})

--[[ ESP ]]
local ESPModule = guiLibrary.Windows.Visuals:createModule({
    ["Name"] = "ESP",
    ["Function"] = function(state)
        modules.ESPController.Enabled = state
    end
})

local ESPVibe = ESPModule.toggles.new({
    ["Name"] = "Vibe ESP",
    ["Description"] = "Give a good vibe to the esp boxes",
    ["Function"] = function(state)
        modules.ESPController.UseGradient = state
    end
})

local ESPTheme = ESPModule.selectors.new({
    ["Name"] = "Themes",
    ["Default"] = "Haze",
    ["Selections"] = {"Haze", "Aqua", "Nova"},
    ["Function"] = function(val)
        if val and val ~= "" then
            modules.ESPController.Theme = val
        else
            modules.ESPController.Theme = "Haze"
        end
    end
})

local ESPTeamCheck = ESPModule.toggles.new({
    ["Name"] = "Team Check",
    ["Function"] = function(state)
        modules.ESPController.TeamCheck = state
    end
})

local ESPIgnoreTeam = ESPModule.toggles.new({
    ["Name"] = "Ignore Team",
    ["Function"] = function(state)
        modules.ESPController.NoTeam = state
    end
})

--[[ Fly ]]
local FlyModule = guiLibrary.Windows.Movement:createModule({
    ["Name"] = "Fly",
    ["Function"] = function(state)
        modules.FlyController:Toggle(state)
    end
})

local FlyVertical = FlyModule.toggles.new({
    ["Name"] = "Vertical",
    ["Function"] = function(state)
        modules.FlyController:SetVertical(state)
    end
})

--[[ Reverbs ]]
local RevertReverbs = SoundService.AmbientReverb

local ReverbModule = guiLibrary.Windows.Visuals:createModule({
    ["Name"] = "Reverbs",
    ["Function"] = function(state)
        if state then
            SoundService.AmbientReverb = Enum.ReverbType.SewerPipe
        else
            SoundService.AmbientReverb = RevertReverbs
        end
    end
})

--[[ Viber ]]
local oldFOV = WCam.FieldOfView
local ReverbBackup = SoundService.AmbientReverb
local oldRevert = {
    ClockTime = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local volumeVal = 1

local MusicSound = Instance.new("Sound")
MusicSound.Parent = SoundService
MusicSound.Looped = true
MusicSound.Volume = volumeVal

local viberVar = false
local reverbsvibervar = false
local fovConnection
local snowConnection
local glowingsnow = {}
local beatLoaded = false

local function playBeat()
    if not beatLoaded then
        local path = "Haze/assets/audios/beat.mp3"
        local success, asset = pcall(function()
            return getcustomasset(path)
        end)
        if success and asset then
            MusicSound.SoundId = tostring(asset)
            beatLoaded = true
        else
            warn("Failed to load beat.mp3")
            return
        end
    end
    MusicSound:Play()
end

local ViberModule = guiLibrary.Windows.Visuals:createModule({
    ["Name"] = "Viber",
    ["Function"] = function(state)
        viberVar = state
        if state then
            playBeat()

            if reverbsvibervar then
                SoundService.AmbientReverb = Enum.ReverbType.Cave
            end

            Lighting.ClockTime = 23
            Lighting.Brightness = 2
            Lighting.FogEnd = 1000
            Lighting.Ambient = Color3.fromRGB(120,120,140)
            Lighting.OutdoorAmbient = Color3.fromRGB(80,80,100)

            fovConnection = RunService.RenderStepped:Connect(function()
                if MusicSound.IsPlaying then
                    local bass = MusicSound.PlaybackLoudness / 150
                    WCam.FieldOfView = oldFOV + bass * 15
                else
                    WCam.FieldOfView = oldFOV
                end
            end)

            snowConnection = RunService.RenderStepped:Connect(function(dt)
                local loudness = MusicSound.IsPlaying and MusicSound.PlaybackLoudness or 0
                local bassScale = math.clamp(loudness / 100, 0.5, 6)
                local rainbow = loudness >= 280

                for _ = 1, math.floor(6 * bassScale) do
                    local s = Instance.new("Part")
                    s.Anchored = true
                    s.CanCollide = false
                    s.Size = Vector3.new(0.5,0.5,0.5)
                    s.Material = Enum.Material.Neon
                    s.Color = rainbow and Color3.fromHSV(math.random(),1,1) or Color3.fromRGB(180,220,255)
                    s.Position = Vector3.new(math.random(-500,500), 80, math.random(-500,500))
                    s.Parent = workspace
                    table.insert(glowingsnow,s)
                end

                for i = #glowingsnow, 1, -1 do
                    local s = glowingsnow[i]
                    if not s or not s.Parent then
                        table.remove(glowingsnow, i)
                        continue
                    end
                    local fall = dt * 14 * bassScale
                    s.Position -= Vector3.new(0, fall, 0)
                    local params = RaycastParams.new()
                    params.FilterDescendantsInstances = { s }
                    params.FilterType = Enum.RaycastFilterType.Blacklist
                    local hit = workspace:Raycast(s.Position, Vector3.new(0, -fall, 0), params)
                    if hit or s.Position.Y <= 0 then
                        s:Destroy()
                        table.remove(glowingsnow, i)
                    end
                end
            end)
        else
            MusicSound:Stop()
            WCam.FieldOfView = oldFOV
            SoundService.AmbientReverb = ReverbBackup
            for k,v in pairs(oldRevert) do
                Lighting[k] = v
            end
            if fovConnection then fovConnection:Disconnect() end
            if snowConnection then snowConnection:Disconnect() end
            for _,s in ipairs(glowingsnow) do
                if s and s.Parent then s:Destroy() end
            end
            glowingsnow = {}
        end
    end
})

local ViberReverb = ViberModule.toggles.new({
    ["Name"] = "Reverbs",
    ["Function"] = function(state)
        reverbsvibervar = state
        if viberVar then
            SoundService.AmbientReverb = state and Enum.ReverbType.Cave or ReverbBackup
        end
    end
})

local ViberVolume = ViberModule.sliders.new({
    ["Name"] = "Volume",
    ["Minimum"] = 0.5,
    ["Maximum"] = 10,
    ["Default"] = 1,
    ["Function"] = function(value)
        volumeVal = value
        MusicSound.Volume = value
    end
})

--[[ Cape ]]
local Capevar = false

local CapePNG = "Haze/assets/capes/Cat.png"
local CapeColor = Color3.fromRGB(255,255,255)

local Cape, Motor

local function torso(char)
    return char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("HumanoidRootPart")
end

local function clear()
    if Cape then Cape:Destroy() Cape = nil end
    if Motor then Motor:Destroy() Motor = nil end
end

local function build(char)
    clear()
    local t = torso(char)
    if not t then return end

    Cape = Instance.new("Part")
    Cape.Size = Vector3.new(2,4,0.1)
    Cape.Color = CapeColor
    Cape.Material = Enum.Material.SmoothPlastic
    Cape.Massless = true
    Cape.CanCollide = false
    Cape.CastShadow = false
    Cape.Parent = WCam

    local gui = Instance.new("SurfaceGui", Cape)
    gui.Adornee = Cape
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud

    local img = Instance.new("ImageLabel", gui)
    img.Size = UDim2.fromScale(1,1)
    img.BackgroundTransparency = 1
    img.Image = CapePNG:find("rbxasset") and CapePNG or getcustomasset(CapePNG)

    Motor = Instance.new("Motor6D", Cape)
    Motor.Part0 = Cape
    Motor.Part1 = t
    Motor.MaxVelocity = 0.08
    Motor.C0 = CFrame.new(0,2,0) * CFrame.Angles(0, math.rad(-90), 0)
    Motor.C1 = CFrame.new(0, t.Size.Y/2, 0.45) * CFrame.Angles(0, math.rad(90), 0)

    task.spawn(function()
        while Capevar and Cape and Motor do
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local v = math.min(root.Velocity.Magnitude, 90)
                Motor.DesiredAngle = math.rad(6 + v) +
                    (v > 1 and math.abs(math.cos(tick()*5))/3 or 0)
            end

            local d = (WCam.CFrame.Position - WCam.Focus.Position).Magnitude
            gui.Enabled = d > 0.6
            Cape.Transparency = d > 0.6 and 0 or 1
            task.wait()
        end
    end)
end

local CapeModule = guiLibrary.Windows.Visuals:createModule({
    ["Name"] = "Cape",
    ["Function"] = function(v)
        Capevar = v
        if v and LocalPlayer.Character then
            build(LocalPlayer.Character)
        else
            clear()
        end
    end
})

local CapeFiles = CapeModule.selectors.new({
    ["Name"] = "Capes",
    ["Default"] = "Wave",
    ["Selections"] = {"Cat", "Waifu", "Troll", "Wave"},
    ["Function"] = function(v)
        local path = "Haze/assets/capes/"..v..".png"
        if isfile(path) then
            CapePNG = path
            if Capevar and LocalPlayer.Character then
                build(LocalPlayer.Character)
            end
        end
    end
})

--[[ Vibe ]]
local VibeModule = guiLibrary.Windows.Visuals:createModule({
    ["Name"] = "Vibe",
    ["Function"] = function(state)
        if state then
            Lighting.TimeOfDay = "00:00:00"
            Lighting.Technology = Enum.Technology.Future

            if not Lighting:FindFirstChild("VibeSky") then
                local sky = Instance.new("Sky")
                sky.Name = "VibeSky"
                sky.SkyboxBk = ""; sky.SkyboxDn = ""; sky.SkyboxFt = ""
                sky.SkyboxLf = ""; sky.SkyboxRt = ""; sky.SkyboxUp = ""
                sky.Parent = Lighting

                local atm = Instance.new("Atmosphere")
                atm.Density = 0.3
                atm.Offset = 0
                atm.Color = Color3.fromRGB(255,182,193)
                atm.Decay = Color3.fromRGB(50,0,80)
                atm.Glare = 0.5
                atm.Haze = 0.1
                atm.Parent = Lighting
            end

            if not Workspace:FindFirstChild("Snowing") then
                local p = Instance.new("Part")
                p.Name = "Snowing"
                p.Anchored = true
                p.CanCollide = false
                p.Size = Vector3.new(500,1,500)
                p.Position = Vector3.new(0,150,0)
                p.Transparency = 1
                p.Parent = Workspace

                local e = Instance.new("ParticleEmitter")
                e.Texture = "rbxassetid://258128463"
                e.Rate = 200
                e.Lifetime = NumberRange.new(8,15)
                e.Speed = NumberRange.new(5,10)
                e.SpreadAngle = Vector2.new(360,0)
                e.Size = NumberSequence.new(2)
                e.VelocityInheritance = 0
                e.Acceleration = Vector3.new(0,-50,0)
                e.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,182,193)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(173,216,230)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(50,0,80))
                }
                e.LightEmission = 0.9
                e.Parent = p
            end
        else
            Lighting.TimeOfDay = "14:00:00"
            Lighting.Technology = Enum.Technology.Compatibility

            if Workspace:FindFirstChild("Snowing") then Workspace.Snowing:Destroy() end
            if Lighting:FindFirstChild("VibeSky") then Lighting.VibeSky:Destroy() end
            for _, a in pairs(Lighting:GetChildren()) do if a:IsA("Atmosphere") then a:Destroy() end end
        end
    end
})

--[[ FOV ]]
local FOVVar = false
local FOVValue = 90
local FOVConnection

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    WCam = workspace.CurrentCamera
end)

local function ManageFOV()
    if FOVConnection then FOVConnection:Disconnect() end
    
    if FOVVar then
        FOVConnection = RunService.RenderStepped:Connect(function()
            WCam.FieldOfView = FOVValue
        end)
    else
        WCam.FieldOfView = 70
    end
end

local FOVModule = guiLibrary.Windows.Visuals:createModule({
    ["Name"] = "FOV",
    ["Function"] = function(state)
        FOVVar = state
        ManageFOV()
    end,
    ["ExtraText"] = function()
        return tostring(FOVValue)
    end
})

local FOVModuleVal = FOVModule.sliders.new({
    ["Name"] = "FOV",
    ["Minimum"] = 90,
    ["Maximum"] = 120,
    ["Default"] = 120,
    ["Function"] = function(value)
        FOVValue = value
    end
})

shared.guiLibrary = guiLibrary

return guiLibrary