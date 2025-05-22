function OnPostSpawn() {
    Tesla1 <- Entities.FindByName(null, "finalboss_teslaprop1");
    Trigger1 <- Entities.FindByName(null, "finalboss_teslatrigger1");
    Tesla2 <- Entities.FindByName(null, "finalboss_teslaprop2");
    Trigger2 <- Entities.FindByName(null, "finalboss_teslatrigger2");
    Tesla3 <- Entities.FindByName(null, "finalboss_teslaprop3");
    Trigger3 <- Entities.FindByName(null, "finalboss_teslatrigger3");
    Tesla4 <- Entities.FindByName(null, "finalboss_teslaprop4");
    Trigger4 <- Entities.FindByName(null, "finalboss_teslatrigger4");
    NumCapturing <- 0;
    TimeToCapture <- 30.0;
    MultiCapturePenaltyMult <- 0.6;
    MaxCapturing <- 4;
    MinCapturing <- 0;
    CaptureRate <- 0.1;
    CurrentCaptures <- [false, false, false, false];
    CaptureProgress <- [0.0, 0.0, 0.0, 0.0];
    SoundCooldown <- [10, 10, 10, 10];

    TeslaArr <- [Tesla1, Tesla2, Tesla3, Tesla4];
    TriggerArr <- [Trigger1, Trigger2, Trigger3, Trigger4];
    // AddThinkToEnt(self, "CaptureThink");
}

function StartCapture(capindex) {
    if (CurrentCaptures[capindex] == true) { return; } // in case it somehow gets called when the capture is already started
    NumCapturing++;
    if (NumCapturing < MinCapturing) { NumCapturing = MinCapturing }
    // ClientPrint(GetListenServerHost(), 3, "Now capturing point " + capindex.tostring());
    CurrentCaptures[capindex] = true;
}

function StopCapture(capindex) {
    if (CurrentCaptures[capindex] == false) { return; } // in case it somehow gets called when the capture isn't even started
    NumCapturing--;
    if (NumCapturing > MaxCapturing) { NumCapturing = MaxCapturing }
    // ClientPrint(GetListenServerHost(), 3, "No longer capturing point " + capindex.tostring());
    CurrentCaptures[capindex] = false;
}

function CaptureSFXLoop(capindex) {
    // ClientPrint(GetListenServerHost(), 3, "Trying to play sound.")

    // if it's not being captured, dont bother playing the sound
    if (CurrentCaptures[capindex] == false) {
        // ClientPrint(GetListenServerHost(), 3, "Capindex reported false.")
        return; 
    }
    // prevent sounds from overlapping, otherwise play that shit
    if (SoundCooldown[capindex] <= 0) {
        local TeslaPitch = 100.0;
        TeslaPitch += (CaptureProgress[capindex])
        EmitSoundEx({
            sound_name = "cybertowersfx/new/teslachargingloop.mp3"
            origin = TeslaArr[capindex].GetOrigin()
            volume = 0.9
            sound_level = 70
            pitch = TeslaPitch.tointeger()
        });
        SoundCooldown[capindex] = 10;
    }
    EntFireByHandle(caller, "FireUser2", "", 1, self, self);
}

// Check each capture state, and add 0.1 to the progress of the capture if it returns true
function CaptureThink() {
    // prevent sounds from overlapping. that shit gets really awful when it does
    for (local i = 0 ; i < SoundCooldown.len() ; i++) {
        if (SoundCooldown[i] > 0) { SoundCooldown[i]-- }
    }
    // no need to do all this iteration if there's nothing being captured
    if (NumCapturing == 0) { return; }
    // local to use for accessing the index of each boolean. starts -1 because we increment at the start of foreach
    local capindex = -1;
    foreach (capstate in CurrentCaptures) {
        capindex++;
        // if true
        if (capstate) {
            // if it's already fully captured, check the next one and turn the fucker off
            if (CaptureProgress[capindex] >= TimeToCapture) {
                StopCapture(capindex);
                continue;
            }
            // increment the capture, slowing it down with diminishing returns.
            CaptureProgress[capindex] += (CaptureRate * (pow(MultiCapturePenaltyMult, (NumCapturing - 1)))); // if one capture is active, it goes to power of zero, which always returns 1. Thanks math!
            // ClientPrint(GetListenServerHost(), 3, CaptureProgress[capindex].tostring());
            // if it's fully captured after this increment, fire user 1 (which does the effects and shit)
            if (CaptureProgress[capindex] >= TimeToCapture ) {
                EntFireByHandle(TriggerArr[capindex], "FireUser1", "", -1, self, self);
            }
        }
    }
}