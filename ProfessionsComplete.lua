--------------------------------------------------------------------------------------------------------------------------------------------
-- Initialize Variables
--------------------------------------------------------------------------------------------------------------------------------------------
local NS = select( 2, ... );
local L = NS.localization;
NS.releasePatch = "8.3.5";
NS.versionString = "3.0";
NS.version = tonumber( NS.versionString );
--
NS.initialized = false;
NS.updateRequestTime = nil;
--
NS.selectedCharacterKey = nil;
NS.selectedSkillLine = nil;
NS.charactersTabItems = {};
--
NS.currentCharacter = {
	name = UnitName( "player" ) .. "-" .. GetRealmName(),
	classColorCode = "|c" .. RAID_CLASS_COLORS[select( 2, UnitClass( "player" ) )].colorStr,
	key = nil,
};
--
NS.professionInfo = {
	-- Alchemy
	[171] = { name = GetSpellInfo( 2259 ),
		cooldowns = {
			-- Alchemy Transmutes that SHARE 1 day CD (reset daily @ DAILY RESET TIME) with others transmutes in all expansions are marked on comments with -> (**shared 1 day CD with others**)
			-- CLASSIC
			-- bar transmutes
			{ spellID = 11479,  name = GetSpellInfo( 11479 ),  itemID = 3577,  icon = GetItemIcon( 3577 )    }, -- Transmute: Iron to Gold (**shared 1 day CD with others**)
			{ spellID = 11480,  name = GetSpellInfo( 11480 ),  itemID = 6037,  icon = GetItemIcon( 6037 )    }, -- Transmute: Mithril to Truesilver (**shared 1 day CD with others**)
			-- essence transmutes
			{ spellID = 17559,  name = GetSpellInfo( 17559 ),  itemID = 7078,  icon = GetItemIcon( 7078 )    }, -- Transmute: Air to Fire (**shared 1 day CD with others**)
			{ spellID = 17560,  name = GetSpellInfo( 17560 ),  itemID = 7076,  icon = GetItemIcon( 7076 )    }, -- Transmute: Fire to Earth (**shared 1 day CD with others**)
			{ spellID = 17561,  name = GetSpellInfo( 17561 ),  itemID = 7080,  icon = GetItemIcon( 7080 )    }, -- Transmute: Earth to Water (**shared 1 day CD with others**)
			{ spellID = 17562,  name = GetSpellInfo( 17562 ),  itemID = 7082,  icon = GetItemIcon( 7082 )    }, -- Transmute: Water to Air (**shared 1 day CD with others**)
			{ spellID = 17563,  name = GetSpellInfo( 17563 ),  itemID = 7080,  icon = GetItemIcon( 7080 )    }, -- Transmute: Undeath to Water (**shared 1 day CD with others**)
			{ spellID = 17564,  name = GetSpellInfo( 17564 ),  itemID = 12808, icon = GetItemIcon( 12808 )   }, -- Transmute: Water to Undeath (**shared 1 day CD with others**)
			{ spellID = 17565,  name = GetSpellInfo( 17565 ),  itemID = 7076,  icon = GetItemIcon( 7076 )    }, -- Transmute: Life to Earth (**shared 1 day CD with others**)
			{ spellID = 17566,  name = GetSpellInfo( 17566 ),  itemID = 12803, icon = GetItemIcon( 12803 )   }, -- Transmute: Earth to Life (**shared 1 day CD with others**)
			-- THE BURNING CRUSADE Expansion
			-- primal transmutes
			{ spellID = 28566,  name = GetSpellInfo( 28566 ),  itemID = 21884,  icon = GetItemIcon( 21884 )  }, -- Transmute: Primal Air to Fire (**shared 1 day CD with others**)
			{ spellID = 28567,  name = GetSpellInfo( 28567 ),  itemID = 21885,  icon = GetItemIcon( 21885 )  }, -- Transmute: Primal Earth to Water (**shared 1 day CD with others**)
			{ spellID = 28568,  name = GetSpellInfo( 28568 ),  itemID = 22452,  icon = GetItemIcon( 22452 )  }, -- Transmute: Primal Fire to Earth (**shared 1 day CD with others**)
			{ spellID = 28569,  name = GetSpellInfo( 28569 ),  itemID = 22451,  icon = GetItemIcon( 22451 )  }, -- Transmute: Primal Water to Air (**shared 1 day CD with others**)
			{ spellID = 28580,  name = GetSpellInfo( 28580 ),  itemID = 21885,  icon = GetItemIcon( 21885 )  }, -- Transmute: Primal Shadow to Water (**shared 1 day CD with others**)
			{ spellID = 28581,  name = GetSpellInfo( 28581 ),  itemID = 22456,  icon = GetItemIcon( 22456 )  }, -- Transmute: Primal Water to Shadow (**shared 1 day CD with others**)
			{ spellID = 28582,  name = GetSpellInfo( 28582 ),  itemID = 21884,  icon = GetItemIcon( 21884 )  }, -- Transmute: Primal Mana to Fire (**shared 1 day CD with others**)
			{ spellID = 28583,  name = GetSpellInfo( 28583 ),  itemID = 22457,  icon = GetItemIcon( 22457 )  }, -- Transmute: Primal Fire to Mana (**shared 1 day CD with others**)
			{ spellID = 28584,  name = GetSpellInfo( 28584 ),  itemID = 22452,  icon = GetItemIcon( 22452 )  }, -- Transmute: Primal Life to Earth (**shared 1 day CD with others**)
			{ spellID = 28585,  name = GetSpellInfo( 28585 ),  itemID = 21886,  icon = GetItemIcon( 21886 )  }, -- Transmute: Primal Earth to Life (**shared 1 day CD with others**)
			-- WRATH OF THE LICH KING
			{ spellID = 60893,  name = GetSpellInfo( 60893 ),  itemID = 115460, icon = GetItemIcon( 115460 ) }, -- Northrend Alchemy Research (3 days CD recipe research)
			-- eternal transmutes
			{ spellID = 53771,  name = GetSpellInfo( 53771 ),  itemID = 35627,  icon = GetItemIcon( 35627 )  }, -- Transmute: Eternal Life to Shadow (**shared 1 day CD with others**)
			{ spellID = 53773,  name = GetSpellInfo( 53773 ),  itemID = 36860,  icon = GetItemIcon( 36860 )  }, -- Transmute: Eternal Life to Fire (**shared 1 day CD with others**)
			{ spellID = 53774,  name = GetSpellInfo( 53774 ),  itemID = 35622,  icon = GetItemIcon( 35622 )  }, -- Transmute: Eternal Fire to Water (**shared 1 day CD with others**)
			{ spellID = 53775,  name = GetSpellInfo( 53775 ),  itemID = 35625,  icon = GetItemIcon( 35625 )  }, -- Transmute: Eternal Fire to Life (**shared 1 day CD with others**)
			{ spellID = 53776,  name = GetSpellInfo( 53776 ),  itemID = 35622,  icon = GetItemIcon( 35622 )  }, -- Transmute: Eternal Air to Water (**shared 1 day CD with others**)
			{ spellID = 53777,  name = GetSpellInfo( 53777 ),  itemID = 35624,  icon = GetItemIcon( 35624 )  }, -- Transmute: Eternal Air to Earth (**shared 1 day CD with others**)
			{ spellID = 53779,  name = GetSpellInfo( 53779 ),  itemID = 35624,  icon = GetItemIcon( 35624 )  }, -- Transmute: Eternal Shadow to Earth (**shared 1 day CD with others**)
			{ spellID = 53780,  name = GetSpellInfo( 53780 ),  itemID = 35625,  icon = GetItemIcon( 35625 )  }, -- Transmute: Eternal Shadow to Life (**shared 1 day CD with others**)
			{ spellID = 53781,  name = GetSpellInfo( 53781 ),  itemID = 35623,  icon = GetItemIcon( 35623 )  }, -- Transmute: Eternal Earth to Air (**shared 1 day CD with others**)
			{ spellID = 53782,  name = GetSpellInfo( 53782 ),  itemID = 35627,  icon = GetItemIcon( 35627 )  }, -- Transmute: Eternal Earth to Shadow (**shared 1 day CD with others**)
			{ spellID = 53783,  name = GetSpellInfo( 53783 ),  itemID = 35623,  icon = GetItemIcon( 35623 )  }, -- Transmute: Eternal Water to Air (**shared 1 day CD with others**)
			{ spellID = 53784,  name = GetSpellInfo( 53784 ),  itemID = 36860,  icon = GetItemIcon( 36860 )  }, -- Transmute: Eternal Water to Fire (**shared 1 day CD with others**)
			-- gem transmutes
			{ spellID = 66658,  name = GetSpellInfo( 66658 ),  itemID = 36931,  icon = GetItemIcon( 36931 )  }, -- Transmute: Ametrine (**shared 1 day CD with others**)
			{ spellID = 66659,  name = GetSpellInfo( 66659 ),  itemID = 36919,  icon = GetItemIcon( 36919 )  }, -- Transmute: Cardinal Ruby (**shared 1 day CD with others**)
			{ spellID = 66660,  name = GetSpellInfo( 66660 ),  itemID = 36922,  icon = GetItemIcon( 36922 )  }, -- Transmute: King's Amber (**shared 1 day CD with others**)
			{ spellID = 66662,  name = GetSpellInfo( 66662 ),  itemID = 36928,  icon = GetItemIcon( 36928 )  }, -- Transmute: Dreadstone (**shared 1 day CD with others**)
			{ spellID = 66663,  name = GetSpellInfo( 66663 ),  itemID = 36925,  icon = GetItemIcon( 36925 )  }, -- Transmute: Majestic Zircon (**shared 1 day CD with others**)
			{ spellID = 66664,  name = GetSpellInfo( 66664 ),  itemID = 36934,  icon = GetItemIcon( 36934 )  }, -- Transmute: Eye of Zul (**shared 1 day CD with others**)
			-- CATACLYSM
			{ spellID = 78866,  name = GetSpellInfo( 78866 ),  itemID = 54464,  icon = GetItemIcon( 54464 )  }, -- Transmute: Living Elements (**shared 1 day CD with others**)
			{ spellID = 80244,  name = GetSpellInfo( 80244 ),  itemID = 51950,  icon = GetItemIcon( 51950 )  }, -- Transmute: Pyrium Bar (**shared 1 day CD with others**)
			-- MISTS OF PANDARIA
			{ spellID = 114780, name = GetSpellInfo( 114780 ), itemID = 72104,  icon = GetItemIcon( 72104 )  }, -- Transmute: Living Steel (**shared 1 day CD with others**)
			-- WARLORDS OF DRAENOR
			{ spellID = 156587, name = GetSpellInfo( 156587 ), itemID = 108996, icon = GetItemIcon( 108996 ) }, -- Alchemical Catalyst
			{ spellID = 175880, name = GetSpellInfo( 175880 ), itemID = 118700, icon = GetItemIcon( 118700 ) }, -- Secrets of Draenor Alchemy
			{ spellID = 181643, name = GetSpellInfo( 181643 ), itemID = 118472, icon = GetItemIcon( 118472 ) }, -- Transmute: Savage Blood (**shared 1 day CD with others**)
			-- LEGION
			{ spellID = 213257, name = GetSpellInfo( 213257 ), itemID = 124124, icon = GetItemIcon( 124124 ) }, -- Transmute: Blood of Sargeras
			{ spellID = 213252, name = GetSpellInfo( 213252 ), itemID = 137593, icon = GetItemIcon( 137593 ) }, -- Transmute: Cloth to Herbs
			{ spellID = 213249, name = GetSpellInfo( 213249 ), itemID = 137591, icon = GetItemIcon( 137591 ) }, -- Transmute: Cloth to Skins
			{ spellID = 213248, name = GetSpellInfo( 213248 ), itemID = 137590, icon = GetItemIcon( 137590 ) }, -- Transmute: Ore to Cloth
			{ spellID = 213251, name = GetSpellInfo( 213251 ), itemID = 137593, icon = GetItemIcon( 137593 ) }, -- Transmute: Ore to Herbs
			{ spellID = 213253, name = GetSpellInfo( 213253 ), itemID = 137593, icon = GetItemIcon( 137593 ) }, -- Transmute: Skins to Herbs
			{ spellID = 213250, name = GetSpellInfo( 213250 ), itemID = 137592, icon = GetItemIcon( 137592 ) }, -- Transmute: Skins to Ore
			{ spellID = 213254, name = GetSpellInfo( 213254 ), itemID = 137594, icon = GetItemIcon( 137594 ) }, -- Transmute: Fish to Gems
			{ spellID = 213255, name = GetSpellInfo( 213255 ), itemID = 137600, icon = GetItemIcon( 137600 ) }, -- Transmute: Meat to Pants
			{ spellID = 213256, name = GetSpellInfo( 213256 ), itemID = 137599, icon = GetItemIcon( 137599 ) }, -- Transmute: Meat to Pet
			--
			{ spellID = 247701, name = GetSpellInfo( 247701 ), itemID = 151568, icon = GetItemIcon( 151568 ) }, -- Transmute: Primal Sargerite
			--
			{ spellID = 188800, name = GetSpellInfo( 188800 ), itemID = 141323, icon = GetItemIcon( 141323 ) }, -- Wild Transmutation Rank 1
			{ spellID = 188801, name = GetSpellInfo( 188801 ), itemID = 141323, icon = GetItemIcon( 141323 ) }, -- Wild Transmutation Rank 2
			{ spellID = 188802, name = GetSpellInfo( 188802 ), itemID = 141323, icon = GetItemIcon( 141323 ) }, -- Wild Transmutation Rank 3
			-- BATTLE FOR AZEROTH
			{ spellID = 251832, name = GetSpellInfo( 251832 ), itemID = 152668, icon = GetItemIcon( 152668 ) }, -- Transmute: Expulsom
			{ spellID = 251822, name = GetSpellInfo( 251822 ), itemID = 152581, icon = GetItemIcon( 152581 ) }, -- Transmute: Fish to Gems
			{ spellID = 251808, name = GetSpellInfo( 251808 ), itemID = 160325, icon = GetItemIcon( 160325 ) }, -- Transmute: Meat to Pet
			{ spellID = 251314, name = GetSpellInfo( 251314 ), itemID = 152582, icon = GetItemIcon( 152582 ) }, -- Transmute: Cloth to Skins
			{ spellID = 251311, name = GetSpellInfo( 251311 ), itemID = 152581, icon = GetItemIcon( 152581 ) }, -- Transmute: Ore to Gems
			{ spellID = 251310, name = GetSpellInfo( 251310 ), itemID = 152580, icon = GetItemIcon( 152580 ) }, -- Transmute: Ore to Cloth
			{ spellID = 251309, name = GetSpellInfo( 251309 ), itemID = 152578, icon = GetItemIcon( 152578 ) }, -- Transmute: Ore to Herbs
			{ spellID = 251306, name = GetSpellInfo( 251306 ), itemID = 152580, icon = GetItemIcon( 152580 ) }, -- Transmute: Herbs to Cloth
			{ spellID = 251305, name = GetSpellInfo( 251305 ), itemID = 160322, icon = GetItemIcon( 160322 ) }, -- Transmute: Herbs to Ore
			{ spellID = 286547, name = GetSpellInfo( 286547 ), itemID = 165851, icon = GetItemIcon( 165851 ) }, -- Transmute: Herbs to Anchors			
		},
	},
	-- Blacksmithing
	[164] = { name = GetSpellInfo( 2018 ),
		cooldowns = {
			-- PANDARIA Expansion
			{ spellID = 143255, name = GetSpellInfo( 143255 ), itemID = 98717,  icon = GetItemIcon( 98717 )  }, -- Balanced Trillium Ingot (1 day CD, also discovery new BS recipes)
			{ spellID = 138646, name = GetSpellInfo( 138646 ), itemID = 94111,  icon = GetItemIcon( 94111 )  }, -- Lightning Steel Ingot (1 day CD, also discovery new BS recipes)
			-- WoD Expansion
			{ spellID = 176090, name = GetSpellInfo( 176090 ), itemID = 118720, icon = GetItemIcon( 118720 ) }, -- Secrets of Draenor Blacksmithing
			{ spellID = 171690, name = GetSpellInfo( 171690 ), itemID = 108257, icon = GetItemIcon( 108257 ) }, -- Truesteel Ingot
		},
	},
	-- Enchanting
	[333] = { name = GetSpellInfo( 7411 ),
		cooldowns = {
			-- CLASSIC Exp (Vanilla Expansion)
			-- Void Sphere and Prismatic Sphere have static 2-day shared CD
			--{ spellID = 28027,  name = GetSpellInfo( 28027 ),  itemID = 22460,  icon = GetItemIcon( 22460 )  }, -- Prismatic Sphere (static 2-day shared CD)
			--{ spellID = 28028,  name = GetSpellInfo( 28028 ),  itemID = 22459,  icon = GetItemIcon( 22459 )  }, -- Void Sphere (static 2-day shared CD)
			-- PANDARIA Expansion
			{ spellID = 116499, name = GetSpellInfo( 116499 ), itemID = 74248,  icon = GetItemIcon( 74248 )  }, -- Sha Crystal
			-- WoD Expansion
			{ spellID = 169092, name = GetSpellInfo( 169092 ), itemID = 113588, icon = GetItemIcon( 113588 ) }, -- Temporal Crystal
			{ spellID = 177043, name = GetSpellInfo( 177043 ), itemID = 119293, icon = GetItemIcon( 119293 ) }, -- Secrets of Draenor Enchanting
		},
	},
	-- Engineering
	[202] = { name = GetSpellInfo( 4036 ),
		cooldowns = {
			-- PANDARIA Expansion
			{ spellID = 139176, name = GetSpellInfo( 139176 ), itemID = 94113,  icon = GetItemIcon( 94113 )  }, -- Jard's Peculiar Energy Source
			-- WoD Expansion
			{ spellID = 169080, name = GetSpellInfo( 169080 ), itemID = 111366, icon = GetItemIcon( 111366 ) }, -- Gearspring Parts
			{ spellID = 177054, name = GetSpellInfo( 177054 ), itemID = 119299, icon = GetItemIcon( 119299 ) }, -- Secrets of Draenor Engineering
		},
	},
	-- Inscription
	[773] = { name = GetSpellInfo( 45357 ),
		cooldowns = {
			-- PANDARIA Expansion
			{ spellID = 112996, name = GetSpellInfo( 112996 ), itemID = 79731,  icon = GetItemIcon( 79731 )  }, -- Scroll of Wisdom
			-- WoD Expansion
			{ spellID = 177045, name = GetSpellInfo( 177045 ), itemID = 119297, icon = GetItemIcon( 119297 ) }, -- Secrets of Draenor Inscription
			{ spellID = 169081, name = GetSpellInfo( 169081 ), itemID = 112377, icon = GetItemIcon( 112377 ) }, -- War Paints
			-- Forged Documents Daily Quest with Inscription daily CD
			{ spellID = 89244,  name = GetSpellInfo( 89244 ),  itemID = 62056,  icon = GetItemIcon( 62056 )  }, -- Forged Documents (Ally)  http://www.wowhead.com/spell=89244/forged-documents
			{ spellID = 86654,  name = GetSpellInfo( 86654 ),  itemID = 63276,  icon = GetItemIcon( 63276 )  }, -- Forged Documents (Horde)  http://www.wowhead.com/spell=86654/forged-documents
		},
	},
	-- Jewelcrafting
	[755] = { name = GetSpellInfo( 25229 ),
		cooldowns = {
			-- BC Expansion
			--{ spellID = 47280,  name = GetSpellInfo( 47280 ),  itemID = 35945,  icon = GetItemIcon( 35945 )  }, -- Brilliant Glass (have static 20h CD)
			-- LK expansion
			--{ spellID = 62242,  name = GetSpellInfo( 62242 ),  itemID = 44943,  icon = GetItemIcon( 44943 )  }, -- Icy Prism (DOESNT HAVE CD)
			-- CATA Expansion
			{ spellID = 73478,  name = GetSpellInfo( 73478 ),  itemID = 52304,  icon = GetItemIcon( 52304 )  }, -- Fire Prism (daily CD)
			-- PANDARIA Expansion
			-- MoP all 6 gem research share daily CD (reset 9:00AM realm time). You can only perform one Pandaria research per day!
			-- If you researched all recipes for 1 colored gem doing the same research will discover random color gem recipe. Total 68 research/discovery recipes.
			{ spellID = 131691, name = GetSpellInfo( 131691 ), itemID = 90399,  icon = GetItemIcon( 90399 )  }, -- Imperial Amethyst (PURPLE Gem 14 recipes research)
			{ spellID = 131686, name = GetSpellInfo( 131686 ), itemID = 90401,  icon = GetItemIcon( 90401 )  }, -- Primordial Ruby (RED Gem 5 recipes research)
			{ spellID = 131593, name = GetSpellInfo( 131593 ), itemID = 90395,  icon = GetItemIcon( 90395 )  }, -- River's Heart (BLUE Gem 4 recipes research)
			{ spellID = 131695, name = GetSpellInfo( 131695 ), itemID = 90398,  icon = GetItemIcon( 90398 )  }, -- Sun's Radiance (YELLOW Gem 5 recipes research)
			{ spellID = 131690, name = GetSpellInfo( 131690 ), itemID = 90400,  icon = GetItemIcon( 90400 )  }, -- Vermilion Onyx (ORANGE Gem 22 recipes research)
			{ spellID = 131688, name = GetSpellInfo( 131688 ), itemID = 90397,  icon = GetItemIcon( 90397 )  }, -- Wild Jade (GREEN Gem 18 recipes research)
			-- MoP Serpent's Heart daily CD research, DOESNT share daily CD with others 6 MoP gem research
			{ spellID = 140050, name = GetSpellInfo( 140050 ), itemID = 95469,  icon = GetItemIcon( 95469 )  }, -- Serpent's Heart
			-- WoD Expansion
			{ spellID = 170700, name = GetSpellInfo( 170700 ), itemID = 115524, icon = GetItemIcon( 115524 ) }, -- Taladite Crystal
			{ spellID = 176087, name = GetSpellInfo( 176087 ), itemID = 118723, icon = GetItemIcon( 118723 ) }, -- Secrets of Draenor Jewelcrafting
		},
	},
	-- Leatherworking
	[165] = { name = GetSpellInfo( 2108 ),
		cooldowns = {
			-- PANDARIA Expansion
			-- Magnificence of Leather and Magnificence Scales SHARE Daily CD
			{ spellID = 140040, name = GetSpellInfo( 140040 ), itemID = 72163,  icon = GetItemIcon( 72163 )  }, -- Magnificence of Leather (1 day CD, also discovery new LW recipes)
			{ spellID = 140041, name = GetSpellInfo( 140041 ), itemID = 72163,  icon = GetItemIcon( 72163 )  }, -- Magnificence of Scales (1 day CD, also discovery new LW recipes)
			{ spellID = 142976, name = GetSpellInfo( 142976 ), itemID = 98617,  icon = GetItemIcon( 98617 )  }, -- Hardened Magnificent Hide (daily CD, also discovery new LW recipes)
			-- WoD Expansion
			{ spellID = 171391, name = GetSpellInfo( 171391 ), itemID = 110611, icon = GetItemIcon( 110611 ) }, -- Burnished Leather
			{ spellID = 176089, name = GetSpellInfo( 176089 ), itemID = 118721, icon = GetItemIcon( 118721 ) }, -- Secrets of Draenor Leatherworking
		},
	},
	-- Tailoring
	[197] = { name = GetSpellInfo( 3908 ),
		cooldowns = {
			-- CATA Expansion
			-- Cata Dreamcloths spells have each 7 days CD (6d 18h) so they DONT share CD with each other Dreams spells (are also used as currency for higher Cata tailoring recipes)
			{ spellID = 75146,  name = GetSpellInfo( 75146 ),  itemID = 54440,  icon = GetItemIcon( 54440 )  }, -- Dream of Azshara
			{ spellID = 75142,  name = GetSpellInfo( 75142 ),  itemID = 54440,  icon = GetItemIcon( 54440 )  }, -- Dream of Deepholm
			{ spellID = 75144,  name = GetSpellInfo( 75144 ),  itemID = 54440,  icon = GetItemIcon( 54440 )  }, -- Dream of Hyjal
			{ spellID = 75145,  name = GetSpellInfo( 75145 ),  itemID = 54440,  icon = GetItemIcon( 54440 )  }, -- Dream of Ragnaros
			{ spellID = 75141,  name = GetSpellInfo( 75141 ),  itemID = 54440,  icon = GetItemIcon( 54440 )  }, -- Dream of Skywall
			-- Dream of Destruction DOESNT HAVE cooldown !!
			--{ spellID = 94743,  name = GetSpellInfo( 94743 ),  itemID = 54440,  icon = GetItemIcon( 54440 )  }, -- Dream of Destruction (without CD)
			-- PANDARIA Expansion
			{ spellID = 125557, name = GetSpellInfo( 125557 ), itemID = 92960,  icon = GetItemIcon( 92960 )  }, -- Imperial Silk (inside Silkworm Cocoon + chance on pets; discovery new recipes)
			{ spellID = 143011, name = GetSpellInfo( 143011 ), itemID = 98619,  icon = GetItemIcon( 98619 )  }, -- Celestial Cloth (also discovery new recipes)
			-- WoD Expansion
			{ spellID = 168835, name = GetSpellInfo( 168835 ), itemID = 111556, icon = GetItemIcon( 111556 ) }, -- Hexweave Cloth
			{ spellID = 176058, name = GetSpellInfo( 176058 ), itemID = 118722, icon = GetItemIcon( 118722 ) }, -- Secrets of Draenor Tailoring
		},
	},
};
--------------------------------------------------------------------------------------------------------------------------------------------
-- SavedVariables(PerCharacter)
--------------------------------------------------------------------------------------------------------------------------------------------
NS.DefaultSavedVariables = function()
	return {
		["version"] = NS.version,
		["characters"] = {},
		["cooldowns"] = ( function()
			local t = {};
			for skillLine,profession in pairs( NS.professionInfo ) do
				t[skillLine] = CopyTable( profession.cooldowns );
			end
			return t;
		end )(),
		["ldbi"] = { hide = false, minimapPos = 60 },
		["showCharacterRealms"] = true,
		["showDeleteCooldownConfirmDialog"] = true,
	};
end
--
NS.DefaultSavedVariablesPerCharacter = function()
	return {
		["version"] = NS.version,
		["openWithTradeSKill"] = true,
	};
end
--
NS.Upgrade = function()
	local vars = NS.DefaultSavedVariables();
	local version = NS.db["version"];
	-- 2.0
	if version < 2.0 then
		wipe( NS.db["characters"] );
		NS.db["cooldowns"] = vars["cooldowns"];
		NS.db["showDeleteCooldownConfirmDialog"] = vars["showDeleteCooldownConfirmDialog"];
	end
	-- 2.8
	if version < 2.8 then
		NS.db["showMinimapButton"] = NS.dbpc["showMinimapButton"];
		NS.db["minimapButtonPosition"] = NS.dbpc["minimapButtonPosition"];
	end
	-- 2.9
	if version < 2.9 then
		NS.db["ldbi"] = vars["ldbi"];
		NS.db["ldbi"] = { hide = ( not NS.db["showMinimapButton"] ), minimapPos = NS.db["minimapButtonPosition"] };
		NS.db["showMinimapButton"] = nil;
		NS.db["minimapButtonPosition"] = nil;
	end
	--
	NS.db["version"] = NS.version;
end
--
NS.UpgradePerCharacter = function()
	local varspercharacter = NS.DefaultSavedVariablesPerCharacter();
	local version = NS.dbpc["version"];
	-- 2.8
	if version < 2.8 then
		NS.dbpc["showMinimapButton"] = nil;
		NS.dbpc["minimapButtonPosition"] = nil;
	end
	--
	NS.dbpc["version"] = NS.version;
end
--------------------------------------------------------------------------------------------------------------------------------------------
-- Updates
--------------------------------------------------------------------------------------------------------------------------------------------
NS.UpdateCharacter = function()
	local newCharacter = false;
	-- Find/Add Character
	local k = NS.FindKeyByField( NS.db["characters"], "name", NS.currentCharacter.name ) or #NS.db["characters"] + 1;
	if not NS.db["characters"][k] then
		newCharacter = true; -- Flag for sort
		NS.db["characters"][k] = {
			["name"] = NS.currentCharacter.name,					-- Permanent
			["realm"] = GetRealmName(),								-- Permanent
			["classColorCode"] = NS.currentCharacter.classColorCode,-- Permanent
			["professions"] = {},									-- Reset below every update
			["monitor"] = {},										-- Set below for each known cooldown when first added
		};
	end
	-- Professions
	wipe( NS.db["characters"][k]["professions"] ); -- Start fresh every update
	local p1, p2 = GetProfessions();
	local professions = { p1, p2 };
	local monitorable = {}; -- Used to cleanup monitor table
	for i = 1, 2 do
		if professions[i] then -- Can be nil if character doesn't have profession 1 or 2
			local skillLine = select( 7, GetProfessionInfo( professions[i] ) );
			if NS.db["cooldowns"][skillLine] then -- Make sure profession exist in cooldowns, e.g. Herbalism not added
				-- Add Profession
				NS.db["characters"][k]["professions"][i] = {
					["skillLine"] = skillLine,	-- Number reference for profession, e.g. 171 for Alchemy
					["cooldowns"] = {},			-- Set below each update
				};
				-- Add Cooldowns
				for _,cd in ipairs( NS.db["cooldowns"][skillLine] ) do -- Pull from global cooldowns
					if IsPlayerSpell( cd.spellID ) then -- Only known cooldowns
						local start, duration = GetSpellCooldown( cd.spellID );
						local resetRemaining = GetQuestResetTime();
						local durationRemaining = ( ( start == 0 or duration == 0 ) and 0 ) or ( duration - ( GetTime() - start ) );
						local cooldownRemaining = ( durationRemaining == 0 and 0 ) or ( durationRemaining < 86400 and resetRemaining ) or ( durationRemaining > 86400 and math.floor( durationRemaining / 86400 ) * 86400 + resetRemaining );
						--print( GetSpellLink( cd.spellID ) .. " (" .. cooldownRemaining .. ") " .. SecondsToTime( cooldownRemaining ) ); -- DEBUG
						NS.db["characters"][k]["professions"][i]["cooldowns"][cd.spellID] = cooldownRemaining;
						if NS.db["characters"][k]["monitor"][cd.spellID] == nil then
							NS.db["characters"][k]["monitor"][cd.spellID] = false; -- NOT monitored (false) by default, true when checked
						end
						monitorable[cd.spellID] = true;
					end
				end
			end
		end
	end
	-- Update Time
	NS.db["characters"][k]["updateTime"] = time();
	--
	if not newCharacter then
		-- Monitor Clean Up, only when NOT new character
		for spellID in pairs( NS.db["characters"][k]["monitor"] ) do
			if not monitorable[spellID] then
				NS.db["characters"][k]["monitor"][spellID] = nil;
			end
		end
	else
		-- Sort Characters by realm and name, only when a new character was added
		table.sort ( NS.db["characters"],
			function ( char1, char2 )
				if char1["realm"] == char2["realm"] then
					return char1["name"] < char2["name"];
				else
					return char1["realm"] < char2["realm"];
				end
			end
		);
	end
end
--
NS.Update = function( event )
	if NS.updateRequestTime and ( time() - NS.updateRequestTime ) == 0 then return end -- Ignore multiple update requests in the same second
	NS.updateRequestTime = time();
	C_Timer.After( 1, function() -- Delay 1 second to allow time for any changes made to be included in our new data
		NS.UpdateCharacter();
		if NS.UI.SubFrames[1]:IsShown() then
			NS.UI.SubFrames[1]:Refresh();
		end
	end );
end
--------------------------------------------------------------------------------------------------------------------------------------------
-- Misc
--------------------------------------------------------------------------------------------------------------------------------------------
NS.OpenWithTradeSkill = function()
	if NS.dbpc["openWithTradeSKill"] and C_TradeSkillUI.GetTradeSkillLine() ~= 129 and C_TradeSkillUI.GetTradeSkillLine() ~= 185 and C_TradeSkillUI.GetTradeSkillLine() ~= 960 and not C_TradeSkillUI.IsTradeSkillLinked() and not C_TradeSkillUI.IsTradeSkillGuild() then
		local parent = ( TradeSkillFrame and TradeSkillFrame:IsShown() and TradeSkillFrame ) or ( TSMCraftingTradeSkillFrame and TSMCraftingTradeSkillFrame:IsShown() and TSMCraftingTradeSkillFrame ) or ( SkilletFrame and SkilletFrame:IsShown() and SkilletFrame );
		if parent then
			NS.UI.MainFrame:SetParent( parent ); -- Put into parent for positioning
			NS.UI.MainFrame:Reposition();
			NS.UI.MainFrame:ShowTab( 1 );
		end
	end
end
--
NS.AddCooldown = function( spellID, itemID, skillLine )
	skillLine = skillLine or NS.selectedSkillLine;
	--
	if not spellID or not itemID then
		return nil;
	else
		spellID = tonumber( spellID );
		itemID = tonumber( itemID );
		local name = spellID ~= 0 and GetSpellInfo( spellID ) or nil;
		local icon = itemID ~= 0 and select( 5, GetItemInfoInstant( itemID ) ) or nil;
		if not name or not icon then
			return nil;
		else
			local cooldownKey = NS.FindKeyByField( NS.db["cooldowns"][skillLine], "spellID", spellID );
			local which = cooldownKey and "updated" or "added";
			--
			if not cooldownKey then
				cooldownKey = #NS.db["cooldowns"][skillLine] + 1;
			end
			NS.db["cooldowns"][skillLine][cooldownKey] = { ["spellID"] = spellID, ["name"] = name, ["itemID"] = itemID, ["icon"] = icon };
			NS.Sort( NS.db["cooldowns"][skillLine], "name", "ASC" );
			--
			return which;
		end
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------
-- LDB Data Object
--------------------------------------------------------------------------------------------------------------------------------------------
NS.ldb = LibStub:GetLibrary( "LibDataBroker-1.1" ):NewDataObject( NS.addon, {
	type = "data source",
	text = NS.addon,
	icon = 237296, -- inv_misc_enggizmos_swissarmy
	OnClick = function( self, button )
		NS.SlashCmdHandler();
	end,
	OnTooltipShow = function( self )
		-- Not initialized
		if not NS.initialized then return end
		-- Show tooltip for known Minimap button
		self:SetText( HIGHLIGHT_FONT_COLOR_CODE .. NS.title .. FONT_COLOR_CODE_CLOSE );
		self:AddLine( L["Left-Click to open and close"] );
		self:AddLine( L["Drag to move this button"] );
	end,
} );
--------------------------------------------------------------------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------------------------------------------------------------------
NS.SlashCmdHandler = function( cmd )
	if not NS.initialized then return end
	--
	if NS.UI.MainFrame:IsShown() then
		NS.UI.MainFrame:Hide();
	elseif not cmd or cmd == "" or cmd == "monitor" then
		NS.UI.MainFrame:ShowTab( 1 );
	elseif cmd == "characters" then
		NS.UI.MainFrame:ShowTab( 2 );
	elseif cmd == "options" then
		NS.UI.MainFrame:ShowTab( 3 );
	elseif cmd == "help" then
		NS.UI.MainFrame:ShowTab( 4 );
	else
		NS.UI.MainFrame:ShowTab( 4 );
		NS.Print( L["Unknown command, opening Help"] );
	end
end
--
SLASH_PROFESSIONSCOMPLETE1 = "/professionscomplete";
SLASH_PROFESSIONSCOMPLETE2 = "/pc";
SlashCmdList["PROFESSIONSCOMPLETE"] = function( msg ) NS.SlashCmdHandler( msg ) end;
--------------------------------------------------------------------------------------------------------------------------------------------
-- Event/Hook Handlers
--------------------------------------------------------------------------------------------------------------------------------------------
NS.OnAddonLoaded = function( event )
	if not NS.db and IsAddOnLoaded( NS.addon ) then
		-- SavedVariables
		if not PROFESSIONSCOMPLETE_SAVEDVARIABLES then
			PROFESSIONSCOMPLETE_SAVEDVARIABLES = NS.DefaultSavedVariables();
		end
		-- SavedVariablesPerCharacter
		if not PROFESSIONSCOMPLETE_SAVEDVARIABLESPERCHARACTER then
			PROFESSIONSCOMPLETE_SAVEDVARIABLESPERCHARACTER = NS.DefaultSavedVariablesPerCharacter();
		end
		-- Localize SavedVariables
		NS.db = PROFESSIONSCOMPLETE_SAVEDVARIABLES;
		NS.dbpc = PROFESSIONSCOMPLETE_SAVEDVARIABLESPERCHARACTER;
		-- Upgrade db
		if NS.db["version"] < NS.version then
			NS.Upgrade();
		end
		-- Upgrade dbpc
		if NS.dbpc["version"] < NS.version then
			NS.UpgradePerCharacter();
		end
	elseif TradeSkillFrame then
		PCEventsFrame:UnregisterEvent( event );
		TradeSkillFrame:HookScript( "OnShow", NS.OpenWithTradeSkill );
	end
end
--
NS.OnPlayerLogin = function( event )
	PCEventsFrame:UnregisterEvent( event );
	C_Timer.After( 2, function()
		-- Call initial character update directly to avoid delay which would run intialize prematurely
		NS.UpdateCharacter();
		-- Initialize some variables and register events
		NS.currentCharacter.key = NS.FindKeyByField( NS.db["characters"], "name", NS.currentCharacter.name ); -- Must be reset when character is deleted
		NS.selectedCharacterKey = NS.currentCharacter.key; -- Sets selected character to current character
		--
		PCEventsFrame:RegisterEvent( "CHAT_MSG_TRADESKILLS" );
		PCEventsFrame:RegisterEvent( "SKILL_LINES_CHANGED" );
		--
		NS.initialized = true; -- Slash command handler won't open GUI until intialized
	end );
	-- LibDBIcon
	NS.ldbi = LibStub:GetLibrary( "LibDBIcon-1.0" );
	NS.ldbi:Register( NS.addon, NS.ldb, NS.db["ldbi"] );
end
--
NS.OnTradeSkillListUpdate = function( event )
	if TSMCraftingTradeSkillFrame then
		PCEventsFrame:UnregisterEvent( event );
		TSMCraftingTradeSkillFrame:HookScript( "OnShow", NS.OpenWithTradeSkill );
		NS.OpenWithTradeSkill();
	elseif SkilletFrame then
		PCEventsFrame:UnregisterEvent( event );
		SkilletFrame:HookScript( "OnShow", NS.OpenWithTradeSkill );
		NS.OpenWithTradeSkill();
	end
end
--
NS.OnChatMsgTradeskills = function( event, ... )
	local arg1 = select( 1, ... );
	if not arg1 then return end
	-- If not English update on every message, otherwise only when player craft detected
	if ( GetLocale() ~= "enUS" and GetLocale() ~= "enGB" ) or string.match( arg1, string.gsub( TRADESKILL_LOG_FIRSTPERSON, "%%s%.", "" ) ) then -- You create %s.
		NS.Update( event );
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------
-- PCEventsFrame
--------------------------------------------------------------------------------------------------------------------------------------------
NS.Frame( "PCEventsFrame", UIParent, {
	topLevel = true,
	OnEvent = function ( self, event, ... )
		if		event == "ADDON_LOADED"				then	NS.OnAddonLoaded( event );
		elseif	event == "PLAYER_LOGIN"				then	NS.OnPlayerLogin( event );
		elseif	event == "TRADE_SKILL_LIST_UPDATE"	then	NS.OnTradeSkillListUpdate( event );
		elseif	event == "CHAT_MSG_TRADESKILLS"		then	NS.OnChatMsgTradeskills( event, ... );
		elseif	event == "SKILL_LINES_CHANGED"		then	NS.Update( event );
		end
	end,
	OnLoad = function( self )
		self:RegisterEvent( "ADDON_LOADED" );
		self:RegisterEvent( "PLAYER_LOGIN" );
		self:RegisterEvent( "TRADE_SKILL_LIST_UPDATE" );
	end,
} );
