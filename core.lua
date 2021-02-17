LST = LibStub("AceAddon-3.0"):NewAddon("LegendaryStockTracker", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("LegendaryStockTracker")
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

-- Set up DataBroker for minimap button
local LstockLDB = LibStub("LibDataBroker-1.1"):NewDataObject("LegendaryStockTracker", {
  type = "data source",
  text = "LegendaryStockTracker",
  label = "LegendaryStockTracker",
  icon = "Interface\\AddOns\\LegendaryStockTracker\\LST_logo",
  OnClick = function()
    if LstockMainFrame and LstockMainFrame:IsShown() then
      LstockMainFrame:Hide()
    else
      LST:HandleChatCommand("")
    end
  end,
  OnTooltipShow = function(tt)
	LST:GetAllItemsInBags()
    tt:AddLine("Legendary Stock Tracker")
    tt:AddLine(" ")
    tt:AddLine(L["Click or type /lst to show the main panel"])
    tt:AddLine(L["Items Scanned:"])
    tt:AddLine(LST:GetDataCounts())
  end
})

local db = nil
local LstockIcon = LibStub("LibDBIcon-1.0")
local LstockMainFrame = nil
local LSTTableScrollChild = nil
local LSTRestockScrollChild = nil

--all collections of items are stored separately for future expandability
local itemLinks = {}
local bagItemLinks = {}
local bagItemCount = 0
local bankItemLinks = {}
local bankItemCount = 0
local isBankOpen = false
local ahItemLinks = {}
local ahItemCount = 0
local mailboxItemLinks = {}
local mailboxItemCount = 0
local GuildBankItemLinks = {}
local GuildBankItemCount = 0
local gearLinks = {}
local legendaryLinks = {}
local TSMPriceDataByRank = {}
local Rank1BonusIDs = "::2:1487:6716"
local Rank2BonusIDs = "::2:1507:6717"
local Rank3BonusIDs = "::2:1522:6718"
local Rank4BonusIDs = "::2:1532:6758"

local LegendaryItemData = 
{
	["171419"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["171412"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["171414"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["171416"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["171415"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["171417"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["171413"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["171418"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["178927"] = {["profession"] = "jewelry", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["178926"] = {["profession"] = "jewelry", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173248"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173249"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173242"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173245"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173244"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173246"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173241"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173243"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173247"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172321"] = {["profession"] = "leather",	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172316"] = {["profession"] = "leather", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172317"] = {["profession"] = "leather", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172318"] = {["profession"] = "leather", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172319"] = {["profession"] = "leather", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172315"] = {["profession"] = "leather", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172314"] = {["profession"] = "leather", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172320"] = {["profession"] = "leather", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172329"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172324"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172326"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172325"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172327"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172323"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172322"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172328"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}}
}

local GUILD_BANK_SLOTS_PER_TAB = 98
local IsTSMLoaded = false;
local fontStringPool = nil
local RestockList = {}
local numRanks = 4

local activeTab = nil
local exportTab = nil
local contentFrame = nil
local tabWidth = 150
local tabHeight = 24
local contentWidthOffset = 5
local contentHeightOffset = -25

local playerName = ""
local guildName = ""

function LST:OnInitialize()
	-- init databroker
	db = LibStub("AceDB-3.0"):New("LegendaryStockTrackerDB", {
		profile = 
		{
			minimap = 
			{
				hide = false,
			},
			frame = 
			{
				point = "CENTER",
				relativeFrame = nil,
				relativePoint = "CENTER",
				ofsx = 0,
				ofsy = 0,
				width = 760,
				height = 590,
			},
			settings = 
			{
				loadUnownedLegendaries = true,
				showPricing = true,
				includeBags = true,
				includeBank = true,
				includeAH = true,
				includeMail = true,
				IncludeGuild = true,
				minProfit = 5000,
				restockAmount = 3,
				minrestockAmount = 2,
				includeCachedData = true,
				syncTarget = "charactername",
				onlyRestockCraftable = false
			}
		},
		factionrealm = {
			accountUUID = "",
			characters = 
			{
				['*'] = 
				{
					characterName = "",
					classNameBase = "",
					bagItemLinks = {},
					bagItemCount = 0,
					bankItemLinks = {},
					bankItemCount = 0,
					ahItemLinks = {},
					ahItemCount = 0,
					mailboxItemLinks = {},
					mailboxItemCount = 0,
					unlockedLegendaryCraftRanks = {}
				}
			},
			guilds = 
			{
				['*'] = 
				{
					guildName = "",
					GuildBankItemLinks = {},
					GuildBankItemCount = 0
				}
			},
			syncData = 
			{
				['*'] = 
				{
					legendaries = 
					{
						['*'] = 
						{
							canCraft = 0,
							stock = {}
						}
					}
				}
			},
		}
	});

	LstockIcon:Register("LegendaryStockTracker", LstockLDB, db.profile.minimap)
	--chat commands
    LST:RegisterChatCommand("lstock", "HandleChatCommand")
    LST:RegisterChatCommand("lst", "HandleChatCommand")
    LST:RegisterChatCommand("LST", "HandleChatCommand")
    LST:RegisterChatCommand("lstocktest", "Test")
    LST:RegisterChatCommand("lstSetSize", "SetMainFrameSize")
	LST:RegisterChatCommand("lstockscan", "ScanAhPrices")
	--events
	LST:RegisterEvent("BANKFRAME_OPENED", "GetAllItemsInBank")
	LST:RegisterEvent("OWNED_AUCTIONS_UPDATED", "GetAllItemsInAH")
	LST:RegisterEvent("MAIL_INBOX_UPDATE", "GetAllItemsInMailbox")
	LST:RegisterEvent("MAIL_CLOSED", "GetAllItemsInMailbox")
	LST:RegisterEvent("GUILDBANKFRAME_CLOSED", "GetAllItemsInGuildBank")
	LST:RegisterEvent("GUILDBANKFRAME_OPENED", "GetAllItemsInGuildBank")
	LST:RegisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED", "OnItemAdded")
	LST:RegisterEvent("GET_ITEM_INFO_RECEIVED", "OnItemInfoReceived")
	LST:RegisterEvent("TRADE_SKILL_LIST_UPDATE", "UpdateLegendaryRecipes")
	LST:RegisterEvent("NEW_RECIPE_LEARNED", "UpdateLegendaryRecipes")

	self:RegisterComm("LST")

	LST:CheckIfTSMIsRunning()
	playerName = UnitName("player")
	--guildName = select(1,GetGuildInfo("player")); --doesn't work on login, only on reloads
	db.factionrealm.characters[playerName].characterName = playerName;
	db.factionrealm.characters[playerName].classNameBase = select(1,UnitClassBase("player"));
	LST:GetAllItemsInBags();
	local item = {};
	for id,data in pairs(LegendaryItemData) do
		local iteminfo = GetItemInfo(id);
		if(iteminfo ~= nil ) then
			LST:ProcessItemInfo(id, true)
		end
	end
	if(db.factionrealm.accountUUID == nil or db.factionrealm.accountUUID == "") then
		db.factionrealm.accountUUID = LST:GenerateUUID();
	end
end

function LST:tst()
	print("tst");
end

function LST:ProcessItemInfo(itemID, success)
	if(LegendaryItemData[itemID] ~= nil) then
		local itemName, itemLink, _, _, _, _, _, _, _, itemTexture, _, _, _, _, _, _, _ = GetItemInfo(itemID);
		LegendaryItemData[itemID]["name"] = itemName;
		LegendaryItemData[itemID]["itemLink"] = itemLink;
		LegendaryItemData[itemID]["icon"] = itemTexture;
	end
end

function LST:OnItemInfoReceived(event, itemID, success)
	if(success == true) then
		LST:ProcessItemInfo(tostring(tonumber(itemID)), success);
	end
end


function LST:Test()
	LST:UpdateLegendaryRecipes();
	--LST:SendDataToPlayer("Talyma-Silvermoon");
end

function LST:SetMainFrameSize(value1, value2)
	--db.profile.frame.width = value1
	--db.profile.frame.height = value2
	--local f = LST:GetMainFrame()
	--f:SetSize(tonumber(value1), tonumber(value2))
end

function LST:GetDataCounts()
	local text = ""
	if(db.profile.settings.includeCachedData) then
		text = text .. L["Bags: "] .. LST:GetItemCounts("bagItemCount") .. "\n"
		text = text .. L["Bank: "] .. LST:GetItemCounts("bankItemCount") .. "\n"
		text = text .. L["AH: "] .. LST:GetItemCounts("ahItemCount") .. "\n"
		text = text .. L["Mail: "] .. LST:GetItemCounts("mailboxItemCount") .. "\n"
		local sum = 0
		local count = 0
		local altString = " ("
		for key,val in pairs(db.factionrealm.guilds) do
			sum = sum + db.factionrealm.guilds[key]["GuildBankItemCount"];
			altString = altString .. db.factionrealm.guilds[key]["GuildBankItemCount"] .. " ";
			count = count + 1;
		end
		altString = altString:sub(1, #altString - 1);
		altString = altString .. ")";
		if(count == 0) then
			altString = "";
		end

		text = text .. L["Guild: "] .. sum .. altString .. "\n"
	else
		text = text .. L["Bags: "] .. bagItemCount .. "\n"
		text = text .. L["Bank: "] .. bankItemCount .. "\n"
		text = text .. L["AH: "] .. ahItemCount .. "\n"
		text = text .. L["Mail: "] .. mailboxItemCount .. "\n"
		text = text .. L["Guild: "] .. GuildBankItemCount .. "\n"
	end
	return text
end

function LST:GetItemCounts(itemCountParameterName)
	local sum = 0
	local altString = " ("
	local count = 0
	local classColorEsc = ""
	for key,val in pairs(db.factionrealm.characters) do
		sum = sum + db.factionrealm.characters[key][itemCountParameterName];
		if(db.factionrealm.characters[key].classNameBase ~= nil and db.factionrealm.characters[key].classNameBase ~= "") then
			classColorEsc = "|c" .. C_ClassColor.GetClassColor(db.factionrealm.characters[key].classNameBase):GenerateHexColor();
		else
			classColorEsc = "";
		end
		altString = altString .. classColorEsc .. db.factionrealm.characters[key][itemCountParameterName] .. "|r ";
		count = count + 1;
	end
	altString = altString:sub(1, #altString - 1);
	altString = altString .. ")";
	if(count == 0) then
		altString = "";
	end
	return sum .. altString;
end

function LST:HandleChatCommand(input)
	local f = LST:GetMainFrame(UIParent)
	LST:UpdateExportText()
	LST:UpdateTable()
	f:Show()
end

function LST:UpdateExportText()
	LST:UpdateAllAvailableItemSources()
	LST:GetLegendariesFromItems()
	--LST:GetMainFrame(UIParent)
	LSTEditBox:SetText(LST:GenerateExportText())
	LSTEditBox:HighlightText()
end

function LST:UpdateTable()
	LST:UpdateAllAvailableItemSources()
	LST:GetLegendariesFromItems()
	LST:CreateTableSheet(LSTTableScrollChild)
	--LST:CreateFrameSheet(LstockMainFrame)
end

function LST:UpdateRestock()
	LST:UpdateAllAvailableItemSources()
	LST:GetLegendariesFromItems()
	LST:CreateRestockSheet(LSTRestockScrollChild)
end

function LST:UpdateAllAvailableItemSources()
	LST:GetAllItemsInAH()
	LST:GetAllItemsInBags()
	LST:GetAllItemsInBank() --if the bank is open at the time of command, update bank as well
	--LST:GetAllItemsInAH() auctions specifically not updated on command, as we don't know if the ah is closed or the player has no auctions. relying on OWNED_AUCTIONS_UPDATED to update those.
	--LST:GetAllItemsInMailbox() mailbox is updated anytime the mailbox is updated, no need to update on command 
	--LST:GetAllItemsInGuildBank()
end

function LST:GetLegendariesFromItems()
	LST:CheckIfTSMIsRunning()
	LST:AddAllItemsToList()
	LST:GetGearFromItems()
	LST:GetShadowlandsLegendariesFromGear()
	LST:CountLegendariesByRank()
end

function LST:ShowTestFrame()
	local f = LST:GetMainFrame(UIParent)
	f:Show()
end

function LST:GetMainFrame(parent)
	if not LstockMainFrame then
		local mainFrameWidth = tonumber(db.profile.frame.width)
		local mainFrameHeight = tonumber(db.profile.frame.height)
		if(mainFrameWidth == nil) then
			mainFrameWidth = 760
		end
		if(mainFrameHeight == nil) then
			mainFrameHeight = 590
		end
		local Backdrop = {
			bgFile = "Interface\\AddOns\\LegendaryStockTracker\\Assets\\Plain.tga",
			--edgeFile = temp,
			tile = false, tileSize = 0, edgeSize = 1,
			insets = {left = 1, right = 1, top = 1, bottom = 1},
		}
		local frameConfig = db.profile.frame
		local f = CreateFrame("Frame","LSTMainFrame",parent, BackdropTemplateMixin and "BackdropTemplate")
		LstockMainFrame = f
		f:SetBackdrop(Backdrop)
		f:SetBackdropColor(0.03,0.03,0.03,0.9)
		f:SetSize(mainFrameWidth, mainFrameHeight )
		f:SetFrameStrata("HIGH")
		f:SetToplevel(true)
		f:SetClampedToScreen(true)
		f:SetPoint(
		frameConfig.point,
		frameConfig.relativeFrame,
		frameConfig.relativePoint,
		frameConfig.ofsx,
		frameConfig.ofsy
		)
		tinsert(UISpecialFrames, f:GetName())
		LST:SetFrameMovable(f)

		local tabList = CreateFrame("Frame","LSTTabList",f)
		tabList:SetPoint("TOPLEFT", LstockMainFrame, "TOPLEFT",0,-5)
		tabList:SetPoint("BOTTOMRIGHT", LstockMainFrame, "BOTTOMLEFT",tabWidth,0)

		contentFrame = CreateFrame("Frame","LSTContentFrame",f, BackdropTemplateMixin and "BackdropTemplate")
		contentFrame:SetPoint("TOPLEFT", LstockMainFrame, "TOPLEFT",tabWidth,0)
		contentFrame:SetPoint("BOTTOMRIGHT", LstockMainFrame, "BOTTOMRIGHT")

		--divider lines
		local line = tabList:CreateLine()
		line:SetThickness(1)
		line:SetColorTexture(0.6,0.6,0.6,1)
		line:SetStartPoint("TOPRIGHT",0,4)
		line:SetEndPoint("BOTTOMRIGHT",0,1)

		line= contentFrame:CreateLine()
		line:SetThickness(1)
		line:SetColorTexture(0.6,0.6,0.6,1)
		line:SetStartPoint("TOPLEFT",0,-20)
		line:SetEndPoint("TOPRIGHT",-2,-20)

		--Export Frame
		local exportFrame = LST:CreateOptionsContentFrame("LSTExportFrame", contentFrame, Backdrop)
		--exportFrame:SetBackdropColor(0.75,0,0,0.9)
		exportFrame.title:SetText(L["Paste this data into your copy of the spreadsheet"])
		exportFrame:SetScript("OnShow", function()
			LST:UpdateExportText()
		end)

		-- scroll frame
		local sf = CreateFrame("ScrollFrame", "LSTScrollFrame", exportFrame, BackdropTemplateMixin and "UIPanelScrollFrameTemplate")
		sf:SetPoint("LEFT")
		sf:SetPoint("RIGHT", -22, 0)
		sf:SetPoint("TOP")
		sf:SetPoint("BOTTOM")
		
		-- edit box
		local eb = CreateFrame("EditBox", "LSTEditBox", LstockScrollFrame)
		eb:SetSize(sf:GetSize())
		eb:SetMultiLine(true)
		eb:SetAutoFocus(true)
		eb:SetFontObject("ChatFontNormal")
		eb:SetScript("OnEscapePressed", function() f:Hide() end)
		sf:SetScrollChild(eb)

		-- resizing
		f:SetResizable(true)
		f:SetMinResize(400, 350)
		local rb = CreateFrame("Button", "LSTResizeButton", f)
		rb:SetPoint("BOTTOMRIGHT", -6, 7)
		rb:SetSize(16, 16)
		rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
		rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
		rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

		rb:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				f:StartSizing("BOTTOMRIGHT")
				self:GetHighlightTexture():Hide() -- more noticeable
			end
		end)
		rb:SetScript("OnMouseUp", function(self, button)
			f:StopMovingOrSizing()
			self:GetHighlightTexture():Show()
			contentFrame:SetSize(f:GetWidth() - tabWidth, f:GetHeight())
			-- save size between sessions
			frameConfig.width = f:GetWidth()
			frameConfig.height = f:GetHeight()
		end)
		
		--settings frame
		local settingsFrame = LST:CreateOptionsContentFrame("LSTsettingsFrame", contentFrame, Backdrop)
		--settingsFrame:SetBackdropColor(0,0.75,0,0.9)
		settingsFrame.title:SetText(L["Settings"])

		settingsFrame.scrollframe = settingsFrame.scrollframe or CreateFrame("ScrollFrame", "LSTSettingsScrollFrame", settingsFrame, BackdropTemplateMixin and "UIPanelScrollFrameTemplate");
		settingsFrame.scrollframe:SetPoint("LEFT")
		settingsFrame.scrollframe:SetPoint("RIGHT", -22, 0)
		settingsFrame.scrollframe:SetPoint("TOP")
		settingsFrame.scrollframe:SetPoint("BOTTOM")

		local LSTSettingsScrollChild = settingsFrame.scrollframe.scrollchild or CreateFrame("Frame", "LSTSettingsScrollChild", settingsFrame.scrollframe);
		LSTSettingsScrollChild:SetSize(settingsFrame.scrollframe:GetSize())
		settingsFrame.scrollframe:SetScrollChild(LSTSettingsScrollChild)

		--settings options
		local heightOffset = 0
		heightOffset = LST:AddOptionCheckbox("ShowUnownedItemsCheckButton", LSTSettingsScrollChild, "loadUnownedLegendaries", L["Show all legendaries"], heightOffset)
		heightOffset = LST:AddOptionCheckbox("ShowPricingCheckButton", LSTSettingsScrollChild, "showPricing", L["Show profit (requires TSM operations)"], heightOffset)
		heightOffset = LST:AddOptionEditbox("MinProfitEditBox", LSTSettingsScrollChild, "minProfit", L["Min profit before restocking"], heightOffset, 45)
		heightOffset = LST:AddOptionEditbox("RestockAmountEditBox", LSTSettingsScrollChild, "restockAmount", L["Restock amount"], heightOffset, 25)
		heightOffset = LST:AddOptionEditbox("MinRestockAmountEditBox", LSTSettingsScrollChild, "minrestockAmount", L["Min restock amount"], heightOffset, 25)
		heightOffset = LST:AddOptionCheckbox("onlyRestockCraftableEditBox", LSTSettingsScrollChild, "onlyRestockCraftable", L["Only restock items I can craft"], heightOffset, 25)
		heightOffset = heightOffset - 25
		local text = LSTSettingsScrollChild:CreateFontString(nil,"ARTWORK", "GameFontHighlight") 
		text:SetPoint("TOPLEFT", LSTSettingsScrollChild, "TOPLEFT", 0, heightOffset)
		text:SetText(L["Sources to include:"])
		heightOffset = heightOffset - 15
		heightOffset = LST:AddOptionCheckbox("IncludeBagsCheckButton", LSTSettingsScrollChild, "includeBags", L["Include Bags"], heightOffset)
		heightOffset = LST:AddOptionCheckbox("IncludeBankCheckButton", LSTSettingsScrollChild, "includeBank", L["Include Bank"], heightOffset)
		heightOffset = LST:AddOptionCheckbox("IncludeAHCheckButton", LSTSettingsScrollChild, "includeAH", L["Include AH"], heightOffset)
		heightOffset = LST:AddOptionCheckbox("IncludeMailCheckButton", LSTSettingsScrollChild, "includeMail", L["Include Mail"], heightOffset)
		heightOffset = LST:AddOptionCheckbox("IncludeGuildCheckButton", LSTSettingsScrollChild, "IncludeGuild", L["Include Guild Bank"], heightOffset)
		heightOffset = LST:AddOptionCheckbox("includeCacheCheckButton", LSTSettingsScrollChild, "includeCachedData", L["Include Cached items"], heightOffset)
		heightOffset = heightOffset - 25
		heightOffset = LST:AddSyncButtonToOptions(heightOffset, LSTSettingsScrollChild);
		
		--table frame
		local tableFrame = LST:CreateOptionsContentFrame("LSTtableFrame", contentFrame, BackdropTemplateMixin and "BackdropTemplate")
		--tableFrame:SetBackdrop(Backdrop)
		--tableFrame:SetBackdropColor(0,0,1,0.9)
		tableFrame.title:SetText(L["Table"])
		tableFrame:SetScript("OnShow", function()
			LST:UpdateTable()
		end)
		tableFrame.scrollframe = tableFrame.scrollframe or CreateFrame("ScrollFrame", "LSTTableScrollFrame", tableFrame, BackdropTemplateMixin and "UIPanelScrollFrameTemplate");
		tableFrame.scrollframe:SetPoint("LEFT")
		tableFrame.scrollframe:SetPoint("RIGHT", -22, 0)
		tableFrame.scrollframe:SetPoint("TOP")
		tableFrame.scrollframe:SetPoint("BOTTOM")

		LSTTableScrollChild = tableFrame.scrollframe.scrollchild or CreateFrame("Frame", "LSTtableScrollChild", tableFrame.scrollframe);
		LSTTableScrollChild:SetSize(tableFrame.scrollframe:GetSize())
		tableFrame.scrollframe:SetScrollChild(LSTTableScrollChild)

		--Restock frame
		local restockFrame = LST:CreateOptionsContentFrame("LSTRestockFrame", contentFrame, Backdrop)
		restockFrame.title:SetText(L["Restock"])
		restockFrame:SetScript("OnShow", function()
			LST:UpdateRestock()
		end)
		restockFrame.scrollframe = restockFrame.scrollframe or CreateFrame("ScrollFrame", "LSTRestockScrollFrame", restockFrame, BackdropTemplateMixin and "UIPanelScrollFrameTemplate");
		restockFrame.scrollframe:SetPoint("LEFT")
		restockFrame.scrollframe:SetPoint("RIGHT", -22, 0)
		restockFrame.scrollframe:SetPoint("TOP")
		restockFrame.scrollframe:SetPoint("BOTTOM")

		LSTRestockScrollChild = restockFrame.scrollframe.scrollchild or CreateFrame("Frame", "LSTRestockScrollChild", restockFrame.scrollframe);
		LSTRestockScrollChild:SetSize(restockFrame.scrollframe:GetSize())
		restockFrame.scrollframe:SetScrollChild(LSTRestockScrollChild)

		--create tabs
		exportTab = LST:AddTab(tabList, tabWidth, 24, 3, exportFrame, L["Export"])
		LST:AddTab(tabList, tabWidth, 24, 2, settingsFrame, L["Settings"])
		local tab = LST:AddTab(tabList, tabWidth, 24, 1, tableFrame, L["Table"])
		LST:AddTab(tabList, tabWidth, 24, 4, restockFrame, L["Restock"])
		LST:TabOnClick(tab)

		local closeButton = CreateFrame("Button", "LSTMainFrameCloseButton", f)
		closeButton:SetSize(20,20)
		closeButton:SetText("X")
		closeButton:SetPoint("TOPRIGHT", f, "TOPRIGHT")
		closeButton:SetNormalFontObject("GameFontHighlight")
		closeButton:SetHighlightFontObject("GameFontHighlight")
		closeButton:SetDisabledFontObject("GameFontDisable")
		closeButton:SetScript("OnClick", function()
			LstockMainFrame:Hide()
		end)
	end
	return LstockMainFrame
end

function LST:SetFrameMovable(f)
	local frameConfig = db.profile.frame
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
		self:StartMoving()
		end
	end)
	f:SetScript("OnMouseUp", function(self, button)
	self:StopMovingOrSizing()
	-- save position between sessions
	point, relativeFrame, relativeTo, ofsx, ofsy = self:GetPoint()
	frameConfig.point = point
	frameConfig.relativeFrame = relativeFrame
	frameConfig.relativePoint = relativeTo
	frameConfig.ofsx = ofsx
	frameConfig.ofsy = ofsy
	end)
end

function LST:TabOnClick(self)
	if(activeTab ~= nil) then
		activeTab.content:Hide()
	end
	activeTab = self
	self.content:Show()
end

function LST:AddTab(parent, width, height, index, content, text)

	local b = CreateFrame("Button", "Tab" .. index, parent)
	b:SetSize(width,24)
	b:SetText(text)
	b:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(index - 1) * height)
	b.HighlightTexture = b:CreateTexture()
	b.HighlightTexture:SetColorTexture(1,1,1,.3)
	b.HighlightTexture:SetPoint("TOPLEFT")
	b.HighlightTexture:SetPoint("BOTTOMRIGHT")
	b:SetHighlightTexture(b.HighlightTexture)
	b.PushedTexture = b:CreateTexture()
	b.PushedTexture:SetColorTexture(.9,.8,.1,.3)
	b.PushedTexture:SetPoint("TOPLEFT")
	b.PushedTexture:SetPoint("BOTTOMRIGHT")
	b:SetPushedTexture(b.PushedTexture)
	--b:SetNormalFontObject("GameFontNormal")
	b:SetNormalFontObject("GameFontHighlight")
	b:SetHighlightFontObject("GameFontHighlight")
	b:SetDisabledFontObject("GameFontDisable")
	b:SetScript("OnClick", function(self)
		LST:TabOnClick(self)
	end)
	b.content = content
	b.content:Hide()
	return b
end

function LST:CreateOptionsContentFrame(name, parent, backdrop)
	local f = CreateFrame("Frame",name,parent, BackdropTemplateMixin and "BackdropTemplate")
	--f:SetBackdrop(backdrop)
	--f:SetBackdropColor(0.03,0.03,0.03,0.9)
	f:SetPoint("TOPLEFT", parent, "TOPLEFT", contentWidthOffset, contentHeightOffset)
	f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -contentWidthOffset, -contentHeightOffset)

	f.title = f:CreateFontString(nil,"ARTWORK", "GameFontHighlight") 
	f.title:SetPoint("BottomLeft",f, "TOPLEFT", 0, 8)
	return f
end

function LST:AddOptionCheckbox(name, parent, setting, description, heightOffset)
	local cb = CreateFrame("CheckButton", name, parent, "OptionsCheckButtonTemplate")
	cb:SetSize(20,20)
	cb:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, heightOffset)
	cb.setting = setting
	cb:SetChecked(db.profile.settings[cb.setting])
	cb:SetScript("OnClick", function(cb)
		if cb:GetChecked() then
			db.profile.settings[cb.setting] = true
		else
			db.profile.settings[cb.setting] = false
		end
	end)
	local text = cb:CreateFontString(nil,"ARTWORK", "GameFontHighlight") 
	text:SetPoint("LEFT", cb, "RIGHT", 0, 1)
	text:SetText(description)
	return heightOffset - 20
end

function LST:AddOptionEditbox(name, parent, setting, description, heightOffset, width)
	local Backdrop = {
		bgFile = "Interface\\AddOns\\LegendaryStockTracker\\Assets\\Plain.tga",
		edgeFile = "Interface/Buttons/WHITE8X8",
		tile = false, tileSize = 0, edgeSize = 1,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	}

	local eb = CreateFrame("EditBox", name, parent, BackdropTemplateMixin and "BackdropTemplate")
	eb:SetAutoFocus(false)
	eb:SetBackdrop(Backdrop)
	eb:SetBackdropColor(0.25,0.25,0.25,0.9)
	eb:SetBackdropBorderColor(0,0,0,1)
	eb:SetSize(width,22)
	eb:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, heightOffset)
	eb:SetFontObject("GameFontNormal")
	eb:SetTextColor(1,1,1,1)
	eb.setting = setting
	eb:SetText(db.profile.settings[eb.setting])
	eb:SetScript("OnTextChanged", function(self)
		db.profile.settings[eb.setting] = self:GetText()
	end)

	eb:SetScript("OnEscapePressed", function()
		eb:ClearFocus()
	end)

	local text = eb:CreateFontString(nil,"ARTWORK", "GameFontHighlight") 
	text:SetPoint("LEFT", eb, "RIGHT", 6, -1)
	text:SetText(description)
	return heightOffset - 25, eb, text
end

function LST:AddSyncButtonToOptions(heightOffset, LSTSettingsScrollChild)
	local syncEB = nil;
	local syncText = nil;
	heightOffset, syncEB, syncText = LST:AddOptionEditbox("syncTargetEditBox", LSTSettingsScrollChild, "syncTarget", L["Send data to this alt"], heightOffset, 100)

	local syncButton = CreateFrame("Button", "LSTSendDataButton", LSTSettingsScrollChild, BackdropTemplateMixin and "BackdropTemplate");
	Backdrop = {
		bgFile = "Interface\\AddOns\\LegendaryStockTracker\\Assets\\Plain.tga",
		edgeFile = "Interface/Buttons/WHITE8X8",
		tile = true, tileSize = 0, edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 0},
	}
	syncButton:SetBackdrop(Backdrop)
	syncButton:SetBackdropColor(0.25,0.25,0.25,0.9)
	syncButton:SetBackdropBorderColor(0,0,0,1)
	syncButton:SetSize(200,24)
	syncButton.HighlightTexture = syncButton:CreateTexture()
	syncButton.HighlightTexture:SetColorTexture(1,1,1,.3)
	syncButton.HighlightTexture:SetPoint("TOPLEFT")
	syncButton.HighlightTexture:SetPoint("BOTTOMRIGHT")
	syncButton:SetHighlightTexture(syncButton.HighlightTexture)
	syncButton.PushedTexture = syncButton:CreateTexture()
	syncButton.PushedTexture:SetColorTexture(.9,.8,.1,.3)
	syncButton.PushedTexture:SetPoint("TOPLEFT")
	syncButton.PushedTexture:SetPoint("BOTTOMRIGHT")
	syncButton:SetPushedTexture(syncButton.PushedTexture)
	local padding = 4;
	local xOffset = 0;
	syncButton:SetPoint("TOPLEFT", syncText, "TOPLEFT", -padding + xOffset, padding + 2);
	syncButton:SetPoint("BOTTOMRIGHT", syncText, "BOTTOMRIGHT", padding + xOffset, -padding);
	syncText:SetParent(syncButton);
	syncButton:SetScript("OnClick", function(self) LST:SendDataToSyncTarget() end)
	return heightOffset;
end

function LST:OnEnable()

end

function LST:OnDisable()

end

function LST:GetAllItemsInBags()
	bagItemLinks = {}
	bagItemCount = 0
	db.factionrealm.characters[playerName].bagItemLinks = {}
	db.factionrealm.characters[playerName].bagItemCount = 0
    for bag=0,NUM_BAG_SLOTS do
        for slot=1,GetContainerNumSlots(bag) do
			if not (GetContainerItemID(bag,slot) == nil) then 
				bagItemLinks[#bagItemLinks+1] = (select(7,GetContainerItemInfo(bag,slot)));
				bagItemCount = bagItemCount + 1;
				db.factionrealm.characters[playerName].bagItemLinks[#db.factionrealm.characters[playerName].bagItemLinks + 1] = (select(7,GetContainerItemInfo(bag,slot)));
				db.factionrealm.characters[playerName].bagItemCount = db.factionrealm.characters[playerName].bagItemCount + 1;
			end
        end
	end
end

function LST:GetAllItemsInBank(event)
	if(event ~= nil) then
		if(event == "BANKFRAME_OPENED") then
			LST:RegisterEvent("BANKFRAME_CLOSED", "GetAllItemsInBank");
			isBankOpen = true;
		elseif(event == "BANKFRAME_CLOSED") then
			LST:UnregisterEvent("BANKFRAME_CLOSED", "GetAllItemsInBank");
			isBankOpen = false;
		end
	end

	if(isBankOpen == true) then
		bankItemLinks = {}
		bankItemCount = 0
		db.factionrealm.characters[playerName].bankItemLinks = {}
		db.factionrealm.characters[playerName].bankItemCount = 0
		--go through all bank bag slots
		for bag=NUM_BAG_SLOTS+1,NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			for slot=1,GetContainerNumSlots(bag) do
				if not (GetContainerItemID(bag,slot) == nil) then 
					bankItemLinks[#bankItemLinks+1] = (select(7,GetContainerItemInfo(bag,slot)));
					bankItemCount = bankItemCount + 1;
					db.factionrealm.characters[playerName].bankItemLinks[#db.factionrealm.characters[playerName].bankItemLinks + 1] = (select(7,GetContainerItemInfo(bag,slot)));
					db.factionrealm.characters[playerName].bankItemCount = db.factionrealm.characters[playerName].bankItemCount + 1;
				end
			end
		end
		--go through default 28 bank spaces
		for slot=1,GetContainerNumSlots(-1) do
			if not (GetContainerItemID(-1,slot) == nil) then 
				bankItemLinks[#bankItemLinks+1] = (select(7,GetContainerItemInfo(-1,slot)));
				bankItemCount = bankItemCount + 1;
				db.factionrealm.characters[playerName].bankItemLinks[#db.factionrealm.characters[playerName].bankItemLinks + 1] = (select(7,GetContainerItemInfo(-1,slot)));
				db.factionrealm.characters[playerName].bankItemCount = db.factionrealm.characters[playerName].bankItemCount + 1;
			end
		end
	end
end

function LST:GetAllItemsInAH()
	if(C_AuctionHouse.GetNumOwnedAuctions() ~= 0) then
		ahItemLinks = {}
		ahItemCount = 0
		db.factionrealm.characters[playerName].ahItemLinks = {}
		db.factionrealm.characters[playerName].ahItemCount = 0
		local numOwnedAuctions = C_AuctionHouse.GetNumOwnedAuctions()
		for i=1, numOwnedAuctions do
			local auctionInfo = C_AuctionHouse.GetOwnedAuctionInfo(i)
			if(auctionInfo.status == 0) then 
				ahItemLinks[#ahItemLinks+1] = auctionInfo.itemLink;
				ahItemCount = ahItemCount + 1;
				db.factionrealm.characters[playerName].ahItemLinks[#db.factionrealm.characters[playerName].ahItemLinks + 1] = auctionInfo.itemLink;
				db.factionrealm.characters[playerName].ahItemCount = db.factionrealm.characters[playerName].ahItemCount + 1;
			end
		end
	end
end

function LST:GetAllItemsInMailbox()
	mailboxItemLinks = {}
	mailboxItemCount = 0
	db.factionrealm.characters[playerName].mailboxItemLinks = {}
	db.factionrealm.characters[playerName].mailboxItemCount = 0
	for i=1, GetInboxNumItems() do
		for j=1,ATTACHMENTS_MAX_RECEIVE do 
			if(GetInboxItemLink(i, j) ~= nil) then
				mailboxItemLinks[#mailboxItemLinks+1] = GetInboxItemLink(i, j);
				mailboxItemCount = mailboxItemCount + 1;
				db.factionrealm.characters[playerName].mailboxItemLinks[#db.factionrealm.characters[playerName].mailboxItemLinks + 1] = GetInboxItemLink(i, j);
				db.factionrealm.characters[playerName].mailboxItemCount = db.factionrealm.characters[playerName].mailboxItemCount + 1;
			end
		end
	end
end

function LST:GetAllItemsInGuildBank()
	local guildBankTabCount = GetNumGuildBankTabs()
	guildName = select(1,GetGuildInfo("player"));
	if(guildBankTabCount > 0 and GetGuildBankTabInfo(1) ~= nil) then
		GuildBankItemLinks = {}
		GuildBankItemCount = 0
		db.factionrealm.guilds[guildName].GuildBankItemLinks = {}
		db.factionrealm.guilds[guildName].GuildBankItemCount = 0
		for tab=1,guildBankTabCount do
			for slot=1,GUILD_BANK_SLOTS_PER_TAB do
				if not (GetGuildBankItemInfo(tab,slot) == nil) then 
					GuildBankItemLinks[#GuildBankItemLinks+1] = GetGuildBankItemLink(tab,slot);
					GuildBankItemCount = GuildBankItemCount + 1;
					db.factionrealm.guilds[guildName].GuildBankItemLinks[#db.factionrealm.guilds[guildName].GuildBankItemLinks + 1] = GetGuildBankItemLink(tab,slot);
					db.factionrealm.guilds[guildName].GuildBankItemCount = db.factionrealm.guilds[guildName].GuildBankItemCount + 1;
				end
			end
		end
	end
end

function LST:GetGearFromItems()
	gearLinks = {}
	for i=1, #itemLinks do
		if select(12, GetItemInfo(itemLinks[i])) == 4 then 
			gearLinks[#gearLinks+1] = itemLinks[i]
		end
	end
end

function LST:AddAllItemsToList()
	itemLinks = {}
	if(db.profile.settings.includeBags) then
		if(db.profile.settings.includeCachedData) then
			LST:AddItemsToList("bagItemLinks")
		else
			for i=1, #bagItemLinks do
				itemLinks[#itemLinks+1] = bagItemLinks[i]
			end
		end
	end
	if(db.profile.settings.includeBank) then
		if(db.profile.settings.includeCachedData) then
			LST:AddItemsToList("bankItemLinks")
		else
			for i=1, #bankItemLinks do
				itemLinks[#itemLinks+1] = bankItemLinks[i]
			end
		end
	end
	if(db.profile.settings.includeAH) then
		if(db.profile.settings.includeCachedData) then
			LST:AddItemsToList("ahItemLinks")
		else
			for i=1, #ahItemLinks do
				itemLinks[#itemLinks+1] = ahItemLinks[i]
			end
		end
	end
	if(db.profile.settings.includeMail) then
		if(db.profile.settings.includeCachedData) then
			LST:AddItemsToList("mailboxItemLinks")
		else
			for i=1, #mailboxItemLinks do
				itemLinks[#itemLinks+1] = mailboxItemLinks[i]
			end
		end
	end
	if(db.profile.settings.IncludeGuild) then
		if(db.profile.settings.includeCachedData) then
			for key,val in pairs(db.factionrealm.guilds) do
				for i=1, #db.factionrealm.guilds[key]["GuildBankItemLinks"] do
					itemLinks[#itemLinks+1] = db.factionrealm.guilds[key]["GuildBankItemLinks"][i]
				end
			end
		else
			for i=1, #GuildBankItemLinks do
				itemLinks[#itemLinks+1] = GuildBankItemLinks[i]
			end
		end
	end
end

function LST:AddItemsToList(itemSource)
	for key,val in pairs(db.factionrealm.characters) do
		for i=1, #db.factionrealm.characters[key][itemSource] do
			itemLinks[#itemLinks+1] = db.factionrealm.characters[key][itemSource][i]
		end
	end
end

function LST:GetShadowlandsLegendariesFromGear()
	legendaryLinks = {}
	for i=1, #gearLinks do
		if (select(3, GetItemInfo(gearLinks[i])) == 1)  then 
			local detailedItemLevel = GetDetailedItemLevelInfo(gearLinks[i])
			if (detailedItemLevel > 175) and (detailedItemLevel < 300) then --leaving ilvl room for future upgradres (max 235 at time of writing)
				legendaryLinks[#legendaryLinks+1] = gearLinks[i]
			end
		end
	end
end

function LST:CountLegendariesByRank()
	LST:CountLegendariesByRankWithoutSyncdata();

	if(db.profile.settings.includeCachedData) then
		for account, accountdata in pairs(db.factionrealm.syncData) do
			for id, data in pairs (accountdata["legendaries"]) do
				for rank, count in pairs(data["stock"]) do
					LegendaryItemData[id]["stock"][rank] = LegendaryItemData[id]["stock"][rank] + count;
					if(db.profile.settings.loadUnownedLegendaries == false and count > 0) then
						LST:UpdateTsmPrices(id, rank);
					end
				end
			end
		end
	end
end

function LST:CountLegendariesByRankWithoutSyncdata()
	for id, data in pairs (LegendaryItemData) do
		for rank, count in pairs(LegendaryItemData[id]["stock"]) do
			LegendaryItemData[id]["stock"][rank] = 0;
		end
	end
	
	TSMPriceDataByRank = {}
	for i=1, #legendaryLinks do
		local itemID = select(3, strfind(legendaryLinks[i], "item:(%d+)"));
		local detailedItemLevel = GetDetailedItemLevelInfo(legendaryLinks[i]);
		local rank = 0;
		if detailedItemLevel == 190 then
			rank = 1;
		elseif detailedItemLevel == 210 then
			rank = 2;
		elseif detailedItemLevel == 225 then
			rank = 3;
		elseif detailedItemLevel == 235 then
			rank = 4;
		end
		LegendaryItemData[itemID]["stock"][rank] = LegendaryItemData[itemID]["stock"][rank] + 1;
		if(db.profile.settings.loadUnownedLegendaries == false) then
			LST:UpdateTsmPrices(itemID, rank);
		end
	end
end

function LST:GetUnlockedCraftRank(itemID, includeSyncData)
	if(includeSyncData == nil) then
		includeSyncData = true;
	end
	local unlockedRank  = 0;
	if(db.profile.settings.includeCachedData) then
		for key,val in pairs(db.factionrealm.characters) do
			if(db.factionrealm.characters[key].unlockedLegendaryCraftRanks[itemID] ~= nil and db.factionrealm.characters[key].unlockedLegendaryCraftRanks[itemID] > unlockedRank) then
				unlockedRank = db.factionrealm.characters[key].unlockedLegendaryCraftRanks[itemID];
			end
		end
		if(includeSyncData == true) then
			for account,data in pairs(db.factionrealm.syncData) do
				if(data ~= nil and data["legendaries"] ~= nil and data["legendaries"][itemID] ~= nil and data["legendaries"][itemID]["canCraft"] > unlockedRank) then
					unlockedRank = data["legendaries"][itemID]["canCraft"];
				end
			end
		end
	else
		unlockedRank = LegendaryItemData[itemID]["recipeUnlocked"];
	end
	return unlockedRank;
end

function LST:UpdateRestockList()
	RestockList = {}
	local nameTable = LST:createNameTable()
	local restockAmount = tonumber(db.profile.settings.restockAmount)
	for item=1, #nameTable do
		for rank=1, numRanks do
			if(not db.profile.settings.onlyRestockCraftable or (db.profile.settings.onlyRestockCraftable and LST:GetUnlockedCraftRank(nameTable[item]) >= rank)) then
				local currentStock = tonumber(LST:GetStockCount(nameTable[item], rank))
				if currentStock < restockAmount and restockAmount - currentStock >= tonumber(db.profile.settings.minrestockAmount) then 
					if(IsTSMLoaded == false or db.profile.settings.showPricing == false) then
						table.insert(RestockList, {LegendaryItemData[nameTable[item]]["name"] , rank, restockAmount - currentStock, 0})
					else
						if tonumber(LST:GetMinBuyoutMinusAuctionOpMin(nameTable[item], rank)) > tonumber(db.profile.settings.minProfit) then
							table.insert(RestockList, {LegendaryItemData[nameTable[item]]["name"], rank, restockAmount - currentStock, LST:GetMinBuyoutMinusAuctionOpMin(nameTable[item], rank)})
						end
					end
				end
			end
		end
	end
end

function LST:GenerateExportText()
	local NameTable = LST:createNameTable()
	local text = ""
	if(IsTSMLoaded == false or db.profile.settings.showPricing == false) then
		text = L["Item name, Rank 1, Rank 2, Rank 3,  Rank 4\n"]
		for i=1, #NameTable do 
			text = text .. LegendaryItemData[NameTable[i]]["name"] .. "," 
			.. LST:GetStockCount(NameTable[i], 1) .. "," 
			.. LST:GetStockCount(NameTable[i], 2) .. "," 
			.. LST:GetStockCount(NameTable[i], 3) .. "," 
			.. LST:GetStockCount(NameTable[i], 4) .. "\n" 
		end
	else
		text = L["Item name, Rank 1, Profit Rank 1, Rank 2, Profit Rank 2, Rank 3, Profit Rank 3, Rank 4, Profit Rank 4\n"]
		for i=1, #NameTable do 
			text = text .. LegendaryItemData[NameTable[i]]["name"] .. "," 
			.. LST:GetStockCount(NameTable[i], 1) .. "," .. tostring(LST:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 1)) .. ","
			.. LST:GetStockCount(NameTable[i], 2) .. "," .. tostring(LST:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 2)) .. ","
			.. LST:GetStockCount(NameTable[i], 3) .. "," .. tostring(LST:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 3)) .. ","
			.. LST:GetStockCount(NameTable[i], 4) .. "," .. tostring(LST:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 4)) .. "\n"
		end
	end
	return text
end

function LST:createNameTable()
	local NameTable = {} --nametable is now "list of items to export"
	if(db.profile.settings.loadUnownedLegendaries == false) then
		for id, data in pairs (LegendaryItemData) do
			local count = 0;
			for rank, data in pairs(LegendaryItemData[id]["stock"]) do
				count = count + data;
			end
			if(count > 0 ) then
				table.insert(NameTable, id) 
			end
		end
		table.sort(NameTable)
	else
		TSMPriceDataByRank = {}
		for id, data in pairs(LegendaryItemData) do 
			table.insert(NameTable, id)
			LST:UpdateTsmPriceForAllRanks(id)
		end
		table.sort(NameTable)	
	end
	return NameTable
end

function LST:CreateRestockSheet(frame)
	LST:UpdateRestockList()
	local NameTable = LST:createNameTable()
	if(fontStringPool == nil) then
		fontStringPool = CreateFontStringPool(frame, "OVERLAY", nil, "GameFontNormal", FontStringPool_Hide)
	else
		fontStringPool:ReleaseAll()
	end
	local sheet = {}
	local titles = {LST:CreateTableTitle(frame, L["Item"]), LST:CreateTableTitle(frame, L["Amount"]), LST:CreateTableTitle(frame, L["Profit"])}
	table.insert(sheet, titles)
	for i=1, #RestockList do 
		row = 
		{
			LST:CreateTableElement(frame, RestockList[i][1] .. " - " .. L["Rank"] .. " " .. RestockList[i][2],  1, 1, 1, 1),
			LST:CreateTableElement(frame, RestockList[i][3],  1, 1, 1, 1),
			LST:CreateTableElement(frame, RestockList[i][4],  1, 1, 1, 1)
		}
		table.insert(sheet, row)
	end

	LST:CreateFrameSheet(frame, sheet, 3)
end

function LST:CreateTableSheet(frame)
	local NameTable = LST:createNameTable()
	if(fontStringPool == nil) then
		fontStringPool = CreateFontStringPool(frame, "OVERLAY", nil, "GameFontNormal", FontStringPool_Hide)
	else
		fontStringPool:ReleaseAll()
	end
	local sheet = {}
	local maxwidth = {};
	if(IsTSMLoaded == false or db.profile.settings.showPricing == false) then
		local titles = {LST:CreateTableTitle(frame, L["Item name"]), LST:CreateTableTitle(frame, L["Rank 1"]), LST:CreateTableTitle(frame, L["Rank 2"]), LST:CreateTableTitle(frame, L["Rank 3"]), LST:CreateTableTitle(frame, L["Rank 4"])}
		table.insert(sheet, titles)
		maxWidth = {0,0,0,0,0}
		local stockSum = {0,0,0,0}
		for i=1, #NameTable do 
			local stock = {0,0,0,0}
			for j=1, 4 do
				stock[j] = LST:GetStockCount(NameTable[i], j);
				stockSum[j] = stockSum[j] + stock[j];
			end
			row = 
			{
				LST:CreateTableElement(frame, LegendaryItemData[NameTable[i]]["name"],  1, 1, 1, 1),
				LST:CreateTableElement(frame, stock[1], LST:GetTableStockFont(stock[1])), 
				LST:CreateTableElement(frame, stock[2], LST:GetTableStockFont(stock[2])), 
				LST:CreateTableElement(frame, stock[3], LST:GetTableStockFont(stock[3])), 
				LST:CreateTableElement(frame, stock[4], LST:GetTableStockFont(stock[4]))
			}
			table.insert(sheet, row)
		end
		row = 
		{
			LST:CreateTableElement(frame, L["Total"] .. (stockSum[1] + stockSum[2] + stockSum[3] + stockSum[4]),  1, 1, 1, 1),
			LST:CreateTableElement(frame, stockSum[1], 1, 1, 1, 1), 
			LST:CreateTableElement(frame, stockSum[2], 1, 1, 1, 1), 
			LST:CreateTableElement(frame, stockSum[3], 1, 1, 1, 1), 
			LST:CreateTableElement(frame, stockSum[4], 1, 1, 1, 1)
		}
		table.insert(sheet, row)
	else
		local titles = {LST:CreateTableTitle(frame, L["Item name"]), LST:CreateTableTitle(frame, L["R1"]), LST:CreateTableTitle(frame, L["Profit R1"]), LST:CreateTableTitle(frame, L["R2"]),
			LST:CreateTableTitle(frame, L["Profit R2"]), LST:CreateTableTitle(frame, L["R3"]), LST:CreateTableTitle(frame, L["Profit R3"]), LST:CreateTableTitle(frame, L["R4"]), LST:CreateTableTitle(frame, "Profit R4")}
		table.insert(sheet, titles)
		maxWidth = {0,0,0,0,0,0,0,0,0}
		local stockSum = {0,0,0,0}
		local priceSum = {0,0,0,0}
		local profitSum = {0,0,0,0}
		for i=1, #NameTable do 
			local stock = {0,0,0,0}
			local price = {0,0,0,0}
			local profit = {0,0,0,0}
			for j=1, 4 do
				stock[j] = LST:GetStockCount(NameTable[i], j);
				price[j] = LST:GetMinBuyout(NameTable[i], j);
				profit[j] = LST:GetMinBuyoutMinusAuctionOpMin(NameTable[i], j);
				stockSum[j] = stockSum[j] + stock[j];
				priceSum[j] = priceSum[j] + (stock[j] * price[j]);
				profitSum[j] = profitSum[j] + (stock[j] * profit[j]);
			end
			row = 
			{
				LST:CreateTableElement(frame, LegendaryItemData[NameTable[i]]["name"], 1, 1, 1, 1),
				LST:CreateTableElement(frame, stock[1], LST:GetTableStockFont(stock[1], tostring(profit[1]))), LST:CreateTableElement(frame, tostring(profit[1]), LST:GetTablePriceFont(tostring(profit[1]))),
				LST:CreateTableElement(frame, stock[2], LST:GetTableStockFont(stock[2], tostring(profit[2]))), LST:CreateTableElement(frame, tostring(profit[2]), LST:GetTablePriceFont(tostring(profit[2]))),
				LST:CreateTableElement(frame, stock[3], LST:GetTableStockFont(stock[3], tostring(profit[3]))), LST:CreateTableElement(frame, tostring(profit[3]), LST:GetTablePriceFont(tostring(profit[3]))),
				LST:CreateTableElement(frame, stock[4], LST:GetTableStockFont(stock[4], tostring(profit[4]))), LST:CreateTableElement(frame, tostring(profit[4]), LST:GetTablePriceFont(tostring(profit[4])))
			}
			table.insert(sheet, row)		
		end
		table.insert(sheet, LST:CreateTablePriceRowWhite(frame, L["Total per rank (profit): "], stockSum[1], LST:AddComasEveryThousand(profitSum[1]), stockSum[2], LST:AddComasEveryThousand(profitSum[2]), stockSum[3], LST:AddComasEveryThousand(profitSum[3]), stockSum[4], LST:AddComasEveryThousand(profitSum[4])))
		table.insert(sheet, LST:CreateTablePriceRowWhite(frame, L["Total per rank (min price): "], stockSum[1], LST:AddComasEveryThousand(priceSum[1]), stockSum[2], LST:AddComasEveryThousand(priceSum[2]), stockSum[3], LST:AddComasEveryThousand(priceSum[3]), stockSum[4], LST:AddComasEveryThousand(priceSum[4])))
		table.insert(sheet, LST:CreateTablePriceRowWhite(frame, L["Total (profit): "], (stockSum[1] + stockSum[2] + stockSum[3] + stockSum[4]), LST:AddComasEveryThousand(profitSum[1] + profitSum[2] + profitSum[3] + profitSum[4]), "","","","","",""))
		table.insert(sheet, LST:CreateTablePriceRowWhite(frame, L["Total (min price): "], (stockSum[1] + stockSum[2] + stockSum[3] + stockSum[4]), LST:AddComasEveryThousand(priceSum[1] + priceSum[2] + priceSum[3] + priceSum[4]), "","","","","",""))
	end
	LST:CreateFrameSheet(frame, sheet, #maxWidth)
end

function LST:GetColorWhite()
	return 1, 1, 1, 1
end

function LST:CreateTablePriceRowWhite(frame, title, text1, text2, text3, text4, text5, text6, text7, text8)
	row = 
	{
		LST:CreateTableElement(frame, title, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text1, LST:GetColorWhite()), LST:CreateTableElement(frame, text2, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text3, LST:GetColorWhite()), LST:CreateTableElement(frame, text4, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text5, LST:GetColorWhite()), LST:CreateTableElement(frame, text6, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text7, LST:GetColorWhite()), LST:CreateTableElement(frame, text8, LST:GetColorWhite())
	}
	return row;
end

function LST:CreateTableRowWhite(frame, title, text1, text2, text3, text4)
	row = 
	{
		LST:CreateTableElement(frame, title, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text1, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text2, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text3, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text4, LST:GetColorWhite())
	}
	return row;

end

function LST:CreateFrameSheet(frame, table, numColumns)
	local sheet  = {}
	local maxWidth = {}
	local xStartValue = 0
	local xPosition = xStartValue
	local yPosition = 0
	local YDIFF = 15
	local XDIFF = 15
	maxWidth = {}
	for i=1, numColumns do
		maxWidth[i] = 0
	end

	for i=1, #table do 
		for j=1, #table[i] do
			LST:CompareTableValue(frame, maxWidth, j, table[i][j][2])
		end
	end
	for i=1, #table do
		for j=1, #table[i] do
			LST:SetElementPosition(table[i][j][1], xPosition, yPosition)
			xPosition = xPosition + XDIFF + maxWidth[j]
		end
		xPosition = xStartValue
		yPosition = yPosition - YDIFF
		--LST:AddTableLine(frame, yPosition)
	end
end

function LST:GetTablePriceFont(stringValue)
	if(tonumber(db.profile.settings.minProfit) > 0 and tonumber(stringValue) > tonumber(db.profile.settings.minProfit)) then
		return 0.15, 1, 0.15, 1
	elseif(tonumber(stringValue) < 0) then
		return 1, 0.15, 0.15, 1
	else 
		return 1, 1, 1, 1
	end
end

function LST:GetTableStockFont(value, price)
	if(value < tonumber(db.profile.settings.restockAmount)) then
		if(db.profile.settings.showPricing == true and price ~= nil) then
			if(tonumber(price) > tonumber(db.profile.settings.minProfit)) then 
				return 0, 0.5, 1, 1
			else 
				return 1, 1, 1, 1
			end
		else
			return 0, 0.75, 1, 1
		end
	else 
		return 1, 1, 1, 1
	end
end

function LST:SetElementPosition(element, x, y)
	element:SetPoint("LEFT", x, 0)
	element:SetPoint("TOP", 0, y)
end

function LST:CreateTableElement(frame, text, r, g, b, a)
	local fontString = fontStringPool:Acquire()
	fontString:SetParent(frame)
	fontString:SetTextColor(r,g,b,a)
	fontString:SetJustifyH("LEFT")
	fontString:SetJustifyV("MIDDLE")
	fontString:SetPoint("LEFT", 15, 0)
	fontString:SetPoint("TOP", 0, -15)
	fontString:SetText(text)
	fontString:Show()
	return {fontString, fontString:GetStringWidth(text)}
end

function LST:CreateTableTitle(frame, text)
	local fontString = fontStringPool:Acquire()
	fontString:SetParent(frame)
	fontString:SetTextColor(1,0.9,0,1)
	--fontString:SetFontObject("GameFontNormal")
	fontString:SetJustifyH("CENTER")
	fontString:SetJustifyV("MIDDLE")
	fontString:SetPoint("LEFT", 15, 0)
	fontString:SetPoint("TOP", 0, -15)
	fontString:SetText(text)
	fontString:Show()
	return {fontString, fontString:GetStringWidth(text)}
end

function LST:CompareTableValue(frame, table, index, toCompare)
	if (toCompare > table[index]) then
		table[index] = toCompare
	end
end

function LST:AddTableLine(frame, yPosition)
	local line = frame:CreateLine()
	line:SetThickness(1)
	line:SetColorTexture(0.6,0.6,0.6,1)
	line:SetStartPoint("TOPLEFT", -3, yPosition + 2)
	line:SetEndPoint("TOPRIGHT", 3, yPosition + 2)
end

function LST:AddEmptyTsmPriceDataEntryIfNotPresent(itemName)
	if (TSMPriceDataByRank[itemName] == nil) then
		TSMPriceDataByRank[itemName] = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}} --leaving room for up to 10 legendary ranks
	end
end

function LST:GetMinBuyoutMinusAuctionOpMin(name, rank)
	return tonumber(TSMPriceDataByRank[name][rank][1] - TSMPriceDataByRank[name][rank][2]);
end

function LST:GetMinBuyout(name, rank)
	return tonumber(TSMPriceDataByRank[name][rank][1]);
end

function LST:UpdateTsmPriceForAllRanks(itemName)
	LST:UpdateTsmPrices(itemName, 1)
	LST:UpdateTsmPrices(itemName, 2)
	LST:UpdateTsmPrices(itemName, 3)
	LST:UpdateTsmPrices(itemName, 4)
end

function LST:UpdateTsmPrices(itemName, rank)
	LST:AddEmptyTsmPriceDataEntryIfNotPresent(itemName)
	local ItemPrices = TSMPriceDataByRank[itemName]
	if(IsTSMLoaded ~= true) then
		ItemPrices[rank][1] = 0
		ItemPrices[rank][2] = 0
		return nil
	end
	local tsmString = "i:" .. itemName;
	if(rank == 1) then
		tsmString = tsmString .. Rank1BonusIDs
	elseif(rank == 2) then
		tsmString = tsmString .. Rank2BonusIDs
	elseif(rank == 3) then
		tsmString = tsmString .. Rank3BonusIDs
	elseif(rank == 4) then
		tsmString = tsmString .. Rank4BonusIDs
	end
	tsmstring = TSM_API.ToItemString(tsmString)
	ItemPrices[rank][1] = LST:ConvertTsmPriceToGold(TSM_API.GetCustomPriceValue("DBMinBuyout", tsmString))
	ItemPrices[rank][2] = LST:ConvertTsmPriceToGold(TSM_API.GetCustomPriceValue("AuctioningOpMin", tsmString))
	if(ItemPrices[rank][1] == nil) then
		ItemPrices[rank][1] = LST:ConvertTsmPriceToGold(TSM_API.GetCustomPriceValue("AuctioningOpNormal", tsmString))
	end
	if(ItemPrices[rank][1] == nil or ItemPrices[rank][2] == nil) then
		ItemPrices[rank][1] = 0
		ItemPrices[rank][2] = 0
	end

	TSMPriceDataByRank[itemName] = ItemPrices
end

function LST:ConvertTsmPriceToGold(value)
	local string = tostring(value)
	if(string ~= "0") then
		string = string:sub(1, #string - 4)
	end
	if(tonumber(string) == nil or tonumber(string) <= 0) then
		return 0
	end
	return tonumber(string)
end

function LST:GetStockCount(itemID, rank)
	local count = 0;
	if (LegendaryItemData[itemID] ~= nil) then 
		if (LegendaryItemData[itemID]["stock"][rank] ~= nil) then 
			count = LegendaryItemData[itemID]["stock"][rank];
		end
	end
	return count;
end

function LST:CheckIfTSMIsRunning()
	IsTSMLoaded = select(1,IsAddOnLoaded("TradeSkillMaster"))
end

function LST:OnItemAdded(self, event, itemKey)
end

function LST:ScanAhPrices(item)
	if AuctionHouseFrame and AuctionHouseFrame:IsShown() then
		local itemKeys = {}
		itemKeys[1] = C_AuctionHouse.MakeItemKey(171419, 190, nil)
		itemKeys[2] = C_AuctionHouse.MakeItemKey(171419, 210, nil)
		itemKeys[3] = C_AuctionHouse.MakeItemKey(171419, 225, nil)
		itemKeys[4] = C_AuctionHouse.MakeItemKey(171419, 235, nil)
		C_AuctionHouse.SearchForItemKeys(itemKeys, {})
	end
end

function LST:GetKnownTradeSkillRecipes()
	local learnedRecipes = {};
	local recipes = C_TradeSkillUI.GetAllRecipeIDs();
	if not recipes or #recipes == 0 then 
		return learnedRecipes;
	end

	for _, recipeID in pairs(recipes) do
		local info = C_TradeSkillUI.GetRecipeInfo(recipeID);
		if info.learned then
			learnedRecipes[recipeID] = true; --set as key instead of value since legendaries will report multiple times (once per rank)
		end
	end
	return learnedRecipes;
end

function LST:IsTradeSkillRecipeSLLegendary(recipeInfo)
	if(recipeInfo["unlockedRecipeLevel"] == nil) then
		return false;
	end
	return true;
end

function LST:GetTradeSkillRecipeName(recipeInfo)
	return recipeInfo["name"];
end

function LST:GetSLLegendaryUnlockedLevel(recipeInfo)
	return recipeInfo["unlockedRecipeLevel"];
end

function LST:GetCraftResultItemId(recipeInfo)
	local recipeItemLink = C_TradeSkillUI.GetRecipeItemLink(recipeInfo["recipeID"])
	local itemID = select(3, strfind(recipeItemLink, "item:(%d+)"));
	return itemID;
end

function LST:UpdateLegendaryRecipes()
	local recipes = LST:GetKnownTradeSkillRecipes();
	for recipeID, val in pairs(recipes) do 
		local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID);
		if(LST:IsTradeSkillRecipeSLLegendary(recipeInfo)) then
			local itemID = LST:GetCraftResultItemId(recipeInfo);
			local unlockedLevel = LST:GetSLLegendaryUnlockedLevel(recipeInfo)
			db.factionrealm.characters[playerName].unlockedLegendaryCraftRanks[itemID] = unlockedLevel;
			LegendaryItemData[itemID]["recipeUnlocked"] = unlockedLevel;
		end
	end
end

function LST:OnCommReceived(prefix, payload, distribution, sender)
	local decoded = LibDeflate:DecodeForWoWAddonChannel(payload)
	if not decoded then return end
	local decompressed = LibDeflate:DecompressDeflate(decoded)
	if not decompressed then return end
	local success, data = LibSerialize:Deserialize(decompressed)
	if not success then return end
	print(L["LST: Received item data from "] .. sender)
	db.factionrealm.syncData[data["accID"]] = {}
	db.factionrealm.syncData[data["accID"]]["legendaries"] = {}
	local table = db.factionrealm.syncData[data["accID"]]["legendaries"]
	for id, data in pairs (data["legendaries"]) do
		table[id] = 
		{
			["canCraft"] = data[1],
			["stock"] = {data[2],  data[3], data[4], data[5]}
		}
	end
end

function LST:SendDataToSyncTarget()
	LST:SendDataToPlayer(db.profile.settings.syncTarget)
end

function LST:SendDataToPlayer(player)
	print(L["LST: Sending data to "] .. player)
	LST:CountLegendariesByRankWithoutSyncdata();
	local syncData = {
		["accID"] = db.factionrealm.accountUUID,
		["legendaries"] = {}
	}

	for id, data in pairs (LegendaryItemData) do
		local count = 0;
		for rank, data in pairs(LegendaryItemData[id]["stock"]) do
			count = count + data;
		end
		count = count + LST:GetUnlockedCraftRank(id, false); --save in separate var if "count" is ever used
		if(count > 0 ) then
			syncData["legendaries"][id] = {LST:GetUnlockedCraftRank(id, false), LegendaryItemData[id]["stock"][1], LegendaryItemData[id]["stock"][2], LegendaryItemData[id]["stock"][3], LegendaryItemData[id]["stock"][4]}
		end
	end

	LST:CountLegendariesByRank();

	local serialized = LibSerialize:Serialize(syncData)
	local compressed = LibDeflate:CompressDeflate(serialized)
	local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
	self:SendCommMessage("LST", encoded, "WHISPER", player, "NORMAL", LST:OnCommChunkSent())
end

function LST:OnCommChunkSent(arg, sentBytes, totalBytes)
	--print(sentBytes == totalBytes);
end

function LST:GenerateUUID()
	local random = math.random
	local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
	return string.gsub(template, '[xy]', function (c)
		local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
		return string.format('%x', v)
	end)
end



function LST:AddComasEveryThousand(number)

	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
  
	-- reverse the int-string and append a comma to all blocks of 3 digits
	int = int:reverse():gsub("(%d%d%d)", "%1,")
  
	-- reverse the int-string back remove an optional comma and put the 
	-- optional minus and fractional part back
	return minus .. int:reverse():gsub("^,", "") .. fraction
  end