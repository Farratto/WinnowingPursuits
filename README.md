## FGU Winnowing Pursuits
**Current Version**: ~dev_version~ \
**Updated**: ~date~

This extension adds search and filter controls to
* character inventory
* character actions
* party inventory
* log tab
* combat tracker on host

### Installation

Install from the [Fantasy Grounds Forge](https://forge.fantasygrounds.com/shop/items/177/view). \
You can find the source code at Farratto's [GitHub](https://github.com/Farratto/WinnowingPursuits). \
You can ask questions at the [Fantasy Grounds Forum](https://www.fantasygrounds.com/forums/showthread.php?72835-Winnowing-Pursuits-search-and-filter-your-sheets!).

### Details

Rulesets supported:
* Dungeons and Dragons 3.5 Edition
* Dungeons and Dragons 4th Edition
* Dungeons and Dragons 5th Edition
* Pathfinder Roleplaying Game
* Pathfinder 2nd Edition

Extensions supported:
* Pets
* Floating Tabs
* Extraplanar Containers
* 3.5E/PFRPG Advanced Charsheet
* Combat Groups
* Combat Timer
* Jack of All Things
* Generic Actions
* Capital Gains
* Mad Nomad's Character Sheet Effects Display

### Attribution

Michael Baird is the original author of Winnowing Pursuits.  Farratto has taken over support with permission from the original author and under the MIT license. \
SmiteWorks owns rights to code sections copied from their rulesets by permission for Fantasy Grounds community development. \
'Fantasy Grounds' is a trademark of SmiteWorks USA, LLC. \
'Fantasy Grounds' is Copyright 2004-2021 SmiteWorks USA LLC.

### Change Log

* v2.7.3: FIXED: not recognizing groups with class names in them as spells in 5E ruleset
* v2.7.2: FIXED: nil error on PFRGP/3.5E. FIXED: action filter not reporting correctly. Improved behavior when locking/unlocking character sheet.
* v2.7.1: FIXED: nil error when not loading Capital Gains
* v2.7.0: FIXED: interaction with JoAT items and Generic Actions. FEATURES: now searches Capital Gains fields and Current Effects from Mad Nomad extension. Action, Bonus Action, & Reaction added as filters
* v2.6.2: FIXED: nil errors in some circumstances, filter labels not correct, missing inv filter on non-5E rulesets, filter dropdowns being cutoff.
* v2.6.1: FIXED: for window changes in latest 5E ruleset
* v2.6.0: FEATURE: now searches JoAT item group names. Minor bug FIX.
* v2.5.5: Aesthetic improvement to action search. Bug introduced in 2.5.4: FIXED. Accomodations for Pets extension.
* v2.5.4: Accommodations for latest ruleset changes and new JoAT features. Can now also search Generic Action buttons.
* v2.5.3: Rare bug with WP checking action uses.  FIXED
* v2.5.2: Renewed support for Floating Tabs extension
* v2.5.1: Moved CT Search field for better fit for RFPG2
* v2.5.1: Moved CT Search field for better fit for RFPG2
* v2.5.0: Added search filter to CT and support for Combat Groups and Combat Timer
* v2.4.0: Farratto takes over support. Updated for compatibility of latest version of FGU. Added inventory filters. Added search and filter capabilities to top and bottom of party sheet.
* v2.3.2: Updated for compatibility with FGU 4.4.8
* v2.3.1: Fixed 4E Powers interaction
* v2.3.0:  Compatibility with collapsible containers as provided by [Extraplanar Containers](https://forge.fantasygrounds.com/shop/items/13/view). Winnowing Pursuits will show results for items that are inside collapsed containers, but respect the collapsed state when the search is cleared. Compatibility with [3.5E/PFRPG Advanced Charsheet](https://forge.fantasygrounds.com/shop/items/861/view)
* v2.2.1: Fixed 4E Powers interaction
* v2.2.0: Dynamic power/spell schools, which adds filter options based on discovered schools (thanks **@MeAndUnique**!). Support for PF2 "Concentrate" trait
* v2.1.0: Added exclusive Potion and Scroll inventory filters (thanks **@kevininrussia**!)
* v2.0.1: Resolved adventure logs compatibility when using [Pets](https://forge.fantasygrounds.com/shop/items/1960/view)
* v2.0.0: Renamed extension to **Winnowing Pursuits**. Added search and filters to the actions/powers tab.
* v1.5.0: Added "Inventory Search Filters" section to client options to control visible filter options. Added "Wondrous Item" to 4E Magical filter
* v1.4.2: Fixed 4E Ritual filter
* v1.4.1: Added better support for 4E filters (magic items, ritual, adventuring gear) (thanks **@kevininrussia**!)
* 1.4.0: Added logs search (5E). Compatibility with [FloatingTabs](https://www.fantasygrounds.com/forums/showthread.php?67847-5E-Floating-Character-Sheet-Tabs) (thanks **@ScriedRaven**!). Increased versatility of filters: magical now includes potions, goods and services includes tools and more
* v1.3.0: Added inventory filter (thanks **@daddyogreman**!). Resolved party sheet search sync (thanks **@Trenloe**!). Resolved inventory search sharing input values (thanks **@Trenloe**!).
* v1.2.0: Added party sheet inventory search
* v1.1.0: Added support for PFRPG, PFRPG2, 3.5E, and 4E rulesets.