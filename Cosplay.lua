Cosplay = LibStub("AceAddon-3.0"):NewAddon("Cosplay", "AceEvent-3.0", "AceHook-3.0")
local Cosplay = Cosplay
local L = LibStub("AceLocale-3.0"):GetLocale("Cosplay")

local AHButtonsCreated = false
local MainButtonsCreated = false

-- Frames
local DressUpFrame = DressUpFrame
local SideDressUpFrame = SideDressUpFrame

-- Functions
local UnitIsPlayer = UnitIsPlayer
local UnitIsVisible = UnitIsVisible
local UnitRace = UnitRace

-- Globals
local GS_TITLE_OPTION_OK = SOUNDKIT.GS_TITLE_OPTION_OK

-- Bindings
BINDING_NAME_CosplayButtonName = L["Open the DressUpFrame"]
BINDING_NAME_CosplayButtonHeader = L["Undress Button"]

local IsClassic
do
    local classic_versions = {
        [11302] = true,
    }

    local version = select(4, GetBuildInfo())
    local isClassic = classic_versions[version]

    IsClassic = function()
        return isClassic
    end
end

-- Client dependent local functions
local AHDressUpModel   -- Returns the Auction House DressUpModel
local DressUpModel     -- Returns the Dressing Room DressupModel
local DressUpTarget    -- Takes a unitID and sets the model of the DressUpModel
local ResetPlayerModel -- Resets the Dressing Room model
do
    if IsClassic() then
        AHDressUpModel = function()
            return SideDressUpModel
        end

        DressUpModel = function()
            return DressUpFrame.DressUpModel
        end

        DressUpTarget = function(unitID)
            DressUpModel():SetUnit(unitID)
        end

        ResetPlayerModel = function()
            DressUpTarget("player")
        end
    else
        AHDressUpModel = function()
            return SideDressUpFrame.ModelScene:GetPlayerActor()
        end

        DressUpModel = function()
            return DressUpFrame.ModelScene:GetPlayerActor()
        end

        DressUpTarget = function(unitID)
            DressUpModel():SetModelByUnit(unitID)
        end

        ResetPlayerModel = function()
            DressUpTarget("player")

            local model = DressUpModel()
            model:SetSheathed(false)
            model:Dress()
        end
    end
end

function Cosplay:CreateMainButtons()
    if not MainButtonsCreated then
        -- Undress button.  Lets get nekkid!
        local button = CreateFrame("Button", "DUFUndressButton", DressUpFrame, "UIPanelButtonTemplate")
        button:SetWidth(80)
        button:SetHeight(22)
        button:SetText(L["Undress"])
        button:SetPoint("RIGHT", "DressUpFrameResetButton", "LEFT", 0, 0)
        button:SetFrameStrata("HIGH")
        button:SetScript("OnClick", function()
            DressUpModel():Undress()
            PlaySound(GS_TITLE_OPTION_OK)
        end)

        -- Target button.
        local targetButton = CreateFrame("Button", "DUFDressTargetButton", DressUpFrame, "UIPanelButtonTemplate")
        targetButton:SetWidth(80)
        targetButton:SetHeight(22)
        targetButton:SetText(L["Target"])
        targetButton:SetPoint("RIGHT", "DUFUndressButton", "LEFT", 0, 0)
        targetButton:SetFrameStrata("HIGH")
        targetButton:SetScript("OnClick", function()
            self:DressUpTarget()
        end)
        targetButton:SetScript("OnShow", function()
            self:Reset()
        end)

        -- All done
        MainButtonsCreated = true

        -- Unhook the script now.
        self:Unhook(DressUpFrame, "OnShow")
    end
end

function Cosplay:CreateAHButtons()
    if not AHButtonsCreated then
        local button = CreateFrame("Button", "ADUFUndressButton", SideDressUpFrame, "UIPanelButtonTemplate")
        button:SetWidth(70)
        button:SetHeight(22)
        button:SetText(L["Undress"])

        if IsClassic() then
            button:SetPoint("BOTTOM", "SideDressUpModelResetButton", "TOP", 0, 2)
        else
            button:SetPoint("BOTTOM", SideDressUpFrame.ResetButton, "TOP", 0, 2)
            button:SetFrameLevel(SideDressUpFrame.ModelScene:GetFrameLevel() + 1)
        end

        button:SetScript("OnClick", function()
            AHDressUpModel():Undress()
            PlaySound(GS_TITLE_OPTION_OK)
        end)

        AHButtonsCreated = true
    end

    self:UnregisterEvent("AUCTION_HOUSE_SHOW")
end


function Cosplay:Reset()
    local race, fileName = UnitRace("player")

    SetPortraitTexture(DressUpFramePortrait, "player")
    SetDressUpBackground(DressUpFrame, fileName)

    -- Client dependent local function
    ResetPlayerModel()
end

function Cosplay:DressUpTarget()
    if not DressUpFrame:IsVisible() then
        ShowUIPanel(DressUpFrame)
    else
        PlaySound(GS_TITLE_OPTION_OK)
    end

    -- Attempting to dress a target that isn't a player will crash the retail
    -- client (8.2.5) and result in an untextured model in classic.
    if UnitIsVisible("target") and UnitIsPlayer("target") then
        local race, fileName = UnitRace("target")
        SetPortraitTexture(DressUpFramePortrait, "target")
        SetDressUpBackground(DressUpFrame, fileName)

        -- Client dependent local function
        DressUpTarget("target")
    else
        self:Reset()
    end
end

function Cosplay:OnEnable()
    if not AHButtonsCreated then
        self:RegisterEvent("AUCTION_HOUSE_SHOW", "CreateAHButtons")
    end

    if not MainButtonsCreated then
        self:HookScript(DressUpFrame, "OnShow", "CreateMainButtons")
    end

    -- We need to secure hook the Reset button in retail, otherwise the
    -- DressUpFrame won't reset properly if we've previously dressed up another
    -- player.
    if not IsClassic() then
        self:SecureHookScript(DressUpFrame.ResetButton, "OnClick", "Reset")
    end
end
