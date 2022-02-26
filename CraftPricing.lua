local addonName, globalTable = ...
local L = LibStub("AceLocale-3.0"):GetLocale("LegendaryStockTracker")

function LST:GetCheapestCraftCost(itemID, rank, onlyCraftable)
	if(LST.PriceDataByRank[itemID][rank]["craftCost"] == L["not scanned"]) then
		return L["not scanned"];
	end
	local unlockedRank, crafter = LST:GetUnlockedCraftRank(itemID, true);
	if(onlyCraftable == false) then unlockedRank = 4; end
	if(crafter == nil) then
		print(L["error_unknown_crafter"] .. itemID);
		return L["not scanned"];
	end;
	local defaultCraftCost = LST:GetDefaultCraftCost(itemID, rank, crafter, unlockedRank);
	local vestigeOfOriginCraftCost = LST:GetCraftCostWithVestigeOfOrigins(itemID, rank, crafter, unlockedRank);
	local vestigeOfEternalCraftCost = LST:GetCraftCostWithVestigeOfEternal(itemID, rank, crafter, unlockedRank);
	if(defaultCraftCost == vestigeOfOriginCraftCost == vestigeOfEternalCraftCost == L["not scanned"]) then return L["not scanned"] end;
	if(defaultCraftCost == L["not scanned"] or defaultCraftCost == nil) then defaultCraftCost = 9999998 end;
	if(vestigeOfOriginCraftCost == L["not scanned"] or vestigeOfOriginCraftCost == nil) then vestigeOfOriginCraftCost = 9999999 end;
	if(vestigeOfEternalCraftCost == L["not scanned"] or vestigeOfEternalCraftCost == nil) then vestigeOfEternalCraftCost = 9999999 end;
	if(defaultCraftCost < vestigeOfEternalCraftCost and defaultCraftCost < vestigeOfOriginCraftCost) then
		return defaultCraftCost, nil;
	end
	if(vestigeOfOriginCraftCost < defaultCraftCost and vestigeOfOriginCraftCost < vestigeOfEternalCraftCost) then
		return vestigeOfOriginCraftCost, LST.VestigeOfOriginID;
	end
	if(vestigeOfEternalCraftCost < defaultCraftCost and vestigeOfEternalCraftCost < vestigeOfOriginCraftCost) then
		return vestigeOfEternalCraftCost, LST.VestigeOfEternalID;
	end
	return math.min(defaultCraftCost, vestigeOfOriginCraftCost, vestigeOfEternalCraftCost);
end

function LST:GetDefaultCraftCost(itemID, rank, crafter, unlockedRank)
	if(rank > 4 or unlockedRank < rank) then return 9999998 end;
	return tonumber(LST.PriceDataByRank[itemID][rank]["craftCost"]);
end

function LST:GetCraftCostWithVestigeOfOrigins(itemID, rank, crafter, unlockedRank)
	if(rank < 3 or rank > 6 or unlockedRank + 2 < rank) then return 9999999 end;
	local vestigePrice, VestigeProfession = LST:GetCheapestReagentProfessionForCrafter(crafter, LST.VestigeOfOriginID);
	if(VestigeProfession == 0) then return L["not scanned"] end;
	return LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank - 2]) + vestigePrice;
end

function LST:GetCraftCostWithVestigeOfEternal(itemID, rank, crafter, unlockedRank)
	if(rank < 4 or rank > 7 or unlockedRank + 3 < rank) then return 9999999 end;
	local vestigePrice, VestigeProfession = LST:GetCheapestReagentProfessionForCrafter(crafter, LST.VestigeOfEternalID);
	if(VestigeProfession == 0) then return L["not scanned"] end;
	return LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank - 3]) + vestigePrice;
end

function LST:GetLSTCraftCostForLegendary(itemID, rank)
	if(rank <= 4) then
		if(LST.db.factionrealm.recipeData.recipes[itemID] == nil or LST.db.factionrealm.recipeData.recipes[itemID]["ranks"] == nil or LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank] == nil) then
			return L["not scanned"];
		else
			return LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank])
		end
	elseif(rank == 5 or rank == 6) then
		if(LST.db.factionrealm.recipeData.recipes[itemID] == nil or LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank - 2] == nil or LST.db.factionrealm.recipeData.OptionalReagents[LST.VestigeOfOriginID][LST.LegendaryItemData[itemID]["profession"]] == nil) then
			return L["not scanned"];
		else
			return LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank - 2]) + LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.OptionalReagents[LST.VestigeOfOriginID][LST.LegendaryItemData[itemID]["profession"]])
		end
	elseif(rank == 7) then
		if(LST.db.factionrealm.recipeData.recipes[itemID] == nil or LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank - 3] == nil or LST.db.factionrealm.recipeData.OptionalReagents[LST.VestigeOfEternalID][LST.LegendaryItemData[itemID]["profession"]] == nil) then
			return L["not scanned"];
		else
			return LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.recipes[itemID]["ranks"][rank - 3]) + LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.OptionalReagents[LST.VestigeOfEternalID][LST.LegendaryItemData[itemID]["profession"]])
		end
	end
end

function LST:GetMaterialPriceSum(table)
	if(table == nil) then return 0 end;
	local price = 0;
	for materialID, data in pairs(table) do
		if(LST.materialPrices[materialID] == nil) then
			price = price + 0;
		else
			price = price + (LST.materialPrices[materialID] * data["numRequired"]);
		end
	end
	return price;
end

function LST:GetCheapestReagentProfession(reagentID)
	local price = 9999999;
	local professionID = 0;
	if(IsTSMLoaded == false or LST.db.profile.settings.showPricing == false) then
		if(LST.leggoProf1 ~= nil) then return 0,LST.leggoProf1;
		else return 0,LST.leggoProf2;
		end
	end
	if (LST.leggoProf1 ~= nil and LST.db.factionrealm.recipeData.OptionalReagents[reagentID][LST.leggoProf1] ~= nil) then
		price = LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.OptionalReagents[reagentID][LST.leggoProf1]);
		professionID = LST.leggoProf1;
	end
	if(LST.leggoProf2 ~= nil and LST.db.factionrealm.recipeData.OptionalReagents[reagentID][LST.leggoProf2] ~= nil) then
		local tempPrice = LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.OptionalReagents[reagentID][LST.leggoProf2]);
		if(tempPrice < price) then
			price = LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.OptionalReagents[reagentID][LST.leggoProf2]);
			professionID = LST.leggoProf2;
		end
	end
	return price, professionID;
end

function LST:GetCheapestReagentProfessionForCrafter(crafter, reagentID)
	local price = 9999999;
	local professionID = 0;
	local prof1, prof2 = nil,nil;
	if(LST.db.factionrealm.characters[crafter].professions[1] ~= nil or LST.db.factionrealm.characters[crafter].professions[2] ~= nil) then
		prof1 = LST.db.factionrealm.characters[crafter].professions[1];
		prof2 = LST.db.factionrealm.characters[crafter].professions[2];
	else
		for acc, data in pairs(LST.db.factionrealm.syncData) do
			if(LST.db.factionrealm.syncData[acc].characters == nil) then
				print(L["error_please_resync"] .. crafter);
				return 0, 0;
			end
			if(LST.db.factionrealm.syncData[acc].characters[crafter] == nil) then
				print(L["error_character_missing_data"] .. crafter);
				return 0, 0;
			end
			if(LST.db.factionrealm.syncData[acc].characters[crafter]["professions"][1] ~= nil or LST.db.factionrealm.syncData[acc].characters[crafter]["professions"][2] ~= nil) then
				prof1 = LST.db.factionrealm.syncData[acc].characters[crafter]["professions"][1];
				prof2 = LST.db.factionrealm.syncData[acc].characters[crafter]["professions"][2];
			end
		end
	end;
	if(IsTSMLoaded == false or LST.db.profile.settings.showPricing == false) then
		if(prof1 ~= nil) then return 0, prof1;
		else return 0, prof2;
		end
	end
	if (prof1 ~= nil) then
		price = LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.OptionalReagents[reagentID][prof1]);
		professionID = prof1;
		if(price == 0 or price == L["not scanned"]) then
			price = 9999999;
			professionID = 0;
		end;
	end
	if(prof2 ~= nil) then
		local tempPrice = LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.OptionalReagents[reagentID][prof2]);
		if(tempPrice < price) then
			price = LST:GetMaterialPriceSum(LST.db.factionrealm.recipeData.OptionalReagents[reagentID][prof2]);
			professionID = prof2;
		end
		if(price == 0 or price == L["not scanned"]) then
			price = 9999999;
			professionID = 0;
		end;
	end
	return price, professionID;
end

function LST:GetProfit(name, rank, useSubTsmCraftCost)
	if(LST.PriceDataByRank[name][rank]["craftCost"] == L["not scanned"]) then
		return L["not scanned"];
	end
	if(useSubTsmCraftCost == true) then
		local craftCost, reagentID = LST:GetCheapestCraftCost(name, rank, true);
		if(craftCost == L["not scanned"]) then
			return L["not scanned"];
		else
			return tonumber(LST.PriceDataByRank[name][rank]["dbminbuyout"] - craftCost);
		end
	else
		return tonumber(LST.PriceDataByRank[name][rank]["dbminbuyout"] - LST.PriceDataByRank[name][rank]["craftCost"]);
	end
end

function LST:GetProfitPercentage(name, rank, useSubTsmCraftCost)
	if(LST.PriceDataByRank[name][rank]["craftCost"] == L["not scanned"]) then
		return L["not scanned"];
	end
	local fraction = -999;
	if(useSubTsmCraftCost == true) then
		local craftCost = LST:GetCheapestCraftCost(name, rank, true);
		if(craftCost == L["not scanned"]) then
			return L["not scanned"];
		else
			fraction = tonumber(LST.PriceDataByRank[name][rank]["dbminbuyout"] / craftCost);
		end
	else
		fraction = LST.PriceDataByRank[name][rank]["dbminbuyout"] / LST.PriceDataByRank[name][rank]["craftCost"]
	end
	return LST:FractionToPercentage(fraction);
end

function LST:FractionToPercentage(fraction)
	return (fraction - 1) * 100;
end