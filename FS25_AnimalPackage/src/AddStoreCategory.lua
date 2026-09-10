--[[
Script to add new store category(s) in the mod view

Author:		Ifko[nator]
Date:		16.04.2023
Version:	3.1

History:	v1.0 @16.11.2015 - initial release in FS 15
			------------------------------------------------------------------------------------------------------------------
			v1.1 @09.12.2015 - bug fix for wrong placement of the new category in the mod view
			------------------------------------------------------------------------------------------------------------------
			v1.5 @25.10.2016 - add support for the new categories from FS 17
			------------------------------------------------------------------------------------------------------------------
			v1.8 @27.11.2017 - some improvements in the script, now it is smaller
			------------------------------------------------------------------------------------------------------------------
			v2.0 @21.01.2019 - add support for the new store from FS 19
			------------------------------------------------------------------------------------------------------------------
			v2.1 @07.08.2019 - added posibility to add the new category to the GPS Mod from Wopster
			------------------------------------------------------------------------------------------------------------------
			v2.2 @06.12.2020 - added posibility to add the new category to the tireSound Mod from PeterAH
			------------------------------------------------------------------------------------------------------------------
			v2.3 @13.06.2021 - minior adjustments
			------------------------------------------------------------------------------------------------------------------
			v3.0 @18.11.2021 - convert to FS 22
							 - removed function for tireSound and GPS Mod
			------------------------------------------------------------------------------------------------------------------
			v3.1 @16.04.2023 - added posibility to add the new category to the headland managment Mod from Glowins Modschmiede
			------------------------------------------------------------------------------------------------------------------
			v4.0 @17.01.2025 - convert to FS 25

]]

AddStoreCategory = {};

AddStoreCategory.currentModDirectory = g_currentModDirectory;
AddStoreCategory.currentModName = g_currentModName;

local function addCategory(self, superFunc, xmlFile, missionInfo, baseDirectory)
	superFunc(self, xmlFile, missionInfo, baseDirectory);
	
	local xmlFile = XMLFile.load("modDesc", AddStoreCategory.currentModDirectory .. "modDesc.xml");

    for _, storeTypeKey in xmlFile:iterator("modDesc.storeCategories.storeType") do
        g_storeManager:loadCategoryType(xmlFile, storeTypeKey, nil);
    end;

    for _, storeCategoryKey in xmlFile:iterator("modDesc.storeCategories.storeCategory") do
        g_storeManager:loadCategoryFromXML(xmlFile, storeCategoryKey, AddStoreCategory.currentModDirectory, AddStoreCategory.currentModName);
    end;

    local defaultIconFilename = "dataS/menu/construction/ui_construction_icons.png";
    local defaultRefSize = {256, 256};

	for _, constructionTag in pairs({"constructionType", "constructionCategory"}) do
		for _, constructionKey in xmlFile:iterator("modDesc.constructionCategories." .. constructionTag) do
			local name = xmlFile:getString(constructionKey .. "#name");
			local title = g_i18n:convertText(xmlFile:getString(constructionKey .. "#title"));
			local iconFilename = Utils.getNoNil(xmlFile:getString(constructionKey .. "#iconFilename"), defaultIconFilename);
			local refSize = xmlFile:getVector(constructionKey .. "#refSize", defaultRefSize, 2);
			local iconUVs = GuiUtils.getUVs(xmlFile:getString(constructionKey .. "#iconUVs", "0 0 1 1"), refSize);
			local iconSliceId = xmlFile:getString(constructionKey .. "#iconSliceId");
			
			if constructionTag == "constructionCategory" then
				local categoryTypeName = xmlFile:getString(constructionKey .. "#type");

				g_storeManager:addConstructionTab(categoryTypeName, name, title, iconFilename, iconUVs, "", iconSliceId);
			else
				g_storeManager:addConstructionCategory(name, title, iconFilename, iconUVs, "", iconSliceId);
			end;	
		end;
	end;

    xmlFile:delete();

    return true;
end;

StoreManager.loadMapData = Utils.overwrittenFunction(StoreManager.loadMapData, addCategory);