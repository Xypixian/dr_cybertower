// Hello there! You are probably concerned about me using player SteamIDs.
// This script is SOLELY for a small room with some silly intelligence flags, for me and my close friends.
// This DOES NOT affect the gameplay in any way. We do not have special powers or cheats. We must play the map normally just like everyone else.
// This is purely for fashion and flaire.
// Please understand.

// If you are sure, and still want to disable this, Stripper out the entity named "funnytrig" and it won't be usable by us.
function OnPostSpawn()
{
    AllowedPlayers <- 
    {
        scrotes = "[U:1:48448063]"
        prowi = "[U:1:312694195]"
        danny = "[U:1:28631020]"
        zaty = "[U:1:319770901]"
    };
    TPDest <- Entities.FindByName(null, "debugTPDest3");
    TPDestDeny <- Entities.FindByName(null, "debug_return");
}

function CheckID()
{
    local actID = NetProps.GetPropString(activator, "m_szNetworkIDString");

    foreach (player in AllowedPlayers) 
    {
        if (actID == player) 
        {
            activator.SetAbsOrigin(TPDest.GetOrigin());
            return;
        }
    }
    activator.SetAbsOrigin(TPDestDeny.GetOrigin());
}