function OnPostSpawn() {
    CurrentSequence <- "nil";
    DisableThinking <- false;
    AddThinkToEnt(self, "BossThink")
    PreparingForSyncedAction <- false;
    RegularActionProbability <- 20 // higher = less likely
    SyncedActionProbability <- 150; // higher = less likely
    HeadNumber <- 0;
    HeadsBusy <- [false, false, false] // false = idling
    AwaitingCinematicAction <- false;
    CinematicActionPending <- "nil"

    // get indexes of all sequences to vars for ease of use
    seqRage <- self.LookupSequence("rage");
    seqIdle <- self.LookupSequence("idle");
    seqSlam <- self.LookupSequence("slam");
    seqVertLas <- self.LookupSequence("verticallaser");
    seqWideLas <- self.LookupSequence("widelaser");
    seqFlatLas <- self.LookupSequence("flatlaser");
    seqFireLas <- self.LookupSequence("firelaser");
    seqIntro <- self.LookupSequence("intro");
    seqDeath <- self.LookupSequence("death");
    seqHurt <- self.LookupSequence("hurt");

    switch (self.GetName()) {
        case "thehead1": {
            wideLasP <- Entities.FindByName(null, "finalboss_head1_biglaserp");
            wideLasH <- Entities.FindByName(null, "finalboss_head1_widelaserH");
            flatLasP <- Entities.FindByName(null, "finalboss_head1_flatlaserp");
            fireLasP <- Entities.FindByName(null, "finalboss_head1_firelaserp");
            HeadNumber = 0;
            break;
        }
        case "thehead2": {
            wideLasP <- Entities.FindByName(null, "finalboss_head2_biglaserp");
            wideLasH <- Entities.FindByName(null, "finalboss_head2_widelaserH");
            flatLasP <- Entities.FindByName(null, "finalboss_head2_flatlaserp");
            fireLasP <- Entities.FindByName(null, "finalboss_head2_firelaserp");
            HeadNumber = 1;
            break;
        }
        case "thehead3": {
            wideLasP <- Entities.FindByName(null, "finalboss_head3_biglaserp");
            wideLasH <- Entities.FindByName(null, "finalboss_head3_widelaserH");
            flatLasP <- Entities.FindByName(null, "finalboss_head3_flatlaserp");
            fireLasP <- Entities.FindByName(null, "finalboss_head3_firelaserp");
            HeadNumber = 2;
            break;
        }
    }
}

function Precache() { 
    NetProps.SetPropBool(self, "m_bClientSideAnimation", false);
    // ClientPrint(GetListenServerHost(), 3, "Set netprops.");
}

// general function called by OnUser2, which is fired by animation events at certain times to keep things easily synced.
// check the current sequence when the input is fired, and then do the corresponding shit.
function SoundOnHead() {
    CurrentSequence = self.GetSequence();
    switch (CurrentSequence) {
        case seqRage: {
            EntFire("gamerules", "PlayVO", "Cybertower.BossRoarRage", -1, self);
            EntFire("finalboss_fallingfloor", "FireUser1", "", -1, self);
            break;
        }
        case seqIdle: {
            break;
        }
        case seqSlam: {
            wideLasP.EmitSound("Cybertower.SlamRoar"); // using this because its in the center of the head. good place to play a sound from.
            EntFireByHandle(self, "RunScriptCode", "wideLasP.EmitSound(`Cybertower.BossSlam`)", 1.1, self, self);
            EntFireByHandle(self, "CallScriptFunction", "DoSlamImpact", 1.1, self, self);
            EntFire("globalshake_severeLong", "StartShake", "", 1.1, self);
            break;
        }
        case seqDeath: {
            EntFire("gamerules", "PlayVO", "Cybertower.BossDeath", -1, self);
            break;
        }
        case seqHurt: {
            wideLasP.EmitSound("Cybertower.BossHurt");
            break;
        }
        case seqFlatLas: {
            EntFireByHandle(flatLasP, "Start", "", 0.94, self, self);
            EntFireByHandle(flatLasP, "FireUser1", "", 2.84, self, self);
            EntFireByHandle(self, "RunScriptCode", "wideLasP.EmitSound(`Cybertower.BossFlatLaser`)", 0.5, self, self);
            EntFireByHandle(flatLasP, "Stop", "", 3.24, self, self);
            break;
        }
        case seqFireLas: {
            EntFireByHandle(fireLasP, "Start", "", -1, self, self);
            fireLasP.EmitSound("Cybertower.BossFireLaser1");
            EntFireByHandle(fireLasP, "FireUser1", "", 2.5, self, self);
            EntFireByHandle(fireLasP, "Stop", "", 3.5, self, self);
            break;
        }
    }
}

// damage players close to the head, launch people upward at mid range
function DoSlamImpact() {
    local plyr = null;
    local selfOrg = self.GetBoneOrigin(self.LookupBone("head"));
    while (plyr = Entities.FindByClassnameWithin(plyr, "player", selfOrg, 900)) {
        if ((plyr.GetOrigin() - selfOrg).Length() < 450) {
            plyr.TakeDamage(600, 1, self);
            // ClientPrint(GetListenServerHost(), 3, "Dealt damage to " + plyr.GetName());
        }
        else { plyr.ApplyAbsVelocityImpulse(Vector(0, 0, 1000)); }
    }
}

function BossThink() {
    if (DisableThinking) { return; }
    // Don't bother doing anything if we aren't idle.
    CurrentSequence = self.GetSequence();
    if (CurrentSequence == seqIdle) {
        if (AwaitingCinematicAction == true) {
            AwaitingCinematicAction = false;
            DisableThinking = true;
            DoCinematicAction();
            return;
        }
        HeadsBusy[HeadNumber] = false; // If you're idling, you aren't busy. Used only for synced actions, and it sets true when a solo action starts.
        // Randomly roll for an action.
        if (RandomInt(0, RegularActionProbability) == RegularActionProbability) {
            // If we're preparing for a synced action, don't actually do anything.
            if (!PreparingForSyncedAction) {
                HeadsBusy[HeadNumber] = true;
                DoRandomAttack(RandomInt(1, 4));
            }
        }
        // If the previous roll fails, roll for a synced action instead (assuming we aren't waiting for one)
        else if (!PreparingForSyncedAction) {
            if (RandomInt(0, SyncedActionProbability) == SyncedActionProbability) {
                EntFire("thehead*", "RunScriptCode", "PreparingForSyncedAction = true", -1, self);
            }
        }
        if (HeadNumber != 0) { return; } // dont run this on all three heads to prevent jank/redundancy
        if (PreparingForSyncedAction) {
            local AllIdle = true;
            // if any of the heads are busy, delay the synced action until they're finished.
            foreach (status in HeadsBusy) {
                if (status == true) {
                    AllIdle = false;
                    break;
                }
            }
            if (AllIdle) {
                DoRandomSyncedAction(RandomInt(1, 3));
            }
        }
    }
    else { HeadsBusy[HeadNumber] = true;} // if you aren't idling, clearly you're busy. failsafe thing.
}

function DoRandomAttack(ind) {
    switch (ind) {
        case 1: {
            EntFireByHandle(self, "SetAnimation", "slam", -1, self, self);
            break;
        }
        case 2: {
            EntFireByHandle(self, "SetAnimation", "firelaser", -1, self, self);
            break;
        }
        case 3: {
            EntFireByHandle(self, "SetAnimation", "widelaser", -1, self, self);
            break;
        }
        case 4: {
            EntFireByHandle(self, "SetAnimation", "flatlaser", -1, self, self);
            break;
        }
    }
}

function DoRandomSyncedAction(ind) {
    switch (ind) {
        case 1: {
            EntFire("thehead*", "SetAnimation", "slam", -1, self);
            EntFire("thehead*", "RunScriptCode", "PreparingForSyncedAction = false", 1, self);
            break;
        }
        case 2: {
            EntFire("thehead*", "SetAnimation", "flatlaser", -1, self);
            EntFire("thehead*", "RunScriptCode", "PreparingForSyncedAction = false", 1, self);
            break;
        }
        case 3: {
            EntFire("debug_bossdovertlaser", "Trigger", "", -1, self);
            EntFire("thehead*", "RunScriptCode", "PreparingForSyncedAction = false", 1, self);
            break;
        }
    }
}

function DoCinematicAction() {
    // this is sort of redundant but hey, might be useful in the future so fuck it
    switch (CinematicActionPending) {
        case "hurt": {
            EntFireByHandle(self, "SetAnimation", CinematicActionPending, -1, self, self);
            EntFireByHandle(self, "RunScriptCode", "CinematicActionPending = false", 2, self, self);
            EntFireByHandle(self, "RunScriptCode", "DisableThinking = false", 2, self, self);
            break;
        }
        case "rage": {
            EntFireByHandle(self, "SetAnimation", CinematicActionPending, -1, self, self);
            EntFireByHandle(self, "RunScriptCode", "CinematicActionPending = false", 2, self, self);
            EntFireByHandle(self, "RunScriptCode", "DisableThinking = false", 2, self, self);
            break;
        }
    }
}