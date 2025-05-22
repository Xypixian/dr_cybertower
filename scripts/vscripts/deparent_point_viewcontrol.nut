ClearGameEventCallbacks();

// hook game event just after entity spawn, avoiding ClearGameEventCallbacks
function OnPostSpawn() {
    __CollectGameEventCallbacks(this);

    // if the pvc somehow disappears anyway, respawn it
    if (Entities.FindByName(null, "cutscenecamera")) { return }
    else { SpawnEntityFromTable("point_viewcontrol", {
        targetname = "cutscenecamera"
        vscripts = "point_viewcontrol"
        spawnflags = 12
        origin = self.GetOrigin()
        acceleration = 500
        wait = 10
    })}
}

// clear parent on all cameras right before round restart
function OnGameEvent_scorestats_accumulated_update(params) {
	local camera = null;
    while (camera = Entities.FindByClassname(camera, "point_viewcontrol")) {
        EntFireByHandle(camera, "ClearParent", null, -1, null, null);
    }
}
