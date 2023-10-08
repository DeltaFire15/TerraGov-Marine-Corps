/datum/xeno_caste/warden
	caste_name = "Warden"
	display_name = "Warden"
	upgrade_name = ""
	caste_desc = ""
	caste_type_path = /mob/living/carbon/xenomorph/warden
	//tier = WARDEN-WIP TODO //Either T2 or T3
	upgrade = XENO_UPGRADE_BASETYPE
	//wound_type = TODO

	// *** Melee Attacks *** //
	melee_damage = 12

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS
	spit_types = list(/datum/ammo/xeno/thorn/regenerative, /datum/ammo/xeno/thorn/searing, /datum/ammo/xeno/thorn/draining)

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 400
	plasma_regen_limit = 0
	plasma_gain = 0
	plasma_icon_state = "fury" //WARDEN-WIP Make prismatic / resonance bar for this.

	// *** Health *** //
	//max_health = TODO

	// *** Evolution *** //
	//evolution_threshold = TODO existence depends on tier.
	//upgrade_threshold = TODO depends on tier.

	//deevolves_to = TODO

	// *** Flags *** //
	caste_flags = CASTE_PLASMADRAIN_IMMUNE|CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_LEADER
	caste_traits = null

	// *** Defense *** //
	//soft_armor = TODO - should probably be between Warrior and Spitter in defensive values.

	// *** Minimap Icon *** //
	//minimap_icon = TODO - What do I even use for this? Shield icon? Something similar to Defender line + drone?

	// *** Abilities *** //
	//TODO: Code the abilities!
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
	)

