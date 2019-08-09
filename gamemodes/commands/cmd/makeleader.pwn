//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//-----------------------------------------------[ makeleader ]----------------------------------------------//
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

YCMD:makeleader(playerid, params[], help)
{
	new string[128];
	new giveplayer[MAX_PLAYER_NAME];
	new sendername[MAX_PLAYER_NAME];

    if(IsPlayerConnected(playerid))
    {
		new para1, level;
		if( sscanf(params, "k<fix>d", para1, level))
		{
			sendTipMessage(playerid, "U�yj /makeleader [playerid/Cz��Nicku] [Number(1-17)]");
			return 1;
		}

		if(level > 17 || level < 0) { sendTipMessageEx(playerid, COLOR_GREY, "Numer lidera od 1 do 17!"); return 1; }
		if(Uprawnienia(playerid, ACCESS_MAKELEADER) || IsAScripter(playerid))
		{
			
			if(IsPlayerConnected(para1))
			{
				if(para1 != INVALID_PLAYER_ID)
				{
					if(level == 0)
					{
						if(PlayerInfo[para1][pLiderValue] == 1)
						{
							format(string, sizeof(string), "%s jest g��wnym liderem organizacji.\nCzy chcesz zwolni� wszystkich lider�w?", GetNick(para1));
							SetPVarInt(playerid, "ID_LIDERA", para1);  
							ShowPlayerDialogEx(playerid, DIALOG_UNFRAKCJA, DIALOG_STYLE_MSGBOX, "Mrucznik Role Play", string, "Tak", "Nie"); 
							return 1;
						}
						format(string, sizeof(string), "* Zosta�e� wyrzucony z frakcji przez %s.", GetNick(playerid));
						SendClientMessage(para1, COLOR_LIGHTBLUE, string);
						SendClientMessage(para1, COLOR_LIGHTBLUE, "* Jeste� cywilem.");
						Log(adminLog, INFO, "Admin %s usun�� gracza [VLD] %s z jego frakcji {NR %d }", GetPlayerLogName(playerid), GetPlayerLogName(para1), PlayerInfo[para1][pMember]);
						PlayerInfo[para1][pMember] = 0;
						PlayerInfo[para1][pLider] = 0;
						PlayerInfo[para1][pJob] = 0;
						orgUnInvitePlayer(para1);
						MedicBill[para1] = 0;
						SetPlayerSpawn(para1);
						format(string, sizeof(string), "  Wyrzuci�es %s z frakcji.", GetNick(para1));
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						Remove_MySQL_Leader(para1); 
						return 1;
					}
					if(PlayerInfo[para1][pMember] > 0 || GetPlayerOrg(para1) != 0)
					{
						sendTipMessageEx(playerid, COLOR_GREY, "Ten gracz jest we frakcji jako cz�onek lub w rodzinie !");
						return 1;
					}
					
					GetPlayerName(para1, giveplayer, sizeof(giveplayer));
					GetPlayerName(playerid, sendername, sizeof(sendername));
					PlayerInfo[para1][pLider] = level;
					PlayerInfo[para1][pLiderValue] = 1; 
					PlayerInfo[para1][pMember] = level;
					MruMySQL_SetAccInt("Member", giveplayer, level);
					//MruMySQL_SetAccInt("Lider", giveplayer, level);
					Create_MySQL_Leader(para1, level, 1);//Tworzenie konta GLD
					Save_MySQL_Leader(para1);
					format(string, sizeof(string), "Zosta�e� mianowany liderem [GLD] frakcji przez %s", sendername);
					SendClientMessage(para1, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "Da�e� graczowi %s kontrol� [GLD] nad frakcj� numer %d.", giveplayer,level);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					
					//logi
            		Log(adminLog, INFO, "Admin %s da� graczowi %s lidera [GLD] frakcji %d", GetPlayerLogName(playerid), GetPlayerLogName(para1), level);
					if(GetPlayerAdminDutyStatus(playerid) == 1)
					{
						iloscInne[playerid] = iloscInne[playerid]+1;
					}
					
					if(level == 0) { PlayerInfo[para1][pSkin] = 0; }
					else if(level == 1) { PlayerInfo[para1][pSkin] = 288; } //Police Force
					else if(level == 2) { PlayerInfo[para1][pSkin] = 295; } //FBI/ATF
					else if(level == 3) { PlayerInfo[para1][pSkin] = 287; } //National Guard
					else if(level == 4) { PlayerInfo[para1][pSkin] = 228; } //Fire/Ambulance
					else if(level == 5) { PlayerInfo[para1][pSkin] = 113; } //La Cosa Nostra
					else if(level == 6) { PlayerInfo[para1][pSkin] = 208; } //Yakuza
					else if(level == 7) { PlayerInfo[para1][pSkin] = 57; } //BOR
					else if(level == 8) { PlayerInfo[para1][pSkin] = 294; } //Hitmans
					else if(level == 9) { PlayerInfo[para1][pSkin] = 227; } //News Reporters
					else if(level == 10) { PlayerInfo[para1][pSkin] = 61; } //Taxi Cab Company
					else if(level == 11) { PlayerInfo[para1][pSkin] = 147; } //Burmistrz
					else if(level == 12) { PlayerInfo[para1][pSkin] = 270; } //Grove Street
					else if(level == 13) { PlayerInfo[para1][pSkin] = 103; } //Ballas
					else if(level == 14) { PlayerInfo[para1][pSkin] = 109; } //Vagos
					else if(level == 15) { PlayerInfo[para1][pSkin] = 60; } //NoA
					else if(level == 16) { PlayerInfo[para1][pSkin] = 112; } //Dziady
					else if(level == 17) { PlayerInfo[para1][pSkin] = 279; } //LSFD
					if(level != 0)
					{
						gTeam[para1] = 11;
						PlayerInfo[para1][pTeam] = 11;
						PlayerInfo[para1][pRank] = 6;
					}
					if(PlayerInfo[para1][pSkin] != 0) SetPlayerSkin(para1, PlayerInfo[para1][pSkin]);
					else SetPlayerSkin(para1, PlayerInfo[para1][pModel]);
				}
			}//not connected
		}
		else
		{
			noAccessMessage(playerid); 
		}
	}
	return 1;
}
