//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//-----------------------------------------------[ poddajesie ]----------------------------------------------//
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

YCMD:poddajesie(playerid, params[], help)
{
	new string[128];
	new sendername[MAX_PLAYER_NAME];
	new giveplayer[MAX_PLAYER_NAME];

	new reward = PoziomPoszukiwania[playerid] * 10000;
	new punishment = PoziomPoszukiwania[playerid] * 1000;
	new bail = PoziomPoszukiwania[playerid] * 16000;

    if(IsPlayerConnected(playerid))
    {
        if(poddaje[playerid] == 1)
        {
            if(PoziomPoszukiwania[playerid] >= 2)
            {
	            GetPlayerName(playerid, sendername, sizeof(sendername));
  				GetPlayerName(lowcap[playerid], giveplayer, sizeof(giveplayer));
		        format(string, sizeof(string), "* Podda�e� si� �owcy Nagr�d %s idziesz do celi i tracisz %d, kaucja: %d$",giveplayer, punishment, bail);
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
		        ZabierzKase(playerid, punishment);
				PlayerInfo[playerid][pJailed] = 1;
			    PlayerInfo[playerid][pJailTime] = (PoziomPoszukiwania[playerid])*(200);
				SetPlayerVirtualWorld(playerid, 29);
				JailPrice[playerid] = bail;
				WantLawyer[playerid] = 1;
				new losuj= random(sizeof(Cela));
				SetPlayerPos(playerid, Cela[losuj][0], Cela[losuj][1], Cela[losuj][2]);
				TogglePlayerControllable(playerid, 0);
                Wchodzenie(playerid);
				format(string, sizeof(string), "* %s podda� si�, dostajesz %d nagrody za z�apanie �ywego przest�pcy",sendername, reward);
		        SendClientMessage(lowcap[playerid], COLOR_LIGHTBLUE, string);
		        SendClientMessage(lowcap[playerid], COLOR_GRAD3, "Skill + 4");
                PoziomPoszukiwania[playerid] = 0;
				SetPlayerWantedLevel(playerid, 0);
		        PlayerInfo[lowcap[playerid]][pDetSkill]+=4;
		        DajKase(lowcap[playerid], reward);
				poddaje[playerid] = 0;
				lowcap[playerid] = 0;
			}
			else
			{
				sendTipMessage(playerid, "Nie jeste� poszukiwany - nie mo�esz si� podda�!", COLOR_LIGHTBLUE);
			}
		}
	}
	return 1;
}
