-- Please see the LICENSE.txt file included with this distribution for
-- attribution and copyright information.

-- luacheck: globals onSearchClear ct_search_input onSearchEnter ct_search_clear_btn onFilterWP fonFilter
-- luacheck: globals onNewCombatant createControl

fonFilter = '';

function onInit()
	ct_search_input.setValue('');

	if super and super.onInit then super.onInit() end

	if InventoryFiltersManager.hasExtension('Combat-Timer') then
		createControl('combat_timer_new', 'combat_timer');
	end

	ct_search_clear_btn.onButtonPress = onSearchClear;
	ct_search_input.onValueChanged = onSearchEnter;

	fonFilter = parentcontrol.window.list.onFilter;
	parentcontrol.window.list.onFilter = onFilterWP;
	DB.addHandler("combattracker.list", "onChildAdded", onNewCombatant);
end

function onClose()
	if super and super.onClose then super.onClose() end

	DB.removeHandler("combattracker.list", "onChildAdded", onNewCombatant);
end

function onFilterWP(w)
	if fonFilter and not fonFilter(w) then return false end

	local sSearchLower = string.lower(ct_search_input.getValue());
	if sSearchLower == '' then return true end

	local sNameLower;
	if w.name.isVisible() then
		sNameLower = w.name.getValue();
	else
		sNameLower = w.nonid_name.getValue();
	end
	sNameLower = string.lower(sNameLower);

	if string.match(sNameLower, sSearchLower) then return true end
	return false;
end

function onSearchClear()
	ct_search_input.setValue('');
end

function onSearchEnter()
	ct_search_clear_btn.setVisible(ct_search_input.getValue() ~= '');

	parentcontrol.window.list.applyFilter();
end

function onNewCombatant(nodeParent, nodeChildAdded) --luacheck: ignore 212
	onSearchEnter();
end