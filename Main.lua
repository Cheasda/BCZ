local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera
local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
local CommF = Remotes:FindFirstChild("CommF_")
local CommE = Remotes:FindFirstChild("CommE")
local Data = Player:FindFirstChild("Data") or Player:WaitForChild("Data")
local Level = Data:FindFirstChild("Level")
local Fragments = Data:FindFirstChild("Fragments")
local Beli = Data:FindFirstChild("Beli")
local Gems = Data:FindFirstChild("Gems")
local Race = Data:FindFirstChild("Race")
local Fruit = Data:FindFirstChild("Fruit")
local Settings = {
    AutoFarm = false,
    AutoCollect = false,
    AutoRaid = false,
    AutoDungeon = false,
    AutoSeaBeast = false,
    AutoShip = false,
    AutoBring = false,
    AutoAttack = true,
    AutoShoot = false,
    FarmRadius = 100,
    BringDistance = 40,
    CombatMode = "Melee",
    SkillKeys = {"Z", "X", "C", "V", "F"},
    SkillCooldown = 0.5,
    ShowESP = false,
    ShowAimbot = false,
    SmoothMode = false,
    NoAimMobs = false,
    WalkSpeed = 16,
    JumpPower = 50,
    IgnoreErrors = true,
    FarmTool = "Melee",
    AutoBoss = false,
    AutoFruit = false,
    AutoStats = false,
    AutoStore = false,
}
local function IsAlive(Char)
    if not Char then return false end
    local Hum = Char:FindFirstChild("Humanoid")
    return Hum and Hum.Health > 0
end
local function GetDistance(Pos1, Pos2)
    return (Pos1 - Pos2).Magnitude
end
local function GetClosest(ObjectList, Position)
    local Closest = nil
    local ClosestDist = math.huge
    for _, Obj in ipairs(ObjectList) do
        if Obj and Obj:IsA("BasePart") then
            local Dist = GetDistance(Obj.Position, Position)
            if Dist < ClosestDist then
                ClosestDist = Dist
                Closest = Obj
            end
        end
    end
    return Closest
end
local function GetRoot(Char)
    return Char and Char:FindFirstChild("HumanoidRootPart")
end
local function GetHum(Char)
    return Char and Char:FindFirstChild("Humanoid")
end
local function GetTool()
    if not Character then return nil end
    for _, Tool in ipairs(Character:GetChildren()) do
        if Tool:IsA("Tool") then return Tool end
    end
    return nil
end
local function GetDistanceFromPlayer(Position)
    if typeof(Position) ~= "Vector3" then
        Position = Position.Position
    end
    return Player:DistanceFromCharacter(Position)
end
local function TableFind(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then return i end
    end
    return nil
end
local function TableClone(tbl)
    local new = {}
    for k, v in pairs(tbl) do
        new[k] = v
    end
    return new
end
local function StringSplit(str, sep)
    local parts = {}
    for part in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(parts, part)
    end
    return parts
end
local PlayerManager = {}
PlayerManager.__index = PlayerManager
function PlayerManager:GetPosition()
    local Root = GetRoot(Character)
    return Root and Root.Position or Vector3.new(0, 0, 0)
end
function PlayerManager:IsAlive()
    return IsAlive(Character)
end
function PlayerManager:GetDistance(Pos)
    return GetDistance(self:GetPosition(), Pos)
end
function PlayerManager:MoveTo(Position)
    if Character and Humanoid then
        Humanoid:MoveTo(Position)
    end
end
function PlayerManager:GetCharacter()
    return Character
end
function PlayerManager:GetHumanoid()
    return Humanoid
end
function PlayerManager:GetRoot()
    return RootPart
end
local EnemyManager = {}
EnemyManager.__index = EnemyManager
local EnemyCategories = {
    ["__CakePrince"] = {},
    ["__PirateRaid"] = {},
    ["__TyrantSkies"] = {},
    ["__Bones"] = {},
    ["__Elite"] = {},
    ["__Others"] = {},
    ["__Ectoplasm"] = {},
}
local EnemyMapping = {
    ["Deandre"] = "Elite",
    ["Diablo"] = "Elite",
    ["Urban"] = "Elite",
    ["Reborn Skeleton"] = "Bones",
    ["Living Zombie"] = "Bones",
    ["Demonic Soul"] = "Bones",
    ["Possessed Mummy"] = "Bones",
    ["Head Baker"] = "CakePrince",
    ["Baking Staff"] = "CakePrince",
    ["Cake Guard"] = "CakePrince",
    ["Cookie Crafter"] = "CakePrince",
    ["Sun-kissed Warrior"] = "TyrantSkies",
    ["Skull Slayer"] = "TyrantSkies",
    ["Isle Champion"] = "TyrantSkies",
    ["Serpent Hunter"] = "TyrantSkies",
    ["Ship Deckhand"] = "Ectoplasm",
    ["Ship Engineer"] = "Ectoplasm",
    ["Ship Officer"] = "Ectoplasm",
    ["Ship Steward"] = "Ectoplasm",
}
local BossData = {
    ["The Gorilla King"] = {Spawn = CFrame.new(-1128, 6, -451), LevelReq = 20, Island = "Jungle"},
    ["Chef"] = {Spawn = CFrame.new(-1131, 14, 4080), LevelReq = 55, Island = "Buggy"},
    ["Yeti"] = {Spawn = CFrame.new(1185, 106, -1518), LevelReq = 105, Island = "Snow"},
    ["Vice Admiral"] = {Spawn = CFrame.new(-4807, 21, 4360), LevelReq = 130, Island = "Marine"},
    ["Warden"] = {Spawn = CFrame.new(5230, 4, 749), LevelReq = 220, Island = "Impel Down"},
    ["Chief Warden"] = {Spawn = CFrame.new(5230, 4, 749), LevelReq = 230, Island = "Impel Down"},
    ["Swan"] = {Spawn = CFrame.new(5230, 4, 749), LevelReq = 240, Island = "Impel Down"},
    ["Magma Admiral"] = {Spawn = CFrame.new(-5694, 18, 8735), LevelReq = 350, Island = "Magma"},
    ["Fishman Lord"] = {Spawn = CFrame.new(61350, 31, 1095), LevelReq = 425, Island = "Fishman"},
    ["Wysper"] = {Spawn = CFrame.new(-7927, 5551, -637), LevelReq = 500, Island = "Sky"},
    ["Thunder God"] = {Spawn = CFrame.new(-7751, 5607, -2315), LevelReq = 575, Island = "Sky"},
    ["Cyborg"] = {Spawn = CFrame.new(6138, 10, 3939), LevelReq = 675, Island = "Fountain"},
    ["Diamond"] = {Spawn = CFrame.new(-1569, 199, -31), LevelReq = 750, Island = "Kingdom of Rose"},
    ["Jeremy"] = {Spawn = CFrame.new(2316, 449, 787), LevelReq = 850, Island = "Kingdom of Rose"},
    ["Orbitus"] = {Spawn = CFrame.new(-2086, 73, -4208), LevelReq = 925, Island = "Marine Fortress"},
    ["Smoke Admiral"] = {Spawn = CFrame.new(-5078, 24, -5352), LevelReq = 1150, Island = "Ice Side"},
    ["Awakened Ice Admiral"] = {Spawn = CFrame.new(6473, 297, -6944), LevelReq = 1400, Island = "Frost"},
    ["Tide Keeper"] = {Spawn = CFrame.new(-3711, 77, -11469), LevelReq = 1475, Island = "Forgotten"},
    ["Stone"] = {Spawn = CFrame.new(-1049, 40, 6791), LevelReq = 1550, Island = "Pirate Port"},
    ["Hydra Leader"] = {Spawn = CFrame.new(5836, 1019, -83), LevelReq = 1675, Island = "Venom Crew"},
    ["Kilo Admiral"] = {Spawn = CFrame.new(2904, 509, -7349), LevelReq = 1750, Island = "Marine Tree"},
    ["Captain Elephant"] = {Spawn = CFrame.new(-13393, 319, -8423), LevelReq = 1875, Island = "Deep Forest"},
    ["Beautiful Pirate"] = {Spawn = CFrame.new(5370, 22, -89), LevelReq = 1950, Island = "Deep Forest"},
    ["Cake Queen"] = {Spawn = CFrame.new(-710, 382, -11150), LevelReq = 2175, Island = "Ice Cream"},
}
local RaidBosses = {
    ["Ice Admiral"] = {Raid = "Ice Raid", LevelReq = 700, Fruit = "Ice"},
    ["Dark Beard"] = {Raid = "Dark Raid", LevelReq = 1000, Fruit = "Dark"},
    ["Flame Admiral"] = {Raid = "Flame Raid", LevelReq = 1300, Fruit = "Flame"},
    ["rip_indra"] = {Raid = "Indra Raid", LevelReq = 2000, Fruit = "Rumble"},
    ["rip_indra True Form"] = {Raid = "Indra True Form", LevelReq = 2500, Fruit = "None"},
}
local SeaBeastData = {
    ["Sea Beast"] = {LevelReq = 700, Drop = "Sea Beast Scale"},
    ["Rumbling Sea Beast"] = {LevelReq = 1000, Drop = "Rumbling Scale"},
    ["Terror Sea Beast"] = {LevelReq = 1500, Drop = "Terror Scale"},
    ["Abyssal Sea Beast"] = {LevelReq = 2000, Drop = "Abyssal Scale"},
}
function EnemyManager:GetEnemies(Radius)
    Radius = Radius or Settings.FarmRadius
    local Enemies = {}
    local Pos = PlayerManager:GetPosition()
    local EnemyFolder = Workspace:FindFirstChild("Enemies") or Workspace
    for _, Enemy in ipairs(EnemyFolder:GetChildren()) do
        if IsAlive(Enemy) then
            local Root = GetRoot(Enemy)
            if Root and GetDistance(Root.Position, Pos) <= Radius then
                table.insert(Enemies, Enemy)
            end
        end
    end
    return Enemies
end
function EnemyManager:GetClosest(Radius)
    local Enemies = self:GetEnemies(Radius)
    local Pos = PlayerManager:GetPosition()
    return GetClosest(Enemies, Pos)
end
function EnemyManager:IsBoss(Enemy)
    if Enemy:GetAttribute("IsBoss") then return true end
    if Enemy:GetAttribute("RaidBoss") then return true end
    local Hum = GetHum(Enemy)
    return Hum and Hum.MaxHealth > 1000
end
function EnemyManager:IsRaidBoss(Enemy)
    return Enemy:GetAttribute("RaidBoss") == true
end
function EnemyManager:GetBossLevel(BossName)
    local Boss = BossData[BossName]
    return Boss and Boss.LevelReq or nil
end
function EnemyManager:GetBossSpawn(BossName)
    local Boss = BossData[BossName]
    return Boss and Boss.Spawn or nil
end
function EnemyManager:GetAllBosses()
    return BossData
end
function EnemyManager:GetBossesByLevel(MinLevel, MaxLevel)
    local Result = {}
    for Name, Data in pairs(BossData) do
        if Data.LevelReq >= MinLevel and Data.LevelReq <= MaxLevel then
            table.insert(Result, {Name = Name, Data = Data})
        end
    end
    table.sort(Result, function(a, b) return a.Data.LevelReq < b.Data.LevelReq end)
    return Result
end
function EnemyManager:GetClosestBoss()
    local Enemies = self:GetEnemies(500)
    local Closest = nil
    local ClosestDist = math.huge
    local Pos = PlayerManager:GetPosition()
    for _, Enemy in ipairs(Enemies) do
        if self:IsBoss(Enemy) then
            local Root = GetRoot(Enemy)
            if Root then
                local Dist = GetDistance(Root.Position, Pos)
                if Dist < ClosestDist then
                    ClosestDist = Dist
                    Closest = Enemy
                end
            end
        end
    end
    return Closest
end
function EnemyManager:BringMobs(Enemy, Position, Distance)
    Distance = Distance or Settings.BringDistance
    local Root = GetRoot(Enemy)
    if not Root then return end
    local BV = Instance.new("BodyVelocity")
    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BV.P = 1000
    BV.Velocity = Vector3.new(0, 0, 0)
    BV.Parent = Root
    local PlayerPos = PlayerManager:GetPosition()
    local Count = 0
    while IsAlive(Enemy) and Enemy.Parent == Workspace.Enemies and Count < 50 do
        local TargetPos = Position and Position.Position or PlayerPos
        if GetDistance(Root.Position, TargetPos) > Distance then
            BV.Velocity = (TargetPos - Root.Position).Unit * 50
        else
            BV.Velocity = Vector3.new(0, 0, 0)
            break
        end
        task.wait(0.25)
        Count = Count + 1
    end
    BV:Destroy()
end
function EnemyManager:GetTagged(Tag)
    return EnemyCategories["__" .. Tag] or EnemyCategories.__Others[Tag]
end
function EnemyManager:GetEnemyByTag(Tag)
    local Enemies = self:GetTagged(Tag)
    if not Enemies then return nil end
    for _, Enemy in ipairs(Enemies) do
        if IsAlive(Enemy) then
            return Enemy
        end
    end
    return nil
end
function EnemyManager:GetClosestByTag(Tag)
    local Enemies = self:GetTagged(Tag)
    if not Enemies or #Enemies == 0 then return nil end
    local Pos = PlayerManager:GetPosition()
    local Closest = nil
    local ClosestDist = math.huge
    for _, Enemy in ipairs(Enemies) do
        if IsAlive(Enemy) then
            local Root = GetRoot(Enemy)
            if Root then
                local Dist = GetDistance(Root.Position, Pos)
                if Dist < ClosestDist then
                    ClosestDist = Dist
                    Closest = Enemy
                end
            end
        end
    end
    return Closest
end
local CollectionManager = {}
CollectionManager.__index = CollectionManager
function CollectionManager:GetChests(Radius)
    Radius = Radius or 50
    local Chests = {}
    local Pos = PlayerManager:GetPosition()
    for _, Obj in ipairs(Workspace:GetDescendants()) do
        if Obj:IsA("BasePart") and Obj:GetAttribute("IsChest") then
            if GetDistance(Obj.Position, Pos) <= Radius then
                table.insert(Chests, Obj)
            end
        end
    end
    return Chests
end
function CollectionManager:GetBerries(Radius)
    Radius = Radius or 50
    local Berries = {}
    local Pos = PlayerManager:GetPosition()
    for _, Obj in ipairs(Workspace:GetDescendants()) do
        if Obj:IsA("BasePart") and Obj:GetAttribute("IsBerry") then
            if GetDistance(Obj.Position, Pos) <= Radius then
                table.insert(Berries, Obj)
            end
        end
    end
    return Berries
end
function CollectionManager:CollectChest(Chest)
    if not Chest then return end
    VirtualInputManager:SendMouseButtonEvent(1, 0, 0, true, game)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(1, 0, 0, false, game)
end
function CollectionManager:GetClosestChest()
    local Chests = self:GetChests()
    local Pos = PlayerManager:GetPosition()
    return GetClosest(Chests, Pos)
end
function CollectionManager:GetClosestBerry()
    local Berries = self:GetBerries()
    local Pos = PlayerManager:GetPosition()
    return GetClosest(Berries, Pos)
end
local FruitData = {
    [15124425041] = "Rocket",
    [15123685330] = "Spin",
    [15123613404] = "Blade",
    [15123689268] = "Spring",
    [15123595806] = "Bomb",
    [15123677932] = "Smoke",
    [15124220207] = "Spike",
    [121545956771325] = "Flame",
    [15123673019] = "Sand",
    [15123618591] = "Dark",
    [77885466312115] = "Eagle",
    [15112600534] = "Diamond",
    [15123640714] = "Light",
    [15123668008] = "Rubber",
    [15123662036] = "Ghost",
    [15123645682] = "Magma",
    [15123606541] = "Quake",
    [15123643097] = "Love",
    [15123681598] = "Spider",
    [116828771482820] = "Creation",
    [15123679712] = "Sound",
    [15123654553] = "Phoenix",
    [15123656798] = "Portal",
    [15123670514] = "Rumble",
    [15123652069] = "Pain",
    [15123587371] = "Blizzard",
    [15123633312] = "Gravity",
    [15123648309] = "Mammoth",
    [15694681122] = "T-Rex",
    [15123624401] = "Dough",
    [15123675904] = "Shadow",
    [10773719142] = "Venom",
    [15123616275] = "Control",
    [118054805452821] = "Gas",
    [11911905519] = "Spirit",
    [15123638064] = "Leopard",
    [115276580506154] = "Yeti",
    [15487764876] = "Kitsune",
    [95749033139458] = "Dragon East",
}
FruitManager = {}
FruitManager.__index = FruitManager
FruitManager.RealFruitsName = {}
FruitManager.RealFruitsId = {}
function FruitManager:GetRealFruitName(FruitObj, ReturnId)
    if FruitObj.Name ~= "Fruit " then
        return FruitObj.Name
    end
    if FruitManager.RealFruitsName[FruitObj] then
        return ReturnId and FruitManager.RealFruitsId[FruitObj] or FruitManager.RealFruitsName[FruitObj]
    end
    local FruitPart = FruitObj:FindFirstChild("Fruit")
    if FruitPart then
        local MeshId = FruitPart:IsA("MeshPart") and FruitPart.MeshId or FruitPart.AnimationId
        local Id = tonumber(MeshId:match("(%d+)"))
        local Name = FruitData[Id] or "???-???"
        FruitManager.RealFruitsName[FruitObj] = Name
        FruitManager.RealFruitsId[FruitObj] = MeshId
        return ReturnId and MeshId or Name
    end
    return ReturnId and "rbxassetid://0" or "???-???"
end
function FruitManager:FindFruits(Radius)
    Radius = Radius or 500
    local Fruits = {}
    local Pos = PlayerManager:GetPosition()
    for _, Obj in ipairs(Workspace:GetDescendants()) do
        if Obj:IsA("Model") and Obj.Name == "Fruit " then
            local Name = self:GetRealFruitName(Obj)
            local Dist = GetDistance(Obj:GetPivot().Position, Pos)
            if Dist <= Radius then
                table.insert(Fruits, {Name = Name, Object = Obj, Distance = Dist})
            end
        end
    end
    table.sort(Fruits, function(a, b) return a.Distance < b.Distance end)
    return Fruits
end
function FruitManager:GetClosestFruit()
    local Fruits = self:FindFruits()
    return Fruits[1]
end
local ShopManager = {}
ShopManager.__index = ShopManager
local ShopItems = {
    ["Frags"] = {
        {"Race Reroll", {"BlackbeardReward", "Reroll", "2"}},
        {"Reset Stats", {"BlackbeardReward", "Refund", "2"}},
    },
    ["Fighting Style"] = {
        {"Buy Black Leg", {"BuyBlackLeg"}},
        {"Buy Electro", {"BuyElectro"}},
        {"Buy Fishman Karate", {"BuyFishmanKarate"}},
        {"Buy Dragon Claw", {"BlackbeardReward", "DragonClaw", "2"}},
        {"Buy Superhuman", {"BuySuperhuman"}},
        {"Buy Death Step", {"BuyDeathStep"}},
        {"Buy Sharkman Karate", {"BuySharkmanKarate"}},
        {"Buy Electric Claw", {"BuyElectricClaw"}},
        {"Buy Dragon Talon", {"BuyDragonTalon"}},
        {"Buy GodHuman", {"BuyGodhuman"}},
        {"Buy Sanguine Art", {"BuySanguineArt"}},
    },
    ["Ability Teacher"] = {
        {"Buy Geppo", {"BuyHaki", "Geppo"}},
        {"Buy Buso", {"BuyHaki", "Buso"}},
        {"Buy Soru", {"BuyHaki", "Soru"}},
        {"Buy Ken", {"KenTalk", "Buy"}},
    },
    ["Sword"] = {
        {"Buy Katana", {"BuyItem", "Katana"}},
        {"Buy Cutlass", {"BuyItem", "Cutlass"}},
        {"Buy Dual Katana", {"BuyItem", "Dual Katana"}},
        {"Buy Iron Mace", {"BuyItem", "Iron Mace"}},
        {"Buy Triple Katana", {"BuyItem", "Triple Katana"}},
        {"Buy Pipe", {"BuyItem", "Pipe"}},
        {"Buy Dual-Headed Blade", {"BuyItem", "Dual-Headed Blade"}},
        {"Buy Soul Cane", {"BuyItem", "Soul Cane"}},
        {"Buy Bisento", {"BuyItem", "Bisento"}},
    },
    ["Gun"] = {
        {"Buy Musket", {"BuyItem", "Musket"}},
        {"Buy Slingshot", {"BuyItem", "Slingshot"}},
        {"Buy Flintlock", {"BuyItem", "Flintlock"}},
        {"Buy Refined Slingshot", {"BuyItem", "Refined Slingshot"}},
        {"Buy Dual Flintlock", {"BuyItem", "Dual Flintlock"}},
        {"Buy Cannon", {"BuyItem", "Cannon"}},
        {"Buy Kabucha", {"BlackbeardReward", "Slingshot", "2"}},
    },
    ["Accessories"] = {
        {"Buy Black Cape", {"BuyItem", "Black Cape"}},
        {"Buy Swordsman Hat", {"BuyItem", "Swordsman Hat"}},
        {"Buy Tomoe Ring", {"BuyItem", "Tomoe Ring"}},
    },
    ["Race"] = {
        {"Ghoul Race", {"Ectoplasm", "Change", 4}},
        {"Cyborg Race", {"CyborgTrainer", "Buy"}},
    },
}
function ShopManager:Buy(ShopCategory, ItemName)
    if not CommF then return false end
    local Category = ShopItems[ShopCategory]
    if not Category then return false end
    for _, Item in ipairs(Category) do
        if Item[1] == ItemName then
            local Args = Item[2]
            pcall(function()
                CommF:InvokeServer(unpack(Args))
            end)
            return true
        end
    end
    return false
end
function ShopManager:GetShopItems()
    return ShopItems
end
local InventoryManager = {}
InventoryManager.__index = InventoryManager
InventoryManager.Items = {}
InventoryManager.Unlocked = {}
InventoryManager.Mastery = {}
InventoryManager.Count = {}
InventoryManager.MasteryRequirements = {}
InventoryManager.Loaded = false
function InventoryManager:Load()
    if CommF then
        local Data = CommF:InvokeServer("getInventory")
        if type(Data) == "table" then
            for _, Item in ipairs(Data) do
                self.Items[Item.Name] = Item
                self.Unlocked[Item.Name] = true
                if Item.Count then self.Count[Item.Name] = Item.Count end
                if Item.Mastery then self.Mastery[Item.Name] = Item.Mastery end
                if Item.MasteryRequirements then 
                    self.MasteryRequirements[Item.Name] = Item.MasteryRequirements 
                end
            end
            self.Loaded = true
        end
    end
end
function InventoryManager:GetItem(ItemName)
    return self.Items[ItemName]
end
function InventoryManager:IsUnlocked(ItemName)
    return self.Unlocked[ItemName] or false
end
function InventoryManager:GetMastery(ItemName)
    return self.Mastery[ItemName] or 0
end
function InventoryManager:GetCount(ItemName)
    return self.Count[ItemName] or 0
end

local CombatSystem = {}
CombatSystem.__index = CombatSystem
local WeaponTypes = {
    ["Blox Fruit"] = 35,
    ["Melee"] = 40,
    ["Sword"] = 40,
    ["Gun"] = 200,
}
local WeaponMultipliers = {
    ["Dual Flintlock"] = 2,
}
local WeaponRanges = {
    ["Dragonstorm"] = 300,
}
local WeaponModes = {
    ["Skull Guitar"] = "TAP",
    ["Bazooka"] = "Position",
    ["Cannon"] = "Position",
    ["Dragonstorm"] = "Overheat",
}
function CombatSystem:GetTool()
    if not Character then return nil end
    for _, Tool in ipairs(Character:GetChildren()) do
        if Tool:IsA("Tool") then return Tool end
    end
    return nil
end
function CombatSystem:EquipTool(ToolName)
    local Backpack = Player:FindFirstChild("Backpack")
    if not Backpack then return false end
    local Tool = Backpack:FindFirstChild(ToolName)
    if Tool and Humanoid then
        Humanoid:EquipTool(Tool)
        return true
    end
    return false
end
function CombatSystem:Attack()
    VirtualInputManager:SendMouseButtonEvent(1, 0, 0, true, game)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(1, 0, 0, false, game)
end
function CombatSystem:UseSkill(Key)
    VirtualInputManager:SendKeyEvent(true, Key, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Key, false, game)
end
function CombatSystem:UseSkills(Target, Skills)
    if GetDistanceFromPlayer(Target) >= 60 then return end
    local Tool = self:GetTool()
    if not Tool then return end
    local Mastery = Tool:GetAttribute("Level") or 0
    local Requirements = Tool:GetAttribute("MasteryRequirements") or {}
    for Skill, Enabled in pairs(Skills) do
        if Enabled then
            local Req = Requirements[Skill]
            if Req and Mastery >= Req then
                local LastUsed = Settings.SkillCooldowns and Settings.SkillCooldowns[Skill] or 0
                if tick() - LastUsed >= Settings.SkillCooldown then
                    self:UseSkill(Skill)
                    if not Settings.SkillCooldowns then Settings.SkillCooldowns = {} end
                    Settings.SkillCooldowns[Skill] = tick()
                end
            end
        end
    end
end
function CombatSystem:GetWeaponRange()
    local Tool = self:GetTool()
    if not Tool then return 10 end
    return Tool:GetAttribute("Range") or 10
end
function CombatSystem:GetWeaponType()
    local Tool = self:GetTool()
    if not Tool then return "Melee" end
    return Tool.ToolTip or "Melee"
end
function CombatSystem:CanAttack()
    local Tool = self:GetTool()
    if not Tool then return false end
    local Cooldown = Tool:FindFirstChild("Cooldown")
    if Cooldown and Cooldown.Value > 0 then
        return false
    end
    return true
end
function CombatSystem:Shoot(Target)
    local Tool = self:GetTool()
    if not Tool or Tool.ToolTip ~= "Gun" then return end
    local Mode = WeaponModes[Tool.Name] or "Normal"
    local Position = Target.Position
    if Mode == "Overheat" then
        while IsAlive(Character) and IsAlive(Target) and Tool.Parent == Character do
            self:ShootInTarget(Position)
            task.wait()
            if GetDistanceFromPlayer(Position) > 300 then break end
        end
    elseif Mode == "Normal" then
        local Shots = WeaponMultipliers[Tool.Name] or 1
        for _ = 1, Shots do
            self:ShootInTarget(Position)
        end
    else
        self:ShootInTarget(Position)
    end
end
function CombatSystem:ShootInTarget(Position)
    local Tool = self:GetTool()
    if not Tool or Tool.ToolTip ~= "Gun" then return end
    local Remote = Tool:FindFirstChild("RemoteEvent")
    if Remote then
        Remote:FireServer("TAP", Position)
    else
        local ShootRemote = Remotes:FindFirstChild("ShootGunEvent")
        if ShootRemote then
            ShootRemote:FireServer(Position, {Position})
        end
    end
end
local FarmSystem = {}
FarmSystem.__index = FarmSystem
function FarmSystem:AutoFarm()
    while Settings.AutoFarm and PlayerManager:IsAlive() do
        local Target = EnemyManager:GetClosest(Settings.FarmRadius)
        if Target then
            local Root = GetRoot(Target)
            if Root then
                PlayerManager:MoveTo(Root.Position)
                local Dist = GetDistance(Root.Position, PlayerManager:GetPosition())
                local WeaponRange = CombatSystem:GetWeaponRange()
                if Dist <= WeaponRange then
                    if Settings.AutoAttack then
                        CombatSystem:Attack()
                    end
                    if Settings.SkillKeys then
                        CombatSystem:UseSkills(Target, Settings.SkillKeys)
                    end
                end
                if Settings.AutoBring and Dist > Settings.BringDistance then
                    EnemyManager:BringMobs(Target, PlayerManager:GetPosition())
                end
            end
        else
            task.wait(0.5)
        end
        task.wait()
    end
end
function FarmSystem:AutoBoss()
    while Settings.AutoBoss and PlayerManager:IsAlive() do
        local Target = EnemyManager:GetClosestBoss()
        if Target then
            local Root = GetRoot(Target)
            if Root then
                PlayerManager:MoveTo(Root.Position)
                local Dist = GetDistance(Root.Position, PlayerManager:GetPosition())
                local WeaponRange = CombatSystem:GetWeaponRange()
                if Dist <= WeaponRange then
                    if Settings.AutoAttack then
                        CombatSystem:Attack()
                    end
                    if Settings.SkillKeys then
                        CombatSystem:UseSkills(Target, Settings.SkillKeys)
                    end
                end
                if Settings.AutoBring and Dist > Settings.BringDistance then
                    EnemyManager:BringMobs(Target, PlayerManager:GetPosition())
                end
            end
        else
            task.wait(1)
        end
        task.wait()
    end
end
function FarmSystem:AutoCollect()
    while Settings.AutoCollect and PlayerManager:IsAlive() do
        local Chests = CollectionManager:GetChests(50)
        for _, Chest in ipairs(Chests) do
            local Dist = GetDistance(Chest.Position, PlayerManager:GetPosition())
            if Dist <= 5 then
                CollectionManager:CollectChest(Chest)
            else
                PlayerManager:MoveTo(Chest.Position)
            end
        end
        local Berries = CollectionManager:GetBerries(50)
        for _, Berry in ipairs(Berries) do
            local Dist = GetDistance(Berry.Position, PlayerManager:GetPosition())
            if Dist <= 5 then
                Berry:Destroy()
            else
                PlayerManager:MoveTo(Berry.Position)
            end
        end
        task.wait(0.5)
    end
end
function FarmSystem:AutoRaid()
    while Settings.AutoRaid and PlayerManager:IsAlive() do
        local RaidIsland = nil
        local Locations = Workspace:FindFirstChild("_WorldOrigin")
        if Locations then
            Locations = Locations:FindFirstChild("Locations")
            if Locations then
                for i = 5, 1, -1 do
                    local Island = Locations:FindFirstChild("Island " .. i)
                    if Island and GetDistanceFromPlayer(Island.Position) < 3500 then
                        RaidIsland = Island
                        break
                    end
                end
            end
        end
        if not RaidIsland then
            task.wait(1)
        end
        local Enemies = EnemyManager:GetEnemies(200)
        for _, Enemy in ipairs(Enemies) do
            if Enemy:GetAttribute("RaidBoss") or Enemy.Name:find("Raid") then
                local Root = GetRoot(Enemy)
                if Root then
                    PlayerManager:MoveTo(Root.Position)
                    if GetDistance(Root.Position, PlayerManager:GetPosition()) <= 10 then
                        CombatSystem:Attack()
                    end
                end
            end
        end
        task.wait()
    end
end
function FarmSystem:AutoDungeon()
    while Settings.AutoDungeon and PlayerManager:IsAlive() do
        local Enemies = EnemyManager:GetEnemies(200)
        for _, Enemy in ipairs(Enemies) do
            if Enemy:GetAttribute("Dungeon") or Enemy.Name:find("Dungeon") then
                local Root = GetRoot(Enemy)
                if Root then
                    PlayerManager:MoveTo(Root.Position)
                    if GetDistance(Root.Position, PlayerManager:GetPosition()) <= 10 then
                        CombatSystem:Attack()
                    end
                end
            end
        end
        task.wait()
    end
end
function FarmSystem:AutoSeaBeast()
    while Settings.AutoSeaBeast and PlayerManager:IsAlive() do
        local SeaBeasts = Workspace:FindFirstChild("SeaBeasts")
        if SeaBeasts then
            for _, Beast in ipairs(SeaBeasts:GetChildren()) do
                if IsAlive(Beast) then
                    local Root = GetRoot(Beast)
                    if Root then
                        PlayerManager:MoveTo(Root.Position)
                        if GetDistance(Root.Position, PlayerManager:GetPosition()) <= 50 then
                            CombatSystem:Attack()
                        end
                    end
                end
            end
        end
        task.wait()
    end
end
function FarmSystem:AutoShip()
    while Settings.AutoShip and PlayerManager:IsAlive() do
        local Ships = Workspace:FindFirstChild("Boats")
        if Ships then
            for _, Ship in ipairs(Ships:GetChildren()) do
                if Ship:IsA("Model") and Ship:FindFirstChild("Humanoid") then
                    local Root = GetRoot(Ship)
                    if Root then
                        PlayerManager:MoveTo(Root.Position)
                        if GetDistance(Root.Position, PlayerManager:GetPosition()) <= 20 then
                            CombatSystem:Attack()
                        end
                    end
                end
            end
        end
        task.wait()
    end
end
function FarmSystem:AutoFruit()
    while Settings.AutoFruit and PlayerManager:IsAlive() do
        local Fruit = FruitManager:GetClosestFruit()
        if Fruit then
            local Dist = Fruit.Distance
            if Dist <= 10 then
                CollectionManager:CollectChest(Fruit.Object)
            else
                PlayerManager:MoveTo(Fruit.Object:GetPivot().Position)
            end
        end
        task.wait(0.5)
    end
end
function FarmSystem:AutoStore()
    while Settings.AutoStore and PlayerManager:IsAlive() do
        if CommF then
            pcall(function()
                CommF:InvokeServer("Store", "Fruits")
                CommF:InvokeServer("Store", "Materials")
            end)
        end
        task.wait(60)
    end
end
function FarmSystem:AutoStats()
    while Settings.AutoStats and PlayerManager:IsAlive() do
        if Level then
            local CurrentLevel = Level.Value
            if CurrentLevel <= 50 then
                if CommF then
                    pcall(function()
                        CommF:InvokeServer("AddStat", "Melee")
                    end)
                end
            elseif CurrentLevel <= 200 then
                if CommF then
                    pcall(function()
                        CommF:InvokeServer("AddStat", "Defense")
                    end)
                end
            elseif CurrentLevel <= 500 then
                if CommF then
                    pcall(function()
                        CommF:InvokeServer("AddStat", "Sword")
                    end)
                end
            elseif CurrentLevel <= 1000 then
                if CommF then
                    pcall(function()
                        CommF:InvokeServer("AddStat", "Gun")
                    end)
                end
            else
                if CommF then
                    pcall(function()
                        CommF:InvokeServer("AddStat", "Fruit")
                    end)
                end
            end
        end
        task.wait(5)
    end
end
local TeleportSystem = {}
TeleportSystem.__index = TeleportSystem
function TeleportSystem:FindRemotes()
    local Remotes = {}
    for _, Obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if Obj:IsA("RemoteEvent") or Obj:IsA("RemoteFunction") then
            local Name = string.lower(Obj.Name)
            if Name:find("teleport") or Name:find("travel") or Name:find("goto") or Name:find("commf") then
                table.insert(Remotes, Obj)
            end
        end
    end
    return Remotes
end
function TeleportSystem:Teleport(Location)
    local Remotes = self:FindRemotes()
    for _, Remote in ipairs(Remotes) do
        pcall(function()
            if Remote:IsA("RemoteFunction") then
                Remote:InvokeServer(Location)
            elseif Remote:IsA("RemoteEvent") then
                Remote:FireServer(Location)
            end
        end)
    end
end
function TeleportSystem:TeleportToIsland(IslandName)
    if CommF then
        pcall(function()
            CommF:InvokeServer("Travel", IslandName)
        end)
    end
    self:Teleport(IslandName)
end
function TeleportSystem:TeleportToBoss(BossName)
    local Boss = BossData[BossName]
    if Boss and Boss.Spawn then
        self:Teleport(Boss.Spawn.Position)
    end
end
function TeleportSystem:TeleportToNPC(NPCName)
    self:Teleport(NPCName)
end
function TeleportSystem:RejoinServer()
    if TeleportService then
        pcall(function()
            TeleportService:Teleport(game.PlaceId, Player)
        end)
    end
end
function TeleportSystem:ServerHop(MaxPlayers, Region)
    MaxPlayers = MaxPlayers or 8
    Region = Region or "Singapore"
    local ServerBrowser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
    if not ServerBrowser then return end
    local Invoke = ServerBrowser:FindFirstChild("InvokeServer")
    if not Invoke then return end
    local CurrentJobId = game.JobId
    local Page = 1
    for _ = 1, 100 do
        task.delay(_ / 50, function()
            local Success, Data = pcall(function()
                return Invoke:InvokeServer(Page)
            end)
            if not Success or type(Data) ~= "table" then return end
            Page = Page + 1
            local BestCount = MaxPlayers
            local BestJobId = nil
            for _, Server in ipairs(Data) do
                if Server[1] ~= CurrentJobId and Server[2].Count <= BestCount then
                    BestCount = Server[2].Count
                    BestJobId = Server[1]
                end
            end
            if BestJobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, BestJobId, Player)
            end
        end)
    end
end
local ESP = {}
ESP.__index = ESP
local ESPObjects = {}
function ESP:CreateESP(Obj, Color)
    if not Settings.ShowESP then return end
    local Billboard = Instance.new("BillboardGui")
    Billboard.Size = UDim2.new(0, 200, 0, 50)
    Billboard.AlwaysOnTop = true
    Billboard.MaxDistance = 500
    Billboard.Parent = Obj
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundTransparency = 0.5
    Frame.BackgroundColor3 = Color or Color3.fromRGB(255, 0, 0)
    Frame.Parent = Billboard
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    NameLabel.Position = UDim2.new(0, 0, 0.5, 0)
    NameLabel.Text = Obj.Name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 14
    NameLabel.Parent = Frame
    local HealthBar = Instance.new("Frame")
    HealthBar.Size = UDim2.new(1, 0, 0.3, 0)
    HealthBar.Position = UDim2.new(0, 0, 0.7, 0)
    HealthBar.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    HealthBar.BackgroundTransparency = 0.3
    HealthBar.Parent = Frame
    local HealthFill = Instance.new("Frame")
    HealthFill.Size = UDim2.new(1, 0, 1, 0)
    HealthFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    HealthFill.BackgroundTransparency = 0
    HealthFill.Parent = HealthBar
    table.insert(ESPObjects, {Obj = Obj, Gui = Billboard, Health = HealthFill})
end
function ESP:Clear()
    for _, Obj in ipairs(ESPObjects) do
        if Obj.Gui then
            Obj.Gui:Destroy()
        end
    end
    table.clear(ESPObjects)
end
function ESP:Update()
    if not Settings.ShowESP then
        self:Clear()
        return
    end
    local Enemies = EnemyManager:GetEnemies(500)
    local Existing = {}
    for _, Obj in ipairs(ESPObjects) do
        Existing[Obj.Obj] = true
    end
    for _, Enemy in ipairs(Enemies) do
        if not Existing[Enemy] then
            local Color = EnemyManager:IsBoss(Enemy) and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 0)
            self:CreateESP(Enemy, Color)
        end
    end
end
local Aimbot = {}
Aimbot.__index = Aimbot
local AimTarget = nil
local AimTargetTime = 0
function Aimbot:GetTarget()
    if not Settings.ShowAimbot then return nil end
    if AimTarget and IsAlive(AimTarget) and tick() - AimTargetTime < 2 then
        return AimTarget
    end
    local Target = EnemyManager:GetClosest(500)
    if Target then
        AimTarget = Target
        AimTargetTime = tick()
        return Target
    end
    return nil
end
function Aimbot:GetTargetPosition()
    local Target = self:GetTarget()
    if not Target then return nil end
    local Root = GetRoot(Target)
    if not Root then return nil end
    return Root.Position
end
function Aimbot:GetClosestHitbox(Target)
    if not Target then return nil end
    local Hitboxes = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}
    local Pos = PlayerManager:GetPosition()
    local Closest = nil
    local ClosestDist = math.huge
    for _, Hitbox in ipairs(Hitboxes) do
        local Part = Target:FindFirstChild(Hitbox)
        if Part and Part:IsA("BasePart") then
            local Dist = GetDistance(Part.Position, Pos)
            if Dist < ClosestDist then
                ClosestDist = Dist
                Closest = Part
            end
        end
    end
    return Closest
end
local SilentAim = {}
SilentAim.__index = SilentAim
SilentAim.Enabled = true
function SilentAim:Setup()
    if not self.Enabled then return end
    if CommF then
        local OldInvoke = CommF.InvokeServer
        CommF.InvokeServer = function(self, ...)
            local Args = {...}
            for i, Arg in ipairs(Args) do
                if typeof(Arg) == "Vector3" then
                    local Target = Aimbot:GetTarget()
                    if Target then
                        local Hitbox = Aimbot:GetClosestHitbox(Target)
                        if Hitbox then
                            Args[i] = Hitbox.Position
                        end
                    end
                    break
                end
            end
            return OldInvoke(self, unpack(Args))
        end
    end
    if CommE then
        local OldFire = CommE.FireServer
        CommE.FireServer = function(self, ...)
            local Args = {...}
            for i, Arg in ipairs(Args) do
                if typeof(Arg) == "Vector3" then
                    local Target = Aimbot:GetTarget()
                    if Target then
                        local Hitbox = Aimbot:GetClosestHitbox(Target)
                        if Hitbox then
                            Args[i] = Hitbox.Position
                        end
                    end
                    break
                end
            end
            return OldFire(self, unpack(Args))
        end
    end
end
local WalkSpeedBypass = {}
WalkSpeedBypass.__index = WalkSpeedBypass
WalkSpeedBypass.Enabled = true
function WalkSpeedBypass:Setup()
    if not self.Enabled then return end
    local OldIndex = getmetatable(game).__index
    local OldNewIndex = getmetatable(game).__newindex
    hookmetamethod(game, "__index", function(Obj, Key)
        if Obj.ClassName == "Humanoid" and Key == "WalkSpeed" then
            return Settings.WalkSpeed
        end
        return OldIndex(Obj, Key)
    end)
    hookmetamethod(game, "__newindex", function(Obj, Key, Value)
        if Obj.ClassName == "Humanoid" and Key == "WalkSpeed" then
            return
        end
        return OldNewIndex(Obj, Key, Value)
    end)
end
local function AntiKick()
    local OldNamecall
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local Method = getnamecallmethod()
        if Method == "Kick" then
            return
        end
        return OldNamecall(self, ...)
    end)
end
local function AntiBan()
    if syn and syn.crypt then
        pcall(function()
            syn.crypt.custom_encryption = function() end
        end)
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MyHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 450)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "My Hub v2.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 1, 0)
CloseButton.Position = UDim2.new(1, -35, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundTransparency = 1
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 35, 1, 0)
MinimizeButton.Position = UDim2.new(1, -70, 0, 0)
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18
MinimizeButton.Parent = TitleBar
local Minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        MainFrame.Size = UDim2.new(0, 550, 0, 35)
        MainFrame.Position = UDim2.new(0.5, -275, 0.5, -17.5)
    else
        MainFrame.Size = UDim2.new(0, 550, 0, 450)
        MainFrame.Position = UDim2.new(0.5, -275, 0.5, -225)
    end
end)
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0, 130, 1, -35)
TabFrame.Position = UDim2.new(0, 0, 0, 35)
TabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame
local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 10)
TabCorner.Parent = TabFrame
local TabScrolling = Instance.new("ScrollingFrame")
TabScrolling.Size = UDim2.new(1, 0, 1, 0)
TabScrolling.BackgroundTransparency = 1
TabScrolling.ScrollBarThickness = 3
TabScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
TabScrolling.Parent = TabFrame
local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 5)
TabLayout.Parent = TabScrolling
local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 10)
TabPadding.PaddingBottom = UDim.new(0, 10)
TabPadding.PaddingLeft = UDim.new(0, 10)
TabPadding.PaddingRight = UDim.new(0, 10)
TabPadding.Parent = TabScrolling
local TabButtons = {}
local TabContents = {}
local CurrentTab = nil
local function CreateTab(Name)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.Text = Name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.BorderSizePixel = 0
    Button.Parent = TabScrolling
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -130, 1, -35)
    Content.Position = UDim2.new(1, 0, 0, 35)
    Content.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 3
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.Visible = false
    Content.Parent = MainFrame
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 10)
    ContentCorner.Parent = Content
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 10)
    ContentPadding.PaddingBottom = UDim.new(0, 10)
    ContentPadding.PaddingLeft = UDim.new(0, 10)
    ContentPadding.PaddingRight = UDim.new(0, 10)
    ContentPadding.Parent = Content
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 5)
    ContentLayout.Parent = Content
    table.insert(TabButtons, Button)
    table.insert(TabContents, Content)
    if #TabButtons == 1 then
        Content.Visible = true
        Button.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        CurrentTab = Content
    end
    Button.MouseButton1Click:Connect(function()
        for i, Btn in ipairs(TabButtons) do
            Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            TabContents[i].Visible = false
        end
        Button.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        Content.Visible = true
        CurrentTab = Content
    end)
    return Content
end
local function CreateToggle(Parent, Label, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Parent
    local LabelText = Instance.new("TextLabel")
    LabelText.Size = UDim2.new(0.7, 0, 1, 0)
    LabelText.Text = Label
    LabelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LabelText.BackgroundTransparency = 1
    LabelText.Font = Enum.Font.Gotham
    LabelText.TextSize = 14
    LabelText.TextXAlignment = Enum.TextXAlignment.Left
    LabelText.Parent = Frame
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 60, 0, 28)
    Toggle.Position = UDim2.new(1, -65, 0.5, -14)
    Toggle.Text = Default and "ON" or "OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.BackgroundColor3 = Default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.TextSize = 12
    Toggle.BorderSizePixel = 0
    Toggle.Parent = Frame
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 5)
    ToggleCorner.Parent = Toggle
    local State = Default or false
    Toggle.MouseButton1Click:Connect(function()
        State = not State
        Toggle.Text = State and "ON" or "OFF"
        Toggle.BackgroundColor3 = State and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        if Callback then Callback(State) end
    end)
    return Toggle
end
local function CreateSlider(Parent, Label, Min, Max, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 55)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Parent
    local LabelText = Instance.new("TextLabel")
    LabelText.Size = UDim2.new(1, 0, 0, 20)
    LabelText.Text = Label .. ": " .. tostring(Default)
    LabelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LabelText.BackgroundTransparency = 1
    LabelText.Font = Enum.Font.Gotham
    LabelText.TextSize = 14
    LabelText.Parent = Frame
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 25)
    SliderFrame.Position = UDim2.new(0, 0, 0, 25)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = Frame
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 5)
    SliderCorner.Parent = SliderFrame
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderFrame
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 5)
    FillCorner.Parent = Fill
    local Value = Default or Min
    local Dragging = false
    SliderFrame.MouseButton1Down:Connect(function()
        Dragging = true
    end)
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    SliderFrame.MouseMoved:Connect(function()
        if Dragging then
            local MousePos = UserInputService:GetMouseLocation()
            local SliderPos = SliderFrame.AbsolutePosition
            local Percent = math.clamp((MousePos.X - SliderPos.X) / SliderFrame.AbsoluteSize.X, 0, 1)
            Value = math.floor(Min + (Max - Min) * Percent)
            Fill.Size = UDim2.new(Percent, 0, 1, 0)
            LabelText.Text = Label .. ": " .. tostring(Value)
            if Callback then Callback(Value) end
        end
    end)
    return SliderFrame
end
local function CreateButton(Parent, Label, Callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.Text = Label
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.BorderSizePixel = 0
    Button.Parent = Parent
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    Button.MouseButton1Click:Connect(function()
        if Callback then Callback() end
    end)
    return Button
end
local function CreateDropdown(Parent, Label, Options, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Parent
    local LabelText = Instance.new("TextLabel")
    LabelText.Size = UDim2.new(0.5, 0, 1, 0)
    LabelText.Text = Label
    LabelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LabelText.BackgroundTransparency = 1
    LabelText.Font = Enum.Font.Gotham
    LabelText.TextSize = 14
    LabelText.TextXAlignment = Enum.TextXAlignment.Left
    LabelText.Parent = Frame
    local Dropdown = Instance.new("TextButton")
    Dropdown.Size = UDim2.new(0.4, 0, 1, 0)
    Dropdown.Position = UDim2.new(0.6, 0, 0, 0)
    Dropdown.Text = Default or Options[1] or ""
    Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    Dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Dropdown.Font = Enum.Font.Gotham
    Dropdown.TextSize = 14
    Dropdown.BorderSizePixel = 0
    Dropdown.Parent = Frame
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = Dropdown
    local DropdownList = Instance.new("Frame")
    DropdownList.Size = UDim2.new(0.4, 0, 0, 0)
    DropdownList.Position = UDim2.new(0.6, 0, 1, 0)
    DropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    DropdownList.BorderSizePixel = 0
    DropdownList.ClipsDescendants = true
    DropdownList.Visible = false
    DropdownList.Parent = Frame
    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 6)
    ListCorner.Parent = DropdownList
    local ListScrolling = Instance.new("ScrollingFrame")
    ListScrolling.Size = UDim2.new(1, 0, 1, 0)
    ListScrolling.BackgroundTransparency = 1
    ListScrolling.ScrollBarThickness = 3
    ListScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ListScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
    ListScrolling.Parent = DropdownList
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.Parent = ListScrolling
    local Selected = Default or Options[1] or ""
    for _, Option in ipairs(Options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 30)
        OptionButton.Text = Option
        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionButton.BackgroundColor3 = Option == Selected and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(50, 50, 60)
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 14
        OptionButton.BorderSizePixel = 0
        OptionButton.Parent = ListScrolling
        local OptionCorner = Instance.new("UICorner")
        OptionCorner.CornerRadius = UDim.new(0, 4)
        OptionCorner.Parent = OptionButton
        OptionButton.MouseButton1Click:Connect(function()
            Selected = Option
            Dropdown.Text = Option
            DropdownList.Visible = false
            for _, Child in ipairs(ListScrolling:GetChildren()) do
                if Child:IsA("TextButton") then
                    Child.BackgroundColor3 = Child.Text == Option and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(50, 50, 60)
                end
            end
            if Callback then Callback(Option) end
        end)
    end
    local DropdownOpen = false
    Dropdown.MouseButton1Click:Connect(function()
        DropdownOpen = not DropdownOpen
        DropdownList.Visible = DropdownOpen
        if DropdownOpen then
            local Count = #ListScrolling:GetChildren()
            DropdownList.Size = UDim2.new(0.4, 0, 0, math.min(Count * 32, 160))
        end
    end)
    return Dropdown
end
local function CreateTextBox(Parent, Label, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Parent
    local LabelText = Instance.new("TextLabel")
    LabelText.Size = UDim2.new(0.5, 0, 1, 0)
    LabelText.Text = Label
    LabelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LabelText.BackgroundTransparency = 1
    LabelText.Font = Enum.Font.Gotham
    LabelText.TextSize = 14
    LabelText.TextXAlignment = Enum.TextXAlignment.Left
    LabelText.Parent = Frame
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0.4, 0, 1, 0)
    TextBox.Position = UDim2.new(0.6, 0, 0, 0)
    TextBox.Text = Default or ""
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 14
    TextBox.BorderSizePixel = 0
    TextBox.Parent = Frame
    local TextBoxCorner = Instance.new("UICorner")
    TextBoxCorner.CornerRadius = UDim.new(0, 6)
    TextBoxCorner.Parent = TextBox
    TextBox.FocusLost:Connect(function()
        if Callback then Callback(TextBox.Text) end
    end)
    return TextBox
end

local AutoTab = CreateTab("Auto")
CreateToggle(AutoTab, "Auto Farm", Settings.AutoFarm, function(State)
    Settings.AutoFarm = State
    if State then
        task.spawn(FarmSystem.AutoFarm, FarmSystem)
    end
end)
CreateToggle(AutoTab, "Auto Boss", Settings.AutoBoss, function(State)
    Settings.AutoBoss = State
    if State then
        task.spawn(FarmSystem.AutoBoss, FarmSystem)
    end
end)
CreateToggle(AutoTab, "Auto Collect", Settings.AutoCollect, function(State)
    Settings.AutoCollect = State
    if State then
        task.spawn(FarmSystem.AutoCollect, FarmSystem)
    end
end)
CreateToggle(AutoTab, "Auto Raid", Settings.AutoRaid, function(State)
    Settings.AutoRaid = State
    if State then
        task.spawn(FarmSystem.AutoRaid, FarmSystem)
    end
end)
CreateToggle(AutoTab, "Auto Dungeon", Settings.AutoDungeon, function(State)
    Settings.AutoDungeon = State
    if State then
        task.spawn(FarmSystem.AutoDungeon, FarmSystem)
    end
end)
CreateToggle(AutoTab, "Auto Sea Beast", Settings.AutoSeaBeast, function(State)
    Settings.AutoSeaBeast = State
    if State then
        task.spawn(FarmSystem.AutoSeaBeast, FarmSystem)
    end
end)
CreateToggle(AutoTab, "Auto Ship", Settings.AutoShip, function(State)
    Settings.AutoShip = State
    if State then
        task.spawn(FarmSystem.AutoShip, FarmSystem)
    end
end)
CreateToggle(AutoTab, "Auto Fruit", Settings.AutoFruit, function(State)
    Settings.AutoFruit = State
    if State then
        task.spawn(FarmSystem.AutoFruit, FarmSystem)
    end
end)
CreateToggle(AutoTab, "Auto Bring", Settings.AutoBring, function(State)
    Settings.AutoBring = State
end)
CreateToggle(AutoTab, "Auto Attack", Settings.AutoAttack, function(State)
    Settings.AutoAttack = State
end)
CreateToggle(AutoTab, "Auto Shoot", Settings.AutoShoot, function(State)
    Settings.AutoShoot = State
end)
CreateToggle(AutoTab, "Auto Stats", Settings.AutoStats, function(State)
    Settings.AutoStats = State
    if State then
        task.spawn(FarmSystem.AutoStats, FarmSystem)
    end
end)
CreateToggle(AutoTab, "Auto Store", Settings.AutoStore, function(State)
    Settings.AutoStore = State
    if State then
        task.spawn(FarmSystem.AutoStore, FarmSystem)
    end
end)
CreateSlider(AutoTab, "Farm Radius", 10, 500, Settings.FarmRadius, function(Value)
    Settings.FarmRadius = Value
end)
CreateSlider(AutoTab, "Bring Distance", 10, 100, Settings.BringDistance, function(Value)
    Settings.BringDistance = Value
end)
CreateSlider(AutoTab, "Skill Cooldown", 0.1, 5, Settings.SkillCooldown, function(Value)
    Settings.SkillCooldown = Value
end)
local CombatTab = CreateTab("Combat")
CreateToggle(CombatTab, "Silent Aim", SilentAim.Enabled, function(State)
    SilentAim.Enabled = State
    if State then
        SilentAim:Setup()
    end
end)
CreateToggle(CombatTab, "Show Aimbot", Settings.ShowAimbot, function(State)
    Settings.ShowAimbot = State
end)
CreateToggle(CombatTab, "Smooth Mode", Settings.SmoothMode, function(State)
    Settings.SmoothMode = State
end)
CreateToggle(CombatTab, "No Aim Mobs", Settings.NoAimMobs, function(State)
    Settings.NoAimMobs = State
end)
local WeaponOptions = {"Melee", "Sword", "Gun", "Fruit"}
CreateDropdown(CombatTab, "Combat Mode", WeaponOptions, Settings.CombatMode, function(Value)
    Settings.CombatMode = Value
end)
local TeleportTab = CreateTab("Teleport")
local Islands = {"Main", "Dressrosa", "Zou"}
local SelectedIsland = "Main"
local IslandDropdown = CreateDropdown(TeleportTab, "Island", Islands, SelectedIsland, function(Value)
    SelectedIsland = Value
end)
CreateButton(TeleportTab, "Teleport to Island", function()
    if SelectedIsland then
        TeleportSystem:TeleportToIsland(SelectedIsland)
    end
end)
local BossList = {}
for Name in pairs(BossData) do
    table.insert(BossList, Name)
end
table.sort(BossList)
local SelectedBoss = BossList[1] or ""
local BossDropdown = CreateDropdown(TeleportTab, "Boss", BossList, SelectedBoss, function(Value)
    SelectedBoss = Value
end)
CreateButton(TeleportTab, "Teleport to Boss", function()
    if SelectedBoss then
        TeleportSystem:TeleportToBoss(SelectedBoss)
    end
end)
CreateButton(TeleportTab, "Rejoin Server", function()
    TeleportSystem:RejoinServer()
end)
CreateButton(TeleportTab, "Server Hop", function()
    TeleportSystem:ServerHop(8)
end)
local VisualTab = CreateTab("Visual")
CreateToggle(VisualTab, "Show ESP", Settings.ShowESP, function(State)
    Settings.ShowESP = State
    if State then
        task.spawn(ESP.Update, ESP)
    else
        ESP:Clear()
    end
end)
CreateToggle(VisualTab, "WalkSpeed Bypass", WalkSpeedBypass.Enabled, function(State)
    WalkSpeedBypass.Enabled = State
    if State then
        WalkSpeedBypass:Setup()
    end
end)
CreateSlider(VisualTab, "Walk Speed", 16, 100, Settings.WalkSpeed, function(Value)
    Settings.WalkSpeed = Value
    if Humanoid then
        Humanoid.WalkSpeed = Value
    end
end)
CreateSlider(VisualTab, "Jump Power", 50, 200, Settings.JumpPower, function(Value)
    Settings.JumpPower = Value
    if Humanoid then
        Humanoid.JumpPower = Value
    end
end)
local SettingsTab = CreateTab("Settings")
CreateToggle(SettingsTab, "Ignore Errors", Settings.IgnoreErrors, function(State)
    Settings.IgnoreErrors = State
end)
CreateButton(SettingsTab, "Reset Settings", function()
    Settings.AutoFarm = false
    Settings.AutoCollect = false
    Settings.AutoRaid = false
    Settings.AutoDungeon = false
    Settings.AutoSeaBeast = false
    Settings.AutoShip = false
    Settings.AutoBring = false
    Settings.AutoAttack = true
    Settings.AutoShoot = false
    Settings.FarmRadius = 100
    Settings.BringDistance = 40
    Settings.WalkSpeed = 16
    Settings.JumpPower = 50
    print("Settings Reset!")
end)
CreateButton(SettingsTab, "Destroy GUI", function()
    ScreenGui:Destroy()
end)
local InfoTab = CreateTab("Info")
local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, 0, 0, 200)
InfoText.Text = "My Hub v2.0\n\nDeveloped by: Your Name\n\nFeatures:\n- Auto Farm\n- Auto Boss\n- Auto Collect\n- Auto Raid\n- Auto Dungeon\n- Auto Sea Beast\n- Auto Ship\n- Auto Fruit\n- Auto Bring\n- Silent Aim\n- ESP\n- WalkSpeed Bypass\n- Server Hop\n\nNo Key Required!\nNo Server Connection!"
InfoText.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoText.BackgroundTransparency = 1
InfoText.Font = Enum.Font.Gotham
InfoText.TextSize = 14
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.Parent = InfoTab
local CreditsText = Instance.new("TextLabel")
CreditsText.Size = UDim2.new(1, 0, 0, 50)
CreditsText.Position = UDim2.new(0, 0, 0, 200)
CreditsText.Text = "Credits: Banana Cat Hub (Modified)\nNo Key | No Server | Clean Code"
CreditsText.TextColor3 = Color3.fromRGB(150, 150, 150)
CreditsText.BackgroundTransparency = 1
CreditsText.Font = Enum.Font.Gotham
CreditsText.TextSize = 12
CreditsText.TextYAlignment = Enum.TextYAlignment.Top
CreditsText.Parent = InfoTab
local function Init()
    print("=== My Hub v2.0 Loaded ===")
    print("No Key Required - No Server Connection")
    print("")
    print("Settings:")
    print("  Auto Farm: " .. tostring(Settings.AutoFarm))
    print("  Auto Boss: " .. tostring(Settings.AutoBoss))
    print("  Auto Collect: " .. tostring(Settings.AutoCollect))
    print("  Auto Raid: " .. tostring(Settings.AutoRaid))
    print("  Auto Dungeon: " .. tostring(Settings.AutoDungeon))
    print("  Auto Sea Beast: " .. tostring(Settings.AutoSeaBeast))
    print("  Auto Ship: " .. tostring(Settings.AutoShip))
    print("  Auto Fruit: " .. tostring(Settings.AutoFruit))
    print("  Auto Bring: " .. tostring(Settings.AutoBring))
    print("  Auto Attack: " .. tostring(Settings.AutoAttack))
    print("  Auto Shoot: " .. tostring(Settings.AutoShoot))
    print("  Auto Stats: " .. tostring(Settings.AutoStats))
    print("  Auto Store: " .. tostring(Settings.AutoStore))
    print("  Silent Aim: " .. tostring(SilentAim.Enabled))
    print("  Show ESP: " .. tostring(Settings.ShowESP))
    print("  Show Aimbot: " .. tostring(Settings.ShowAimbot))
    print("  Farm Radius: " .. Settings.FarmRadius)
    print("  Bring Distance: " .. Settings.BringDistance)
    print("  Walk Speed: " .. Settings.WalkSpeed)
    print("  Jump Power: " .. Settings.JumpPower)
    print("  Smooth Mode: " .. tostring(Settings.SmoothMode))
    print("  Combat Mode: " .. Settings.CombatMode)
    print("")
    print("=== Hub Ready ===")
    print("Type getgenv().MyHub to access all functions")
    AntiKick()
    AntiBan()
    SilentAim:Setup()
    WalkSpeedBypass:Setup()
    task.spawn(InventoryManager.Load, InventoryManager)
    if Settings.ShowESP then
        task.spawn(ESP.Update, ESP)
    end
    if Settings.AutoFarm then
        task.spawn(FarmSystem.AutoFarm, FarmSystem)
    end
    if Settings.AutoBoss then
        task.spawn(FarmSystem.AutoBoss, FarmSystem)
    end
    if Settings.AutoCollect then
        task.spawn(FarmSystem.AutoCollect, FarmSystem)
    end
    if Settings.AutoRaid then
        task.spawn(FarmSystem.AutoRaid, FarmSystem)
    end
    if Settings.AutoDungeon then
        task.spawn(FarmSystem.AutoDungeon, FarmSystem)
    end
    if Settings.AutoSeaBeast then
        task.spawn(FarmSystem.AutoSeaBeast, FarmSystem)
    end
    if Settings.AutoShip then
        task.spawn(FarmSystem.AutoShip, FarmSystem)
    end
    if Settings.AutoFruit then
        task.spawn(FarmSystem.AutoFruit, FarmSystem)
    end
    if Settings.AutoStats then
        task.spawn(FarmSystem.AutoStats, FarmSystem)
    end
    if Settings.AutoStore then
        task.spawn(FarmSystem.AutoStore, FarmSystem)
    end
end
getgenv().MyHub = {
    Settings = Settings,
    Player = PlayerManager,
    Enemy = EnemyManager,
    Collection = CollectionManager,
    Combat = CombatSystem,
    Teleport = TeleportSystem,
    Inventory = InventoryManager,
    Shop = ShopManager,
    Fruit = FruitManager,
    Farm = FarmSystem,
    ESP = ESP,
    Aimbot = Aimbot,
    SilentAim = SilentAim,
    WalkSpeed = WalkSpeedBypass,
    Bosses = BossData,
    Init = Init,
}
Init()