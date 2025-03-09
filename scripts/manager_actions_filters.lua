-- Please see the LICENSE.txt file included with this distribution for
-- attribution and copyright information.

-- luacheck: globals configureOption findFilterOption getFilterOptions getSchools getSchoolsFlat getSchoolsNested
-- luacheck: globals hasExtension isSpell isWeapon setFilterOptionListener removeFilterOptionListener
-- luacheck: globals onOptionChanged bHasExtensionAdvancedCharsheet

bHasExtensionAdvancedCharsheet = false;

local WEAPONS_FILTER_OPTION = "AFopt_weapons";
local SPELLS_FILTER_OPTION = "AFopt_spells";
local CONCENTRATION_FILTER_OPTION = "AFopt_spells_con";
local NOT_CONCENTRATION_FILTER_OPTION = "AFopt_spells_notcon";
local RITUAL_FILTER_OPTION = "AFopt_spells_ritual";
local SCHOOL_FILTER_OPTION = "AFopt_spellschool";

function onInit()
	bHasExtensionAdvancedCharsheet = self.hasExtension("Advanced Charsheet") or self.hasExtension("AdvancedCharsheet");

	if not bHasExtensionAdvancedCharsheet then
		configureOption(WEAPONS_FILTER_OPTION, "filteropt_weapons");
		configureOption(SPELLS_FILTER_OPTION, "filteropt_spells");
	end

	configureOption(CONCENTRATION_FILTER_OPTION, "filteropt_spells_con");
	configureOption(NOT_CONCENTRATION_FILTER_OPTION, "filteropt_spells_notcon");
	configureOption(RITUAL_FILTER_OPTION, "filteropt_spells_ritual");
	configureOption(SCHOOL_FILTER_OPTION, "filteropt_schools_label");
end

function configureOption(sOptKey, sOptLabelRes)
	if OptionsManager.getOption(sOptKey) == "" then
		--OptionsManager.registerOption2(sOptKey, true, "option_header_AF", sOptLabelRes, "option_entry_cycler",
		OptionsManager.registerOption2(sOptKey, true, "option_header_WP", sOptLabelRes, "option_entry_cycler",
				{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" });
		OptionsManager.registerCallback(sOptKey, onOptionChanged);
	end
end

function findFilterOption(nodeChar, sLabelRes, sLabelValue)
	local option;

	for _, v in ipairs(getFilterOptions(nodeChar)) do
		if sLabelRes ~= nil and sLabelRes == v.sLabelRes then
			option = v;
		elseif sLabelValue ~= nil and ((v.sLabel == sLabelValue) or (Interface.getString(v.sLabelRes) == sLabelValue)) then
			option = v;
		end
	end

	return option;
end

function getFilterOptions(nodeChar)
	local ruleset = User.getRulesetName();

	if ruleset == "4E" then
		return;
	end

	local aFilterOptions = {{
		sLabelRes = "filteropt_none",
		fFilter = function()
			return true;
		end
	}};

	if OptionsManager.isOption(WEAPONS_FILTER_OPTION, "on") then
		table.insert(aFilterOptions, {
			sLabelRes = "filteropt_weapons",
			fFilter = function(item)
				return self.isWeapon(item);
			end
		});
	end

	if OptionsManager.isOption(SPELLS_FILTER_OPTION, "on") then
		table.insert(aFilterOptions, {
			sLabelRes = "filteropt_spells",
			fFilter = function(item)
				return self.isSpell(item, ruleset);
			end
		});
	end

	if OptionsManager.isOption(CONCENTRATION_FILTER_OPTION, "on") then
		table.insert(aFilterOptions, {
			sLabelRes = "filteropt_spells_con",
			fFilter = function(item)
				if not self.isSpell(item, ruleset) then
					return false;
				end

				if ruleset == "PFRPG2" then
					return DB.getValue(item, "traits", ""):lower():find("concentrate") ~= nil;
				end

				return DB.getValue(item, "duration", ""):lower():find("concentration") ~= nil;
			end
		});
	end

	if OptionsManager.isOption(NOT_CONCENTRATION_FILTER_OPTION, "on") then
		table.insert(aFilterOptions, {
			sLabelRes = "filteropt_spells_notcon",
			fFilter = function(item)
				if not self.isSpell(item, ruleset) then
					return false;
				end

				if ruleset == "PFRPG2" then
					return DB.getValue(item, "traits", ""):lower():find("concentrate") == nil;
				end

				return DB.getValue(item, "duration", ""):lower():find("concentration") == nil;
			end
		});
	end

	if ruleset == "5E" and OptionsManager.isOption(RITUAL_FILTER_OPTION, "on") then
		table.insert(aFilterOptions, {
			sLabelRes = "filteropt_spells_ritual",
			fFilter = function(item)
				return DB.getValue(item, "ritual", 0) == 1;
			end
		});
	end

	if ruleset ~= "PFRPG2" and OptionsManager.isOption(SCHOOL_FILTER_OPTION, "on") then
		for _, sSchool in ipairs(getSchools(nodeChar)) do
			local sLabel;

			if sSchool == "" then
				sLabel = Interface.getString("filteropt_school_none");
			else
				sLabel = Interface.getString("filteropt_school_prefix") .. sSchool;
			end

			table.insert(aFilterOptions, {
				sLabel = sLabel,
				fFilter = function(item)
					if ruleset == "PFRPG2" then
						return DB.getValue(item, "traits", ""):lower():find(sSchool:lower());
					end

					return DB.getValue(item, "school", ""):lower():find("^" .. sSchool:lower());
				end
			});
		end
	end

	return aFilterOptions;
end

function getSchools(nodeChar)
	local sRuleset = User.getRulesetName();
	local tPowers;

	if sRuleset == "5E" then
		tPowers = getSchoolsFlat(nodeChar)
	else
		tPowers = getSchoolsNested(nodeChar, sRuleset);
	end

	local aSchools = {};

	for sSchool, _ in pairs(tPowers) do
		table.insert(aSchools, sSchool);
	end

	table.sort(aSchools);

	return aSchools;
end

function getSchoolsFlat(nodeChar)
	local tPowers = {};

	for _, nodePower in pairs(DB.getChildren(nodeChar, "powers")) do
		local sSchool = DB.getValue(nodePower, "school", "");

		tPowers[sSchool] = true;
	end

	return tPowers;
end

function getSchoolsNested(nodeChar, sRuleset)
	local tPowers = {};

	for _, nodeSpellSet in pairs(DB.getChildren(nodeChar, "spellset")) do
		for _, nodeLevel in pairs(DB.getChildren(nodeSpellSet, "levels")) do
			for _, nodeSpell in pairs(DB.getChildren(nodeLevel, "spells")) do
				local sSchool;

				if sRuleset == "PFRPG2" then
					sSchool = DB.getValue(nodeSpell, "traits", "");
				else
					sSchool = DB.getValue(nodeSpell, "school", "");
				end

				sSchool = StringManager.trim(sSchool:gsub("[%[%(][^%]%)]*[%]%)]", ""));
				tPowers[sSchool] = true;
			end
		end
	end

	return tPowers;
end

function hasExtension(sName)
	return table.concat(Extension.getExtensions(), ","):match(sName) ~= nil;
end

function isSpell(vRecord, sRuleset)
	if sRuleset == "5E" then
		return DB.getValue(vRecord, "group", ""):lower() == "spells"
	end

	return vRecord.getParent().getName() == "spells";
end

function isWeapon(vRecord)
	return vRecord.getParent().getName() == "weaponlist";
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
