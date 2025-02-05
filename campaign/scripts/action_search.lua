-- Please see the LICENSE.txt file included with this distribution for
-- attribution and copyright information.

-- luacheck: globals applySearchAndFilter findWeaponList initFilterDropdown onFilterFieldChanged refreshFilters
-- luacheck: globals onFilterOptionChanged onFilterSelect onSearchClear onSearchEnter onSpellModeChange
-- luacheck: globals actions_search_btn actions_search_input actions_search_clear_btn actions_filter_dropdown
-- luacheck: globals subspells subweapons filter_lbl

local fFilter;
local fSearch;

function onInit()
	if super and super.onInit then
		super.onInit();
	end

	actions_search_btn.onButtonPress = onSearchEnter;
	actions_search_input.setValue("");
	actions_search_input.onEnter = onSearchEnter;
	actions_search_clear_btn.onButtonPress = onSearchClear;

	local ruleset = User.getRulesetName();

	if ruleset ~= "4E" then
		initFilterDropdown();
		actions_filter_dropdown.onSelect = onFilterSelect;

		ActionsFiltersManager.setFilterOptionListener(onFilterOptionChanged);
	end

	local nodeModeButton;

	if ruleset == "5E" then
		nodeModeButton = powermode.getDatabaseNode();
	elseif ruleset == "4E" then
		nodeModeButton = powersort.getDatabaseNode();
	else
		if ActionsFiltersManager.bHasExtensionAdvancedCharsheet then
			nodeModeButton = subspells.subwindow.spellmode.getDatabaseNode();
		else
			nodeModeButton = spellmode.getDatabaseNode();
		end
	end

	local nodeChar = getDatabaseNode();
	DB.addHandler(DB.getPath(nodeModeButton), "onUpdate", onSpellModeChange);
	DB.addHandler(DB.getPath(nodeChar, "powers.*.name"), "onUpdate", onFilterFieldChanged);
	DB.addHandler(DB.getPath(nodeChar, "powers.*.duration"), "onUpdate", onFilterFieldChanged);
	DB.addHandler(DB.getPath(nodeChar, "powers.*.school"), "onUpdate", onFilterFieldChanged);
end

function onClose()
	ActionsFiltersManager.removeFilterOptionListener(onFilterOptionChanged);

	local ruleset = User.getRulesetName();
	local nodeModeButton;

	if ruleset == "5E" then
		nodeModeButton = powermode.getDatabaseNode();
	elseif ruleset == "4E" then
		nodeModeButton = powersort.getDatabaseNode();
	else
		if ActionsFiltersManager.bHasExtensionAdvancedCharsheet then
			nodeModeButton = subspells.subwindow.spellmode.getDatabaseNode();
		else
			nodeModeButton = spellmode.getDatabaseNode();
		end
	end

	local nodeChar = getDatabaseNode();
	DB.removeHandler(DB.getPath(nodeModeButton), "onUpdate", onSpellModeChange);
	DB.removeHandler(DB.getPath(nodeChar, "powers.*.name"), "onUpdate", onFilterFieldChanged);
	DB.removeHandler(DB.getPath(nodeChar, "powers.*.duration"), "onUpdate", onFilterFieldChanged);
	DB.removeHandler(DB.getPath(nodeChar, "powers.*.school"), "onUpdate", onFilterFieldChanged);
end

function applySearchAndFilter()
	local ruleset = User.getRulesetName();

	if ruleset == "5E" then
		local vWindow;
		if content then
			vWindow = content.subwindow.actions.subwindow;
		else --FloatingTabs compatibility
			vWindow = contents.subwindow.actions.subwindow; --luacheck: ignore 85
		end
		local nodeSpell;

		vWindow.updateUses();

		for _, vPowerPage in pairs(vWindow.powers.getWindows()) do
			if vPowerPage.getClass() ~= "power_group_header" and vPowerPage.getFilter() == true then
				nodeSpell = vPowerPage.getDatabaseNode();

				local bMatchesFilter = fFilter == nil or fFilter(nodeSpell);
				local bMatchesSearch = fSearch == nil or fSearch(nodeSpell);

				if not (bMatchesFilter and bMatchesSearch) then
					vPowerPage.setFilter(false);
				end
			end
		end

		vWindow.powers.applyFilter();
	elseif ruleset == "4E" then
		local list = powerlist;
		local fOriginalFilter = list.onFilter;

		list.onFilter = function(w)
			local bInternalVisible = fOriginalFilter(w);

			if not bInternalVisible then
				return false;
			end

			if w.getClass() == "char_power" or w.getClass() == "power_item" or w.getClass() == "power_item_mini" then
				local nodePower = w.getDatabaseNode();
				local bMatchesSearch = fSearch == nil or fSearch(nodePower);

				return bMatchesSearch;
			end

			return true;
		end

		list.applyFilter();
	else
		local nodeLevel, nodeSpell;
		local tSpellclasslist;

		if ActionsFiltersManager.bHasExtensionAdvancedCharsheet then
			tSpellclasslist = subspells.subwindow.spells.subwindow.spellclasslist;
		else
			tSpellclasslist = actions.subwindow.spellclasslist;
		end

		for _, vSpellClass in pairs(tSpellclasslist.getWindows()) do
			vSpellClass.updateSpellView();

			for _, vSpellLevel in pairs(vSpellClass.levels.getWindows()) do
				nodeLevel = vSpellLevel.getDatabaseNode();

				if nodeLevel then
					for _, vSpell in pairs(vSpellLevel.spells.getWindows()) do
						nodeSpell = vSpell.getDatabaseNode();

						if vSpell.getFilter() == true then
							local bMatchesFilter = fFilter == nil or fFilter(nodeSpell);
							local bMatchesSearch = fSearch == nil or fSearch(nodeSpell);

							if not (bMatchesFilter and bMatchesSearch) then
								vSpell.setFilter(false);
							end
						end
					end

					vSpellLevel.spells.applyFilter();
				end
			end
		end
	end

	if ruleset ~= "4E" then
		local weaponList = self.findWeaponList();

		if weaponList ~= nil then
			local fOriginalFilter = weaponList.onFilter;

			weaponList.onFilter = function(w)
				local bInternalVisible = fOriginalFilter(w);

				if not bInternalVisible then
					return false;
				end

				local item = w.getDatabaseNode();
				local matchesFilter = fFilter == nil or fFilter(item);
				local matchesSearch = fSearch == nil or fSearch(item);

				return matchesFilter and matchesSearch;
			end

			weaponList.applyFilter();
		end
	end
end

function findWeaponList()
	local ruleset = User.getRulesetName();
	local list;

	if ruleset == "5E" then
		if content then
			list = content.subwindow.weapons;
		else
			list = contents.subwindow.weapons;
		end
	elseif ActionsFiltersManager.bHasExtensionAdvancedCharsheet then
		if subweapons.subwindow.weapons.subwindow ~= nil then
			list = subweapons.subwindow.weapons.subwindow.weaponlist;
		end
	else
		list = actions.subwindow.weaponlist;
	end

	return list;
end

function initFilterDropdown()
	fFilter = nil;
	actions_filter_dropdown.clear();

	refreshFilters();

	actions_filter_dropdown.setListIndex(1);

	if #actions_filter_dropdown.getValues() == 1 then
		actions_filter_dropdown.setComboBoxVisible(false);
		filter_lbl.setVisible(false);
	else
		actions_filter_dropdown.setComboBoxVisible(true);
		filter_lbl.setVisible(true);
	end
end

function onFilterFieldChanged()
	if User.getRulesetName() ~= "4E" then
		self.refreshFilters();
	end

	self.applySearchAndFilter();
end

function onFilterOptionChanged()
	self.initFilterDropdown();
	self.applySearchAndFilter();
end

function onFilterSelect(sValue)
	local nodeChar = getDatabaseNode();
	local vFilterOpt = ActionsFiltersManager.findFilterOption(nodeChar, nil, sValue);

	if vFilterOpt ~= nil then
		fFilter = vFilterOpt.fFilter;
	else
		fFilter = nil;
	end

	self.applySearchAndFilter();
end

function onSearchClear()
	fSearch = function(_)
		return true;
	end

	self.applySearchAndFilter();

	actions_search_input.setValue("");
	actions_search_clear_btn.setVisible(false);
end

function onSearchEnter()
	local searchInput = StringManager.trim(actions_search_input.getValue()):lower();

	if searchInput == "" then
		self.onSearchClear();
	else
		fSearch = function(item)
			local name = DB.getValue(item, "name", ""):lower();

			return string.find(name, searchInput);
		end

		self.applySearchAndFilter();
		actions_search_clear_btn.setVisible(true);
	end
end

function onSpellModeChange()
	self.applySearchAndFilter();
end

function refreshFilters()
	local nodeChar = getDatabaseNode();
	actions_filter_dropdown.clear();
	for _, v in ipairs(ActionsFiltersManager.getFilterOptions(nodeChar)) do
		if v.sLabelRes then
			actions_filter_dropdown.add(Interface.getString(v.sLabelRes));
		else
			actions_filter_dropdown.add(v.sLabel);
		end
	end
end
