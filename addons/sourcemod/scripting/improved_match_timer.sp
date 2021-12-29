#include <tf2_morestocks>
#include <string>
#pragma newdecls required
#pragma semicolon 1

ConVar cvar_timelimit;
ConVar cvar_restartgame;
ConVar cvar_restartgame_immediate;
bool doOnRestart = true;
bool doOnRestartImmediate = true;
char mapname[64];

public Plugin myinfo =
{
	name = "Improved Match Timer",
	author = "Dooby Skoo",
	description = "TF2 winlimit gets reduced after 30 minutes on 5CP.",
	version = "1.0.3",
	url = "https://github.com//dewbsku"
};

public void OnMapStart()
{
    GetCurrentMap(mapname, 64);
    cvar_timelimit = FindConVar("mp_timelimit");
    cvar_restartgame = FindConVar("mp_restartgame");
    cvar_restartgame_immediate = FindConVar("mp_restartgame_immediate");
    cvar_restartgame.AddChangeHook(OnRestartGame);
    cvar_restartgame_immediate.AddChangeHook(OnRestartGameImmediate);
}

public void OnRestartGame(ConVar convar, char[] oldValue, char[] newValue){
    if(StrContains(mapname, "cp_", true) == 0 && cvar_timelimit.IntValue != 0 && doOnRestart){
        CreateTimer(3.0, WaitTime, _, TIMER_FLAG_NO_MAPCHANGE);
        doOnRestart = false;
    }
}

public void OnRestartGameImmediate(ConVar convar, char[] oldValue, char[] newValue){
    if(StrContains(mapname, "cp_", true) == 0 && cvar_timelimit.IntValue != 0 && doOnRestartImmediate){
        CreateTimer(3.0, WaitTime, _, TIMER_FLAG_NO_MAPCHANGE);
        doOnRestartImmediate = false;
    }
}

public Action WaitTime(Handle timer){
    PrintToChatAll("Running Improved Match Timer...");
    PrintToServer("Running Improved Match Timer...");
    doOnRestart = true;
    doOnRestartImmediate = true;
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
                if(GetClientTeam(client) == 2) PrintToChat(client, "Win %d more round%s to win the match!", 
                    newRoundLimit-GetTeamScore(2), (newRoundLimit-GetTeamScore(2)!=1) ? "s":"");
                if(GetClientTeam(client) == 3) PrintToChat(client, "Win %d more round%s to win the match!", 
                    newRoundLimit-GetTeamScore(3), (newRoundLimit-GetTeamScore(3)!=1) ? "s":"");
            }
        }
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

bool IsValidClient(int client){
	return ( client > 0 && client <= MaxClients && IsClientInGame(client) );
}