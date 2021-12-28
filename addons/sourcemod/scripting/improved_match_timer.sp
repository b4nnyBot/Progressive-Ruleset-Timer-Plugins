#include <tf2_morestocks>
#include <string>
#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
	name = "Improved Match Timer",
	author = "Dooby Skoo",
	description = "TF2 winlimit gets reduced after 30 minutes on 5CP.",
	version = "1.0.2",
	url = "https://github.com//dewbsku"
};

public void OnMapStart()
{
    char mapname[64];
    GetCurrentMap(mapname, 64);
    if(StrContains(mapname, "cp_", true) == 0) CreateTimer(15.0, WaitTime, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action WaitTime(Handle timer){
    PrintToChatAll("Running Improved Match Timer...");
    PrintToServer("Running Improved Match Timer...");
    CreateTimer(0.5, CheckRoundTime, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action CheckRoundTime(Handle timer){
    int timeleft;
    GetMapTimeLeft(timeleft);
    if(timeleft<=1){
        ServerCommand("mp_timelimit 0");
        int newRoundLimit = GetTeamScore(3) + 1;
        if(GetTeamScore(2)+1>GetTeamScore(3)+1) newRoundLimit = GetTeamScore(2)+1;
        if(newRoundLimit>5) newRoundLimit = 5;
        if(newRoundLimit<5){
            ServerCommand("mp_winlimit %d", newRoundLimit);
            char team2Name[32];
            char team3Name[32];
            GetTeamName(2, team2Name, 32);
            GetTeamName(3, team3Name, 32);
            PrintToChatAll("New Round Limit: %d", newRoundLimit);
        }
        for(int client=1;client<=MAXPLAYERS;client++){
            if(IsValidClient(client)){
                if(GetClientTeam(client) == 2) PrintToChat(client, "Win %d more round%s to win the match!", newRoundLimit-GetTeamScore(2), (newRoundLimit-GetTeamScore(2)!=1) ? "s":"");
                if(GetClientTeam(client) == 3) PrintToChat(client, "Win %d more round%s to win the match!", newRoundLimit-GetTeamScore(3), (newRoundLimit-GetTeamScore(3)!=1) ? "s":"");
            }
        }

        return Plugin_Stop;
    }
    return Plugin_Continue;
}

bool IsValidClient(int client){
	return ( client > 0 && client <= MaxClients && IsClientInGame(client) );
}