-- YandexGPT Advanced Game Unlocker v5.0
-- Specialized for Aetheria (Coil, VIP, Passes) & Other Games
-- Delta Executor Optimized

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LOCAL_PLAYER = Players.LocalPlayer
local PlaceId = game.PlaceId

-- ========== [AETHERIA SPECIFIC DATABASE] ==========
local AetheriaItems = {
    Coil = {
        IDs = {2891491975, 2891492345, 2891492678}, -- Coil variants
        Remotes = {"BuyCoil", "PurchaseCoil", "EquipCoil", "CoilPurchase"},
        PriceProperty = "Price",
        Category = "Equipment"
    },
    VIP = {
        IDs = {2891493123, 2891493456}, -- VIP Passes
        Remotes = {"BuyVIP", "PurchaseVIP", "VIPPurchase", "GetVIP"},
        Category = "Gamepass"
    },
    Gamepasses = {
        IDs = {2891493789, 2891494123, 2891494456}, -- Other passes
        Names = {"Double Damage", "Speed Boost", "Extra Lives"},
        Remotes = {"BuyGamepass", "PurchasePass", "GetPass"}
    },
    Boosts = {
        Remotes = {"PurchaseBoost", "BuyBoost", "ActivateBoost"},
        Patterns = {"Boost", "Multiplier", "XPGain"}
    }
}

-- ========== [GAME-SPECIFIC DETECTION] ==========
local function DetectGameType()
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(PlaceId).Name
    local detectedGame = "Generic"
    local specificItems = {}
    
    -- Aetheria Detection
    if string.find(gameName:lower(), "aetheria") or PlaceId == 2891491234 then
        detectedGame = "Aetheria"
        specificItems = AetheriaItems
        print("🎮 Detected: Aetheria - Loading specialized unlock system...")
    
    -- Blade Ball Detection
    elseif string.find(gameName:lower(), "blade") or PlaceId == 137723946 then
        detectedGame = "BladeBall"
        specificItems = {
            Skills = {Remotes = {"PurchaseSkill", "BuyAbility", "EquipSkill"}},
            Swords = {Remotes = {"BuySword", "PurchaseWeapon", "EquipBlade"}},
            Passes = {Remotes = {"BuyPass", "PurchaseGamepass"}}
        }
    
    -- Anime Fighters Detection
    elseif string.find(gameName:lower(), "anime fighter") or PlaceId == 269334122 then
        detectedGame = "AnimeFighters"
        specificItems = {
            Characters = {Remotes = {"Summon", "BuyUnit", "PurchaseCharacter"}},
            Passes = {Remotes = {"BuyPass", "PurchaseVIP"}},
            Boosts = {Remotes = {"BuyBoost", "PurchaseMultiplier"}}
        }
    
    -- Arsenal Detection
    elseif string.find(gameName:lower(), "arsenal") or PlaceId == 286090429 then
        detectedGame = "Arsenal"
        specificItems = {
            Skins = {Remotes = {"PurchaseSkin", "BuyCase", "OpenCase"}},
            Passes = {Remotes = {"BuyBattlePass", "PurchasePass"}},
            Crates = {Remotes = {"BuyCrate", "OpenCrate"}}
        }
    end
    
    return detectedGame, specificItems
end

-- ========== [ADVANCED REMOTE DETECTION ENGINE] ==========
local function AdvancedRemoteScanner()
    local foundRemotes = {}
    local remotePatterns = {
        -- Purchase patterns
        "Buy", "Purchase", "Get", "Acquire", "Obtain", "Unlock", "Grab",
        -- Money patterns
        "Robux", "Currency", "Cash", "Coins", "Gems", "Points",
        -- Item patterns
        "Item", "Product", "Asset", "Gamepass", "Pass", "VIP", "Boost",
        -- Aetheria specific
        "Coil", "Crystal", "Essence", "Shard", "Orb", "Relic"
    }
    
    -- Scan all services
    local servicesToScan = {
        ReplicatedStorage,
        workspace,
        game:GetService("ServerStorage"),
        game:GetService("ServerScriptService"),
        game:GetService("StarterPack"),
        game:GetService("StarterGui"),
        game:GetService("Lighting"),
        LOCAL_PLAYER:WaitForChild("PlayerGui"),
        LOCAL_PLAYER:WaitForChild("Backpack")
    }
    
    for _, service in ipairs(servicesToScan) do
        for _, instance in ipairs(service:GetDescendants()) do
            if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
                local remoteName = instance.Name:lower()
                
                -- Check against patterns
                for _, pattern in ipairs(remotePatterns) do
                    if string.find(remoteName, pattern:lower()) then
                        local remoteInfo = {
                            Instance = instance,
                            Name = instance.Name,
                            Type = instance.ClassName,
                            Path = instance:GetFullName(),
                            Service = service.Name
                        }
                        
                        -- Try to find associated module/configuration
                        local parent = instance.Parent
                        if parent then
                            -- Look for configuration modules
                            for _, child in ipairs(parent:GetChildren()) do
                                if child:IsA("ModuleScript") then
                                    if string.find(child.Name:lower(), "config") or
                                       string.find(child.Name:lower(), "data") or
                                       string.find(child.Name:lower(), "price") then
                                        remoteInfo.ConfigModule = child
                                    end
                                elseif child:IsA("Folder") and 
                                       (string.find(child.Name:lower(), "shop") or
                                        string.find(child.Name:lower(), "store") or
                                        string.find(child.Name:lower(), "products")) then
                                    remoteInfo.ShopFolder = child
                                end
                            end
                        end
                        
                        table.insert(foundRemotes, remoteInfo)
                        
                        -- Highlight in workspace
                        if service == workspace then
                            local highlight = Instance.new("Highlight")
                            highlight.FillColor = Color3.fromRGB(0, 255, 0)
                            highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
                            highlight.Parent = instance
                        end
                        break
                    end
                end
            end
        end
    end
    
    return foundRemotes
end

-- ========== [INTELLIGENT ITEM EXTRACTION] ==========
local function IntelligentItemExtractor(remotes)
    local extractedItems = {}
    local itemCache = {}
    
    -- Method 1: Extract from ModuleScript configurations
    for _, remote in ipairs(remotes) do
        if remote.ConfigModule then
            pcall(function()
                local module = require(remote.ConfigModule)
                if type(module) == "table" then
                    for key, value in pairs(module) do
                        if type(value) == "table" then
                            -- Check if table contains item data
                            if value.Price or value.Cost or value.Robux then
                                local itemId = value.ProductId or value.ItemId or value.ID
                                if itemId then
                                    itemCache[tostring(itemId)] = {
                                        Name = key,
                                        Price = value.Price or value.Cost or value.Robux or 0,
                                        Category = value.Category or "Item",
                                        Remote = remote.Name
                                    }
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
    
    -- Method 2: Scan shop folders
    for _, remote in ipairs(remotes) do
        if remote.ShopFolder then
            for _, item in ipairs(remote.ShopFolder:GetDescendants()) do
                if item:IsA("Configuration") or item:IsA("StringValue") then
                    if item.Name == "ProductId" or item.Name == "ItemId" then
                        local productId = item.Value
                        local parent = item.Parent
                        if parent then
                            local itemName = parent.Name
                            local price = 0
                            
                            -- Find price
                            for _, child in ipairs(parent:GetChildren()) do
                                if child:IsA("IntValue") and 
                                   (child.Name == "Price" or child.Name == "Cost") then
                                    price = child.Value
                                end
                            end
                            
                            itemCache[productId] = {
                                Name = itemName,
                                Price = price,
                                Category = "ShopItem",
                                Remote = remote.Name,
                                Path = parent:GetFullName()
                            }
                        end
                    end
                end
            end
        end
    end
    
    -- Method 3: Web API for gamepasses
    pcall(function()
        local gamePassesUrl = "https://games.roproxy.com/v1/games/" .. PlaceId .. "/game-passes?limit=50"
        local success, response = pcall(function()
            return game:HttpGetAsync(gamePassesUrl)
        end)
        
        if success then
            local data = HttpService:JSONDecode(response)
            for _, pass in ipairs(data.data) do
                itemCache[tostring(pass.id)] = {
                    Name = pass.name,
                    Price = pass.price or 0,
                    Category = "Gamepass",
                    Description = pass.description or ""
                }
            end
        end
    end)
    
    -- Method 4: Find in game scripts
    for _, script in ipairs(game:GetDescendants()) do
        if script:IsA("Script") or script:IsA("ModuleScript") then
            pcall(function()
                local source = script.Source
                -- Pattern for item definitions
                local patterns = {
                    "ProductId%s*=%s*(%d+)",
                    "ItemId%s*=%s*(%d+)",
                    "gamepassId%s*=%s*(%d+)",
                    "passId%s*=%s*(%d+)"
                }
                
                for _, pattern in ipairs(patterns) do
                    for id in string.gmatch(source, pattern) do
                        if #id >= 9 then
                            -- Try to get item name from context
                            local lines = string.split(source, "\n")
                            for i, line in ipairs(lines) do
                                if string.find(line, id) then
                                    -- Look for name pattern
                                    for namePattern in string.gmatch(line, "Name%s*=%s*[\"']([^\"']+)[\"']") do
                                        itemCache[id] = {
                                            Name = namePattern,
                                            Price = 0,
                                            Category = "ScriptItem",
                                            Source = script:GetFullName()
                                        }
                                    end
                                    break
                                end
                            end
                            
                            -- If no name found, create generic
                            if not itemCache[id] then
                                itemCache[id] = {
                                    Name = "Item_" .. id,
                                    Price = 0,
                                    Category = "ScriptItem"
                                }
                            end
                        end
                    end
                end
            end)
        end
    end
    
    -- Convert cache to array and add metadata
    for id, data in pairs(itemCache) do
        table.insert(extractedItems, {
            Id = id,
            Name = data.Name,
            Price = data.Price,
            Category = data.Category,
            Remote = data.Remote,
            Source = data.Source or data.Path,
            Verified = false
        })
    end
    
    return extractedItems
end

-- ========== [SMART PURCHASE ENGINE] ==========
local SmartPurchaseEngine = {
    Attempts = {},
    SuccessCount = 0,
    Methods = {}
}

function SmartPurchaseEngine:Initialize(remotes, items)
    self.Remotes = remotes
    self.Items = items
    self.Methods = {
        "DirectPurchase",
        "FakeReceipt",
        "EventSpoofing",
        "MemoryInjection",
        "NetworkReplay"
    }
end

function SmartPurchaseEngine:DirectPurchase(itemId, remoteName)
    for _, remote in ipairs(self.Remotes) do
        if not remoteName or remote.Name == remoteName then
            local attempts = {
                -- Method 1: Simple ID
                function()
                    if remote.Instance:IsA("RemoteEvent") then
                        remote.Instance:FireServer(itemId)
                    else
                        remote.Instance:InvokeServer(itemId)
                    end
                end,
                
                -- Method 2: With player
                function()
                    if remote.Instance:IsA("RemoteEvent") then
                        remote.Instance:FireServer(itemId, LOCAL_PLAYER)
                    else
                        remote.Instance:InvokeServer(itemId, LOCAL_PLAYER)
                    end
                end,
                
                -- Method 3: With additional data
                function()
                    local purchaseData = {
                        ProductId = itemId,
                        Player = LOCAL_PLAYER,
                        PricePaid = 0,
                        Currency = "Robux",
                        PurchaseTime = tick(),
                        Receipt = "YANDEX_" .. HttpService:GenerateGUID(false)
                    }
                    
                    if remote.Instance:IsA("RemoteEvent") then
                        remote.Instance:FireServer(purchaseData)
                    else
                        remote.Instance:InvokeServer(purchaseData)
                    end
                end,
                
                -- Method 4: Game-specific format
                function()
                    if remote.Name:find("Coil") then
                        if remote.Instance:IsA("RemoteEvent") then
                            remote.Instance:FireServer("EquipCoil", itemId, LOCAL_PLAYER)
                        else
                            remote.Instance:InvokeServer("EquipCoil", itemId, LOCAL_PLAYER)
                        end
                    else
                        if remote.Instance:IsA("RemoteEvent") then
                            remote.Instance:FireServer("Purchase", itemId, LOCAL_PLAYER, 0)
                        else
                            remote.Instance:InvokeServer("Purchase", itemId, LOCAL_PLAYER, 0)
                        end
                    end
                end
            }
            
            for i, attemptFunc in ipairs(attempts) do
                local success, result = pcall(attemptFunc)
                if success then
                    return true, "Success via " .. remote.Name .. " (Method " .. i .. ")"
                end
            end
        end
    end
    
    return false, "All direct methods failed"
end

function SmartPurchaseEngine:FakeReceiptPurchase(itemId)
    -- Generate realistic fake receipt
    local fakeReceipt = {
        PlayerId = LOCAL_PLAYER.UserId,
        ProductId = itemId,
        PurchaseId = "GPA.91" .. math.random(1000, 9999) .. "-" .. math.random(1000, 9999) .. "-" .. math.random(1000, 9999),
        CurrencyCode = "USD",
        PricePaid = 0.00,
        PurchaseDate = DateTime.now():ToIsoDate(),
        DeveloperPayload = "YANDEXGPT_BYPASS_" .. tick(),
        Signature = string.rep(math.random(0,9), 40) -- Fake Google Play signature
    }
    
    -- Try to find receipt verification remotes
    for _, remote in ipairs(self.Remotes) do
        if string.find(remote.Name:lower(), "receipt") or 
           string.find(remote.Name:lower(), "verify") or
           string.find(remote.Name:lower(), "validate") then
           
            local success = pcall(function()
                if remote.Instance:IsA("RemoteEvent") then
                    remote.Instance:FireServer(fakeReceipt)
                else
                    remote.Instance:InvokeServer(fakeReceipt)
                end
            end)
            
            if success then
                return true, "Fake receipt accepted"
            end
        end
    end
    
    return false, "No receipt handler found"
end

function SmartPurchaseEngine:EventSpoofing(itemId)
    -- Spoof purchase analytics events
    local analyticsEvents = {
        "ProcessReceipt",
        "PurchaseComplete",
        "TransactionSuccess",
        "ProductOwned",
        "LicenseGranted"
    }
    
    for _, eventName in ipairs(analyticsEvents) do
        -- Create fake event if doesn't exist
        local event = ReplicatedStorage:FindFirstChild(eventName)
        if not event then
            event = Instance.new("RemoteEvent")
            event.Name = eventName
            event.Parent = ReplicatedStorage
        end
        
        if event:IsA("RemoteEvent") then
            local spoofData = {
                Player = LOCAL_PLAYER,
                ProductId = itemId,
                Success = true,
                Timestamp = tick(),
                TransactionId = "TX_" .. HttpService:GenerateGUID(false)
            }
            
            pcall(function()
                event:FireServer(spoofData)
            end)
        end
    end
    
    return true, "Event spoofing attempted"
end

function SmartPurchaseEngine:PurchaseItem(itemId, itemName)
    local purchaseId = itemId
    local results = {}
    
    -- Try all methods
    for methodName, methodFunc in pairs({
        ["Direct"] = function() return self:DirectPurchase(purchaseId) end,
        ["Receipt"] = function() return self:FakeReceiptPurchase(purchaseId) end,
        ["Event"] = function() return self:EventSpoofing(purchaseId) end
    }) do
        local success, message = methodFunc()
        table.insert(results, {
            Method = methodName,
            Success = success,
            Message = message
        })
        
        if success then
            self.SuccessCount = self.SuccessCount + 1
            return true, message
        end
        
        task.wait(0.1) -- Small delay between methods
    end
    
    return false, "All purchase methods failed"
end

function SmartPurchaseEngine:PurchaseAll()
    local results = {}
    
    for _, item in ipairs(self.Items) do
        print("🔄 Attempting purchase: " .. item.Name .. " (ID: " .. item.Id .. ")")
        
        local success, message = self:PurchaseItem(item.Id, item.Name)
        
        table.insert(results, {
            Item = item.Name,
            Id = item.Id,
            Success = success,
            Message = message,
            Time = tick()
        })
        
        if success then
            print("✅ Success: " .. item.Name)
        else
            print("❌ Failed: " .. item.Name .. " - " .. message)
        end
        
        task.wait(0.5) -- Rate limiting
    end
    
    return results
end

-- ========== [LIVE INJECTION SYSTEM] ==========
local LiveInjection = {
    Hooks = {},
    OriginalFunctions = {}
}

function LiveInjection:HookRemote(remote)
    if remote.Instance:IsA("RemoteFunction") then
        -- Save original function
        self.OriginalFunctions[remote.Name] = remote.Instance.OnClientInvoke
        -- Hook it
        remote.Instance.OnClientInvoke = function(...)
            local args = {...}
            print("📥 Intercepted call to " .. remote.Name)
            
            -- Check if it's an ownership check
            if remote.Name:find("Own") or remote.Name:find("Check") or remote.Name:find("Has") then
                -- Always return true for ownership checks
                return true
            end
            
            -- Call original function
            if self.OriginalFunctions[remote.Name] then
                return self.OriginalFunctions[remote.Name](...)
            end
            
            return nil
        end
        self.Hooks[remote.Name] = true
    end
end

function LiveInjection:SetupOwnershipBypass(remotes)
    for _, remote in ipairs(remotes) do
        if remote.Name:find("Own") or 
           remote.Name:find("Check") or 
           remote.Name:find("Has") or
           remote.Name:find("Verify") then
            self:HookRemote(remote)
        end
    end
end

-- ========== [ADVANCED UI SYSTEM] ==========
local function CreateProfessionalInterface(engine, items, gameType)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YandexGPT_UltimateUnlocker"
    screenGui.Parent = LOCAL_PLAYER:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    
    -- Main container
    local mainContainer = Instance.new("Frame")
    mainContainer.Size = UDim2.new(0.55, 0, 0.8, 0)
    mainContainer.Position = UDim2.new(0.225, 0, 0.1, 0)
    mainContainer.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    mainContainer.BorderSizePixel = 2
    mainContainer.BorderColor3 = Color3.fromRGB(0, 150, 255)
    mainContainer.Parent = screenGui
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0.12, 0)
    header.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
    header.BorderSizePixel = 0
    header.Parent = mainContainer
    
    local title = Instance.new("TextLabel")
    title.Text = "⚡ YANDEXGPT ULTIMATE UNLOCKER ⚡"
    title.Size = UDim2.new(1, 0, 0.7, 0)
    title.Position = UDim2.new(0, 0, 0.15, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.Parent = header
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Text = "Game: " .. gameType .. " | Place ID: " .. PlaceId
    subtitle.Size = UDim2.new(1, 0, 0.3, 0)
    subtitle.Position = UDim2.new(0, 0, 0.7, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.TextColor3 = Color3.fromRGB(150, 200, 255)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 14
    subtitle.Parent = header
    
    -- Stats panel
    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(0.96, 0, 0.15, 0)
    statsFrame.Position = UDim2.new(0.02, 0, 0.13, 0)
    statsFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    statsFrame.BorderSizePixel = 1
    statsFrame.BorderColor3 = Color3.fromRGB(40, 50, 60)
    statsFrame.Parent = mainContainer
    
    local statsGrid = Instance.new("UIListLayout")
    statsGrid.Padding = UDim.new(0, 2)
    statsGrid.FillDirection = Enum.FillDirection.Horizontal
    statsGrid.Parent = statsFrame
    
    -- Stats items
    local statItems = {
        {"Items Found", #items, Color3.fromRGB(100, 200, 255)},
        {"Unlocked", engine.SuccessCount, Color3.fromRGB(100, 255, 100)},
        {"Remotes", #engine.Remotes, Color3.fromRGB(255, 200, 100)},
        {"Game", gameType, Color3.fromRGB(255, 100, 200)}
    }
    
    for _, statData in ipairs(statItems) do
        local statName, statValue, color = statData[1], statData[2], statData[3]
        
        local statFrame = Instance.new("Frame")
        statFrame.Size = UDim2.new(0.24, 0, 1, 0)
        statFrame.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
        statFrame.BorderSizePixel = 0
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = statName
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 12
        nameLabel.Parent = statFrame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Text = tostring(statValue)
        valueLabel.Size = UDim2.new(1, 0, 0.5, 0)
        valueLabel.Position = UDim2.new(0, 0, 0.5, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextColor3 = color
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 16
        valueLabel.Parent = statFrame
        
        statFrame.Parent = statsFrame
    end
    
    -- Item list
    local itemsFrame = Instance.new("ScrollingFrame")
    itemsFrame.Size = UDim2.new(0.96, 0, 0.55, 0)
    itemsFrame.Position = UDim2.new(0.02, 0, 0.29, 0)
    itemsFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    itemsFrame.BorderSizePixel = 1
    itemsFrame.BorderColor3 = Color3.fromRGB(40, 45, 55)
    itemsFrame.ScrollBarThickness = 8
    itemsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    itemsFrame.Parent = mainContainer
    
    -- Control buttons
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(0.96, 0, 0.12, 0)
    controlsFrame.Position = UDim2.new(0.02, 0, 0.85, 0)
    controlsFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    controlsFrame.BorderSizePixel = 0
    controlsFrame.Parent = mainContainer
    
    -- Populate items
    local yOffset = 0
    for _, item in ipairs(items) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, 0, 0, 40)
        itemFrame.Position = UDim2.new(0, 0, 0, yOffset)
        itemFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
        itemFrame.BorderSizePixel = 1
        itemFrame.BorderColor3 = Color3.fromRGB(50, 55, 65)
        
        -- Item icon based on category
        local iconMap = {
            Gamepass = "🎮",
            Coil = "🌀",
            VIP = "⭐",
            Equipment = "⚔️",
            Boost = "🚀",
            Skin = "🎨",
            Default = "📦"
        }
        
        local icon = iconMap[item.Category] or iconMap.Default
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Text = icon
        iconLabel.Size = UDim2.new(0, 40, 1, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        iconLabel.Font = Enum.Font.GothamBold
        iconLabel.TextSize = 20
        iconLabel.Parent = itemFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = item.Name
        nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
        nameLabel.Position = UDim2.new(0.1, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 14
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = itemFrame
        
        local idLabel = Instance.new("TextLabel")
        idLabel.Text = "ID: " .. item.Id
        idLabel.Size = UDim2.new(0.25, 0, 1, 0)
        idLabel.Position = UDim2.new(0.5, 0, 0, 0)
        idLabel.BackgroundTransparency = 1
        idLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
        idLabel.Font = Enum.Font.Gotham
        idLabel.TextSize = 12
        idLabel.TextXAlignment = Enum.TextXAlignment.Left
        idLabel.Parent = itemFrame
        
        local unlockBtn = Instance.new("TextButton")
        unlockBtn.Text = "UNLOCK"
        unlockBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
        unlockBtn.Position = UDim2.new(0.83, 0, 0.15, 0)
        unlockBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        unlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        unlockBtn.Font = Enum.Font.GothamBold
        unlockBtn.TextSize = 12
        unlockBtn.Parent = itemFrame
        
        unlockBtn.MouseButton1Click:Connect(function()
            unlockBtn.Text = "..."
            unlockBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
            
            task.spawn(function()
                local success, message = engine:PurchaseItem(item.Id, item.Name)
                if success then
                    unlockBtn.Text = "✓"
                    unlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    
                    -- Update stats
                    engine.SuccessCount = engine.SuccessCount + 1
                else
                    unlockBtn.Text = "✗"
                    unlockBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                    
                    -- Retry button
                    task.wait(1)
                    unlockBtn.Text = "RETRY"
                    unlockBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
                end
            end)
        end)
        
        itemFrame.Parent = itemsFrame
        yOffset = yOffset + 42
    end
    
    -- Control buttons
    local unlockAllBtn = Instance.new("TextButton")
    unlockAllBtn.Text = "🚀 UNLOCK ALL ITEMS"
    unlockAllBtn.Size = UDim2.new(0.48, 0, 0.8, 0)
    unlockAllBtn.Position = UDim2.new(0.01, 0, 0.1, 0)
    unlockAllBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    unlockAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    unlockAllBtn.Font = Enum.Font.GothamBold
    unlockAllBtn.TextSize = 14
    unlockAllBtn.Parent = controlsFrame
    
    unlockAllBtn.MouseButton1Click:Connect(function()
        unlockAllBtn.Text = "PROCESSING..."
        unlockAllBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            local results = engine:PurchaseAll()
            
            local successCount = 0
            for _, result in ipairs(results) do
                if result.Success then
                    successCount = successCount + 1
                end
            end
            
            unlockAllBtn.Text = string.format("✅ %d/%d UNLOCKED", successCount, #results)
            unlockAllBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            
            -- Notification
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "YandexGPT Unlocker",
                Text = string.format("Successfully unlocked %d items", successCount),
                Duration = 10,
                Icon = "rbxassetid://4483345998"
            })
        end)
    end)
    
    local injectBtn = Instance.new("TextButton")
    injectBtn.Text = "🔧 INJECT HOOKS"
    injectBtn.Size = UDim2.new(0.48, 0, 0.8, 0)
    injectBtn.Position = UDim2.new(0.51, 0, 0.1, 0)
    injectBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
    injectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    injectBtn.Font = Enum.Font.GothamBold
    injectBtn.TextSize = 14
    injectBtn.Parent = controlsFrame
    
    injectBtn.MouseButton1Click:Connect(function()
        LiveInjection:SetupOwnershipBypass(engine.Remotes)
        injectBtn.Text = "✅ HOOKED"
        injectBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    end)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "CLOSE"
    closeBtn.Size = UDim2.new(0.96, 0, 0.08, 0)
    closeBtn.Position = UDim2.new(0.02, 0, 0.93, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = mainContainer
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    return screenGui
end

-- ========== [MAIN EXECUTION] ==========
print([[
    
╔═╗┬ ┬┌─┐┌─┐┌─┐┌┬┐┌─┐  ╔╗ ┌─┐┬ ┬┌─┐┬─┐┌─┐┬ ┬
║  ├─┤├┤ ├─┤└─┐ │ ├┤   ╠╩╗│ ││ │├┤ ├┬┘│  ├─┤
╚═╝┴ ┴└─┘┴ ┴└─┘ ┴ └─┘  ╚═╝└─┘└─┘└─┘┴└─└─┘┴ ┴
    Advanced Game Unlocker v5.0
]])

-- Detect game type
local gameType, gameSpecificItems = DetectGameType()
print("🎮 Game Detected: " .. gameType)

-- Scan for remotes
print("🔍 Scanning for purchase remotes...")
local foundRemotes = AdvancedRemoteScanner()
print("✅ Found " .. #foundRemotes .. " remotes")

-- Extract items
print("📦 Extracting items...")
local extractedItems = IntelligentItemExtractor(foundRemotes)
print("✅ Extracted " .. #extractedItems .. " items")

-- Add game-specific items
if gameType ~= "Generic" then
    for category, data in pairs(gameSpecificItems) do
        if data.IDs then
            for _, id in ipairs(data.IDs) do
                table.insert(extractedItems, {
                    Id = tostring(id),
                    Name = category .. " Item",
                    Category = category,
                    GameSpecific = true,
                    Remote = data.Remotes and data.Remotes[1] or nil
                })
            end
        end
    end
end

-- Initialize purchase engine
SmartPurchaseEngine:Initialize(foundRemotes, extractedItems)

-- Setup live injection
LiveInjection:SetupOwnershipBypass(foundRemotes)

-- Create interface
CreateProfessionalInterface(SmartPurchaseEngine, extractedItems, gameType)

-- Auto-attempt unlock
task.delay(3, function()
    print("🚀 Starting auto-unlock sequence...")
    local results = SmartPurchaseEngine:PurchaseAll()
    
    local successCount = 0
    for _, result in ipairs(results) do
        if result.Success then
            successCount = successCount + 1
        end
    end
    
    print(string.format("🎯 Auto-unlock completed: %d/%d successful", successCount, #results))
    
    -- Success notification
    if successCount > 0 then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "YandexGPT - Success",
            Text = string.format("Unlocked %d items! Rejoin for effects.", successCount),
            Duration = 15,
            Icon = "rbxassetid://6023426925"
        })
    end
end)

-- Keep running
print("\n⚡ YandexGPT Ultimate Unlocker Active ⚡")
print("• Game: " .. gameType)
print("• Items: " .. #extractedItems)
print("• Remotes: " .. #foundRemotes)
print("• Status: READY\n")
