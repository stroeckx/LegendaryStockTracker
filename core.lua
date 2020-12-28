LegendaryStockTracker = LibStub("AceAddon-3.0"):NewAddon("LegendaryStockTracker", "AceConsole-3.0", "AceEvent-3.0")

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
	["Shadowghast Armguards"] =  171419,
	["Shadowghast Breastplate"] =  171412,
	["Shadowghast Gauntlets"] =  171414,
	["Shadowghast Greaves"] =  171416,
	["Shadowghast Helm"] =  171415,
	["Shadowghast Pauldrons"] =  171417,
	["Shadowghast Sabatons"] =  171413,
	["Shadowghast Waistguard"] =  171418,
	
	["Shadowghast Necklace"] =  178927,
	["Shadowghast Ring"] =  178926,
	
	["Grim-Veiled Belt"] =  173248,
	["Grim-Veiled Bracers"] =  173249,
	["Grim-Veiled Cape"] =  173242,
	["Grim-Veiled Hood"] =  173245,
	["Grim-Veiled Mittens"] =  173244,
	["Grim-Veiled Pants"] =  173246,
	["Grim-Veiled Robe"] =  173241,
	["Grim-Veiled Sandals"] =  173243,
	["Grim-Veiled Spaulders"] =  173247,
	
	["Umbrahide Armguards"] =  172321,
	["Umbrahide Gauntlets"] =  172316,
	["Umbrahide Helm"] =  172317,
	["Umbrahide Leggings"] =  172318,
	["Umbrahide Pauldrons"] =  172319,
	["Umbrahide Treads"] =  172315,
	["Umbrahide Vest"] =  172314,
	["Umbrahide Waistguard"] =  172320,
	
	["Boneshatter Armguards"] =  172329,
	["Boneshatter Gauntlets"] =  172324,
	["Boneshatter Greaves"] =  172326,
	["Boneshatter Helm"] =  172325,
	["Boneshatter Pauldrons"] =  172327,
	["Boneshatter Treads"] =  172323,
	["Boneshatter Vest"] =  172322,
	["Boneshatter Waistguard"] =  172328
}
local GUILD_BANK_SLOTS_PER_TAB = 98
local IsTSMLoaded = false;


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
    LegendaryStockTracker:RegisterChatCommand("lstocktest", "Test")
	LegendaryStockTracker:RegisterEvent("BANKFRAME_CLOSED", "GetAllItemsInBank")
	LegendaryStockTracker:RegisterEvent("BANKFRAME_OPENED", "GetAllItemsInBank")
	LegendaryStockTracker:RegisterEvent("OWNED_AUCTIONS_UPDATED", "GetAllItemsInAH")
	LegendaryStockTracker:RegisterEvent("MAIL_INBOX_UPDATE", "GetAllItemsInMailbox")
	LegendaryStockTracker:RegisterEvent("MAIL_CLOSED", "GetAllItemsInMailbox")
	LegendaryStockTracker:RegisterEvent("GUILDBANKFRAME_CLOSED", "GetAllItemsInGuildBank")
	LegendaryStockTracker:RegisterEvent("GUILDBANKFRAME_OPENED", "GetAllItemsInGuildBank")
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
	local f = LegendaryStockTracker:GetMainFrame(LegendaryStockTracker:GenerateExportText())
	f:Show()
end

function LegendaryStockTracker:OnEnable()

end

function LegendaryStockTracker:OnDisable()

end

function LegendaryStockTracker:GetMainFrame(text)
  -- Frame code largely adapted from https://www.wowinterface.com/forums/showpost.php?p=323901&postcount=2
  if not LstockFrame then
    -- Main Frame
    local frameConfig = self.db.profile.frame
    local f = CreateFrame("Frame", "LstockFrame", UIParent, "DialogBoxFrame")
    f:ClearAllPoints()
    -- load position from local DB
    f:SetPoint(
      frameConfig.point,
      frameConfig.relativeFrame,
      frameConfig.relativePoint,
      frameConfig.ofsx,
      frameConfig.ofsy
    )
    f:SetSize(frameConfig.width, frameConfig.height)
    f:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight",
      edgeSize = 16,
      insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    f:SetMovable(true)
    f:SetClampedToScreen(true)
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

    -- scroll frame
    local sf = CreateFrame("ScrollFrame", "LstockScrollFrame", f, "UIPanelScrollFrameTemplate")
    sf:SetPoint("LEFT", 16, 0)
    sf:SetPoint("RIGHT", -32, 0)
    sf:SetPoint("TOP", 0, -32)
    sf:SetPoint("BOTTOM", LstockFrameButton, "TOP", 0, 0)

    -- edit box
    local eb = CreateFrame("EditBox", "LstockEditBox", LstockScrollFrame)
    eb:SetSize(sf:GetSize())
    eb:SetMultiLine(true)
    eb:SetAutoFocus(true)
    eb:SetFontObject("ChatFontNormal")
    eb:SetScript("OnEscapePressed", function() f:Hide() end)
    sf:SetScrollChild(eb)

    -- resizing
    f:SetResizable(true)
    f:SetMinResize(150, 100)
    local rb = CreateFrame("Button", "LstockResizeButton", f)
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
        eb:SetWidth(sf:GetWidth())

        -- save size between sessions
        frameConfig.width = f:GetWidth()
        frameConfig.height = f:GetHeight()
    end)
    LstockFrame = f
  end
  LstockEditBox:SetText(text)
  LstockEditBox:HighlightText()
  return LstockFrame
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
			ahItemLinks[#ahItemLinks+1] = C_AuctionHouse.GetOwnedAuctionInfo(i).itemLink
			ahItemCount = ahItemCount + 1
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
		if select(6, GetItemInfo(itemLinks[i])) == "Armor" then 
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