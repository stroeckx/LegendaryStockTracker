--localization file for german/Germany
local L = LibStub("AceLocale-3.0"):NewLocale("LegendaryStockTracker", "deDE")
if not L then return end 

-- Blacksmithing Legendaries
L["Shadowghast Armguards"] =  "Schattenschreckarmschützer"
L["Shadowghast Breastplate"] =  "Schattenschreckbrustplatte"
L["Shadowghast Gauntlets"] =  "Schattenschreckstulpen"
L["Shadowghast Greaves"] =  "Schattenschreckbeinschützer"
L["Shadowghast Helm"] =  "Schattenschreckhelm"
L["Shadowghast Pauldrons"] =  "Schattenschreckschulterstücke"
L["Shadowghast Sabatons"] =  "Schattenschrecksabatons"
L["Shadowghast Waistguard"] =  "Schattenschrecktaillenschutz"

-- Jewelcrafting Legendaries
L["Shadowghast Necklace"] =  "Schattenschreckhalskette"
L["Shadowghast Ring"] =  "Schattenschreckring"

-- Tailoring Legendaries
L["Grim-Veiled Belt"] =  "Gramschleiergürtel"
L["Grim-Veiled Bracers"] =  "Gramschleierarmschienen"
L["Grim-Veiled Cape"] =  "Gramschleiercape"
L["Grim-Veiled Hood"] =  "Gramschleierkapuze"
L["Grim-Veiled Mittens"] =  "Gramschleierfäustlinge"
L["Grim-Veiled Pants"] =  "Gramschleierhose"
L["Grim-Veiled Robe"] =  "Gramschleierrobe"
L["Grim-Veiled Sandals"] =  "Gramschleiersandalen"
L["Grim-Veiled Spaulders"] =  "Gramschleierschiftung"

-- Leatherworking (Leather) Legendaries
L["Umbrahide Armguards"] =  "Umbralederarmschützer"
L["Umbrahide Gauntlets"] =  "Umbralederstulpen"
L["Umbrahide Helm"] =  "Umbralederhelm"
L["Umbrahide Leggings"] =  "Umbraledergamaschen"
L["Umbrahide Pauldrons"] =  "Umbralederschulterstücke"
L["Umbrahide Treads"] =  "Umbraledertreter"
L["Umbrahide Vest"] =  "Umbralederweste"
L["Umbrahide Waistguard"] =  "Umbraledertaillenschutz"

-- Leatherworking (Mail) Legendaries
L["Boneshatter Armguards"] =  "Knochenschmetternde Armschützer"
L["Boneshatter Gauntlets"] =  "Knochenschmetternde Stulpen"
L["Boneshatter Greaves"] =  "Knochenschmetternde Beinschützer"
L["Boneshatter Helm"] =  "Knochenschmetternder Helm"
L["Boneshatter Pauldrons"] =  "Knochenschmetternde Schulterstücke"
L["Boneshatter Treads"] =  "Knochenschmetternde Treter"
L["Boneshatter Vest"] =  "Knochenschmetternde Weste"
L["Boneshatter Waistguard"] =  "Knochenschmetternder Taillenschutz"

-- UI-Elements
L["Export"] =  "Exportieren"
L["Settings"] =  "Einstellungen"
L["Table"] =  "Übersicht"
L["Restock"] =  "Auffüllen"
L["Rank"] =  "Rang"
L["Profit"] =  "Gewinn"
L["Total"] =  "Gesamt"
L["Total (profit): "] =  "Gesamt (Gewinn): "
L["Total (min price): "] =  "Gesamt (Mindestpreis): "
L["Total per rank (profit): "] =  "Gesamt pro Rang (Gewinn): "
L["Total per rank (min price): "] =  "Gesamt pro Rang (Mindestpreis): "
L["LST: Clearing item cache"] = "LST: Clearing item cache"

-- Export Frame
L["Paste this data into your copy of the spreadsheet"] = "Füge diese Daten in deine Kopie des Tabellenblatts ein"

--Settings Frame
L["Show all legendaries"] = "Zeige alle Legendaries"
L["Show profit (requires TSM operations)"] = "Gewinn anzeigen (erfordert TSM-Operationen)"
L["Include Cached items"] = "Zwischengespeicherte Elemente einbeziehen"
L["Min profit before restocking"] = "Minimaler Gewinn zum Auffüllen"
L["Restock amount"] = "Maximale Auffüllmenge"
L["Min restock amount"] = "Mindest Auffüllmenge"
L["Only restock items I can craft"] = "Nur Artikel aufstocken, die ich herstellen kann"
L["Sources to include:"] = "Einzuschließende Quellen: (Gegenstandsreihenfolge anders)"
L["Include Bags"] = "Taschen berücksichtigen"
L["Include Bank"] = "Bank berücksichtigen"
L["Include AH"] = "Auktionshaus berücksichtigen"
L["Include Mail"] = "Briefkasten berücksichtigen"
L["Include Guild Bank"] = "Gildenbank berücksichtigen"
L["Include Synced Data"] = "Synchrone Daten berücksichtigen"
L["Send data to this alt"] = "Daten an diesen Twink senden"
L["clear cache"] = "Cache löschen"
L["LST: Cleared item cache"] = "LST: Artikel-Cache geleert"
L["Restock domination slots"] = "Dominanz-Slots wieder auffüllen"

-- Minimap Icon
L["Click or type /lst to show the main panel"] =  "Klicken Sie oder geben Sie /lst ein, um das Hauptfenster anzuzeigen"
L["Items Scanned:"] = "Gegenstände gescannt:"
L["Bags: "] = "Taschen: "
L["Bank: "] = "Bank: "
L["AH: "] = "AH: "
L["Mail: "] = "Post: "
L["Guild: "] = "Gilde: "

--Data Export
L["Item name, Rank 1, Rank 2, Rank 3, Rank 4, Rank 5, Rank 6\n"] = "Gegenstandsname, Rang 1, Rang 2, Rang 3, Rang 4, Rang 5, Rang 6\n"
L["Item name, Rank 1, Profit Rank 1, Rank 2, Profit Rank 2, Rank 3, Profit Rank 3, Rank 4, Profit Rank 4, Rank 5, Profit Rank 5, Rank 6, Profit Rank 6\n"] = "Gegenstandsname, Rang 1, Gewinn Rang 1, Rang 2, Gewinn Rang 2, Rang 3, Gewinn Rang 3, Rang 4, Gewinn Rang 4, Rang 5, Gewinn Rang 5, Rang 6, Gewinn Rang 6\n"

-- Table view
L["Item name"] = "Gegenstandsname"
L["Rank 1"] = "Rang 1"
L["Rank 2"] = "Rang 2"
L["Rank 3"] = "Rang 3"
L["Rank 4"] = "Rang 4"
L["Rank 5"] = "Rang 5"
L["Rank 6"] = "Rang 6"
L["R1"] = "R1"
L["R2"] = "R2"
L["R3"] = "R3"
L["R4"] = "R4"
L["R5"] = "R5"
L["R6"] = "R6"
L["Profit R1"] = "Gewinn R1"
L["Profit R2"] = "Gewinn R2"
L["Profit R3"] = "Gewinn R3"
L["Profit R4"] = "Gewinn R4"
L["Profit R5"] = "Gewinn R5"
L["Profit R6"] = "Gewinn R6"

-- Restock
L["Item"] = "Gegenstand"
L["Amount"] = "Menge"

-- Data Sync
L["LST: Sending data to "] = "LST: Sende Daten an "
L["LST: Received item data from "] = "LST: Gegenstandsdaten empfangen von "

-- Crafting
L["LST: You need to open your profession first"] = "LST: Sie müssen Ihren Beruf erst öffnen"
L["LST: Not enough materials to craft "] = "LST: Nicht genügend Materialien zum Basteln "
L["not scanned"] = "nicht gescannt"
L["LST Crafting"] = "LST Crafting"
L["TSM operations"] = "TSM operations"
L["LST: no material price found in TSM for "] = "LST: kein Materialpreis im TSM gefunden für "
L[", defaulting material cost to 0"] = ", Vorgabe der Materialkosten auf 0"
L["LST: Invalid price source"] = "LST: Ungültige Preisquelle"

-- FAQ
L["FAQ"] = "FAQ"
L["FAQ_Intro"] = "Legendary Stock Tracker is an addon that helps you restock or keep track of all your shadowlands base legendary items \nFor any feedback, questions or support, please join the discord https://discord.gg/nYexBdaBuP (go to curseforge if you don't want to copy the url)"
L["FAQ_Stock_Title"] = "Tracking your stock"
L["FAQ_Stock_Description"] = "When opening or closing your bags, bank, mailbox, or auction house, LST will scan for all the items you have and keep track of them.\nIf you then open the LST window via the minimap icon or by typing /lst, you will get a table that shows you how many you have of each legendary.\nPlease note that you need to either reopen the LST window or click on a tab before the values displayed are updated."
L["FAQ_Profit_Title"] = "Calculating profit margins"
L["FAQ_Profit_Description"] = "If you have TSM installed, LST can also show you a profit margin on each item, depending on which price source you use:\n\n1. LST crafting cost\nWhen opening your professions, LST will scan all recipes you have unlocked, and remember which items you can make, and which materials are required for each item at each rank.\nLST will then calculate an accurate crafting cost using your TSM material price for each of the materials.\nAuction house cut is then taken into account from the dbmarket price to show you how much profit you would make on each item. If there is no dbmarket price available, LST will fall back on your tsm auctioning operation's normal price.\nLST won't be able to read the data of ranks you haven't unlocked yet if you have never crafted any rank 1's of the item. You will need to craft at least one rank 1 of each item before LST can scan all other rank's recipes.\n\n2. TSM operation prices:\nWhen using tsm operations as crafting source, your auctioning operation's minimum price is seen as the crafting cost of each item, so it is important to have an accurate minimum price set up in your operations for each item at each rank. \nSince the auction house cut should already be included in your min price, it is not taken into account anymore afterwards, which means the raw profit will actually be 5% less as shown by LST, this 5% is only on the profit part of a sale though, since the fee is already included in the minimum price. If there is no dbmarket price available, LST will fall back on your tsm auctioning operation's normal price."
L["FAQ_Restock_Title"] = "Restocking what's profitable"
L["FAQ_Restock_Description"] = "In the settings tab, you can find settings to choose your minimum profit you want to make before crafting an item.\nYou will also find settings to choose how many items you want to keep in stock, and how many of an item you should be short before you start crafting. \nIf you enable the \"only restock items I can craft\" option, LST remember which items you can make when opening a profession, and only show items you can make in the restock tab.\nItems you are short on, and should restock are highlighted in blue in the table overview, or you can go to the restock tab.\nThe restock tab will show you all items you have to restock in a list, with the amount of them you should craft and the expected profit.\nIf you have you profession window open, you can click the \"Craft next\" button to automatically craft the next item in your restock list that you have the materials for.\nYou can also macro this button by making a \"/click LSTCraftNextButton\" so you can drag it onto your hotbar."
L["FAQ_Export_Title"] = "What if I want to do more with this stock data?"
L["FAQ_Export_Description"] = "You can export it as csv so you can paste it into a spreadsheet, in fact that's all the original version of the addon was intended to do!\nJust go to the export tab, copy the text, paste it in the correct cell of the spreadsheet, and then make sure to click on the icon on the bottom of the pasted data, and click \"split text into columns\"\nIt is important to click that button before clicking anywhere else in the document or you won't have this option anymore untill you paste the data again.\n\nYou can find both the official spreadsheet and some community-made versions linked on the curseforge page of LST!"
L["FAQ_Syncing_Title"] = "I post my auctions on another account, how do I get my data?"
L["FAQ_Syncing_Description"] = "Don't worry, so do I. I've got you covered!\nIn the settings tab, there is a button to sync your data. Enter the name of the character that is online on your other account, and \"click send data to this alt\".\nThis will do a one time transfer of the following data:\n- Which legendaries you are able to craft, and at which rank (to filter the restock list)\n- Which legendaries you have in stock (LST will count all items on both the account of the receiving alt, and all items on the account of the sending alt)\n- Which materials are needed at each rank of each craft (to calculate an accurate LST crafting cost on each item)"
L["FAQ_IncorrectData_Title"] = "The numbers are wrong!"
L["FAQ_IncorrectData_Description"] = "It happens, sometimes LST can't know when items have moved. For example if an auction expires LST can only know this once you opened your auction house again.\nLST updates most data when opening or closing a window, if you think something isn't right, just open your bank, guild bank, mailbox and auction house again so everything can update.\nYou can also try to troubleshoot where this data is coming from by disabling caching, that way it will ignore all items from other alts and even everything you didn't open this session.\nHovering over the minimap icon will also show you how many items LST found in every source, color coded based on the class of the alt the items are on."
L["FAQ_KnowIssues_Title"] = "Known issues"
L["FAQ_KnowIssues_Description"] = "Items on the AH can't be updated if you don't have a single auction posted."
L["FAQ_Outro"] = "If you still have any questions, feedback or need support, please go to https://discord.gg/nYexBdaBuP (go to curseforge if you don't want to copy the url)"

-- Errors
L["Incorrect itemlevel data received for item "] = "LST: Falsche Daten auf Elementebene für Element "
L[", skipping data for this rank."] = ", Daten für diesen Rang werden übersprungen."
L["LST: Error, incorrect input"] = "LST: Fehler, falsche Eingabe"
L["LST: Crafting is not yet supported for rank 5 and 6, please craft these manually for now"] = "LST: Crafting wird für Rang 5 und 6 noch nicht unterstützt, bitte craftet diese vorerst manuell"