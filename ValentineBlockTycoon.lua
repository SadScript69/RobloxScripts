local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- ===== CONFIG =====
local SPEED = 16
local REACH_DISTANCE = 3

humanoid.WalkSpeed = SPEED

local HEARTS_FOLDER =
	Workspace:WaitForChild("Map")
	:WaitForChild("Physical")
	:WaitForChild("Pumpkins")

-- ===== ETAT =====
local botEnabled = false
local currentTarget = nil

-- ===== STATS =====
local leaderstats = player:WaitForChild("leaderstats")
local heartValue = leaderstats:WaitForChild("Hearts")

local startHearts = heartValue.Value
local startTime = tick()

-- ===== GUI =====
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false
gui.Name = "HeartBotGui"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 180, 0, 150)
frame.Position = UDim2.new(0.02, 0, 0.75, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true

-- ===== DRAG =====
local dragging = false
local dragStart
local startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		updateDrag(input)
	end
end)

-- ===== UI ELEMENTS =====
local function makeLabel(text, y)
	local l = Instance.new("TextLabel", frame)
	l.Size = UDim2.new(1, -10, 0, 22)
	l.Position = UDim2.new(0, 5, 0, y)
	l.BackgroundTransparency = 1
	l.TextColor3 = Color3.new(1,1,1)
	l.TextScaled = true
	l.Text = text
	return l
end

local function makeButton(text, y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(1, -10, 0, 30)
	b.Position = UDim2.new(0, 5, 0, y)
	b.BackgroundColor3 = Color3.fromRGB(140,50,50)
	b.TextColor3 = Color3.new(1,1,1)
	b.TextScaled = true
	b.Text = text
	b.BorderSizePixel = 0
	return b
end

makeLabel("💘 Heart Bot", 5)

local gainMinLabel = makeLabel("Hearts/min : 0", 30)
local gainHourLabel = makeLabel("Hearts/h : 0", 52)

local toggleBtn = makeButton("OFF", 90)

-- ===== TROUVE HEART LE PLUS PROCHE =====
local function getClosestHeart()
	local closest = nil
	local dist = math.huge

	for _, obj in pairs(HEARTS_FOLDER:GetChildren()) do
		if obj:IsA("BasePart") then
			local d = (root.Position - obj.Position).Magnitude
			if d < dist then
				dist = d
				closest = obj
			end
		end
	end

	return closest
end

-- ===== BOT LOOP =====
RunService.Heartbeat:Connect(function()
	if not botEnabled then return end

	local target = getClosestHeart()
	if not target then return end

	currentTarget = target
	humanoid:MoveTo(currentTarget.Position)

	if (root.Position - currentTarget.Position).Magnitude <= REACH_DISTANCE then
		currentTarget = nil
	end
end)

-- ===== STATS LOOP =====
RunService.Heartbeat:Connect(function()
	if not botEnabled then return end

	local elapsed = tick() - startTime
	if elapsed < 1 then return end

	local gained = heartValue.Value - startHearts
	local perMin = math.floor((gained / elapsed) * 60)
	local perHour = math.floor((gained / elapsed) * 3600)

	gainMinLabel.Text = "Hearts/min : +" .. perMin
	gainHourLabel.Text = "Hearts/h : +" .. perHour
end)

-- ===== TOGGLE =====
toggleBtn.MouseButton1Click:Connect(function()
	botEnabled = not botEnabled

	if botEnabled then
		toggleBtn.Text = "ON"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(50,140,50)
		startHearts = heartValue.Value
		startTime = tick()
	else
		toggleBtn.Text = "OFF"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(140,50,50)
		humanoid:Move(Vector3.zero)
		currentTarget = nil
	end
end)
