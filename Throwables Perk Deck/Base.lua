local ThrowablesPerkDeck_ModPath = ModPath

if ModCore then
	ModCore:new(ThrowablesPerkDeck_ModPath .. "Config.xml", true, true)
else
	Hooks:Add("LocalizationManagerPostInit", "ThrowablesPerkDeck_Loc", function(loc)
		loc:load_localization_file(ThrowablesPerkDeck_ModPath.."Loc/EN.txt")
	end)
end

_G.ThrowablesPerkDeck = _G.ThrowablesPerkDeck or {}

ThrowablesPerkDeck.NotiList = {
	{--fak
		desc_id = "hint_switch_throwables_fak",
		icon_id = "equipment_first_aid_kit"
	},
	{--armour
		desc_id = "hint_switch_throwables_armour",
		icon_id = "csb_armor"
	},
	{--knife
		desc_id = "hint_switch_throwables_knife",
		icon_id = "hobby_knife"
	},
	{--poison
		desc_id = "hint_switch_throwables_four",
		icon_id = "four_projectile"
	},
	{--big damage
		desc_id = "hint_switch_throwables_jav",
		icon_id = "jav_projectile"
	},
	{--stun
		desc_id = "hint_switch_throwables_concussion",
		icon_id = "concussion_grenade"
	},
	{--frag_com
		desc_id = "hint_switch_throwables_frag_com",
		icon_id = "frag_grenade"
	}
}
ThrowablesPerkDeck.tpd_id_List = {
	nil,
	nil,
	"wpn_prj_target",
	"wpn_prj_four",
	"wpn_prj_jav",
	"concussion",
	"frag_com"
}
ThrowablesPerkDeck.grenade_cooldown = {
	20,
	9,
	0.25,
	0.25,
	3,
	6,
	6
}

if BlackMarketManager then
	local function ThrowablesPerkDeck_Exchanage()
		local tpd_id = managers.player and managers.player:GetSwitchThrowables() or 0
		local tpd_id_List = ThrowablesPerkDeck.tpd_id_List
		if tpd_id_List[tpd_id] then
			return tpd_id_List[tpd_id], 1
		end
		return nil
	end

	local ThrowablesPerkDeck_BM_equipped_projectile = BlackMarketManager.equipped_projectile
	function BlackMarketManager:equipped_projectile(...)
		local Ans = ThrowablesPerkDeck_Exchanage()
		if not Ans then
			return ThrowablesPerkDeck_BM_equipped_projectile(self, ...)
		else
			return Ans
		end
	end
	
	local ThrowablesPerkDeck_BM_equipped_grenade = BlackMarketManager.equipped_grenade
	function BlackMarketManager:equipped_grenade(...)
		local Ans = ThrowablesPerkDeck_Exchanage()
		if not Ans then
			return ThrowablesPerkDeck_BM_equipped_grenade(self, ...)
		else
			return Ans
		end
	end
end

if PlayerManager then
	function PlayerManager:IsUsingSwitchThrowables()
		if not self:has_category_upgrade("player", "player_tool_box_switching") then
			return false
		end
		if managers.blackmarket:equipped_grenade() ~= "tool_box" then
			return false
		end
		return true
	end

	function PlayerManager:GetSwitchThrowables()
		if not self:has_category_upgrade("player", "player_tool_box_switching") then
			return 0
		end
		return self._SwitchThrowables or 0
	end

	function PlayerManager:SwitchThrowables()
		if not self:IsUsingSwitchThrowables() then
			return
		end
		self._SwitchThrowables = self:GetSwitchThrowables() + 1
		local NotiList = ThrowablesPerkDeck.NotiList
		if self._SwitchThrowables > #NotiList then
			self._SwitchThrowables = 1
		end		
		self._SwitchThrowables_Msg = 2
		if managers.hud and Utils:IsInHeist() then
			managers.hud:set_teammate_grenades(HUDManager.PLAYER_PANEL, {
				amount = self:can_throw_grenade() and 1 or 0,
				icon = NotiList[self._SwitchThrowables].icon_hud_id or NotiList[self._SwitchThrowables].icon_id
			})
		end
	end

	ThrowablesPerkDeck_upgrade_value = ThrowablesPerkDeck_upgrade_value or PlayerManager.upgrade_value
	function PlayerManager:upgrade_value(category, upgrade, ...)
		local Ans = ThrowablesPerkDeck_upgrade_value(self, category, upgrade, ...)
		if category == "player" and upgrade == "extra_ammo_multiplier" then
			Ans = Ans * self:upgrade_value("player", "player_tool_box_loss_ammo", 1)
		end
		return Ans
	end
	
	Hooks:PostHook(PlayerManager, "update", "ThrowablesPerkDeck_loop_timer", function(self, t, dt)
		if not Utils:IsInHeist() then
			return
		end
		if not self:IsUsingSwitchThrowables() then
			return
		end
		if self._SwitchThrowables_Msg then
			self._SwitchThrowables_Msg = self._SwitchThrowables_Msg - dt
			if self._SwitchThrowables_Msg <= 0 then
				self._SwitchThrowables_Msg = nil
				if HudChallengeNotification and managers.hud then
					local NotiList = ThrowablesPerkDeck.NotiList
					HudChallengeNotification.queue(
						managers.localization:to_upper_text("hint_switch_throwables_perk_deck"),
						managers.localization:to_upper_text(NotiList[self._SwitchThrowables].desc_id),
						NotiList[self._SwitchThrowables].icon_id
					)
					managers.hud:set_teammate_grenades(HUDManager.PLAYER_PANEL, {
						amount = self:can_throw_grenade() and 1 or 0,
						icon = NotiList[self._SwitchThrowables].icon_hud_id or NotiList[self._SwitchThrowables].icon_id
					})
				end
			end	
		end
		if not self._SwitchThrowables and self._global and self._global.synced_grenades then
			self:SwitchThrowables()
			self:add_grenade_amount(-1, true)
			self:speed_up_grenade_cooldown(-1)
		end
	end)

	Hooks:PostHook(PlayerManager, "add_grenade_amount", "ThrowablesPerkDeck_add_grenade_amount", function(self, amount, finger_gun)
		if self:player_unit() and alive(self:player_unit()) and amount == -1 then
			if self:IsUsingSwitchThrowables() then
				local PlyStandard = self:player_unit() and self:player_unit():movement() and self:player_unit():movement()._states.standard or nil
				if PlyStandard then
					local tpd_id = self:GetSwitchThrowables()
					local grenade_cooldown = ThrowablesPerkDeck.grenade_cooldown
					if tpd_id == 1 then
						self:player_unit():character_damage():band_aid_health()
					elseif tpd_id == 2 then
						self:player_unit():character_damage():_regenerate_armor()
					end
					if finger_gun then
						self:speed_up_grenade_cooldown(-1)
					elseif grenade_cooldown[tpd_id] then
						self:speed_up_grenade_cooldown(-grenade_cooldown[tpd_id])
					end
				end
			end
		end
	end)
end

if PlayerStandard then
	Hooks:PostHook(PlayerStandard, "_start_action_intimidate", "ThrowablesPerkDeck_Perk7_Hunter", function(self, t, secondary)
		if not managers.player:IsUsingSwitchThrowables() then
			return
		end
		if not managers.player:can_throw_grenade() or managers.player:has_active_timer("replenish_grenades") then
			return
		end
		local skip_alert = managers.groupai:state():whisper_mode()
		if skip_alert then
			return
		end
		local voice_type, plural, prime_target = self:_get_unit_intimidation_action(not secondary, not secondary, true, false, true, nil, nil, nil, secondary)
		if prime_target and prime_target.unit and prime_target.unit.base and (prime_target.unit:base().unintimidateable or prime_target.unit:anim_data() and prime_target.unit:anim_data().unintimidateable) then
			return
		end
		if type(voice_type) ~= "string" then
			return
		end
		local interact_type, sound_name = nil
		local sound_suffix = plural and "plu" or "sin"
		if (voice_type == "mark_cop" or voice_type == "stop_cop") then
			if prime_target.unit and prime_target.unit.character_damage then
				local player_unit = managers.player:player_unit()
				local weapon_unit = managers.player:equipped_weapon_unit()
				if player_unit and weapon_unit then
					local mvec_from_pos = prime_target.unit:position() + Vector3(0, 0, 10)
					local mvec_direction = Vector3(0, 0, -1)
					if Network:is_client() then
						local projectile_type_index = tweak_data.blackmarket:get_index_from_projectile_id("long_arrow_exp")
						managers.network:session():send_to_host("request_throw_projectile", projectile_type_index, mvec_from_pos, mvec_direction)
					else
						local unit = ProjectileBase.throw_projectile("long_arrow_exp", mvec_from_pos, mvec_direction, managers.network:session():local_peer():id())
						unit:base()._weapon_damage_mult = 1
						unit:base()._weapon_charge_value = 1
						unit:base()._weapon_speed_mult = 1
						unit:base()._weapon_charge_fail = false
					end
					local Ncooldown = ThrowablesPerkDeck.grenade_cooldown[managers.player:GetSwitchThrowables()]
					managers.player:add_grenade_amount(-1, true, true)
				end
			end
		end
	end)
end

if PlayerDamage then
	Hooks:PostHook(PlayerDamage, "_regenerate_armor", "ThrowablesPerkDeck_regenerate_armor", function(self)
		if not managers.player:IsUsingSwitchThrowables() then
			return
		end
		self._ThrowablesPerkDeck_Perk9 = nil
	end)

	Hooks:PreHook(PlayerDamage, "_on_damage_event", "ThrowablesPerkDeck_Perk9_FireCounter", function(self)
		if not managers.player:IsUsingSwitchThrowables() then
			return
		end
		if self._ThrowablesPerkDeck_Perk9 then
			return
		end
		local weapon_unit = managers.player:equipped_weapon_unit()
		if not weapon_unit then
			return
		end
		if not managers.player:has_category_upgrade("player", "player_tool_box_unknown") then
			return
		end
		local armor_broken = self:_max_armor() > 0 and self:get_real_armor() <= 0
		if not armor_broken then
			return
		end
		local units = World:find_units("sphere", self._unit:position(), 1000, managers.slot:get_mask("enemies"))
		if type(units) ~= "table" then
			return
		end
		for _, funit in ipairs(units) do
			if funit and funit:character_damage() and funit:character_damage().damage_fire then
				local fdmg = self:_max_armor() or 1
				fdmg = math.max(fdmg / 10, 1)
				funit:character_damage():damage_fire({
					damage = fdmg,
					attacker_unit = self._unit,
					weapon_unit = weapon_unit,
					is_molotov = "fir_com",
					is_fire_dot_damage = false,
					variant = "fire",
					fire_dot_data = {
							dot_trigger_chance = 100,
							dot_damage = 25,
							dot_length = 3,
							dot_trigger_max_distance = 3000,
							dot_tick_period = 0.5
					},
					col_ray = {
						position = funit:position(),
						hit_position = funit:position(),
						ray = Vector3(0, 0, -1)
					}
				})
				self._ThrowablesPerkDeck_Perk9 = true
			end
		end
	end)
	
	Hooks:PostHook(PlayerDamage, "init", "ThrowablesPerkDeck_load_package", function(self)
		for _, d in pairs(ThrowablesPerkDeck.tpd_id_List) do
			local data = tweak_data.blackmarket.projectiles[d]
			if data then
				local unit_name = Idstring(not Network:is_server() and data.local_unit or data.unit)
				if not managers.dyn_resource:is_resource_ready(Idstring("unit"), unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
					managers.dyn_resource:load(Idstring("unit"), unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE)
				end
			end
		end
	end)
	
	Hooks:PostHook(PlayerDamage, "_on_enter_swansong_event", "ThrowablesPerkDeck_on_enter_swansong_event", function(self)
		if not managers.player:IsUsingSwitchThrowables() then
			return
		end
		if managers.player:has_active_timer("replenish_grenades") then
			managers.player:speed_up_grenade_cooldown(999)
		end		
	end)
end

if BlackMarketTweakData then
	Hooks:PostHook(BlackMarketTweakData, "_init_projectiles", "ThrowablesPerkDeck_init_projectiles", function(self, tweak_data)
		self.projectiles.tool_box = deep_clone(self.projectiles.concussion)
		
		self.projectiles.tool_box.name_id = "bm_grenade_tool_box"
		self.projectiles.tool_box.desc_id = "bm_grenade_tool_box_desc"
		self.projectiles.tool_box.icon = "equipment_bfd_tool"
		self.projectiles.tool_box.ability = true
		self.projectiles.tool_box.throwable = nil
		self.projectiles.tool_box.texture_bundle_folder = "tool_box"
		self.projectiles.tool_box.max_amount = 1
		self.projectiles.tool_box.base_cooldown = 0.01
		self.projectiles.tool_box.sounds = {cooldown = "perkdeck_cooldown_over"}
		
	end)
end

if PlayerEquipment then
	local ThrowablesPerkDeck_throw_grenade = PlayerEquipment.throw_grenade
	function PlayerEquipment:throw_grenade(...)
		local ST = managers.player:GetSwitchThrowables()
		local grenade_name = ThrowablesPerkDeck.tpd_id_List[ST]
		if grenade_name then
			local from = self._unit:movement():m_head_pos()
			local pos = from + self._unit:movement():m_head_rot():y() * 30 + Vector3(0, 0, 0)
			local dir = self._unit:movement():m_head_rot():y()			
			local grenade_tweak = tweak_data.blackmarket.projectiles[grenade_name]
			if grenade_tweak then
				local unit_name = not Network:is_server() and grenade_tweak.local_unit or grenade_tweak.unit
				unit_name = Idstring(unit_name)
				if DB:has(Idstring("unit"), unit_name) then
					if not managers.dyn_resource:is_resource_ready(Idstring("unit"), unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
						managers.dyn_resource:load(Idstring("unit"), unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, callback(self, self, "throw_grenade"))
					else
						local unit = World:spawn_unit(unit_name, pos, Rotation(dir, math.UP))
						if unit and alive(unit) then
							unit:base():throw({
								dir = dir,
								projectile_entry = grenade_name
							})
							if grenade_tweak.impact_detonation then
								unit:damage():add_body_collision_callback(callback(unit:base(), unit:base(), "clbk_impact"))
								unit:base():create_sweep_data()
							end
						end
					end
				end
			end
		end
		if ST > 0 then
			managers.player:on_throw_grenade()
			return
		end
		ThrowablesPerkDeck_throw_grenade(self, ...)
	end
end

if UpgradesTweakData then
	Hooks:PostHook(UpgradesTweakData, "_grenades_definitions", "ThrowablesPerkDeck_grenades_definitions", function(self)
		self.definitions.tool_box = {category = "grenade"}
	end)
	
	Hooks:PostHook(UpgradesTweakData, "_player_definitions", "ThrowablesPerkDeck_player_definitions", function(self)
		self.values.player.player_tool_box_loss_ammo = {
			0
		}
		self.definitions.player_tool_box_loss_ammo = {
			name_id = "player_tool_box_loss_ammo",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "player_tool_box_loss_ammo",
				category = "player"
			}
		}	
		self.values.player.player_tool_box_switching = {1}
		self.definitions.player_tool_box_switching = {
			name_id = "player_tool_box_switching",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "player_tool_box_switching",
				category = "player"
			}
		}		
		self.values.temporary.berserker_damage_multiplier[3] = {
			1,
			20
		}
		self.definitions.player_tool_box_backup = {
			name_id = "player_tool_box_backup",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "berserker_damage_multiplier",
				category = "temporary"
			}
		}
		self.values.player.player_tool_box_hunter = {1}
		self.definitions.player_tool_box_hunter = {
			name_id = "player_tool_box_hunter",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "player_tool_box_hunter",
				category = "player"
			}
		}
		self.values.player.player_tool_box_unknown = {1}
		self.definitions.player_tool_box_unknown = {
			name_id = "player_tool_box_unknown",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "player_tool_box_unknown",
				category = "player"
			}
		}
	end)
end

if SkillTreeTweakData then
	Hooks:PostHook(SkillTreeTweakData, "init", "HackerPerkDeck_SkillTree_Init", function(self)
		local deck2 = {
			cost = 0,
			desc_id = "empty_perk_desc",
			name_id = "menu_deckall_2",
			upgrades = {"weapon_passive_headshot_damage_multiplier"},
			icon_xy = {
				1,
				0
			}
		}
		local deck4 = {
			cost = 0,
			desc_id = "empty_perk_desc",
			name_id = "menu_deckall_4",
			upgrades = {
				"passive_player_xp_multiplier",
				"player_passive_suspicion_bonus",
				"player_passive_armor_movement_penalty_multiplier"
			},
			icon_xy = {
				3,
				0
			}
		}
		local deck6 = {
			cost = 0,
			desc_id = "empty_perk_desc",
			name_id = "menu_deckall_6",
			upgrades = {
				"armor_kit",
				"player_pick_up_ammo_multiplier"
			},
			icon_xy = {
				5,
				0
			}
		}
		local deck8 = {
			cost = 0,
			desc_id = "empty_perk_desc",
			name_id = "menu_deckall_8",
			upgrades = {
				"weapon_passive_damage_multiplier",
				"passive_doctor_bag_interaction_speed_multiplier"
			},
			icon_xy = {
				7,
				0
			}
		}
		table.insert(self.specializations, {
				custom = true,
				custom_id = "Throwables",
				name_id = "throwables_perk_name",
				desc_id = "throwables_perk_desc",
				{
					custom = true,
					upgrades = {
						"tool_box",
						"player_tool_box_loss_ammo"
					},
					cost = 0,
					texture_bundle_folder = "tool_box",
					icon_xy = {
						0,
						0
					},
					name_id = "throwables_tier_1_name",
					desc_id = "throwables_tier_1_desc"
				},
				deck2,
				{
					custom = true,
					upgrades = {
						"player_tool_box_switching"
					},
					cost = 0,
					texture_bundle_folder = "tool_box",
					icon_xy = {
						1,
						0
					},
					name_id = "throwables_tier_3_name",
					desc_id = "throwables_tier_3_desc"
				},
				deck4,
				{
					custom = true,
					upgrades = {
						"player_tool_box_backup"
					},
					cost = 0,
					texture_bundle_folder = "tool_box",
					icon_xy = {
						2,
						0
					},
					name_id = "throwables_tier_5_name",
					desc_id = "throwables_tier_5_desc"
				},
				deck6,
				{
					custom = true,
					upgrades = {
						"player_tool_box_hunter"
					},
					cost = 0,
					texture_bundle_folder = "tool_box",
					icon_xy = {
						3,
						0
					},
					name_id = "throwables_tier_7_name",
					desc_id = "throwables_tier_7_desc"
				},
				deck8,
				{
					custom = true,
					upgrades = {
						"player_tool_box_unknown"
					},
					cost = 0,
					texture_bundle_folder = "tool_box",
					icon_xy = {
						0,
						1
					},
					name_id = "throwables_tier_9_name",
					desc_id = "throwables_tier_9_desc"
				}
			}
		)
	end)
end

if NetworkMatchMakingSTEAM then
	local Block_set_attributes_original = NetworkMatchMakingSTEAM.set_attributes
	function NetworkMatchMakingSTEAM:set_attributes(settings, ...)
		if settings.numbers[3] < 3 then
			settings.numbers[3] = 3
		end
	end

	local Block_is_server_ok_original = NetworkMatchMakingSTEAM.is_server_ok
	function NetworkMatchMakingSTEAM:is_server_ok(friends_only, room, attributes_list, is_invite)
		if attributes_list.numbers and attributes_list.numbers[3] < 3 then
			return false
		end
	end
end

if StatisticsManager then
	local ThrowablesPerkDeck_killed_by_anyone = StatisticsManager.killed_by_anyone
	function StatisticsManager:killed_by_anyone(data, ...)
		if not alive(data.weapon_unit) or not data.weapon_unit:base().get_name_id then
			return
		end
		ThrowablesPerkDeck_killed_by_anyone(self, data, ...)
	end
end