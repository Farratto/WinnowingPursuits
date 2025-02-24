-- Please see the LICENSE.txt file included with this distribution for
-- attribution and copyright information.

-- luacheck: globals applySearch findLogsList onSearchClear onSearchEnter logs_search_input
-- luacheck: globals logs_search_clear_btn replace createControl

local fSearch;
local bPets;

function onInit()
	if super and super.onInit then super.onInit() end

	--if replace and replace.subwindow and replace.subwindow.logs and
	--	replace.subwindow.logs.subwindow
	--then
	if InventoryFiltersManager.hasExtension('Pets')	then
		bPets = true;
		--replace.setAnchor('bottom', 'bottomanchor', 'bottom', 'current', -60);
		content.setAnchor('bottom', 'bottomanchor', 'bottom', 'current', -60);
		createControl('charsheet_groupbox_bot', 'cs_inv_gb_bot')
		createControl('logs_search_input', 'logs_search_input')
		createControl('button_search_clear', 'logs_search_clear_btn')
	else
		bPets = false;
	end

	if logs_search_input then logs_search_input.setValue('') end
	if logs_search_input then logs_search_input.onEnter = onSearchEnter end
	if logs_search_clear_btn then logs_search_clear_btn.onButtonPress = onSearchClear end
end

function applySearch()
	local list = findLogsList();
	if not list then
		Debug.console("Winnowing Pursuits - logs_search.lua - not list");
		return;
	end

	list.onFilter = function(node)
		return fSearch(node.getDatabaseNode());
	end

	list.applyFilter();
end

function findLogsList()
	local listSubwindow;
	if content and content.subwindow then
		listSubwindow = content.subwindow;
	end
	-- Pets compatibility
	if bPets then
		--listSubwindow = replace.subwindow.logs.subwindow;
		listSubwindow = content.subwindow.logs.subwindow;
	end

	if listSubwindow and listSubwindow.list then return listSubwindow.list end
end

function onSearchClear()
	fSearch = function(_)
		return true;
	end

	self.applySearch();

	logs_search_input.setValue("");
	logs_search_clear_btn.setVisible(false);
end

function onSearchEnter()
	local searchInput = StringManager.trim(logs_search_input.getValue()):lower();

	if searchInput == "" then
		self.onSearchClear();
	else
		fSearch = function(item)
			local sText = DB.getValue(item, "text", ""):lower();

			return string.find(sText, searchInput);
		end
	end

	self.applySearch();
	logs_search_clear_btn.setVisible(true);
end
