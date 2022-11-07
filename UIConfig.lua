--------------------------------------------------------------------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------------------------------------------------------------------
local NS = select( 2, ... );
local L = NS.localization;
--------------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG
--------------------------------------------------------------------------------------------------------------------------------------------
NS.UI.cfg = {
	--
	mainFrame = {
		width		= 469,
		height		= 496,
		frameStrata	= "MEDIUM",
		frameLevel	= "TOP",
		Init		= function( MainFrame ) end,
		OnShow		= function( MainFrame )
			MainFrame:Reposition();
		end,
		OnHide		= function( MainFrame )
			local parentName = MainFrame:GetParent():GetName();
			if parentName == "TradeSkillFrame" or parentName == "TSMCraftingTradeSkillFrame" or parentName == "SkilletFrame" then
				MainFrame:SetParent( UIParent ); -- Remove from TradeSkillFrame, TSMCraftingTradeSkillFrame, SkilletFrame
				MainFrame:Hide();
			end
			StaticPopup_Hide( "PC_CHARACTER_DELETE" );
			StaticPopup_Hide( "PC_COOLDOWN_DELETE" );
			StaticPopup_Hide( "PC_COOLDOWNS_IMPORT" );
			StaticPopup_Hide( "PC_COOLDOWNS_DEFAULTS" );
			StaticPopup_Hide( "PC_COOLDOWNS_EXPORT" );
		end,
		Reposition = function( MainFrame )
			MainFrame:ClearAllPoints();
			local parentName = MainFrame:GetParent():GetName();
			if parentName == "TradeSkillFrame" then
				MainFrame:SetPoint( "LEFT", "$parent", "RIGHT", 0, 0 ); -- TradeSkillFrame
			elseif parentName == "TSMCraftingTradeSkillFrame" or parentName == "SkilletFrame" then
				MainFrame:SetPoint( "TOPLEFT", "$parent", "TOPRIGHT", 0, 0 ); -- SkilletFrame
			else
				MainFrame:SetPoint( "CENTER", 0, 0 ); -- UIParent
			end
		end,
	},
	--
	subFrameTabs = {
		{
			-- Monitor
			mainFrameTitle	= NS.title,
			tabText			= L["Monitor"],
			Init			= function( SubFrame )
				NS.Button( "NameColumnHeaderButton", SubFrame, NAME, {
					template = "PCColumnHeaderButtonTemplate",
					size = { ( 152 + 8 ), 19 },
					setPoint = { "TOPLEFT", "$parent", "TOPLEFT", -2, 0 },
				} );
				NS.Button( "CooldownsColumnHeaderButton", SubFrame, "" .. L["Cooldowns"], {
					template = "PCColumnHeaderButtonTemplate",
					size = { 266, 19 },
					setPoint = { "TOPLEFT", "#sibling", "TOPRIGHT", -2, 0 },
				} );
				local function CooldownButton_OnClick( CooldownButton, buttonClicked, skillLine, spellName, spellID )
					if ( ( not TradeSkillFrame or not TradeSkillFrame:IsShown() ) and ( not TSMCraftingTradeSkillFrame or not TSMCraftingTradeSkillFrame:IsShown() ) and ( not SkilletFrame or not SkilletFrame:IsShown() ) ) or C_TradeSkillUI.IsTradeSkillLinked() or C_TradeSkillUI.IsTradeSkillGuild() or skillLine ~= select( 6, C_TradeSkillUI.GetTradeSkillLine() ) then
						CastSpellByName( NS.professionInfo[skillLine].name ); -- Open required TradeSkillFrame. Not having the profession causes no effect
						C_Timer.After( 0.01, function()
							if GetMouseFocus() == CooldownButton then
								CooldownButton:GetScript( "OnEnter" )( CooldownButton ); -- Updates tooltip - I had to delay this in patch 8.0.1 because a newly opened TradeSkill wasn't being reflected fast enough.
							end
						end );
					elseif C_TradeSkillUI.IsTradeSkillReady() then
						local recipeInfo = C_TradeSkillUI.GetRecipeInfo( spellID );
						if not recipeInfo or not recipeInfo.learned then
							NS.Print( RED_FONT_COLOR_CODE .. string.format( L["%s spell %s (%d) not found"], NS.professionInfo[skillLine].name, spellName, spellID ) .. FONT_COLOR_CODE_CLOSE );
						else
							if TradeSkillFrame and TradeSkillFrame:IsShown() then -- Select recipe if using TradeSkillFrame
								TradeSkillFrame.RecipeList:OnLearnedTabClicked(); -- Learned Tab
								if not TradeSkillFrame.RecipeList:IsRecipeInCurrentList( spellID ) then
									-- Expand Categories
									TradeSkillFrame.RecipeList.collapsedCategories = {};
									-- Clear "Search"
									C_TradeSkillUI.SetRecipeItemNameFilter( "" );
									C_TradeSkillUI.SetRecipeItemLevelFilter( 0, 0 );
									TradeSkillFrame.SearchBox:SetText( "" );
									TradeSkillFrame.SearchBox:ClearFocus();
									-- Clear "Filter"
									C_TradeSkillUI.SetOnlyShowMakeableRecipes( false ); -- Clear "Have Materials" filter
									C_TradeSkillUI.SetOnlyShowSkillUpRecipes( false ); -- Clear "Has skill up" filter
									C_TradeSkillUI.ClearInventorySlotFilter(); -- Clear "Slots" filter
									C_TradeSkillUI.ClearRecipeCategoryFilter(); -- Clear "Category" filter
									C_TradeSkillUI.ClearRecipeSourceTypeFilter(); -- Clear "Sources" filter
									CloseDropDownMenus();
									-- Try to select shortly after clear and expand
									C_Timer.After( 0.10, function() TradeSkillFrame.RecipeList:SetSelectedRecipeID( spellID ); end );
								else
									TradeSkillFrame.RecipeList:SetSelectedRecipeID( spellID );
								end
							end
							if buttonClicked == "LeftButton" then
								-- "LeftButton"
								C_TradeSkillUI.CraftRecipe( spellID, 1 ); -- Create
							else
								-- "RightButton"
								C_TradeSkillUI.CraftRecipe( spellID, recipeInfo.numAvailable ); -- Create All
							end
						end
					end
				end
				NS.ScrollFrame( "ScrollFrame", SubFrame, {
					size = { 422, ( 30 * 12 - 5 ) },
					setPoint = { "TOPLEFT", "$parentNameColumnHeaderButton", "BOTTOMLEFT", 1, -3 },
					buttonTemplate = "PCMonitorTabScrollFrameButtonTemplate",
					update = {
						numToDisplay = 12, -- Default, will be reset on update
						buttonHeight = 30, -- Default, will be reset on update
						alwaysShowScrollBar = true,
						UpdateFunction = function( sf )
							local numToDisplayMax = 12; -- Allows hiding all unused buttons when switching to 2 rows of cooldowns
							local cdNumMax = 16; -- 2 rows of 8 cooldowns
							sf.numToDisplay = 12; -- Reset to default for 1 row of cooldowns
							sf.buttonHeight = 30; -- Reset to default for 1 row of cooldowns
							NS.notReady = 0;
							NS.ready = 0;
							local currentTime = time(); -- Time used in cooldown status calculation
							-- Count Ready/NotReady and add characters monitoring at least one cooldown into items for ScrollFrame
							local items = {};
							for _,char in ipairs( NS.db["characters"] ) do
								local monitoring = 0; -- Init monitoring count
								local passedTime = currentTime - char["updateTime"]; -- Time passed since character's last update
								-- Professions
								for i = 1, 2 do
									if char["professions"][i] then -- Can be nil if character doesn't have profession 1 or 2
										for _,cd in ipairs( NS.db["cooldowns"][char["professions"][i]["skillLine"]] ) do -- Pull from global cooldowns
											if char["professions"][i]["cooldowns"][cd.spellID] and char["monitor"][cd.spellID] then -- Was cooldown known to character on last update and being monitored?
												monitoring = monitoring + 1;
												local status = char["professions"][i]["cooldowns"][cd.spellID] > passedTime and "NotReady" or "Ready";
												if status == "NotReady" then
													NS.notReady = NS.notReady + 1;
												else
													NS.ready = NS.ready + 1;
												end
											end
										end
									end
								end
								-- Monitoring?
								if monitoring > 0 then
									if char["name"] == NS.currentCharacter.name then
										-- Force current character to beginning of items
										local t = { char };
										for i = 1, #items do
											t[#t + 1] = items[i];
										end
										items = t;
									else
										table.insert( items, char );
									end
									-- Activate 2nd row of cooldowns
									if monitoring > 8 then
										sf.numToDisplay = 6;
										sf.buttonHeight = 60;
									end
								end
							end
							local numItems = #items;
							local sfn = SubFrame:GetName();
							FauxScrollFrame_Update( sf, numItems, sf.numToDisplay, sf.buttonHeight, nil, nil, nil, nil, nil, nil, sf.alwaysShowScrollBar );
							local offset = FauxScrollFrame_GetOffset( sf );
							for num = 1, numToDisplayMax do
								local bn = sf.buttonName .. num; -- button name
								local b = _G[bn]; -- button
								local k = offset + num; -- key
								--
								b:SetHeight( sf.buttonHeight ); -- Adjust for 1 or 2 rows of cooldowns
								_G[bn .. "Cooldowns"]:SetHeight( sf.buttonHeight ); -- Adjust for 1 or 2 rows of cooldowns
								--
								b:UnlockHighlight();
								--
								if num <= sf.numToDisplay and k <= numItems then
									local CooldownButton_OnEnter = function( self, text, skillLine )
										GameTooltip:SetOwner( self, "ANCHOR_RIGHT" );
										GameTooltip:SetText( text );
										if skillLine then
											local line = "";
											if ( ( not TradeSkillFrame or not TradeSkillFrame:IsShown() ) and ( not TSMCraftingTradeSkillFrame or not TSMCraftingTradeSkillFrame:IsShown() ) and ( not SkilletFrame or not SkilletFrame:IsShown() ) ) or C_TradeSkillUI.IsTradeSkillLinked() or C_TradeSkillUI.IsTradeSkillGuild() or skillLine ~= select( 6, C_TradeSkillUI.GetTradeSkillLine() ) then
												line = string.format( L["Click to open %s"], NS.professionInfo[skillLine].name );
											else
												line = L["Click to Create"];
											end
											GameTooltip:AddLine( HIGHLIGHT_FONT_COLOR_CODE .. line .. FONT_COLOR_CODE_CLOSE );
										end
										GameTooltip:Show();
										b:LockHighlight();
									end
									local OnLeave = function( self )
										GameTooltip_Hide();
										b:UnlockHighlight();
									end
									-- Character: Button
									_G[bn .. "CharacterText"]:SetText( ( items[k]["name"] == NS.currentCharacter.name and "|TInterface\\FriendsFrame\\StatusIcon-Online:16:16:-2:-1|t" or "" ) .. items[k]["classColorCode"] .. ( NS.db["showCharacterRealms"] and items[k]["name"] or strsplit( "-", items[k]["name"], 2 ) ) .. FONT_COLOR_CODE_CLOSE );
									_G[bn .. "Character"]:SetScript( "OnClick", function()
										NS.selectedCharacterKey = NS.FindKeyByField( NS.db["characters"], "name", items[k]["name"] ); -- Set clicked character to selected
										NS.UI.MainFrame:ShowTab( 2 ); -- Characters Tab
									end );
									_G[bn .. "Character"]:SetScript( "OnEnter", function() b:LockHighlight(); end );
									_G[bn .. "Character"]:SetScript( "OnLeave", OnLeave );
									-- Cooldowns: Professions
									local cdNum = 0;
									local cdNumNotReady = 0;
									local cdNumReady = 0;
									local passedTime = currentTime - items[k]["updateTime"]; -- Time passed since character's last update
									for i = 1, 2 do
										if items[k]["professions"][i] then -- Can be nil if character doesn't have profession 1 or 2
											for _,cd in ipairs( NS.db["cooldowns"][items[k]["professions"][i]["skillLine"]] ) do -- Pull from global cooldowns
												if items[k]["professions"][i]["cooldowns"][cd.spellID] and items[k]["monitor"][cd.spellID] then -- Was cooldown known to character on last update and being monitored?
													if cdNum == cdNumMax then
														break; -- Stop, max cooldowns
													else
														cdNum = cdNum + 1; -- Continue, add cooldown
													end
													-- Button
													_G[bn .. "Cooldowns" .. cdNum]:SetNormalTexture( cd.icon );
													if items[k]["name"] == NS.currentCharacter.name then
														_G[bn .. "Cooldowns" .. cdNum]:RegisterForClicks( "LeftButtonUp", "RightButtonUp" );
														_G[bn .. "Cooldowns" .. cdNum]:SetScript( "OnClick", function( self, buttonClicked ) CooldownButton_OnClick( self, buttonClicked, items[k]["professions"][i]["skillLine"], cd.name, cd.spellID ); end );
													else
														_G[bn .. "Cooldowns" .. cdNum]:SetScript( "OnClick", nil );
													end
													_G[bn .. "Cooldowns" .. cdNum]:SetScript( "OnEnter", function( self ) CooldownButton_OnEnter( self, cd.name, self:GetScript( "OnClick" ) and items[k]["professions"][i]["skillLine"] or nil ); end );
													_G[bn .. "Cooldowns" .. cdNum]:SetScript( "OnLeave", OnLeave );
													-- Status Overlay
													local status = items[k]["professions"][i]["cooldowns"][cd.spellID] > passedTime and "NotReady" or "Ready";
													if status == "NotReady" then
														cdNumNotReady = cdNumNotReady + 1;
													else
														cdNumReady = cdNumReady + 1;
													end
													_G[bn .. "Cooldowns" .. cdNum .. "Status"]:SetTexture( "Interface\\RAIDFRAME\\ReadyCheck-" .. status );
													--
													_G[bn .. "Cooldowns" .. cdNum]:Show();
													_G[bn .. "Cooldowns" .. cdNum]:Enable();
												end
											end
										end
									end
									-- HighlightBar (BG) Color
									if cdNum == cdNumNotReady then
										_G[bn .. "BG"]:SetTexture( "Interface\\Addons\\" .. NS.addon .. "\\HighlightBar-Red" );
									elseif cdNum == cdNumReady then
										_G[bn .. "BG"]:SetTexture( "Interface\\Addons\\" .. NS.addon .. "\\HighlightBar-Green" );
									else
										_G[bn .. "BG"]:SetTexture( "Interface\\Addons\\" .. NS.addon .. "\\HighlightBar-Orange" );
									end
									-- Cooldowns: Hide unused cooldown buttons up to max
									for cdNum = ( cdNum + 1 ), cdNumMax do
										_G[bn .. "Cooldowns" .. cdNum]:Hide();
										_G[bn .. "Cooldowns" .. cdNum]:Disable();
									end
									--
									b:Show();
								else
									b:Hide();
								end
							end
							-- Message When Empty
							if numItems == 0 then
								_G[SubFrame:GetName() .. "MessageWhenEmptyText"]:Show();
							else
								_G[SubFrame:GetName() .. "MessageWhenEmptyText"]:Hide();
							end
						end
					},
				} );
				NS.TextFrame( "MessageWhenEmpty", SubFrame, L["There are no cooldowns being monitored.\n\nYou can select cooldowns to\nmonitor on the Characters tab."], {
					setPoint = {
						{ "TOPLEFT", "$parentScrollFrame", "TOPLEFT", 0, 0 },
						{ "BOTTOMRIGHT", "$parentScrollFrame", "BOTTOMRIGHT", 0, 120 },
					},
					fontObject = "GameFontNormalLarge",
					justifyH = "CENTER",
					justifyV = "CENTER",
				} );
				NS.TextFrame( "Footer", SubFrame, "", {
					size = { 450, 16 },
					setPoint = { "BOTTOM", "$parent", "BOTTOM", 0, 20 },
					justifyH = "CENTER",
				} );
			end,
			Refresh			= function( SubFrame )
				local sfn = SubFrame:GetName();
				--
				_G[sfn .. "ScrollFrame"]:Reset();
				_G[sfn .. "FooterText"]:SetText(
					string.format( L["Reset: %s%s|r"], HIGHLIGHT_FONT_COLOR_CODE, NS.SecondsToStrTime( GetQuestResetTime() ) ) .. "     " ..
					string.format( L["|TInterface\\RAIDFRAME\\ReadyCheck-Ready:16|t Ready: %s%d|r     |TInterface\\RAIDFRAME\\ReadyCheck-NotReady:16|t NotReady: %s%d|r"], HIGHLIGHT_FONT_COLOR_CODE, NS.ready, HIGHLIGHT_FONT_COLOR_CODE, NS.notReady )
				);
			end,
		},
		{
			-- Characters
			mainFrameTitle	= NS.title,
			tabText			= L["Characters"],
			Init			= function( SubFrame )
				NS.TextFrame( "Character", SubFrame, L["Character:"], {
					size = { 67, 16 },
					setPoint = { "TOPLEFT", "$parent", "TOPLEFT", 8, -8 },
				} );
				NS.DropDownMenu( "CharacterDropDownMenu", SubFrame, {
					setPoint = { "LEFT", "#sibling", "RIGHT", -12, -1 },
					buttons = function()
						local t = {};
						for ck,c in ipairs( NS.db["characters"] ) do
							local cn = NS.db["showCharacterRealms"] and c["name"] or strsplit( "-", c["name"], 2 );
							tinsert( t, { cn, ck } );
						end
						return t;
					end,
					OnClick = function( info )
						NS.selectedCharacterKey = info.value;
						SubFrame:Refresh();
					end,
					width = 190,
				} );
				NS.TextFrame( "MonitoredNum", SubFrame, "", {
					size = { 122, 20 },
					setPoint = { "LEFT", "#sibling", "RIGHT", -6, 0 },
					fontObject = "GameFontHighlight",
					justifyH = "RIGHT",
				} );
				local function CharactersTabNumMonitored()
					local numMonitored,numTotal = 0,0;
					for i = 1, #NS.charactersTabItems do
						if NS.db["characters"][NS.selectedCharacterKey]["monitor"][NS.charactersTabItems[i].key] then
							numMonitored = numMonitored + 1;
						end
						numTotal = numTotal + 1;
					end
					return numMonitored,numTotal;
				end
				NS.ScrollFrame( "ScrollFrame", SubFrame, {
					size = { 422, ( 30 * 12 - 5 ) },
					setPoint = { "TOPLEFT", "$parent", "TOPLEFT", -1, -37 },
					buttonTemplate = "PCCharactersTabScrollFrameButtonTemplate",
					update = {
						numToDisplay = 12,
						buttonHeight = 30,
						alwaysShowScrollBar = true,
						UpdateFunction = function( sf )
							local items = NS.charactersTabItems;
							local numItems = #items;
							FauxScrollFrame_Update( sf, numItems, sf.numToDisplay, sf.buttonHeight, nil, nil, nil, nil, nil, nil, sf.alwaysShowScrollBar );
							local offset = FauxScrollFrame_GetOffset( sf );
							local numMonitored = CharactersTabNumMonitored();
							local numMonitoredMax = 16; -- cdNumMax
							for num = 1, sf.numToDisplay do
								local k = offset + num; -- key
								local bn = sf.buttonName .. num; -- button name
								local b = _G[bn]; -- button
								local c = _G[bn .. "_Check"]; -- check
								b:UnlockHighlight();
								if k <= numItems then
									b:SetScript( "OnClick", function() c:Click(); end );
									_G[bn .. "_IconTexture"]:SetNormalTexture( items[k].icon );
									_G[bn .. "_IconTexture"]:SetScript( "OnClick", function() c:Click(); end );
									_G[bn .. "_IconTexture"]:SetScript( "OnEnter", function( self )
										if items[k].link then
											GameTooltip:SetOwner( self, "ANCHOR_RIGHT" );
											GameTooltip:SetHyperlink( items[k].link );
										end
										b:LockHighlight();
									end );
									_G[bn .. "_IconTexture"]:SetScript( "OnLeave", function() GameTooltip_Hide(); b:UnlockHighlight(); end );
									_G[bn .. "_NameText"]:SetText( items[k].name );
									c:SetChecked( NS.db["characters"][NS.selectedCharacterKey]["monitor"][items[k].key] );
									c:SetScript( "OnClick", function()
										NS.db["characters"][NS.selectedCharacterKey]["monitor"][items[k].key] = c:GetChecked();
										_G[SubFrame:GetName() .. "ScrollFrame"]:Update();
									end );
									--
									b:Show();
								else
									b:Hide();
								end
							end
							-- Monitored: %d+/%d+
							_G[SubFrame:GetName() .. "MonitoredNumText"]:SetText( NORMAL_FONT_COLOR_CODE .. L["Monitored"] .. ": " .. FONT_COLOR_CODE_CLOSE .. numMonitored .. "/" .. numItems );
							-- Many cooldowns, handle it!
							if numMonitored > numMonitoredMax then
								NS.Print( RED_FONT_COLOR_CODE .. string.format( L["%s is monitoring %d cooldowns. Only %d can be shown per character."], NS.db["characters"][NS.selectedCharacterKey]["name"], numMonitored, numMonitoredMax ) .. FONT_COLOR_CODE_CLOSE );
							end
							-- Message When Empty
							if numItems == 0 then
								_G[SubFrame:GetName() .. "MessageWhenEmptyText"]:Show();
							else
								_G[SubFrame:GetName() .. "MessageWhenEmptyText"]:Hide();
							end
						end
					},
				} );
				local function MonitorSetChecks( checked )
					for spellID in pairs( NS.db["characters"][NS.selectedCharacterKey]["monitor"] ) do
						NS.db["characters"][NS.selectedCharacterKey]["monitor"][spellID] = checked;
					end
				end
				NS.TextFrame( "MessageWhenEmpty", SubFrame, L["There are no cooldowns this\ncharacter can currently use.\n\nCheck back when you've learned\nmore spells or added usable cooldowns.\n\nYou can add additional\ncooldowns on the Professions tab."], {
					setPoint = {
						{ "TOPLEFT", "$parentScrollFrame", "TOPLEFT", 0, 0 },
						{ "BOTTOMRIGHT", "$parentScrollFrame", "BOTTOMRIGHT", 0, 120 },
					},
					fontObject = "GameFontNormalLarge",
					justifyH = "CENTER",
					justifyV = "CENTER",
				} );
				NS.Button( "UncheckAllButton", SubFrame, L["Uncheck All"], {
					size = { 110, 22 },
					setPoint = { "BOTTOMRIGHT", "$parent", "BOTTOM", ( -55 - 8 ), 8 },
					OnClick = function()
						MonitorSetChecks( false );
						_G[SubFrame:GetName() .. "ScrollFrame"]:Update();
					end,
				} );
				NS.Button( "DeleteCharacterButton", SubFrame, L["Delete"], {
					size = { 110, 22 },
					setPoint = { "BOTTOM", "$parent", "BOTTOM", 0, 8 },
					OnClick = function()
						StaticPopup_Show( "PC_CHARACTER_DELETE", NS.db["characters"][NS.selectedCharacterKey]["name"], nil, { ["ck"] = NS.selectedCharacterKey, ["name"] = NS.db["characters"][NS.selectedCharacterKey]["name"] } );
					end,
				} );
				NS.Button( "CheckAllButton", SubFrame, L["Check All"], {
					size = { 110, 22 },
					setPoint = { "BOTTOMLEFT", "$parent", "BOTTOM", ( 55 + 8 ), 8 },
					OnClick = function()
						MonitorSetChecks( true );
						_G[SubFrame:GetName() .. "ScrollFrame"]:Update();
					end,
				} );
				StaticPopupDialogs["PC_CHARACTER_DELETE"] = {
					text = L["Delete character? %s"];
					button1 = YES,
					button2 = NO,
					OnAccept = function ( self, data )
						if data["ck"] == NS.currentCharacter.key then return end
						-- Delete
						table.remove( NS.db["characters"], data["ck"] );
						NS.Print( RED_FONT_COLOR_CODE .. string.format( L["%s deleted"], data["name"] ) .. FONT_COLOR_CODE_CLOSE );
						-- Reset keys (Exactly like initialize)
						NS.currentCharacter.key = NS.FindKeyByName( NS.db["characters"], NS.currentCharacter.name ); -- Must be reset when a character is deleted because the keys shift up one
						NS.selectedCharacterKey = NS.currentCharacter.key; -- Sets selected character to current character
						-- Refresh
						SubFrame:Refresh();
					end,
					OnCancel = function ( self ) end,
					OnShow = function ( self, data )
						if data["name"] == NS.currentCharacter.name then
							NS.Print( RED_FONT_COLOR_CODE .. L["You cannot delete the current character"] .. FONT_COLOR_CODE_CLOSE );
							self:Hide();
						end
					end,
					showAlert = 1,
					hideOnEscape = 1,
					timeout = 0,
					exclusive = 1,
					whileDead = 1,
				};
			end,
			Refresh			= function( SubFrame )
				local sfn = SubFrame:GetName();
				_G[sfn .. "CharacterDropDownMenu"]:Reset( NS.selectedCharacterKey );
				-- Merge cooldowns from both professions into items for ScrollFrame
				wipe( NS.charactersTabItems );
				for i = 1, 2 do
					if NS.db["characters"][NS.selectedCharacterKey]["professions"][i] then -- Can be nil if character doesn't have profession 1 or 2
						for _,cd in ipairs( NS.db["cooldowns"][NS.db["characters"][NS.selectedCharacterKey]["professions"][i]["skillLine"]] ) do -- Pull from global cooldowns
							if NS.db["characters"][NS.selectedCharacterKey]["professions"][i]["cooldowns"][cd.spellID] then -- Only add cooldowns known to selected character on their last update
								table.insert( NS.charactersTabItems, { key = cd.spellID, name = cd.name, icon = cd.icon, link = GetSpellLink( cd.spellID ) } );
							end
						end
					end
				end
				--
				_G[sfn .. "ScrollFrame"]:Reset();
			end,
		},
		{
			-- Professions
			mainFrameTitle	= NS.title,
			tabText			= L["Professions"],
			Init			= function( SubFrame )
				NS.TextFrame( "Profession", SubFrame, L["Profession:"], {
					size = { 72, 16 },
					setPoint = { "TOPLEFT", "$parent", "TOPLEFT", 8, -8 },
				} );
				-- Create profession names drop down buttons A-Z
				local professionDropDownMenuButtons = {};
				for skillLine,profession in pairs( NS.professionInfo ) do
					tinsert( professionDropDownMenuButtons, { profession.name, skillLine } );
				end
				NS.Sort( professionDropDownMenuButtons, 1, "ASC" );
				NS.selectedSkillLine = professionDropDownMenuButtons[1][2]; -- First button selected
				NS.DropDownMenu( "ProfessionDropDownMenu", SubFrame, {
					setPoint = { "LEFT", "#sibling", "RIGHT", -12, -1 },
					buttons = professionDropDownMenuButtons,
					OnClick = function( info )
						NS.selectedSkillLine = info.value;
						_G[SubFrame:GetName() .. "ScrollFrame"]:Update();
					end,
					width = 185,
				} );
				NS.TextFrame( "CooldownsNum", SubFrame, "", {
					size = { 122, 20 },
					setPoint = { "LEFT", "#sibling", "RIGHT", -6, 0 },
					fontObject = "GameFontHighlight",
					justifyH = "RIGHT",
				} );
				NS.ScrollFrame( "ScrollFrame", SubFrame, {
					size = { 422, ( 30 * 12 - 5 ) },
					setPoint = { "TOPLEFT", "$parent", "TOPLEFT", -1, -37 },
					buttonTemplate = "PCProfessionsTabScrollFrameButtonTemplate",
					update = {
						numToDisplay = 12,
						buttonHeight = 30,
						alwaysShowScrollBar = true,
						UpdateFunction = function( sf )
							local items = NS.db["cooldowns"][NS.selectedSkillLine]; -- Items are cooldowns for selected profession
							local numItems = #items;
							FauxScrollFrame_Update( sf, numItems, sf.numToDisplay, sf.buttonHeight, nil, nil, nil, nil, nil, nil, sf.alwaysShowScrollBar );
							local offset = FauxScrollFrame_GetOffset( sf );
							for num = 1, sf.numToDisplay do
								local k = offset + num; -- key
								local bn = sf.buttonName .. num; -- button name
								local b = _G[bn]; -- button
								b:UnlockHighlight();
								if k <= numItems then
									_G[bn .. "_IconTexture"]:SetNormalTexture( items[k].icon );
									_G[bn .. "_IconTexture"]:SetScript( "OnEnter", function( self )
										GameTooltip:SetOwner( self, "ANCHOR_RIGHT" );
										GameTooltip:SetHyperlink( GetSpellLink( items[k].spellID ) );
										b:LockHighlight();
									end );
									_G[bn .. "_IconTexture"]:SetScript( "OnLeave", function() GameTooltip_Hide(); b:UnlockHighlight(); end );
									_G[bn .. "_NameText"]:SetText( items[k].name );
									_G[bn .. "_ImportStringText"]:SetText( items[k].spellID .. ":" .. items[k].itemID );
									_G[bn .. "_DeleteButton"]:SetScript( "OnClick", function() StaticPopup_Show( "PC_COOLDOWN_DELETE", items[k].name, nil, { ["skillLine"] = NS.selectedSkillLine, ["spellID"] = items[k].spellID } ); end );
									--
									b:Show();
								else
									b:Hide();
								end
							end
							-- Cooldowns: %d+
							_G[SubFrame:GetName() .. "CooldownsNumText"]:SetText( NORMAL_FONT_COLOR_CODE .. L["Cooldowns"] .. ": " .. FONT_COLOR_CODE_CLOSE .. numItems );
							-- Message When Empty
							if numItems == 0 then
								_G[SubFrame:GetName() .. "MessageWhenEmptyText"]:Show();
							else
								_G[SubFrame:GetName() .. "MessageWhenEmptyText"]:Hide();
							end
						end
					},
				} );
				NS.TextFrame( "MessageWhenEmpty", SubFrame, L["There are no cooldowns for this profession.\n\nYou can add additional\ncooldowns using Import.\n\nOr\n\nRestore the default cooldowns using Defaults."], {
					setPoint = {
						{ "TOPLEFT", "$parentScrollFrame", "TOPLEFT", 0, 0 },
						{ "BOTTOMRIGHT", "$parentScrollFrame", "BOTTOMRIGHT", 0, 120 },
					},
					fontObject = "GameFontNormalLarge",
					justifyH = "CENTER",
					justifyV = "CENTER",
				} );
				NS.Button( "ImportButton", SubFrame, L["Import"], {
					size = { 110, 22 },
					setPoint = { "BOTTOMRIGHT", "$parent", "BOTTOM", ( -55 - 8 ), 8 },
					OnClick = function()
						StaticPopup_Show( "PC_COOLDOWNS_IMPORT", NS.professionInfo[NS.selectedSkillLine].name, nil, { ["skillLine"] = NS.selectedSkillLine } );
					end,
				} );
				NS.Button( "DefaultsButton", SubFrame, L["Defaults"], {
					size = { 110, 22 },
					setPoint = { "BOTTOM", "$parent", "BOTTOM", 0, 8 },
					OnClick = function()
						StaticPopup_Show( "PC_COOLDOWNS_DEFAULTS", nil, nil, { ["skillLine"] = NS.selectedSkillLine } );
					end,
				} );
				NS.Button( "ExportButton", SubFrame, L["Export"], {
					size = { 110, 22 },
					setPoint = { "BOTTOMLEFT", "$parent", "BOTTOM", ( 55 + 8 ), 8 },
					OnClick = function()
						StaticPopup_Show( "PC_COOLDOWNS_EXPORT", NS.professionInfo[NS.selectedSkillLine].name, nil, { ["skillLine"] = NS.selectedSkillLine } );
					end,
				} );
				local function ImportCooldowns( importString, data )
					importString = strtrim( importString );
					if importString == "" then return end -- Ignore empty string
					--
					_G[SubFrame:GetName() .. "ImportButton"]:Disable();
					local cooldowns = NS.Explode( ",", importString );
					local cooldownsInvalid,importedTotal = {}, 0;
					local spellID,itemID,cooldownNum,NextCooldown,CompleteCooldown;
					--
					NextCooldown = function()
						if cooldownNum <= #cooldowns then
							spellID,itemID = nil,nil;
							--
							if string.find( cooldowns[cooldownNum], "^%d+:%d+$" ) then
								spellID,itemID = strsplit( ":", cooldowns[cooldownNum] );
							end
							--
							return CompleteCooldown();
						else
							-- ALL ITEMS COMPLETE
							NS.Print( string.format( L["%d of %d cooldowns imported to %s"], importedTotal, #cooldowns, NS.professionInfo[data["skillLine"]].name ) );
							if #cooldownsInvalid > 0 then
								NS.Print( string.format( L["%d invalid cooldown(s) not imported:"], #cooldownsInvalid ) );
								for _,invalidCooldown in ipairs( cooldownsInvalid ) do
									NS.Print( RED_FONT_COLOR_CODE .. invalidCooldown .. FONT_COLOR_CODE_CLOSE );
								end
							end
							if importedTotal > 0 and #NS.db["characters"] > 1 then
								NS.Print( RED_FONT_COLOR_CODE .. string.format( L["You must log onto characters with %s to make new cooldowns show up for them."], NS.professionInfo[data["skillLine"]].name ) .. FONT_COLOR_CODE_CLOSE );
							end
							_G[SubFrame:GetName() .. "ScrollFrame"]:Update();
							_G[SubFrame:GetName() .. "ImportButton"]:Enable();
						end
					end
					--
					CompleteCooldown = function()
						if NS.AddCooldown( spellID, itemID, data["skillLine"] ) then
							importedTotal = importedTotal + 1;
						else
							table.insert( cooldownsInvalid, cooldowns[cooldownNum] );
						end
						--
						cooldownNum = cooldownNum + 1;
						return NextCooldown();
					end
					--
					cooldownNum = 1;
					NextCooldown();
				end
				StaticPopupDialogs["PC_COOLDOWN_DELETE"] = {
					text = L["Delete cooldown? %s"];
					button1 = YES,
					button2 = NO,
					OnAccept = function ( self, data )
						local cooldownKey = NS.FindKeyByField( NS.db["cooldowns"][data["skillLine"]], "spellID", data["spellID"] );
						if not cooldownKey then return end
						NS.Print( L["Cooldown deleted"] .. " " .. ( GetSpellLink( data["spellID"] ) or L["Unknown Spell"] ) );
						table.remove( NS.db["cooldowns"][data["skillLine"]], cooldownKey );
						_G[SubFrame:GetName() .. "ScrollFrame"]:Update();
					end,
					OnCancel = function ( self ) end,
					OnShow = function ( self )
						if not NS.db["showDeleteCooldownConfirmDialog"] then
							local OnAccept = StaticPopupDialogs[self.which].OnAccept;
							OnAccept( self, self.data );
							self:Hide();
						end
					end,
					showAlert = 1,
					hideOnEscape = 1,
					timeout = 0,
					exclusive = 1,
					whileDead = 1,
				};
				StaticPopupDialogs["PC_COOLDOWNS_IMPORT"] = {
					text = L["Import cooldown(s) to profession:\n|cffffd200%s|r\n\nColon-delimited cooldown\n|cff82c5ffSpellID:ItemID|r\n\nComma-delimited cooldowns\n|cff82c5ff123456:12345,123456:12345|r\n\n|cffffd200Example|r\nJard's Peculiar Energy Source\n|cff82c5ff139176:94113|r\n|cff1eff00Found in Wowhead URLs\n/spell=139176/ and /item=94113/|r\n"],
					button1 = ACCEPT,
					button2 = CANCEL,
					hasEditBox = 1,
					maxLetters = 0,
					OnAccept = function ( self, data )
						ImportCooldowns( self.editBox:GetText(), data );
						NS.Update(); -- Must update character cooldowns
					end,
					OnCancel = function ( self ) end,
					OnShow = function ( self )
						self.editBox:SetFocus();
					end,
					OnHide = function ( self )
						self.editBox:SetText( "" );
					end,
					EditBoxOnEnterPressed = function ( self, data )
						local parent = self:GetParent();
						ImportCooldowns( parent.editBox:GetText(), data );
						NS.Update(); -- Must update character cooldowns
						parent:Hide();
					end,
					EditBoxOnEscapePressed = function( self )
						self:GetParent():Hide();
					end,
					hideOnEscape = 1,
					timeout = 0,
					exclusive = 1,
					whileDead = 1,
				};
				StaticPopupDialogs["PC_COOLDOWNS_DEFAULTS"] = {
					text = L["Remove all cooldowns you have added and restore the default cooldowns?"];
					button1 = L["This Profession"],
					button2 = CANCEL,
					button3 = L["All Professions"],
					OnAccept = function ( self, data )
						NS.db["cooldowns"][data["skillLine"]] = CopyTable( NS.professionInfo[data["skillLine"]].cooldowns );
						NS.Print( string.format( L["Default cooldowns restored for %s"], NS.professionInfo[data["skillLine"]].name ) );
						if #NS.db["characters"] > 1 then
							NS.Print( RED_FONT_COLOR_CODE .. string.format( L["You must log onto characters with %s to make new cooldowns show up for them."], NS.professionInfo[data["skillLine"]].name ) .. FONT_COLOR_CODE_CLOSE );
						end
						_G[SubFrame:GetName() .. "ScrollFrame"]:Update();
						NS.Update(); -- Must update character cooldowns
					end,
					OnCancel = function ( self ) end,
					OnAlt = function( self, data )
						wipe( NS.db["cooldowns"] );
						for skillLine,profession in pairs( NS.professionInfo ) do
							NS.db["cooldowns"][skillLine] = CopyTable( profession.cooldowns );
						end
						NS.Print( L["Default cooldowns restored for all professions"] );
						if #NS.db["characters"] > 1 then
							NS.Print( RED_FONT_COLOR_CODE .. L["You must log onto a character to make new cooldowns show up for them."] .. FONT_COLOR_CODE_CLOSE );
						end
						_G[SubFrame:GetName() .. "ScrollFrame"]:Update();
						NS.Update(); -- Must update character cooldowns
					end,
					OnShow = function ( self ) end,
					showAlert = 1,
					hideOnEscape = 1,
					timeout = 0,
					exclusive = 1,
					whileDead = 1,
				};
				StaticPopupDialogs["PC_COOLDOWNS_EXPORT"] = {
					text = L["Export cooldown(s) from profession:\n|cffffd200%s|r\n\nColon-delimited cooldown\n|cff82c5ffSpellID:ItemID|r\n\nComma-delimited cooldowns\n|cff82c5ff123456:12345,123456:12345|r\n\n|cffffd200Example|r\nJard's Peculiar Energy Source\n|cff82c5ff139176:94113|r\n"];
					button1 = ACCEPT,
					button2 = CANCEL,
					hasEditBox = 1,
					maxLetters = 0,
					OnAccept = function ( self, data )
						local exportTable = {};
						for _,cooldown in ipairs( NS.db["cooldowns"][data["skillLine"]] ) do
							table.insert( exportTable, strjoin( ":", cooldown["spellID"], cooldown["itemID"] ) );
						end
						local exportString = table.concat( exportTable, "," );
						--
						NS.Print( string.format( L["%d cooldowns exported from %s"], #NS.db["cooldowns"][data["skillLine"]], NS.professionInfo[data["skillLine"]].name ) );
						--
						self.editBox:SetText( exportString );
						self.editBox:SetFocus();
						self.editBox:SetCursorPosition( 0 );
						self.editBox:HighlightText();
						return true; -- Prevents dialog from closing
					end,
					OnCancel = function ( self ) end,
					OnShow = function ( self ) end,
					OnHide = function ( self )
						self.editBox:SetText( "" );
					end,
					EditBoxOnEscapePressed = function( self )
						self:GetParent():Hide();
					end,
					hideOnEscape = 1,
					timeout = 0,
					exclusive = 1,
					whileDead = 1,
				};
			end,
			Refresh			= function( SubFrame )
				local sfn = SubFrame:GetName();
				_G[sfn .. "ProfessionDropDownMenu"]:Reset( NS.selectedSkillLine );
				_G[sfn .. "ScrollFrame"]:Reset();
			end,
		},
		{
			-- Options
			mainFrameTitle	= NS.title,
			tabText			= OPTIONS,
			Init			= function( SubFrame )
				NS.TextFrame( "MiscLabel", SubFrame, L["Miscellaneous"], {
					size = { 100, 16 },
					setPoint = { "TOPLEFT", "$parent", "TOPLEFT", 8, -8 },
				} );
				NS.CheckButton( "OpenWithTradeSKillCheckButton", SubFrame, L["Open With TradeSkill"], {
					setPoint = { "TOPLEFT", "#sibling", "BOTTOMLEFT", 3, -1 },
					tooltip = L["Open and close frame with:\nTradeSkillFrame (Default)\nTSMCraftingTradeSkillFrame\nSkilletFrame\n\nIgnored if Linked or Guild\n\n(Character Specific)"],
					dbpc = "openWithTradeSKill",
				} );
				NS.CheckButton( "ShowMinimapButtonCheckButton", SubFrame, L["Show Minimap Button"], {
					setPoint = { "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -1 },
					tooltip = L["Show or hide the\nbutton on the Minimap"],
					OnClick = function( checked )
						-- LibDBIcon
						NS.db["ldbi"].hide = not checked;
						NS.ldbi:Refresh( NS.addon );
					end,
				} );
				NS.CheckButton( "ShowCharacterRealmsCheckButton", SubFrame, L["Show Character Realms"], {
					setPoint = { "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -1 },
					tooltip = L["Show or hide\ncharacter realms"],
					db = "showCharacterRealms",
				} );
				NS.CheckButton( "ShowDeleteCooldownConfirmDialogCheckButton", SubFrame, L["Show Delete Cooldown Confirmation Dialog"], {
					setPoint = { "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -1 },
					tooltip = L["Confirm before deleting a\ncooldown from a profession."],
					db = "showDeleteCooldownConfirmDialog",
				} );
			end,
			Refresh			= function( SubFrame )
				local sfn = SubFrame:GetName();
				_G[sfn .. "OpenWithTradeSKillCheckButton"]:SetChecked( NS.dbpc["openWithTradeSKill"] );
				_G[sfn .. "ShowMinimapButtonCheckButton"]:SetChecked( not NS.db["ldbi"].hide ); -- LibDBIcon
				_G[sfn .. "ShowCharacterRealmsCheckButton"]:SetChecked( NS.db["showCharacterRealms"] );
				_G[sfn .. "ShowDeleteCooldownConfirmDialogCheckButton"]:SetChecked( NS.db["showDeleteCooldownConfirmDialog"] );
			end,
		},
		{
			-- Help
			mainFrameTitle	= NS.title,
			tabText			= HELP_LABEL,
			Init			= function( SubFrame )
				NS.TextFrame( "Description", SubFrame, string.format( L["%s version %s for patch %s"], NS.title, NS.versionString, NS.releasePatch ), {
					setPoint = {
						{ "TOPLEFT", "$parent", "TOPLEFT", 8, -8 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontRedSmall",
				} );
				NS.TextFrame( "SlashCommandsHeader", SubFrame, string.format( L["%sSlash Commands|r"], BATTLENET_FONT_COLOR_CODE ), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -18 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontNormalLarge",
				} );
				NS.TextFrame( "SlashCommands", SubFrame, string.format( L["%s/pc|r - Open and close this frame"], NORMAL_FONT_COLOR_CODE ), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -8 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontHighlight",
				} );
				NS.TextFrame( "GettingStartedHeader", SubFrame, string.format( L["%sGetting Started|r"], BATTLENET_FONT_COLOR_CODE ), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -18 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontNormalLarge",
				} );
				NS.TextFrame( "GettingStarted", SubFrame, string.format(
						L["%s1.|r Login to a character you want to monitor.\n" ..
						"%s2.|r Select Characters tab and check what you want to monitor.\n" ..
						"%s3.|r Repeat 1-2 for all characters you want included in this addon."],
						NORMAL_FONT_COLOR_CODE, NORMAL_FONT_COLOR_CODE, NORMAL_FONT_COLOR_CODE
					), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -8 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontHighlight",
				} );
				NS.TextFrame( "NeedMoreHelpHeader", SubFrame, string.format( L["%sNeed More Help?|r"], BATTLENET_FONT_COLOR_CODE ), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -18 },
						{ "RIGHT", 0 },
					},
					fontObject = "GameFontNormalLarge",
				} );
				NS.TextFrame( "NeedMoreHelp", SubFrame, string.format(
						L["%sQuestions, Comments, Bugs, and Suggestions|r\n\n" ..
						"https://www.curseforge.com/wow/addons/professions-complete"],
						NORMAL_FONT_COLOR_CODE
					), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -8 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontHighlight",
				} );
			end,
			Refresh			= function( SubFrame ) return end,
		},
	},
};
