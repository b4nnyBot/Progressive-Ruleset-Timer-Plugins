//#include <sourcemod>
//#include <sdktools>
//#include <sdkhooks>
#include <tf2_stocks>
#include <tf2_morestocks>
//#include <timers>
#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
	name = "Soft Match Timer",
	author = "Dooby Skoo",
	description = "TF2 winlimit gets reduced after 30 minutes.",
	version = "1.0",
	url = "https://github.com//dewbsku"
};

public void OnMapStart()
{
    if(GameRules_GetProp("m_nGameType") == 2) CreateTimer(15.0, WaitTime, _, TIMER_FLAG_NO_MAPCHANGE); // gametype == 2 is control points
}

public Action WaitTime(Handle timer){
    ServerCommand("mp_timelimit 30");
    ServerCommand("mp_winlimit 5");
    PrintToChatAll("Running Soft Match Timer...");
    PrintToServer("Running Soft Match Timer...");
    CreateTimer(0.5, CheckRoundTime, _, TIMER_REPEAT);
}

public Action CheckRoundTime(Handle timer){
    int timeleft;
    GetMapTimeLeft(timeleft);
    if(timeleft<=1){
        ServerCommand("mp_timelimit 0");
        int newRoundLimit = GetTeamScore(3) + 1;
        if(GetTeamScore(2)+1>GetTeamScore(3)+1) newRoundLimit = GetTeamScore(2)+1;
        if(newRoundLimit>5) newRoundLimit = 5;
        ServerCommand("mp_winlimit %d", newRoundLimit);
        char team2Name[32];
        char team3Name[32];
        GetTeamName(2, team2Name, 32);
        GetTeamName(3, team3Name, 32);
        PrintToChatAll("%s's Score: %d, %s's Score: %d, New Round Limit: %d", team2Name, GetTeamScore(2), team3Name, GetTeamScore(3), newRoundLimit); //debug
        return Plugin_Stop;
    }
    return Plugin_Continue;
}