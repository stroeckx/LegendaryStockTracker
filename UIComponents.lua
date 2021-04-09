local addonName, globalTable = ...

function LST:CreateSettingsButton(name, parent, sizeX, sizeY)
	local button = CreateFrame("Button", name, parent, BackdropTemplateMixin and "BackdropTemplate");
    local Backdrop = {
		bgFile = "Interface\\AddOns\\LegendaryStockTracker\\Assets\\Plain.tga",
		edgeFile = "Interface/Buttons/WHITE8X8",
		tile = true, tileSize = 0, edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 0},
	}
	button:SetBackdrop(Backdrop)
	button:SetBackdropColor(0.25,0.25,0.25,0.9)
	button:SetBackdropBorderColor(0,0,0,1)
	button:SetSize(sizeX,sizeY)
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
    return button;
end