LegendaryStockTracker = LibStub("AceAddon-3.0"):NewAddon("LegendaryStockTracker", "AceConsole-3.0", "AceEvent-3.0")

-- Set up DataBroker for minimap button
local LstockLDB = LibStub("LibDataBroker-1.1"):NewDataObject("LegendaryStockTracker", {
  type = "data source",
  text = "LegendaryStockTracker",
  label = "LegendaryStockTracker",
  icon = "Interface\\AddOns\\LegendaryStockTracker\\logo",
  OnClick = function()
    if LstockFrame and LstockFrame:IsShown() then
      LstockFrame:Hide()
    else
      LegendaryStockTracker:HandleChatCommand("")
    end
  end,
  OnTooltipShow = function(tt)
    tt:AddLine("LegendaryStockTracker")
    tt:AddLine(" ")
    tt:AddLine("Click to show Lstock panel")
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
local gearLinks = {}
local legendaryLinks = {}
local legendaryCountByRank = {}

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
	LegendaryStockTracker:RegisterEvent("BANKFRAME_CLOSED", "GetAllItemsInBank")
	LegendaryStockTracker:RegisterEvent("BANKFRAME_OPENED", "GetAllItemsInBank")
	LegendaryStockTracker:RegisterEvent("OWNED_AUCTIONS_UPDATED", "GetAllItemsInAH")
	LegendaryStockTracker:RegisterEvent("MAIL_INBOX_UPDATE", "GetAllItemsInMailbox")
	LegendaryStockTracker:RegisterEvent("MAIL_CLOSED", "GetAllItemsInMailbox")
end

function LegendaryStockTracker:HandleChatCommand(input)
	LegendaryStockTracker:GetAllItemsInAH()
	LegendaryStockTracker:GetAllItemsInBags()
	LegendaryStockTracker:GetAllItemsInBank() --if the bank is open at the time of command, update bank as well
	--LegendaryStockTracker:GetAllItemsInAH() auctions specifically not updated on command, as we don't know if the ah is closed or the player has no auctions. relying on OWNED_AUCTIONS_UPDATED to update those.
	--LegendaryStockTracker:GetAllItemsInMailbox() mailbox is updated when an item gets taken out, no need to update on command 
	LegendaryStockTracker:AddAllItemsToList()
	LegendaryStockTracker:GetGearFromItems()
	LegendaryStockTracker:GetShadowlandsLegendariesFromGear()
	LegendaryStockTracker:CountLegendariesByRank()
	local f = LegendaryStockTracker:GetMainFrame(LegendaryStockTracker:GenerateExportText())
	f:Show()
end

function LegendaryStockTracker:msg()
	message('OWNED_AUCTIONS_UPDATED')
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
		for bag=NUM_BAG_SLOTS+1,NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			for slot=1,GetContainerNumSlots(bag) do
				if not (GetContainerItemID(bag,slot) == nil) then 
					bankItemLinks[#bankItemLinks+1] = (select(7,GetContainerItemInfo(bag,slot)))
					bankItemCount = bankItemCount + 1
				end
			end
		end
	end
end

function LegendaryStockTracker:GetAllItemsInAH()
	if(C_AuctionHouse.GetNumOwnedAuctions() ~= 0) then
		ahItemLinks = {}
		local numOwnedAuctions = C_AuctionHouse.GetNumOwnedAuctions()
		for i=1, numOwnedAuctions do
			ahItemLinks[#ahItemLinks+1] = C_AuctionHouse.GetOwnedAuctionInfo(i).itemLink
			ahItemCount = ahItemCount + 1
		end
	end
end

function LegendaryStockTracker:GetAllItemsInMailbox()
	mailboxItemLinks = {}
	for i=1, GetInboxNumItems() do
		for j=1,ATTACHMENTS_MAX_RECEIVE do 
			mailboxItemLinks[#mailboxItemLinks+1] = GetInboxItemLink(i, j)
			mailboxItemCount = mailboxItemCount + 1
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
	for i=1, #legendaryLinks do
		local itemName = select(1, GetItemInfo(legendaryLinks[i]))
		local detailedItemLevel = GetDetailedItemLevelInfo(legendaryLinks[i])
		LegendaryStockTracker:AddItemToLegendaryTableIfNotPresent(itemName)
		local itemEntry = legendaryCountByRank[itemName]
		if detailedItemLevel == 190
			then itemEntry[1] = itemEntry[1] + 1
		elseif detailedItemLevel == 210
			then itemEntry[2] = itemEntry[2] + 1
		elseif detailedItemLevel == 225
			then itemEntry[3] = itemEntry[3] + 1
		elseif detailedItemLevel == 235
			then itemEntry[4] = itemEntry[4] + 1
		--add future ranks here
		end
		legendaryCountByRank[itemName] = itemEntry
	end
end

function LegendaryStockTracker:GenerateExportText()
	local keyTable = {}
	for key, val in pairs(legendaryCountByRank) do 
		table.insert(keyTable, key) 
	end
	table.sort(keyTable)
	local text = "Item name, Rank 1, Rank 2, Rank 3, Rank 4\n"
	for i=1, #keyTable do 
		text = text .. keyTable[i] .. "," .. legendaryCountByRank[keyTable[i]][1] .. "," .. legendaryCountByRank[keyTable[i]][2] .. "," .. legendaryCountByRank[keyTable[i]][3] .. "," .. legendaryCountByRank[keyTable[i]][4] .. "\n"
	end
	return text
end

function LegendaryStockTracker:AddItemToLegendaryTableIfNotPresent(itemName)
	if (legendaryCountByRank[itemName] == nil) then
		legendaryCountByRank[itemName] = {0,0,0,0,0,0,0,0,0,0} --leaving room for up to 10 legendary ranks
	end
end