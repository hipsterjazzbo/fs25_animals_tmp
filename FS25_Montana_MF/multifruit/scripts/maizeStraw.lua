--[[
maizeStraw

Specialization to allow straw for maize

Author: 	Ifko[nator]
Date: 		06.08.2020
Version:	1.0

History:	v1.0 @06.08.2020 - initial implemation in FS 19
]]

maizeStraw = {};

function maizeStraw:loadFruitTypeWindrow(superFunc, fruitType, xmlFile, key)
	local maize = g_fruitTypeManager:getFruitTypeByName("maize");

	if maize ~= nil then
		local windrowFillType = g_fillTypeManager:getFillTypeByName("corn_stalks");
		
		maize.hasWindrow = true;
		maize.windrowName = windrowFillType.name;
		maize.windrowLiterPerSqm = 60;
		self.windrowFillTypes[windrowFillType.index] = true;
		self.fruitTypeIndexToWindrowFillTypeIndex[maize.index] = windrowFillType.index;
		self.fillTypeIndexToFruitTypeIndex[windrowFillType.index] = maize.index;
	end;
	
	if fruitType ~= nil and fruitType.name ~= "maize" then
		local windrowName = getXMLString(xmlFile, key .. ".windrow#name");
		local windrowLitersPerSqm = getXMLFloat(xmlFile, key .. ".windrow#litersPerSqm");

		if windrowName == nil or windrowLitersPerSqm == nil then
			return true;
		end;

		local windrowFillType = g_fillTypeManager:getFillTypeByName(windrowName);

		if windrowFillType == nil then
			print("Warning: Missing fillType '" .. tostring(windrowName) .. "' for windrow definition. Ignoring windrow!");

			return false;
		end;

		fruitType.hasWindrow = true;
		fruitType.windrowName = windrowFillType.name;
		fruitType.windrowLiterPerSqm = windrowLitersPerSqm;
		self.windrowFillTypes[windrowFillType.index] = true;
		self.fruitTypeIndexToWindrowFillTypeIndex[fruitType.index] = windrowFillType.index;
		self.fillTypeIndexToFruitTypeIndex[windrowFillType.index] = fruitType.index;
	end;

	return true;
end;

FruitTypeManager.loadFruitTypeWindrow = Utils.overwrittenFunction(FruitTypeManager.loadFruitTypeWindrow, maizeStraw.loadFruitTypeWindrow)