local dewdrop = AceLibrary("Dewdrop-2.0")
local tablet = AceLibrary("Tablet-2.0")
local L = AceLibrary("AceLocale-2.2"):new("MrPlow")

local dustBag = {}
local count = 0
local theWorks = {}
local eventCalled = false
local delayCalled = false

local theWorksBank = nil
local bankAvailable = nil
local plowingBank = nil
local swapping = nil
local itemCount = 0

BINDING_HEADER_MRPLOW = "Mr Plow"

--<< ================================================= >>--
-- Section II: AddOn Information.                        --
--<< ================================================= >>--
local sortCategories = {"Potion", "Water", "Weapon Buff"}

local itemCategories = {
	ARMOR = 1,
	WEAPON = 2,
	QUEST = 3,
	KEY = 4,
	RECIPE = 5,
	REAGENT = 6,
	TRADEGOODS = 7,
	CONSUMABLE = 8,
	CONTAINER = 9,
	QUIVER = 10,
	MISCELLANEOUS = 11,
	PROJECTILE = 12
}

local armWepRank = {
	INVTYPE_AMMO = 0,
	INVTYPE_HEAD = 1,
	INVTYPE_NECK = 2,
	INVTYPE_SHOULDER = 3,
	INVTYPE_BODY = 4,
	INVTYPE_CHEST = 5,
	INVTYPE_ROBE = 5,
	INVTYPE_WAIST = 6,
	INVTYPE_LEGS = 7,
	INVTYPE_FEET = 8,
	INVTYPE_WRIST = 9,
	INVTYPE_HAND = 10,
	INVTYPE_FINGER = 11,
	INVTYPE_TRINKET = 12,
	INVTYPE_CLOAK = 13,
	INVTYPE_WEAPON = 14,
	INVTYPE_SHIELD = 15,
	INVTYPE_2HWEAPON = 16,
	INVTYPE_WEAPONMAINHAND = 18,
	INVTYPE_WEAPONOFFHAND = 19,
	INVTYPE_HOLDABLE = 20,
	INVTYPE_RANGED = 21,
	INVTYPE_THROWN = 22,
	INVTYPE_RANGEDRIGHT = 23,
	INVTYPE_RELIC = 24,
	INVTYPE_TABARD = 25,
}

-- Trade Good sorting
local ingredientRanking = {
	["Mats - Bars"] = 1,
	["Mats - Bolts"] = 2,
	["Mats - Cloth"] = 3,
	["Mats - Dusts"] = 4,
	["Mats - Dyes"] = 5,
	["Mats - Elemental"] = 6,
	["Mats - Essence"] = 7,
	["Mats - Flux"] = 8,
	["Mats - Gem"] = 9,
	["Mats - Grinding"] = 10,
	["Mats - Hide"] = 11,
	["Mats - Leather"] = 12,
	["Mats - Oil"] = 13,
	["Mats - Ore"] = 14,
	["Mats - Parts"] = 15,
	["Mats - Pearls"] = 16,
	["Mats - Poisons"] = 17,
	["Mats - Powders"] = 18,
	["Mats - Rods"] = 19,
	["Mats - Salt"] = 20,
	["Mats - Scales"] = 21,
	["Mats - Shards"] = 22,
	["Mats - Spices"] = 23,
	["Mats - Stones"] = 24,
	["Mats - Thread"] = 25,
	["Mats - Vials"] = 26,
	["Mats - Nexus"] = 27
}

local itemRanking = {
	[L["Armor"]] = itemCategories.ARMOR,
	[L["Weapon"]] = itemCategories.WEAPON,
	[L["Quest"]] = itemCategories.QUEST,
	[L["Key"]] = itemCategories.KEY,
	[L["Recipe"]] = itemCategories.RECIPE,
	[L["Reagent"]] = itemCategories.REAGENT,
	[L["Consumable"]] = itemCategories.CONSUMABLE,
	[L["Container"]] = itemCategories.CONTAINER,
	[L["Quiver"]] = itemCategories.QUIVER,
	[L["Miscellaneous"]] = itemCategories.MISCELLANEOUS,
	[L["Projectile"]] = itemCategories.PROJECTILE,
	[L["Trade Goods"]] = itemCategories.TRADEGOODS 
}

local during = {
	L["There is a tinkle of broken glass and a soft \"D'oh!\""],
	L["It looks like two wet cats in a bag..."],
	L["You hear the theme music being hummed out of key."],
	L["The engine cuts off for a bit, followed by the sounds of an asthmatic cow and curses before spluttering on..."],
	L["You wince as something reverses into your lower back."],
	L["You hear a loud CRASH, and the ever present revolving noise of a single plate spinning on the ground."],
	L["The discordant noise of what sounds like a piano dropping onto a hessian sack full of lasagne fills your ears."],
}

local optionTable = {
	type = "group",
	args = {
		stack = {
			type = "execute",
			name = L["Stack"],
			desc = L["Compresses your inventory."],
			func = "ParseInventory",
			order = 100,
		},
		plow = {
			type = "execute",
			name = L["Plow"],
			desc = L["Defragments your inventory."],
			func = "Defrag",
			order = 101,
		},
		sort = {
			type = "execute",
			name = L["Sort"],
			desc = L["Sorts your inventory."],
			func = "SortAll",
			order = 102,
		},
		theworks = {
			type = "execute",
			name = L["The Works"],
			desc = L["Stacks, plows and sorts. All in one."],
			func = "Works",
			order = 103,
		},
		bank = {
			type = "group",
			name = L["Bank"],
			desc = L["Bank commands"],
			order = 104,
			args = {
				stack = {
					type = "execute",
					name = L["Stack"],
					desc = L["Compresses your bank."],
					func = function() MrPlow:ParseInventory(L["Bank"]) end,
					order = 100,
				},
				plow = {
					type = "execute",
					name = L["Plow"],
					desc = L["Defragments your bank."],
					func = function() MrPlow:Defrag(L["Bank"]) end,
					order = 101,
				},
				sort = {
					type = "execute",
					name = L["Sort"],
					desc = L["Sorts your bank."],
					func = function() MrPlow:SortAll(L["Bank"]) end,
					order = 102,
				},
				theworks = {
					type = "execute",
					name = L["The Works"],
					desc = L["Stacks, plows and sorts. All in one."],
					func = function() MrPlow:Works(L["Bank"]) end,
					order = 103,
				},
				bankstack = {
					type = "execute",
					name = L["Bank Stack"],
					desc = L["Moves stuff from your bags to your bank."],
					func = "BankStack",
					order = 104,
				},
			},
		},
		info	= {
			type = "execute",
			name = L["Status"],
			desc = L["Shows the current options set for Mr Plow."],
			func = "Report",
			order = 105,
		},
		properties = {
			type = "group",
			name = L["Properties"],
			desc = L["Mr Plow Properties"],
			order = 106,
			args = {
				direction = {
					type     = "text",
					name     = L["Direction"],
					usage    = "<"..L["Direction"]..">",
					desc     = L["Change the plow direction."],
					get      = function() return MrPlow.db.profile.Direction end,
					set      = function(v)
									MrPlow.db.profile.Direction = v
									if(v == "Forwards") then
										MrPlow:Print(L["Mr Plow does a three point turn and faces forward..."])
									else
										MrPlow:Print(L["Mr Plow changes gear into reverse..."])
									end
								end,
					validate = {["Forwards"] = L["Forwards"], ["Backwards"] = L["Backwards"]},
					order = 100,
				},
				gag = {
					type = "toggle",
					name = L["Gag"],
					desc = L["Silence output"],
					get  = function() return MrPlow.db.profile.Gag end,
					set  = function(v)
								if(v) then
									MrPlow:Print(L["You feel a great disturbance in the Force, as if millions of voices suddenly cried out in terror and were suddenly silenced..."])
									MrPlow:Print(L["Oh wait. No. Just one."])
								else
									MrPlow:Print(L["There is a grumbling as the gag is removed."])
								end
								MrPlow.db.profile.Gag = v
							end,
					order = 102,
				},
				bankstackstyle = {
					type    = "execute",
					name = L["Bank Stack Style"],
					desc    = L["Toggles the bank stack style."],
					func    = "BankStackStyle",
					order	= 103,
				},
				junkfilter = {
					type	= "toggle",
					name	= L["Filter Junk"],
					desc	= L["Moves all greys to the end."],
					get		= function() return MrPlow.db.profile.Junk end,
					set		= function() MrPlow.db.profile.Junk = not MrPlow.db.profile.Junk end,
					order	= 104,
				},
				clicktorun = {
					type	= "toggle",
					name = L["Click To Run"],
					desc	= L["Disables the click to run functionality."],
					get		= function() return MrPlow.db.profile.ClickToRun end,
					set		= function() MrPlow.db.profile.ClickToRun = not MrPlow.db.profile.ClickToRun end,
					order	= 105,
				},
			},
		},
		ignore = {
			type      = "group",
			name      = L["ignore"],
			desc      = L["Modifies your ignore list."],
			guiHidden = true,
			args      = {
				add = {
					 type = "text",
					 get  = false,
					 usage = "<[item]>",
					 name = L["add"],
					 desc = L["add item(s) to the ignore list, just shiftclick."],
					 set = "IgnoreAdd",
				},
				delete = {
					 type = "text",
					 get  = false,
					 usage = "<[item]>",
					 name = L["del"],
					 desc = L["remove item(s) from the ignore list, just shiftclick."],
					 set = "IgnoreDel",
				},
				clear = {
					 type = "execute",
					 name = L["clear"],
					 desc = L["clear the ignore list completely."],
					 func = "IgnoreClear",
				},
				bag = {
					 type = "group",
					 name = L["bag"],
					 desc = L["ignore specific bags."],
					 args = { 
						add = {
							type = "text",
							get  = false,
							usage = "<0,1,2,3,4>",
							name = L["add"],
							desc = L["add a bag to the ignore list. Use '0' for the backpack, and 1-4 for the others. Use a single number or a comma separated list."],
							set = "IgnoreBagsAdd",
						},
						del = {
							type =  "text",
							get  = false,
							usage = "<0,1,2,3,4>",
							name = L["del"],
							desc = L["remove bags from the ignore list. Use '0' for the backpack, and 1-4 for the others, Use a single number or a comma separated list."],
							set = "IgnoreBagsDel",
						},
						clear = {
							type = "execute",
							name = L["clear"],
							desc = L["clear the ignore bag list."],
							func = "IgnoreBagsClear",
						}
					}
				},
				slotignore = {
					 type = "group",
					 name = L["slot"],
					 desc = L["ignore specific slots."],
					 args = { 
						add = {
							type = "text",
							get  = false,
							usage = "<[0,1,2,3,4]-[1-x]>",
							name = L["add"],
							desc = L["add slots to the ignore list. Use '0' for the backpack, and 1-4 for the others in the form bag-slot (eg 1-12). Use a single entry or a comma separated list."],
							set = "IgnoreSlotsAdd",
						},
						del = {
							type = "text",
							get  = false,
							name = L["del"],
							usage = "<[0,1,2,3,4]-[1-x]>",
							desc = L["remove slots from the ignore list. Use '0' for the backpack, and 1-4 for the others in the form bag-slot (eg 1-12), Use a single entry or a comma separated list."],
							set = "IgnoreSlotsDel",
						},
						addmouse = {
							type = "execute",
							name = L["addmouse"],
							desc = L["add slots to the ignore list. Place the cursor over the intended bagslot to ignore and run the command."],
							func = "IgnoreSlotsMouseAdd",
						},
						delmouse = {
							type = "execute",
							name = L["delmouse"],
							desc = L["remove slots from the ignore list. Place the cursor over the intended bagslot to unignore and run the command."],
							func = "IgnoreSlotsMouseDel",
						},
						clear = {
							type = "execute",
							name = L["clear"],
							desc = L["clear the ignore slot list."],
							func = "IgnoreSlotsClear",
						},
					},
				},
				ignorebank = {
					 type = "group",
					 name = L["bankbag"],
					 desc = L["ignore specific bankbags."],
					 args = {
						add = {
							type = "text",
							name = L["add"],
							get	 = false,
							usage = "<[0,1,2,3,4,5,6]>",
							desc = L["add a bankbag to the ignore list. Use '0' for the main bank window, and 1-6 for the others. Use a single number or a comma separated list."],
							set = "IgnoreBankBagsAdd",
						},
						del = {
							type = "text",
							get  = false,
							name = L["del"],
							usage = "<[0,1,2,3,4,5,6]>",
							desc = L["remove bags from the ignore list. Use '0' for the main bank window, and 1-6 for the others, Use a single number or a comma separated list."],
							set = "IgnoreBankBagsDel",
						},
						clear = {
							type = "execute",
							name = L["clear"],
							desc = L["clear the ignore bankbag list."],
							func = "IgnoreBankBagsClear",
						}
					},
				}
			}
		},
	},
}

--<< ================================================= >>--
-- Section II: AddOn Information.                        --
--<< ================================================= >>--

local PT = AceLibrary("PeriodicTable-2.0")

MrPlow = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDB-2.0", "AceConsole-2.0", "AceDebug-2.0", "FuBarPlugin-2.0")
MrPlow:RegisterDB("MrPlowDB")
MrPlow:RegisterDefaults("profile", {
	Direction = "Forwards",
	BankStackStyle = 1,
	IgnoreList = {},
	IgnoreBagList = {},
	IgnoreBankBagList = {},
	IgnoreSlotList = {}
})
MrPlow.hasIcon = true
MrPlow.hasNoColor = true
MrPlow.OnMenuRequest = optionTable
MrPlow.cannotDetachTooltip = true

function MrPlow:OnInitialize()
	self.version = self.version..".2.".. string.sub("$Revision: 23832 $", 12, -3)
	self:RegisterEvent("BANKFRAME_OPENED")
	self:RegisterEvent("BANKFRAME_CLOSED")

	MrPlow:RegisterChatCommand(L["AceConsole-commands"], optionTable, "MRPLOW")
	MrPlow:SetDebugging(false)
end

function MrPlow:Report()
	if(self.db.profile.Direction == "Backwards") then
		self:Print(L["Mr Plow is facing"].." ".. L["backward."])
	else
		self:Print(L["Mr Plow is facing"].." ".. L["forward."])
	end
	local tag = true
	for link,v in pairs(self.db.profile.IgnoreList) do
		if(tag) then 
			self:Print(L["Mr Plow is ignoring:"])
			tag = false
		end
		local linkstring = MrPlow:GetLink(link)
		if(linkstring == "") then
			self.db.profile.IgnoreList[link] = nil
		else
			self:Print("     "..linkstring)
		end
	end
	for bag,slots in pairs(self.db.profile.IgnoreSlotList) do
		for slot,_ in pairs(slots) do
			self:Print("     "..bag.."-"..slot)
		end
	end
	local ibag = "[ "
	for i,v in pairs(self.db.profile.IgnoreBagList) do
		ibag = ibag..(i-1).." "
	end
	if(ibag ~= "[ ") then
		self:Print(L["and bags: "]..ibag.." ]")
	end
	ibag = "[ "
	for i,v in pairs(self.db.profile.IgnoreBankBagList) do
		ibag = ibag..(i-1).." "
	end
	if(ibag ~= "[ ") then
		self:Print(L["and bank bags: "]..ibag.." ]")
	end

	MrPlow:PrintBankStyle()
end

function MrPlow:BankStackStyle()
	local style = self.db.profile.BankStackStyle or 0
	if(style >= 2) then
		self.db.profile.BankStackStyle = 0
	else
		self.db.profile.BankStackStyle = style + 1
	end
	MrPlow:PrintBankStyle()
end

function MrPlow:PrintBankStyle()
	local style = self.db.profile.BankStackStyle or 0
	local message = {}
	local list = ""
	if(style >= 0) then
		table.insert(message, L["filling up current stacks"])
	end
	if(style >= 1) then
		table.insert(message, L["filling up the bag that contains the same item"])
	end
	if(style >= 2) then
		table.insert(message, L["filling up any other free space"])
	end
	if(table.getn(message) > 1) then
		list = table.concat(message, ",", 1, table.getn(message) - 1)..L[" and then "]..message[table.getn(message)]
	else
		list = message[1]
	end
	self:Print(L["Mr Plow will stack items from your bag to your bank by "]..list)
end

function MrPlow:IgnoreAdd(list)
	MrPlow:ChangeIgnore(list, false)
end

function MrPlow:IgnoreDel(list)
	MrPlow:ChangeIgnore(list, true)
end

function MrPlow:IgnoreClear()
	MrPlow:ChangeIgnore(nil, true, true)
end

function MrPlow:IgnoreSlotsAdd(list)
	MrPlow:ChangeSlotsIgnore(list, false)
end

function MrPlow:IgnoreSlotsDel(list)
	MrPlow:ChangeSlotsIgnore(list, true)
end

function MrPlow:IgnoreSlotsMouseAdd(list)
	local bag = GetMouseFocus():GetParent():GetID()
	local slot = GetMouseFocus():GetID()
	if(bag and slot) then
		self:Debug("ignoring "..bag.." and "..slot)
		MrPlow:ChangeSlotsIgnore(bag.."-"..slot, false)
	end
end

function MrPlow:IgnoreSlotsMouseDel(list)
	local bag = GetMouseFocus():GetParent():GetID()
	local slot = GetMouseFocus():GetID()
	if(bag and slot) then
		self:Debug("ignoring "..bag.." and "..slot)
		MrPlow:ChangeSlotsIgnore(bag.."-"..slot, true)
	end
end

function MrPlow:IgnoreSlotsClear()
	MrPlow:ChangeSlotsIgnore(nil, true, true)
end

function MrPlow:IgnoreBagsAdd(list)
	MrPlow:ChangeBagIgnore(list, false)
end

function MrPlow:IgnoreBagsDel(list)
	MrPlow:ChangeBagIgnore(list, true)
end

function MrPlow:IgnoreBagsClear()
	MrPlow:ChangeBagIgnore(nil, true, true)
end


function MrPlow:IgnoreBankBagsAdd(list)
	MrPlow:ChangeBagIgnore(list, false, false, true)
end

function MrPlow:IgnoreBankBagsDel(list)
	MrPlow:ChangeBagIgnore(list, true, false, true)
end

function MrPlow:IgnoreBankBagsClear()
	MrPlow:ChangeBagIgnore(nil, true, true, true)
end


function MrPlow:Works(Bank)
	if(table.getn(theWorks) == 0) then
		theWorks = { "ParseInventory", "Defrag", "SortAll" }
		if(Bank == L["Bank"]) then
			theWorksBank = L["Bank"]
		end
		MrPlow:SwapIt()
	end
end

function MrPlow:RegisterEvents()
	self:RegisterEvent("BAG_UPDATE", "ScanEvent")
	if(bankAvailable) then
		self:RegisterEvent("PLAYERBANKSLOTS_CHANGED", "ScanEvent") 
	end
end

function MrPlow:UnregisterEvents()
	if(self:IsEventRegistered("BAG_UPDATE")) then
		self:UnregisterEvent("BAG_UPDATE")
	end
	if(self:IsEventRegistered("PLAYERBANKSLOTS_CHANGED")) then
		self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED")
	end
end

function MrPlow:BANKFRAME_OPENED()
	bankAvailable = true
end

function MrPlow:BANKFRAME_CLOSED()
	if (plowingBank) then
		bankAvailable = false
		plowingBank = false
		this:UnregisterEvent("PLAYERBANKSLOTS_CHANGED")
		for k in pairs(dustBag) do dustBag[k] = nil end
		swapping = false
	end
end


--[[
	This function will parse the inventory for stacks that can be restacked. They will be filled up from the back, forward, 
	so that if there is too many items to make all of the stacks full, the partial stack will remain at the front, to be 
	used by the player automatically (like ammo usage, or tradeskills)
]]--
function MrPlow:ParseInventory(Bank)
	local t, mem = GetTime(), gcinfo()
	if (table.getn(dustBag) == 0) then
		local notFull = {}
		local dupe = {}
		local baglist

		if(Bank == L["Bank"] and bankAvailable) then
			baglist = MrPlow:GetBagList(true)
			plowingBank = true
		else
			if(Bank == L["Bank"] and not bankAvailable) then
				self:Print("Your Bank window is not open!")
				for k in pairs(theWorks) do theWorks[k] = nil end
				theWorksBank = nil
				return
			else
				baglist = MrPlow:GetBagList()
			end
		end
			
		
		for i,bag in pairs(baglist) do
			for slot=1, GetContainerNumSlots(bag) do
				if(not (self.db.profile.IgnoreSlotList[bag] and self.db.profile.IgnoreSlotList[bag][slot]) and GetContainerItemLink(bag,slot)) then
					local _, _, link = string.find(GetContainerItemLink(bag,slot), "item:(%d+):%d+:%d+:%d+")

					if (link) then
						if(not self.db.profile.IgnoreList[link]) then -- Skip over ignored items
							local _, stackSize = GetContainerItemInfo(bag,slot)
							--local fullStack													
							--_, _, _, _, _, _, _, fullStack = GetItemInfo(link)
							-- fixed by fuba to work with 1.12
							local itemName, itemLink, itemRarity, itemMinLevel, itemType, itemSubType, fullStack, itemEquipLoc, itemTexture = GetItemInfo(link)	

							-- If it exists, and is 1) in our NotFull list, and 2) isn't full itself add it to the dupe list
							if (notFull[link] and stackSize < fullStack) then
								if(not dupe[link]) then
									dupe[link] = {}
								end
								table.insert(dupe[link], 1, {bag, slot, stackSize})
							else -- Otherwise check if it's not full and put it in our list to fill
								if(tonumber(stackSize) < tonumber(fullStack)) then
									notFull[link] = {bag, slot, fullStack - stackSize, fullStack}
								end
							end
						end
					end
				end
			end
		end
		--[[
		-- Now we have two lists. The notFull has the last unfilled position, while the dupe table holds the rest 
		-- of the unfilled stacks of that object, but in forward order. So what we need to do now, is take the 
		-- first unfilled, and dump it on the last...
		--]]
		for link, data in pairs(dupe) do
			while (table.getn(data) > 0) do
				local dBag, dSlot, dStackSize = unpack(table.remove(data,1))
				local fillBag, fillSlot, fillDeficit, fullStack = unpack(notFull[link])
				local newTarget

				table.insert(dustBag, 1, {{dBag, dSlot}, {fillBag, fillSlot}})

				if (dStackSize >= fillDeficit) then -- If there is more than needed...
					if(dStackSize > fillDeficit) then -- Put the remainder back in the queue
						table.insert(data, 1, {dBag, dSlot, -(fillDeficit - dStackSize)})
					end --and retarget the module to the next last unfilled slot
					newTarget = table.remove(data)
					if (newTarget) then
						notFull[link] = {newTarget[1], newTarget[2], fullStack - newTarget[3], fullStack}
					end
				else -- Otherwise, update how much is needed to fill the target stack
					notFull[link][3] = fillDeficit - dStackSize
				end
			end
		end

		if (table.getn(dustBag) > 0) then
			MrPlow:Chat(L["Your bags rumble as Mr Plow gets busy and drives into your bags..."])
			MrPlow:RegisterEvents()
		else
			MrPlow:Chat(L["Mr Plow looks at your neat bags and shakes his head."])
		end
		MrPlow:SwapIt()
	end
	self:Debug(string.format("InventoryParse: |cff80ff80%.3f sec|r |cffff8000(%d KiB)", GetTime() - t, gcinfo() - mem))
end


function MrPlow:Defrag(Bank)
	local t, mem = GetTime(), gcinfo()
	if (table.getn(dustBag) == 0) then	
		local Empty = {}
		local Full = {}
		local QEmpty = {}
		local QFull = {}

		local function _BagDefrag(Full, Empty, bag)
			for slot=1, GetContainerNumSlots(bag) do
				if(not (self.db.profile.IgnoreSlotList[bag] and self.db.profile.IgnoreSlotList[bag][slot])) then
					local link = nil
					
					if(GetContainerItemLink(bag,slot)) then
						_, _, link = string.find(GetContainerItemLink(bag,slot), "item:(%d+):%d+:%d+:%d+")
					end
					
					if(not link or not self.db.profile.IgnoreList[link]) then -- Skip over ignored items
		
						if(self.db.profile.Direction == "Forwards") then
							if(link) then
								table.insert(Full, 1, {bag, slot}) -- Insert the full spaces in reverse order
							else
								table.insert(Empty, {bag, slot}) -- And the empty spaces in forward order
							end
						else
							if(link) then
								table.insert(Full, {bag, slot}) -- Insert the full spaces in forward order
							else
								table.insert(Empty, 1, {bag, slot}) -- And the empty spaces in reverse order
							end
						end
					end
				end
			end
		end
		
		local function _Defrag_Move(Full, Empty)
			if(self.db.profile.Direction == "Forwards") then
				if(table.getn(Full) <= table.getn(Empty)) then
					for i,Full in ipairs(Full) do
						if (Full[1] > Empty[i][1] or (Full[1] == Empty[i][1] and Full[2] > Empty[i][2])) then
							table.insert(dustBag, {{Full[1], Full[2]}, {Empty[i][1], Empty[i][2]}})
						end
					end
				else
					for i,Empty in ipairs(Empty) do
						if (Empty[1] < Full[i][1] or (Empty[1] == Full[i][1] and Empty[2] < Full[i][2])) then
							table.insert(dustBag, {{Full[i][1], Full[i][2]}, {Empty[1], Empty[2]}})
						end
					end
				end
			else
				if(table.getn(Full) <= table.getn(Empty)) then
					for i,Full in ipairs(Full) do
						if (Full[1] < Empty[i][1] or (Full[1] == Empty[i][1] and Full[2] < Empty[i][2])) then
							table.insert(dustBag, {{Full[1], Full[2]}, {Empty[i][1], Empty[i][2]}})
						end
					end
				else
					for i,Empty in ipairs(Empty) do
						if (Empty[1] > Full[i][1] or (Empty[1] == Full[i][1] and Empty[2] > Full[i][2])) then
							table.insert(dustBag, {{Full[i][1], Full[i][2]}, {Empty[1], Empty[2]}})
						end
					end
				end
			end
		end

		local baglist = {}

		if(Bank == L["Bank"] and bankAvailable) then
			baglist = MrPlow:GetBagList(true)
			plowingBank = true
		else
			if(Bank == L["Bank"] and not bankAvailable) then
				self:Print("Your Bank window is not open!")
				for k in pairs(theWorks) do theWorks[k] = nil end
				theWorksBank = nil
				return
			else
				baglist = MrPlow:GetBagList()
			end
		end

		for i,bag in pairs(baglist) do
			if(GetBagName(bag) or bankAvailable and bag == -1) then -- First, ignore all ammo pouches...
				local specialBag
				if(bag > 0) then
					local bagslot = bag < 5 and bag + 19 or bag + 40
					local bagTLink = GetInventoryItemLink("player", bagslot) or ""
					self:Debug(bag)
					local _, _, bagLink = strfind(bagTLink, "(%d+):")
					if (bagLink) then
						specialBag = PT:ItemInSets(bagLink + 0, "Bags - Special")
					end
				end
				if(not specialBag) then
					_BagDefrag(Full, Empty, bag)
				else
					_BagDefrag(QFull, QEmpty, bag)
				end
			end
		end
		-- Now move the full items from the end to the empty spaces from the beginning
		for k in pairs(dustBag) do dustBag[k] = nil end
		_Defrag_Move(Full, Empty)
		_Defrag_Move(QFull, QEmpty)
		if (table.getn(dustBag) > 0) then
			MrPlow:Chat(L["Your bags rumble as Mr Plow gets busy and drives into your bags..."])
			MrPlow:RegisterEvents()
		else
			MrPlow:Chat(L["Mr Plow looks at your neat bags and shakes his head."])
		end	
		MrPlow:SwapIt()
	end
	self:Debug(string.format("Defrag: |cff80ff80%.3f sec|r |cffff8000(%d KiB)", GetTime() - t, gcinfo() - mem))
end

function MrPlow:SortAll(Bank)
	--[[
	-- For every item, I want to gather information about type/name/size and sort it in that order. Type will eventually be
	-- modifiable, but for now, lets get it working 
	--]]
	if (table.getn(dustBag) == 0) then
		local Pile = {}
		local SpecialPile = {}
		local Stuff = {}
		Stuff.mt = {}
		local NormalBlankSlate = {}
		local SpecialBlankSlate = {}
		local Lookup = {}
		local IndexLookup = {}
		local SIndexLookup = {}
		itemCount = 0

		function Stuff.new(num, ItemID, sbag, sslot)
			local stuff = {}
			setmetatable(stuff, Stuff.mt)
			stuff.OldPos = num
			stuff.itemName, stuff.itemLink, stuff.itemRarity, stuff.itemLevel, stuff.itemMinLevel, 
			stuff.itemType, stuff.itemSubType, stuff.itemStackCount, stuff.itemEquipLoc, stuff.itemTexture = GetItemInfo(ItemID)
			_, stuff.itemCount = GetContainerItemInfo(sbag, sslot)
			stuff.bag = -1
			stuff.bag = sbag
			stuff.slot = -1
			stuff.slot = sslot
			return stuff
		end
		
		function Stuff.Position(self,num)
			self.pos = num
		end
		
		function Stuff.mt.__tostring(stuff)
			return "Stuff: "..stuff.itemName.."("..stuff.itemLink..") at "..stuff.bag..":"..stuff.slot
		end

		function Stuff.mt.__lt(a, b)
			if (a.itemLink == b.itemLink) then
				if (a.itemCount < b.itemCount) then
					return true
				elseif(a.itemCount > b.itemCount) then
					return false
				else
					return a.OldPos < b.OldPos
				end
			end
	
			local ItemA = itemRanking[a.itemType] or -1
			local ItemB = itemRanking[b.itemType] or -1
			
			if (MrPlow.db.profile.Junk) then
				if(a.itemRarity == 0 and b.itemRarity > 0) then
					return false
				elseif (a.itemRarity > 0 and b.itemRarity == 0) then
					return true
				elseif(a.itemRarity == 0 and b.itemRarity == 0) then
					return a.itemName < b.itemName
				end
			end

			if ( ItemA < ItemB ) then
				return true
			elseif (ItemA == ItemB) then
				if (itemRanking[a.itemType] == itemCategories.TRADEGOODS) then
					local aSet = PT:ItemInSets(a.itemLink, "Materials") or {}
					local bSet = PT:ItemInSets(b.itemLink, "Materials") or {}
					if (table.getn(aSet) and table.getn(bSet)) then
						local aRank = ingredientRanking[aSet[1]] or -1
						local bRank = ingredientRanking[bSet[1]] or -1
						if(aRank < bRank) then
							return true
						elseif(aRank > bRank) then 
							return false
						end
					end
					return (a.itemName < b.itemName)

				elseif (itemRanking[a.itemType] == itemCategories.ARMOR or itemRanking[a.itemType] == itemCategories.WEAPON) then
					local aWep = armWepRank[a.itemEquipLoc] or -1
					local bWep = armWepRank[b.itemEquipLoc] or -1
					if( aWep == bWep) then
						if(a.itemRarity == b.itemRarity) then -- sort within by item rarity (common, etc) then itemLevel
							if(a.itemLevel == b.itemLevel) then
								return a.itemName < b.itemName
							else
								return a.itemLevel > b.itemLevel
							end
						else
							return a.itemRarity < b.itemRarity
						end
					else
						return aWep < bWep
					end
				elseif (itemRanking[a.itemType] == itemCategories.CONSUMABLE) then
					for i,v in ipairs(sortCategories) do
						local _, aitem = PT:ItemInSet(a.itemLink, v)
						local _, bitem = PT:ItemInSet(b.itemLink, v)
						if (bitem == nil and aitem ~= nil) then
							return false
						elseif (aitem == nil and bitem ~= nil) then
							return true
						end
					end
					return (a.itemName < b.itemName)
				end
				return (a.itemName < b.itemName)
			else
				return false
			end
		end

		local function _BagScan(Storage, bag, BlankSlate, IndexLookup)
			self:Debug("Scanning "..bag)
			for slot=1, GetContainerNumSlots(bag) do
				if(not(self.db.profile.IgnoreSlotList[bag] and self.db.profile.IgnoreSlotList[bag][slot]) and GetContainerItemLink(bag,slot)) then
					local _, _, link = string.find(GetContainerItemLink(bag,slot), "item:(%d+):%d+:%d+:%d+")

					if(not self.db.profile.IgnoreList[link]) then
						local item = Stuff.new(itemCount, link, bag, slot)
						itemCount = itemCount + 1
						table.insert(Storage, item)
						Lookup[bag.."-"..slot] = item
						table.insert(IndexLookup, table.getn(IndexLookup) + 1, bag.."-"..slot)
						table.insert(BlankSlate, {bag, slot})
					end
				end
			end
		end

		local function _BagShift(Pile, BlankSlate)
			local item = table.remove(Pile)
			while( item ) do
				if(not (item.bag == BlankSlate[item.pos][1] and item.slot == BlankSlate[item.pos][2])) then
					table.insert(dustBag, 1, { {item.bag, item.slot}, 
												{BlankSlate[item.pos][1], BlankSlate[item.pos][2]}}) -- Move the item into it's proper position
					local movedItem = Lookup[BlankSlate[item.pos][1].."-"..BlankSlate[item.pos][2]]
					movedItem.bag = item.bag
					movedItem.slot = item.slot
					Lookup[item.bag.."-"..item.slot] = movedItem
					for i,v in ipairs(Pile) do
						if (v == Lookup[IndexLookup[movedItem.pos]]) then
							table.insert(Pile, 1, table.remove(Pile, i))
							break
						end
					end
				end
				item = table.remove(Pile)
			end
		end

		local baglist

		if(Bank == L["Bank"] and bankAvailable) then
			baglist = MrPlow:GetBagList(true)
			plowingBank = true
		else
			if(Bank == L["Bank"] and not bankAvailable) then
				self:Print("Your Bank window is not open!")
				for k in pairs(theWorks) do theWorks[k] = nil end
				theWorksBank = nil
				return
			else
				baglist = MrPlow:GetBagList()
			end
		end
		
		for i,bag in pairs(baglist) do
			local specialBag
			if(bag > 0) then
				local bagslot = bag < 5 and bag + 19 or bag + 40
				if (bagslot ~= nil) then
					local bagTLink = GetInventoryItemLink("player",bagslot) or ""
					if (bagTLink ~= nil) then
						local _, _, bagLink = strfind(bagTLink, "(%d+):")
						if (bagLink) then
							specialBag = PT:ItemInSets(bagLink + 0, "Bags - Special")
						end
					end
				end
			end
			if(not specialBag) then
				_BagScan(Pile, bag, NormalBlankSlate, IndexLookup)
			else
				_BagScan(SpecialPile, bag, SpecialBlankSlate, SIndexLookup)
			end
		end
		self:Debug("Original size = "..table.getn(Pile) + table.getn(SpecialPile))
		table.sort(Pile)
		table.sort(SpecialPile)
		
		for i,v in ipairs(Pile) do v.pos = i end -- rejig the iteration
		for i,v in ipairs(SpecialPile) do v.pos = i end
		
		for k in pairs(dustBag) do dustBag[k] = nil end
		_BagShift(Pile, NormalBlankSlate)
		_BagShift(SpecialPile, SpecialBlankSlate)
		self:Debug("Final:"..table.getn(dustBag))

		if (table.getn(dustBag) > 0) then
			MrPlow:Chat(L["Your bags rumble as Mr Plow gets busy and drives into your bags..."])
			MrPlow:RegisterEvents()
		else
			MrPlow:Chat(L["Mr Plow looks at your neat bags and shakes his head."])
		end	

		MrPlow:SwapIt()
	end
end

function MrPlow:BankStack()
	if(not bankAvailable) then
		self:Print("Your Bank window is not open!")
		return
	end
	local bankContents = {}
	local bankbagContents = {}
	local bagContents = {}
	local bankSpace = {}
	
	local function _FindStacks(bankbag)
		bankbagContents[bankbag] = {}
		
		for slot=1, GetContainerNumSlots(bankbag) do
			if(GetContainerItemLink(bankbag,slot)) then
				local _, stackSize = GetContainerItemInfo(bankbag,slot)
				local _, _, link = string.find(GetContainerItemLink(bankbag,slot), "item:(%d+):%d+:%d+:%d+")
				local _, _, _, _, _, _, _, fullStack = GetItemInfo(link)
				if(not bankbagContents[bankbag][link]) then bankbagContents[bankbag][link] = slot end
				if(fullStack > 1 and fullStack == stackSize) then -- If this is a stackable item... and is a full stack, add it
					if(not bankContents[link]) then bankContents[link] = {0} end
				elseif(fullStack > 1 and fullStack ~= stackSize) then -- If this is stackable and not a full stack add or overwrite the current one
					if(not bankContents[link] or bankContents[link] == 0) then 
						bankContents[link] = {fullStack - stackSize, bankbag, slot} 
					end
				end
			else -- Add in as freespace
				if(not bankSpace[bankbag]) then bankSpace[bankbag] = {} end
				table.insert(bankSpace[bankbag], slot)
			end
		end
	end
	local function _FillStacks()
		for i,bag in ipairs(MrPlow:GetBagList()) do
			for slot=1, GetContainerNumSlots(bag) do
				if(GetContainerItemLink(bag,slot)) then
					local _, _, link = string.find(GetContainerItemLink(bag,slot), "item:(%d+):%d+:%d+:%d+")
					local _, stackSize = GetContainerItemInfo(bag,slot)
					if(link) then --Add to bagContents
						if(bankContents[link] and bankContents[link][1] ~= 0) then
							if(bankContents[link][1] < stackSize) then -- if there's a matched unfull stack, add to it with as big a stack as possible
								table.insert(dustBag, {{bag, slot, bankContents[link][1]}, 
									{bankContents[link][2], bankContents[link][3]}})
								bankContents[link][1] = 0
								stackSize = stackSize - bankContents[link][1]
							else
								table.insert(dustBag, {{bag, slot, stackSize}, 
									{bankContents[link][2], bankContents[link][3]}})
								bankContents[link][1] = bankContents[link][1] - stackSize
								stackSize = 0
							end
						end
						if(stackSize ~= 0) then
							if(not bagContents[link]) then bagContents[link] = {} end
							table.insert(bagContents[link], {bag, slot})
						end
					end
				end
			end
		end
	end
		-- We now have three tables, bankContents, bankSpace and bagContents.
	local function _OverflowBag(bankbag)
		if(bankSpace[bankbag]) then
			for i,v in ipairs(bankSpace[bankbag]) do
				for link, slot in pairs(bankbagContents[bankbag]) do
					if(bagContents[link] and table.getn(bagContents[link]) > 0) then
						local item = table.remove(bagContents[link])
						table.insert(dustBag, {{item[1], item[2]}, {bankbag, v}})
						table.remove(bankSpace[bankbag],i)
						if(table.getn(bankSpace[bankbag]) == 0) then bankSpace[bankbag] = nil end
						break
					end
				end
			end
		end
	end
	local function _OverflowRemainder()
		for bankBags, clearSpaces in pairs(bankSpace) do
			if(bankBags > 4) then
				local bagTLink = GetInventoryItemLink("player", bankBags + 63) or ""
				local _, _, bagLink = strfind(bagTLink, "(%d+):")
				specialBag = PT:ItemInSets(bagLink + 0, "Bags - Special")
			end
			if(not specialBag) then
				local dobreak = false
				for i, clearSlot in pairs(clearSpaces) do -- for each clear slot left.
					for link, _ in pairs(bankContents) do -- look in the bank
						self:Debug(link)
						if(bagContents[link] and table.getn(bagContents[link]) > 0) then -- check if our bags hold it.
							local item = table.remove(bagContents[link])
							if(bankSpace[bankBags][i]) then
								table.insert(dustBag, {{item[1], item[2]}, 
												{bankBags, clearSlot}})
							end
											
							bankSpace[bankBags][i] = nil
						dobreak = true
						break
						end
					end
				end
			end
		end
	end
	
	--Right, first we get all bank contents...
	if(bankAvailable) then
		local baglist = MrPlow:GetBagList(true)
		local bsstyle = self.db.profile.BankStackStyle
		for i,v in pairs(baglist) do
			_FindStacks(v)
		end
		_FillStacks()
		if(bsstyle >= 1) then
			for i,v in pairs(baglist) do
				_OverflowBag(v)
			end
		end
		if(bsstyle >= 2) then
			_OverflowRemainder()
		end

		if (table.getn(dustBag) > 0) then
			MrPlow:Chat(L["Your bags rumble as Mr Plow gets busy and drives into your bags..."])
			MrPlow:RegisterEvents()
		else
			MrPlow:Chat(L["Mr Plow looks at your neat bags and shakes his head."])
		end	
		MrPlow:SwapIt()
	end
end

function MrPlow:DelayCalled()
	delayCalled = true
	if (eventCalled) then
		MrPlow:SwapIt()
		delayCalled = false
		eventCalled = false
	end
end

function MrPlow:ScanEvent()
	count = count + 1
	if(math.mod(count,2) == 0) then
		eventCalled = true
	end
	if(eventCalled and delayCalled) then
		MrPlow:SwapIt()
		delayCalled = false
		eventCalled = false
	else
		delayCalled = false
		--self:ScheduleEvent("MrPlow", MrPlow.DelayCalled, 0.15, self) 
		self:ScheduleEvent("MrPlow", MrPlow.DelayCalled, 0, self) 
	end
end

function MrPlow:SwapIt()
	
	if(swapping) then
		return
	end
	if(plowingBank and not bankAvailable) then
		for k in pairs(dustBag) do dustBag[k] = nil end
		MrPlow:BANKFRAME_CLOSED()
		return
	end
	swapping = true
	self:Debug("Size is: "..table.getn(dustBag))
	if(table.getn(dustBag) > 0) then
		local detail = table.remove(dustBag)
		if(detail) then
			local from = detail[1]
			local to = detail[2]
			if (random(1,24)== 4) then
				MrPlow:Chat(during[random(1, table.getn(during))])
			end
			if(table.getn(from) == 3) then
				SplitContainerItem(from[1], from[2], from[3])
			else
				PickupContainerItem(from[1], from[2])
			end
			if(CursorHasItem()) then
				PickupContainerItem(to[1], to[2])
			end
			if(CursorHasItem()) then
				PickupContainerItem(from[1], from[2])	
			end
		end
	else
		MrPlow:UnregisterEvents()
		swapping = false
		plowingBank = false
		for k in pairs(dustBag) do dustBag[k] = nil end
		
		if(table.getn(theWorks) ~= 0) then
			func = table.remove(theWorks, 1)
			MrPlow[func](MrPlow, theWorksBank)
		else
			theWorksBank = nil
			MrPlow:Chat(L["As he drives off into the sunset, your bags deflate somewhat due to the extra room now available. That name again, is Mr Plow!"])
		end
	end
	swapping = false
end

function MrPlow:Chat(mess)
	if(not self.db.profile.Gag) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffeda55f"..mess.."|r")
	end
end

function MrPlow:GetBagList(bank)
	local bagList
	local ignoreList

	if(bank) then
		bagList = { -1, 5, 6, 7, 8, 9, 10, 11}
		ignoreList = self.db.profile.IgnoreBankBagList or nil
	else
		bagList = {0, 1, 2, 3, 4}
		ignoreList = self.db.profile.IgnoreBagList or nil
	end
	
	if(ignoreList) then
		for i,v in pairs(ignoreList) do
			bagList[i] = nil 
		end
	end
	return bagList
end


function MrPlow:ChangeIgnore(linklist, delete, purge)
	if(purge) then 
		self.db.profile.IgnoreList = {}
		self:Print(L["Mr Plow has cleared the ignore list"])
	else
		local link
		for link in string.gfind(linklist, "%bH|") do
			local _, _, itemID = string.find(link,"-*:(%d+):.*")
			if(itemID) then
				if(self.db.profile.IgnoreList[itemID]) then
					if(delete) then
						self.db.profile.IgnoreList[itemID] = nil
						self:Print(MrPlow:GetLink(itemID).." "..L["has been removed from the ignore list"])
					end
				else
					if(not delete) then
						self.db.profile.IgnoreList[itemID] = true
						self:Print(MrPlow:GetLink(itemID).." "..L["has been added to the ignore list"])
					end
				end
			end
		end
	end
	self.db.profile.IgnoreList = self.db.profile.IgnoreList
end

function MrPlow:ChangeSlotsIgnore(linklist, delete, purge)
	if(purge) then 
		self.db.profile.IgnoreSlotList = {}
		self:Print(L["Mr Plow has cleared the ignore list"])
	else
		local link
		for link in string.gfind(linklist, "(%-?%d+%-%d+)[,]*") do
			local _, _, bag, slot = string.find(link,"(%-?%d+)-(%d+)")
			bag, slot = tonumber(bag), tonumber(slot)
			if(bag and slot ) then
				if(self.db.profile.IgnoreSlotList[bag] and self.db.profile.IgnoreSlotList[bag][slot]) then
					if(delete) then
						self.db.profile.IgnoreSlotList[bag][slot] = nil
						self:Print(bag..","..slot.." "..L["has been removed from the ignore list"])
					end
				else
					if(not delete) then
						if(not self.db.profile.IgnoreSlotList[bag]) then self.db.profile.IgnoreSlotList[bag] = {} end
						self.db.profile.IgnoreSlotList[bag][slot] = true
						self:Print(bag..","..slot.." "..L["has been added to the ignore list"])
					end
				end
			end
		end
	end
	self.db.profile.IgnoreSlotList = self.db.profile.IgnoreSlotList
end

function MrPlow:ChangeBagIgnore(list, delete, purge, bankbag)
	if(purge) then
		if(bankbag) then self.db.profile.IgnoreBankBagList = {}
		else self.db.profile.IgnoreBagList = {} end
		self:Print(L["Mr Plow has cleared the ignore list"])
		return
	end
	self:Debug(list)
	for bag in string.gfind(list, "([0-7]),?") do
		if(bankbag) then
			if(delete) then
				self.db.profile.IgnoreBankBagList[bag + 1] = nil
				self:Print(bag.." "..L["has been removed from the ignore list"])
			else
				self.db.profile.IgnoreBankBagList[bag + 1] = true
				self:Print(bag.." "..L["has been added to the ignore list"])
			end
		else
			if(tonumber(bag) < 5) then
				if(delete) then
					self.db.profile.IgnoreBagList[bag + 1] = nil
					self:Print(bag.." "..L["has been removed from the ignore list"])
				else
					self.db.profile.IgnoreBagList[bag + 1] = true
					self:Print(bag.." "..L["has been added to the ignore list"])
				end
			end
		end
	end
end

function MrPlow:GetLink(linkInfo)
	local sName, sLink, iQuality = GetItemInfo(linkInfo)
	if (sName) then
		local _, _, _, color = GetItemQualityColor(iQuality)
		local linkFormat = "%s%s|h|r"
		return string.format(linkFormat, color, sLink)
	else
		return ""
	end
end

--[[ MrPlow ]]--
function MrPlow:OnTooltipUpdate()
	if(not self.db.profile.ClickToRun) then
		tablet:SetHint(L["|cffeda55fRight-Click|r for options."])
	else
		tablet:SetHint(L["|cffeda55fClick|r to run The Works on your bag, |cffeda55fShift-Click|r to run Bank The Works, |cffeda55fShift-Control-Click|r to run BankStack. |cffeda55fClick|r again to cancel."])
	end
end

function MrPlow:OnClick()
	if(not self.db.profile.ClickToRun) then
		return
	end
	if(table.getn(dustBag) == 0) then
		if(IsShiftKeyDown()) then
			if(IsControlKeyDown()) then
				MrPlow:BankStack()
			else
				MrPlow:Works(L["Bank"])
			end
		else
			MrPlow:Works()
		end
	else
		for k in pairs(dustBag) do dustBag[k] = nil end
		for k in pairs(theWorks) do theWorks[k] = nil end
		theWorksBank = nil
		MrPlow:Print(L["Stopping"])
	end
end


