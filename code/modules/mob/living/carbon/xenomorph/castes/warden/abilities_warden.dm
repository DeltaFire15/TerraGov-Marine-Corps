
/**
 * Special version of xeno spit, snowflaked. Might just write a completely new one to have radial selection, or just override that part of spit code
 * Xeno spit just uses a lot of code I'd copypaste in this.
**/
/datum/action/xeno_action/activable/xeno_spit/launch_thorn
	name = "Launch Thorn"
	//action_icon_state = TODO - Remember, this goes off the projectile's icon state and chooses a ability icon related to that one.
	desc = "Launch a Thorn at a target, applying a mark depending on type. Marks can later be detonated by melee attacks or resonance abilities, and will apply various effect when they do."
	spit_verb = "launch"
	quantifyable = TRUE
	cooldown_finish_message = "Our posture sharpens, ready to launch another thorn."
	var/selection_locked = FALSE //When using the primordial ability, your spit is locked to prismatic.

/datum/action/xeno_action/activable/xeno_spit/launch_thorn/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.selected_ability == src && selection_locked)
		to_chat(X, span_xenonotice("We are currently locked into one thorn type!"))
		return
	return ..()
