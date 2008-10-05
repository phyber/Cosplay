Cosplay = LibStub("AceAddon-3.0"):NewAddon("Cosplay", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Cosplay")
local MainButtonsCreated = false
local ABButtonsCreated = false
local string_lower = string.lower

-- Bindings
BINDING_NAME_CosplayButtonName = L["Open the DressUpFrame"]
BINDING_NAME_CosplayButtonHeader = L["Undress Button"]

function Cosplay:OnEnable()
	if not AHButtonsCreated then
		self:RegisterEvent("AUCTION_HOUSE_SHOW", "CreateAHButtons")
	end
	if not MainButtonsCreated then
		self:HookScript(DressUpFrame, "OnShow", "CreateMainButtons")
	end
end

function Cosplay:CreateMainButtons()
	if not MainButtonsCreated then
		-- Undress button.  Lets get nekkid!
		local DUFUndressButton = CreateFrame("Button", "DUFUndressButton", DressUpFrame, "UIPanelButtonTemplate")
		DUFUndressButton:SetWidth(80)
		DUFUndressButton:SetHeight(22)
		DUFUndressButton:SetText(L["Undress"])
		DUFUndressButton:SetPoint("RIGHT", "DressUpFrameResetButton", "LEFT", 0, 0)
		DUFUndressButton:SetFrameStrata("HIGH")
		DUFUndressButton:SetScript("OnClick", function()
			DressUpModel:Undress()
			PlaySound("gsTitleOptionOK")
		end)

		-- Target button.
		local DUFDressTargetButton = CreateFrame("Button", "DUFDressTargetButton", DressUpFrame, "UIPanelButtonTemplate")
		DUFDressTargetButton:SetWidth(80)
		DUFDressTargetButton:SetHeight(22)
		DUFDressTargetButton:SetText(L["Target"])
		DUFDressTargetButton:SetPoint("RIGHT", "DUFUndressButton", "LEFT", 0, 0)
		DUFDressTargetButton:SetFrameStrata("HIGH")
		DUFDressTargetButton:SetScript("OnClick", function()
			self:DressUpTarget()
		end)
		DUFDressTargetButton:SetScript("OnShow", function()
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
		local AuctionDUFUndressButton = CreateFrame("Button", "ADUFUndressButton", AuctionDressUpModel, "UIPanelButtonTemplate")
		ADUFUndressButton:SetWidth(70)
		ADUFUndressButton:SetHeight(22)
		ADUFUndressButton:SetText(L["Undress"])
		ADUFUndressButton:SetPoint("BOTTOM", "AuctionDressUpFrameResetButton", "TOP", 0, 2)
		ADUFUndressButton:SetScript("OnClick", function()
			AuctionDressUpModel:Undress()
			PlaySound("gsTitleOptionOK")
		end)

		AHButtonsCreated = true
	end
	self:UnregisterEvent("AUCTION_HOUSE_SHOW")
end

function Cosplay:Reset()
	SetPortraitTexture(DressUpFramePortrait, "player")
	SetDressUpBackground()
	DressUpModel:SetUnit("player")
end

local function DressUpTargetTexturePath()
	local fileName = select(2, UnitRace("target"))
	if fileName then
		if string_lower(fileName) == "gnome" then
			fileName = "Dwarf"
		elseif string_lower(fileName) == "troll" then
			fileName = "Orc"
		end
	else
		fileName = "Orc"
	end

	return "Interface\\DressUpFrame\\DressUpBackground-"..fileName
end

local function SetDressUpTargetBackground()
	local texture = DressUpTargetTexturePath()
	DressUpBackgroundTopLeft:SetTexture(texture..1)
	DressUpBackgroundTopRight:SetTexture(texture..2)
	DressUpBackgroundBotLeft:SetTexture(texture..3)
	DressUpBackgroundBotRight:SetTexture(texture..4)
end

function Cosplay:DressUpTarget()
	if not DressUpFrame:IsVisible() then
		ShowUIPanel(DressUpFrame)
	else
		PlaySound("gsTitleOptionOK")
	end
	if UnitIsVisible("target") then
		SetPortraitTexture(DressUpFramePortrait, "target")
		SetDressUpTargetBackground()
		DressUpModel:SetUnit("target")
	else
		self:Reset()
	end
end
