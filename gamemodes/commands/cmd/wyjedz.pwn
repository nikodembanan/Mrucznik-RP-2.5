//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//-------------------------------------------------[ wyjedz ]------------------------------------------------//
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

// Opis:
/*
	
*/


// Notatki skryptera:
/*
	
*/

YCMD:wyjedz(playerid, params[], help)
{
	if(GetPVarInt(playerid, "Lockdown-izolacja") != 0) return sendTipMessageEx(playerid, COLOR_PANICRED, "Nie mo�esz u�ywa� tej komendy w trakcie weryfikacji.");
	if(GetPVarInt(playerid, "JestPodczasWjezdzania") == 1)
	{
		sendTipMessage(playerid, "Jeste� podczas wje�d�ania!"); 
		return 1;
	}
	if(GetPVarInt(playerid, "IsAGetInTheCar") == 1)
	{
		sendErrorMessage(playerid, "Jeste� podczas wsiadania - odczekaj chwile."); 
		return 1;
	}	
	SetAntyCheatForPlayer(playerid, 4); 
	if(SprawdzWjazdy(playerid))
	{
	
	}
	else
	{
		sendErrorMessage(playerid, "Nie jeste� w obszarze, w kt�rym mo�na wjecha�"); 
	}
	return 1;
}
