#include <sourcemod>
#include <sdktools>
#pragma newdecls required
#pragma semicolon 1

bool doOnRestart = true;
char mapname[64];
int winlimit_original = -1;
int timelimit_original = -1;
bool rightGamemode;

//timers
Handle timer1 = INVALID_HANDLE;
Handle timer2 = INVALID_HANDLE;

//Default ConVars
ConVar cvar_timelimit;
ConVar cvar_restartgame;
ConVar cvar_winlimit;

//Custom ConVars
ConVar mp_timelimit_improved;
ConVar mp_timelimit_improved_visibility;

public Plugin myinfo =
{
	name = "Improved Match Timer",
	author = "Dooby Skoo",
	description = "TF2 round win limit gets reduced after the map timer runs out on 5CP.",
	version = "1.1.6",
	url = "https://github.com//dewbsku"
};

public void OnPluginStart(){
    mp_timelimit_improved = CreateConVar("mp_timelimit_improved", "0", "Determines whether the plugin should do anything. 0 off (default), 1 on.", FCVAR_NONE, true, 0.0, true, 1.0);
    mp_timelimit_improved_visibility = CreateConVar("mp_timelimit_improved_visibility", "0", "Removes the timer when a team reaches 4 rounds won. 0 off (default), 1 on.", FCVAR_NONE, true, 0.0, true, 1.0);
    cvar_timelimit = FindConVar("mp_timelimit");
    cvar_restartgame = FindConVar("mp_restartgame");
    cvar_winlimit = FindConVar("mp_winlimit");
    cvar_restartgame.AddChangeHook(OnRestartGame);
    AddCommandListener(OnExec, "exec");
}

public Action OnExec(int client, const char[] command, int argc){
    winlimit_original = -1;
    timelimit_original = -1;
}

public void OnMapStart()
{
    timer1 = INVALID_HANDLE;
    timer2 = INVALID_HANDLE;
    winlimit_original = -1;
    timelimit_original = -1;
    GetCurrentMap(mapname, sizeof(mapname));
    rightGamemode = (StrContains(mapname, "cp_", true) == 0);
}

public void OnRestartGame(ConVar convar, char[] oldValue, char[] newValue){
    if(timelimit_original==-1) timelimit_original = cvar_timelimit.IntValue;
    if(winlimit_original==-1) winlimit_original = cvar_winlimit.IntValue;

    if(cvar_timelimit.IntValue!=timelimit_original && mp_timelimit_improved.BoolValue && rightGamemode) ServerCommand("mp_timelimit %d", timelimit_original);
    if(cvar_winlimit.IntValue!=winlimit_original && mp_timelimit_improved.BoolValue && rightGamemode) ServerCommand("mp_winlimit %d", winlimit_original);

    if(StrContains(mapname, "cp_", true) == 0 && cvar_timelimit.IntValue != 0 && doOnRestart && mp_timelimit_improved.BoolValue == true){
        SafelyKillTimer(timer1);
        SafelyKillTimer(timer2);
        timer1 = CreateTimer(6.0, WaitTime, _, TIMER_FLAG_NO_MAPCHANGE);
        doOnRestart = false;
    }
    else if(doOnRestart){
        SafelyKillTimer(timer1);
        SafelyKillTimer(timer2);
    }
}

public Action WaitTime(Handle timer){
    PrintToChatAll("Running Improved Match Timer.");
    PrintToServer("Running Improved Match Timer.");
    doOnRestart = true;
    timer2 = CreateTimer(1.0, CheckRoundTime, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    timer1 = INVALID_HANDLE;
}

public Action CheckRoundTime(Handle timer){
    int timeleft;
    GetMapTimeLeft(timeleft);
    if(timeleft>=300 && timeleft%300==0) DisplayClockInfo();
    if(timeleft<300 && timeleft%60==0) DisplayClockInfo();
    if(timeleft<=1){
        ServerCommand("mp_timelimit 0");
        int newRoundLimit = GetTeamScore(3) + 1;
        if(GetTeamScore(2)+1>GetTeamScore(3)+1) newRoundLimit = GetTeamScore(2)+1;
        if(newRoundLimit>5) newRoundLimit = 5;
        if(newRoundLimit<5){
            ServerCommand("mp_winlimit %d", newRoundLimit);
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
    if((GetTeamScore(2) >= 4 || GetTeamScore(3) >= 4) && mp_timelimit_improved_visibility.BoolValue){
        ServerCommand("mp_timelimit 0");
        for(int client=1;client<=MAXPLAYERS;client++){
            if(IsValidClient(client)){
                if(GetClientTeam(client) == 2) PrintToChat(client, "Win %d more round%s to win the match!", 
                    5-GetTeamScore(2), (5-GetTeamScore(2)!=1) ? "s":"");
                if(GetClientTeam(client) == 3) PrintToChat(client, "Win %d more round%s to win the match!", 
                    5-GetTeamScore(3), (5-GetTeamScore(3)!=1) ? "s":"");
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

public void DisplayClockInfo(){
    int timeleft, minutes, seconds;
    GetMapTimeLeft(timeleft);
    minutes = timeleft/60;
    seconds = timeleft%60;
    char message[64];
    char msg1[16];
    char msg2[16];
    Format(msg1, sizeof(msg1), " %d minute%s", minutes, (minutes!=1)? "s":"");
    Format(msg2, sizeof(msg2), " %d second%s", seconds, (seconds!=1)? "s":"");
    Format(message, sizeof(message), "Round win limit will be reduced in%s%s%s.",
     (minutes!=0)? msg1:"",
     (minutes!=0 && seconds!=0)? " and":"",
     (seconds!=0)? msg2:""
    );
    PrintToChatAll(message);
}

public void SafelyKillTimer(Handle timer){
    if(timer != INVALID_HANDLE){
        KillTimer(timer);
        timer = INVALID_HANDLE;
    }
}
