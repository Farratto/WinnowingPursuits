-- Please see the LICENSE.txt file included with this distribution for
-- attribution and copyright information.

-- luacheck: globals applySearch findLogsList onSearchClear onSearchEnter logs_search_input logs_search_clear_btn

local fSearch;

function onInit()
	if super and super.onInit then
		super.onInit();
	end

	logs_search_input.setValue("");
	logs_search_input.onEnter = onSearchEnter;
	logs_search_clear_btn.onButtonPress = onSearchClear;
end

function applySearch()
	local list = findLogsList();

	list.onFilter = function(node)
		return fSearch(node.getDatabaseNode());
	end

	list.applyFilter();
end

function findLogsList()
	local listSubwindow = content.subwindow;

	-- Friend Zone compatibility
	if content.subwindow.logs ~= nil then
		listSubwindow = content.subwindow.logs.subwindow;
	end

	return listSubwindow.list;
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
