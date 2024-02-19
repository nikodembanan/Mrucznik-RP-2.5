//-----------------------------------------------<< Timers >>------------------------------------------------//
//                                                  napady                                                  //
//----------------------------------------------------*------------------------------------------------------//
//----[                                                                                                 ]----//
//----[         |||||             |||||                       ||||||||||       ||||||||||               ]----//
//----[        ||| |||           ||| |||                      |||     ||||     |||     ||||             ]----//
//----[       |||   |||         |||   |||                     |||       |||    |||       |||            ]----//
//----[       ||     ||         ||     ||                     |||       |||    |||       |||            ]----//
//----[      |||     |||       |||     |||                    |||     ||||     |||     ||||             ]----//
//----[      ||       ||       ||       ||     __________     ||||||||||       ||||||||||               ]----//
//----[     |||       |||     |||       |||                   |||    |||       |||                      ]----//
//----[     ||         ||     ||         ||                   |||     ||       |||                      ]----//
//----[    |||         |||   |||         |||                  |||     |||      |||                      ]----//
//----[    ||           ||   ||           ||                  |||      ||      |||                      ]----//
//----[   |||           ||| |||           |||                 |||      |||     |||                      ]----//
//----[  |||             |||||             |||                |||       |||    |||                      ]----//
//----[                                                                                                 ]----//
//----------------------------------------------------*------------------------------------------------------//
// Autor: Sandal
// Data utworzenia: 17.02.2024
//Opis:
/*
	System napad�w
*/

//

//-----------------<[ Timery: ]>-------------------
forward Heist_UnlockCooldown();
public Heist_UnlockCooldown()
{
	Heist_BlockHeisting = 0;
}


forward Heist_ClearData(attackerid);
public Heist_ClearData(attackerid)
{
	if(attackerid != 5)
	{
		Heist_Attackers[attackerid] = -1;
		Heist_AttackersCounter--;
	}
	else
	{
		Heist_AttackersCount = 0;
		Heist_AttackersCounter = 0;
		for(new i = 0; i < 4; i++)
		{
			Heist_Attackers[i] = -1;
			Heist_AttackerWarnCount[i] = 0;
		}
		Heist_CurrentZoneid = -1;
		Heist_CurrentVehicleid = -1;
		Heist_Steal_Countdown = 0;
		Heist_NotifyPoliceCooldown = 10;
		Heist_MapIconCounter = 0;
		KillTimer(Heist_Timers);
		Heist_DestroyMapIcon();
	}
}

forward Heist_Timer();
public Heist_Timer()
{
	if(Heist_AttackersCounter < 1)
	{
		Heist_Lost();
	}
	new string[32];
	format(string, sizeof(string), "~w~%d s", Heist_Steal_Countdown);
	if(Heist_NotifyPoliceCooldown > 0)
		Heist_NotifyPoliceCooldown--;
	else if(Heist_NotifyPoliceCooldown == 0)
	{
		Heist_Notify(HEIST_MSG_STEAL);
		Heist_NotifyPoliceCooldown = -1;
	}
	for(new i = 0; i < Heist_AttackersCount; i++)
	{
		if(Heist_Attackers[i] == -1) continue;
		if(!Heist_EligibleToContinue(i))
		{
			Heist_Remove(i);
			continue;
		}
		if(!IsPlayerInRangeOfPoint(Heist_Attackers[i], 30.0, HeistZone[Heist_CurrentZoneid][Heist_x], HeistZone[Heist_CurrentZoneid][Heist_y], HeistZone[Heist_CurrentZoneid][Heist_z]))
		{
			Heist_Remove(i);
			continue;
		}
		if(!IsPlayerInRangeOfPoint(Heist_Attackers[i], 15.0, HeistZone[Heist_CurrentZoneid][Heist_x], HeistZone[Heist_CurrentZoneid][Heist_y], HeistZone[Heist_CurrentZoneid][Heist_z]))
			SendClientMessage(Heist_Attackers[i], COLOR_GRAD2, "Nie oddalaj si� od miejsca napadu do czasu zako�czenia kradzie�y!");
		GameTextForPlayer(Heist_Attackers[i], string, 3200, 6);
		SetPlayerChatBubble(Heist_Attackers[i], "** Napada na sklep **", COLOR_DO, 100.0, 4500);
	}
	new Float:vehHP;
	GetVehicleHealth(Heist_CurrentVehicleid, vehHP);
	if(Heist_Steal_Countdown > 0)
		Heist_Steal_Countdown -= 5;
	if(vehHP <= 251.0)
	{
		Heist_Lost();
	}

	if(Heist_Steal_Countdown <= 0)
	{
		Heist_ProcessEscape();
		Heist_UpdateMapIcon();
	}
}

forward Heist_Escape();
public Heist_Escape()
{
	if(Heist_AttackersCounter < 1)
	{
		Heist_Lost();
	}
	new Float:vehHP;
	GetVehicleHealth(Heist_CurrentVehicleid, vehHP);
	if(vehHP <= 251.0)
	{
		Heist_Lost();
	}
	if(Heist_MapIconCounter == 10)
	{
		Heist_UpdateMapIcon();
		Heist_MapIconCounter = 0;
	}
	else
		Heist_MapIconCounter++;
		
	new string[32], warning[48];
	new time;
	format(string, sizeof(string), "~w~%d s", Heist_Steal_Countdown);
	for(new i = 0; i < Heist_AttackersCount; i++)
	{
		if(Heist_Attackers[i] == -1) continue;
		if(!Heist_EligibleToContinue(i))
		{
			Heist_Remove(i);
			continue;
		}

		if(!IsPlayerInVehicle(Heist_Attackers[i], Heist_CurrentVehicleid))
		{
			if(Heist_AttackerWarnCount[i] < 4)
			{
				time = 5 * (4 - Heist_AttackerWarnCount[i]);
				Heist_AttackerWarnCount[i]++;
				format(warning, sizeof(warning), "Wr�c do swojego auta! Masz na to %d sekund!", time);
				SendClientMessage(Heist_Attackers[i], COLOR_LIGHTRED, warning);
			}
			else
				Heist_Remove(i);
			continue;
		}
		else if(Heist_AttackerWarnCount[i] > 0)
			Heist_AttackerWarnCount[i] = 0;
		SetPlayerChatBubble(Heist_Attackers[i], "** Niesie torb� wypchan� pieni�dzmi **", COLOR_DO, 60.0, 6500);
		GameTextForPlayer(Heist_Attackers[i], string, 5200, 6);
	}
	if(Heist_Steal_Countdown > 0)
		Heist_Steal_Countdown -= 10;
	else
	{
		Heist_Win();
	}
}
//end