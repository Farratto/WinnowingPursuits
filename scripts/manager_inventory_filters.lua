-- Please see the LICENSE.txt file included with this distribution for
-- attribution and copyright information.

-- luacheck: globals isValuable setValueTypes findFilterOption setFilterOptionListener removeFilterOptionListener
-- luacheck: globals onOptionChanged buildPartyInventoryWP tValueTypes fbuildPartyInventory filterOptions
-- luacheck: globals _bAllowBuildPartyInventory hasExtension

tValueTypes = {};
fbuildPartyInventory = '';
filterOptions = {};
_bAllowBuildPartyInventory = false;
local tExtensions = {};

function onInit()
	local ruleset = User.getRulesetName();

	if not tValueTypes[1] then setValueTypes() end

	if Session.IsHost then
		fbuildPartyInventory = PartyLootManager.buildPartyInventory;
		PartyLootManager.buildPartyInventory = buildPartyInventoryWP;
	end

	filterOptions = {
		[1] = {
			sLabelRes = "filteropt_none",
			bPartySearch = true,
			fFilter = nil },
		[2] = {
			sLabelRes = "filteropt_valuables",
			sOptKey = "ISopt_valuables",
			bPartySearch = true,
			fFilter = function(item)
				return isValuable(item);
			end },
		[3] = {
			sLabelRes = "filteropt_armor",
			sOptKey = "ISopt_armor",
			bPartySearch = true,
			fFilter = function(item)
				return (ItemManager2.isArmor(item));
			end },
		[4] = {
			--sLabelRes = "filteropt_weapons",
			sLabelRes = "filteropt_inv_weapons",
			sOptKey = "ISopt_weapons",
			bPartySearch = true,
			fFilter = function(item)
				return (ItemManager2.isWeapon(item));
			end },
		[5] = {
			sLabelRes = "filteropt_armorweapons",
			sOptKey = "ISopt_armorweapons",
			bPartySearch = true,
			fFilter = function(item)
				return (ItemManager2.isArmor(item) or ItemManager2.isWeapon(item));
			end },
		[6] = {
			sLabelRes = "filteropt_magical",
			sOptKey = "ISopt_magical",
			bPartySearch = true,
			fFilter = function(item)
				if LibraryData.getIDState("item", item, true) == false then
					return false; -- do not reveal that unidentified items are magical
				end

				if ruleset == "5E" then
					local sProp = DB.getValue(item, "properties", ""):lower();
					local sType = DB.getValue(item, "type", "");

					return sProp:match("magic") or sType == "Wondrous Item" or sType == "Potion"
						or CharAttunementManager.doesItemAllowAttunement(item
					);
				elseif ruleset == "4E" then
					local sClass = DB.getValue(item, "class", "");

					return sClass == "Potion" or sClass == "Consumable" or sClass == "Wondrous Item"
						or sClass == "Implements" or sClass == "Arms Slot" or sClass == "Feet Slot" or sClass ==
						"Hands Slot" or sClass == "Head Slot" or sClass == "Neck Slot" or sClass == "Ring Slot"
						or sClass == "Waist Slot"
					;
				else
					local sAura = DB.getValue(item, "aura", "");
					local sType = DB.getValue(item, "type", "");

					return (sAura ~= "" and string.match(sAura, "nonmagical") == nil) or sType == "Potion";
				end
			end },
		[7] = {
			sLabelRes = "filteropt_potions",
			sOptKey = "ISopt_potions",
			bPartySearch = true,
			fFilter = function(item)
				if ruleset == "4E" then
					return DB.getValue(item, "class", "") == "Potion" or DB.getValue(item, "subclass", "") == "Potion";
				end

				return DB.getValue(item, "type", "") == "Potion" or DB.getValue(item, "subtype", "") == "Potion";
			end },
		[8] = {
			sLabelRes = "filteropt_scrolls",
			sOptKey = "ISopt_scrolls",
			bPartySearch = true,
			fFilter = function(item)
				if ruleset == "4E" then
					return DB.getValue(item, "class", "") == "Scroll" or DB.getValue(item, "subclass", "") == "Scroll";
				end

				return DB.getValue(item, "type", "") == "Scroll" or DB.getValue(item, "subtype", "") == "Scroll";
			end },
		[9] = {
			sLabelRes = "filteropt_ritual",
			sOptKey = "ISopt_ritual",
			sRulesetFilter = "4E",
			bPartySearch = true,
			fFilter = function(item)
				return DB.getValue(item, "class", "") == "Ritual";
			end },
		[10] = {
			sLabelRes = "filteropt_attunement",
			sOptKey = "ISopt_attunement",
			sRulesetFilter = "5E",
			bPartySearch = true,
			fFilter = function(item)
				return CharAttunementManager.doesItemAllowAttunement(item);
			end },
		[11] = {
			sLabelRes = "filteropt_id",
			sOptKey = "ISopt_id",
			bPartySearch = true,
			fFilter = function(item)
				return (LibraryData.getIDState("item", item, true)) == true;
			end },
		[12] = {
			sLabelRes = "filteropt_not_id",
			sOptKey = "ISopt_not_id",
			bPartySearch = true,
			fFilter = function(item)
				return (LibraryData.getIDState("item", item, true)) == false;
			end },
		[13] = {
			sLabelRes = "filteropt_gear",
			sOptKey = "ISopt_gear",
			bPartySearch = true,
			fFilter = function(item)
				if ruleset == "4E" then
					return DB.getValue(item, "class", "") == "Gear" or DB.getValue(item, "subclass", "") == "Gear";
				end

				return DB.getValue(item, "type", "") == "Adventuring Gear" or DB.getValue(item, "subtype", "") == "Adventuring Gear";
			end },
		[14] = {
			sLabelRes = "filteropt_goods",
			sOptKey = "ISopt_goods",
			bPartySearch = true,
			fFilter = function(item)
				local sType = DB.getValue(item, "type", "");
				local sSubType = DB.getValue(item, "subtype", "");

				return sType == "Goods and Services" or sSubType == "Goods and Services" or sType == "Tools"
					or sType:match("Mounts") or sType:match("Vehicles"
				);
			end },
		[15] = {
			sLabelRes = "filteropt_carried",
			sOptKey = "ISopt_carried",
			bPartySearch = false,
			fFilter = function(item)
				return DB.getValue(item, "carried", "") == 1;
			end },
		[16] = {
			sLabelRes = "filteropt_equipped",
			sOptKey = "ISopt_equipped",
			bPartySearch = false,
			fFilter = function(item)
				return DB.getValue(item, "carried", "") == 2;
			end },
		[17] = {
			sLabelRes = "filteropt_not_carried",
			sOptKey = "ISopt_not_carried",
			bPartySearch = false,
			fFilter = function(item)
				return DB.getValue(item, "carried", "") == 0;
			end },
	};

	for _, v in ipairs(filterOptions) do
		if v.sOptKey ~= nil and (v.sRulesetFilter == nil or v.sRulesetFilter == ruleset) then
			--OptionsManager.registerOption2(v.sOptKey, true, "option_header_IF", v.sLabelRes, "option_entry_cycler",
			OptionsManager.registerOption2(v.sOptKey, true, "option_header_WP", v.sLabelRes, "option_entry_cycler",
					{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" });
			OptionsManager.registerCallback(v.sOptKey, onOptionChanged);
		end
	end

	if Session.IsHost then
		_bAllowBuildPartyInventory = true;
		PartyLootManager.populate();
	end
end

function onTabletopInit()
	hasExtension();
end

function isValuable(nodeItem)
	local sTypeLower = StringManager.trim(DB.getValue(nodeItem, "type", "")):lower();
	local sSubtypeLower = StringManager.trim(DB.getValue(nodeItem, "subtype", "")):lower();

	--make sure it has a valid price
	local nCurrency,_ = CurrencyManager.parseCurrencyString(DB.getValue(nodeItem, "cost", ""), true);
	if not nCurrency or nCurrency == 0 then return end

	--check if type or subtype matches any of the valuables set in table
	if not tValueTypes[1] then setValueTypes() end
	local bValue = false;
	for _,sValueType in ipairs(tValueTypes) do
		if not bValue then bValue = (string.match(sTypeLower, '^'..sValueType)) end
		if not bValue then bValue = (string.match(sSubtypeLower, '^'..sValueType)) end
	end

	return bValue;
end

function setValueTypes()
	table.insert(tValueTypes, 'trade good');
	table.insert(tValueTypes, 'trade bar');
	table.insert(tValueTypes, 'gemstone');
	table.insert(tValueTypes, 'jewelry');
	table.insert(tValueTypes, 'art object');
	table.insert(tValueTypes, 'artwork');
end

function findFilterOption(sLabelRes, sLabelValue, sOptKey)
	local option;

	local sExpanded = 'Inventory Filter - ' .. sLabelValue;
	for _, v in ipairs(filterOptions) do
		if sLabelRes ~= nil and sLabelRes == v.sLabelRes then
			option = v;
		--elseif sLabelValue ~= nil and Interface.getString(v.sLabelRes) == sLabelValue then
		elseif sLabelValue ~= nil and Interface.getString(v.sLabelRes) == sExpanded then
			option = v;
		elseif sOptKey ~= nil and sOptKey == v.sOptKey then
			option = v;
		end
	end

	return option;
end

local aFilterOptionListeners = {};
function setFilterOptionListener(f)
	table.insert(aFilterOptionListeners, f);
end
function removeFilterOptionListener(f)
	for k, v in ipairs(aFilterOptionListeners) do
		if v == f then
			table.remove(aFilterOptionListeners, k);
			return true;
		end
	end

	return false;
end

function onOptionChanged(sKey)
	for _, v in pairs(aFilterOptionListeners) do
		v(sKey);
	end
end

function buildPartyInventoryWP()
	if not _bAllowBuildPartyInventory then return false end

	DB.deleteChildren("partysheet.inventorylist");

	-- Determine members of party
	local tParty = PartyLootManager.getPartyMemberRecordsForItems();

	-- Build a database of party inventory items
	local aInvDB = {};
	for _,v in ipairs(tParty) do
		local sRecordType = ActorManager.getRecordType(v.node);
		local tItemPaths = ItemManager.getInventoryPaths(sRecordType) or {};
		for _,sListPath in pairs(tItemPaths) do
			for _,nodeItem in ipairs(DB.getChildList(v.node, sListPath)) do
				local sItem = ItemManager.getDisplayName(nodeItem, true);
				if sItem ~= "" then
					local nCount = math.max(DB.getValue(nodeItem, "count", 0), 1)
					if aInvDB[sItem] then
						aInvDB[sItem].count = aInvDB[sItem].count + nCount;
					else
						local aItem = {};
						aItem.count = nCount;
						aItem.node = nodeItem; --added
						aInvDB[sItem] = aItem;
					end

					if not aInvDB[sItem].carriedby then
						aInvDB[sItem].carriedby = {};
					end
					aInvDB[sItem].carriedby[v.sName] = ((aInvDB[sItem].carriedby[v.sName]) or 0) + nCount;
				end
			end
		end
	end

	-- Create party sheet inventory entries
	for sItem, rItem in pairs(aInvDB) do
		local vGroupItem = DB.createChild("partysheet.inventorylist");
		DB.copyNode(rItem.node, vGroupItem); --added
		DB.setValue(vGroupItem, "count", "number", rItem.count);
		DB.setValue(vGroupItem, "name", "string", sItem);

		local aCarriedBy = {};
		for k,v in pairs(rItem.carriedby) do
			table.insert(aCarriedBy, string.format("%s [%d]", k, math.floor(v)));
		end
		DB.setValue(vGroupItem, "carriedby", "string", table.concat(aCarriedBy, ", "));
	end
	_bAllowBuildPartyInventory = false;
end

function hasExtension(sExtName)
	if not tExtensions[1] then tExtensions = Extension.getExtensions() end
	if not sExtName then return end
	for _,sExtension in ipairs(tExtensions) do
		if sExtension == sExtName then
			return true;
		end
	end
	return false;
end
