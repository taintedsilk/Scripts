local getgenv: () -> ({[string]: any}) = getfenv().getgenv

getgenv().ScriptVersion = "Discontinued"

loadstring(game:HttpGet("https://raw.githubusercontent.com/alyssagithub/Scripts/refs/heads/main/FrostByte/Core.luau"))()

type Tab = {
	CreateSection: (self: Tab, Name: string) -> Section,
	CreateDivider: (self: Tab) -> Divider,
}

local ApplyUnsupportedName: (Name: string, Condition: boolean) -> (string) = getgenv().ApplyUnsupportedName
local HandleConnection: (Connection: RBXScriptConnection, Name: string) -> () = getgenv().HandleConnection
local Notify: (Title: string, Content: string, Image: string) -> () = getgenv().Notify
local GetClosestChild: (Children: {PVInstance}, Callback: (Child: PVInstance) -> boolean) -> (PVInstance?) = getgenv().GetClosestChild

local Remotes: Folder & {[string]: RemoteEvent & RemoteFunction} = game:GetService("ReplicatedStorage").Remotes

local Interactions: Folder = workspace:WaitForChild("Interactions")

local Flags: {[string]: {["CurrentValue"]: any, ["CurrentOption"]: {string}}} = getgenv().Flags

local Player = game:GetService("Players").LocalPlayer

local Window = getgenv().Window

if not Window then
	return
end

local Tab: Tab = Window:CreateTab("Combat", "swords")

Tab:CreateSection("Attacking")

Tab:CreateToggle({
	Name = "⚔ • Kill Aura",
	CurrentValue = false,
	Flag = "KillAura",
	Callback = function(Value)	
		while Flags.KillAura.CurrentValue and task.wait() do
			local Closest = GetClosestChild(workspace.Characters:GetChildren(), function(Child)
				if Child == Player.Character then
					return true
				end
			end)
			
			if not Closest then
				continue
			end
			
			Remotes.CharactersDamageRemote:FireServer({Closest})
		end
	end,
})
Tab:CreateToggle({
	Name = "🔥 • Breath Aura (Needs Breath On)",
	CurrentValue = false,
	Flag = "BreathAura",
	Callback = function(Value)	
		while Flags.BreathAura.CurrentValue and task.wait() do
			local Closest = GetClosestChild(workspace.Characters:GetChildren(), function(Child)
				if Child == Player.Character then
					return true
				end
			end)

			if not Closest then
				continue
			end

			Remotes.CharactersDamageRemoteBreath:FireServer({Closest})
		end
	end,
})

-- VVVVVV NEWLY ADDED CODE STARTS HERE VVVVVV

Tab:CreateButton({
    Name = "🎯 • Hit Random Player",
    Callback = function()
        if not Player.Character then
            getgenv().Notify("Error", "You do not have a character. Please spawn in first.")
            return
        end

        local characters = workspace.Characters:GetChildren()
        local otherPlayerModels = {} -- Store valid, non-local player character models
        for _, charInstance in ipairs(characters) do
            -- Check if it's a Model, has a Humanoid, and is not the LocalPlayer's character
            if charInstance:IsA("Model") and charInstance:FindFirstChild("Humanoid") and charInstance ~= Player.Character then
                table.insert(otherPlayerModels, charInstance)
            end
        end

        if #otherPlayerModels > 0 then
            local randomTarget = otherPlayerModels[math.random(#otherPlayerModels)]
            getgenv().Notify("Combat", "Attempting to hit random player: " .. randomTarget.Name)
            Remotes.CharactersDamageRemote:FireServer({randomTarget})
        else
            getgenv().Notify("Combat", "No other players found to target.")
        end
    end
})

-- Assuming Tab:CreateInput exists and works similarly to CreateToggle, using the Flags system.
-- The 'Flag' property will store the input text in getgenv().Flags.TargetPlayerNameInput.CurrentValue
Tab:CreateInput({
    Name = "👤 Target Player Name",
    PlaceholderText = "Enter player's exact name", -- Assuming a 'PlaceholderText' property
    Flag = "TargetPlayerNameInput", -- This flag will hold the string from the input field
    CurrentValue = "", -- Initial value of the input field
    Callback = function(Value)
        -- This callback is typically invoked when the input value changes.
        -- The UI system should ideally update Flags.TargetPlayerNameInput.CurrentValue automatically.
        -- If specific action on text change is needed, it would go here.
        -- For this use case, the button will read the value, so this can be minimal.
    end
})

Tab:CreateButton({
    Name = "🏹 • Hit Player by Name",
    Callback = function()
        if not Player.Character then
            getgenv().Notify("Error", "You do not have a character. Please spawn in first.")
            return
        end

        -- Read the target name from the flag associated with the input field
        local targetName = Flags.TargetPlayerNameInput and Flags.TargetPlayerNameInput.CurrentValue
        
        if not targetName or targetName == "" then
            getgenv().Notify("Error", "Please enter a player name in the 'Target Player Name' input field.")
            return
        end

        local targetCharacter = nil
        for _, charInstance in ipairs(workspace.Characters:GetChildren()) do
            -- Check if it's a Model, has a Humanoid, and matches the target name
            if charInstance:IsA("Model") and charInstance:FindFirstChild("Humanoid") and charInstance.Name == targetName then
                if charInstance == Player.Character then
                    getgenv().Notify("Info", "You cannot target yourself using this function.")
                    return -- Exit if trying to target self
                end
                targetCharacter = charInstance
                break
            end
        end

        if targetCharacter then
            getgenv().Notify("Combat", "Attempting to hit player: " .. targetCharacter.Name)
            Remotes.CharactersDamageRemote:FireServer({targetCharacter})
        else
            getgenv().Notify("Combat", "Player '" .. targetName .. "' not found or is not a valid character.")
        end
    end
})

Tab:CreateToggle({
	Name = "🔥 • Breath Aura (Needs Breath On)",
	CurrentValue = false,
	Flag = "BreathAura",
	Callback = function(Value)	
		while Flags.BreathAura.CurrentValue and task.wait() do
			local Closest = GetClosestChild(workspace.Characters:GetChildren(), function(Child)
				if Child == Player.Character then
					return true
				end
			end)

			if not Closest then
				continue
			end

			Remotes.CharactersDamageRemoteBreath:FireServer({Closest})
		end
	end,
})

local Tab: Tab = Window:CreateTab("Consumption", "apple")

Tab:CreateSection("Food/Drinks")

Tab:CreateToggle({
	Name = "🍴 • Auto Eat Closest Food",
	CurrentValue = false,
	Flag = "Eat",
	Callback = function(Value)	
		while Flags.Eat.CurrentValue and task.wait() do
			local Closest = GetClosestChild(Interactions.Food:GetChildren(), function(Child: PVInstance)
				if not Child:GetChildren()[1] then
					return true
				end

				local Value = Child:GetAttribute("Value")

				if not Value or Value <= 0 then
					return true
				end
			end)
			
			if not Closest then
				continue
			end
			
			Remotes.Food:FireServer(Closest)
		end
	end,
})

Tab:CreateToggle({
	Name =  "💧 • Auto Drink on Closest Lake",
	CurrentValue = false,
	Flag = "Drink",
	Callback = function(Value)	
		while Flags.Drink.CurrentValue and task.wait() do
			local Closest = GetClosestChild(Interactions.Lakes:GetChildren(), function(Child)
				if Child:GetAttribute("Sickly") then
					return true
				end
			end)

			if not Closest then
				continue
			end
			
			Remotes.DrinkRemote:FireServer(Closest)
		end
	end,
})

Tab:CreateSection("Ailments")

Tab:CreateToggle({
	Name = "💨 • Auto Use Closest Mud Pile",
	CurrentValue = false,
	Flag = "Mud",
	Callback = function(Value)
		while Flags.Mud.CurrentValue and task.wait() do
			local Closest = GetClosestChild(Interactions.Mud:GetChildren())

			if not Closest then
				continue
			end

			Remotes.Mud:FireServer(Closest)
			task.wait(1)
		end
	end,
})

Tab:CreateSection("Items")

Tab:CreateToggle({
	Name = "💊 • Auto Collect Spawned Tokens",
	CurrentValue = false,
	Flag = "Tokens",
	Callback = function(Value)	
		while Flags.Tokens.CurrentValue and task.wait() do
			local Token: MeshPart? = Interactions.SpawnedTokens:GetChildren()[1]

			if not Token then
				continue
			end

			if Remotes.GetSpawnedTokenRemote:InvokeServer() then
				Token:Destroy()
			end
		end
	end,
})

local function GetResourcesTable()
	local DroppedResources = {}

	for _, Resource: PVInstance in Interactions.DroppedResources:GetChildren() do
		table.insert(DroppedResources, Resource.Name)
	end
	
	return DroppedResources
end

local ResourcesDropdown
ResourcesDropdown = Tab:CreateDropdown({
	Name = "💎 • Quick Pick Up Resources",
	Options = GetResourcesTable(),
	CurrentOption = "",
	MultipleOptions = false,
	Callback = function(CurrentOption)
		CurrentOption = CurrentOption[1]

		if CurrentOption == "" then
			return
		end
		
		local Resource = Interactions.DroppedResources:FindFirstChild(CurrentOption)
		
		if not Resource then
			return
		end
		
		Remotes.PickupResource:FireServer(Resource)
		ResourcesDropdown:Set({""})
	end,
})

Tab:CreateButton({
	Name = "🔃 • Refresh Dropdown",
	Callback = function()
		ResourcesDropdown:Refresh(GetResourcesTable())
	end,
})

local Tab: Tab = Window:CreateTab("Transport", "wind")

Tab:CreateSection("Teleportation")

Tab:CreateButton({
	Name = "🥚 • Teleport to Abandoned Egg",
	Callback = function()
		local Teleported = false
		
		local Character = Player.Character
		
		if not Character then
			return Notify("Error", "You do not have a character, please spawn in first.")
		end
		
		for _, Egg: Model in Interactions.AbandonedEggs:GetChildren() do
			if not Egg:GetChildren()[1] then
				continue
			end
			
			Character:PivotTo(Egg:GetPivot())
			Teleported = true
			break
		end
		
		if not Teleported then
			Notify("Failed", "Couldn't find an Abandoned Egg")
		end
	end,
})

local WardenShrines = {}

for _, Shrine: Folder in Interactions["Warden Shrines"]:GetChildren() do
	for _, Tablet: MeshPart in Shrine:GetChildren() do
		table.insert(WardenShrines, Tablet.Name)
	end
end

local TeleportWardenShrine
TeleportWardenShrine = Tab:CreateDropdown({
	Name = "⛩ • Teleport to Warden Shrine",
	Options = WardenShrines,
	CurrentOption = "",
	MultipleOptions = false,
	Callback = function(CurrentOption)
		CurrentOption = CurrentOption[1]

		if CurrentOption == "" then
			return
		end
		
		local Tablet: MeshPart = Interactions["Warden Shrines"]:FindFirstChild(CurrentOption, true)
		
		if not Tablet then
			return Notify("Error", `Couldn't find the tablet for the '{CurrentOption}' Warden Shrine.`)
		end
		
		local Character = Player.Character
		
		if not Character then
			return
		end

		Character:PivotTo(Tablet:GetPivot() + Tablet:GetPivot().LookVector * 5)
		TeleportWardenShrine:Set({""})
	end,
})

local Tab: Tab = Window:CreateTab("Safety", "shield")

Tab:CreateSection("Damage")

Tab:CreateToggle({
	Name = "🌋 • Delete All Lava Pools",
	CurrentValue = false,
	Flag = "DeleteLava",
	Callback = function(Value)	
		if not Value then
			return
		end
		
		Interactions.LavaPools:ClearAllChildren()
	end,
})

Tab:CreateSection("Location")

Tab:CreateToggle({
	Name = "🛡 • Auto Hide Scent",
	CurrentValue = false,
	Flag = "Scent",
	Callback = function(Value)
		while Flags.Scent.CurrentValue and task.wait() do
			Remotes.HideScent:FireServer()
			
			task.wait(5)
		end
	end,
})

local Tab: Tab = Window:CreateTab("Boost", "arrow-big-up-dash")

Tab:CreateSection("Oxygen")

local InfiniteNumber = 1e9

local function SetModuleFunctions(Value: boolean, BoostName: string, Module, OriginalFunctions: {[string]: () -> ()})
	if Value then
		for _, FunctionName in {`GetMax{BoostName}`, `Get{BoostName}`} do
			OriginalFunctions[FunctionName] = Module[FunctionName]
			print("set function for:", FunctionName, "Existing function:", Module[FunctionName])
			Module[FunctionName] = function(Data)
				local PropertyName = FunctionName:gsub("Get", "")
				
				if Data[PropertyName] then
					Data[PropertyName] = InfiniteNumber
				end
				
				return 1e9
			end
		end
	else
		for Name, Function in OriginalFunctions do
			Module[Name] = Function
		end
	end
end

local CanUseModules, OxygenModule = pcall(require, game:GetService("ReplicatedStorage")._replicationFolder.OxygenTracker)

local OxygenFunctions = {}

Tab:CreateToggle({
	Name =  ApplyUnsupportedName("🌊 • Infinite Oxygen", CanUseModules),
	CurrentValue = false,
	Flag = "Oxygen",
	Callback = function(Value)
		if not CanUseModules then
			return
		end
		
		SetModuleFunctions(Value, "Oxygen", OxygenModule, OxygenFunctions)
	end,
})

local _, StaminaModule = pcall(require, game:GetService("ReplicatedStorage")._replicationFolder.StaminaTracker)

local StaminaFunctions = {}

Tab:CreateToggle({
	Name =  ApplyUnsupportedName("⚡ • Infinite Stamina", CanUseModules),
	CurrentValue = false,
	Flag = "Stamina",
	Callback = function(Value)
		if not CanUseModules then
			return
		end
		
		SetModuleFunctions(Value, "Stamina", StaminaModule, StaminaFunctions)
	end,
})

local Tab: Tab = Window:CreateTab("Reset", "rotate-ccw")

Tab:CreateSection("Suicide")

local Suicide = false
local Toggle
Toggle = Tab:CreateToggle({
	Name = "🩸 • Suicide (KILLS YOUR CREATURE)",
	CurrentValue = false,
	Callback = function(Value)
		Suicide = Value
		
		if Value then
			for i = 5, 1, -1 do
				if not Suicide then
					Notify("Cancel", "Canceled the suicide.")
					break
				end
				
				Notify("Suicide", `Killing your creature in {i} second(s), disable to cancel.`)
				task.wait(1)
			end
		end
		
		while Suicide and task.wait() and Player.Character do
			Remotes.LavaSelfDamage:FireServer()
		end
		
		if Suicide then
			pcall(Toggle.Set, Toggle, false)
			Suicide = false
			Notify("Suicide Disabled", "Detected your death, disabled suicide.")
		end
	end,
})

getgenv().CreateUniversalTabs()
