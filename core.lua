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
    if LST.LstockMainFrame and LST.LstockMainFrame:IsShown() then
      LST.LstockMainFrame:Hide()
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

local LSTVersion = "v2.21.10"
--local db = nil
LST.db = nil
local LstockIcon = LibStub("LibDBIcon-1.0")
LST.LstockMainFrame = nil
local LSTTableScrollChild = nil
local LSTRestockScrollChild = nil
local LSTMaterialRestockListScrollChild = nil
local tableFrame = nil
local restockFrame = nil
local exportFrame = nil
local materialRestockListFrame = nil;

--all collections of items are stored separately for future expandability
LST.legendaryLinks = {}
LST.PriceDataByRank = {}
LST.materialPrices = {}
LST.Rank1BonusIDs = "::2:1487:6716"
LST.Rank2BonusIDs = "::2:1507:6717"
LST.Rank3BonusIDs = "::2:1522:6718"
LST.Rank4BonusIDs = "::2:1532:6758"
LST.Rank5BonusIDs = "::2:1546:7450"
LST.Rank6BonusIDs = "::2:1559:7451"
LST.Rank7BonusIDs = "::2:1588:7882"

LST.LegendaryItemData = 
{
	["171419"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["171412"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["171414"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["171416"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["171415"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["171417"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["171413"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["171418"] = {["profession"] = 1311, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["178927"] = {["profession"] = 1418, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["178926"] = {["profession"] = 1418, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["173248"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["173249"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["173242"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["173245"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["173244"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["173246"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["173241"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["173243"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["173247"] = {["profession"] = 1395, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172321"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172316"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172317"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172318"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172319"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172315"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172314"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172320"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172329"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172324"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172326"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172325"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172327"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172323"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172322"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}},
	["172328"] = {["profession"] = 1334, ["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0,0,0,0}, ["recipeID"] = {0,0,0,0,0,0,0}}
}
local SLProfessionsIds =
{
	[1418] = {["name"] = "Jewelcrafting", ["skillIndex"] = 755, ["185960"] = 352443, ["187784"] = 359701},
	[1311] = {["name"] = "Blacksmithing", ["skillIndex"] = 164, ["185960"] = 352439, ["187784"] = 359700},
	[1395] = {["name"] = "Tailoring", ["skillIndex"] = 197, ["185960"] = 352445, ["187784"] = 359703},
	[1334] = {["name"] = "Leatherworking", ["skillIndex"] = 165, ["185960"] = 352444, ["187784"] = 359702}
}
local openedProfession = 0;
LST.leggoProf1 = nil;
LST.leggoProf2 = nil;

local IsTSMLoaded = false;
local fontStringPool = nil;
local backgroundLinePool = nil;
local RestockList = {};
local SortedRestockList = {};
LST.MaterialRestockList = {};

LST.VestigeOfOriginID = "185960";
LST.VestigeOfEternalID = "187784";

local NumReagentsToCraft = 
{
	["185960"] =
	{
		[1418] = 0,
		[1311] = 0,
		[1395] = 0,
		[1334] = 0
	},
	["187784"] =
	{
		[1418] = 0,
		[1311] = 0,
		[1395] = 0,
		[1334] = 0
	}
}
local numRanks = 7;
local ShouldUpdateMaterialListOnBagUpdate = false;

local activeTab = nil
local exportTab = nil
local contentFrame = nil
local tabWidth = 150
local tabHeight = 24
local contentWidthOffset = 5
local contentHeightOffset = -25
local isfirstRestockAmountInputChange = true;
local HaveBagsBeenUpdatedThisFrame = false;

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
				UsePercentages = true,
				minProfit = 1000,
				minProfitWhenLeveling = 1000,
				percentageMinProfit = 1,
				percentageMinProfitWhenLeveling = 1,
				restockAmount = 1,
				restockAmountByRank = {1,1,1,1,1,1,1},
				IsRankEnabled = {true, true, true, true, true, true, true},
				minrestockAmount = 1,
				syncTarget = "charactername",
				onlyRestockCraftable = true,
				ShowOtherCraftersInRestockList = true,
				priceSource = L["LST Crafting"],
				ShowOtherCraftersMaterialRestockList = false,
				UseTSMMaterialCounts = false,
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
					professions = {},
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
				vestiges = {},
				OptionalReagents = 
				{
					["185960"] = {},
					["187784"] = {}
				}
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
	LST:RegisterChatCommand("lstsenddata", "SendDataToPlayerCommand")
	
	--events
	LST:RegisterEvent("BANKFRAME_OPENED", "GetAllItemsInBank")
	LST:RegisterEvent("OWNED_AUCTIONS_UPDATED", "OnOwnedAuctionsUpdated")
	LST:RegisterEvent("AUCTION_HOUSE_SHOW", "OnAhOpened")
	LST:RegisterEvent("AUCTION_HOUSE_CLOSED", "OnAhClosed")
	LST:RegisterEvent("AUCTION_HOUSE_AUCTION_CREATED", "OnAuctionCreated")
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
	LST:RegisterEvent("CHAT_MSG_LOOT", "OnItemLooted")

	self:RegisterComm("LST")

	LST:CheckIfTSMIsRunning();
	LST.playerName = UnitName("player")
	--guildName = select(1,GetGuildInfo("player")); --doesn't work on login, only on reloads
	LST.db.factionrealm.characters[LST.playerName].characterName = LST.playerName;
	LST.db.factionrealm.characters[LST.playerName].classNameBase = select(1,UnitClassBase("player"));

	LST:GetAllItemsInBags();
	local item = {};
	for id,data in pairs(LST.LegendaryItemData) do
		local iteminfo = GetItemInfo(id);
		if(iteminfo ~= nil ) then
			LST:ProcessItemInfo(id, true)
		end
	end
	if(tonumber(LST.db.profile.settings.minProfit) == nil) then
		local profit = string.match(LST.db.profile.settings.minProfit, "%d+");
		if(tonumber(profit) == nil) then
			profit = 1000;
		end
		LST.db.profile.settings.minProfit = profit;
	end
	if(tonumber(LST.db.profile.settings.percentageMinProfit) == nil) then
		local profit = string.match(LST.db.profile.settings.percentageMinProfit, "%d+");
		if(tonumber(profit) == nil) then
			profit = 1;
		end
		LST.db.profile.settings.percentageMinProfit = profit;
	end
	if(tonumber(LST.db.profile.settings.minProfitWhenLeveling) == nil) then
		local profit = string.match(LST.db.profile.settings.minProfitWhenLeveling, "%d+");
		if(tonumber(profit) == nil) then
			profit = 1000;
		end
		LST.db.profile.settings.minProfitWhenLeveling = profit;
	end
	if(tonumber(LST.db.profile.settings.percentageMinProfitWhenLeveling) == nil) then
		local profit = string.match(LST.db.profile.settings.percentageMinProfitWhenLeveling, "%d+");
		if(tonumber(profit) == nil) then
			profit = 1;
		end
		LST.db.profile.settings.percentageMinProfitWhenLeveling = profit;
	end
	LST.db.profile.settings.priceSource = L["LST Crafting"];
	if(LST.db.factionrealm.accountUUID == nil or LST.db.factionrealm.accountUUID == "") then
		LST.db.factionrealm.accountUUID = LST:GenerateUUID();
	end
	if(type(LST.db.profile.settings.restockAmount) ~= "number") then
		print("XXX")
		LST.db.profile.settings.restockAmount = 1;
	end
	if(LST.db.profile.settings.restockAmountByRank[1] == 0 and LST.db.profile.settings.restockAmountByRank[2] == 0 and LST.db.profile.settings.restockAmountByRank[3] == 0 and LST.db.profile.settings.restockAmountByRank[4] == 0 and LST.db.profile.settings.restockAmountByRank[5] == 0 and LST.db.profile.settings.restockAmountByRank[6] == 0 and LST.db.profile.settings.restockAmountByRank[7] == 0) then
		LST:SetRestockAmountByRank(LST.db.profile.settings.restockAmount, nil, nil, nil, nil, nil, nil);
	end
	if(LST.db.profile.settings.restockAmountByRank[1] == nil or LST.db.profile.settings.restockAmountByRank[2] == nil or LST.db.profile.settings.restockAmountByRank[3] == nil or LST.db.profile.settings.restockAmountByRank[4] == nil or LST.db.profile.settings.restockAmountByRank[5] == nil or LST.db.profile.settings.restockAmountByRank[6] == nil or LST.db.profile.settings.restockAmountByRank[7] == nil) then
		LST:SetRestockAmountByRank(LST.db.profile.settings.restockAmount, nil, nil, nil, nil, nil, nil);
	end
	LST:InitExtensions();
end

function LST:tst()
	print(LST.db.factionrealm.recipeData.materialList["172439"] ~= nil);
	print(LST.db.factionrealm.recipeData.materialList["172439"].itemName ~= nil);
	print(LST.db.factionrealm.recipeData.materialList["172439"].itemQuality ~= nil);

end

function LST:ProcessItemInfo(itemID, success)
	if(LST.LegendaryItemData[itemID] ~= nil) then
		local itemName, itemLink, _, _, _, _, _, _, _, itemTexture, _, _, _, _, _, _, _ = GetItemInfo(itemID);
		LST.LegendaryItemData[itemID]["name"] = itemName;
		LST.LegendaryItemData[itemID]["itemLink"] = itemLink;
		LST.LegendaryItemData[itemID]["icon"] = itemTexture;
	end
end

function LST:OnItemInfoReceived(event, itemID, success)
	if(success == true) then
		LST:ProcessItemInfo(tostring(tonumber(itemID)), success);
	end
end

function LST:OnNewFrame()
	HaveBagsBeenUpdatedThisFrame = false;
end

function LST:Test()
end

function LST:CheckLegendaryProfessions()
	local prof1, prof2, _, _, _ = GetProfessions();
	if(prof1 ~= nil ) then 
		prof1 = select(7, GetProfessionInfo(prof1));
	end
	if(prof2 ~= nil ) then
		prof2 = select(7, GetProfessionInfo(prof2));
	end
	for slid, data in pairs(SLProfessionsIds) do
		if(data.skillIndex == prof1) then
			LST.leggoProf1 = slid;
		elseif(data.skillIndex == prof2) then
			LST.leggoProf2 = slid;
		end
	end
	LST.db.factionrealm.characters[LST.playerName].professions = {LST.leggoProf1, LST.leggoProf2};
end

function LST:GetTSMitemIDs()
	for bag=0,NUM_BAG_SLOTS do
        for slot=1,GetContainerNumSlots(bag) do
			if not (GetContainerItemID(bag,slot) == nil) then 
                local itemLink = (select(7,GetContainerItemInfo(bag,slot)));
                print(itemLink .. ": " .. TSM_API.ToItemString(itemLink));
			end
        end
	end
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
	--LST:CreateFrameSheet(LST.LstockMainFrame)
end

function LST:UpdateRestock()
	LST:UpdateAllAvailableItemSources();
	LST:GetLegendariesFromItems();
	LST:UpdateRestockList();
	LST:CreateRestockSheet(LSTRestockScrollChild);
end

function LST:UpdateAllAvailableItemSources()
	LST:GetAllItemsInAH();
	LST:GetAllItemsInBags();
	LST:GetAllItemsInBank(); --if the bank is open at the time of command, update bank as well
	--LST:GetAllItemsInAH() auctions specifically not updated on command, as we don't know if the ah is closed or the player has no auctions. relying on OWNED_AUCTIONS_UPDATED to update those.
	--LST:GetAllItemsInMailbox() mailbox is updated anytime the mailbox is updated, no need to update on command 
	LST:GetAllItemsInGuildBank()
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
	if not LST.LstockMainFrame then
		LST:CheckLegendaryProfessions();
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
		LST.LstockMainFrame = f
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
		tabList:SetPoint("TOPLEFT", LST.LstockMainFrame, "TOPLEFT",0,-5)
		tabList:SetPoint("BOTTOMRIGHT", LST.LstockMainFrame, "BOTTOMLEFT",tabWidth,0)

		contentFrame = CreateFrame("Frame","LSTContentFrame",f, BackdropTemplateMixin and "BackdropTemplate")
		contentFrame:SetPoint("TOPLEFT", LST.LstockMainFrame, "TOPLEFT",tabWidth,0)
		contentFrame:SetPoint("BOTTOMRIGHT", LST.LstockMainFrame, "BOTTOMRIGHT")

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
		f:SetResizeBounds(400, 350)
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
			frameConfig.w = f:GetWidth()
			frameConfig.h = f:GetHeight()
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
		heightOffset = LST:AddOptionCheckbox("ShowPricingCheckButton", LSTSettingsScrollChild, "showPricing", L["Show profit"], heightOffset)
		local percentagesCheckBox, minProfitEditBox, minProfitWhenLevelingEditBox = nil
		heightOffset, percentagesCheckBox = LST:AddOptionCheckbox("LSTUsePercentagesCheckButton", LSTSettingsScrollChild, "UsePercentages", L["Show values as percentages"], heightOffset)
		local minProfitSetting = "minProfit";
		local minProfitWhenLevelingSetting = "minProfitWhenLeveling";
		if(LST.db.profile.settings.UsePercentages == true) then 
			minProfitSetting = "percentageMinProfit";
			minProfitWhenLevelingSetting = "percentageMinProfitWhenLeveling";
		end
		heightOffset, minProfitEditBox = LST:AddOptionEditbox("MinProfitEditBox", LSTSettingsScrollChild, minProfitSetting, L["Min profit before restocking"], heightOffset, 45)
		heightOffset, minProfitWhenLevelingEditBox = LST:AddOptionEditbox("minProfitWhenLevelingEditBox", LSTSettingsScrollChild, minProfitWhenLevelingSetting, L["Min profit when not max exp"], heightOffset, 45)
		percentagesCheckBox:SetScript("OnClick", function(cb)
			if cb:GetChecked() then
				LST.db.profile.settings[cb.setting] = true;
				LST:RebindOptionEditbox(minProfitEditBox, "percentageMinProfit");
				LST:RebindOptionEditbox(minProfitWhenLevelingEditBox, "percentageMinProfitWhenLeveling");
			else
				LST.db.profile.settings[cb.setting] = false;
				LST:RebindOptionEditbox(minProfitEditBox, "minProfit");
				LST:RebindOptionEditbox(minProfitWhenLevelingEditBox, "minProfitWhenLeveling");
			end
		end)
		heightOffset = LST:AddOptionEditbox("RestockAmountEditBox", LSTSettingsScrollChild, "restockAmount", L["Restock amount"], heightOffset, 25)
		heightOffset = LST:AddOptionEditbox("MinRestockAmountEditBox", LSTSettingsScrollChild, "minrestockAmount", L["Min restock amount"], heightOffset, 25)
		heightOffset = LST:AddOptionCheckbox("onlyRestockCraftableEditBox", LSTSettingsScrollChild, "onlyRestockCraftable", L["Only restock items I can craft"], heightOffset, 25)
		heightOffset = LST:AddOptionCheckbox("ShowOtherCraftersInRestockListEditBox", LSTSettingsScrollChild, "ShowOtherCraftersInRestockList", L["Show other crafters in restock list"], heightOffset, 25)
		heightOffset = LST:AddOptionCheckboxList("IsRankEnabledCheckBoxList", LSTSettingsScrollChild, "IsRankEnabled", L["Show ranks"], heightOffset, {L["R1"], L["R2"], L["R3"], L["R4"], L["R5"], L["R6"], L["R7"]}, 7)
		heightOffset = LST:AddOptionCheckbox("ShowOtherCraftersCheckBox", LSTSettingsScrollChild, "ShowOtherCraftersMaterialRestockList", L["Show other crafters items in material list"], heightOffset, 25)
		heightOffset = LST:AddOptionCheckbox("UseTSMMaterialCountsCheckBox", LSTSettingsScrollChild, "UseTSMMaterialCounts", L["Use TSM Material Counts"], heightOffset, 25)
		--heightOffset = LST:AddDropdownMenu("LSTPriceSourceDropdown", LSTSettingsScrollChild, heightOffset);
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
		restockFrame.scrollframe = restockFrame.scrollframe or CreateFrame("ScrollFrame", "LSTRestockScrollFrame", restockFrame, BackdropTemplateMixin and "UIPanelScrollFrameTemplate");
		restockFrame.scrollframe:SetPoint("LEFT")
		restockFrame.scrollframe:SetPoint("RIGHT", -22, 0)
		restockFrame.scrollframe:SetPoint("TOP")
		restockFrame.scrollframe:SetPoint("BOTTOM")
		restockFrame:SetScript("OnShow", function()
			LST:CreateRestockSheet(LSTRestockScrollChild)
		end)

		LSTRestockScrollChild = restockFrame.scrollframe.scrollchild or CreateFrame("Frame", "LSTRestockScrollChild", restockFrame.scrollframe);
		LSTRestockScrollChild:SetSize(restockFrame.scrollframe:GetSize())
		restockFrame.scrollframe:SetScrollChild(LSTRestockScrollChild)

		LST:AddCraftButtonToRestock(restockFrame);
		LST:AddUpdateButtonToRestock(restockFrame);

		--material list frame
		materialRestockListFrame = LST:CreateOptionsContentFrame("LSTMaterialRestockListFrame", contentFrame, Backdrop)
		materialRestockListFrame.title:SetText(L["Material list"])
		materialRestockListFrame.scrollframe = materialRestockListFrame.scrollframe or CreateFrame("ScrollFrame", "LSTMaterialRestockListScrollFrame", materialRestockListFrame, BackdropTemplateMixin and "UIPanelScrollFrameTemplate");
		materialRestockListFrame.scrollframe:SetPoint("LEFT")
		materialRestockListFrame.scrollframe:SetPoint("RIGHT", -22, 0)
		materialRestockListFrame.scrollframe:SetPoint("TOP")
		materialRestockListFrame.scrollframe:SetPoint("BOTTOM")
		materialRestockListFrame:SetScript("OnShow", function()
			LST:CreateMaterialRestockListSheet(LSTMaterialRestockListScrollChild)
		end)

		LSTMaterialRestockListScrollChild = materialRestockListFrame.scrollframe.scrollchild or CreateFrame("Frame", "LSTMaterialRestockListScrollChild", materialRestockListFrame.scrollframe);
		LSTMaterialRestockListScrollChild:SetSize(materialRestockListFrame.scrollframe:GetSize())
		materialRestockListFrame.scrollframe:SetScrollChild(LSTMaterialRestockListScrollChild)

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
		LST:AddTab(tabList, tabWidth, 24, 5, materialRestockListFrame, L["Material list"])
		LST:AddTab(tabList, tabWidth, 24, 6, faqFrame, L["FAQ"])
		LST:TabOnClick(tab)

		local closeButton = CreateFrame("Button", "LSTMainFrameCloseButton", f)
		closeButton:SetSize(20,20)
		closeButton:SetText("X")
		closeButton:SetPoint("TOPRIGHT", f, "TOPRIGHT")
		closeButton:SetNormalFontObject("GameFontHighlight")
		closeButton:SetHighlightFontObject("GameFontHighlight")
		closeButton:SetDisabledFontObject("GameFontDisable")
		closeButton:SetScript("OnClick", function()
			LST.LstockMainFrame:Hide()
		end)
		LST.LstockMainFrame:SetScript("OnUpdate", function()
			LST:OnNewFrame();
		end)
		LST.LstockMainFrame:Hide();
	end
	return LST.LstockMainFrame
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
	lastTextElement = LST:AddAnchoredFontString("FAQ_Vestiges_Title", frame, frame2, horizontalPadding, verticalOffset, "FAQ_Vestiges_Title", lastTextElement, "GameFontNormal");
	verticalOffset = -5;
	lastTextElement = LST:AddAnchoredFontString("FAQ_Vestiges_Description", frame, frame2, horizontalPadding, verticalOffset, "FAQ_Vestiges_Description", lastTextElement);
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
	local cb = CreateFrame("CheckButton", name, parent, "OptionsBaseCheckButtonTemplate")
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
	return heightOffset - 20, cb
end

function LST:AddOptionCheckboxList(name, parent, setting, description, heightOffset, subDescriptions, numItems)
	local f = CreateFrame("Frame", name, parent, BackdropTemplateMixin and "BackdropTemplate")
	f:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, heightOffset)
	f:SetSize(20,20)

	local text = f:CreateFontString(nil ,"ARTWORK" ,"GameFontHighlight" ) 
	text:SetPoint("LEFT", f, "LEFT", 0, 1)
	text:SetText(description)

	f:SetWidth(text:GetStringWidth());

	local frame = f;
	for i=1, numItems do
		local cb = CreateFrame("CheckButton", name .. i, parent, "OptionsBaseCheckButtonTemplate");
		cb:SetSize(20,20);
		cb:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, 0);
		cb.setting = setting;
		cb.index = i;
		cb:SetHitRectInsets(0, 0, 0, 0);
		cb:SetChecked(LST.db.profile.settings[cb.setting][cb.index]);
		cb:SetScript("OnClick", function(cb)
			if cb:GetChecked() then
				LST.db.profile.settings[cb.setting][cb.index] = true;
			else
				LST.db.profile.settings[cb.setting][cb.index] = false;
			end
		end)
		frame = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
		frame:SetPoint("TOPLEFT", cb, "TOPRIGHT", 0, 0)
		frame:SetSize(20,20)

		local text = frame:CreateFontString(nil,"ARTWORK", "GameFontHighlight");
		text:SetPoint("LEFT", frame, "LEFT", 0, 0);
		text:SetHeight(20);
		text:SetText(subDescriptions[i]);
		frame:SetSize(text:GetStringWidth(),20)
end
	
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
	eb:SetTextColor(LST:GetTextColor("white"))
	eb.setting = setting
	eb:SetText(LST.db.profile.settings[eb.setting])
	eb:SetScript("OnTextChanged", function(self)
		LST.db.profile.settings[eb.setting] = self:GetText()
		if(eb.setting == "restockAmount") then
			if(isfirstRestockAmountInputChange) then
				isfirstRestockAmountInputChange = false;
				return;
			else
				LST:SetRestockAmountByRank(LST.db.profile.settings.restockAmount, nil, nil, nil, nil, nil, nil);
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

function LST:RebindOptionEditbox(editBox, newSetting)
	editBox.setting = newSetting
	editBox:SetText(LST.db.profile.settings[editBox.setting])
	editBox:SetScript("OnTextChanged", function(self)
		LST.db.profile.settings[editBox.setting] = self:GetText()
		if(editBox.setting == "restockAmount") then
			if(isfirstRestockAmountInputChange) then
				isfirstRestockAmountInputChange = false;
				return;
			else
				LST:SetRestockAmountByRank(LST.db.profile.settings.restockAmount, nil, nil, nil, nil, nil, nil);
			end
		end
	end)
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
	local button = LST:CreateButton("LSTCraftNextButton", restockFrame, 100, 24, "craft next");
	button:SetScript("OnClick", function(self) LST:CraftNextRestockItem() end)
end

function LST:AddUpdateButtonToRestock(restockFrame)
	local button = LST:CreateButton("LSTUpdateRestocklistButton", restockFrame, 100, 24, "Update list");
	button:SetPoint("TOPLEFT", restockFrame, "BOTTOMLEFT", 105, 2);
	button:SetScript("OnClick", function(self) LST:UpdateRestock() end)
end

function LST:CreateButton(name, parent, width, height, textKey)
	local button = CreateFrame("Button", name, parent, BackdropTemplateMixin and "BackdropTemplate");
	Backdrop = {
		bgFile = "Interface\\AddOns\\LegendaryStockTracker\\Assets\\Plain.tga",
		edgeFile = "Interface/Buttons/WHITE8X8",
		tile = true, tileSize = 0, edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 0},
	}
	button:SetBackdrop(Backdrop)
	button:SetBackdropColor(0.25,0.25,0.25,0.9)
	button:SetBackdropBorderColor(0,0,0,1)
	button:SetSize(width, height)
	button.HighlightTexture = button:CreateTexture()
	button.HighlightTexture:SetColorTexture(1,1,1,.3)
	button.HighlightTexture:SetPoint("TOPLEFT")
	button.HighlightTexture:SetPoint("BOTTOMRIGHT")
	button:SetHighlightTexture(button.HighlightTexture)
	button.PushedTexture = button:CreateTexture()
	button.PushedTexture:SetColorTexture(.9,.8,.1,.3)
	button.PushedTexture:SetPoint("TOPLEFT")
	button.PushedTexture:SetPoint("BOTTOMRIGHT")
	button:SetPushedTexture(button.PushedTexture)
	button:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, 2);

	local text = button:CreateFontString(nil,"ARTWORK", "GameFontHighlight") 
	text:SetPoint("TOPLEFT")
	text:SetPoint("BOTTOMRIGHT")
	text:SetText(L[textKey])
	return button
end

function LST:OnEnable()

end

function LST:OnDisable()

end

function LST:OnBagsUpdated(bagIndex)
	if(ShouldUpdateMaterialListOnBagUpdate == true) then
			LST:CreateMaterialRestockListSheet(LSTMaterialRestockListScrollChild);
			ShouldUpdateMaterialListOnBagUpdate = false;
	end;
	--if(HaveBagsBeenUpdatedThisFrame == true) then return end;
	--LST:UpdateShownTab();
	--HaveBagsBeenUpdatedThisFrame = true;
end

function LST:UpdateShownTab()
	if not LST.LstockMainFrame then
		return nil
	end
	if(tableFrame:IsVisible()) then
		LST:UpdateTable();
	end
	if(exportFrame:IsVisible()) then
		LST:UpdateExportText();
	end
	if(restockFrame:IsVisible()) then
		LST:CreateRestockSheet(LSTRestockScrollChild);
	end
	if(materialRestockListFrame:IsVisible()) then
		LST:CreateMaterialRestockListSheet(LSTMaterialRestockListScrollChild)
	end
end

function LST:CountLegendariesByRank()
	LST:CountLegendariesByRankWithoutSyncdata();
	LST:UpdateMaterialPrices();
	if(LST.db.profile.settings.IncludeSyncData) then
		for account, accountdata in pairs(LST.db.factionrealm.syncData) do
			for id, data in pairs (accountdata["legendaries"]) do
				for rank, count in pairs(data["stock"]) do
					LST.LegendaryItemData[id]["stock"][rank] = LST.LegendaryItemData[id]["stock"][rank] + count;
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
	elseif itemlevel == 291 then
		rank = 7;
	end
	return rank;
end

function LST:CountLegendariesByRankWithoutSyncdata()
	for id, data in pairs (LST.LegendaryItemData) do
		for rank, count in pairs(LST.LegendaryItemData[id]["stock"]) do
			LST.LegendaryItemData[id]["stock"][rank] = 0;
		end
	end
	
	--if(isTSMPriceUpdated == false) then
		LST.PriceDataByRank = {}
	--end
	LST:UpdateMaterialPrices();
	for i=1, #LST.legendaryLinks do
		local itemID = select(3, strfind(LST.legendaryLinks[i], "item:(%d+)"));
		local detailedItemLevel = GetDetailedItemLevelInfo(LST.legendaryLinks[i]);
		if(detailedItemLevel == nil) then
			print(L["Incorrect itemlevel data received for item "] .. LST.LegendaryItemData[itemID]["name"] .. L[", skipping data for this rank."])
			return;
		end
		local rank = LST:GetLegendaryRankByItemLevel(detailedItemLevel);
		LST.LegendaryItemData[itemID]["stock"][rank] = LST.LegendaryItemData[itemID]["stock"][rank] + 1;
	end
end

function LST:GetUnlockedCraftRank(itemID, includeSyncData)
	if(includeSyncData == nil) then
		includeSyncData = true;
	end
	local unlockedRank  = 0;
	local crafter = nil;
	for key,val in pairs(LST.db.factionrealm.characters) do
		if(LST.db.factionrealm.characters[key].unlockedLegendaryCraftRanks[itemID] ~= nil and LST.db.factionrealm.characters[key].unlockedLegendaryCraftRanks[itemID] > unlockedRank) then
			unlockedRank = LST.db.factionrealm.characters[key].unlockedLegendaryCraftRanks[itemID];
			crafter = key;
		end
	end
	if(includeSyncData == true) then
		for account,data in pairs(LST.db.factionrealm.syncData) do
			if(data ~= nil and data["legendaries"] ~= nil and data["legendaries"][itemID] ~= nil and data["legendaries"][itemID]["canCraft"] > unlockedRank) then
				unlockedRank = data["legendaries"][itemID]["canCraft"];
				crafter = data["legendaries"][itemID]["crafter"];
			end
		end
	end
	return unlockedRank, crafter;
end

function LST:CanCraft(itemID, rank)
	local unlockedRank, crafter = LST:GetUnlockedCraftRank(itemID);
	if(unlockedRank >= rank) then 
		return true, crafter;
	end
	if(LST.db.factionrealm.recipeData.OptionalReagents[LST.VestigeOfOriginID][LST.LegendaryItemData[itemID]["profession"]] ~= nil) then
		if(unlockedRank + 2 >= rank) then 
			return true, crafter;
		end
	end
	if(LST.db.factionrealm.recipeData.OptionalReagents[LST.VestigeOfEternalID][LST.LegendaryItemData[itemID]["profession"]] ~= nil) then
		if(unlockedRank + 3 >= rank) then 
			return true, crafter;
		end
	end
	return false, crafter;
end

function LST:IsRecipeMaxLevel(itemID)
	if(LST:GetUnlockedCraftRank(itemID) < 4) then
		return false;
	else
		return true;
	end
end

function LST:UpdateRestockList()
	RestockList = {};
	LST.MaterialRestockList = {};
	local nameTable = LST:createNameTable();
	local restockAmount = {};
	NumReagentsToCraft = 
	{
		["185960"] =
		{
			[1418] = 0,
			[1311] = 0,
			[1395] = 0,
			[1334] = 0
		},
		["187784"] =
		{
			[1418] = 0,
			[1311] = 0,
			[1395] = 0,
			[1334] = 0
		}
	}
	restockAmount[1] = tonumber(LST.db.profile.settings.restockAmountByRank[1]);
	restockAmount[2] = tonumber(LST.db.profile.settings.restockAmountByRank[2]);
	restockAmount[3] = tonumber(LST.db.profile.settings.restockAmountByRank[3]);
	restockAmount[4] = tonumber(LST.db.profile.settings.restockAmountByRank[4]);
	restockAmount[5] = tonumber(LST.db.profile.settings.restockAmountByRank[5]);
	restockAmount[6] = tonumber(LST.db.profile.settings.restockAmountByRank[6]);
	restockAmount[7] = tonumber(LST.db.profile.settings.restockAmountByRank[7]);
	for item=1, #nameTable do
		for rank=1, numRanks do
			local canCraft, crafter = LST:CanCraft(nameTable[item], rank)
			if((not LST.db.profile.settings.onlyRestockCraftable or (LST.db.profile.settings.onlyRestockCraftable and canCraft)) and LST.db.profile.settings.IsRankEnabled[rank] == true) then
				if LST.db.profile.settings.ShowOtherCraftersInRestockList == true or crafter == LST.playerName then
					local currentStock = tonumber(LST:GetStockCount(nameTable[item], rank))
					if currentStock < restockAmount[rank] and restockAmount[rank] - currentStock >= tonumber(LST.db.profile.settings.minrestockAmount) then 
						if(IsTSMLoaded == false or LST.db.profile.settings.showPricing == false) then
							LST:AddItemToRestockList(nameTable[item], rank, restockAmount[rank] - currentStock);
						else
							if(LST:GetProfit(nameTable[item], rank, true) ~= L["not scanned"] ) then
								if tonumber(LST:GetProfit(nameTable[item], rank, true)) > LST:GetMinProfit(LST:GetCheapestCraftCost(nameTable[item], rank, true), nameTable[item]) then
									LST:AddItemToRestockList(nameTable[item], rank, restockAmount[rank] - currentStock);
								end
							end
						end
					end
				end
			end
		end
	end
	if(LST.db.profile.settings.ShowOtherCraftersMaterialRestockList == true) then
		for reagent, data in pairs(NumReagentsToCraft) do
			for prof, count in pairs(data) do
				LST:AddReagentToMaterialList(count, prof, reagent);
			end
		end
	else
		local price, profession = LST:GetCheapestReagentProfession(LST.VestigeOfOriginID);
		if(profession ~= 0 and profession ~= nil) then
			NumReagentsToCraft[LST.VestigeOfOriginID][profession] = NumReagentsToCraft[LST.VestigeOfOriginID][profession] - LST:GetVestigesInBags(LST.VestigeOfOriginID);
			LST:AddReagentToMaterialList(NumReagentsToCraft[LST.VestigeOfOriginID][profession], profession, LST.VestigeOfOriginID);
		end
		local price, profession = LST:GetCheapestReagentProfession(LST.VestigeOfEternalID);
		if(profession ~= 0 and profession ~= nil) then
			NumReagentsToCraft[LST.VestigeOfEternalID][profession] = NumReagentsToCraft[LST.VestigeOfEternalID][profession] - LST:GetVestigesInBags(LST.VestigeOfEternalID);
			LST:AddReagentToMaterialList(NumReagentsToCraft[LST.VestigeOfEternalID][profession], profession, LST.VestigeOfEternalID);
		end
	end
end

function LST:UpdateSortedRestockList()
	SortedRestockList = {};
	for k,v in pairs(RestockList) do table.insert(SortedRestockList, v) end;
	table.sort(SortedRestockList, 
		function(x,y) 
			if(x.profession > y.profession) then return true;
			else if(x.profession < y.profession) then return false end;
			if(x.profit > y.profit) then return true;
			else return false end;
		end
	end)
end

function LST:AddItemToRestockList(itemID, rank, restockCount)
	local localProfit =  0;
	local localProfitPercentage =  0;
	if(LST.db.profile.settings.showPricing == true and IsTSMLoaded == true) then
		localProfit = LST:GetProfit(itemID, rank, true);
		localProfitPercentage = LST:GetProfitPercentage(itemID, rank, true);
	end
	local itemToRestock = 
	{
		name = LST.LegendaryItemData[itemID]["name"], 
		rank = rank,
		amountToRestock = restockCount, 
		profit = localProfit, 
		itemID = itemID,
		profitPercentage = localProfitPercentage,
		usesVestige = LST:AddVestigeToRestock(rank, itemID, restockCount),
		profession = LST.LegendaryItemData[itemID]["profession"]
	}
	if(LST:DoesThisCharacterHaveProfession(LST.LegendaryItemData[itemID].profession) or LST.db.profile.settings.ShowOtherCraftersMaterialRestockList == true) then
		if(itemToRestock.usesVestige == nil) then
			LST:AddMaterialsToMaterialRestockList(LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank], restockCount);
		elseif(itemToRestock.usesVestige == LST.VestigeOfOriginID) then
			LST:AddMaterialsToMaterialRestockList(LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank - 2], restockCount);
		elseif(itemToRestock.usesVestige == LST.VestigeOfEternalID) then
			LST:AddMaterialsToMaterialRestockList(LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank - 3], restockCount);
		end
	end
	RestockList[itemID .. rank] = itemToRestock;
end

function LST:AddMaterialsToMaterialRestockList(table, count)
	for materialID, data in pairs(table) do
		if(LST.MaterialRestockList[materialID] == nil) then LST.MaterialRestockList[materialID] = 0; end;
		LST.MaterialRestockList[materialID] = LST.MaterialRestockList[materialID] + (data["numRequired"] * count);
	end
end

function LST:RemoveMaterialsFromRestockList(table)
	for materialID, data in pairs(table) do
		LST.MaterialRestockList[materialID] = LST.MaterialRestockList[materialID] - data["numRequired"];
		if(LST.MaterialRestockList[materialID] == 0) then LST.MaterialRestockList[materialID] = nil; end;
	end
end

function LST:AddReagentToMaterialList(numVestiges, vestigeProfession, vestigeID)
	if(numVestiges <= 0) then return; end;
	if(LST:DoesThisCharacterHaveProfession(vestigeProfession) == false and LST.db.profile.settings.ShowOtherCraftersMaterialRestockList == false) then return; end;
	for materialID, data in pairs(LST.db.factionrealm.recipeData.OptionalReagents[vestigeID][vestigeProfession]) do
		if(LST.MaterialRestockList[materialID] == nil) then LST.MaterialRestockList[materialID] = 0; end;
		LST.MaterialRestockList[materialID] = LST.MaterialRestockList[materialID] + (data["numRequired"] * numVestiges);
	end
end

function LST:RemoveReagentFromMaterialList(numVestiges, professionID, vestigeID)
	if(numVestiges <= 0) then return; end;
	local _, vestigeProfession = LST:GetCheapestReagentProfession(vestigeID);
	if(LST:DoesThisCharacterHaveProfession(vestigeProfession) == false) then return; end;
	for materialID, data in pairs(LST.db.factionrealm.recipeData.OptionalReagents[vestigeID][vestigeProfession]) do
		LST.MaterialRestockList[materialID] = LST.MaterialRestockList[materialID] - (data["numRequired"] * numVestiges);
		if(LST.MaterialRestockList[materialID] == 0) then LST.MaterialRestockList[materialID] = nil; end;
	end
end

function LST:AddVestigeToRestock(rank, itemID, count) 
	if(IsTSMLoaded == false or LST.db.profile.settings.showPricing == false) then
		if(rank == 5 or rank == 6 ) then
			local prof = LST.LegendaryItemData[itemID]["profession"];
			NumReagentsToCraft[LST.VestigeOfOriginID][prof] = NumReagentsToCraft[LST.VestigeOfOriginID][prof] + count;
			return LST.VestigeOfOriginID;
		elseif(rank == 7) then
			local prof = LST.LegendaryItemData[itemID]["profession"];
			NumReagentsToCraft[LST.VestigeOfEternalID][prof] = NumReagentsToCraft[LST.VestigeOfEternalID][prof] + count;
			return LST.VestigeOfEternalID;
		else return nil end;
	end;

	local unlockedRank, crafter = LST:GetUnlockedCraftRank(itemID);
	if(crafter == nil) then
		print(L["error_unknown_crafter"] .. itemID);
		return nil;
	end;
	local price, vestigeID = LST:GetCheapestCraftCost(itemID, rank, true);
	if(vestigeID == nil) then 
		return nil;
	end
	local price, prof = LST:GetCheapestReagentProfessionForCrafter(crafter, vestigeID)
	if(prof == 0) then
		print("LST: " .. crafter .. L["error_crafter_can't_make_vestige"]);
		return nil;
	end
	NumReagentsToCraft[vestigeID][prof] = NumReagentsToCraft[vestigeID][prof] + count;
	return vestigeID;
end

function LST:DoesThisCharacterHaveProfession(slid)
	if(slid == LST.leggoProf1) then return true end
	if(slid == LST.leggoProf2) then return true end;
	return false;
end

function LST:GenerateExportText()
	local NameTable = LST:createNameTable()
	local text = ""
	if(IsTSMLoaded == false or LST.db.profile.settings.showPricing == false) then
		text = L["Item name, Rank 1, Rank 2, Rank 3, Rank 4, Rank 5, Rank 6\n"]
		for i=1, #NameTable do 
			text = text .. LST.LegendaryItemData[NameTable[i]]["name"] .. "," 
			.. LST:GetStockCount(NameTable[i], 1) .. "," 
			.. LST:GetStockCount(NameTable[i], 2) .. "," 
			.. LST:GetStockCount(NameTable[i], 3) .. "," 
			.. LST:GetStockCount(NameTable[i], 4) .. "," 
			.. LST:GetStockCount(NameTable[i], 5) .. "," 
			.. LST:GetStockCount(NameTable[i], 6) .. "," 
			.. LST:GetStockCount(NameTable[i], 7) .. "\n" 
		end
	else
		text = L["Item name, Rank 1, Profit Rank 1, Rank 2, Profit Rank 2, Rank 3, Profit Rank 3, Rank 4, Profit Rank 4, Rank 5, Profit Rank 5, Rank 6, Profit Rank 6\n"]
		for i=1, #NameTable do 
			text = text .. LST.LegendaryItemData[NameTable[i]]["name"] .. "," 
			.. LST:GetStockCount(NameTable[i], 1) .. "," .. tostring(LST:RoundToInt(LST:GetProfit(NameTable[i], 1, false))) .. ","
			.. LST:GetStockCount(NameTable[i], 2) .. "," .. tostring(LST:RoundToInt(LST:GetProfit(NameTable[i], 2, false))) .. ","
			.. LST:GetStockCount(NameTable[i], 3) .. "," .. tostring(LST:RoundToInt(LST:GetProfit(NameTable[i], 3, false))) .. ","
			.. LST:GetStockCount(NameTable[i], 4) .. "," .. tostring(LST:RoundToInt(LST:GetProfit(NameTable[i], 4, false))) .. ","
			.. LST:GetStockCount(NameTable[i], 5) .. "," .. tostring(LST:RoundToInt(LST:GetProfit(NameTable[i], 5, false))) .. ","
			.. LST:GetStockCount(NameTable[i], 6) .. "," .. tostring(LST:RoundToInt(LST:GetProfit(NameTable[i], 6, false))) .. ","
			.. LST:GetStockCount(NameTable[i], 7) .. "," .. tostring(LST:RoundToInt(LST:GetProfit(NameTable[i], 7, false))) .. "\n"
		end
	end
	return text;
end

function LST:createNameTable()
	local NameTable = {} --nametable is now "list of items to export"
	--if(isTSMPriceUpdated == false) then
		LST.PriceDataByRank = {}
	--end
	LST:UpdateMaterialPrices();
	for id, data in pairs(LST.LegendaryItemData) do 
		table.insert(NameTable, id);
		LST:UpdateTsmPriceForAllRanks(id);
	end
	--print("updated prices")
	--isTSMPriceUpdated = true;
	table.sort(NameTable)	
	return NameTable
end

function LST:CreateRestockSheet(frame)
	LST:UpdateSortedRestockList();
	if(frame == nil) then return end;
	local NameTable = LST:createNameTable();
	local CurrentProfession = 0;
	local PastProfessions = {}
	LST:PrepareTablePools(frame);
	local sheet = {}
	local titles = {LST:CreateTableTitle(frame, L["Item"]), LST:CreateTableTitle(frame, L["Amount"]), LST:CreateTableTitle(frame, L["Vestige"]), LST:CreateTableTitle(frame, L["Profit"]), LST:CreateTableTitle(frame, L["Profit"] .. " (%)")}
	table.insert(sheet, titles)
	for i, restockData in ipairs(SortedRestockList) do
		if(restockData["profession"] ~= CurrentProfession) then
			CurrentProfession = restockData["profession"];
			PastProfessions[CurrentProfession] = 1;
			row = 
			{
				LST:CreateTableElement(frame, SLProfessionsIds[CurrentProfession]["name"], LST:GetTextColor("yellow")),
				LST:CreateTableElement(frame, "", 1, 1, 1, 1),
				LST:CreateTableElement(frame, "", 1, 1, 1, 1),
				LST:CreateTableElement(frame, "", 1, 1, 1, 1),
				LST:CreateTableElement(frame, "", 1, 1, 1, 1),
			}
			table.insert(sheet, row)

			for reagent, data in pairs(NumReagentsToCraft) do
				if(NumReagentsToCraft[reagent][CurrentProfession] > 0) then 
					row = 
					{
						LST:CreateTableElement(frame, L[reagent], LST:GetTextColor("legendary")),
						LST:CreateTableElement(frame, NumReagentsToCraft[reagent][CurrentProfession], 1, 1, 1, 1),
						LST:CreateTableElement(frame, "", 1, 1, 1, 1),
						LST:CreateTableElement(frame, "", 1, 1, 1, 1),
						LST:CreateTableElement(frame, "", 1, 1, 1, 1)
					}
					table.insert(sheet, row)
				end
			end
		end
		row = 
		{
			LST:CreateTableElement(frame, SortedRestockList[i]["name"] .. " - " .. L["Rank"] .. " " .. SortedRestockList[i]["rank"], 1, 1, 1, 1),
			LST:CreateTableElement(frame, SortedRestockList[i]["amountToRestock"], 1, 1, 1, 1),
			LST:CreateTableElement(frame, LST:GetUsesVestigeCheckmark(SortedRestockList[i]["usesVestige"]), 1, 1, 1, 1),
			LST:CreateTableElement(frame, LST:RoundToInt(SortedRestockList[i]["profit"]), 1, 1, 1, 1),
			LST:CreateTableElement(frame, LST:RoundToInt(SortedRestockList[i]["profitPercentage"]) .. "%", 1, 1, 1, 1)
		}
		--print(row[1][1])
		--print(row[1][2])
		--local texture = frame:CreateTexture()
		----texture:SetParent(row[1][1])
		--texture:SetDrawLayer("OVERLAY")
		--texture:SetTexture(GetItemIcon(185960))
		--texture:SetPoint("CENTER")
		--texture:SetSize(36, 36)
		table.insert(sheet, row)
	end
	for reagent, data in pairs(NumReagentsToCraft) do
		for prof, count in pairs(data) do
			if(count > 0) then 
				if(PastProfessions[prof] == nil) then
					row = 
					{
						LST:CreateTableElement(frame, SLProfessionsIds[prof]["name"], LST:GetTextColor("yellow")),
						LST:CreateTableElement(frame, "", 1, 1, 1, 1),
						LST:CreateTableElement(frame, "", 1, 1, 1, 1),
						LST:CreateTableElement(frame, "", 1, 1, 1, 1),
						LST:CreateTableElement(frame, "", 1, 1, 1, 1),
					}
					table.insert(sheet, row)

					if(NumReagentsToCraft[reagent][prof] > 0) then 
						row = 
						{
							LST:CreateTableElement(frame, L[reagent], LST:GetTextColor("legendary")),
							LST:CreateTableElement(frame, NumReagentsToCraft[reagent][prof], 1, 1, 1, 1),
							LST:CreateTableElement(frame, "", 1, 1, 1, 1),
							LST:CreateTableElement(frame, "", 1, 1, 1, 1),
							LST:CreateTableElement(frame, "", 1, 1, 1, 1)
						}
						table.insert(sheet, row)
					end
				end
			end
		end
	end
	LST:CreateFrameSheet(frame, sheet, 5)
end

function LST:CreateMaterialRestockListSheet(frame)
	if(frame == nil) then return end;
	LST:PrepareTablePools(frame);
	local sheet = {}
	local titles = {LST:CreateTableTitle(frame, L["Item"]), LST:CreateTableTitle(frame, L["needed"]), LST:CreateTableTitle(frame, L["available"]), LST:CreateTableTitle(frame, L["missing"])}--, LST:CreateTableTitle(frame, L["Profit"] .. " (%)")}
	table.insert(sheet, titles)
	for materialID, count in pairs(LST.MaterialRestockList) do
		local numOwned = 0;
		if(LST.db.profile.settings.UseTSMMaterialCounts == true) then
			local num1, num2, num3, num4 = TSM_API.GetPlayerTotals("i:" .. materialID);
			local num5 = TSM_API.GetGuildTotal("i:" .. materialID);
			numOwned = num1 + num2 + num3 + num4 + num5;
		else
			numOwned = GetItemCount(materialID, true, false, true);
		end
		local numMissing = LST.MaterialRestockList[materialID] - numOwned;
		if(numMissing < 0) then numMissing = 0; end; 
		
		local itemText = ""
		if(LST.db.factionrealm.recipeData.materialList[tostring(materialID)] ~= nil and LST.db.factionrealm.recipeData.materialList[tostring(materialID)].itemName ~= nil and LST.db.factionrealm.recipeData.materialList[tostring(materialID)].itemQuality ~= nil) then
			local r, g, b, hex = GetItemQualityColor(LST.db.factionrealm.recipeData.materialList[tostring(materialID)].itemQuality)
			itemText = "|c" .. hex .. LST.db.factionrealm.recipeData.materialList[tostring(materialID)].itemName
		else
			print(materialID);
			print(tostring(LST.db.factionrealm.recipeData.materialList[materialID]));
			print(tostring(LST.db.factionrealm.recipeData.materialList[materialID].itemName));
			print(tostring(LST.db.factionrealm.recipeData.materialList[materialID].itemQuality));
			print(L["error_missing_material_info"])
			if(LST.db.factionrealm.recipeData.materialList[tostring(materialID)] ~= nil) then
				itemText = LST.db.factionrealm.recipeData.materialList[tostring(materialID)]; --show legacy data if present
			end
			LST:UpdateMaterialInfo(materialID);
		end
		row = 
		{
			LST:CreateTableElement(frame, itemText, 1, 1, 1, 1),
			LST:CreateTableElement(frame, LST.MaterialRestockList[materialID], 1, 1, 1, 1),
			LST:CreateTableElement(frame, numOwned, 1, 1, 1, 1),
			LST:CreateTableElement(frame, numMissing, 1, 1, 1, 1)
		}
		table.insert(sheet, row)
	end
	LST:CreateFrameSheet(frame, sheet, 4)
end

function LST:UpdateMaterialInfo(materialID)
	local currentData = LST.db.factionrealm.recipeData.materialList[materialID];
	if(currentData == nil or currentData["itemName"] == nil or currentData["itemLink"] == nil or currentData["itemQuality"] == nil or currentData["itemIcon"] == nil) then
		local item = Item:CreateFromItemID(tonumber(materialID));

		item:ContinueOnItemLoad(function()
			local newData = {};
			newData["itemName"] = item:GetItemName();
			newData["itemLink"] = item:GetItemLink();
			newData["itemQuality"] = item:GetItemQuality();
			newData["itemIcon"] = item:GetItemIcon();
			LST.db.factionrealm.recipeData.materialList[tostring(item:GetItemID())] = newData;
		end)
	end
end

function LST:GetUsesVestigeCheckmark(usesVestige)
	if(usesVestige == LST.VestigeOfOriginID) then
		return "O";
	elseif(usesVestige == LST.VestigeOfEternalID) then
		return "E";
	else
		return "";
	end
end

function LST:CreateTableSheet(frame)
	local NameTable = LST:createNameTable()
	LST:PrepareTablePools(frame);
	local sheet = {}
	local maxwidth = {};
	if(IsTSMLoaded == false or LST.db.profile.settings.showPricing == false) then
		local titles = {};
		table.insert(titles, LST:CreateTableTitle(frame, L["Item name"]))
		for r=1, numRanks do
			if(LST.db.profile.settings.IsRankEnabled[r] == true) then
				table.insert(titles, LST:CreateTableTitle(frame, L["R" .. r]))
			end
		end
		--local titles = {LST:CreateTableTitle(frame, L["Item name"]), LST:CreateTableTitle(frame, L["Rank 1"]), LST:CreateTableTitle(frame, L["Rank 2"]), LST:CreateTableTitle(frame, L["Rank 3"]), LST:CreateTableTitle(frame, L["Rank 4"]), LST:CreateTableTitle(frame, L["Rank 5"]), LST:CreateTableTitle(frame, L["Rank 6"])}
		table.insert(sheet, titles)
		maxWidth = {0,0,0,0,0,0,0,0}
		local stockSum = {0,0,0,0,0,0,0}
		for i=1, #NameTable do 
			local stock = {0,0,0,0,0,0,0}
			for j=1, numRanks do
				stock[j] = LST:GetStockCount(NameTable[i], j);
				stockSum[j] = stockSum[j] + stock[j];
			end

			local row = {}
			local nameString = LST.LegendaryItemData[NameTable[i]]["name"];
			if(LST:GetUnlockedCraftRank(NameTable[i]) ~= 4 and LST:GetUnlockedCraftRank(NameTable[i]) ~= 0) then 
				nameString = nameString .. " (r" .. LST:GetUnlockedCraftRank(NameTable[i]) .. ")";
			end
			row[1] = LST:CreateTableElement(frame, nameString, 1, 1, 1, 1);
			local rowIndex = 2;
			for r=1, numRanks do
				if(LST.db.profile.settings.IsRankEnabled[r] == true) then
					row[rowIndex] = LST:CreateTableElement(frame, stock[r], LST:GetTableStockFont(r,stock[r], nil, nil, NameTable[i]))
					rowIndex = rowIndex + 1;
				end
			end
			table.insert(sheet, row)
		end
		local totalStock = 0;
		for r=1, numRanks do
			if(LST.db.profile.settings.IsRankEnabled[r] == true) then
				totalStock = totalStock + stockSum[r];
			end
		end
		local row = {};
		table.insert( row, LST:CreateTableElement(frame, L["Total"] .. totalStock, 1, 1, 1, 1));
		for r=1, numRanks do
			if(LST.db.profile.settings.IsRankEnabled[r] == true) then
				table.insert( row, LST:CreateTableElement(frame, stockSum[r], 1, 1, 1, 1)); 
			end
		end
		--row = 
		--{
		--	LST:CreateTableElement(frame, L["Total"] .. (stockSum[1] + stockSum[2] + stockSum[3] + stockSum[4] + stockSum[5] + stockSum[6]), 1, 1, 1, 1),
		--	LST:CreateTableElement(frame, stockSum[1], 1, 1, 1, 1), 
		--	LST:CreateTableElement(frame, stockSum[2], 1, 1, 1, 1), 
		--	LST:CreateTableElement(frame, stockSum[3], 1, 1, 1, 1), 
		--	LST:CreateTableElement(frame, stockSum[4], 1, 1, 1, 1),
		--	LST:CreateTableElement(frame, stockSum[5], 1, 1, 1, 1),
		--	LST:CreateTableElement(frame, stockSum[6], 1, 1, 1, 1)
		--}
		table.insert(sheet, row)
	else
		local titles = {};
		table.insert(titles, LST:CreateTableTitle(frame, L["Item name"]))
		for r=1, numRanks do
			if(LST.db.profile.settings.IsRankEnabled[r] == true) then
				table.insert(titles, LST:CreateTableTitle(frame, L["R" .. r]))
				table.insert(titles, LST:CreateTableTitle(frame, L["Profit R" .. r]))
			end
		end
		table.insert(sheet, titles)
		maxWidth = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		local stockSum = {0,0,0,0,0,0,0}
		local priceSum = {0,0,0,0,0,0,0}
		local costSum = {0,0,0,0,0,0,0}
		for i=1, #NameTable do 
			local stock = {0,0,0,0,0,0,0}
			local cost = {0,0,0,0,0,0,0}
			local profit = {0,0,0,0,0,0,0}
			local profitText = {0,0,0,0,0,0,0}
			for j=1, numRanks do
				if(LST.db.profile.settings.IsRankEnabled[j] == true) then
					stock[j] = LST:GetStockCount(NameTable[i], j);
					profit[j] = LST:GetProfit(NameTable[i], j, false);
					if(profit[j] ~= L["not scanned"]) then
						if(LST.db.profile.settings.UsePercentages == true) then
							profitText[j] = LST:RoundToInt(LST:GetProfitPercentage(NameTable[i], j, fals)) .. "%";
						else
							profitText[j] = LST:AddDecimalSeparator(LST:RoundToInt(profit[j]));
						end
					else
						profitText[j] = L["not scanned"];
					end
					stockSum[j] = stockSum[j] + stock[j];
					local craftCost = LST.PriceDataByRank[NameTable[i]][j]["craftCost"];
					cost[j] = craftCost;
					priceSum[j] = priceSum[j] + (stock[j] * LST:GetMinBuyout(NameTable[i], j));
					if(craftCost ~= L["not scanned"]) then
						costSum[j] = costSum[j] + (stock[j] * craftCost);
					end
				end
			end
			local row = {}
			local nameString = LST.LegendaryItemData[NameTable[i]]["name"];
			if(LST:GetUnlockedCraftRank(NameTable[i]) ~= 4 and LST:GetUnlockedCraftRank(NameTable[i]) ~= 0) then 
				nameString = nameString .. " (r" .. LST:GetUnlockedCraftRank(NameTable[i]) .. ")";
			end
			row[1] = LST:CreateTableElement(frame, nameString, 1, 1, 1, 1);
			local rowIndex = 2;
			for r=1, numRanks do
				if(LST.db.profile.settings.IsRankEnabled[r] == true) then
					row[rowIndex] = LST:CreateTableElement(frame, stock[r], LST:GetTableStockFont(r, stock[r], tostring(profit[r]), cost[r], NameTable[i]));
					row[rowIndex + 1] = LST:CreateTableElement(frame, profitText[r], LST:GetTablePriceFont(profit[r], cost[r], NameTable[i]));
					rowIndex = rowIndex + 2;
				end
			end
			table.insert(sheet, row)		
		end
		local profitSum = {0,0,0,0,0,0,0}
		for r = 1, numRanks do
			profitSum[r] = priceSum[r] - costSum[r];
		end
		
		local totalProfit = {};
		local totalPrice = {};
		totalProfit[1] = LST:CreateTableElement(frame, L["Total per rank (profit): "], 1, 1, 1, 1);
		totalPrice[1] = LST:CreateTableElement(frame, L["Total per rank (min price): "], 1, 1, 1, 1);
		local rowIndex = 2;
		for r=1, numRanks do
			if(LST.db.profile.settings.IsRankEnabled[r] == true) then
				totalProfit[rowIndex] = LST:CreateTableElement(frame, stockSum[r], 1, 1, 1, 1);
				totalProfit[rowIndex + 1] = LST:CreateTableElement(frame, LST:AddDecimalSeparator(LST:RoundToInt(profitSum[r])), 1, 1, 1, 1);
				totalPrice[rowIndex] = LST:CreateTableElement(frame, stockSum[r], 1, 1, 1, 1);
				totalPrice[rowIndex + 1] = LST:CreateTableElement(frame, LST:AddDecimalSeparator(LST:RoundToInt(priceSum[r])), 1, 1, 1, 1);
				rowIndex = rowIndex + 2;
			end
		end
		table.insert(sheet, totalProfit)
		table.insert(sheet, totalPrice)
		local totalStockSum = 0;
		local totalPriceSum = 0;
		local totalProfitSum = 0;
		for r=1, numRanks do
			totalStockSum = totalStockSum + stockSum[r];
			totalPriceSum = totalPriceSum + priceSum[r];
			totalProfitSum = totalProfitSum + profitSum[r];
		end
		table.insert(sheet, LST:CreateTablePriceRowWhite(frame, L["Total (profit): "], totalStockSum, LST:AddDecimalSeparator(LST:RoundToInt(totalProfitSum)), "","","","","","","","","","","",""))
		table.insert(sheet, LST:CreateTablePriceRowWhite(frame, L["Total (min price): "], totalStockSum, LST:AddDecimalSeparator(LST:RoundToInt(totalPriceSum)), "","","","","","","","","","","",""))
	end
	LST:CreateFrameSheet(frame, sheet, #maxWidth)
end

function LST:PrepareTablePools(frame)
	if(fontStringPool == nil) then
		fontStringPool = CreateFontStringPool(frame, "OVERLAY", nil, "GameFontNormal", FontStringPool_Hide)
	else
		fontStringPool:ReleaseAll()
	end
	if(backgroundLinePool == nil) then
		backgroundLinePool = CreateFramePool("Frame", nil, BackdropTemplateMixin and "BackdropTemplate")
	else
		backgroundLinePool:ReleaseAll()
	end
end

function LST:GetColorWhite()
	return 1, 1, 1, 1
end

function LST:CreateTablePriceRowWhite(frame, title, text1, text2, text3, text4, text5, text6, text7, text8, text9, text10, text11, text12, text13,text14)
	row = 
	{
		LST:CreateTableElement(frame, title, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text1, LST:GetColorWhite()), LST:CreateTableElement(frame, text2, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text3, LST:GetColorWhite()), LST:CreateTableElement(frame, text4, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text5, LST:GetColorWhite()), LST:CreateTableElement(frame, text6, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text7, LST:GetColorWhite()), LST:CreateTableElement(frame, text8, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text9, LST:GetColorWhite()), LST:CreateTableElement(frame, text10, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text11, LST:GetColorWhite()), LST:CreateTableElement(frame, text12, LST:GetColorWhite()),
		LST:CreateTableElement(frame, text13, LST:GetColorWhite()), LST:CreateTableElement(frame, text14, LST:GetColorWhite())
	}
	return row;
end

--function LST:CreateTableRowWhite(frame, title, text1, text2, text3, text4, text5, text6)
--	row = 
--	{
--		LST:CreateTableElement(frame, title, LST:GetColorWhite()),
--		LST:CreateTableElement(frame, text1, LST:GetColorWhite()),
--		LST:CreateTableElement(frame, text2, LST:GetColorWhite()),
--		LST:CreateTableElement(frame, text3, LST:GetColorWhite()),
--		LST:CreateTableElement(frame, text4, LST:GetColorWhite()),
--		LST:CreateTableElement(frame, text5, LST:GetColorWhite()),
--		LST:CreateTableElement(frame, text6, LST:GetColorWhite())
--	}
--	return row;
--
--end

function LST:CreateFrameSheet(frame, table, numColumns)
	local sheet  = {}
	local maxWidth = {}
	local xStartValue = 0
	local xPosition = xStartValue
	local yPosition = 0
	local YDIFF = 15
	local XDIFF = 15
	local ScrollChildWidth = frame:GetWidth();
	local Backdrop = {
		bgFile = "Interface\\AddOns\\LegendaryStockTracker\\Assets\\Plain.tga",
		--edgeFile = temp,
		tile = false, tileSize = 0, edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 1},
	}
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
		--local backgroundLine = CreateFrame("Frame", "LSTTableRow" .. i, frame, BackdropTemplateMixin and "BackdropTemplate");
		local backgroundLine = backgroundLinePool:Acquire();
		backgroundLine:SetParent(frame);
		backgroundLine:Show();
		backgroundLine:SetPoint("TOPLEFT", 0, yPosition);
		--backgroundLine:SetPoint("BOTTOMRIGHT");
		backgroundLine:SetHeight(YDIFF);
		--backgroundLine:SetPoint("RIGHT");
		backgroundLine:SetBackdrop(Backdrop);
		backgroundLine:SetBackdropColor(0.2,0.2,0.2,((i+1)%2) * 0.5);

		for j=1, #table[i] do
			table[i][j][1]:SetParent(backgroundLine);
			LST:SetElementPosition(table[i][j][1], xPosition, 0);
			xPosition = xPosition + XDIFF + maxWidth[j];
		end
		backgroundLine:SetWidth(xPosition - XDIFF);
		xPosition = xStartValue;
		yPosition = yPosition - YDIFF;
		--LST:AddTableLine(frame, yPosition);
	end
end

function LST:GetTablePriceFont(profit, price, itemID)
	if(profit == L["not scanned"]) then
		return 1,1,1,1;
	end
	local minProfit = LST:GetMinProfit(price, itemID);
	if(tonumber(profit) >= minProfit) then
		return 0.15, 1, 0.15, 1 --green
	elseif(tonumber(profit) < 0) then
		return 1, 0.15, 0.15, 1 -- red
	else 
		return 1, 1, 1, 1
	end
end

function LST:GetMinProfit(price, itemID)
	local minProfit = 1;
	if(price == L["not scanned"]) then 
		price = 1;
	end
	if(LST.db.profile.settings.UsePercentages == true) then
		if(LST:IsRecipeMaxLevel(itemID) == true) then
			minProfit = (tonumber(LST.db.profile.settings.percentageMinProfit) / 100) * price;
		else
			minProfit = (tonumber(LST.db.profile.settings.percentageMinProfitWhenLeveling) / 100) * price;
		end
	else
		if(LST:IsRecipeMaxLevel(itemID) == true) then
			minProfit = tonumber(LST.db.profile.settings.minProfit);
		else
			minProfit = tonumber(LST.db.profile.settings.minProfitWhenLeveling);
		end
	end
	return minProfit;
end

function LST:GetTableStockFont(rank, value, profit, price, itemID)
	if(profit == L["not scanned"]) then
		return 1,1,1,1;
	end
	if (profit == nil) then
		profit = 0;
	end
	if (price == nil) then
		price = 0;
	end
	if(value < tonumber(LST.db.profile.settings.restockAmountByRank[rank])) then
		if(LST.db.profile.settings.showPricing == true and profit ~= nil) then
			if(tonumber(profit) > LST:GetMinProfit(price, itemID)) then 
				return 0, 0.75, 1, 1
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
	fontString:SetTextColor(LST:GetTextColor("yellow"))
	--fontString:SetFontObject("GameFontNormal")
	fontString:SetJustifyH("CENTER")
	fontString:SetJustifyV("MIDDLE")
	fontString:SetPoint("LEFT", 15, 0)
	fontString:SetPoint("TOP", 0, -15)
	fontString:SetText(text)
	fontString:Show()
	return {fontString, fontString:GetStringWidth(text)}
end

function LST:GetTextColor(color)
	if 		color == "yellow" 	then return 1, 0.9, 0, 1
	elseif  color == "white" 	then return 1, 1, 1, 1
	elseif  color == "legendary" 	then return 1, 0.5, 0, 1
	end
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
	if (LST.PriceDataByRank[itemName] == nil) then
		LST.PriceDataByRank[itemName] = {{dbminbuyout = 0, dbmarket = 0,0,0,0},{dbminbuyout = 0, dbmarket = 0,0,0,0},{dbminbuyout = 0, dbmarket = 0,0,0,0},{dbminbuyout = 0, dbmarket = 0,0,0,0},{dbminbuyout = 0, dbmarket = 0,0,0,0},{dbminbuyout = 0, dbmarket = 0,0,0,0},{dbminbuyout = 0, dbmarket = 0,0,0,0},{dbminbuyout = 0, dbmarket = 0,0,0,0},{dbminbuyout = 0, dbmarket = 0,0,0,0},{dbminbuyout = 0, dbmarket = 0,0,0,0}} --leaving room for up to 10 legendary ranks
	end
end

function LST:GetMinBuyout(name, rank)
	return tonumber(LST.PriceDataByRank[name][rank]["dbminbuyout"]);
end

function LST:UpdateMaterialPrices()
	if(not IsTSMLoaded) then return 0 end;
	--if(isMaterialPriceUpdated == true) then return nil end
	for materialID, name in	pairs(LST.db.factionrealm.recipeData.materialList) do
		local matPrice = tonumber(LST:ConvertTsmPriceToValue(TSM_API.GetCustomPriceValue("matPrice", "i:" .. materialID)));
		if(tonumber(matPrice) == 0 and tonumber(matprice) == nil) then
			LST.materialPrices[materialID] = 0;
		else
			LST.materialPrices[materialID] = matPrice;
		end
	end
	--isMaterialPriceUpdated = true;
end

function LST:UpdateTsmPriceForAllRanks(itemName)
	LST:UpdateTsmPrices(itemName, 1)
	LST:UpdateTsmPrices(itemName, 2)
	LST:UpdateTsmPrices(itemName, 3)
	LST:UpdateTsmPrices(itemName, 4)
	LST:UpdateTsmPrices(itemName, 5)
	LST:UpdateTsmPrices(itemName, 6)
	LST:UpdateTsmPrices(itemName, 7)
end

function LST:UpdateTsmPrices(itemName, rank)
	--if(isTSMPriceUpdated == true) then return nil end
	LST:AddEmptyTsmPriceDataEntryIfNotPresent(itemName)
	local ItemPrices = LST.PriceDataByRank[itemName]
	if(IsTSMLoaded ~= true) then
		ItemPrices[rank]["dbminbuyout"] = 0
		ItemPrices[rank]["craftCost"] = 0
		return nil
	end
	local tsmString = "i:" .. itemName;
	if(rank == 1) then
		tsmString = tsmString .. LST.Rank1BonusIDs
	elseif(rank == 2) then
		tsmString = tsmString .. LST.Rank2BonusIDs
	elseif(rank == 3) then
		tsmString = tsmString .. LST.Rank3BonusIDs
	elseif(rank == 4) then
		tsmString = tsmString .. LST.Rank4BonusIDs
	elseif(rank == 5) then
		tsmString = tsmString .. LST.Rank5BonusIDs
	elseif(rank == 6) then
		tsmString = tsmString .. LST.Rank6BonusIDs
	elseif(rank == 7) then
		tsmString = tsmString .. LST.Rank7BonusIDs
	end
	tsmstring = TSM_API.ToItemString(tsmString)
	ItemPrices[rank]["dbminbuyout"] = LST:ConvertTsmPriceToValue(TSM_API.GetCustomPriceValue("DBMinBuyout", tsmString));
	local craftCost = LST:GetLSTCraftCostForLegendary(itemName, rank);
	if(craftCost ~= L["not scanned"]) then
		craftCost = LST:RoundToInt(craftCost);
	end
	ItemPrices[rank]["craftCost"] = craftCost;
	if(ItemPrices[rank]["dbminbuyout"] == nil or ItemPrices[rank]["dbminbuyout"] == 0 or (rank == 7 and ItemPrices[rank]["dbminbuyout"] < LST:ConvertTsmPriceToValue(TSM_API.GetCustomPriceValue("DBMarket", "i:187707")))) then
		ItemPrices[rank]["dbminbuyout"] = LST:ConvertTsmPriceToValue(TSM_API.GetCustomPriceValue("AuctioningOpNormal", tsmString));
	end
	if(ItemPrices[rank]["dbminbuyout"] == nil or ItemPrices[rank]["craftCost"] == nil) then
		ItemPrices[rank]["dbminbuyout"] = 0
		ItemPrices[rank]["craftCost"] = 0
	else
		ItemPrices[rank]["dbminbuyout"] = ItemPrices[rank]["dbminbuyout"] * 0.95;
	end
	--if(rank == 7) then 
	--	ItemPrices[rank]["dbminbuyout"] = 100000;
	--end
	LST.PriceDataByRank[itemName] = ItemPrices
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
		if(string.len(string) > 4) then
		gold = tonumber(string:sub(1, #string - 4));
		silver = tonumber(string.sub(string, -4)) / 10000;
		else
			gold = 0;
			silver = tonumber(string / 10000);
		end
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
	if (LST.LegendaryItemData[itemID] ~= nil) then 
		if (LST.LegendaryItemData[itemID]["stock"][rank] ~= nil) then 
			count = LST.LegendaryItemData[itemID]["stock"][rank];
		end
	end
	return count;
end

function LST:CheckIfTSMIsRunning()
	IsTSMLoaded = select(1,C_AddOns.IsAddOnLoaded("TradeSkillMaster"))
end

function LST:OnItemAdded(self, event, itemKey)
end

function LST:OnItemLooted(_, lootstring, player, _, _, player2)
	if ((UnitName("player") .. "-" .. GetNormalizedRealmName()) == player) then 
		local itemLink = string.match(lootstring,"|%x+|Hitem:.-|h.-|h|r");
		if(itemLink == nil) then return; end;
		local itemString = string.match(itemLink, "item[%-?%d:]+");
		if(itemString == nil) then return; end;
		local itemID = LST:GetItemIDFromItemLink(itemString);
		if(itemID == nil) then return; end;
		local detailedItemLevel = GetDetailedItemLevelInfo(itemLink);
		LST:IsLootRelevant(itemID, detailedItemLevel);
	end
end

function LST:IsLootRelevant(itemID, itemLevel)
	if not restockFrame then
		return nil
	end
	if(itemID == LST.VestigeOfOriginID) then -- vestige of origins
		local price, professionID = LST:GetCheapestReagentProfession(LST.VestigeOfOriginID);
		if( NumReagentsToCraft[LST.VestigeOfOriginID][professionID] ~= nil and NumReagentsToCraft[LST.VestigeOfOriginID][professionID] > 0) then
			NumReagentsToCraft[LST.VestigeOfOriginID][professionID] = NumReagentsToCraft[LST.VestigeOfOriginID][professionID] - 1;
			LST:AddVestigeToCount(LST.VestigeOfOriginID);
			LST:RemoveReagentFromMaterialList(1, professionID, LST.VestigeOfOriginID);
		end
		if(restockFrame:IsVisible()) then
			LST:CreateRestockSheet(LSTRestockScrollChild);
		end
		if(materialRestockListFrame:IsVisible()) then
			ShouldUpdateMaterialListOnBagUpdate = true;
		end
	elseif(itemID == LST.VestigeOfEternalID) then
		local price, professionID = LST:GetCheapestReagentProfession(LST.VestigeOfEternalID);
		if( NumReagentsToCraft[LST.VestigeOfEternalID][professionID] ~= nil and NumReagentsToCraft[LST.VestigeOfEternalID][professionID] > 0) then
			NumReagentsToCraft[LST.VestigeOfEternalID][professionID] = NumReagentsToCraft[LST.VestigeOfEternalID][professionID] - 1;
			LST:AddVestigeToCount(LST.VestigeOfEternalID);
			LST:RemoveReagentFromMaterialList(1, professionID, LST.VestigeOfEternalID);
		end
		if(restockFrame:IsVisible()) then
			LST:CreateRestockSheet(LSTRestockScrollChild);
		end
		if(materialRestockListFrame:IsVisible()) then
			ShouldUpdateMaterialListOnBagUpdate = true;
		end
	elseif(LST.LegendaryItemData[itemID] ~= nil) then 
		if(itemLevel == nil) then
			print(L["Incorrect itemlevel data received for item "] .. LST.LegendaryItemData[itemID] .. L[", skipping data for this rank."])
		else
			LST:CheckForRestockUpdate(itemID, LST:GetLegendaryRankByItemLevel(itemLevel));
		end
		return true;
	elseif(LST.MaterialRestockList[itemID] ~= nil) then
		if(materialRestockListFrame:IsVisible()) then
			ShouldUpdateMaterialListOnBagUpdate = true;
		end
	end;
	return false;
end

function LST:CheckForRestockUpdate(itemID, rank)
	if(RestockList[itemID..rank] ~= nil) then
		RestockList[itemID..rank].amountToRestock = RestockList[itemID..rank].amountToRestock - 1;
		if(RestockList[itemID..rank].amountToRestock <= 0) then RestockList[itemID..rank] = nil end;
		LST:UpdateSortedRestockList();
		if(LST:DoesThisCharacterHaveProfession(LST.LegendaryItemData[itemID].profession)) then
			local price, vestigeID = LST:GetCheapestCraftCost(itemID, rank, true);
			if(vestigeID == nil) then
				LST:RemoveMaterialsFromRestockList(LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank]);
			elseif(vestigeID == LST.VestigeOfOriginID) then
				LST:RemoveMaterialsFromRestockList(LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank - 2]);
			elseif(vestigeID == LST.VestigeOfEternalID) then
				LST:RemoveMaterialsFromRestockList(LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank - 3]);
			end
		end
		LST:UpdateShownTab()
	end
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
	local schematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, false, 1);
	for reagentslotIndex, reagentSlotInfo in pairs(schematic.reagentSlotSchematics) do
		if(reagentSlotInfo.reagentType == 1) then
			local materialID = reagentSlotInfo.reagents[1].itemID;
			local reagentNumRequired = reagentSlotInfo.quantityRequired;
			local reagentName, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _ = GetItemInfo(materialID);
			materials[materialID] = 
			{
				name = reagentName,
				itemid = tostring(materialID),
				numRequired = reagentNumRequired
			}
			LST:UpdateMaterialInfo(materialID);
		end
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
				LST.LegendaryItemData[itemID]["recipeUnlocked"] = unlockedLevel;
				LST.LegendaryItemData[itemID]["recipeID"][rank] = recipeID;
				LST.db.factionrealm.recipeData.recipes[itemID]["name"] = recipeInfo["name"];
				LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank] = LST:GetMaterialListFromRecipe(recipeID);
			elseif(LST:GetCraftResultItemId(recipeInfo) == LST.VestigeOfOriginID) then
				LST.db.factionrealm.recipeData.OptionalReagents[LST.VestigeOfOriginID][SLID] = LST:GetMaterialListFromRecipe(recipeID);
			elseif(LST:GetCraftResultItemId(recipeInfo) == LST.VestigeOfEternalID) then
				LST.db.factionrealm.recipeData.OptionalReagents[LST.VestigeOfEternalID][SLID] = LST:GetMaterialListFromRecipe(recipeID);
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
	for reagent, data in pairs (NumReagentsToCraft) do
		if(NumReagentsToCraft[reagent][openedProfession] > 0) then
			local recipeID = SLProfessionsIds[openedProfession][reagent];
			local availableCraftCount = C_TradeSkillUI.GetCraftableCount(recipeID);
			local craftCount = 0;
			if(availableCraftCount >= NumReagentsToCraft[reagent][openedProfession]) then
				craftCount = NumReagentsToCraft[reagent][openedProfession];
			elseif(availableCraftCount > 0) then
				craftCount = availableCraftCount;
			end
			if(craftCount > 0) then
				C_TradeSkillUI.CraftRecipe(recipeID, craftCount, nil, 1);
				return nil;
			else
				print(L["LST: Not enough materials to craft "] .. L["Vestige"])
			end
		end
	end
	for index, restockData in ipairs(SortedRestockList) do
		local itemID = restockData["itemID"];
		local rank = restockData["rank"];
		local addVestige = restockData["usesVestige"];
		local optionalReagents = nil;
		if(addVestige == LST.VestigeOfOriginID) then 
			rank = rank - 2;
			optionalReagents = {{itemID = tonumber(LST.VestigeOfOriginID), count = 1, slot = 1}};
		elseif(addVestige == LST.VestigeOfEternalID) then 
			rank = rank - 3;
			optionalReagents = {{itemID = tonumber(LST.VestigeOfEternalID), dataSlotIndex = 1, quantity = 1}};
		end
		if(LST.LegendaryItemData[itemID]["profession"] == openedProfession and restockData["rank"]) then
			local recipeID = LST.LegendaryItemData[tostring(itemID)]["recipeID"][rank];
			if(recipeID ~= 0) then
				local availableCraftCount = C_TradeSkillUI.GetCraftableCount(recipeID, 1);
				local craftCount = 0;
				if(availableCraftCount >= restockData["amountToRestock"] and (addVestige == nil or LST:GetVestigesInBags(addVestige) > restockData["amountToRestock"])) then
					craftCount = restockData["amountToRestock"];
				elseif(availableCraftCount > 0 and (addVestige == nil or LST:GetVestigesInBags(addVestige) > 0)) then
					craftCount = 1;
				end

				if(craftCount > 0) then
					C_TradeSkillUI.CraftRecipe(recipeID, craftCount, optionalReagents, 1);
					return nil;
				else
					print(L["LST: Not enough materials to craft "] .. restockData["name"])
				end
			end
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
	print(L["LST: Received item data from "] .. sender);
	LST.db.factionrealm.syncData[data["accID"]] = {};
	LST.db.factionrealm.syncData[data["accID"]]["legendaries"] = {};
	LST.db.factionrealm.syncData[data["accID"]]["characters"] = {};
	local table = LST.db.factionrealm.syncData[data["accID"]]["legendaries"];
	for id, data in pairs(data["legendaries"]) do
		table[id] = 
		{
			["canCraft"] = data[1],
			["crafter"] = data[9],
			["stock"] = {data[2],  data[3], data[4], data[5], data[6], data[7], data[8]}
		}
	end
	table = LST.db.factionrealm.syncData[data["accID"]]["characters"];
	for char, professions in pairs(data["characters"]) do
		table[char] = professions;
	end
	LST.db.factionrealm.recipeData.materialList = data.recipeData["materialList"];
	--for materialId, materialName in pairs(data.recipeData.materialList) do
	--	LST.db.factionrealm.recipeData.materialList[materialId] = materialName;
	--end
	for recipeID, recipeData in pairs(data.recipeData.recipes) do
		LST.db.factionrealm.recipeData.recipes[recipeID] = recipeData;
	end
	for vestigeID, data in pairs(data.recipeData.OptionalReagents) do
		LST.db.factionrealm.recipeData.OptionalReagents[vestigeID] = data;
	end
end

function LST:SendDataToPlayerCommand(player)
	if(player == nil or player == "") then print("LST: make sure to add a character name, e.g. '/lstsenddata charactername'"); return; end;
	LST:SendDataToPlayer(player);
end

function LST:SendDataToSyncTarget()
	LST:SendDataToPlayer(LST.db.profile.settings.syncTarget)
end

function LST:SendDataToPlayer(player)
	print(L["LST: Sending data to "] .. player)
	LST:UpdateAllAvailableItemSources();
	LST:GetLegendariesFromItems();
	LST:CountLegendariesByRankWithoutSyncdata();
	local syncData = {
		["accID"] = LST.db.factionrealm.accountUUID,
		["legendaries"] = {},
		["recipeData"] = LST.db.factionrealm.recipeData,
		["characters"] = {}
	}

	for char, data in pairs(LST.db.factionrealm.characters) do
		if(data["professions"] ~= nil) then
			local temp = {};
			temp["professions"] = data["professions"]
			syncData["characters"][char] = temp;
		end
	end

	for id, data in pairs (LST.LegendaryItemData) do
		local count = 0;
		for rank, data in pairs(LST.LegendaryItemData[id]["stock"]) do
			count = count + data;
		end
		local unlockedRank, crafter = LST:GetUnlockedCraftRank(id, false);
		if(count > 0 or unlockedRank > 0) then
			syncData["legendaries"][id] = {unlockedRank, LST.LegendaryItemData[id]["stock"][1], LST.LegendaryItemData[id]["stock"][2], LST.LegendaryItemData[id]["stock"][3], LST.LegendaryItemData[id]["stock"][4], LST.LegendaryItemData[id]["stock"][5], LST.LegendaryItemData[id]["stock"][6], LST.LegendaryItemData[id]["stock"][7], crafter}
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

function LST:AddDecimalSeparator(number)
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

function LST:SetExportText(text)
	local f = LST:GetMainFrame(UIParent)
	if(not f:IsShown()) then
		f:Show()
	end
	LST:TabOnClick(exportTab);
	LSTEditBox:SetText(text)
	LSTEditBox:HighlightText()
end