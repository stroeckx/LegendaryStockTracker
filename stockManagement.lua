local addonName, globalTable = ...
local GUILD_BANK_SLOTS_PER_TAB = 98

local vestigesInBags =
{
	["185960"] = 0,
	["187784"] = 0
}
local isBankOpen = false;
local isAhOpen = false;
local areOwnedAuctionsUpdatedSinceCreation = true;
local L = LibStub("AceLocale-3.0"):GetLocale("LegendaryStockTracker")

local bagUpdateCount = 0;
function LST:GetAllItemsInBags()
	bagUpdateCount = bagUpdateCount + 1;
	LST.db.factionrealm.characters[LST.playerName].bagItemLegendaryLinks = {}
	LST.db.factionrealm.characters[LST.playerName].bagItemLegendaryCount = 0
	vestigesInBags =
	{
		["185960"] = 0,
		["187784"] = 0
	}
    for bag=0,NUM_BAG_SLOTS do
        for slot=1,GetContainerNumSlots(bag) do
            local itemID = C_Container.GetContainerItemID(bag,slot);
            if not (itemID == nil) then
                local itemLink = C_Container.GetContainerItemLink(bag,slot);
                local itemInfo = C_Container.GetContainerItemInfo(bag,slot);
                if(LST:IsItemASLLegendary(itemLink) == true) then
				    LST.db.factionrealm.characters[LST.playerName].bagItemLegendaryLinks[#LST.db.factionrealm.characters[LST.playerName].bagItemLegendaryLinks + 1] = itemLink;
				    LST.db.factionrealm.characters[LST.playerName].bagItemLegendaryCount = LST.db.factionrealm.characters[LST.playerName].bagItemLegendaryCount + 1;
				elseif(itemID == LST.VestigeOfOriginID) then
					vestigesInBags[LST.VestigeOfOriginID] = vestigesInBags[LST.VestigeOfOriginID] + itemInfo.stackCount;
				elseif(itemID == LST.VestigeOfEternalID) then
					vestigesInBags[LST.VestigeOfEternalID] = vestigesInBags[LST.VestigeOfEternalID] + itemInfo.stackCount;
                end
			end
        end
	end
end

function LST:GetVestigesInBags(reagentID)
	return vestigesInBags[reagentID];
end

function LST:AddVestigeToCount(reagentID)
	vestigesInBags[reagentID] = vestigesInBags[reagentID] + 1;
end

function LST:GetAllItemsInBank(event)
    local isBankOpenAfterThisFrame = isBankOpen;
	if(event ~= nil) then
		if(event == "BANKFRAME_OPENED") then
			LST:RegisterEvent("BANKFRAME_CLOSED", "GetAllItemsInBank");
			isBankOpenAfterThisFrame = true;
            isBankOpen = true;
		elseif(event == "BANKFRAME_CLOSED") then
			LST:UnregisterEvent("BANKFRAME_CLOSED", "GetAllItemsInBank");
			isBankOpenAfterThisFrame = false;
		end
	end

	if(isBankOpen == true) then
		LST.db.factionrealm.characters[LST.playerName].bankItemLegendaryLinks = {}
		LST.db.factionrealm.characters[LST.playerName].bankItemLegendaryCount = 0
		--go through all bank bag slots
		for bag=NUM_BAG_SLOTS+1,NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			for slot=1,C_Container.GetContainerNumSlots(bag) do
				if not (C_Container.GetContainerItemID(bag,slot) == nil) then
                    local itemLink = C_Container.GetContainerItemLink(bag,slot);
                    if(LST:IsItemASLLegendary(itemLink) == true) then
					    LST.db.factionrealm.characters[LST.playerName].bankItemLegendaryLinks[#LST.db.factionrealm.characters[LST.playerName].bankItemLegendaryLinks + 1] = itemLink;
					    LST.db.factionrealm.characters[LST.playerName].bankItemLegendaryCount = LST.db.factionrealm.characters[LST.playerName].bankItemLegendaryCount + 1;
                    end
				end
			end
		end
		--go through default 28 bank spaces
		for slot=1,C_Container.GetContainerNumSlots(-1) do
			if not (C_Container.GetContainerItemID(-1,slot) == nil) then
                local itemLink = C_Container.GetContainerItemLink(-1,slot);
                if(LST:IsItemASLLegendary(itemLink) == true) then
				    LST.db.factionrealm.characters[LST.playerName].bankItemLegendaryLinks[#LST.db.factionrealm.characters[LST.playerName].bankItemLegendaryLinks + 1] = itemLink;
				    LST.db.factionrealm.characters[LST.playerName].bankItemLegendaryCount = LST.db.factionrealm.characters[LST.playerName].bankItemLegendaryCount + 1;
                end
			end
		end
	end
    isBankOpen = isBankOpenAfterThisFrame;
end

function LST:OnAhOpened()
	isAhOpen = true;
end

function LST:OnAhClosed()
	if(areOwnedAuctionsUpdatedSinceCreation == false and isAhOpen == true) then
		print(L["error_ah_not_updated_after_posting"]);
	end
	isAhOpen = false;
end

function LST:OnOwnedAuctionsUpdated()
	areOwnedAuctionsUpdatedSinceCreation = true;
	LST:GetAllItemsInAH();
end

function LST:GetAllItemsInAH()
	if(isAhOpen and C_AuctionHouse.GetNumOwnedAuctions() ~= nil) then
		LST.db.factionrealm.characters[LST.playerName].ahItemLegendaryLinks = {}
		LST.db.factionrealm.characters[LST.playerName].ahItemLegendaryCount = 0
		local numOwnedAuctions = C_AuctionHouse.GetNumOwnedAuctions()
		for i=1, numOwnedAuctions do
			LST:CheckOwnedAuction(i);
		end
	end
end

function LST:OnAuctionCreated(event, auctionID)
	--LST:CheckOwnedAuction(auctionID);
	areOwnedAuctionsUpdatedSinceCreation = false;
end

function LST:CheckOwnedAuction(auctionID)
	local auctionInfo = C_AuctionHouse.GetOwnedAuctionInfo(auctionID);
	if(auctionInfo.status == 0) then 
		local itemLink = auctionInfo.itemLink;
		if(LST:IsItemASLLegendary(itemLink) == true) then
			LST.db.factionrealm.characters[LST.playerName].ahItemLegendaryLinks[#LST.db.factionrealm.characters[LST.playerName].ahItemLegendaryLinks + 1] = itemLink;
			LST.db.factionrealm.characters[LST.playerName].ahItemLegendaryCount = LST.db.factionrealm.characters[LST.playerName].ahItemLegendaryCount + 1;
		end
	end
end

function LST:GetAllItemsInMailbox()
	LST.db.factionrealm.characters[LST.playerName].mailboxItemLegendaryLinks = {}
	LST.db.factionrealm.characters[LST.playerName].mailboxItemLegendaryCount = 0
	for i=1, GetInboxNumItems() do
		for j=1,ATTACHMENTS_MAX_RECEIVE do 
			if(GetInboxItemLink(i, j) ~= nil) then
                local itemLink = GetInboxItemLink(i, j);
                if(LST:IsItemASLLegendary(itemLink) == true) then
				    LST.db.factionrealm.characters[LST.playerName].mailboxItemLegendaryLinks[#LST.db.factionrealm.characters[LST.playerName].mailboxItemLegendaryLinks + 1] = itemLink;
				    LST.db.factionrealm.characters[LST.playerName].mailboxItemLegendaryCount = LST.db.factionrealm.characters[LST.playerName].mailboxItemLegendaryCount + 1;
                end
			end
		end
	end
end

function LST:GetAllItemsInGuildBank()
	local guildBankTabCount = GetNumGuildBankTabs()
	local guildName = select(1,GetGuildInfo("player"));
	if(guildBankTabCount > 0 and GetGuildBankTabInfo(1) ~= nil) then
		LST.db.factionrealm.guilds[guildName].GuildBankItemLegendaryLinks = {}
		LST.db.factionrealm.guilds[guildName].GuildBankItemLegendaryCount = 0
		for tab=1,guildBankTabCount do
			for slot=1,GUILD_BANK_SLOTS_PER_TAB do
				if not (GetGuildBankItemInfo(tab,slot) == nil) then 
                    local itemLink = GetGuildBankItemLink(tab,slot);
                    if(LST:IsItemASLLegendary(itemLink) == true) then
					    LST.db.factionrealm.guilds[guildName].GuildBankItemLegendaryLinks[#LST.db.factionrealm.guilds[guildName].GuildBankItemLegendaryLinks + 1] = itemLink;
					    LST.db.factionrealm.guilds[guildName].GuildBankItemLegendaryCount = LST.db.factionrealm.guilds[guildName].GuildBankItemLegendaryCount + 1;
                    end
				end
			end
		end
	end
end

function LST:IsItemASLLegendary(itemLink)
    if(itemLink == nil) then return false end;
    local itemClass = select(12, GetItemInfo(itemLink))
    local itemQuality = select(3, GetItemInfo(itemLink))
    if(itemClass == 4 and itemQuality == 1) then
        local detailedItemLevel = GetDetailedItemLevelInfo(itemLink)

        if (detailedItemLevel > 175) and (detailedItemLevel < 300) then --leaving ilvl room for future upgradres (max 235 at time of writing)
            return true;
        end
    end
    return false;
end

function LST:AddAllItemsToList()
	LST.legendaryLinks = {}
	if(LST.db.profile.settings.includeBags) then
		LST:AddItemsToList("bagItemLegendaryLinks")
	end
	if(LST.db.profile.settings.includeBank) then
		LST:AddItemsToList("bankItemLegendaryLinks")
	end
	if(LST.db.profile.settings.includeAH) then
		LST:AddItemsToList("ahItemLegendaryLinks")
	end
	if(LST.db.profile.settings.includeMail) then
		LST:AddItemsToList("mailboxItemLegendaryLinks")
	end
	if(LST.db.profile.settings.IncludeGuild) then
		for key,val in pairs(LST.db.factionrealm.guilds) do
			for i=1, #LST.db.factionrealm.guilds[key]["GuildBankItemLegendaryLinks"] do
				LST.legendaryLinks[#LST.legendaryLinks+1] = LST.db.factionrealm.guilds[key]["GuildBankItemLegendaryLinks"][i]
			end
		end
	end
end

function LST:AddItemsToList(itemSource)
	for key,val in pairs(LST.db.factionrealm.characters) do
		for i=1, #LST.db.factionrealm.characters[key][itemSource] do
			LST.legendaryLinks[#LST.legendaryLinks+1] = LST.db.factionrealm.characters[key][itemSource][i]
		end
	end
end