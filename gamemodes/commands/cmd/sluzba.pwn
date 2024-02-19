//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//-------------------------------------------------[ sluzba ]------------------------------------------------//
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

YCMD:sluzba(playerid, params[], help)
{
    new string[128];
    new sendername[MAX_PLAYER_NAME];

    if(IsPlayerConnected(playerid))
    {
        if(IsAPolicja(playerid) && PoziomPoszukiwania[playerid] > 0)
        {
            sendTipMessage(playerid, "Osoby poszukiwane przez policj� nie mog� rozpocz�� s�u�by !");
            return 1;
        }
        if(IsAPolicja(playerid) && OnDutyCD[playerid] == 1)
        {
            sendTipMessageEx(playerid, COLOR_LIGHTBLUE, "U�yj /dutycd !");
            return 1;
        }
		if(GetPlayerAdminDutyStatus(playerid) == 1)
		{
			sendErrorMessage(playerid, "Nie mo�esz tego u�y�  podczas @Duty! Zejd� ze s�u�by u�ywaj�c /adminduty");
			return 1;
		}

        if((IsAPolicja(playerid) || IsAMedyk(playerid) || GetPlayerFraction(playerid) == FRAC_BOR) && PlayerInfo[playerid][pUniform] == 0)
        {
            sendTipMessage(playerid, "Nie masz skina frakcyjnego, u�yj /fskin !");
            return 1;
        }
		
        if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return sendTipMessage(playerid, "Aby wzi�� s�u�be musisz by� pieszo!");

        if(GetPVarInt(playerid, "IsAGetInTheCar") == 1)
        {
            sendErrorMessage(playerid, "Jeste� podczas wsiadania - odczekaj chwile. Nie mo�esz znajdowa� si� w poje�dzie.");
            return 1;
        }

        GetPlayerName(playerid, sendername, sizeof(sendername));
        if(PlayerInfo[playerid][pMember] == 1 || PlayerInfo[playerid][pLider] == 1)
        {
            if (PlayerToPoint(3, playerid,255.3,77.4,1003.6)
            || PlayerToPoint(5, playerid, 266.7904,118.9303,1004.6172)
            || PlayerToPoint(3, playerid, 1579.6711,-1635.4512,13.5609) //STARE DUTY
            || PlayerToPoint(3, playerid, -2614.1667,2264.6279,8.2109)
            || PlayerToPoint(3, playerid, 2425.6,117.69,26.5)//nowe domy
            || PlayerToPoint(3, playerid, -1645.3046,895.2336,-45.4141)
			|| PlayerToPoint(3, playerid, 2522.8916,-2441.6270,13.6435)
            || (PlayerToPoint(4,playerid, 1562.0536,-1649.9120,28.5040) && GetPlayerVirtualWorld(playerid) == 27))//nowe komi by charlie)//nowe komi by dywan

            {
                if(OnDuty[playerid]==0)
                {
                    format(string, sizeof(string), "* Oficer %s bierze odznak� i bro� ze swojej szafki.", sendername);
                    ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                    DajBronieFrakcyjne(playerid);
                    SetPlayerHealth(playerid, 100);
                    SetPlayerArmour(playerid, 90.0);
                    SetPlayerSkinEx(playerid, PlayerInfo[playerid][pUniform]);
                    OnDuty[playerid] = 1;
                    SetPlayerToTeamColor(playerid);
                    AddLSPDMemberToThiefMapIcons(playerid);
                }
                else if(OnDuty[playerid]==1)
                {
                    format(string, sizeof(string), "* Oficer %s odk�ada odznak� i bro� do swojej szafki.", sendername);
                    ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                    SetPlayerHealth(playerid, 100);
                    SetPlayerSkinEx(playerid, PlayerInfo[playerid][pSkin]);
                    OnDuty[playerid] = 0;
                    SetPlayerArmour(playerid, 0.0);
                    PrzywrocBron(playerid);
                    SetPlayerToTeamColor(playerid);
                    RmvLSPDMemberFromThiefMapIcons(playerid);
                }
            }
            else
            {
                sendTipMessage(playerid, "Nie jeste� w szatni !");
                return 1;
            }
        }
        else if(PlayerInfo[playerid][pMember] == 2 || PlayerInfo[playerid][pLider] == 2)
        {
            new vw = GetPlayerVirtualWorld(playerid);
            if ((vw == 2 && PlayerToPoint(3.5, playerid,592.5598,-1477.5116,82.4736)) //nowe FBI by Ubunteq
            || (vw == 2 && PlayerToPoint(5, playerid, 185.3000488281,-1571.0999755859,-54.5))//nowe domy
            || (vw == 2 && PlayerToPoint(5, playerid, 1189.5999755859,-1574.6999511719,-54.5))//nowe domy /duty w domu
            || (vw == 0 && PlayerToPoint(2, playerid, 596.5255, -1489.2544, 15.3587))) // winda fbi
            {
                if(OnDuty[playerid]==0)
                {
                    format(string, sizeof(string), "* Agent FBI %s bierze odznak� i bro� ze swojej szafki.", sendername);
                    ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                    DajBronieFrakcyjne(playerid);
                    SetPlayerArmour(playerid, 90);
                    SetPlayerHealth(playerid, 100);
                    OnDuty[playerid] = 1;
                    SetPlayerSkinEx(playerid, PlayerInfo[playerid][pUniform]);
                    SetPlayerToTeamColor(playerid);
                }
                else if(OnDuty[playerid]==1)
                {
                    format(string, sizeof(string), "* Agent FBI %s odk�ada odznak� i bro� do swojej szafki.", sendername);
                    ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                    SetPlayerArmour(playerid, 0.0);
                    SetPlayerHealth(playerid, 100);
                    OnDuty[playerid] = 0;
                    PrzywrocBron(playerid);
                    SetPlayerSkinEx(playerid, PlayerInfo[playerid][pSkin]);
                    SetPlayerToTeamColor(playerid);
                }
            }
            else
            {
                sendTipMessage(playerid, "Nie jeste� w szatni !");
                return 1;
            }
        }
        else if(PlayerInfo[playerid][pMember] == 3 || PlayerInfo[playerid][pLider] == 3)
        {
            if ( IsPlayerInRangeOfPoint(playerid, 5.0, 254.1888,77.0841,1003.6406) || IsPlayerInRangeOfPoint(playerid, 5.0, 609.0364,-555.1090,19.4573) ) //PlayerToPoint(3, playerid,255.3,77.4,1003.6) || PlayerToPoint(3,playerid,266.7904,118.9303,1004.6172) || PlayerToPoint(10.0,playerid, 2515.0200, -2459.5896, 13.8187)
            {
                if(OnDuty[playerid]==0)
                {
                    format(string, sizeof(string), "* Funkcjonariusz %s bierze mundur i bro� ze swojej szafki.", sendername);
                    ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                    DajBronieFrakcyjne(playerid);
                    SetPlayerArmour(playerid, 90);
                    SetPlayerHealth(playerid, 100);
                    OnDuty[playerid] = 1;
                    SetPlayerToTeamColor(playerid);
                    SetPlayerSkinEx(playerid, PlayerInfo[playerid][pUniform]);
                }
                else if(OnDuty[playerid]==1)
                {
                    format(string, sizeof(string), "* Funkcjonariusz %s odk�ada mundur i bro� do swojej szafki.", sendername);
                    ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                    SetPlayerArmour(playerid, 0.0);
                    SetPlayerHealth(playerid, 100);
                    OnDuty[playerid] = 0;
                    SetPlayerToTeamColor(playerid);
                    SetPlayerSkinEx(playerid, PlayerInfo[playerid][pSkin]);
                    PrzywrocBron(playerid);
                }
            }
            else
            {
                sendTipMessage(playerid, "Nie jeste� w szatni !");
                return 1;
            }
        }
		else if(GetPlayerOrg(playerid) == 12)
		{
			if ( IsPlayerInRangeOfPoint(playerid, 5.0, 2522.8916,-2441.6270,13.6435) )
            {
				if(OnDuty[playerid]==0)
                {
                    format(string, sizeof(string), "* �o�nierz %s bierze odznak� i bro� ze swojej szafki.", sendername);
                    ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                    SetPlayerArmour(playerid, 90);
                    SetPlayerHealth(playerid, 100);
					
					if(PlayerInfo[playerid][pSex] == 1)
						SetPlayerSkinEx(playerid, 287);
					else
						SetPlayerSkinEx(playerid, 191);
                    OnDuty[playerid] = 1;
                }
                else if(OnDuty[playerid]==1)
                {
                    format(string, sizeof(string), "* �o�nierz %s odk�ada odznak� i bro� do swojej szafki.", sendername);
                    ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                    SetPlayerArmour(playerid, 0.0);
                    SetPlayerHealth(playerid, 100);
                    OnDuty[playerid] = 0;
                    SetPlayerSkinEx(playerid, PlayerInfo[playerid][pSkin]);
                    PrzywrocBron(playerid);
                }
			}
		}
        else if(GetPlayerFraction(playerid) == FRAC_ERS)
        {
            if (PlayerToPoint(4, playerid,1147.3623,-1314.4891,13.6743))
            {
                if(JobDuty[playerid] == 1)
                {
                    SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Nie jeste� ju� na s�u�bie LSRS, nie b�dziesz widzia� zg�osze�.");
                    JobDuty[playerid] = 0;
                    Medics -= 1;
                    SetPlayerSkinEx(playerid, PlayerInfo[playerid][pSkin]);
                    SetPlayerToTeamColor(playerid);
                }
                else
                {
                    SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Jeste� na s�u�bie LSRS, kiedy kto� b�dzie potrzebowa� pomocy zostanie wy�wietlony komunikat.");
                    JobDuty[playerid] = 1;
                    Medics += 1;
                    SetPlayerSkinEx(playerid, PlayerInfo[playerid][pUniform]);
                    SetPlayerToTeamColor(playerid);
                }
            }
            else
            {
                sendTipMessage(playerid, "Nie jeste� w szatni !");
                return 1;
            }
        }
        else if(PlayerInfo[playerid][pMember] == 11||PlayerInfo[playerid][pLider] == 11)
        {
            if(JobDuty[playerid] == 1)
            {
                SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Nie jeste� ju� na s�u�bie urz�dasa.");
                JobDuty[playerid] = 0;
                SetPlayerToTeamColor(playerid);
                SetPlayerSkinEx(playerid, PlayerInfo[playerid][pSkin]);
				
            }
            else
            {
                SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Jeste� ju� na s�u�bie urz�dasa. Id� do Urz�du urz�dasie.");
                JobDuty[playerid] = 1;
                SetPlayerToTeamColor(playerid);
                SetPlayerSkinEx(playerid, PlayerInfo[playerid][pUniform]);
            }
        }
        else if(PlayerInfo[playerid][pMember] == 7||PlayerInfo[playerid][pLider] == 7)
        {
            if (PlayerToPoint(5, playerid, 1521.8843,-1479.6427,22.9377))
            {
                if(OnDuty[playerid]==0)
                {
                    format(string, sizeof(string), "* Agent USSS %s wyci�ga bro� i garnitur z szafy.", sendername);//a
                    ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                    OnDuty[playerid]= 1;
                    DajBronieFrakcyjne(playerid);
                    SetPlayerArmour(playerid, 90);
                    SetPlayerHealth(playerid, 100);
                    SetPlayerSkinEx(playerid, PlayerInfo[playerid][pUniform]);
                    SetPlayerToTeamColor(playerid);
                }
                else if(OnDuty[playerid]==1)
                {
                    format(string, sizeof(string), "* Agent USSS %s chowa bro� i garnitur do szafy.", sendername);
                    ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                    SetPlayerArmour(playerid, 0);
                    SetPlayerHealth(playerid, 100);
                    OnDuty[playerid] = 0;
                    SetPlayerSkinEx(playerid, PlayerInfo[playerid][pSkin]);
                    SetPlayerToTeamColor(playerid);
                    PrzywrocBron(playerid);
                }
            }
        }
        else if(PlayerInfo[playerid][pMember] == 10 || PlayerInfo[playerid][pLider] == 10)
        {
			if(JobDuty[playerid] == 1)
            {
				SendClientMessage(playerid, COLOR_LIGHTBLUE, "*Nie jeste� ju� na s�u�bie taks�wkarza");
				JobDuty[playerid] = 0;
				SetPlayerToTeamColor(playerid);
				SetPlayerSkinEx(playerid, PlayerInfo[playerid][pSkin]);
            }
            else
            {
				SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Wchodzisz na s�u�b�, udaj si� do pojazdu!");
                JobDuty[playerid] = 1;
                SetPlayerToTeamColor(playerid);
                SetPlayerSkinEx(playerid, PlayerInfo[playerid][pUniform]);
            }
        }
        else if(PlayerInfo[playerid][pJob] == 7)
        {
            if(AntySpam[playerid] == 0)
            {
                if(JobDuty[playerid] == 1)
                {
                    SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Nie jeste� ju� na s�u�bie mechanika, nie b�d� ci si� wy�wietla� zg�oszenia.");
                    JobDuty[playerid] = 0;
                    Mechanics -= 1;
                }
                else
                {
                    SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Jeste� na s�u�bie mechanika, kiedy kto� b�dzie ci� potrzebowa� zostanie wy�wietlony komunikat.");
                    JobDuty[playerid] = 1;
                    Mechanics += 1;
                }
                AntySpam[playerid] = 1;
                SetTimerEx("AntySpamTimer",10000,0,"d",playerid);
            }
            else
            {
                SendClientMessage(playerid, COLOR_GREY, "Odczekaj 10 sekund");
            }
        }
        else if(PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLider] == 9)
        {
            if(SanDuty[playerid] == 1)
            {
                SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Nie jeste� ju� na s�u�bie reportera, komunikaty oraz kasa za SMS nie b�d� wysy�ane.");
                SetPlayerSkinEx(playerid, PlayerInfo[playerid][pSkin]);
                SanDuty[playerid] = 0;
                SetPlayerToTeamColor(playerid);
            }
            else
            {
                SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Jeste� na s�u�bie reportera.");
                SetPlayerSkinEx(playerid, PlayerInfo[playerid][pUniform]);
                SanDuty[playerid] = 1;
                SetPlayerToTeamColor(playerid);
            }
        }
        else
        {
            sendTipMessage(playerid, "Nie jeste� policjantem !");
        }
    }
    return 1;
}
