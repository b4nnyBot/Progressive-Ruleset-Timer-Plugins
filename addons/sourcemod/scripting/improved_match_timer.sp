#include <tf2_morestocks>
#include <string>
#pragma newdecls required
#pragma semicolon 1


bool doOnRestart = true;
char mapname[64];

//timers
Handle timer1 = INVALID_HANDLE;
Handle timer2 = INVALID_HANDLE;

//Default ConVars
ConVar cvar_timelimit;
ConVar cvar_restartgame;

//Custom ConVars
ConVar enabled;

public Plugin myinfo =
{
	name = "Improved Match Timer",
	author = "Dooby Skoo",
	description = "TF2 round win limit gets reduced after 30 minutes on 5CP.",
	version = "1.1.0",
	url = "https://github.com//dewbsku"
};

public void OnPluginStart(){
    enabled = CreateConVar("mp_timelimit_improved", "0", "Determines whether the plugin should do anything. 0 off (default), 1 on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
}

public void OnMapStart()
{
    timer1 = INVALID_HANDLE;
    timer2 = INVALID_HANDLE;
    GetCurrentMap(mapname, 64);
    cvar_timelimit = FindConVar("mp_timelimit");
    cvar_restartgame = FindConVar("mp_restartgame");
    cvar_restartgame.AddChangeHook(OnRestartGame);
}

public void OnRestartGame(ConVar convar, char[] oldValue, char[] newValue){
    if(StrContains(mapname, "cp_", true) == 0 && cvar_timelimit.IntValue != 0 && doOnRestart && enabled.BoolValue == true){
        if(timer1 != INVALID_HANDLE){
            KillTimer(timer1);
            timer1 = INVALID_HANDLE;
        }
        if(timer2 != INVALID_HANDLE){
            KillTimer(timer2);
            timer2 = INVALID_HANDLE;
        }
        timer1 = CreateTimer(6.0, WaitTime, _, TIMER_FLAG_NO_MAPCHANGE);
        doOnRestart = false;
    }
    else if(doOnRestart){
        if(timer1 != INVALID_HANDLE){
            KillTimer(timer1);
            timer1 = INVALID_HANDLE;
        }
        if(timer2 != INVALID_HANDLE){
            KillTimer(timer2);
            timer2 = INVALID_HANDLE;
        }
    }
}

public Action WaitTime(Handle timer){
    PrintToChatAll("Running Improved Match Timer...");
    PrintToServer("Running Improved Match Timer...");
    doOnRestart = true;
    timer2 = CreateTimer(0.5, CheckRoundTime, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    timer1 = INVALID_HANDLE;
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
        timer2 = INVALID_HANDLE;
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

bool IsValidClient(int client){
	return ( client > 0 && client <= MaxClients && IsClientInGame(client) );
}