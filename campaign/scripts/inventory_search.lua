-- Please see the LICENSE.txt file included with this distribution for
-- attribution and copyright information.

-- luacheck: globals applySearchAndFilter findInventoryList initFilterDropdown onFilterOptionChanged
-- luacheck: globals onSearchClear onSearchEnter onFilterSelect inv_search_clear_btn inv_search_input
-- luacheck: globals inv_filter_dropdown filter_lbl inv_search_btn

local bIsPS;
local fFilter;
local fSearch;

function onInit()
	if super and super.onInit then
		super.onInit();
	end

	inv_search_input.setValue("");
	inv_search_input.onEnter = onSearchEnter;
	inv_search_clear_btn.onButtonPress = onSearchClear;

	bIsPS = getDatabaseNode().getNodeName() == "partysheet";

	if not bIsPS then
		inv_search_btn.onButtonPress = onSearchEnter;
	end
	initFilterDropdown();

	InventoryFiltersManager.setFilterOptionListener(onFilterOptionChanged);
	inv_filter_dropdown.onSelect = onFilterSelect;
end

function applySearchAndFilter()
	local list = self.findInventoryList();
	local fOriginalFilter = list.onFilter;

	list.onFilter = function(node)
		local item = node.getDatabaseNode();
		local matchesFilter = fFilter == nil or fFilter(item);
		local matchesSearch = fSearch == nil or fSearch(item);

		if fFilter == nil and fSearch == nil then
			return fOriginalFilter == nil or fOriginalFilter(node);
		end

		return matchesFilter and matchesSearch;
	end

	list.applyFilter();
end

function findInventoryList()
	if bIsPS then
		return list;
	end

	local ruleset = User.getRulesetName();
	local invlist;

	if ruleset == "5E" then
		if content then
			invlist = content.subwindow.items.subwindow.list;
		else --FloatingTabs compatibility
			invlist = contents.subwindow.items.subwindow.list; --luacheck: ignore 85 143
		end
	else
		invlist = inventorylist;
	end

	return invlist;
end

function initFilterDropdown()
	fFilter = nil;
	inv_filter_dropdown.clear();

	local ruleset = User.getRulesetName();

	for _, v in ipairs(InventoryFiltersManager.filterOptions) do
		if (v.sOptKey == nil or OptionsManager.isOption(v.sOptKey, "on")) and (v.sRulesetFilter == nil
			or v.sRulesetFilter == ruleset) and ((not bIsPS) or v.bPartySearch
		) then
			inv_filter_dropdown.add(Interface.getString(v.sLabelRes));
		end
	end

	inv_filter_dropdown.setListIndex(1);

	if #inv_filter_dropdown.getValues() == 1 then
		inv_filter_dropdown.setComboBoxVisible(false);
		filter_lbl.setVisible(false);
	else
		inv_filter_dropdown.setComboBoxVisible(true);
		filter_lbl.setVisible(true);
	end
end

function onClose()
	InventoryFiltersManager.removeFilterOptionListener(onFilterOptionChanged);
end

function onFilterOptionChanged()
	self.initFilterDropdown();
	self.applySearchAndFilter();
end

function onFilterSelect(sValue)
	local vFilterOpt = InventoryFiltersManager.findFilterOption(nil, sValue);

	if vFilterOpt ~= nil then
		fFilter = vFilterOpt.fFilter;
	else
		fFilter = nil;
	end

	self.applySearchAndFilter();
end

function onSearchClear()
	fSearch = nil;
	inv_search_input.setValue("");
	inv_search_clear_btn.setVisible(false);

	self.applySearchAndFilter();
end

function onSearchEnter()
	local searchInput = StringManager.trim(inv_search_input.getValue()):lower();

	if searchInput == "" then
		self.onSearchClear();
	else
		fSearch = function(item)
			local name = ItemManager.getDisplayName(item, true):lower();

			return string.find(name, searchInput);
		end

		self.applySearchAndFilter();
		inv_search_clear_btn.setVisible(true);
	end
end
