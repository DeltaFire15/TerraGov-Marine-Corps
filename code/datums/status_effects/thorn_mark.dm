//This status effect is quite expansive and is linked to one specific caste, so I felt its own file was warranted.

/datum/status_effect/thorn_mark
	id = "thorn_mark"
	tick_interval = 1 SECONDS
	alert_type = null //No direct alert. Work on colored particles from alchemy.
	///The owner of the debuff, always human.
	var/mob/living/carbon/human/debuff_owner
	///When this status will decay. Starts 20 seconds after the last interaction with it, and loses one stack every 5 seconds after.
	var/next_decay = 0
	///Max amount of stacks per type.
	var/stack_cap = 5
	//Thorn marks by type:
	var/regenerative_stacks = 0
	var/searing_stacks = 0
	var/draining_stacks = 0

	///List of wardens that applied stacks. Maintained via listening to qdel signals. Determines who gets resonance if marks get detonated.
	var/list/wardens = list()

	/// Particle holder, shows everyone what exactly your fate is if your marks trigger.
	var/obj/effect/abstract/particle_holder/particle_holder //TODO!!!!!!

/datum/status_effect/thorn_mark/on_creation(mob/living/new_owner)
	if(!ishuman(new_owner)) //Guh?
		qdel(src)
		return
	. = ..()
	debuff_owner = new_owner
	next_decay = world.time + 20 SECONDS
	RegisterSignal(debuff_owner, COMSIG_HUMAN_ATTACKEDBY_XENO, PROC_REF(try_detonating))

/datum/status_effect/thorn_mark/on_remove()
	UnregisterSignal(debuff_owner, COMSIG_HUMAN_ATTACKEDBY_XENO)
	for(var/warden as anything in wardens)
		cleanse_warden_ref(warden)
	wardens = null
	debuff_owner = null
	return ..()

/datum/status_effect/thorn_mark/tick()
	. = ..()
	if(next_decay < world.time)
		next_decay += 5 SECONDS
		remove_stack_tier()

/datum/status_effect/thorn_mark/proc/add_stacks(mob/living/carbon/xenomorph/applier, regenerative = 0, searing = 0, draining = 0)
	if(!QDELETED(applier))
		if(!wardens[applier])
			RegisterSignal(applier, COMSIG_QDELETING, PROC_REF(cleanse_warden_ref))
			wardens[applier] = 0
		wardens[applier] += 1
	if(regenerative)
		regenerative_stacks = min(regenerative_stacks + regenerative, stack_cap)
	if(searing)
		searing_stacks = min(searing_stacks + searing, stack_cap)
	if(draining)
		draining_stacks = min(draining_stacks + draining, stack_cap)
	next_decay = world.time + 20 SECONDS

/datum/status_effect/thorn_mark/proc/remove_stack_tier()
	regenerative_stacks = max(0, regenerative_stacks - 1)
	searing_stacks = max(0, searing_stacks - 1)
	draining_stacks = max(0, draining_stacks -1)

	var/list/wardens_to_remove = list()
	for(var/warden as anything in wardens)
		wardens[warden] -= 1
		if(wardens[warden] <= 0)
			wardens_to_remove += warden
	for(var/warden as anything in wardens_to_remove)
		cleanse_warden_ref(warden)

	if(!regenerative_stacks && !searing_stacks && !draining_stacks)
		qdel(src) //No more stacks, no reason to keep track of this.


/datum/status_effect/thorn_mark/proc/try_detonating(mob/living/carbon/human/marked, mob/living/carbon/xenomorph/detonator)
	SIGNAL_HANDLER
	//TODO
	var/resonance_boost = 0
	var/burst_color = "#000000" //should never be black
	var/list/mob/living/carbon/xenomorph/benefitting = cheap_get_xenos_near(detonator, 2)
	//Kind of cursed if chain, is there a better way?

	//WARDEN-WIP: Move the actual effect applications out of this proc; It as effects are also applied by other abilities. Instead hand that proc which stacks are present, and the affected mobs!
	//WARDEN-WIP: SERIOUSLY CHANGE THE WAY THIS ITERATES, go off proc -> per xeno iter, instead of doing this MANY loops (worst case)
	//Base effects
	if(regenerative_stacks)
		resonance_boost++
		burst_color = "#16e40fcc"
		for(var/mob/living/carbon/xenomorph/healed as anything in benefitting)
			var/heal_amount = round(healed.xeno_caste.max_health * 0.05, 0.1) //5% flat
			healed.heal_wounds(override = heal_amount)
	if(searing_stacks)
		resonance_boost++
		marked.apply_status_effect(/datum/status_effect/stacking/melting, 2) //Perhaps 3, would be 15 damage
		burst_color = "#e21313d0"
	if(draining_stacks)
		resonance_boost++
		marked.adjust_stagger(1.5 SECONDS)
		burst_color = "#1644ddd0"

	//Alchemy
	if(regenerative_stacks && searing_stacks)
		burst_color = "#f7f317e8"
		marked.apply_damage(5, BURN, blocked = FIRE)
		for(var/mob/living/carbon/xenomorph/bonus_healed as anything in benefitting)
			bonus_healed.apply_status_effect(/datum/status_effect/stacking/burning_recovery, 5) //1% bonus healing per second, for 5 seconds.
	if(regenerative_stacks && draining_stacks)
		burst_color = "#40dbe0ce"
		for(var/mob/living/carbon/xenomorph/bonus_protected as anything in benefitting)
			bonus_protected.apply_status_effect(/datum/status_effect/stacking/absorbed_resilience, 30) //protection against 3 seconds worth of debilitating effects.
	if(searing_stacks && draining_stacks)
		burst_color = "#a51acfc0"
		marked.adjust_slowdown(3)
		for(var/mob/living/carbon/xenomorph/bonus_invigorated as anything in benefitting) //Speed for 3 seconds - target gains 3 stacks of slow.
			bonus_invigorated.apply_status_effect(/datum/status_effect/searing_momentum)
	//Primatic
	if(regenerative_stacks && searing_stacks && draining_stacks)
		burst_color = "#dfdfdfdc"
		for(var/mob/living/carbon/xenomorph/bonus_shielded as anything in benefitting) //Bonus shielding for combining all three effects on a detonation.
			adjustOverheal(bonus_shielded, 50)
	for(var/warden_key as anything in wardens)
		var/mob/living/carbon/xenomorph/warden = wardens[warden_key]
		warden.gain_plasma(10 * resonance_boost)
	display_burst(marked, detonator, burst_color)
	remove_stack_tier()

/datum/status_effect/thorn_mark/proc/display_burst(mob/living/carbon/human/marked, mob/living/carbon/xenomorph/detonator)
	//TODO: Display a fancy colored effect burst around the detonator

/datum/status_effect/thorn_mark/proc/cleanse_warden_ref(mob/living/carbon/xenomorph/referenced)
	SIGNAL_HANDLER
	wardens -= referenced
	UnregisterSignal(referenced, COMSIG_QDELETING)
