/obj/structure/lattice
	name = "lattice"
	desc = "A lightweight support lattice."
	icon = 'icons/obj/structures.dmi'
	icon_state = "latticefull"
	density = 0
	anchored = 1.0
	w_class = ITEM_SIZE_NORMAL
	layer = LATTICE_LAYER
	//	obj_flags = OBJ_FLAG_CONDUCTIBLE

/obj/structure/lattice/Initialize()
	. = ..()
///// Z-Level Stuff
	if(!(istype(src.loc, /turf/space) || istype(src.loc, /turf/simulated/open)))
///// Z-Level Stuff
		return INITIALIZE_HINT_QDEL
	for(var/obj/structure/lattice/LAT in loc)
		if(LAT != src)
			util_crash_with("Found multiple lattices at '[log_info_line(loc)]'")
			return INITIALIZE_HINT_QDEL
	icon = 'icons/obj/smoothlattice.dmi'
	icon_state = "latticeblank"
	updateOverlays()
	for (var/dir in GLOB.cardinal)
		var/obj/structure/lattice/L
		if(locate(/obj/structure/lattice, get_step(src, dir)))
			L = locate(/obj/structure/lattice, get_step(src, dir))
			L.updateOverlays()

/obj/structure/lattice/Destroy()
	for (var/dir in GLOB.cardinal)
		var/obj/structure/lattice/L
		if(locate(/obj/structure/lattice, get_step(src, dir)))
			L = locate(/obj/structure/lattice, get_step(src, dir))
			L.updateOverlays(src.loc)
	. = ..()

/obj/structure/lattice/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			qdel(src)
			return
		if(3.0)
			return
	return

/obj/structure/lattice/attackby(obj/item/C as obj, mob/user as mob)

	if(istype(C, /obj/item/stack/tile/floor) || istype(C, /obj/item/stack/tile/floor_rough))
		var/turf/T = get_turf(src)
		T.attackby(C, user) //BubbleWrap - hand this off to the underlying turf instead
		return
	if(isWelder(C))
		var/obj/item/weldingtool/WT = C
		if(!WT.use_tool(src, user, amount = 1))
			return

		to_chat(user, SPAN_NOTICE("Slicing lattice joints."))
		new /obj/item/stack/rods(loc)
		qdel(src)

	if (istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		if(R.use(2))
			src.alpha = 0
			playsound(src, 'sound/effects/fighting/Genhit.ogg', 50, 1)
			new /obj/structure/catwalk(src.loc)
			qdel(src)
			return
		else
			to_chat(user, "<span class='notice'>You require at least two rods to complete the catwalk.</span>")
			return
	return

/obj/structure/lattice/proc/updateOverlays()
	//if(!(istype(src.loc, /turf/space)))
	//	qdel(src)
	spawn(1)
		ClearOverlays()

		var/dir_sum = 0

		var/turf/T
		for (var/direction in GLOB.cardinal)
			T = get_step(src, direction)
			if(locate(/obj/structure/lattice, T) || locate(/obj/structure/catwalk, T))
				dir_sum += direction
			else
				if(!(istype(get_step(src, direction), /turf/space)) && !(istype(get_step(src, direction), /turf/simulated/open)))
					dir_sum += direction

		icon_state = "lattice[dir_sum]"
		return

/obj/structure/lattice/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_TURF)
		return list("delay" = 0, "cost" = the_rcd.rcd_design_path == /obj/structure/catwalk ? 2 : 1)

	return FALSE

/obj/structure/lattice/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(rcd_data["[RCD_DESIGN_MODE]"] == RCD_TURF)
		var/design_structure = rcd_data["[RCD_DESIGN_PATH]"]
		if(design_structure == /turf/simulated/floor/plating)
			var/turf/T = get_turf(src)
			T.ChangeTurf(/turf/simulated/floor/plating)
			qdel_self()
			return TRUE

		if(design_structure == /obj/structure/catwalk)
			var/turf/turf = loc
			qdel_self()
			new /obj/structure/catwalk(turf)
			return TRUE

	return FALSE
