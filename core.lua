LegendaryStockTracker = LibStub("AceAddon-3.0"):NewAddon("LegendaryStockTracker", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("LegendaryStockTracker")

-- Set up DataBroker for minimap button
local LstockLDB = LibStub("LibDataBroker-1.1"):NewDataObject("LegendaryStockTracker", {
  type = "data source",
  text = "LegendaryStockTracker",
  label = "LegendaryStockTracker",
  icon = "Interface\\AddOns\\LegendaryStockTracker\\LST_logo",
  OnClick = function()
    if LstockFrame and LstockFrame:IsShown() then
      LstockFrame:Hide()
    else
      LegendaryStockTracker:HandleChatCommand("")
    end
  end,
  OnTooltipShow = function(tt)
	LegendaryStockTracker:GetAllItemsInBags()
    tt:AddLine("Legendary Stock Tracker")
    tt:AddLine(" ")
    tt:AddLine("Click or type /lstock to show export panel")
    tt:AddLine("Items Scanned:")
    tt:AddLine(LegendaryStockTracker:GetDataCounts())
  end
})

local LstockIcon = LibStub("LibDBIcon-1.0")
local LstockFrame = nil

--all collections of items are stored separately for future expandability
local itemLinks = {}
local bagItemLinks = {}
local bagItemCount = 0
local bankItemLinks = {}
local bankItemCount = 0
local ahItemLinks = {}
local ahItemCount = 0
local mailboxItemLinks = {}
local mailboxItemCount = 0
local GuildBankItemLinks = {}
local GuildBankItemCount = 0
local gearLinks = {}
local legendaryLinks = {}
local legendaryCountByRank = {}
local TSMPriceDataByRank = {}
local LoadUnownedLegendaries = true
local Rank1BonusIDs = "::2:1487:6716"
local Rank2BonusIDs = "::2:1507:6717"
local Rank3BonusIDs = "::2:1522:6718"
local Rank4BonusIDs = "::2:1532:6758"
local LegendaryIDsByName = 
{
	[L["Shadowghast Armguards"]] =  171419,
	[L["Shadowghast Breastplate"]] =  171412,
	[L["Shadowghast Gauntlets"]] =  171414,
	[L["Shadowghast Greaves"]] =  171416,
	[L["Shadowghast Helm"]] =  171415,
	[L["Shadowghast Pauldrons"]] =  171417,
	[L["Shadowghast Sabatons"]] =  171413,
	[L["Shadowghast Waistguard"]] =  171418,
	
	[L["Shadowghast Necklace"]] =  178927,
	[L["Shadowghast Ring"]] =  178926,
	
	[L["Grim-Veiled Belt"]] =  173248,
	[L["Grim-Veiled Bracers"]] =  173249,
	[L["Grim-Veiled Cape"]] =  173242,
	[L["Grim-Veiled Hood"]] =  173245,
	[L["Grim-Veiled Mittens"]] =  173244,
	[L["Grim-Veiled Pants"]] =  173246,
	[L["Grim-Veiled Robe"]] =  173241,
	[L["Grim-Veiled Sandals"]] =  173243,
	[L["Grim-Veiled Spaulders"]] =  173247,
	
	[L["Umbrahide Armguards"]] =  172321,
	[L["Umbrahide Gauntlets"]] =  172316,
	[L["Umbrahide Helm"]] =  172317,
	[L["Umbrahide Leggings"]] =  172318,
	[L["Umbrahide Pauldrons"]] =  172319,
	[L["Umbrahide Treads"]] =  172315,
	[L["Umbrahide Vest"]] =  172314,
	[L["Umbrahide Waistguard"]] =  172320,
	
	[L["Boneshatter Armguards"]] =  172329,
	[L["Boneshatter Gauntlets"]] =  172324,
	[L["Boneshatter Greaves"]] =  172326,
	[L["Boneshatter Helm"]] =  172325,
	[L["Boneshatter Pauldrons"]] =  172327,
	[L["Boneshatter Treads"]] =  172323,
	[L["Boneshatter Vest"]] =  172322,
	[L["Boneshatter Waistguard"]] =  172328
}
local GUILD_BANK_SLOTS_PER_TAB = 98
local IsTSMLoaded = false;

local activeTab = nil

function LegendaryStockTracker:OnInitialize()
	-- init databroker
	self.db = LibStub("AceDB-3.0"):New("LegendaryStockTrackerDB", {
		profile = {
		  minimap = {
			hide = false,
		  },
		  frame = {
			point = "CENTER",
			relativeFrame = nil,
			relativePoint = "CENTER",
			ofsx = 0,
			ofsy = 0,
			width = 750,
			height = 400,
		  },
		},
	});

	LstockIcon:Register("LegendaryStockTracker", LstockLDB, self.db.profile.minimap)
    LegendaryStockTracker:RegisterChatCommand("lstock", "HandleChatCommand")
    LegendaryStockTracker:RegisterChatCommand("lst", "ShowTestFrame")
    LegendaryStockTracker:RegisterChatCommand("lstocktest", "Test")
    LegendaryStockTracker:RegisterChatCommand("lstockscan", "ScanAhPrices")
	LegendaryStockTracker:RegisterEvent("BANKFRAME_CLOSED", "GetAllItemsInBank")
	LegendaryStockTracker:RegisterEvent("BANKFRAME_OPENED", "GetAllItemsInBank")
	LegendaryStockTracker:RegisterEvent("OWNED_AUCTIONS_UPDATED", "GetAllItemsInAH")
	LegendaryStockTracker:RegisterEvent("MAIL_INBOX_UPDATE", "GetAllItemsInMailbox")
	LegendaryStockTracker:RegisterEvent("MAIL_CLOSED", "GetAllItemsInMailbox")
	LegendaryStockTracker:RegisterEvent("GUILDBANKFRAME_CLOSED", "GetAllItemsInGuildBank")
	LegendaryStockTracker:RegisterEvent("GUILDBANKFRAME_OPENED", "GetAllItemsInGuildBank")
	LegendaryStockTracker:RegisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED", "OnItemAdded")
	LegendaryStockTracker:CheckIfTSMIsRunning()
end

function LegendaryStockTracker:Test()
	local tsmstring = "i:171419::2:1532:6758"
	local test = ""
	test = test .. tostring(IsTSMLoaded) .. "\n"
	message(test)
end

function LegendaryStockTracker:GetDataCounts()
	local text = ""
	text = text .. "Bags: " .. bagItemCount .. "\n"
	text = text .. "Bank: " .. bankItemCount .. "\n"
	text = text .. "AH: " .. ahItemCount .. "\n"
	text = text .. "Mail: " .. mailboxItemCount .. "\n"
	text = text .. "Guild: " .. GuildBankItemCount .. "\n"
	return text
end

function LegendaryStockTracker:HandleChatCommand(input)
	LegendaryStockTracker:CheckIfTSMIsRunning()
	LegendaryStockTracker:GetAllItemsInAH()
	LegendaryStockTracker:GetAllItemsInBags()
	LegendaryStockTracker:GetAllItemsInBank() --if the bank is open at the time of command, update bank as well
	--LegendaryStockTracker:GetAllItemsInAH() auctions specifically not updated on command, as we don't know if the ah is closed or the player has no auctions. relying on OWNED_AUCTIONS_UPDATED to update those.
	--LegendaryStockTracker:GetAllItemsInMailbox() mailbox is updated anytime the mailbox is updated, no need to update on command 
	LegendaryStockTracker:GetAllItemsInGuildBank()
	LegendaryStockTracker:AddAllItemsToList()
	LegendaryStockTracker:GetGearFromItems()
	LegendaryStockTracker:GetShadowlandsLegendariesFromGear()
	LegendaryStockTracker:CountLegendariesByRank()
	local f = LegendaryStockTracker:AddMainFrame(UIParent)
	LstockEditBox:SetText(LegendaryStockTracker:GenerateExportText())
	LstockEditBox:HighlightText()
	--LegendaryStockTracker:createFrameSheet(LstockFrame)
	f:Show()
end

function LegendaryStockTracker:ShowTestFrame()
	local f = LegendaryStockTracker:AddMainFrame(UIParent)
	f:Show()
end

function LegendaryStockTracker:AddMainFrame(parent)
	local mainFrameHeight = 400 
	local mainFrameWidth = 600 
	if not LstockMainFrame then
		local temp = "Interface\\AddOns\\LegendaryStockTracker\\Assets\\Plain.tga"
		local Backdrop = {
			bgFile = temp,
			--edgeFile = temp,
			tile = false, tileSize = 0, edgeSize = 1,
			insets = {left = 1, right = 1, top = 1, bottom = 1},
		}
		local frameConfig = self.db.profile.frame
		local f = CreateFrame("Frame","LSTMainFrame",parent, BackdropTemplateMixin and "BackdropTemplate")
		LstockMainFrame = f
		f:SetBackdrop(Backdrop)
		f:SetBackdropColor(0.03,0.03,0.03,0.9)
		f:SetSize(mainFrameWidth,mainFrameHeight)
		--f:SetFrameStrata("HIGH")
		f:SetToplevel(true)
		f:SetClampedToScreen(true)
		f:SetPoint(
		frameConfig.point,
		frameConfig.relativeFrame,
		frameConfig.relativePoint,
		frameConfig.ofsx,
		frameConfig.ofsy
		)
		LegendaryStockTracker:SetFrameMovable(f)

		local tabWidth = 150
		local tabHeight = 24
		local contentWidth = mainFrameWidth - tabWidth - 10
		local contentHeight = mainFrameHeight - 30
		local contentWidthOffset = 5
		local contentHeightOffset = -25

		local tabList = CreateFrame("Frame","LSTTabList",f)
		tabList:SetSize(tabWidth, mainFrameHeight)
		tabList:SetPoint("TOPLEFT", LstockMainFrame, "TOPLEFT",0,-5)

		local contentFrame = CreateFrame("Frame","LSTContentFrame",f, BackdropTemplateMixin and "BackdropTemplate")
		--contentFrame:SetBackdrop(Backdrop)
		--contentFrame:SetBackdropColor(0.03,0.03,0.03,0.9)
		contentFrame:SetSize(contentWidth + 10,mainFrameHeight)
		contentFrame:SetPoint("TOPLEFT", LstockMainFrame, "TOPLEFT",tabWidth,0)

		--divider lines
		local line = tabList:CreateLine()
		line:SetThickness(1)
		line:SetColorTexture(0.6,0.6,0.6,1)
		line:SetStartPoint("TOPRIGHT",0,4)
		line:SetEndPoint("BOTTOMRIGHT",0,6)

		line= contentFrame:CreateLine()
		line:SetThickness(1)
		line:SetColorTexture(0.6,0.6,0.6,1)
		line:SetStartPoint("TOPLEFT",0,-20)
		line:SetEndPoint("TOPRIGHT",0,-20)

		--Export Frame
		local exportFrame = LegendaryStockTracker:CreateOptionsContentFrame("LSTExportFrame", contentFrame, contentWidth, contentHeight, contentWidthOffset, contentHeightOffset, Backdrop)
		--exportFrame:SetBackdropColor(0.75,0,0,0.9)
		-- scroll frame
		local sf = CreateFrame("ScrollFrame", "LstockScrollFrame", exportFrame, BackdropTemplateMixin and "UIPanelScrollFrameTemplate")
		sf:SetPoint("LEFT")
		sf:SetPoint("RIGHT", -22, 0)
		sf:SetPoint("TOP")
		sf:SetPoint("BOTTOM")
	
		-- edit box
		local eb = CreateFrame("EditBox", "LstockEditBox", LstockScrollFrame)
		eb:SetSize(sf:GetSize())
		eb:SetMultiLine(true)
		eb:SetAutoFocus(true)
		eb:SetFontObject("ChatFontNormal")
		eb:SetScript("OnEscapePressed", function() f:Hide() end)
		sf:SetScrollChild(eb)
		
		local settingsFrame = LegendaryStockTracker:CreateOptionsContentFrame("LSTsettingsFrame", contentFrame, contentWidth, contentHeight, contentWidthOffset, contentHeightOffset, Backdrop)
		--settingsFrame:SetBackdropColor(0,0.75,0,0.9)

		local tableFrame = LegendaryStockTracker:CreateOptionsContentFrame("LSTtableFrame", contentFrame, contentWidth, contentHeight, contentWidthOffset, contentHeightOffset, Backdrop)
		--tableFrame:SetBackdropColor(0,0,0.75,0.9)

		

		local tab = LegendaryStockTracker:AddTab(tabList, tabWidth, 24, 1, exportFrame, L["Export"])
		LegendaryStockTracker:AddTab(tabList, tabWidth, 24, 2, settingsFrame, L["Settings"])
		LegendaryStockTracker:AddTab(tabList, tabWidth, 24, 3, tableFrame, L["Table"])
		LegendaryStockTracker:TabOnClick(tab)

		local closeButton = CreateFrame("Button", "LSTMainFrameCloseButton", f)
		closeButton:SetSize(20,20)
		closeButton:SetText("X")
		closeButton:SetPoint("TOPRIGHT", f, "TOPRIGHT")
		closeButton:SetNormalFontObject("GameFontHighlight")
		--closeButton:SetNormalFontObject("GameFontNormal")
		closeButton:SetHighlightFontObject("GameFontHighlight")
		closeButton:SetDisabledFontObject("GameFontDisable")
		closeButton:SetScript("OnClick", function()
			LstockMainFrame:Hide()
		end)
	end
	return LstockMainFrame
end

function LegendaryStockTracker:SetFrameMovable(f)
	local frameConfig = self.db.profile.frame
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

function LegendaryStockTracker:TabOnClick(self)
	if(activeTab ~= nil) then
		activeTab.content:Hide()
	end
	activeTab = self
	self.content:Show()
end

function LegendaryStockTracker:AddTab(parent, width, height, index, content, text)

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
		LegendaryStockTracker:TabOnClick(self)
	end)
	b.content = content
	b.content:Hide()
	return b
end

function LegendaryStockTracker:CreateOptionsContentFrame(name, parent, width, height, offsetX, offsetY, backdrop)
	local f = CreateFrame("Frame",name,parent, BackdropTemplateMixin and "BackdropTemplate")
	--f:SetBackdrop(backdrop)
	--f:SetBackdropColor(0.03,0.03,0.03,0.9)
	f:SetSize(width,height)
	f:SetPoint("TOPLEFT", parent, "TOPLEFT",offsetX,offsetY)
	return f
end

function LegendaryStockTracker:OnEnable()

end

function LegendaryStockTracker:OnDisable()

end

function LegendaryStockTracker:GetAllItemsInBags()
	bagItemLinks = {}
	bagItemCount = 0
    for bag=0,NUM_BAG_SLOTS do
        for slot=1,GetContainerNumSlots(bag) do
			if not (GetContainerItemID(bag,slot) == nil) then 
				bagItemLinks[#bagItemLinks+1] = (select(7,GetContainerItemInfo(bag,slot)))
				bagItemCount = bagItemCount + 1
			end
        end
	end
end

function LegendaryStockTracker:GetAllItemsInBank()
	if(GetContainerItemLink(NUM_BAG_SLOTS+1,1) ~= nil) then
		bankItemLinks = {}
		bankItemCount = 0
		--go through all bank bag slots
		for bag=NUM_BAG_SLOTS+1,NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			for slot=1,GetContainerNumSlots(bag) do
				if not (GetContainerItemID(bag,slot) == nil) then 
					bankItemLinks[#bankItemLinks+1] = (select(7,GetContainerItemInfo(bag,slot)))
					bankItemCount = bankItemCount + 1
				end
			end
		end
		--go through default 28 bank spaces
		for slot=1,GetContainerNumSlots(-1) do
			if not (GetContainerItemID(-1,slot) == nil) then 
				bankItemLinks[#bankItemLinks+1] = (select(7,GetContainerItemInfo(-1,slot)))
				bankItemCount = bankItemCount + 1
			end
		end
	end
end

function LegendaryStockTracker:GetAllItemsInAH()
	if(C_AuctionHouse.GetNumOwnedAuctions() ~= 0) then
		ahItemLinks = {}
		ahItemCount = 0
		local numOwnedAuctions = C_AuctionHouse.GetNumOwnedAuctions()
		for i=1, numOwnedAuctions do
			local auctionInfo = C_AuctionHouse.GetOwnedAuctionInfo(i)
			if(auctionInfo.status == 0) then 
				ahItemLinks[#ahItemLinks+1] = auctionInfo.itemLink
				ahItemCount = ahItemCount + 1
			end
		end
	end
end

function LegendaryStockTracker:GetAllItemsInMailbox()
	mailboxItemLinks = {}
	mailboxItemCount = 0
	for i=1, GetInboxNumItems() do
		for j=1,ATTACHMENTS_MAX_RECEIVE do 
			if(GetInboxItemLink(i, j) ~= nil) then
				mailboxItemLinks[#mailboxItemLinks+1] = GetInboxItemLink(i, j)
				mailboxItemCount = mailboxItemCount + 1
			end
		end
	end
end

function LegendaryStockTracker:GetAllItemsInGuildBank()
	local guildBankTabCount = GetNumGuildBankTabs()
	if(guildBankTabCount > 0 and GetGuildBankTabInfo(1) ~= nil) then
		GuildBankItemLinks = {}
		GuildBankItemCount = 0
		for tab=1,guildBankTabCount do
			for slot=1,GUILD_BANK_SLOTS_PER_TAB do
				if not (GetGuildBankItemInfo(tab,slot) == nil) then 
					GuildBankItemLinks[#GuildBankItemLinks+1] = GetGuildBankItemLink(tab,slot)
					GuildBankItemCount = GuildBankItemCount + 1
				end
			end
		end
	end
end

function LegendaryStockTracker:GetGearFromItems()
	gearLinks = {}
	for i=1, #itemLinks do
		if select(12, GetItemInfo(itemLinks[i])) == 4 then 
			gearLinks[#gearLinks+1] = itemLinks[i]
		end
	end
end

function LegendaryStockTracker:AddAllItemsToList()
	itemLinks = {}
	for i=1, #bagItemLinks do
		itemLinks[#itemLinks+1] = bagItemLinks[i]
	end
	for i=1, #bankItemLinks do
		itemLinks[#itemLinks+1] = bankItemLinks[i]
	end
	for i=1, #ahItemLinks do
		itemLinks[#itemLinks+1] = ahItemLinks[i]
	end
	for i=1, #mailboxItemLinks do
		itemLinks[#itemLinks+1] = mailboxItemLinks[i]
	end
	for i=1, #GuildBankItemLinks do
		itemLinks[#itemLinks+1] = GuildBankItemLinks[i]
	end
end

function LegendaryStockTracker:GetShadowlandsLegendariesFromGear()
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

function LegendaryStockTracker:CountLegendariesByRank()
	legendaryCountByRank = {}
	TSMPriceDataByRank = {}
	for i=1, #legendaryLinks do
		local itemName = select(1, GetItemInfo(legendaryLinks[i]))
		local detailedItemLevel = GetDetailedItemLevelInfo(legendaryLinks[i])
		LegendaryStockTracker:AddItemToLegendaryTableIfNotPresent(itemName)
		local ItemCounts = legendaryCountByRank[itemName]
		if detailedItemLevel == 190
			then 
				ItemCounts[1] = ItemCounts[1] + 1
				if(LoadUnownedLegendaries == false) then
					LegendaryStockTracker:UpdateTsmPrices(itemName, 1)
				end
		elseif detailedItemLevel == 210
			then 
				ItemCounts[2] = ItemCounts[2] + 1
				if(LoadUnownedLegendaries == false) then
					LegendaryStockTracker:UpdateTsmPrices(itemName, 2)
				end
		elseif detailedItemLevel == 225
			then 
				ItemCounts[3] = ItemCounts[3] + 1
				if(LoadUnownedLegendaries == false) then
					LegendaryStockTracker:UpdateTsmPrices(itemName, 3)
				end
		elseif detailedItemLevel == 235
			then 
				ItemCounts[4] = ItemCounts[4] + 1
				if(LoadUnownedLegendaries == false) then
					LegendaryStockTracker:UpdateTsmPrices(itemName, 4)
				end
		--add future ranks here
		end
		legendaryCountByRank[itemName] = ItemCounts
	end
end

function LegendaryStockTracker:GenerateExportText()
	NameTable = createNameTable()

	local text = ""
	if(IsTSMLoaded == false) then
		text = "Item name, Rank 1, Rank 2, Rank 3,  Rank 4\n"
		for i=1, #NameTable do 
			text = text .. NameTable[i] .. "," 
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 1) .. "," 
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 2) .. "," 
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 3) .. "," 
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 4) .. "\n" 
		end
	else
		text = "Item name, Rank 1, Profit Rank 1, Rank 2, Profit Rank 2, Rank 3, Profit Rank 3, Rank 4, Profit Rank 4\n"
		for i=1, #NameTable do 
			text = text .. NameTable[i] .. "," 
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 1) .. "," .. LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 1) .. ","
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 2) .. "," .. LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 2) .. ","
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 3) .. "," .. LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 3) .. ","
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 4) .. "," .. LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 4) .. "\n"
		end
	end
	return text
end

function createNameTable()
	local NameTable = {}
	if(LoadUnownedLegendaries == false) then
		for name, count in pairs(legendaryCountByRank) do 
			table.insert(NameTable, name) 
		end
		table.sort(NameTable)
	else
		TSMPriceDataByRank = {}
		for name, id in pairs(LegendaryIDsByName) do 
			NameTable[#NameTable + 1] = name;
			LegendaryStockTracker:UpdateTsmPriceForAllRanks(name)
		end
		table.sort(NameTable)	
	end
	return NameTable
end

function LegendaryStockTracker:createFrameSheet(frame)
	NameTable = createNameTable()

	local xStartValue = 15
	local xPosition = xStartValue
	local yPosition = -15
	local YDIFF = 15
	local XDIFF = 15

	if(IsTSMLoaded == false) then
		local titles = {createTableTitle(frame, "Item name"), createTableTitle(frame, "Rank 1"), createTableTitle(frame, "Rank 2"), createTableTitle(frame, "Rank 3"), createTableTitle(frame, "Rank 4")}
		local sheet  = {}
		table.insert(sheet, titles)
		local maxWidth = {0,0,0,0,0}
		for i=1, #NameTable do 
			row = {createTableElement(frame, NameTable[i]),
				createTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 1)), createTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 2)),
				createTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 3)), createTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 4))}
			table.insert(sheet, row)
		end

		for i=1, #sheet do 
			for j=1, #sheet[i] do
				compareTableValue(frame, maxWidth, j, sheet[i][j][2])
			end
		end
		for i=1, #sheet do
			for j=1, #sheet[i] do
				setElementPosition(sheet[i][j][1], xPosition, yPosition)
				xPosition = xPosition + XDIFF + maxWidth[j]
			end
			xPosition = xStartValue
			yPosition = yPosition - YDIFF
		end
	else
		local titles = {createTableTitle(frame, "Item name"), createTableTitle(frame, "Rank 1"), createTableTitle(frame, "Profit Rank 1"), createTableTitle(frame, "Rank 2"),
			createTableTitle(frame, "Profit Rank 2"), createTableTitle(frame, "Rank 3"), createTableTitle(frame, "Profit Rank 3"), createTableTitle(frame, "Rank 4"), createTableTitle(frame, "Profit Rank 4")}
		local sheet  = {}
		table.insert(sheet, titles)
		local maxWidth = {0,0,0,0,0,0,0,0,0}
		for i=1, #NameTable do 
			row = {createTableElement(frame, NameTable[i]),
				createTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 1)), createTableElement(frame, LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 1)),
				createTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 2)), createTableElement(frame, LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 2)),
				createTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 3)), createTableElement(frame, LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 3)),
				createTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 4)), createTableElement(frame, LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 4))}
			table.insert(sheet, row)		
		end
		for i=1, #sheet do 
			for j=1, #sheet[i] do
				compareTableValue(frame, maxWidth, j, sheet[i][j][2])
			end
		end
		for i=1, #sheet do
			for j=1, #sheet[i] do
				setElementPosition(sheet[i][j][1], xPosition, yPosition)
				xPosition = xPosition + XDIFF + maxWidth[j]
			end
			xPosition = xStartValue
			yPosition = yPosition - YDIFF
		end
	end
end

function setElementPosition(element, x, y)
	element:SetPoint("LEFT", x, 0)
	element:SetPoint("TOP", 0, y)
end

function createTableElement(frame, text, yOffset)
	local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fontString:SetJustifyH("LEFT")
	fontString:SetJustifyV("MIDDLE")
	fontString:SetPoint("LEFT", 15, 0)
	fontString:SetPoint("TOP", 0, -15)
	fontString:SetText(text)
	return {fontString, fontString:GetStringWidth(text)}
end

function createTableTitle(frame, text)
	local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontGreen")
	fontString:SetJustifyH("CENTER")
	fontString:SetJustifyV("MIDDLE")
	fontString:SetPoint("LEFT", 15, 0)
	fontString:SetPoint("TOP", 0, -15)
	fontString:SetText(text)
	return {fontString, fontString:GetStringWidth(text)}
end

function compareTableValue(frame, table, index, toCompare)
	if (toCompare > table[index]) then
		table[index] = toCompare
	end
end

function LegendaryStockTracker:AddItemToLegendaryTableIfNotPresent(itemName)
	if (legendaryCountByRank[itemName] == nil) then
		legendaryCountByRank[itemName] = {0,0,0,0,0,0,0,0,0,0} --leaving room for up to 10 legendary ranks
	end
end

function LegendaryStockTracker:AddEmptyTsmPriceDataEntryIfNotPresent(itemName)
	if (TSMPriceDataByRank[itemName] == nil) then
		TSMPriceDataByRank[itemName] = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}} --leaving room for up to 10 legendary ranks
	end
end

function LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(name, rank)
	local string = ""
	string = tostring(TSMPriceDataByRank[name][rank][1] - TSMPriceDataByRank[name][rank][2])
	if(string ~= "0") then
		string = string:sub(1, #string - 4)
	end
	return string;
end

function LegendaryStockTracker:UpdateTsmPriceForAllRanks(itemName)
	LegendaryStockTracker:UpdateTsmPrices(itemName, 1)
	LegendaryStockTracker:UpdateTsmPrices(itemName, 2)
	LegendaryStockTracker:UpdateTsmPrices(itemName, 3)
	LegendaryStockTracker:UpdateTsmPrices(itemName, 4)
end

function LegendaryStockTracker:UpdateTsmPrices(itemName, rank)
	LegendaryStockTracker:AddEmptyTsmPriceDataEntryIfNotPresent(itemName)
	local ItemPrices = TSMPriceDataByRank[itemName]
	if(IsTSMLoaded ~= true) then
		ItemPrices[rank][1] = 0
		ItemPrices[rank][2] = 0
		return nil
	end
	local tsmString = "i:" .. LegendaryIDsByName[itemName]
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
	ItemPrices[rank][1] = TSM_API.GetCustomPriceValue("DBMinBuyout", tsmString)
	ItemPrices[rank][2] = TSM_API.GetCustomPriceValue("AuctioningOpMin", tsmString)
	if(ItemPrices[rank][1] == nil) then
		ItemPrices[rank][1] = TSM_API.GetCustomPriceValue("AuctioningOpNormal", tsmString)
	end
	if(ItemPrices[rank][1] == nil or ItemPrices[rank][2] == nil) then
		ItemPrices[rank][1] = 0
		ItemPrices[rank][2] = 0
	end

	TSMPriceDataByRank[itemName] = ItemPrices
end

function LegendaryStockTracker:GetStockCount(itemName, rank)
	local count = 0
	if (legendaryCountByRank[itemName] ~= nil) then 
		if (legendaryCountByRank[itemName][rank] ~= nil) then 
			count = legendaryCountByRank[itemName][rank] 
		end
	end
	return count
end

function LegendaryStockTracker:CheckIfTSMIsRunning()
	IsTSMLoaded = select(1,IsAddOnLoaded("TradeSkillMaster"))
end

function LegendaryStockTracker:OnItemAdded(self, event, itemKey)
end

function LegendaryStockTracker:ScanAhPrices(item)
	if AuctionHouseFrame and AuctionHouseFrame:IsShown() then
		local itemKeys = {}
		itemKeys[1] = C_AuctionHouse.MakeItemKey(171419,190,nil)
		itemKeys[2] = C_AuctionHouse.MakeItemKey(171419,210,nil)
		itemKeys[3] = C_AuctionHouse.MakeItemKey(171419,225,nil)
		itemKeys[4] = C_AuctionHouse.MakeItemKey(171419,235,nil)
		C_AuctionHouse.SearchForItemKeys(itemKeys, {})
	end
end

