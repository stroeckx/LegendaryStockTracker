--localization file for French/France
local L = LibStub("AceLocale-3.0"):NewLocale("LegendaryStockTracker", "frFR")
if not L then return end 

-- Blacksmithing Legendaries
L["Shadowghast Armguards"] =  "Garde-bras ombrepeur"
L["Shadowghast Breastplate"] =  "Cuirasse ombrepeur"
L["Shadowghast Gauntlets"] =  "Gantelets ombrepeur"
L["Shadowghast Greaves"] =  "Grèves ombrepeur"
L["Shadowghast Helm"] =  "Heaume ombrepeur"
L["Shadowghast Pauldrons"] =  "Espauliers ombrepeur"
L["Shadowghast Sabatons"] =  "Solerets ombrepeur"
L["Shadowghast Waistguard"] =  "Sangle ombrepeur"

-- Jewelcrafting Legendaries
L["Shadowghast Necklace"] =  "Collier ombrepeur"
L["Shadowghast Ring"] =  "Anneau ombrepeur"

-- Tailoring Legendaries
L["Grim-Veiled Belt"] =  "Ceinture voilée-de-deuil"
L["Grim-Veiled Bracers"] =  "Brassards voilés-de-deuil"
L["Grim-Veiled Cape"] =  "Cape voilée-de-deuil"
L["Grim-Veiled Hood"] =  "Chaperon voilé-de-deuil"
L["Grim-Veiled Mittens"] =  "Mitaines voilées-de-deuil"
L["Grim-Veiled Pants"] =  "Pantalon voilé-de-deuil"
L["Grim-Veiled Robe"] =  "Robe voilée-de-deuil"
L["Grim-Veiled Sandals"] =  "Sandales voilées-de-deuil"
L["Grim-Veiled Spaulders"] =  "Spallières voilées-de-deuil"

-- Leatherworking (Leather) Legendaries
L["Umbrahide Armguards"] =  "Garde-bras en peau ombreuse"
L["Umbrahide Gauntlets"] =  "Gantelets en peau ombreuse"
L["Umbrahide Helm"] =  "Heaume en peau ombreuse"
L["Umbrahide Leggings"] =  "Jambières en peau ombreuse"
L["Umbrahide Pauldrons"] =  "Espauliers en peau ombreuse"
L["Umbrahide Treads"] =  "Bottines en peau ombreuse"
L["Umbrahide Vest"] =  "Gilet en peau ombreuse"
L["Umbrahide Waistguard"] =  "Sangle en peau ombreuse"

-- Leatherworking (Mail) Legendaries
L["Boneshatter Armguards"] =  "Garde-bras fracasse-os"
L["Boneshatter Gauntlets"] =  "Gantelets fracasse-os"
L["Boneshatter Greaves"] =  "Grèves fracasse-os"
L["Boneshatter Helm"] =  "Heaume fracasse-os"
L["Boneshatter Pauldrons"] =  "Espauliers fracasse-os"
L["Boneshatter Treads"] =  "Bottines fracasse-os"
L["Boneshatter Vest"] =  "Gilet fracasse-os"
L["Boneshatter Waistguard"] =  "Sangle fracasse-os"

-- UI-Elements
L["Export"] =  "Exporter"
L["Settings"] =  "Paramètres"
L["Table"] =  "Table"
L["Restock"] =  "Restock"
L["Material list"] = "Liste des matériaux"
L["Rank"] =  "Rank"
L["Profit"] =  "Profit"
L["Total"] =  "Total: "
L["Total (profit): "] =  "Total (bénéfice): "
L["Total (min price): "] =  "Total (prix min.): "
L["Total per rank (profit): "] =  "Total par rang (profit): "
L["Total per rank (min price): "] =  "Total par rang (prix min): "
L["Vestige"] = "Vestige"

-- Export Frame
L["Paste this data into your copy of the spreadsheet"] = "Coller les données dans votre copie du tableur"

-- Settings Frame
L["Show all legendaries"] = "Montrer tous les légendaires"
L["Show values as percentages"] = "Afficher les valeurs sous forme de pourcentages"
L["Show profit"] = "Montrer les profits"
L["Include Cached items"] = "Inclure les objets mis en cache"
L["Min profit before restocking"] = "Bénéfice minimum avant le réapprovisionnement"
L["Min profit when not max exp"] = "Bénéfice minimum quand pas max exp"
L["Restock amount"] = "Montant de réapprovisionnement"
L["Min restock amount"] = "Min montant de réapprovisionnement"
L["Only restock items I can craft"] = "Ne réapprovisionner que les objets que je peux fabriquer"
L["Sources to include:"] = "Sources à inclure:"
L["Include Bags"] = "Inclure Sacs"
L["Include Bank"] = "Inclure Banque"
L["Include AH"] = "Inclure AH"
L["Include Mail"] = "Inclure Mail"
L["Include Guild Bank"] = "Inclure Banque de Guilde"
L["Include Synced Data"] = "Inclure les données synchronisées"
L["Send data to this alt"] = "Send data to this alt"
L["clear cache"] = "effacer le cache"
L["LST: Cleared item cache"] = "LST: Effacement du cache des éléments"
L["Restock domination slots"] = "Réapprovisionnement des créneaux de domination"
L["Show ranks"] = "Afficher les rangs: "
L["Show other crafters items in material list"] = "Afficher les articles d'autres artisans dans la liste des matériaux"
L["Use TSM Material Counts"] = "Utiliser les comptages de matériaux TSM"

-- Minimap Icon
L["Click or type /lst to show the main panel"] =  "Cliquer ou saisir /lst pour montrer le panneau principal"
L["Items Scanned:"] = "Objets scannés:"
L["Bags: "] = "Sacs: "
L["Bank: "] = "Banque: "
L["AH: "] = "AH: "
L["Mail: "] = "Mail: "
L["Guild: "] = "Guilde: "

-- Data Export
L["Item name, Rank 1, Rank 2, Rank 3, Rank 4, Rank 5, Rank 6\n"] = "Nom de l'objet, Rank 1, Rank 2, Rank 3, Rank 4, Rank 5, Rank 6\n"
L["Item name, Rank 1, Profit Rank 1, Rank 2, Profit Rank 2, Rank 3, Profit Rank 3, Rank 4, Profit Rank 4, Rank 5, Profit Rank 5, Rank 6, Profit Rank 6\n"] = "Nom de l'objet, Rank 1, Profit Rank 1, Rank 2, Profit Rank 2, Rank 3, Profit Rank 3, Rank 4, Profit Rank 4, Rank 5, Profit Rank 5, Rank 6, Profit Rank 6\n"

-- Table view
L["Item name"] = "Nom de l'objet"
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
L["Profit R1"] = "Profit R1"
L["Profit R2"] = "Profit R2"
L["Profit R3"] = "Profit R3"
L["Profit R4"] = "Profit R4"
L["Profit R5"] = "Profit R5"
L["Profit R6"] = "Profit R6"

-- Restock
L["Item"] = "Objet"
L["Amount"] = "Montant"
L["craft next"] = "créer le prochain"
L["Update list"] = "rafraîchir la liste"

-- Material list
L["needed"] = "nécessaire"
L["available"] = "disponible"
L["missing"] = "pénurie"

-- Data Sync
L["LST: Sending data to "] = "LST : Envoi de données vers "
L["LST: Received item data from "] = "LST : Received item data from "

-- Crafting
L["LST: You need to open your profession first"] = "LST: Vous devez d'abord ouvrir votre profession"
L["LST: Not enough materials to craft "] = "LST: Pas assez de matériaux pour l'artisanat "
L["not scanned"] = "non scanné"
L["LST Crafting"] = "LST Crafting"
L["TSM operations"] = "TSM operations"
L["LST: no material price found in TSM for "] = "LST: no material price found in TSM for "
L[", defaulting material cost to 0"] = ", le coût du matériau est fixé par défaut à 0"
L["LST: Invalid price source"] = "LST: source de prix non valide"

-- FAQ
L["FAQ"] = "FAQ"
L["FAQ_Intro"] = "Legendary Stock Tracker is an addon that helps you restock or keep track of all your shadowlands base legendary items \nFor any feedback, questions or support, please join the discord https://discord.gg/nYexBdaBuP (go to curseforge if you don't want to copy the url)"
L["FAQ_Stock_Title"] = "Tracking your stock"
L["FAQ_Stock_Description"] = "When opening or closing your bags, bank, mailbox, or auction house, LST will scan for all the items you have and keep track of them.\nIf you then open the LST window via the minimap icon or by typing /lst, you will get a table that shows you how many you have of each legendary.\nPlease note that you need to either reopen the LST window or click on a tab before the values displayed are updated."
L["FAQ_Profit_Title"] = "Calculating profit margins"
L["FAQ_Profit_Description"] = "If you have TSM installed, LST can also show you a profit margin on each item.\n\n1. LST crafting cost\nWhen opening your professions, LST will scan all recipes you have unlocked, and remember which items you can make, and which materials are required for each item at each rank.\nLST will then calculate an accurate crafting cost using your TSM material price for each of the materials.\nAuction house cut is then taken into account from the dbmarket price to show you how much profit you would make on each item. If there is no dbmarket price available, LST will fall back on your tsm auctioning operation's normal price.\nLST won't be able to read the data of ranks you haven't unlocked yet if you have never crafted any rank 1's of the item. You will need to craft at least one rank 1 of each item before LST can scan all other rank's recipes.\n\n"
L["FAQ_Restock_Title"] = "Restocking what's profitable"
L["FAQ_Restock_Description"] = "In the settings tab, you can find settings to choose your minimum profit you want to make before crafting an item.\nYou will also find settings to choose how many items you want to keep in stock, and how many of an item you should be short before you start crafting.\nThe min profit when not max exp setting allows you to set a lower (or even negative!) min profit for items you still need exp in.\n\nThe settings menu always sets the same restock value for each rank, if you want to configure separate restock amounts per rank, you can use this command:\n/lstsetrestock 1 2 3 4 5 6\nyou can always check what the current settings are by doing\n/lstprintrestock\n\nIf you enable the \"only restock items I can craft\" option, LST remember which items you can make when opening a profession, and only show items you can make in the restock tab.\nItems you are short on, and should restock are highlighted in blue in the table overview, or you can go to the restock tab.\n\nAfter pressing the update list button, the restock tab will show you all items you have to restock in a list, with the amount of them you should craft and the expected profit.\nIf you have you profession window open, you can click the \"Craft next\" button to automatically craft the next item in your restock list that you have the materials for.\nThe restock list updates when you loot a legendary base item, so if the list isn't updating, make sure your item loot isn't filtered out of your chat window.\n\nIf you prefer to press a keybind to craft, you can drag a macro onto your hotbar with the following command:\n/click LSTCraftNextButton\n\nThere is also a material list, which lists all the materials needed to craft the items that are in your restock list right now.\nThe material list currently includes all materials in your bags, bank, and reagent bank, and updates when you loot materials or a legendary base item."
L["FAQ_Vestiges_Title"] = "Vestiges are crazy, what is LST doing with them?"
L["FAQ_Vestiges_Description"] = "LST calculates the price of a rank 5 and rank 6 as if it is made with a vestige of the same profession.\nIf your crafter can make a cheaper vestige with another profession, LST will make you craft the cheaper vestige in order to increase your profit even more.\nHowever, LST won't make an item that is profitable with a cheaper vestige, if it is not profitable with the regular vestige, this is done on purpose, because most people's TSM isn't set up to handle this, meaning LST would craft items which your TSM will never post.\n\nIf vestiges are cheap enough that it is worth making ranks 3/4 with vestiges as well, LST will do so, even if you have not unlocked the recipe to make rank 3 / 4 regularly!"
L["FAQ_Export_Title"] = "What if I want to do more with this stock data?"
L["FAQ_Export_Description"] = "You can export it as csv so you can paste it into a spreadsheet, in fact that's all the original version of the addon was intended to do!\nJust go to the export tab, copy the text, paste it in the correct cell of the spreadsheet, and then make sure to click on the icon on the bottom of the pasted data, and click \"split text into columns\"\nIt is important to click that button before clicking anywhere else in the document or you won't have this option anymore untill you paste the data again.\n\nSince all the original functionality is built into the addon now, the official spreadsheet is no longer maintained, but if you want a base to start from you can find it linked on the curseforge page of LST!"
L["FAQ_Syncing_Title"] = "I post my auctions on another account, how do I get my data?"
L["FAQ_Syncing_Description"] = "Don't worry, so do I. I've got you covered!\nIn the settings tab, there is a button to sync your data. Enter the name of the character that is online on your other account, and \"click send data to this alt\".\nThis will do a one time transfer of the following data:\n- Which legendaries you are able to craft, and at which rank (to filter the restock list)\n- Which legendaries you have in stock (LST will count all items on both the account of the receiving alt, and all items on the account of the sending alt)\n- Which materials are needed at each rank of each craft (to calculate an accurate LST crafting cost on each item)\n\nthis means you can send your data from your account with your crafters, to you banker account so your banker will know which items you can craft, and what the recipes are, and you can send your data from your banker to your crafter so your crafter knows which items to restock.\n\nIf you don't want to keep changing the character name in your settings all the time, you can create macros for each of your alts like this:\n/lstsenddata charactername"
L["FAQ_IncorrectData_Title"] = "The numbers are wrong!"
L["FAQ_IncorrectData_Description"] = "It happens, sometimes LST can't know when items have moved. For example if an auction expires LST can only know this once you opened your auction house again.\nLST updates most data when opening or closing a window, if you think something isn't right, just open your bank, guild bank, mailbox and auction house again so everything can update.\nYou can also try to troubleshoot where this data is coming from by disabling caching, that way it will ignore all items from other alts and even everything you didn't open this session.\nHovering over the minimap icon will also show you how many items LST found in every source, color coded based on the class of the alt the items are on."
L["FAQ_KnowIssues_Title"] = "Known issues"
L["FAQ_KnowIssues_Description"] = "- Items on the AH can't be updated if you don't have a single auction posted.\n- LST sometimes doesn't get itemlevel data from the api, and therefore isn't able to count the item anywhere\n- Spamming the craft button can cause LST to start crafting again before the list is updated"
L["FAQ_Outro"] = "If you still have any questions, feedback or need support, please go to https://discord.gg/nYexBdaBuP (go to curseforge if you don't want to copy the url)"

-- Errors
L["Incorrect itemlevel data received for item "] = "LST: Données de niveau d'élément incorrectes reçues pour l'élément "
L[", skipping data for this rank."] = ", en sautant les données pour ce rang."
L["LST: Error, incorrect input"] = "LST: Erreur, entrée incorrecte"
L["LST: Crafting is not yet supported for rank 5 and 6, please craft these manually for now"] = "LST : L'artisanat n'est pas encore supporté pour les rangs 5 et 6, veuillez les fabriquer manuellement pour le moment"
L["error_unknown_crafter"] = "LST: LST doesn't know which character can craft this item, please resync your data so LST knows which character can craft "
L["error_crafter_can't_make_vestige"] = " doesn't have any professions to make a vestige. If this is wrong please log in on that character and resync lst data"
L["error_please_resync"] = "LST is missing necessary sync data, please resync account with character "
L["error_character_missing_data"] = "LST is missing necessary data, please update character "
L["error_missing_material_info"] = "LST is missing material info, please open the material restock list again"
