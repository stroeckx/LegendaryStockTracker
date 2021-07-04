local addonName, globalTable = ...

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
	LST:GetAllItemsInBags();
    tt:AddLine("Legendary Stock Tracker")
    tt:AddLine(" ")
    tt:AddLine(L["Click or type /lst to show the main panel"])
    tt:AddLine(L["Items Scanned:"])
    tt:AddLine(LST:GetDataCounts())
  end
})

local LSTVersion = "v2.9"
--local db = nil
LST.db = nil
local LstockIcon = LibStub("LibDBIcon-1.0")
local LstockMainFrame = nil
local LSTTableScrollChild = nil
local LSTRestockScrollChild = nil
local tableFrame = nil
local restockFrame = nil
local exportFrame = nil

--all collections of items are stored separately for future expandability
LST.legendaryLinks = {}
local isBankOpen = false
local TSMPriceDataByRank = {}
local materialPrices = {}
local Rank1BonusIDs = "::2:1487:6716"
local Rank2BonusIDs = "::2:1507:6717"
local Rank3BonusIDs = "::2:1522:6718"
local Rank4BonusIDs = "::2:1532:6758"
local Rank5BonusIDs = "::2:1256:7450"
local Rank6BonusIDs = "::2:1257:7451"

local LegendaryItemData = 
{
	["171419"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["171412"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["171414"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["171416"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}},
	["171415"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["171417"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["171413"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}},
	["171418"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}},
	["178927"] = {["profession"] = 1418, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}},
	["178926"] = {["profession"] = 1418, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}},
	["173248"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["173249"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["173242"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}},
	["173245"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["173244"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}},
	["173246"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}},
	["173241"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["173243"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}},
	["173247"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["172321"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}},
	["172316"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["172317"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["172318"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}},
	["172319"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["172315"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["172314"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["172320"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}},
	["172329"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}},
	["172324"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}},
	["172326"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}},
	["172325"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["172327"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["172323"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["172322"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true},
	["172328"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0}, ["dominationSlot"] = true}
}
local SLProfessionsIds =
{
	[1418] = "Jewelcrafting",
	[1311] = "Blacksmithing",
	[1395] = "Tailoring",
	[1334] = "LeatherWorking"
}
local openedProfession = 0;

local IsTSMLoaded = false;
local fontStringPool = nil
local RestockList = {}
local numRanks = 6

local activeTab = nil
local exportTab = nil
local contentFrame = nil
local tabWidth = 150
local tabHeight = 24
local contentWidthOffset = 5
local contentHeightOffset = -25
local isfirstRestockAmountInputChange = true;

--LST.playerName = ""
local guildName = ""

local isMaterialPriceUpdated = false;
local isTSMPriceUpdated = false;

function LST:OnInitialize()
	-- init databroker
	LST.db = LibStub("AceDB-3.0"):New("LegendaryStockTrackerDB", {
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
				w = 1115,
				h = 655,
			},
			settings = 
			{
				showPricing = true,
				includeBags = true,
				includeBank = true,
				includeAH = true,
				includeMail = true,
				IncludeGuild = true,
				IncludeSyncData = true,
				minProfit = 1000,
				restockAmount = 2,
				restockAmountByRank = {0,0,0,0,0,0},
				minrestockAmount = 1,
				syncTarget = "charactername",
				onlyRestockCraftable = true,
				priceSource = L["LST Crafting"],
				restockDominationSlots = true,
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
					bagItemLegendaryLinks = {},
					bagItemLegendaryCount = 0,
					bankItemLegendaryLinks = {},
					bankItemLegendaryCount = 0,
					ahItemLegendaryLinks = {},
					ahItemLegendaryCount = 0,
					mailboxItemLegendaryLinks = {},
					mailboxItemLegendaryCount = 0,
					unlockedLegendaryCraftRanks = {}
				}
			},
			guilds = 
			{
				['*'] = 
				{
					guildName = "",
					GuildBankItemLegendaryLinks = {},
					GuildBankItemLegendaryCount = 0
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
			recipeData = 
			{
				materialList = 
				{
					--['*'] = ""
				},
				recipes = 
				{
					['*'] = 
					{
						name = "",
						ranks =
						{
				--			['*'] =  
				--			{
				--				['*'] =  
				--				{
				--					name = "",
				--					itemid = 0,
				--					numRequired = 0
				--				}
				--			}
						}
					}
				},
				vestiges = {}
			}
		}
	});

	LstockIcon:Register("LegendaryStockTracker", LstockLDB, LST.db.profile.minimap)
	--chat commands
    LST:RegisterChatCommand("lstock", "HandleChatCommand")
    LST:RegisterChatCommand("lst", "HandleChatCommand")
    LST:RegisterChatCommand("LST", "HandleChatCommand")
    LST:RegisterChatCommand("lstocktest", "Test")
    LST:RegisterChatCommand("tst", "tst")
    LST:RegisterChatCommand("lstSetSize", "SetMainFrameSize")
	LST:RegisterChatCommand("lstockscan", "ScanAhPrices")
	LST:RegisterChatCommand("lstsetrestock", "SetRestockFromChat")
	LST:RegisterChatCommand("lstprintrestock", "PrintRestockAmountByRank")
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
	LST:RegisterEvent("TRADE_SKILL_CLOSE", "OnTradeskillClosed")
	LST:RegisterEvent("BAG_UPDATE", "OnBagsUpdated")

	self:RegisterComm("LST")

	LST:CheckIfTSMIsRunning()
	LST.playerName = UnitName("player")
	--guildName = select(1,GetGuildInfo("player")); --doesn't work on login, only on reloads
	LST.db.factionrealm.characters[LST.playerName].characterName = LST.playerName;
	LST.db.factionrealm.characters[LST.playerName].classNameBase = select(1,UnitClassBase("player"));
	LST:GetAllItemsInBags();
	local item = {};
	for id,data in pairs(LegendaryItemData) do
		local iteminfo = GetItemInfo(id);
		if(iteminfo ~= nil ) then
			LST:ProcessItemInfo(id, true)
		end
	end
	if(LST.db.factionrealm.accountUUID == nil or LST.db.factionrealm.accountUUID == "") then
		LST.db.factionrealm.accountUUID = LST:GenerateUUID();
	end
	if(LST.db.profile.settings.restockAmountByRank[1] == 0 and LST.db.profile.settings.restockAmountByRank[2] == 0 and LST.db.profile.settings.restockAmountByRank[3] == 0 and LST.db.profile.settings.restockAmountByRank[4] == 0) then
		LST:SetRestockAmountByRank(LST.db.profile.settings.restockAmount, nil, nil, nil);
	end
end

function LST:tst()
	print(tostring(openedProfession))
	return nil;
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
	
end

function LST:SetMainFrameSize(value1, value2)
	--LST.db.profile.frame.width = value1
	--LST.db.profile.frame.height = value2
	--local f = LST:GetMainFrame()
	--f:SetSize(tonumber(value1), tonumber(value2))
end

function LST:GetDataCounts()
	local text = ""
	text = text .. L["Bags: "] .. LST:GetItemCounts("bagItemLegendaryCount") .. "\n"
	text = text .. L["Bank: "] .. LST:GetItemCounts("bankItemLegendaryCount") .. "\n"
	text = text .. L["AH: "] .. LST:GetItemCounts("ahItemLegendaryCount") .. "\n"
	text = text .. L["Mail: "] .. LST:GetItemCounts("mailboxItemLegendaryCount") .. "\n"
	local sum = 0
	local count = 0
	local altString = " ("
	for key,val in pairs(LST.db.factionrealm.guilds) do
		sum = sum + LST.db.factionrealm.guilds[key]["GuildBankItemLegendaryCount"];
		altString = altString .. LST.db.factionrealm.guilds[key]["GuildBankItemLegendaryCount"] .. " ";
		count = count + 1;
	end
	altString = altString:sub(1, #altString - 1);
	altString = altString .. ")";
	if(count == 0) then
		altString = "";
	end

	text = text .. L["Guild: "] .. sum .. altString .. "\n"
	return text
end

function LST:GetItemCounts(itemCountParameterName)
	local sum = 0
	local altString = " ("
	local count = 0
	local classColorEsc = ""
	for key,val in pairs(LST.db.factionrealm.characters) do
		sum = sum + LST.db.factionrealm.characters[key][itemCountParameterName];
		if(LST.db.factionrealm.characters[key].classNameBase ~= nil and LST.db.factionrealm.characters[key].classNameBase ~= "") then
			classColorEsc = "|c" .. C_ClassColor.GetClassColor(LST.db.factionrealm.characters[key].classNameBase):GenerateHexColor();
		else
			classColorEsc = "";
		end
		altString = altString .. classColorEsc .. LST.db.factionrealm.characters[key][itemCountParameterName] .. "|r ";
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
	if(f:IsShown()) then
		f:Hide()
	else
		LST:UpdateExportText()
		LST:UpdateTable()
		f:Show()
	end
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
	LST:GetAllItemsInBags();
	LST:GetAllItemsInBank() --if the bank is open at the time of command, update bank as well
	--LST:GetAllItemsInAH() auctions specifically not updated on command, as we don't know if the ah is closed or the player has no auctions. relying on OWNED_AUCTIONS_UPDATED to update those.
	--LST:GetAllItemsInMailbox() mailbox is updated anytime the mailbox is updated, no need to update on command 
	--LST:GetAllItemsInGuildBank()
end

function LST:GetLegendariesFromItems()
	LST:CheckIfTSMIsRunning()
	LST:AddAllItemsToList()
	LST:CountLegendariesByRank()
end

function LST:ShowTestFrame()
	local f = LST:GetMainFrame(UIParent)
	f:Show()
end

function LST:GetMainFrame(parent)
	if not LstockMainFrame then
		local mainFrameWidth = tonumber(LST.db.profile.frame.w)
		local mainFrameHeight = tonumber(LST.db.profile.frame.h)
		if(mainFrameWidth == nil) then
			mainFrameWidth = 1115
		end
		if(mainFrameHeight == nil) then
			mainFrameHeight = 655
		end
		local Backdrop = {
			bgFile = "Interface\\AddOns\\LegendaryStockTracker\\Assets\\Plain.tga",
			--edgeFile = temp,
			tile = false, tileSize = 0, edgeSize = 1,
			insets = {left = 1, right = 1, top = 1, bottom = 1},
		}
		local frameConfig = LST.db.profile.frame
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

		local versionText = f:CreateFontString(nil,"ARTWORK", "GameFontHighlight"); 
		versionText:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 5, 5);
		versionText:SetText(LSTVersion);

		--Export Frame
		exportFrame = LST:CreateOptionsContentFrame("LSTExportFrame", contentFrame, Backdrop)
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
		heightOffset = LST:AddOptionCheckbox("ShowPricingCheckButton", LSTSettingsScrollChild, "showPricing", L["Show profit (requires TSM operations)"], heightOffset)
		heightOffset = LST:AddOptionEditbox("MinProfitEditBox", LSTSettingsScrollChild, "minProfit", L["Min profit before restocking"], heightOffset, 45)
		heightOffset = LST:AddOptionEditbox("RestockAmountEditBox", LSTSettingsScrollChild, "restockAmount", L["Restock amount"], heightOffset, 25)
		heightOffset = LST:AddOptionEditbox("MinRestockAmountEditBox", LSTSettingsScrollChild, "minrestockAmount", L["Min restock amount"], heightOffset, 25)
		heightOffset = LST:AddOptionCheckbox("onlyRestockCraftableEditBox", LSTSettingsScrollChild, "onlyRestockCraftable", L["Only restock items I can craft"], heightOffset, 25)
		heightOffset = LST:AddOptionCheckbox("restockDominationSlots", LSTSettingsScrollChild, "restockDominationSlots", L["Restock domination slots"], heightOffset, 25)
		heightOffset = LST:AddDropdownMenu("LSTPriceSourceDropdown", LSTSettingsScrollChild, heightOffset);
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
		heightOffset = LST:AddOptionCheckbox("IncludeSyncDataCheckButton", LSTSettingsScrollChild, "IncludeSyncData", L["Include Synced Data"], heightOffset)
		heightOffset = heightOffset - 25
		heightOffset = LST:AddSyncButtonToOptions(heightOffset, LSTSettingsScrollChild);

		local clearCacheText = f:CreateFontString(nil,"ARTWORK", "GameFontHighlight") 
		clearCacheText:SetText(L["clear cache"])
		local clearCacheButton = LST:CreateSettingsButton("LSTClearCacheButton", LSTSettingsScrollChild, 90, 22);
		local padding = 4;
		local xOffset = 0;
		clearCacheButton:SetPoint("TOPLEFT", LSTSettingsScrollChild, "TOPLEFT", 0, heightOffset)
		heightOffset = heightOffset + 25;
		clearCacheText:SetParent(clearCacheButton);
		clearCacheText:SetPoint("LEFT", clearCacheButton, "LEFT", (90 - clearCacheText:GetStringWidth()) / 2, -1)
		clearCacheButton:SetScript("OnClick", function(self) LST:ClearItemCache() end)
		
		
		--table frame
		tableFrame = LST:CreateOptionsContentFrame("LSTtableFrame", contentFrame, BackdropTemplateMixin and "BackdropTemplate")
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
		restockFrame = LST:CreateOptionsContentFrame("LSTRestockFrame", contentFrame, Backdrop)
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

		LST:AddCraftButtonToRestock(restockFrame);

		--FAQ frame
		local faqFrame = LST:CreateOptionsContentFrame("LSTFAQFrame", contentFrame, Backdrop);
		faqFrame.title:SetText(L["FAQ"]);
		faqFrame.scrollframe = faqFrame.scrollframe or CreateFrame("ScrollFrame", "LSTFAQScrollFrame", faqFrame, BackdropTemplateMixin and "UIPanelScrollFrameTemplate");
		faqFrame.scrollframe:SetPoint("LEFT")
		faqFrame.scrollframe:SetPoint("RIGHT", -22, 0)
		faqFrame.scrollframe:SetPoint("TOP")
		faqFrame.scrollframe:SetPoint("BOTTOM")
		LSTFAQScrollChild =  faqFrame.scrollframe.scrollchild or CreateFrame("Frame", "LSTFAQScrollChild", faqFrame.scrollframe);
		LSTFAQScrollChild:SetSize(faqFrame.scrollframe:GetSize())
		faqFrame.scrollframe:SetScrollChild(LSTFAQScrollChild)
		LSTFAQScrollChild:SetPoint("LEFT");
		LSTFAQScrollChild:SetPoint("RIGHT");
		--LSTFAQScrollChild:SetHeight(faqFrame.scrollframe:GetHeight())

		--LSTFAQScrollChild:SetParent(faqFrame.scrollframe);
		LST:PopulateFAQFrame(LSTFAQScrollChild, faqFrame.scrollframe);

		--create tabs
		exportTab = LST:AddTab(tabList, tabWidth, 24, 3, exportFrame, L["Export"])
		LST:AddTab(tabList, tabWidth, 24, 2, settingsFrame, L["Settings"])
		local tab = LST:AddTab(tabList, tabWidth, 24, 1, tableFrame, L["Table"])
		LST:AddTab(tabList, tabWidth, 24, 4, restockFrame, L["Restock"])
		LST:AddTab(tabList, tabWidth, 24, 5, faqFrame, L["FAQ"])
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
		LstockMainFrame:Hide();
	end
	return LstockMainFrame
end

function LST:SetFrameMovable(f)
	local frameConfig = LST.db.profile.frame
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

function LST:PopulateFAQFrame(frame, frame2)
	local horizontalPadding = 0;
	local verticalOffset = -5
	local lastTextElement = nil;
	local text = frame:CreateFontString("FAQ_Intro","ARTWORK", "GameFontHighlight");
	text:SetPoint("TOPLEFT",frame, "TOPLEFT", 5, verticalOffset)
	text:SetPoint("RIGHT",frame, "RIGHT")
	text:SetText(L["FAQ_Intro"]);
	text:SetJustifyH("LEFT");
	lastTextElement = text;
	verticalOffset = -10;
	lastTextElement = LST:AddAnchoredFontString("FAQ_Stock_Title", frame, frame2, horizontalPadding, verticalOffset, "FAQ_Stock_Title", lastTextElement, "GameFontNormal");
	verticalOffset = -5;
	lastTextElement = LST:AddAnchoredFontString("FAQ_Stock_Description", frame, frame2, horizontalPadding, verticalOffset, "FAQ_Stock_Description", lastTextElement);
	verticalOffset = -10;
	lastTextElement = LST:AddAnchoredFontString("FAQ_Profit_Title", frame, frame2, horizontalPadding, verticalOffset, "FAQ_Profit_Title", lastTextElement, "GameFontNormal");
	verticalOffset = -5;
	lastTextElement = LST:AddAnchoredFontString("FAQ_Profit_Description", frame, frame2, horizontalPadding, verticalOffset, "FAQ_Profit_Description", lastTextElement);
	verticalOffset = -10;
	lastTextElement = LST:AddAnchoredFontString("FAQ_Restock_Title", frame, frame2, horizontalPadding, verticalOffset, "FAQ_Restock_Title", lastTextElement, "GameFontNormal");
	verticalOffset = -5;
	lastTextElement = LST:AddAnchoredFontString("FAQ_Restock_Description", frame, frame2, horizontalPadding, verticalOffset, "FAQ_Restock_Description", lastTextElement);
	verticalOffset = -10;
	lastTextElement = LST:AddAnchoredFontString("FAQ_Export_Title", frame, frame2, horizontalPadding, verticalOffset, "FAQ_Export_Title", lastTextElement, "GameFontNormal");
	verticalOffset = -5;
	lastTextElement = LST:AddAnchoredFontString("FAQ_Export_Description", frame, frame2, horizontalPadding, verticalOffset, "FAQ_Export_Description", lastTextElement);
	verticalOffset = -10;
	lastTextElement = LST:AddAnchoredFontString("FAQ_Syncing_Title", frame, frame2, horizontalPadding, verticalOffset, "FAQ_Syncing_Title", lastTextElement, "GameFontNormal");
	verticalOffset = -5;
	lastTextElement = LST:AddAnchoredFontString("FAQ_Syncing_Description", frame, frame2, horizontalPadding, verticalOffset, "FAQ_Syncing_Description", lastTextElement);
	verticalOffset = -10;
	lastTextElement = LST:AddAnchoredFontString("FAQ_IncorrectData_Title", frame, frame2, horizontalPadding, verticalOffset, "FAQ_IncorrectData_Title", lastTextElement, "GameFontNormal");
	verticalOffset = -5;
	lastTextElement = LST:AddAnchoredFontString("FAQ_IncorrectData_Description", frame, frame2, horizontalPadding, verticalOffset, "FAQ_IncorrectData_Description", lastTextElement);
	verticalOffset = -10;
	lastTextElement = LST:AddAnchoredFontString("FAQ_KnowIssues_Title", frame, frame2, horizontalPadding, verticalOffset, "FAQ_KnowIssues_Title", lastTextElement, "GameFontNormal");
	verticalOffset = -5;
	lastTextElement = LST:AddAnchoredFontString("FAQ_KnowIssues_Description", frame, frame2, horizontalPadding, verticalOffset, "FAQ_KnowIssues_Description", lastTextElement);
	verticalOffset = -20;
	lastTextElement = LST:AddAnchoredFontString("FAQ_Outro", frame, frame2, horizontalPadding, verticalOffset, "FAQ_Outro", lastTextElement);
end

function LST:AddAnchoredFontString(name, parent, parent2, horizontalOffset, verticalOffset, localizationKey, topAnchor, font)
	if(font == nil) then
		font = "GameFontHighlight";
	end
	local text = parent:CreateFontString(name,"ARTWORK", font);
	text:SetPoint("TOPLEFT",topAnchor, "BOTTOMLEFT", horizontalOffset, verticalOffset)
	text:SetPoint("RIGHT",parent2, "RIGHT", -horizontalOffset)
	text:SetText(L[localizationKey]);
	text:SetJustifyH("LEFT");
	return text;
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
	cb:SetChecked(LST.db.profile.settings[cb.setting])
	cb:SetScript("OnClick", function(cb)
		if cb:GetChecked() then
			LST.db.profile.settings[cb.setting] = true
		else
			LST.db.profile.settings[cb.setting] = false
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
	eb:SetText(LST.db.profile.settings[eb.setting])
	eb:SetScript("OnTextChanged", function(self)
		LST.db.profile.settings[eb.setting] = self:GetText()
		if(eb.setting == "restockAmount") then
			if(isfirstRestockAmountInputChange) then
				isfirstRestockAmountInputChange = false;
				return;
			else
				LST:SetRestockAmountByRank(LST.db.profile.settings.restockAmount, nil, nil, nil);
			end
		end
	end)

	eb:SetScript("OnEscapePressed", function()
		eb:ClearFocus()
	end)

	local text = eb:CreateFontString(nil,"ARTWORK", "GameFontHighlight") 
	text:SetPoint("LEFT", eb, "RIGHT", 6, -1)
	text:SetText(description)
	return heightOffset - 25, eb, text
end

function LST:AddDropdownMenu(name, parent, heightOffset)
	local dropDown = CreateFrame("FRAME", name, parent, BackdropTemplateMixin and "UIDropDownMenuTemplate")
	dropDown:SetPoint("TOPLEFT", parent, "TOPLEFT", -20, heightOffset);
	UIDropDownMenu_SetWidth(dropDown, 150)
	UIDropDownMenu_SetText(dropDown, "price source: " .. LST.db.profile.settings.priceSource)
	UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
			if (level or 1) == 1 then
				for _, title in ipairs{L["LST Crafting"], L["TSM operations"]} do
				info.text = title;
				info.menuList = title;
				info.arg1 = title;
				info.func = self.SetValue;
				if(title == LST.db.profile.settings.priceSource) then
					info.checked = true;
				else
					info.checked = false;
				end
				UIDropDownMenu_AddButton(info)
				end
			end
	end)

	function dropDown:SetValue(value)
		LST.db.profile.settings.priceSource = value;
		UIDropDownMenu_SetText(dropDown, "price source: " .. value)
		--CloseDropDownMenus()
	end

	return heightOffset - 20;
end

function LST:AddSyncButtonToOptions(heightOffset, LSTSettingsScrollChild)
	local syncEB = nil;
	local syncText = nil;
	heightOffset, syncEB, syncText = LST:AddOptionEditbox("syncTargetEditBox", LSTSettingsScrollChild, "syncTarget", L["Send data to this alt"], heightOffset, 100)
	local syncButton = LST:CreateSettingsButton("LSTSendDataButton", LSTSettingsScrollChild, 200, 24);
	local padding = 4;
	local xOffset = 0;
	syncButton:SetPoint("TOPLEFT", syncText, "TOPLEFT", -padding + xOffset, padding + 2);
	syncButton:SetPoint("BOTTOMRIGHT", syncText, "BOTTOMRIGHT", padding + xOffset, -padding);
	syncText:SetParent(syncButton);
	syncButton:SetScript("OnClick", function(self) LST:SendDataToSyncTarget() end)
	return heightOffset;
end

function LST:AddCraftButtonToRestock(restockFrame)
	local craftButton = CreateFrame("Button", "LSTCraftNextButton", restockFrame, BackdropTemplateMixin and "BackdropTemplate");
	Backdrop = {
		bgFile = "Interface\\AddOns\\LegendaryStockTracker\\Assets\\Plain.tga",
		edgeFile = "Interface/Buttons/WHITE8X8",
		tile = true, tileSize = 0, edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 0},
	}
	craftButton:SetBackdrop(Backdrop)
	craftButton:SetBackdropColor(0.25,0.25,0.25,0.9)
	craftButton:SetBackdropBorderColor(0,0,0,1)
	craftButton:SetSize(100,24)
	craftButton.HighlightTexture = craftButton:CreateTexture()
	craftButton.HighlightTexture:SetColorTexture(1,1,1,.3)
	craftButton.HighlightTexture:SetPoint("TOPLEFT")
	craftButton.HighlightTexture:SetPoint("BOTTOMRIGHT")
	craftButton:SetHighlightTexture(craftButton.HighlightTexture)
	craftButton.PushedTexture = craftButton:CreateTexture()
	craftButton.PushedTexture:SetColorTexture(.9,.8,.1,.3)
	craftButton.PushedTexture:SetPoint("TOPLEFT")
	craftButton.PushedTexture:SetPoint("BOTTOMRIGHT")
	craftButton:SetPushedTexture(craftButton.PushedTexture)
	craftButton:SetPoint("TOPLEFT", restockFrame, "BOTTOMLEFT", 0, 0);
	craftButton:SetScript("OnClick", function(self) LST:CraftNextRestockItem() end)

	local text = craftButton:CreateFontString(nil,"ARTWORK", "GameFontHighlight") 
	text:SetPoint("TOPLEFT")
	text:SetPoint("BOTTOMRIGHT")
	text:SetText("craft next")
end

function LST:OnEnable()

end

function LST:OnDisable()

end

function LST:OnBagsUpdated(bagIndex)
	LST:UpdateShownTab();
end

function LST:UpdateShownTab()
	if not LstockMainFrame then
		return nil
	end
	if(tableFrame:IsVisible()) then
		LST:UpdateTable();
	end
	if(exportFrame:IsVisible()) then
		LST:UpdateExportText();
	end
	if(restockFrame:IsVisible()) then
		LST:UpdateRestock();
	end
end

function LST:CountLegendariesByRank()
	LST:CountLegendariesByRankWithoutSyncdata();
	if(LST.db.profile.settings.priceSource == L["LST Crafting"]) then 
		LST:UpdateMaterialPrices();
	end
	if(LST.db.profile.settings.IncludeSyncData) then
		for account, accountdata in pairs(LST.db.factionrealm.syncData) do
			for id, data in pairs (accountdata["legendaries"]) do
				for rank, count in pairs(data["stock"]) do
					LegendaryItemData[id]["stock"][rank] = LegendaryItemData[id]["stock"][rank] + count;
				end
			end
		end
	end
end

function LST:GetLegendaryRankByItemLevel(itemlevel)
	local rank = 0;
	if itemlevel == 190 then
		rank = 1;
	elseif itemlevel == 210 then
		rank = 2;
	elseif itemlevel == 225 then
		rank = 3;
	elseif itemlevel == 235 then
		rank = 4;
	elseif itemlevel == 249 then
		rank = 5;
	elseif itemlevel == 262 then
		rank = 6;
	end
	return rank;
end

function LST:CountLegendariesByRankWithoutSyncdata()
	for id, data in pairs (LegendaryItemData) do
		for rank, count in pairs(LegendaryItemData[id]["stock"]) do
			LegendaryItemData[id]["stock"][rank] = 0;
		end
	end
	
	--if(isTSMPriceUpdated == false) then
		TSMPriceDataByRank = {}
	--end
	if(LST.db.profile.settings.priceSource == L["LST Crafting"]) then 
		LST:UpdateMaterialPrices();
	end
	for i=1, #LST.legendaryLinks do
		local itemID = select(3, strfind(LST.legendaryLinks[i], "item:(%d+)"));
		local detailedItemLevel = GetDetailedItemLevelInfo(LST.legendaryLinks[i]);
		if(detailedItemLevel == nil) then
			print(L["Incorrect itemlevel data received for item "] .. itemID .. L[", skipping data for this rank."])
			return;
		end
		local rank = LST:GetLegendaryRankByItemLevel(detailedItemLevel);
		LegendaryItemData[itemID]["stock"][rank] = LegendaryItemData[itemID]["stock"][rank] + 1;
	end
end

function LST:GetUnlockedCraftRank(itemID, includeSyncData)
	if(includeSyncData == nil) then
		includeSyncData = true;
	end
	local unlockedRank  = 0;
	for key,val in pairs(LST.db.factionrealm.characters) do
		if(LST.db.factionrealm.characters[key].unlockedLegendaryCraftRanks[itemID] ~= nil and LST.db.factionrealm.characters[key].unlockedLegendaryCraftRanks[itemID] > unlockedRank) then
			unlockedRank = LST.db.factionrealm.characters[key].unlockedLegendaryCraftRanks[itemID];
		end
	end
	if(includeSyncData == true) then
		for account,data in pairs(LST.db.factionrealm.syncData) do
			if(data ~= nil and data["legendaries"] ~= nil and data["legendaries"][itemID] ~= nil and data["legendaries"][itemID]["canCraft"] > unlockedRank) then
				unlockedRank = data["legendaries"][itemID]["canCraft"];
			end
		end
	end
	return unlockedRank;
end

function LST:CanCraft(itemID, rank)
	local unlockedRank = LST:GetUnlockedCraftRank(itemID);
	if(rank <= 4) then
		return unlockedRank >= rank;
	else
		if(LST.db.factionrealm.recipeData.vestiges[LegendaryItemData[itemID]["profession"]] ~= nil) then
			return unlockedRank + 2 >= rank
		end
	end
		
end

function LST:UpdateRestockList()
	RestockList = {};
	local nameTable = LST:createNameTable();
	local restockAmount = {};
	restockAmount[1] = tonumber(LST.db.profile.settings.restockAmountByRank[1]);
	restockAmount[2] = tonumber(LST.db.profile.settings.restockAmountByRank[2]);
	restockAmount[3] = tonumber(LST.db.profile.settings.restockAmountByRank[3]);
	restockAmount[4] = tonumber(LST.db.profile.settings.restockAmountByRank[4]);
	restockAmount[5] = tonumber(LST.db.profile.settings.restockAmountByRank[5]);
	restockAmount[6] = tonumber(LST.db.profile.settings.restockAmountByRank[6]);
	for item=1, #nameTable do
		for rank=1, numRanks do
			if(not LST.db.profile.settings.onlyRestockCraftable or (LST.db.profile.settings.onlyRestockCraftable and LST:CanCraft(nameTable[item], rank))) then
				local currentStock = tonumber(LST:GetStockCount(nameTable[item], rank))
				if currentStock < restockAmount[rank] and restockAmount[rank] - currentStock >= tonumber(LST.db.profile.settings.minrestockAmount) then 
					if(IsTSMLoaded == false or LST.db.profile.settings.showPricing == false) then
						table.insert(RestockList, {LegendaryItemData[nameTable[item]]["name"] , rank, restockAmount[rank] - currentStock, 0, nameTable[item]})
					else
						if(LST:GetMinBuyoutMinusAuctionOpMin(nameTable[item], rank) ~= L["not scanned"] ) then
							if(not LST.db.profile.settings.restockDominationSlots) then
								if(not LST:GetDominationSlotStatus(nameTable[item])) then
									if tonumber(LST:GetMinBuyoutMinusAuctionOpMin(nameTable[item], rank)) > tonumber(LST.db.profile.settings.minProfit) then
										table.insert(RestockList, {LegendaryItemData[nameTable[item]]["name"], rank, restockAmount[rank] - currentStock, LST:GetMinBuyoutMinusAuctionOpMin(nameTable[item], rank), nameTable[item]})
									end
								end	
							else
								if tonumber(LST:GetMinBuyoutMinusAuctionOpMin(nameTable[item], rank)) > tonumber(LST.db.profile.settings.minProfit) then
									table.insert(RestockList, {LegendaryItemData[nameTable[item]]["name"], rank, restockAmount[rank] - currentStock, LST:GetMinBuyoutMinusAuctionOpMin(nameTable[item], rank), nameTable[item]})
								end
							end
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
	if(IsTSMLoaded == false or LST.db.profile.settings.showPricing == false) then
		text = L["Item name, Rank 1, Rank 2, Rank 3, Rank 4, Rank 5, Rank 6\n"]
		for i=1, #NameTable do 
			text = text .. LegendaryItemData[NameTable[i]]["name"] .. "," 
			.. LST:GetStockCount(NameTable[i], 1) .. "," 
			.. LST:GetStockCount(NameTable[i], 2) .. "," 
			.. LST:GetStockCount(NameTable[i], 3) .. "," 
			.. LST:GetStockCount(NameTable[i], 4) .. "," 
			.. LST:GetStockCount(NameTable[i], 5) .. "," 
			.. LST:GetStockCount(NameTable[i], 6) .. "\n" 
		end
	else
		text = L["Item name, Rank 1, Profit Rank 1, Rank 2, Profit Rank 2, Rank 3, Profit Rank 3, Rank 4, Profit Rank 4, Rank 5, Profit Rank 5, Rank 6, Profit Rank 6\n"]
		for i=1, #NameTable do 
			text = text .. LegendaryItemData[NameTable[i]]["name"] .. "," 
			.. LST:GetStockCount(NameTable[i], 1) .. "," .. tostring(LST:RoundToInt(LST:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 1))) .. ","
			.. LST:GetStockCount(NameTable[i], 2) .. "," .. tostring(LST:RoundToInt(LST:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 2))) .. ","
			.. LST:GetStockCount(NameTable[i], 3) .. "," .. tostring(LST:RoundToInt(LST:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 3))) .. ","
			.. LST:GetStockCount(NameTable[i], 4) .. "," .. tostring(LST:RoundToInt(LST:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 4))) .. ","
			.. LST:GetStockCount(NameTable[i], 5) .. "," .. tostring(LST:RoundToInt(LST:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 5))) .. ","
			.. LST:GetStockCount(NameTable[i], 6) .. "," .. tostring(LST:RoundToInt(LST:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 6))) .. "\n"
		end
	end
	return text;
end

function LST:createNameTable()
	local NameTable = {} --nametable is now "list of items to export"
	--if(isTSMPriceUpdated == false) then
		TSMPriceDataByRank = {}
	--end
	if(LST.db.profile.settings.priceSource == L["LST Crafting"]) then 
		LST:UpdateMaterialPrices();
	end
	for id, data in pairs(LegendaryItemData) do 
		table.insert(NameTable, id);
		LST:UpdateTsmPriceForAllRanks(id);
	end
	--print("updated prices")
	--isTSMPriceUpdated = true;
	table.sort(NameTable)	
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
			LST:CreateTableElement(frame, RestockList[i][1] .. " - " .. L["Rank"] .. " " .. RestockList[i][2], 1, 1, 1, 1),
			LST:CreateTableElement(frame, RestockList[i][3], 1, 1, 1, 1),
			LST:CreateTableElement(frame, LST:RoundToInt(RestockList[i][4]), 1, 1, 1, 1)
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
	if(IsTSMLoaded == false or LST.db.profile.settings.showPricing == false) then
		local titles = {LST:CreateTableTitle(frame, L["Item name"]), LST:CreateTableTitle(frame, L["Rank 1"]), LST:CreateTableTitle(frame, L["Rank 2"]), LST:CreateTableTitle(frame, L["Rank 3"]), LST:CreateTableTitle(frame, L["Rank 4"]), LST:CreateTableTitle(frame, L["Rank 5"]), LST:CreateTableTitle(frame, L["Rank 6"])}
		table.insert(sheet, titles)
		maxWidth = {0,0,0,0,0,0,0}
		local stockSum = {0,0,0,0,0,0}
		for i=1, #NameTable do 
			local stock = {0,0,0,0,0,0}
			for j=1, 6 do
				stock[j] = LST:GetStockCount(NameTable[i], j);
				stockSum[j] = stockSum[j] + stock[j];
			end
			row = 
			{
				LST:CreateTableElement(frame, LegendaryItemData[NameTable[i]]["name"], 1, 1, 1, 1),
				LST:CreateTableElement(frame, stock[1], LST:GetTableStockFont(1,stock[1])), 
				LST:CreateTableElement(frame, stock[2], LST:GetTableStockFont(2,stock[2])), 
				LST:CreateTableElement(frame, stock[3], LST:GetTableStockFont(3,stock[3])), 
				LST:CreateTableElement(frame, stock[4], LST:GetTableStockFont(4,stock[4])),
				LST:CreateTableElement(frame, stock[5], LST:GetTableStockFont(5,stock[5])),
				LST:CreateTableElement(frame, stock[6], LST:GetTableStockFont(6,stock[6]))
			}
			table.insert(sheet, row)
		end
		row = 
		{
			LST:CreateTableElement(frame, L["Total"] .. (stockSum[1] + stockSum[2] + stockSum[3] + stockSum[4] + stockSum[5] + stockSum[6]), 1, 1, 1, 1),
			LST:CreateTableElement(frame, stockSum[1], 1, 1, 1, 1), 
			LST:CreateTableElement(frame, stockSum[2], 1, 1, 1, 1), 
			LST:CreateTableElement(frame, stockSum[3], 1, 1, 1, 1), 
			LST:CreateTableElement(frame, stockSum[4], 1, 1, 1, 1),
			LST:CreateTableElement(frame, stockSum[5], 1, 1, 1, 1),
			LST:CreateTableElement(frame, stockSum[6], 1, 1, 1, 1)
		}
		table.insert(sheet, row)
	else
		local titles = {LST:CreateTableTitle(frame, L["Item name"]), LST:CreateTableTitle(frame, L["R1"]), LST:CreateTableTitle(frame, L["Profit R1"]), LST:CreateTableTitle(frame, L["R2"]), LST:CreateTableTitle(frame, L["Profit R2"]), 
		LST:CreateTableTitle(frame, L["R3"]), LST:CreateTableTitle(frame, L["Profit R3"]), LST:CreateTableTitle(frame, L["R4"]), LST:CreateTableTitle(frame, "Profit R4"), 
		LST:CreateTableTitle(frame, L["R5"]), LST:CreateTableTitle(frame, L["Profit R5"]), LST:CreateTableTitle(frame, L["R6"]), LST:CreateTableTitle(frame, "Profit R6")}
		table.insert(sheet, titles)
		maxWidth = {0,0,0,0,0,0,0,0,0,0,0,0,0}
		local stockSum = {0,0,0,0,0,0}
		local priceSum = {0,0,0,0,0,0}
		local profitSum = {0,0,0,0,0,0}
		for i=1, #NameTable do 
			local stock = {0,0,0,0,0,0}
			local price = {0,0,0,0,0,0}
			local profit = {0,0,0,0,0,0}
			for j=1, 6 do
				stock[j] = LST:GetStockCount(NameTable[i], j);
				price[j] = LST:GetMinBuyout(NameTable[i], j);
				profit[j] = LST:GetMinBuyoutMinusAuctionOpMin(NameTable[i], j);
				stockSum[j] = stockSum[j] + stock[j];
				priceSum[j] = priceSum[j] + (stock[j] * price[j]);
				if(profit[j] ~= L["not scanned"]) then
					profitSum[j] = profitSum[j] + (stock[j] * profit[j]);
				end
			end
			row = 
			{
				LST:CreateTableElement(frame, LegendaryItemData[NameTable[i]]["name"], 1, 1, 1, 1),
				LST:CreateTableElement(frame, stock[1], LST:GetTableStockFont(1, stock[1], tostring(profit[1]))), LST:CreateTableElement(frame, tostring(LST:RoundToInt(profit[1])), LST:GetTablePriceFont(tostring(profit[1]))),
				LST:CreateTableElement(frame, stock[2], LST:GetTableStockFont(2, stock[2], tostring(profit[2]))), LST:CreateTableElement(frame, tostring(LST:RoundToInt(profit[2])), LST:GetTablePriceFont(tostring(profit[2]))),
				LST:CreateTableElement(frame, stock[3], LST:GetTableStockFont(3, stock[3], tostring(profit[3]))), LST:CreateTableElement(frame, tostring(LST:RoundToInt(profit[3])), LST:GetTablePriceFont(tostring(profit[3]))),
				LST:CreateTableElement(frame, stock[4], LST:GetTableStockFont(4, stock[4], tostring(profit[4]))), LST:CreateTableElement(frame, tostring(LST:RoundToInt(profit[4])), LST:GetTablePriceFont(tostring(profit[4]))),
				LST:CreateTableElement(frame, stock[5], LST:GetTableStockFont(5, stock[5], tostring(profit[5]))), LST:CreateTableElement(frame, tostring(LST:RoundToInt(profit[5])), LST:GetTablePriceFont(tostring(profit[5]))),
				LST:CreateTableElement(frame, stock[6], LST:GetTableStockFont(6, stock[6], tostring(profit[6]))), LST:CreateTableElement(frame, tostring(LST:RoundToInt(profit[6])), LST:GetTablePriceFont(tostring(profit[6])))
			}
			table.insert(sheet, row)		
		end
		table.insert(sheet, LST:CreateTablePriceRowWhite(frame, L["Total per rank (profit): "], stockSum[1], LST:AddComasEveryThousand(LST:RoundToInt(profitSum[1])), stockSum[2], LST:AddComasEveryThousand(LST:RoundToInt(profitSum[2])), stockSum[3], LST:AddComasEveryThousand(LST:RoundToInt(profitSum[3])), stockSum[4], LST:AddComasEveryThousand(LST:RoundToInt(profitSum[4])), stockSum[5], LST:AddComasEveryThousand(LST:RoundToInt(profitSum[5])), stockSum[6], LST:AddComasEveryThousand(LST:RoundToInt(profitSum[6]))))
		table.insert(sheet, LST:CreateTablePriceRowWhite(frame, L["Total per rank (min price): "], stockSum[1], LST:AddComasEveryThousand(LST:RoundToInt(priceSum[1])), stockSum[2], LST:AddComasEveryThousand(LST:RoundToInt(priceSum[2])), stockSum[3], LST:AddComasEveryThousand(LST:RoundToInt(priceSum[3])), stockSum[4], LST:AddComasEveryThousand(LST:RoundToInt(priceSum[4])), stockSum[5], LST:AddComasEveryThousand(LST:RoundToInt(priceSum[5])), stockSum[6], LST:AddComasEveryThousand(LST:RoundToInt(priceSum[6]))))
		table.insert(sheet, LST:CreateTablePriceRowWhite(frame, L["Total (profit): "], (stockSum[1] + stockSum[2] + stockSum[3] + stockSum[4] + stockSum[5] + stockSum[6]), LST:AddComasEveryThousand(LST:RoundToInt(profitSum[1] + profitSum[2] + profitSum[3] + profitSum[4] + profitSum[5] + profitSum[6])), "","","","","","","","","",""))
		table.insert(sheet, LST:CreateTablePriceRowWhite(frame, L["Total (min price): "], (stockSum[1] + stockSum[2] + stockSum[3] + stockSum[4] + stockSum[5] + stockSum[6]), LST:AddComasEveryThousand(LST:RoundToInt(priceSum[1] + priceSum[2] + priceSum[3] + priceSum[4] + priceSum[5] + priceSum[6])), "","","","","","","","","",""))
	end
	LST:CreateFrameSheet(frame, sheet, #maxWidth)
end

function LST:GetColorWhite()
	return 1, 1, 1, 1
end

function LST:CreateTablePriceRowWhite(frame, title, text1, text2, text3, text4, text5, text6, text7, text8, text9, text10, text11, text12)
	row = 
	{
		LST:CreateTableElement(frame, title, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text1, LST:GetColorWhite()), LST:CreateTableElement(frame, text2, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text3, LST:GetColorWhite()), LST:CreateTableElement(frame, text4, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text5, LST:GetColorWhite()), LST:CreateTableElement(frame, text6, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text7, LST:GetColorWhite()), LST:CreateTableElement(frame, text8, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text9, LST:GetColorWhite()), LST:CreateTableElement(frame, text10, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text11, LST:GetColorWhite()), LST:CreateTableElement(frame, text12, LST:GetColorWhite())
	}
	return row;
end

function LST:CreateTableRowWhite(frame, title, text1, text2, text3, text4, text5, text6)
	row = 
	{
		LST:CreateTableElement(frame, title, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text1, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text2, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text3, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text4, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text5, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text6, LST:GetColorWhite())
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
	if(stringValue == L["not scanned"]) then
		return 1,1,1,1;
	end
	if(tonumber(LST.db.profile.settings.minProfit) > 0 and tonumber(stringValue) > tonumber(LST.db.profile.settings.minProfit)) then
		return 0.15, 1, 0.15, 1
	elseif(tonumber(stringValue) < 0) then
		return 1, 0.15, 0.15, 1
	else 
		return 1, 1, 1, 1
	end
end

function LST:GetTableStockFont(rank, value, price)
	if(price == L["not scanned"]) then
		return 1,1,1,1;
	end
	if (price == nil) then
		price = 0;
	end
	if(value < tonumber(LST.db.profile.settings.restockAmountByRank[rank])) then
		if(LST.db.profile.settings.showPricing == true and price ~= nil) then
			if(tonumber(price) > tonumber(LST.db.profile.settings.minProfit)) then 
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
	if(TSMPriceDataByRank[name][rank][2] == L["not scanned"]) then
		return L["not scanned"];
	end
	return tonumber(TSMPriceDataByRank[name][rank][1] - TSMPriceDataByRank[name][rank][2]);
end

function LST:GetMinBuyout(name, rank)
	return tonumber(TSMPriceDataByRank[name][rank][1]);
end

function LST:UpdateMaterialPrices()
	--if(isMaterialPriceUpdated == true) then return nil end
	for materialID, name in	pairs(LST.db.factionrealm.recipeData.materialList) do
		local matPrice = tonumber(LST:ConvertTsmPriceToValue(TSM_API.GetCustomPriceValue("matPrice", "i:" .. materialID)));
		if(tonumber(matPrice) == 0 and tonumber(matprice) == nil) then
			materialPrices[materialID] = 0;
		else
			materialPrices[materialID] = matPrice;
		end
	end
	--isMaterialPriceUpdated = true;
end

function LST:GetLSTCraftCostForLegendary(itemID, rank)
	if(rank <= 4) then
		if(LST.db.factionrealm.recipeData.recipes[itemID] == nil or LST.db.factionrealm.recipeData.recipes[itemID]["ranks"] == nil or LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank] == nil) then
			return L["not scanned"];
		else
			return LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank])
		end
	else
		if(LST.db.factionrealm.recipeData.recipes[itemID] == nil or LST.db.factionrealm.recipeData.vestiges[LegendaryItemData[itemID]["profession"]] == nil) then
			return L["not scanned"];
		else
			return LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank - 2]) + LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.vestiges[LegendaryItemData[itemID]["profession"]])
		end
	end
end

function LST:GetMaterialPriceSum(table)
	local price = 0;
	for materialID, data in pairs(table) do
		if(materialPrices[materialID] == nil) then
			price = price + 0;
		else
			price = price + (materialPrices[materialID] * data["numRequired"]);
		end
	end
	return price;
end

function LST:GetLSTCraftCostForVestige(professionID)
	if(LST.db.factionrealm.recipeData.vestiges[professionID] == nil) then
		return L["not scanned"];
	end
	local price = 0;
	for materialID, data in pairs(LST.db.factionrealm.recipeData.vestiges[professionID]) do
		if(materialPrices[materialID] == nil) then
			price = price + 0;
		else
			price = price + (materialPrices[materialID] * data["numRequired"]);
		end
	end
	return price;
end

function LST:UpdateTsmPriceForAllRanks(itemName)
	LST:UpdateTsmPrices(itemName, 1)
	LST:UpdateTsmPrices(itemName, 2)
	LST:UpdateTsmPrices(itemName, 3)
	LST:UpdateTsmPrices(itemName, 4)
	LST:UpdateTsmPrices(itemName, 5)
	LST:UpdateTsmPrices(itemName, 6)
end

function LST:UpdateTsmPrices(itemName, rank)
	--if(isTSMPriceUpdated == true) then return nil end
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
	elseif(rank == 5) then
		tsmString = tsmString .. Rank5BonusIDs
	elseif(rank == 6) then
		tsmString = tsmString .. Rank6BonusIDs
	end
	tsmstring = TSM_API.ToItemString(tsmString)
	ItemPrices[rank][1] = LST:ConvertTsmPriceToValue(TSM_API.GetCustomPriceValue("DBMinBuyout", tsmString));
	if(LST.db.profile.settings.priceSource == L["TSM operations"]) then 
		ItemPrices[rank][2] = LST:ConvertTsmPriceToValue(TSM_API.GetCustomPriceValue("AuctioningOpMin", tsmString))
	elseif(LST.db.profile.settings.priceSource == L["LST Crafting"]) then
		local craftCost = LST:GetLSTCraftCostForLegendary(itemName, rank);
		if(craftCost ~= L["not scanned"]) then
			craftCost = LST:RoundToInt(craftCost);
		end
		ItemPrices[rank][2] = craftCost;
	else
		print(LST.db.profile.settings.priceSource)
		print(L["LST: Invalid price source"]);
	end
	if(ItemPrices[rank][1] == nil or ItemPrices[rank][1] == 0) then
		ItemPrices[rank][1] = LST:ConvertTsmPriceToValue(TSM_API.GetCustomPriceValue("AuctioningOpNormal", tsmString));
	end
	if(ItemPrices[rank][1] == nil or ItemPrices[rank][2] == nil) then
		ItemPrices[rank][1] = 0
		ItemPrices[rank][2] = 0
	elseif(LST.db.profile.settings.priceSource == L["LST Crafting"]) then
		ItemPrices[rank][1] = ItemPrices[rank][1] * 0.95;
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

function LST:ConvertTsmPriceToValue(value)
	if(value == nil or value <= 0) then
		return 0
	end
	local string = tostring(value);
	local gold = 0;
	local silver = 0;
	if(string ~= "0" and string ~= nil) then
		gold = tonumber(string:sub(1, #string - 4));
		silver = tonumber(string.sub(string, -4)) / 10000;
	end
	--if(gold == nil or silver == nil) then
	--	print("LST: incorrect price for value: " .. value .. ", defaulting to 0");
	--	return 0;
	--end
	if(gold == nil) then gold = 0; end
	if(silver == nil) then silver = 0; end
	local sum = gold + silver;
	if(sum == nil or sum <= 0) then
		return 0
	end
	return sum;
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

function LST:GetDominationSlotStatus(itemID)
	local isDominationSlot = false
	if (LegendaryItemData[itemID] ~= nil) then
		if (LegendaryItemData[itemID]["dominationSlot"] ~= nil) then 
			isDominationSlot = LegendaryItemData[itemID].dominationSlot
		end
	end
	return isDominationSlot
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
	return LST:GetItemIDFromItemLink(C_TradeSkillUI.GetRecipeItemLink(recipeInfo["recipeID"]));
	--local recipeItemLink = 
	--local itemID = select(3, strfind(recipeItemLink, "item:(%d+)"));
	--return itemID;
end

function LST:GetMaterialListFromRecipe(recipeID)
	local materials = {};
	for i = 1, C_TradeSkillUI.GetRecipeNumReagents(recipeID) do
		local reagentName, reagentIcon, reagentNumRequired, reagentNumOwned = C_TradeSkillUI.GetRecipeReagentInfo(recipeID, i, 1);
		local materialID = LST:GetItemIDFromItemLink(C_TradeSkillUI.GetRecipeReagentItemLink(recipeID, i));
		materials[materialID] = 
		{
			name = reagentName,
			itemid = materialID,
			numRequired = reagentNumRequired
		}
		LST.db.factionrealm.recipeData.materialList[materialID] = reagentName;
	end
	return materials;
end

function LST:GetItemIDFromItemLink(itemlink)
	return select(3, strfind(itemlink, "item:(%d+)"));
end

function LST:UpdateLegendaryRecipes()
	local categories = {C_TradeSkillUI.GetCategories()}
	local SLID = 0;
	for _, categoryID in pairs(categories) do
		if(SLProfessionsIds[categoryID] ~= nil) then
			SLID = categoryID;
		end
	end
	LST:SetOpenedProfessionID(SLID)
	local recipes = LST:GetKnownTradeSkillRecipes();
	for recipeID, val in pairs(recipes) do 
		local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID);
		if(type(recipeInfo) == "table") then
			if(LST:IsTradeSkillRecipeSLLegendary(recipeInfo)) then
				local itemLevel = GetDetailedItemLevelInfo(C_TradeSkillUI.GetRecipeItemLink(recipeID))
				local rank = LST:GetLegendaryRankByItemLevel(itemLevel);
				local itemID = LST:GetCraftResultItemId(recipeInfo);
				local unlockedLevel = LST:GetSLLegendaryUnlockedLevel(recipeInfo)
				LST.db.factionrealm.characters[LST.playerName].unlockedLegendaryCraftRanks[itemID] = unlockedLevel;
				LegendaryItemData[itemID]["recipeUnlocked"] = unlockedLevel;
				LegendaryItemData[itemID]["recipeID"][rank] = recipeID;
				LST.db.factionrealm.recipeData.recipes[itemID]["name"] = recipeInfo["name"];
				LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank] = LST:GetMaterialListFromRecipe(recipeID);
			elseif(LST:GetCraftResultItemId(recipeInfo) == "185960") then
				LST.db.factionrealm.recipeData.vestiges[SLID] = LST:GetMaterialListFromRecipe(recipeID);
			end
		end
	end
end

function LST:OnTradeskillClosed()
	LST:SetOpenedProfessionID(0)
end

function LST:SetOpenedProfessionID(ID)
	openedProfession = ID;
end

function LST:CraftNextRestockItem()
	if(openedProfession == 0) then 
		print(L["LST: You need to open your profession first"]);
		return nil 
	end;
	for index, restockData in ipairs(RestockList) do
		local itemID = restockData[5];
		if(LegendaryItemData[itemID]["profession"] == openedProfession and restockData[2] < 5) then
			local recipeID = LegendaryItemData[tostring(itemID)]["recipeID"][restockData[2]];
			if(recipeID ~= 0) then
				local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID, 1);
				local availableCraftCount = recipeInfo["numAvailable"];
				if(availableCraftCount >= restockData[3]) then
					C_TradeSkillUI.CraftRecipe(recipeID, restockData[3], nil, 1);
					return nil;
				elseif(availableCraftCount > 0) then
					C_TradeSkillUI.CraftRecipe(recipeID, availableCraftCount, nil, 1);
					return nil;
				else 
					print(L["LST: Not enough materials to craft "] .. restockData[1])
				end
			end
		end
		if(restockData[2] > 4 and restockData[2] < 7) then
			print(L["LST: Crafting is not yet supported for rank 5 and 6, please craft these manually for now"])
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
	LST.db.factionrealm.syncData[data["accID"]] = {}
	LST.db.factionrealm.syncData[data["accID"]]["legendaries"] = {}
	local table = LST.db.factionrealm.syncData[data["accID"]]["legendaries"]
	for id, data in pairs(data["legendaries"]) do
		table[id] = 
		{
			["canCraft"] = data[1],
			["stock"] = {data[2],  data[3], data[4], data[5]}
		}
	end
	LST.db.factionrealm.recipeData.materialList = data.recipeData["materialList"];
	for materialId, materialName in pairs(data.recipeData.materialList) do
		LST.db.factionrealm.recipeData.materialList[materialId] = materialName;
	end
	for recipeID, recipeData in pairs(data.recipeData.recipes) do
		LST.db.factionrealm.recipeData.recipes[recipeID] = recipeData;
	end
	for professionID, vestigeData in pairs(data.recipeData.vestiges) do
		LST.db.factionrealm.recipeData.vestiges[professionID] = vestigeData;
	end
end

function LST:SendDataToSyncTarget()
	LST:SendDataToPlayer(LST.db.profile.settings.syncTarget)
end

function LST:SendDataToPlayer(player)
	print(L["LST: Sending data to "] .. player)
	LST:CountLegendariesByRankWithoutSyncdata();
	local syncData = {
		["accID"] = LST.db.factionrealm.accountUUID,
		["legendaries"] = {},
		["recipeData"] = LST.db.factionrealm.recipeData
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

function LST:ClearItemCache()
	for key,val in pairs(LST.db.factionrealm.characters) do
		LST.db.factionrealm.characters[key]["bagItemLegendaryLinks"] = {};
		LST.db.factionrealm.characters[key]["bagItemLegendaryCount"] = 0;
		LST.db.factionrealm.characters[key]["bankItemLegendaryLinks"] = {};
		LST.db.factionrealm.characters[key]["bankItemLegendaryCount"] = 0;
		LST.db.factionrealm.characters[key]["ahItemLegendaryLinks"] = {};
		LST.db.factionrealm.characters[key]["ahItemLegendaryCount"] = 0;
		LST.db.factionrealm.characters[key]["mailboxItemLegendaryLinks"] = {};
		LST.db.factionrealm.characters[key]["mailboxItemLegendaryCount"] = 0;
	end
	for key,val in pairs(LST.db.factionrealm.guilds) do
		LST.db.factionrealm.guilds[key]["GuildBankItemLegendaryLinks"] = {};
		LST.db.factionrealm.guilds[key]["GuildBankItemLegendaryCount"] = 0;
	end
	for key,val in pairs(LST.db.factionrealm.syncData) do
		for k,v in pairs(LST.db.factionrealm.syncData[key]["legendaries"]) do
			LST.db.factionrealm.syncData[key]["legendaries"][k]["stock"] = {0,0,0,0};
		end
	end
	print(L["LST: Cleared item cache"])
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

function LST:RoundToInt(x)
	if(x == L["not scanned"]) then
		return x;
	end
	return x + 0.5 - (x + 0.5) % 1;
end