local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- ===== CONFIG =====
local SPEED = 16
local REACH_DISTANCE = 3

humanoid.WalkSpeed = SPEED

-- Dossier EXACT vu sur ta capture
local PUMPKINS_FOLDER =
	Workspace:WaitForChild("Map")
	:WaitForChild("Physical")
	:WaitForChild("Pumpkins")

-- ===== ETAT =====
local botEnabled = false
local currentTargetRoot = nil

-- ===== GUI =====
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "FarmBotGui"
gui.ResetOnSpawn = false

local button = Instance.new("TextButton", gui)
button.Size = UDim2.new(0, 180, 0, 40)
button.Position = UDim2.new(0.02, 0, 0.8, 0)
button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Text = "BOT FARM : OFF"
button.BorderSizePixel = 0

-- ===== FONCTION : CANNE LA PLUS PROCHE =====
local function getClosestPumpkinRoot()
	local closestRoot = nil
	local shortestDistance = math.huge

	for _, model in pairs(PUMPKINS_FOLDER:GetChildren()) do
		if model:IsA("Model") then
			local rootPart = model:FindFirstChild("Root")
			if rootPart and rootPart:IsA("BasePart") then
				local dist = (root.Position - rootPart.Position).Magnitude
				if dist < shortestDistance then
					shortestDistance = dist
					closestRoot = rootPart
				end
			end
		end
	end

	return closestRoot
end

-- ===== LOOP BOT =====
RunService.Heartbeat:Connect(function()
	if not botEnabled then return end

	-- Trouver la plus proche canne à sucre
	local newTargetRoot = getClosestPumpkinRoot()

	-- Si la cible actuelle est différente ou si elle a disparu
	if newTargetRoot and (not currentTargetRoot or (newTargetRoot.Position - root.Position).Magnitude < (currentTargetRoot.Position - root.Position).Magnitude) then
		-- Changer la cible
		currentTargetRoot = newTargetRoot
		humanoid:MoveTo(currentTargetRoot.Position)
	end

	-- Vérifier si la cible est proche et récolter
	if currentTargetRoot and (root.Position - currentTargetRoot.Position).Magnitude <= REACH_DISTANCE then
		-- Le jeu va gérer la collecte
		currentTargetRoot = nil
	end
end)

-- ===== TOGGLE =====
button.MouseButton1Click:Connect(function()
	botEnabled = not botEnabled

	if botEnabled then
		button.Text = "BOT FARM : ON"
		button.BackgroundColor3 = Color3.fromRGB(0,170,0)
	else
		button.Text = "BOT FARM : OFF"
		button.BackgroundColor3 = Color3.fromRGB(200,0,0)
		humanoid:Move(Vector3.zero)
		currentTargetRoot = nil
	end
end)
