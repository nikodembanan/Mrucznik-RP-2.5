//OnDialogResponse.pwn


stock IsDialogProtected(dialogid)
{
    switch(dialogid)
    {
        case D_PANEL_KAR_NADAJ..D_PANEL_KAR_ZNAJDZ_INFO, D_PERM, D_CREATE_ORG_NAME, D_CREATE_ORG_UID, D_PANEL_CHECKPLAYER, D_EDIT_RANG_NAME, D_OPIS_UPDATE, D_VEHOPIS_UPDATE: return true;
    }
    return false; //dodac dialogi z mysql
}

//ID DIALOG�W 9900+ BIZNESY.
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	#if DEBUG == 1
		printf("%s OnDialogResponse(%d, %d, %d, %d, %s) - begin", GetNick(playerid), playerid, dialogid, response, listitem, inputtext);
	#endif
    if(dialogid < 0) return 1;
    if(dialogid != iddialog[playerid])
    {
        if(dialogid == D_ANIMLIST || dialogid > 10000 && dialogid < 10100) return 0;
        GUIExit[playerid] = 0;
        SendClientMessage(playerid, COLOR_RED, "B��dne ID GUI.");
        #if defined DEBUG
        printf("B��dne ID dialogu dla [%d] aktualny [%d] przypisany %d", playerid, dialogid,iddialog[playerid]);
        #endif
        return 1;
    }
    if(IsDialogProtected(dialogid) || true) //MySQL anti injection
    {
		for(new i; i<strlen(inputtext); i++)
		{
			if(inputtext[i] == '%')
			{
                SendClientMessage(playerid, COLOR_PANICRED, "Nie mo�na posiada� \"%\" w ha�le");
				KickEx(playerid);
				return 0;
            }
		}
    }
	if(antyHider[playerid] != 1)
	{
		if(gettime() > GetPVarInt(playerid, "lastDialogCzitMsg"))
		{
			SetPVarInt(playerid, "lastDialogCzitMsg", gettime() + 60);
			new string[128];
			format(string, sizeof(string), "AdmWarn: %s(ID: %i) <- ten gnoj czituje dialogi sprawdzcie co robi", GetNick(playerid, true), playerid);
			SendAdminMessage(COLOR_YELLOW, string);	
		}
		return 1;
	}

	antyHider[playerid] = 0;
	
	//2.5.8
	premium_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	hq_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	//2.5.2
	if(dialogid == DIALOG_HA_ZMIENSKIN(0))
	{
		if(response)
		{
			if(FRAC_SKINS[listitem+1][0] == 0)
			{
				sendErrorMessage(playerid, "Ta frakcja nie ma skin�w");
				ShowPlayerDialogEx(playerid, DIALOG_HA_ZMIENSKIN(0), DIALOG_STYLE_LIST, "Zmiana ubrania", DialogListaFrakcji(), "Start", "Anuluj");
				return 1;
			}
			ShowPlayerDialogEx(playerid, DIALOG_HA_ZMIENSKIN(listitem+1), DIALOG_STYLE_PREVMODEL, "Zmiana ubrania", DialogListaSkinow(listitem+1), "Start", "Anuluj");
		}
	}
	else if(dialogid >= DIALOG_HA_ZMIENSKIN(1) && dialogid <= DIALOG_HA_ZMIENSKIN(MAX_FRAC))
	{
		if(response)
		{
			new string[64];
			SetPlayerSkin(playerid, FRAC_SKINS[dialogid-DIALOG_HA_ZMIENSKIN(0)][listitem]);
			format(string, sizeof(string), "* %s zdejmuje ubrania i zak�ada nowe.", GetNick(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else
		{
			ShowPlayerDialogEx(playerid, DIALOG_HA_ZMIENSKIN(0), DIALOG_STYLE_LIST, "Zmiana ubrania", DialogListaFrakcji(), "Start", "Anuluj");
		}
	}
	else if(dialogid == 9520)
	{
	    new kasa = GetPVarInt(playerid, "Mats-kasa");
        new giveplayerid = GetPVarInt(playerid, "Mats-id");
        new moneys = GetPVarInt(playerid, "Mats-mats");
		new firstValue = PlayerInfo[playerid][pMats];
        new string[256];
		if(!response)
		{
		    SetPVarInt(playerid, "OKupMats", 0);
			SetPVarInt(giveplayerid, "OSprzedajMats", 0);
			SetPVarInt(playerid, "Mats-kasa", 0);
        	SetPVarInt(playerid, "Mats-id", 0);
        	SetPVarInt(playerid, "Mats-mats", 0);
        	sendErrorMessage(playerid, "Sprzeda� zosta�a anulowana!");
        	sendErrorMessage(giveplayerid, "Sprzeda� zosta�a anulowana!");
			return 1;
		}
		if(kaska[playerid] < kasa) return sendErrorMessage(playerid, "Nie masz tyle kasy!");
		if(GetPVarInt(playerid, "OKupMats") == 0) return sendErrorMessage(playerid, "Co� posz�o nie tak! (kupno)");
        //if(GetPVarInt(playerid, "OSprzedajMats") == 0) return sendErrorMessage(playerid, "Co� posz�o nie tak! (sprzeda�)");
		if(GetPVarInt(giveplayerid, "OSprzedajMats") == 1)
		{
			format(string, sizeof(string), "   Dosta�e� %d materia��w od gracza %s za %d $.", moneys, GetNick(giveplayerid), kasa);
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
			format(string, sizeof(string), "   Da�e� %d materia��w graczowi %s za %d $.", moneys, GetNick(playerid), kasa);
			SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
			format(string, sizeof(string),"%s da� %s torb� z materia�ami.", GetNick(giveplayerid), GetNick(playerid));
			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			PlayerInfo[giveplayerid][pMats] -= moneys;
			PlayerInfo[playerid][pMats] += moneys;
			DajKase(giveplayerid, kasa);
			DajKase(playerid, -kasa);
			
			format(string, sizeof(string), "%s kupil od %s materialy (Kupil: %d || Poprzednio: %d || Cena: %d)", GetNick(playerid), GetNick(giveplayerid), moneys, firstValue, kasa);
			PayLog(string);
			SetPVarInt(playerid, "OKupMats", 0);
			SetPVarInt(giveplayerid, "OSprzedajMats", 0);
			SetPVarInt(playerid, "Mats-kasa", 0);
        	SetPVarInt(playerid, "Mats-id", 0);
        	SetPVarInt(playerid, "Mats-mats", 0);
			
		}
		else
		{
		    sendErrorMessage(playerid, "Co� posz�o nie tak! (sprzeda�)");
		}
	}
	else if(dialogid == 9519)
	{
		if(!response) return 1;
		if(kaska[playerid] < 30000) return sendErrorMessage(playerid, "Nie masz tyle kasy");
		SetPlayerArmour(playerid, 90);
		SetPlayerHealth(playerid, 100);
		DajKase(playerid, -30000);
		sendTipMessage(playerid, "Zaplaciles $30000 za kamizelke i �ycie");
	}	
	//PA�DZIOCH
	else if(dialogid == DIALOGID_MUZYKA) 
	{
		switch(listitem)
		{
			case 0:
			{
			    if(!response) return 1;
				PlayerFixRadio(playerid);
				PlayAudioStreamForPlayer(playerid, "http://4stream.pl:18434");
				return 1;
			}
			case 1:
			{
			    if(!response) return 1;
				PlayerFixRadio(playerid);
				PlayAudioStreamForPlayer(playerid, RadioSANUno);
				return 1;
			}
			case 2:
			{
			    if(!response) return 1;
				PlayerFixRadio(playerid);
				PlayAudioStreamForPlayer(playerid, RadioSANDos);
				return 1;
			}
			case 3:
			{
			    if(!response) return 1;
				StopAudioStreamForPlayer(playerid);
				PlayAudioStreamForPlayer(playerid, "http://zet-net-01.cdn.eurozet.pl:8400/listen.pls");
				return 1;
			}
			case 4:
			{
				if(!response) return 1;
				StopAudioStreamForPlayer(playerid);
				PlayAudioStreamForPlayer(playerid, "http://www.miastomuzyki.pl/n/rmffm.pls");
				return 1;
			}
			case 5:
			{
				if(!response) return 1;
				StopAudioStreamForPlayer(playerid);
				PlayAudioStreamForPlayer(playerid, "http://www.miastomuzyki.pl/n/rmfmaxxx.pls");
				return 1;
			}
			case 6:
			{
				if(!response) return 1;
				StopAudioStreamForPlayer(playerid);
				PlayAudioStreamForPlayer(playerid, "http://radyjko.tk/stacja.pls?id=32 ");
				return 1;
			}
			case 7:
			{
				if(!response) return 1;
				ShowPlayerDialogEx(playerid, DIALOGID_MUZYKA_URL, DIALOG_STYLE_INPUT, "W�asne MP3", "Wprowadz adres URL do radia/piosenki.", "Start", "Anuluj");
				return 1;
			}
			case 8:
			{
			    if(!response) return 1;
				GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~r~MP3 Off", 5000, 5);
				PlayerFixRadio(playerid);
				StopAudioStreamForPlayer(playerid);
				SetPVarInt(playerid, "SluchaBasenu", 0);
				return 1;
			}
		}
	}
	else if(dialogid == DIALOGID_MUZYKA_URL)
	{
		if(response)
		{
			//if(IsAValidURL(inputtext))
			//{
				StopAudioStreamForPlayer(playerid);
				PlayAudioStreamForPlayer(playerid, inputtext);
			//}
			//else
			//{
			//	SendClientMessage(playerid, COLOR_GREY, "Z�y adres URL");
			//	ShowPlayerDialogEx(playerid, DIALOGID_MUZYKA_URL, DIALOG_STYLE_INPUT, "W�asne MP3", "Wprowadz adres URL do radia/piosenki.", "Start", "Anuluj");
			//}
		}
		return 1;
	}
	else if(dialogid == DIALOGID_PODSZYJ)
	{
		switch(listitem)
		{
			case 0:
			{
				ShowPlayerDialogEx(playerid, DIALOGID_PODSZYJ_ZMIENID(1), DIALOG_STYLE_PREVMODEL_LIST, "Podszywasz si� pod FBI.", "165\nAgent FBI (Bia�y)\n166\nAgent FBI (Czarny)\n211\nAgentka FBI\n286\nAgent ICB\n295\nDyrektor FBI", "Podszyj", "Anuluj");
				return 1;
			}
			case 1:
			{
				ShowPlayerDialogEx(playerid, DIALOGID_PODSZYJ_ZMIENID(2), DIALOG_STYLE_PREVMODEL_LIST, "Podszywasz si� pod Grove.", "105\nCz�onek Grove\n106\nCz�onek Grove\n107\nCz�onek Grove\n269\nCz�onek Grove\n270\nCz�onek Grove\n271\nCz�onek Grove", "Podszyj", "Anuluj");
				return 1;
			}
			case 2:
			{
				ShowPlayerDialogEx(playerid, DIALOGID_PODSZYJ_ZMIENID(3), DIALOG_STYLE_PREVMODEL_LIST, "Podszywasz si� pod Ballas.", "102\nCz�onek Ballas\n103\nCz�onek Ballas\n104\nCz�onek Ballas", "Podszyj", "Anuluj");
				return 1;
			}
			case 3:
			{
				ShowPlayerDialogEx(playerid, DIALOGID_PODSZYJ_ZMIENID(4), DIALOG_STYLE_PREVMODEL_LIST, "Podszywasz si� pod ICC.", "124\nCz�onek ICC\n125\nCz�onek ICC\n126\nCz�onek ICC\n111\nCz�onek ICC\n113\nBoss ICC", "Podszyj", "Anuluj");
				return 1;
			}
			case 4:
			{
				ShowPlayerDialogEx(playerid, DIALOGID_PODSZYJ_ZMIENID(5), DIALOG_STYLE_PREVMODEL_LIST, "Podszywasz si� pod Yakuze.", "117\nCz�onek Yakuzy\n118\nCz�onek Yakuzy\n120\nBoss Yakuzy\n122\nCz�onek Yakuzy\n123\nBoss Yakuzy", "Podszyj", "Anuluj");
				return 1;
			}
			case 5:
			{
				ShowPlayerDialogEx(playerid, DIALOGID_PODSZYJ_ZMIENID(6), DIALOG_STYLE_PREVMODEL_LIST, "Podszywasz si� pod Latin Kings.", "108\nCz�onek Latin Kings\n109\nCz�onek Latin Kings\n110\nBoss Latin Kings", "Podszyj", "Anuluj");
				return 1;
			}
		}
	}
	else if(dialogid == DIALOGID_PODSZYJ_ZMIENID(1))
	{
		switch(listitem)
		{
			case 0:
			{
				SetPlayerColor(playerid, COLOR_FBI);//kolor
				SetPlayerSkin(playerid, 165);
				PlayerInfo[playerid][pTajniak] = 0;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod FBI.");
				return 1;
			}
			case 1:
			{
				SetPlayerColor(playerid, COLOR_FBI);//kolor
				SetPlayerSkin(playerid, 166);
				PlayerInfo[playerid][pTajniak] = 0;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod FBI.");
				return 1;
			}
			case 2:
			{
				SetPlayerColor(playerid, COLOR_FBI);//kolor
				SetPlayerSkin(playerid, 211);
				PlayerInfo[playerid][pTajniak] = 0;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod FBI.");
				return 1;
			}
			case 3:
			{
				SetPlayerColor(playerid, COLOR_FBI);//kolor
				SetPlayerSkin(playerid, 286);
				PlayerInfo[playerid][pTajniak] = 0;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod FBI.");
				return 1;
			}
			case 4:
			{
				SetPlayerColor(playerid, COLOR_FBI);//kolor
				SetPlayerSkin(playerid, 295);
				PlayerInfo[playerid][pTajniak] = 0;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod FBI.");
				return 1;
			}
		}
	}

	else if(dialogid == DIALOGID_PODSZYJ_ZMIENID(2))
	{
		switch(listitem)
		{
			case 0:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 105);
				PlayerInfo[playerid][pTajniak] = 1;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Grove.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 1:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 106);
				PlayerInfo[playerid][pTajniak] = 1;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Grove.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 2:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 107);
				PlayerInfo[playerid][pTajniak] = 1;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Grove.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 3:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 269);
				PlayerInfo[playerid][pTajniak] = 1;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Grove.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 4:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 270);
				PlayerInfo[playerid][pTajniak] = 1;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Grove.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 5:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 271);
				PlayerInfo[playerid][pTajniak] = 1;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Grove.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
		}
	}

	else if(dialogid == DIALOGID_PODSZYJ_ZMIENID(3))
	{
		switch(listitem)
		{
			case 0:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 102);
				PlayerInfo[playerid][pTajniak] = 2;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Ballas.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 1:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 103);
				PlayerInfo[playerid][pTajniak] = 2;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Ballas.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 2:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 104);
				PlayerInfo[playerid][pTajniak] = 2;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Ballas.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
		}
	}

	else if(dialogid == DIALOGID_PODSZYJ_ZMIENID(4))
	{
		switch(listitem)
		{
			case 0:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 124);
				PlayerInfo[playerid][pTajniak] = 3;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod ICC.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 1:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 125);
				PlayerInfo[playerid][pTajniak] = 3;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod ICC.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 2:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 126);
				PlayerInfo[playerid][pTajniak] = 3;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod ICC.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 3:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 111);
				PlayerInfo[playerid][pTajniak] = 3;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod ICC.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 4:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 113);
				PlayerInfo[playerid][pTajniak] = 3;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod ICC.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
		}
		return 1;
	}

	else if(dialogid == DIALOGID_PODSZYJ_ZMIENID(5))
	{
		switch(listitem)
		{
			case 0:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 117);
				PlayerInfo[playerid][pTajniak] = 4;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Yakuze.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 1:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 118);
				PlayerInfo[playerid][pTajniak] = 4;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Yakuze.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 2:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 120);
				PlayerInfo[playerid][pTajniak] = 4;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Yakuze.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 3:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 122);
				PlayerInfo[playerid][pTajniak] = 4;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Yakuze.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 4:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 123);
				PlayerInfo[playerid][pTajniak] = 4;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Yakuze.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
		}
		return 1;
	}

	else if(dialogid == DIALOGID_PODSZYJ_ZMIENID(6))
	{
		switch(listitem)
		{
			case 0:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 108);
				PlayerInfo[playerid][pTajniak] = 5;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Latin Kings.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 1:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 109);
				PlayerInfo[playerid][pTajniak] = 5;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Latin Kings.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
			case 2:
			{
				SetPlayerColor(playerid, TEAM_HIT_COLOR);//kolor
				SetPlayerSkin(playerid, 110);
				PlayerInfo[playerid][pTajniak] = 5;
				PlayerInfo[playerid][pTeam] = 2;//team
				gTeam[playerid] = 2;//team
				SendClientMessage(playerid, COLOR_GRAD2, "Podszy�e� si� pod Latin Kings.");
				SetPlayerArmour(playerid, 10);
				return 1;
			}
		}
		return 1;
	}
    else if(dialogid == D_VEHOPIS)
    {
        if(!response) return 1;
        new id;
        if(strcmp(inputtext, "� Ustaw opis", false, 12) == 0) id = 1;
        else if(strcmp(inputtext, "� Zmie� opis", false, 12) == 0) id = 2;
        else if(strcmp(inputtext, "� Usu�", false, 6) == 0) id = 3;

        switch(id)
        {
            case 1:
            {
                new veh = GetPlayerVehicleID(playerid);
                if(strcmp(CarDesc[veh], "BRAK", true) == 0)
                {
                    RunCommand(playerid, "/vopis",  "");
                    SendClientMessage(playerid, COLOR_GRAD2, "Pojazd nie posiada opisu.");
                    return 1;
                }
                CarOpis_Usun(playerid, veh);

                new opis[128];
                strunpack(opis, CarDesc[veh]);
                new str[128];
                WordWrap(opis, true, str);

                CarOpis[veh] = CreateDynamic3DTextLabel(str, COLOR_PURPLE, 0.0, 0.0, -0.2, 5.0, INVALID_PLAYER_ID, veh);
                format(CarOpisCaller[veh], MAX_PLAYER_NAME, "%s", GetNick(playerid));
                SendClientMessage(playerid, -1, "{99CC00}Ustawi�es w�asny opis pojazdu, by go usun�� wpisz {CC3333}/vopis usu�{CC3333}");
            }
            case 2:
            {
                ShowPlayerDialogEx(playerid, D_VEHOPIS_UPDATE, DIALOG_STYLE_INPUT, "Opis pojazdu", "Wprowad� ni�ej w�asny opis pojazdu.", "Ustaw", "Wr��");
            }
            case 3:
            {
                if(!CarOpis_Usun(playerid, GetPlayerVehicleID(playerid), true))
                {
                    SendClientMessage(playerid, -1, "Opis: Pojazd nie posiada opisu.");
                    RunCommand(playerid, "/vopis",  "");
                    return 1;
                }
                RunCommand(playerid, "/vopis",  "");
            }
        }
        return 1;
    }
    else if(dialogid == D_VEHOPIS_UPDATE)
    {
        if(!response) return RunCommand(playerid, "/vopis",  "");
        if(strlen(inputtext) < 4 || strlen(inputtext) > 120)
        {
            RunCommand(playerid, "/vopis",  "");
            SendClientMessage(playerid, COLOR_GRAD1, "Opis: Nieodpowiednia d�ugos� opisu.");
            return 1;
        }
         else for (new i = 0, len = strlen(inputtext); i != len; i ++) {
		    if ((inputtext[i] >= 'A' && inputtext[i] <= 'Z') || (inputtext[i] >= 'a' && inputtext[i] <= 'z') || (inputtext[i] >= '0' && inputtext[i] <= '9') || (inputtext[i] == ' ') || (inputtext[i] == ',') || (inputtext[i] == '.') || (inputtext[i] == '!') || (inputtext[i] == ':') || (inputtext[i] == '-') || (inputtext[i] == '{') || (inputtext[i] == '}') || (inputtext[i] == '[') || (inputtext[i] == ']'))
				continue;
            else if ((inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�') || (inputtext[i] == '�'))
                continue;
			else return SendClientMessage(playerid, COLOR_GRAD1, "Opis: U�y�e� nieodpowiednich znak�w opisu.");
		}
        new veh = GetPlayerVehicleID(playerid);
        strdel(CarDesc[veh], 0, 128 char);
        strpack(CarDesc[veh], inputtext);
        MruMySQL_UpdateOpis(veh, CarData[VehicleUID[veh][vUID]][c_UID], 2);
        RunCommand(playerid, "/vopis",  "");
        return 1;
    }
    else if(dialogid == D_PERM)
    {
        if(!(Uprawnienia(playerid, ACCESS_EDITPERM) && IsPlayerAdmin(playerid))) return SendClientMessage(playerid, -1, "(PERM) - Nie posiadasz pe�nych praw.");
        new param[8];
        GetPVarString(playerid, "perm-id", param, 8);
        new id = strval(param);
        new str[128];
        if(!response)
        {

            if(OLD_ACCESS[id] != ACCESS[id])
            {
                OLD_ACCESS[id] = ACCESS[id];
                format(str, 128, "(PERM) %s zapisa� Twoje nowe uprawnienia", GetNick(playerid));
                SendClientMessage(id, 0x05CA8CFF, str);
                format(str, 128, "(PERM) Zapisales prawa %s", GetNick(id));
                SendClientMessage(playerid, 0x05CA8CFF, str);
                format(str, 128, "SELECT `UID` FROM `mru_uprawnienia` WHERE `UID`=%d", PlayerInfo[id][pUID]);
                mysql_query(str);
                mysql_store_result();
                if(mysql_num_rows()) format(str, 128, "UPDATE `mru_uprawnienia` SET `FLAGS`= b'%b' WHERE `UID`=%d", ACCESS[id], PlayerInfo[id][pUID]);
                else format(str, 128, "INSERT INTO `mru_uprawnienia` (`FLAGS`, `UID`) VALUES (b'%b', %d)", ACCESS[id], PlayerInfo[id][pUID]);
                mysql_query(str);
                printf("(PERM) %s zmienil prawa %s (%d) na %b",GetNick(playerid), GetNick(id), PlayerInfo[id][pUID], ACCESS[id]);
            }
            return 1;
        }
        switch(listitem)
        {
            case 1: ACCESS[id] ^= ACCESS_PANEL;
            case 2: ACCESS[id] ^= ACCESS_KARY;
            case 3: ACCESS[id] ^= ACCESS_KARY_ZNAJDZ;
            case 4: ACCESS[id] ^= ACCESS_KARY_BAN;
            case 5: ACCESS[id] ^= ACCESS_KARY_UNBAN;
            case 6: ACCESS[id] ^= ACCESS_ZG;
            case 7: ACCESS[id] ^= ACCESS_GIVEHALF;
            case 8: ACCESS[id] ^= ACCESS_MAKELEADER;
            case 9: ACCESS[id] ^= ACCESS_MAKEFAMILY;
            case 10: ACCESS[id] ^= ACCESS_DELETEORG;
            case 11: ACCESS[id] ^= ACCESS_EDITCAR;
            case 12: ACCESS[id] ^= ACCESS_EDITRANG;
            case 13: ACCESS[id] ^= ACCESS_EDITPERM;
        }
        format(str, 128, "(PERM) %s edytowa� Twoje uprawnienia (/uprawnienia)", GetNick(playerid));
        SendClientMessage(id, 0x05CA8CFF, str);
        RunCommand(playerid, "/edytujupr",  param);
    }
    else if(dialogid == DIALOG_PATROL)
    {
        if(!response)
        {
            SetPVarInt(playerid, "patrol", 0);
            return 0;
        }
        if(listitem == 0)
        {
            new pat = GetPVarInt(playerid, "patrol-id");
            SetPVarInt(playerid, "patrol-parent", -1);
            PatrolInfo[pat][patroluje][0] = playerid;
            PatrolInfo[pat][patroluje][1] = INVALID_PLAYER_ID;
            PatrolInfo[pat][patstrefa] = 0;
            PatrolInfo[pat][patstan] = 1;
            PatrolInfo[pat][pataktywny] = 2;
            PatrolInfo[pat][pattyp] = 1; //PlayerInfo[playerid][pFrac] 1 PD 2 FBI 3 NG
            PatrolInfo[pat][pattime] = gettime();

            SendClientMessage(playerid, COLOR_BLUE, "Rozpoczynasz patrol samodzielny. Wybierz stref� do patrolowania.");
            Patrol_ShowMap(playerid);
            SetPVarInt(playerid, "patrol-map", 1);
            SelectTextDraw(playerid, 0xD2691E55);
        }
        else
        {
            ShowPlayerDialogEx(playerid, DIALOG_PATROL_PARTNER, DIALOG_STYLE_INPUT, "Konfiguracja patrolu � Partner", "Wprowad� nazw� gracza lub ID, z kt�rym b�dziesz patrolowa� teren.", "Dodaj", "Anuluj");
        }
    }
    else if(dialogid == DIALOG_PATROL_NAME)
    {
        if(!response)
        {
            SetPVarInt(playerid, "patrol", 0);
            return 0;
        }
        if(isnull(inputtext) || strlen(inputtext) < 2) return 0;
        if(strfind(PatrolSq, inputtext, true) == -1)
        {
            strcat(PatrolSq, inputtext);
            format(PatrolInfo[GetPVarInt(playerid, "patrol-id")][patname], 16, "%s" ,inputtext);
            ShowPlayerDialogEx(playerid, DIALOG_PATROL, DIALOG_STYLE_LIST, "Konfiguracja patrolu � Typ", "Patrol samodzielny\nPatrol z partnerem", "Wybierz", "Anuluj");
        }
        else ShowPlayerDialogEx(playerid, DIALOG_PATROL_NAME, DIALOG_STYLE_INPUT, "Konfiguracja patrolu � Nazwa", "Ta nazwa jest zaj�ta.\r\nWprowad� nazw� patrolu (kryptonim)", "Dalej", "Anuluj");
    }
    else if(dialogid == DIALOG_PATROL_PARTNER)
    {
        new pat = GetPVarInt(playerid, "patrol-id");
        if(!response)
        {
            new pos = strfind(PatrolSq, PatrolInfo[pat][patname], true);
            strdel(PatrolSq, pos, pos + strlen(PatrolInfo[pat][patname]));
            strdel(PatrolInfo[pat][patname], 0, 16);

            SetPVarInt(playerid, "patrol", 0);
            return 0;
        }
        new id;
        sscanf(inputtext, "k<fix>", id);
        if(id == INVALID_PLAYER_ID) return ShowPlayerDialogEx(playerid, DIALOG_PATROL_PARTNER, DIALOG_STYLE_INPUT, "Konfiguracja patrolu � Partner", "Nie znaleziono gracza...\r\nWprowad� nazw� gracza lub ID, z kt�rym b�dziesz patrolowa� teren.", "Dodaj", "Anuluj");
        PatrolInfo[pat][patroluje][0] = playerid;
        PatrolInfo[pat][patroluje][1] = id;
        PatrolInfo[pat][patstrefa] = 0;
        PatrolInfo[pat][patstan] = 1;
        PatrolInfo[pat][pataktywny] = 2;
        PatrolInfo[pat][pattime] = gettime();
        new str[128], nick[MAX_PLAYER_NAME+1];
        GetPlayerName(playerid, nick, MAX_PLAYER_NAME);
        format(str, 128, "PATROL �� %s chce patrolowa� z Tob� teren. Aby akceptowa� wpisz /patrol akceptuj", nick);
        SetPVarInt(playerid, "patrol-parent", id);
        SetPVarInt(id, "patrol-parent", playerid);
        SetPVarInt(id, "patrol-dec", 1);
        SetPVarInt(playerid, "patrol-id", pat);
        SetPVarInt(playerid, "patrol-time", PatrolInfo[pat][pattime]);
        SetPVarInt(id, "patrol-time", PatrolInfo[pat][pattime]);
        SendClientMessage(id, COLOR_BLUE, str);
        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wys�ano zapytanie do gracza o pomoc w patrolowaniu.");
    }
    //PANEL ADMINA
    else if(dialogid == D_PANEL_ADMINA)
    {
        if(!response) return 1;
        new upr = GetPVarInt(playerid, "panel-upr");
        if(listitem == 0)
        {
            if(!(upr & 0b10)) return 1;
            SetPVarInt(playerid, "panel-ok", 1);
            ShowPlayerDialogEx(playerid, D_PANEL_KAR, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", TEXT_D_PANEL_KARY, "Wybierz", "Wyjd�");
        }
        else if(listitem == 1)
        {
            ShowPlayerDialogEx(playerid, D_PANEL_CHECKPLAYER, DIALOG_STYLE_INPUT, "M-RP � Sprawdzanie statystyk gracza", "Wprowad� nick gracza:                    ", "Sprawd�", "Wyjd�");
        }
    }
    else if(dialogid == D_PANEL_CHECKPLAYER)
    {
        if(!response) return RunCommand(playerid, "/panel",  "");
        if(strlen(inputtext) < 1 || strlen(inputtext) > MAX_PLAYER_NAME)
        {
            SendClientMessage(playerid, COLOR_RED, "Niepoprawna d�ugosc!");
            ShowPlayerDialogEx(playerid, D_PANEL_CHECKPLAYER, DIALOG_STYLE_INPUT, "M-RP � Sprawdzanie statystyk gracza", "Wprowad� nick gracza:                    ", "Sprawd�", "Wyjd�");
            return 0;
        }
        new lStr[256];
		new nick_escaped[MAX_PLAYER_NAME];
		mysql_real_escape_string(inputtext, nick_escaped);
        format(lStr, 256, "SELECT `Level`, `Admin`, `ZaufanyGracz`, `PAdmin`, `DonateRank`, `Money`, `Bank`, `PhoneNr`, `Job`, `BlokadaPisania`, `Member`, `FMember`, `Dom`, `Block`, `ZmienilNick`, `Warnings`, `UID` FROM `mru_konta` WHERE `Nick`='%s'", nick_escaped);
        mysql_query(lStr);
        mysql_store_result();
        if(mysql_num_rows())
        {
            mysql_fetch_row_format(lStr, "|");
            new plvl, padmin, pzg, ppadmin, ppremium, pmoney, pbank, pnr, pjob, pbp, pmember, porg, pdom, pblock, pzn, pwarn, puid;
            sscanf(lStr, "p<|>ddddddddddddddddd", plvl, padmin, pzg, ppadmin, ppremium, pmoney, pbank, pnr, pjob, pbp, pmember, porg, pdom, pblock, pzn, pwarn, puid);
            format(lStr, 256, "> %s {FFFFFF}(UID: %d)",inputtext,puid);
            SendClientMessage(playerid, COLOR_RED, lStr);
            format(lStr, 256, "Level: %d � Kasa: %d � Bank: %d � Numer tel.: %d � ZN: %d � Dom: %d", plvl, pmoney, pbank, pnr, pzn, pdom);
            SendClientMessage(playerid, -1, lStr);
            format(lStr, 256, "Admin: %d � P@: %d � ZG: %d � BP: %d � Block: %d : Warny: %d", padmin, ppadmin, pzg, pbp, pblock, pwarn);
            SendClientMessage(playerid, -1, lStr);
            format(lStr, 256, "Premium: %d � Praca: %d � Frakcja: %d � Org.: %d", ppremium, pjob, pmember, porg);
            SendClientMessage(playerid, -1, lStr);
            SendClientMessage(playerid, COLOR_YELLOW, "--------------------------------------------------------------------------");
            mysql_free_result();
        }

        return 0;
    }
    else if(dialogid == D_PANEL_KAR)
    {
        if(!response) return 1;
        if(GetPVarInt(playerid, "panel-ok") != 1) return 1;
        switch(listitem)
        {
            case 0: //nadaj kare
            {
                ShowPlayerDialogEx(playerid, D_PANEL_KAR_NADAJ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Ban na IP\nBan na nick", "Wybierz", "Wr��");
            }
            case 1: //zdejmij kare
            {
                ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZDEJMIJ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Unbanuj IP\nUnbanuj nick", "Wybierz", "Wr��");
            }
            case 2: //wyszukiwarka
            {
                ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZNAJDZ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Sprawd� dane po IP\nSprawd� dane po nicku", "Wybierz", "Wr��");
            }
        }
    }
    else if(dialogid == D_PANEL_KARY_POWOD)
    {
        if(strlen(inputtext) > 1 && strlen(inputtext) < 64)
        {
            SetPVarString(playerid, "panel-powod", inputtext);
            SetPVarInt(playerid, "panel-kary-continue", 1);

            switch(GetPVarInt(playerid, "panel-list"))
            {
                case 0:
                {
                    ShowPlayerDialogEx(playerid, D_PANEL_KAR_BANIP, DIALOG_STYLE_INPUT, "M-RP � Panel zarz�dzania karami", "Wprowad� poni�ej adres IP.", "Banuj", "Wr��");
                }
                case 1:
                {
                    ShowPlayerDialogEx(playerid, D_PANEL_KAR_BANNICK, DIALOG_STYLE_INPUT, "M-RP � Panel zarz�dzania karami", "Wprowad� poni�ej nick gracza.", "Banuj", "Wr��");
                }
            }
        }
        else return ShowPlayerDialogEx(playerid, D_PANEL_KARY_POWOD, DIALOG_STYLE_LIST, "M-RP � Pow�d", "Prosz� poni�ej wpisa� pow�d.", "Dalej", "");
    }
    else if(dialogid == D_PANEL_KAR_ZDEJMIJ)
    {
        if(!response) return RunCommand(playerid, "/panel",  "");
        if(!Uprawnienia(playerid, ACCESS_KARY_UNBAN))
        {
            SendClientMessage(playerid, COLOR_RED, "Uprawnienia: Nie posiadasz wystarczaj�cych uprawnie�.");
            ShowPlayerDialogEx(playerid, D_PANEL_KAR, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", TEXT_D_PANEL_KARY, "Wybierz", "Wyjd�");
            return 1;
        }
        switch(listitem)
        {
            case 0:
            {
                ShowPlayerDialogEx(playerid, D_PANEL_KAR_UNBANIP, DIALOG_STYLE_INPUT, "M-RP � Panel zarz�dzania karami", "Wprowad� poni�ej adres IP.", "Odbanuj", "Wr��");
            }
            case 1:
            {
                ShowPlayerDialogEx(playerid, D_PANEL_KAR_UNBANNICK, DIALOG_STYLE_INPUT, "M-RP � Panel zarz�dzania karami", "Wprowad� poni�ej nick gracza.", "Odbanuj", "Wr��");
            }
        }
    }
    else if(dialogid == D_PANEL_KAR_NADAJ)
    {
        if(!response) return RunCommand(playerid, "/panel",  "");
        if(!Uprawnienia(playerid, ACCESS_KARY_BAN))
        {
            SendClientMessage(playerid, COLOR_RED, "Uprawnienia: Nie posiadasz wystarczaj�cych uprawnie�.");
            ShowPlayerDialogEx(playerid, D_PANEL_KAR, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", TEXT_D_PANEL_KARY, "Wybierz", "Wyjd�");
            return 1;
        }
        SetPVarInt(playerid, "panel-list", listitem);
        DeletePVar(playerid, "panel-kary-continue");
        DeletePVar(playerid, "panel-powod");
        if(GetPVarInt(playerid, "panel-kary-continue") == 0) return ShowPlayerDialogEx(playerid, D_PANEL_KARY_POWOD, DIALOG_STYLE_INPUT, "M-RP � Pow�d", "Prosz� poni�ej wpisa� pow�d.", "Dalej", "");
    }
    else if(dialogid == D_PANEL_KAR_BANIP)
    {
        if(!response) return ShowPlayerDialogEx(playerid, D_PANEL_KAR_NADAJ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Ban na IP\nBan na nick", "Wybierz", "Wr��");
        if(strlen(inputtext) < 7 || strlen(inputtext) > 16)
        {
            SendClientMessage(playerid, COLOR_RED, "Niepoprawna d�ugosc IP!");
            ShowPlayerDialogEx(playerid, D_PANEL_KAR_NADAJ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Ban na IP\nBan na nick", "Wybierz", "Wr��");
            return 1;
        }
        new count, cpos;
        while((cpos = strfind(inputtext, ".", false, cpos)) != -1)
        {
            count++;
            cpos++;
        }
        if(count != 3)
        {
            SendClientMessage(playerid, COLOR_RED, "Niepoprawny adres IP (dots)!");
            ShowPlayerDialogEx(playerid, D_PANEL_KAR_NADAJ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Ban na IP\nBan na nick", "Wybierz", "Wr��");
            return 1;
        }
        new str[128], powod[128];
        GetPVarString(playerid, "panel-powod", powod, 128);
        MruMySQL_BanujOffline("Brak", powod, playerid, inputtext);

        format(str, 128, "ADM: %s - zablokowano IP: %s pow�d: %s", GetNick(playerid), inputtext, powod);
        SendClientMessage(playerid, COLOR_LIGHTRED, str);
        BanLog(str);

        SetPVarInt(playerid, "panel-kary-continue", 0);
    }
    else if(dialogid == D_PANEL_KAR_BANNICK)
    {
        if(!response) return ShowPlayerDialogEx(playerid, D_PANEL_KAR_NADAJ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Ban na IP\nBan na nick", "Wybierz", "Wr��");
        if(strlen(inputtext) < 1 || strlen(inputtext) > MAX_PLAYER_NAME)
        {
            SendClientMessage(playerid, COLOR_RED, "Niepoprawna d�ugosc!");
            ShowPlayerDialogEx(playerid, D_PANEL_KAR_NADAJ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Ban na IP\nBan na nick", "Wybierz", "Wr��");
            return 1;
        }
        new str[128], powod[128];
        GetPVarString(playerid, "panel-powod", powod, 128);
        MruMySQL_BanujOffline(inputtext, powod, playerid);

        format(str, 128, "ADM: %s - zablokowano nick: %s pow�d: %s", GetNick(playerid), inputtext, powod);
        SendClientMessage(playerid, COLOR_LIGHTRED, str);
        BanLog(str);

        SetPVarInt(playerid, "panel-kary-continue", 0);
    }
    else if(dialogid == D_PANEL_KAR_UNBANIP)
    {
        if(!response) return ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZDEJMIJ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Unbanuj IP\nUnbanuj nick", "Wybierz", "Wr��");
        if(strlen(inputtext) < 7 || strlen(inputtext) > 16)
        {
            SendClientMessage(playerid, COLOR_RED, "Niepoprawna d�ugosc IP!");
            ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZDEJMIJ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Unbanuj IP\nUnbanuj nick", "Wybierz", "Wr��");
            return 1;
        }
        new count, cpos=0;
        while((cpos = strfind(inputtext, ".", false, cpos)) != -1)
        {
            count++;
            cpos++;
        }
        if(count != 3)
        {
            SendClientMessage(playerid, COLOR_RED, "Niepoprawny adres IP (dots)!");
            ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZDEJMIJ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Unbanuj IP\nUnbanuj nick", "Wybierz", "Wr��");
            return 1;
        }
        new str[128];
        if(!MruMySQL_Odbanuj("Brak", inputtext, playerid))
        {
            SendClientMessage(playerid, COLOR_RED, "Nie mo�na by�o wykona� zapytania do bazy!");
            return 1;
        }

        format(str, 128, "ADM: %s - odblokowano IP: %s", GetNick(playerid), inputtext);
        SendClientMessage(playerid, COLOR_LIGHTRED, str);
        BanLog(str);
    }
    else if(dialogid == D_PANEL_KAR_UNBANNICK)
    {
        if(!response) return ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZDEJMIJ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Unbanuj IP\nUnbanuj nick", "Wybierz", "Wr��");
        if(strlen(inputtext) < 1 || strlen(inputtext) > MAX_PLAYER_NAME)
        {
            SendClientMessage(playerid, COLOR_RED, "Niepoprawna d�ugosc!");
            ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZDEJMIJ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Unbanuj IP\nUnbanuj nick", "Wybierz", "Wr��");
            return 1;
        }
        new str[128];
        if(!MruMySQL_Odbanuj(inputtext, "nieznane", playerid))
        {
            SendClientMessage(playerid, COLOR_RED, "Nie mo�na by�o wykona� zapytania do bazy!");
            return 1;
        }

        format(str, 128, "ADM: %s - odblokowano nick: %s", GetNick(playerid), inputtext);
        SendClientMessage(playerid, COLOR_LIGHTRED, str);
        BanLog(str);
    }
    else if(dialogid == D_PANEL_KAR_ZNAJDZ)  //Sprawd� dane po IP | Sprawd� dane po nicku
    {
        if(!response) return ShowPlayerDialogEx(playerid, D_PANEL_KAR, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", TEXT_D_PANEL_KARY, "Wybierz", "Wyjd�");
        if(!Uprawnienia(playerid, ACCESS_KARY_ZNAJDZ))
        {
            SendClientMessage(playerid, COLOR_RED, "Uprawnienia: Nie posiadasz wystarczaj�cych uprawnie�.");
            ShowPlayerDialogEx(playerid, D_PANEL_KAR, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", TEXT_D_PANEL_KARY, "Wybierz", "Wyjd�");
            return 1;
        }
        switch(listitem)
        {
            case 0: ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZNAJDZIP, DIALOG_STYLE_INPUT, "M-RP � Panel zarz�dzania karami", "Wprowad� poni�ej IP do sprawdzenia.", "Sprawd�", "Wr��");
            case 1: ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZNAJDZNICK, DIALOG_STYLE_INPUT, "M-RP � Panel zarz�dzania karami", "Wprowad� poni�ej NICK do sprawdzenia.", "Sprawd�", "Wr��");
        }
    }
    else if(dialogid == D_PANEL_KAR_ZNAJDZIP)
    {
        if(!response) return ShowPlayerDialogEx(playerid, D_PANEL_KAR, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", TEXT_D_PANEL_KARY, "Wybierz", "Wyjd�");
        if(strlen(inputtext) < 7 || strlen(inputtext) > 16)
        {
            SendClientMessage(playerid, COLOR_RED, "Niepoprawna d�ugosc IP!");
            ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZNAJDZ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Sprawd� dane po IP\nSprawd� dane po nicku", "Wybierz", "Wr��");
            return 1;
        }
        new count, cpos=0;
        while((cpos = strfind(inputtext, ".", false, cpos)) != -1)
        {
            count++;
            cpos++;
        }
        if(count != 3)
        {
            SendClientMessage(playerid, COLOR_RED, "Niepoprawny adres IP (dots)!");
            ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZNAJDZ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Sprawd� dane po IP\nSprawd� dane po nicku", "Wybierz", "Wr��");
            return 1;
        }
        //OK
        new query[256],ip[16], str[800];
        mysql_real_escape_string(inputtext, ip);
        format(query, sizeof(query), "SELECT `nadal_uid`, `nadal`, `powod`, `czas`, `dostal`, `dostal_uid`, `typ` FROM `mru_bany` WHERE `IP` = '%s' AND `typ`>1 ORDER BY `czas` DESC LIMIT 4", ip);
    	mysql_query(query);
    	mysql_store_result();
        if(mysql_num_rows())
        {
            while(mysql_fetch_row_format(query, "|"))
            {
                new powod[64], admin[32], id, czas[32], pid, nick[32], typ;
    		    sscanf(query, "p<|>ds[32]s[64]s[32]s[32]dd", id, admin, powod, czas,nick,pid, typ);
                new resultfit[80];
                if(strlen(powod) > 0)
                    format(resultfit, 80, "{079FE1}%s\n", powod);
                format(str, 800, "%s{FFFFFF}Gracz: %s\t\tPID: %d\tIP: %s\nNada�: %s\t\tPID: %d\n%sData: %s\tStatus: %s\n",str, nick,pid,ip,admin,id, resultfit, czas, (typ == WARN_BAN) ? ("{FF0000}BAN") : ("{00FF00}UNBAN"));
            }
            ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZNAJDZ_INFO, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", str, "Wr��", "");
        }
        else
        {
            ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZNAJDZ_INFO, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Brak wynik�w", "Wr��", "");
        }
        mysql_free_result();
    }
    else if(dialogid == D_PANEL_KAR_ZNAJDZNICK)
    {
        if(!response) return ShowPlayerDialogEx(playerid, D_PANEL_KAR, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", TEXT_D_PANEL_KARY, "Wybierz", "Wyjd�");
        if(strlen(inputtext) < 1 || strlen(inputtext) > MAX_PLAYER_NAME)
        {
            SendClientMessage(playerid, COLOR_RED, "Niepoprawna d�ugosc nazwy!");
            ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZNAJDZ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Sprawd� dane po IP\nSprawd� dane po nicku", "Wybierz", "Wr��");
            return 1;
        }
        //OK
        new query[256],nick[MAX_PLAYER_NAME], str[800];
        mysql_real_escape_string(inputtext, nick);
        format(query, sizeof(query), "SELECT `nadal_uid`, `nadal`, `powod`, `czas`, `IP`, `dostal_uid`, `typ` FROM `mru_bany` WHERE `dostal` = '%s' AND `typ`>1 ORDER BY `czas` DESC LIMIT 4", nick);
    	mysql_query(query);
    	mysql_store_result();
        if(mysql_num_rows())
        {
            while(mysql_fetch_row_format(query, "|"))
            {
                new powod[64], admin[32], id, czas[32], ip[16], pid, typ;
    		    sscanf(query, "p<|>ds[32]s[64]s[32]s[16]dd", id, admin, powod, czas,ip, pid, typ);
                new resultfit[80];
                if(strlen(powod) > 0)
                    format(resultfit, 80, "{079FE1}%s\n", powod);
                format(str, 800, "%s{FFFFFF}Gracz: %s\t\tPID: %d\tIP: %s\nNada�: %s\t\tPID: %d\n%sData: %s\tStatus: %s\n",str, nick,pid,ip,admin,id, resultfit, czas, (typ == WARN_BAN) ? ("{FF0000}BAN") : ("{00FF00}UNBAN"));
            }
            ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZNAJDZ_INFO, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", str, "Wr��", "");
        }
        else
        {
            ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZNAJDZ_INFO, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Brak wynik�w", "Wr��", "");
        }
        mysql_free_result();
    }
    else if(dialogid == D_PANEL_KAR_ZNAJDZ_INFO)
    {
        ShowPlayerDialogEx(playerid, D_PANEL_KAR_ZNAJDZ, DIALOG_STYLE_LIST, "M-RP � Panel zarz�dzania karami", "Sprawd� dane po IP\nSprawd� dane po nicku", "Wybierz", "Wr��");
        return 1;
    }
    //KONIEC PANELU ADMINA

	else if(dialogid == 128)
	{
        if(CheckAlfaNumeric(inputtext))
        {
            SendClientMessage(playerid,COLOR_P@,"Twoje has�o posiada�o nie-alfanumeryczne znak, podaj inne.");
            ShowPlayerDialogEx(playerid, D_REGISTER, DIALOG_STYLE_INPUT, "Rejestracja konta", "Witaj. Aby zacz�� gr� na serwerze musisz si� zarejestrowa�.\nAby to zrobi� wpisz w okienko poni�ej has�o kt�re chcesz u�ywa� w swoim koncie.\nZapami�taj je gdy� b�dziesz musia� go u�ywa� za ka�dym razem kiedy wejdziesz na serwer", "Rejestruj", "Wyjd�");
            return 1;
        }
		SendClientMessage(playerid,COLOR_P@,"|_________________________Rada dnia: zmiana has�a_________________________|");
		SendClientMessage(playerid,COLOR_WHITE,"Zmieni�e� has�o to bardzo dobrze. Zwi�kszy to bezpiecze�stwo twojego konta na serwerze.");
		SendClientMessage(playerid,COLOR_WHITE,"Je�eli posiadasz konto na forum z identycznym has�em, rownie� mo�esz rozwa�y� jego zmian�.");
		SendClientMessage(playerid,COLOR_WHITE,"Teraz najwa�niejsza sprawa {FFA500}KONIECZNIE ZAPAMI�TAJ NOWE HAS�O.");
		SendClientMessage(playerid,COLOR_WHITE,"Z naszych do�wiadcze� wynika, �e du�o os�b zapomina nowo nadane na swoj� posta� has�o.");
		SendClientMessage(playerid,COLOR_WHITE,"Uniknij tej sytuacji w W TEJ CHWILII {CD5C5C}zapisz nowe has�o na karteczce lub wykonaj screen komunikatu poni�ej.");
		SendClientMessage(playerid,COLOR_WHITE,"Je�eli zapomnisz nowe has�o do konta na jego odzyskanie b�dziesz czeka� d�ugie tygodnie!");
		SendClientMessage(playerid,COLOR_WHITE,"Mo�liwe, �e ju� teraz zapomnia�e� has�a. Ale nic nie szkodzi. Poni�ej prezentujemy twoje nowe has�o ( < i > nie s� jego cz�ci�! )");
		SendClientMessage(playerid,COLOR_P@,"|________________________>>> Zapisz nowe has�o na kartce! <<<________________________|");
		new string[128];
		format(string, sizeof(string), "Twoje nowe has�o to: >>>>>> %s <<<<< -> zapisz je!", inputtext);

		if(strcmp(PlayerInfo[playerid][pKey],inputtext, true ) != 0)
		{
			SendClientMessage(playerid, COLOR_PANICRED, string);
			SendClientMessage(playerid, COLOR_PANICRED, string);
			SendClientMessage(playerid, COLOR_PANICRED, string);
			//PlayerInfo[playerid][pCzystka] = 555;
			OnPlayerRegister(playerid,inputtext);
		}
		else
		{
			ShowPlayerDialogEx(playerid, 128, DIALOG_STYLE_INPUT, "Konieczna zmiana hasla", "Uwaga! Konieczna jest zmiana has�a!\nHas�o na tym koncie ju� wygas�o. Koniecznie musisz je zmieni�.\nAby to zrobi� wpisz nowe has�o poni�ej.\n{FF0000}HAS�O NIE MO�E BY� TAKIE SAMO JAK POPRZEDNIE", "Zmien", "");
			return 1;
		}
	}
    else if(dialogid == D_ELEVATOR_LSMC)
    {
        if(response)
        {
            if(LSMCElevatorQueue) return SendClientMessage(playerid, -1, "Prosz� poczeka�... Winda jest w u�yciu!");
			switch(listitem)
			{
			    case 0:
				{
				    ElevatorTravel(playerid,-2805.0967,2596.0566,-98.0829, 90,0.0);//pkostnica
					PlayerInfo[playerid][pLocal] = PLOCAL_FRAC_LSMC;
				}
				case 1:
				{
					ElevatorTravel(playerid,1144.4740, -1333.2556, 13.8348, 0,90.0);//parking
					PlayerInfo[playerid][pLocal] = PLOCAL_DEFAULT;
				}
				case 2:
				{
        			ElevatorTravel(playerid,1134.0449,-1320.7128,68.3750,90,270.0);//p1
					PlayerInfo[playerid][pLocal] = PLOCAL_FRAC_LSMC;
				}
				case 3:
				{
					ElevatorTravel(playerid,1183.3129,-1333.5684,88.1627,90,90.0);//p2
					PlayerInfo[playerid][pLocal] = PLOCAL_FRAC_LSMC;
				}
				case 4:
				{
					ElevatorTravel(playerid,1168.2112,-1340.6785,100.3780,90,90.0);//p3
					PlayerInfo[playerid][pLocal] = PLOCAL_FRAC_LSMC;
				}
				case 5:
				{
					ElevatorTravel(playerid,1158.6868,-1339.4423,120.2738,90,90.0);//p
					PlayerInfo[playerid][pLocal] = PLOCAL_FRAC_LSMC;
				}
				case 6:
				{
					ElevatorTravel(playerid,1167.7832,-1332.2727,134.7856,90,90.0);//p5
					PlayerInfo[playerid][pLocal] = PLOCAL_FRAC_LSMC;
				}
    			case 7:
				{
					ElevatorTravel(playerid,1177.4791,-1320.7749,178.0699,90,90.0);//p6
					PlayerInfo[playerid][pLocal] = PLOCAL_FRAC_LSMC;
				}
				case 8:
            	{
					ElevatorTravel(playerid,1178.2081,-1330.6317,191.5315,90,90.0);//p7
					PlayerInfo[playerid][pLocal] = PLOCAL_FRAC_LSMC;
				}
                case 9:
				{
            		ElevatorTravel(playerid,1161.8228, -1337.0521, 31.6112,0,180.0);//dach
					PlayerInfo[playerid][pLocal] = PLOCAL_DEFAULT;
				}
			}
        }
	}
    else if(dialogid == DIALOG_KONSOLA_VINYL)
    {
        if(!response) return 1;
        if(strlen(inputtext) < 10) return 1;

        foreach(new i : Player)
        {
            if(IsPlayerInRangeOfPoint(i, VinylAudioPos[3],VinylAudioPos[0],VinylAudioPos[1],VinylAudioPos[2]) && GetPlayerVirtualWorld(i) == floatround(VinylAudioPos[4]))
            {
                PlayAudioStreamForPlayer(i, inputtext,VinylAudioPos[0],VinylAudioPos[1],VinylAudioPos[2], VinylAudioPos[3], 1);
            }
        }
        format(VINYL_Stream, 128, "%s",inputtext);
    }
	else if(dialogid == 7420)
	{
	    if(response)
	    {
	        if(strval(inputtext) >= 5 && strval(inputtext) <= 100)
	        {
	            new string[128];
	            new giveplayerid = dajeKontrakt[playerid];
	            new hajs = 0;
	            if(!IsPlayerConnected(giveplayerid))
	            {
	                SendClientMessage(playerid, COLOR_PANICRED, "   Gracz na kt�rego podpisywa�e� zlecenie si� wylogowa�!");
	                return 1;
	            }
				if(PlayerInfo[giveplayerid][pLider] > 0) { hajs += strval(inputtext)*150000; }
				else if(IsACop(playerid)) { hajs = strval(inputtext)*100000; }
				else if(PlayerInfo[giveplayerid][pMember] == 9) { hajs = strval(inputtext)*85000; }
				else if(PlayerInfo[giveplayerid][pMember] > 0 || GetPlayerOrg(giveplayerid) != 0) { hajs = strval(inputtext)*75000; }
				else { hajs = strval(inputtext)*50000; }
				haHajs[playerid] = hajs;
				
		        format(string, sizeof(string), "Cena za g�ow� %s wynosi %d$.\nAby podpisa� na niego kontrakt, kliknij \"Podpisz\"", GetNick(giveplayerid), hajs);
		        ShowPlayerDialogEx(playerid, 7421, DIALOG_STYLE_MSGBOX, "Podpisywanie kontraktu", string, "Podpisz", "Wyjd�");
	        }
	        else
	        {
	            ShowPlayerDialogEx(playerid, 7420, DIALOG_STYLE_INPUT, "Podpisywanie kontraktu", "OOC: Musisz poda�, jak d�ugo zabity gracz ma przebywa� w szpitalu w minutach.\nMinimum 5 minut a maksimum 100. (Cena zlecenia zale�y od ilo�ci minut)", "Dalej", "Wyjd�");
                SendClientMessage(playerid, COLOR_GREY, "    Min 5 Max 100 minut!");
			}
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_GREY, "Anulowa�e� podpisywanie kontraktu.");
	        dajeKontrakt[playerid] = 9999;
	        return 1;
	    }
	    return 1;
	}
    else if(dialogid == SCENA_DIALOG_MAIN)
    {
        if(!response) return 1;
        switch(listitem)
        {
            case 0:
            {
                if(!ScenaCreated)
                {
                    new Float:x, Float:y, Float:z, Float:a;
                    GetPlayerPos(playerid, x, y, z);
                    GetPlayerFacingAngle(playerid, a);
                    x += 10.0 * floatsin(-a, degrees);
                    y += 10.0 * floatcos(-a, degrees);
                    Scena_CreateAt(x, y, z+0.2);
                    new str[64];
                    format(str, 64, "Scena stworzona przez %s", GetNick(playerid));
                    SendAdminMessage(COLOR_RED, str);
                    print(str);
                }
                else
                {
                    Scena_Destroy();
                    new str[64];
                    format(str, 64, "Scena zniszczona przez %s", GetNick(playerid));
                    SendAdminMessage(COLOR_RED, str);
                    print(str);
                }
            }
            case 1:
            {
                ShowPlayerDialogEx(playerid, SCENA_DIALOG_EKRAN, DIALOG_STYLE_LIST, "Zarz�dzanie ekranem", "Zmie� napis g��wny\nUstaw efekt\nUstaw dodatkowy parametr", "Wybierz", "Wyjdz");
            }
            case 2:
            {
                ShowPlayerDialogEx(playerid, SCENA_DIALOG_NEONY, DIALOG_STYLE_LIST, "Zarz�dzanie neonami", "Ustaw efekt\nUstaw powtarzalno��\nUstaw cz�stotliwo��", "Wybierz", "Wyjdz");
            }
            case 3:
            {
                ShowPlayerDialogEx(playerid, SCENA_DIALOG_EFEKTY, DIALOG_STYLE_LIST, "Zarz�dzanie dodatkami", "Ustaw efekt\nUstaw powtarzalno��\nUstaw cz�stotliwo��", "Wybierz", "Wyjdz");
            }
            case 4: ShowPlayerDialogEx(playerid, SCENA_DIALOG_AUDIO, DIALOG_STYLE_INPUT, "Zarz�dzanie audio", "Wprowad� link", "Ustaw", "Wyjdz");
            case 5:
            {
                if(ScenaSmokeMachine)
                {
                    DestroyDynamicObject(ScenaSmokeObject[0]);
                    DestroyDynamicObject(ScenaSmokeObject[1]);
                    ScenaSmokeMachine=false;
                }
                else
                {
                    ScenaSmokeObject[0] = CreateDynamicObject(2780, ScenaPosition[0]+5.84926, ScenaPosition[1]+4.44155, ScenaPosition[2]+0.10611,   0.00000, 0.00000, -48.24001);
                    ScenaSmokeObject[1] = CreateDynamicObject(2780, ScenaPosition[0]+5.98447, ScenaPosition[1]-5.16050, ScenaPosition[2]+0.10611,   0.00000, 0.00000, -143.22002);
                    ScenaSmokeMachine=true;
                    Scena_Refresh();
                }
            }
        }
        return 1;
    }
    else if(dialogid == SCENA_DIALOG_CREATE)
    {
        if(!response) return 1;

    }
    else if(dialogid == SCENA_DIALOG_EFEKTY)
    {
        if(!response) return 1;
        new str[1024] = "{000000}0\t{FFFFFF}Usu�\n{000000}18668\t{FFFFFF}Krew\n{000000}18670\t{FFFFFF}B�yski\n{000000}18675\t{FFFFFF}Dymek\n{000000}18678\t{FFFFFF}Eksplozja\n{000000}18683\t{FFFFFF}Eksplozja medium\n{000000}18685\t{FFFFFF}Eksplozja ma�a\n{000000}18692\t{FFFFFF}Ogie�\n{000000}18702\t{FFFFFF}Niebieski p�omie�\n{000000}18708\t{FFFFFF}B�belki\n{000000}18718\t{FFFFFF}Iskry\n{000000}18728\t{FFFFFF}Raca\n{000000}18740\t{FFFFFF}Woda\n";
        strcat(str, "{000000}18680\t{FFFFFF}Dym + iskry\n{000000}18715\t{FFFFFF}Dym du�y\n{000000}18693\t{FFFFFF}Ogie� #2\n{000000}18744\t{FFFFFF}Splash big\n{000000}18747\t{FFFFFF}Wodna piana");
        switch(listitem)
        {
            case 0: ShowPlayerDialogEx(playerid, SCENA_DIALOG_EFEKTY_TYP, DIALOG_STYLE_LIST, "Zarz�dzanie dodatkami", str, "Wybierz", "Wyjdz");
            case 1: ShowPlayerDialogEx(playerid, SCENA_DIALOG_EFEKTY_COUNT, DIALOG_STYLE_INPUT, "Zarz�dzanie dodatkami", "Podaj ilo�� powt�rze�\t\tnp.\n-1 - dla niesko�czonej p�tli\n0 - dla wy��czenia\nn - liczba", "Wybierz", "Wyjdz");
            case 2: ShowPlayerDialogEx(playerid, SCENA_DIALOG_EFEKTY_DELAY, DIALOG_STYLE_INPUT, "Zarz�dzanie dodatkami", "Podaj odst�p czasowy\t\tnp.\n0 - sta�y efekt\nn [ms] - czas", "Wybierz", "Wyjdz");
        }
        return 1;
    }
    else if(dialogid == SCENA_DIALOG_EFEKTY_TYP)
    {
        if(!response) return 1;
        if(strval(inputtext) == 0)
        {
            if(ScenaEffectData[SCEffectTimer] != 0)
            {
                KillTimer(ScenaEffectData[SCEffectTimer]);
                ScenaEffectData[SCEffectTimer] = 0;
            }
            ScenaEffectData[SCEffectDelay] = 0;
        }
        else ScenaEffectData[SCEffectModel] = strval(inputtext);
        ShowPlayerDialogEx(playerid, SCENA_DIALOG_EFEKTY, DIALOG_STYLE_LIST, "Zarz�dzanie dodatkami", "Ustaw efekt\nUstaw powtarzalno��\nUstaw cz�stotliwo��", "Wybierz", "Wyjdz");
        Scena_GenerateEffect();
        return 1;
    }
    else if(dialogid == SCENA_DIALOG_EFEKTY_COUNT)
    {
        if(!response) return 1;
        if(strval(inputtext) < -1 || strval(inputtext) > 0xFFFF) return 1;
        ScenaEffectData[SCEffectCount] = strval(inputtext);

        if(ScenaEffectData[SCEffectTimer] != 0)
        {
            KillTimer(ScenaEffectData[SCEffectTimer]);
            ScenaEffectData[SCEffectTimer] = 0;
        }

        if(ScenaEffectData[SCEffectCount] == -1)
        {
            if(ScenaEffectData[SCEffectDelay] != 0) ScenaEffectData[SCEffectTimer] = SetTimer("Scena_GenerateEffect", ScenaEffectData[SCEffectDelay], 1);
        }
        ShowPlayerDialogEx(playerid, SCENA_DIALOG_EFEKTY, DIALOG_STYLE_LIST, "Zarz�dzanie dodatkami", "Ustaw efekt\nUstaw powtarzalno��\nUstaw cz�stotliwo��", "Wybierz", "Wyjdz");
        Scena_GenerateEffect();
        return 1;
    }
    else if(dialogid == SCENA_DIALOG_EFEKTY_DELAY)
    {
        if(!response) return 1;
        if(strval(inputtext) < 250 || strval(inputtext) > 0xFFFF) return SendClientMessage(playerid, -1, "Od 250");
        ScenaEffectData[SCEffectDelay] = strval(inputtext);

        if(ScenaEffectData[SCEffectTimer] != 0)
        {
            KillTimer(ScenaEffectData[SCEffectTimer]);
            ScenaEffectData[SCEffectTimer] = 0;
        }
        if(ScenaEffectData[SCEffectCount] == -1)
        {
            if(ScenaEffectData[SCEffectDelay] != 0) ScenaEffectData[SCEffectTimer] = SetTimer("Scena_GenerateEffect", ScenaEffectData[SCEffectDelay], 1);
        }

        ShowPlayerDialogEx(playerid, SCENA_DIALOG_EFEKTY, DIALOG_STYLE_LIST, "Zarz�dzanie dodatkami", "Ustaw efekt\nUstaw powtarzalno��\nUstaw cz�stotliwo��", "Wybierz", "Wyjdz");
        Scena_GenerateEffect();
        return 1;
    }
    else if(dialogid == SCENA_DIALOG_EKRAN)
    {
        if(!response) return 1;
        new str[512] = "{000000}0\t{FFFFFF}Usu�\n{000000}1\t{FFFFFF}G�ra-d�";
        switch(listitem)
        {
            case 0: ShowPlayerDialogEx(playerid, SCENA_DIALOG_EKRAN_TYP, DIALOG_STYLE_INPUT, "Zarz�dzanie ekranem", "Wprowad� napis", "Wybierz", "Wyjdz");
            case 1: ShowPlayerDialogEx(playerid, SCENA_DIALOG_EKRAN_EFEKT, DIALOG_STYLE_LIST, "Zarz�dzanie ekranem", str, "Wybierz", "Wyjdz");
            case 2: ShowPlayerDialogEx(playerid, SCENA_DIALOG_EKRAN_EXTRA, DIALOG_STYLE_INPUT, "Zarz�dzanie ekranem", "Dla efektu Wirnik:\t\tPr�dko�� (ca�kowite warto�ci)", "Wybierz", "Wyjdz");
        }
        return 1;
    }
    else if(dialogid == SCENA_DIALOG_EKRAN_TYP)
    {
        if(!response) return 1;
        if(strlen(inputtext) > 32) return 1;
        format(ScenaScreenText, 32, "%s", inputtext);
        new size = 148-(floatround(floatsqroot(strlen(inputtext)*150))*2);
        if(size < 10) size = 10;
        SetDynamicObjectMaterialText(ScenaScreenObject, 0, inputtext, OBJECT_MATERIAL_SIZE_512x256, "Arial", size, 1, 0xFFFFFFFF, 0, 1);
        ShowPlayerDialogEx(playerid, SCENA_DIALOG_EKRAN, DIALOG_STYLE_LIST, "Zarz�dzanie ekranem", "Zmie� napis g��wny\nUstaw efekt\nUstaw dodatkowy parametr", "Wybierz", "Wyjdz");
        return 1;
    }
    else if(dialogid == SCENA_DIALOG_EKRAN_EFEKT)
    {
        if(!response) return 1;
        if(strval(inputtext) == 0)
        {
            ScenaScreenEnable = false;
            new Float:x, Float:y, Float:z;
            GetDynamicObjectPos(ScenaScreenObject, x, y, z);
            if(ScenaScreenMove == 0) MoveDynamicObject(ScenaScreenObject, x, y, ScenaPosition[2]+4.18430, ScenaScreenData, 0.0, 0.0, 100.0), ScenaScreenMove= 1;
            else if(ScenaScreenMove == 1) MoveDynamicObject(ScenaScreenObject, x, y, ScenaPosition[2]+4.18430, ScenaScreenData, 0.0, 0.0, 100.0), ScenaScreenMove=0;

            SetDynamicObjectMaterialText(ScenaScreenObject, 0, ScenaScreenText, OBJECT_MATERIAL_SIZE_512x256, "Arial", 72, 1, 0xFFFFFFFF, 0, 1);
        }
        else
        {
            ScenaScreenTyp = strval(inputtext);
            ScenaScreenEnable = true;
        }

        Scena_ScreenEffect();
        ShowPlayerDialogEx(playerid, SCENA_DIALOG_EKRAN, DIALOG_STYLE_LIST, "Zarz�dzanie ekranem", "Zmie� napis g��wny\nUstaw efekt\nUstaw dodatkowy parametr", "Wybierz", "Wyjdz");
        return 1;
    }
    else if(dialogid == SCENA_DIALOG_EKRAN_EXTRA)
    {
        if(!response) return 1;
        if(strval(inputtext) < 0 || strval(inputtext) > 100) return 1;
        ScenaScreenData = float(strval(inputtext));

        Scena_ScreenEffect();

        ShowPlayerDialogEx(playerid, SCENA_DIALOG_EKRAN, DIALOG_STYLE_LIST, "Zarz�dzanie ekranem", "Zmie� napis g��wny\nUstaw efekt\nUstaw dodatkowy parametr", "Wybierz", "Wyjdz");
        return 1;
    }
    else if(dialogid == SCENA_DIALOG_NEONY)
    {
        if(!response) return 1;
        new str[512] = "{000000}0\t{FFFFFF}Usu�\n{000000}1\t{FFFFFF}Slider\n{000000}2\t{FFFFFF}Zderzacz";
        switch(listitem)
        {
            case 0: ShowPlayerDialogEx(playerid, SCENA_DIALOG_NEON_EFEKT, DIALOG_STYLE_LIST, "Zarz�dzanie neonami", str, "Wybierz", "Wyjdz");
            case 1: ShowPlayerDialogEx(playerid, SCENA_DIALOG_NEON_COUNT, DIALOG_STYLE_INPUT, "Zarz�dzanie neonami", "Aktualnie brak", "Wybierz", "Wyjdz");
            case 2: ShowPlayerDialogEx(playerid, SCENA_DIALOG_NEON_DELAY, DIALOG_STYLE_INPUT, "Zarz�dzanie neonami", "Dla efektu:\t\tPr�dko�� (ca�kowite warto�ci)", "Wybierz", "Wyjdz");
        }
        return 1;
    }
    else if(dialogid == SCENA_DIALOG_NEON_EFEKT)
    {
        if(!response) return 1;
        ScenaNeonData[SCNeonTyp] = 0;
        Scena_NeonEffect();

        ScenaNeonData[SCNeonTyp] = strval(inputtext);
        if(ScenaNeonData[SCNeonTyp] != 0)
        {
            new str[256] = "{000000}18652\t\t{FFFFFF}Bia�y neon\n{000000}18647\t\t{FFFFFF}Czerwony neon\n{000000}18648\t\t{FFFFFF}Niebieski neon\n{000000}18649\t\t{FFFFFF}Zielony neon\n{000000}18650\t\t{FFFFFF}��ty neon\n{000000}18651\t\t{FFFFFF}R�owy neon <3 :*";
            ShowPlayerDialogEx(playerid, SCENA_DIALOG_NEON_KOLORY, DIALOG_STYLE_LIST, "Zarz�dzanie neonami", str, "Wybierz", "Wyjdz");
        }
        return 1;
    }
    else if(dialogid == SCENA_DIALOG_NEON_COUNT)
    {
        if(!response) return 1;
        if(strval(inputtext) < -1 || strval(inputtext) > 100) return 1;
        ScenaNeonData[SCNeonCount] = strval(inputtext);

        Scena_NeonEffect();

        ShowPlayerDialogEx(playerid, SCENA_DIALOG_NEONY, DIALOG_STYLE_LIST, "Zarz�dzanie neonami", "Ustaw efekt\nUstaw powtarzalno��\nUstaw cz�stotliwo��", "Wybierz", "Wyjdz");
        return 1;
    }
    else if(dialogid == SCENA_DIALOG_NEON_DELAY)
    {
        if(!response) return 1;
        if(strval(inputtext) < 0 || strval(inputtext) > 200) return SendClientMessage(playerid, -1, "Do 200");
        ScenaNeonData[SCNeonDelay] = strval(inputtext);

        Scena_NeonEffect();

        ShowPlayerDialogEx(playerid, SCENA_DIALOG_NEONY, DIALOG_STYLE_LIST, "Zarz�dzanie neonami", "Ustaw efekt\nUstaw powtarzalno��\nUstaw cz�stotliwo��", "Wybierz", "Wyjdz");
        return 1;
    }
    else if(dialogid == SCENA_DIALOG_NEON_KOLORY)
    {
        if(!response) return 1;
        ScenaNeonData[SCNeonModel] = strval(inputtext);
        ScenaNeonData[SCNeonSliderRefresh]=true;

        Scena_NeonEffect();

        ShowPlayerDialogEx(playerid, SCENA_DIALOG_NEONY, DIALOG_STYLE_LIST, "Zarz�dzanie neonami", "Ustaw efekt\nUstaw powtarzalno��\nUstaw cz�stotliwo��", "Wybierz", "Wyjdz");
        return 1;
    }
    else if(dialogid == SCENA_DIALOG_AUDIO)
    {
        if(!response) return 1;
        format(ScenaAudioStream, 128, "%s", inputtext);
        for(new i=0;i<MAX_PLAYERS;i++)
        {
            if(GetPVarInt(i, "scena-audio") == 1)
            {
                StopAudioStreamForPlayer(i);
                SetPVarInt(i, "scena-audio", 0);
            }
        }
        return 1;
    }
	else if(dialogid == 7421)
	{
	    if(response)
		{
		    new string[128];
		    new giveplayerid = dajeKontrakt[playerid];
		    new hajs = haHajs[playerid];
            if(!IsPlayerConnected(giveplayerid))
            {
                SendClientMessage(playerid, COLOR_PANICRED, "   Gracz na kt�rego podpisywa�e� zlecenie si� wylogowa�!");
                return 1;
            }
			
			if(kaska[playerid] > 0 && kaska[playerid] >= hajs)
			{
				ZabierzKase(playerid, hajs);
				PlayerInfo[giveplayerid][pHeadValue]+=hajs;
				format(string, sizeof(string), "%s podpisa� kontrakt na %s, nagroda za wykonanie $%d.",GetNick(playerid), GetNick(giveplayerid), hajs);
				SendFamilyMessage(8, COLOR_YELLOW, string);
				format(string, sizeof(string), "* Podpisa�e� kontrakt na %s, za $%d.",GetNick(giveplayerid), hajs);
				SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				format(string, sizeof(string), "* %s wk�ada kopert� z pieni�dzmi do skrzynki, po czym zamyka j�.", GetNick(playerid));
				ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
				dajeKontrakt[playerid] = 9999;
				haHajs[playerid] = 0;
				ClearAnimations(playerid);
	        	if(IsPlayerInRangeOfPoint(playerid, 5.0, 1013.0000000,-452.6000061,50.5999985))
	        	{
	        	    SetTimerEx("HABox",30000,0,"dd",0, playerid);
	        	    DestroyDynamicObject(habox[0]);
					habox[0] = CreateDynamicObject(3407,1013.0000000,-452.6000061,50.5999985,0.0000000,0.0000000,2.0000000);
	        	}
				else if(IsPlayerInRangeOfPoint(playerid, 5.0, 2130.6000977,-1875.4000244,12.5000000))
				{
				    SetTimerEx("HABox",30000,0,"dd",1, playerid);
				    DestroyDynamicObject(habox[1]);
					habox[1] = CreateDynamicObject(3407,2130.6000977,-1875.4000244,12.5000000,0.0000000,0.0000000,213.9999390); //object(ce_mailbox2) (2)
				}
				else if(IsPlayerInRangeOfPoint(playerid, 5.0, 18.2000008,-214.6000061, 0.5))
				{
				    SetTimerEx("HABox",30000,0,"dd",2, playerid);
					DestroyDynamicObject(habox[2]);
					habox[2] = CreateDynamicObject(3407,18.2000008,-214.6000061,0.5000000,0.0000000,0.0000000,190.0000000); //object(ce_mailbox2) (3)
				}
				else if(IsPlayerInRangeOfPoint(playerid, 5.0, 1230.5999756,-1652.9000244,10.8000002))
				{
				    SetTimerEx("HABox",30000,0,"dd",3, playerid);
					DestroyDynamicObject(habox[3]);
					habox[3] = CreateDynamicObject(3407,1230.5999756,-1652.9000244,10.8000002,0.0000000,0.0000000,70.0000000); //object(ce_mailbox2) (4)
				}
				else if(IsPlayerInRangeOfPoint(playerid, 5.0, 2355.1999512,-651.7999878,127.0999985))
		        {
		            SetTimerEx("HABox",30000,0,"dd",4, playerid);
					DestroyDynamicObject(habox[4]);
					habox[4] = CreateDynamicObject(3407,2355.1999512,-651.7999878,127.0999985,0.0000000,0.0000000,44.0000000); //object(ce_mailbox2) (5)
		        }
		        //OnPlayerUpdate(playerid);
		        return 1;
			}
			else
			{
			    SendClientMessage(playerid, COLOR_PANICRED, "   Nie masz tylu pieni�dzy!");
			    return 1;
			}
		}
		else
		{
		    SendClientMessage(playerid, COLOR_GREY, "Anulowa�e� podpisywanie kontraktu.");
	        dajeKontrakt[playerid] = 9999;
	        haHajs[playerid] = 0;
	        return 1;
		}
	}
    else if(dialogid == D_PRZEBIERZ_FDU)
    {
        if(!response) return 1;
        new lSkin;
        switch(listitem)
        {
            case 0: lSkin = 40;
            case 1: lSkin = 50;
            case 2: lSkin = 93;
            case 3: lSkin = 86;
            case 4: lSkin = 115;
            case 5: lSkin = 122;
            case 6: lSkin = 270;
        }
        if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SendClientMessage(playerid, 0xFF8D00FF, "Musisz by� pieszo, �eby zmieni� skin.");
        SetPlayerSkin(playerid, lSkin);
        SendClientMessage(playerid, 0xC0FF9CFF, "� Zmieni�e� swoje przebranie.");
    }
	else if(dialogid == 1213)
 	{
		if(response == 1)
 		{
  			switch(listitem)
    		{
	                case 0:
	                {
	                	ApplyAnimation(playerid,"PED","WALK_DRUNK",4.0, 1, 1, 1, 1, 0);
					}
	                case 1:
	                {
	                	ApplyAnimation(playerid,"PED","WALK_civi",4.0, 1, 1, 1, 1, 1, 0);
					}
	                case 2:
	                {
	                	ApplyAnimation(playerid,"PED","WALK_fatold",4.0, 1, 1, 1, 1, 1, 0);
	             	}
	                case 3:
	                {
	                    ApplyAnimation(playerid,"PED","WALK_gang1",4.0, 1, 1, 1, 1, 1, 0);
	                }
	                case 4:
	                {
	                    ApplyAnimation(playerid,"PED","WALK_gang2",4.0, 1, 1, 1, 1, 1, 0);
	                }
					case 5:
					{
					    ApplyAnimation(playerid,"PED","WALK_old",4.0, 1, 1, 1, 1, 1, 0);
					}
					case 6:
					{
                        ApplyAnimation(playerid,"PED","WALK_rocket",4.0, 1, 1, 1, 1, 1, 0);
					}
					case 7:
					{
                        ApplyAnimation(playerid,"PED","WALK_player",4.0, 1, 1, 1, 1, 1, 0);
					}
					case 8:
					{
                        ApplyAnimation(playerid,"PED","WOMAN_walkfatold",4.0, 1, 1, 1, 1, 1, 0);
					}
					case 9:
					{
                        ApplyAnimation(playerid,"PED","WOMAN_walksexy",4.0, 1, 1, 1, 1, 1, 0);
					}
					case 10:
					{
                        ApplyAnimation(playerid,"FAT","FatWalk",4.0, 1, 1, 1, 1, 1, 0);
					}
					case 11:
					{
                        ApplyAnimation(playerid,"PED","WOMAN_Walkbusy",4.0, 1, 1, 1, 1, 1, 0);
					}
					case 12:
					{
                        ApplyAnimation(playerid,"PED","WOMAN_walkshop",4.0, 1, 1, 1, 1, 1, 0);
					}
					case 13:
					{
                        ApplyAnimation(playerid,"MUSCULAR","MuscleWalk",4.0, 1, 1, 1, 1, 1, 0);
  				}
			}
		}
	}
	else if(dialogid == iddialog[playerid])
	{
		if(dialogid == 1)
	    {
	        if(response)
	        {
	            GUIExit[playerid] = 0;
	      		SendClientMessage(playerid, 0xFFFFFFFF, "Pozycja przywr�cona");
	      		lowcap[playerid] = 0;

                SetPVarInt(playerid, "spawn", 2);
                if(PlayerInfo[playerid][pPos_x] == 2246.6 || PlayerInfo[playerid][pPos_y] == -1161.9 || PlayerInfo[playerid][pPos_z] == 1029.7 || PlayerInfo[playerid][pPos_x] == 0 || PlayerInfo[playerid][pPos_y] == 0)
	      		{
	                SendClientMessage(playerid, 0xFFFFFFFF, "Twoja pozycja zosta�a b��dnie zapisana, dlatego zespawnujesz si� na zwyk�ym spawnie.");
                    SetPVarInt(playerid, "spawn", 1);
                }
				TogglePlayerSpectating(playerid, false);
		        return 1;
			}
			if(!response)
			{
                SetPVarInt(playerid, "spawn", 1);
			    GUIExit[playerid] = 0;
				TogglePlayerSpectating(playerid, false);
			    lowcap[playerid] = 0;
				PlayerInfo[playerid][pLocal] = 255;
			}
	    }
	    //OnDialogResposne OKNA DMV
		if(dialogid == 99)
		{
			if(response)
			{
				new string[256];
				new okienkoid = GetPVarInt(playerid, "okienko-edit");
				new mojeimie[MAX_PLAYER_NAME];
				GetPlayerName(playerid, mojeimie, sizeof(mojeimie));
				
			    switch(listitem)
			    {
			        case 0:
			        {
						if(PlayerInfo[playerid][pRank] == 0)
						{
							
							
							format(string, sizeof(string), "Urz�d Miasta Los Santos\n\n{0080FF}___Okienko %d___\n[%s: %s]\n{FF0000}[ID: %d]\n {00FFCC}Dowody Osobiste\n Karty W�dkarskie\n Egzaminy Praktyczne", okienkoid+1,FracRang[11][PlayerInfo[playerid][pRank]],mojeimie,playerid);
							UpdateDynamic3DTextLabelText(okienko[okienkoid], 0xFFFFFFFF, string);
						}
						else if(PlayerInfo[playerid][pRank] == 1)
						{
	
							format(string, sizeof(string), "Urz�d Miasta Los Santos\n\n{0080FF}___Okienko %d___\n[%s: %s]\n{FF0000}[ID: %d]\n {00FFCC}Dowody Osobiste\n Karty W�dkarskie\n Egzaminy Praktyczne i Teoretyczne\n Pozwolenia na bro�", okienkoid+1,FracRang[11][PlayerInfo[playerid][pRank]],mojeimie,playerid);
							UpdateDynamic3DTextLabelText(okienko[okienkoid], 0xFFFFFFFF, string);
						}
						else if(PlayerInfo[playerid][pRank] == 2)
						{
							format(string, sizeof(string), "Urz�d Miasta Los Santos\n\n{0080FF}___Okienko %d___\n[%s: %s]\n{FF0000}[ID: %d]\n {00FFCC}Dowody Osobiste\n Karty W�dkarskie\n Egzaminy Praktyczne i Teoretyczne\n Pozwolenia na bro�\n Patenty �eglarskie", okienkoid+1,FracRang[11][PlayerInfo[playerid][pRank]],mojeimie,playerid);
							UpdateDynamic3DTextLabelText(okienko[okienkoid], 0xFFFFFFFF, string);
						}
						else if(PlayerInfo[playerid][pRank] >= 3 || PlayerInfo[playerid][pLider] == 11)
						{
							format(string, sizeof(string), "Urz�d Miasta Los Santos\n\n{0080FF}___Okienko %d___\n[%s: %s]\n{FF0000}[ID: %d]\n {00FFCC}Uniwersalne", okienkoid+1,FracRang[11][PlayerInfo[playerid][pRank]],mojeimie,playerid);
							UpdateDynamic3DTextLabelText(okienko[okienkoid], 0xFFFFFFFF, string);	
						}
			        }
			        case 1:
			        {
						format(string, sizeof(string), "Urz�d Miasta Los Santos\n\n{0080FF}___Okienko %d___\n[%s: %s]\n{FF0000}[ID: %d]\n {00FFCC} Egzaminy Praktyczne\n{008080}Zapis i egzamin odbywa si�\n u tej samej osoby", okienkoid+1,FracRang[11][PlayerInfo[playerid][pRank]],mojeimie,playerid);
						UpdateDynamic3DTextLabelText(okienko[okienkoid], 0xFFFFFFFF, string);
			        }
			        case 2:
			        {
						format(string, sizeof(string), "Urz�d Miasta Los Santos\n\n{0080FF}___Okienko %d___\n[%s: %s]\n{FF0000}[ID: %d]\n {00FFCC} Egzaminy Teoretyczne\n{008080}Ka�de kolejne podej�cie\n wymaga zachowania 1h odst�pu", okienkoid+1,FracRang[11][PlayerInfo[playerid][pRank]],mojeimie,playerid);
						UpdateDynamic3DTextLabelText(okienko[okienkoid], 0xFFFFFFFF, string);
			        }
			        case 3:
			        {
						format(string, sizeof(string), "Urz�d Miasta Los Santos\n\n{0080FF}___Okienko %d___\n[%s: %s]\n{FF0000}[ID: %d]\n {00FFCC} Kurs na prawo jazdy\n{008080}Zapisy", okienkoid+1,FracRang[11][PlayerInfo[playerid][pRank]],mojeimie,playerid);
						UpdateDynamic3DTextLabelText(okienko[okienkoid], 0xFFFFFFFF, string);
			        }
			        case 4:
			        {
						format(string, sizeof(string), "Urz�d Miasta Los Santos\n\n{0080FF}___Okienko %d___\n[%s: %s]\n{FF0000}[ID: %d]\n {00FFCC} Rejestracja", okienkoid+1,FracRang[11][PlayerInfo[playerid][pRank]],mojeimie,playerid);
			        	UpdateDynamic3DTextLabelText(okienko[okienkoid], 0xFFFFFFFF, string);
			        }
			        case 5:
			        {
						format(string, sizeof(string), "Urz�d Miasta Los Santos\n\n{0080FF}___Okienko %d___\n[%s: %s]\n{FF0000}[ID: %d]\n {FA9C1A} Zaraz Wracam", okienkoid+1,FracRang[11][PlayerInfo[playerid][pRank]],mojeimie,playerid);
			        	UpdateDynamic3DTextLabelText(okienko[okienkoid], 0xFFFFFFFF, string);
			        }
			        case 6:
			        {
						format(string, sizeof(string), "Urz�d Miasta Los Santos\n{0080FF}Okienko %d \n {FF0000}Nieczynne", okienkoid+1);
						UpdateDynamic3DTextLabelText(okienko[okienkoid], 0xFFFFFFFF, string);
			        }
			    }
			}
		}
	    else if(dialogid == 112)
	    {
            if(!response) return 1;
            switch(listitem)
            {
                case 0:
                {
    	            SendClientMessage(playerid, COLOR_ALLDEPT, "Centrala: ��cze z policj�, prosze czeka�...");
    				SendClientMessage(playerid, COLOR_DBLUE, "Police HQ: Witam, prosze poda� kr�tki opis przest�pstwa.");
    				Mobile[playerid] = POLICE_NUMBER;
					Callin[playerid] = CALL_EMERGENCY;
                }
                case 1:
                {
                	SendClientMessage(playerid, COLOR_ALLDEPT, "Centrala: ��cze ze stra�� po�arn�, prosze czeka�...");
    				SendClientMessage(playerid, COLOR_DBLUE, "LSFD HQ: Witam, prosze poda� kr�tki opis zdarzenia.");	
    				Mobile[playerid] = SHERIFF_NUMBER;
					Callin[playerid] = CALL_EMERGENCY;
                }
                case 2:
                {
    			    SendClientMessage(playerid, COLOR_ALLDEPT, "Centrala: ��cze ze szpitalem, prosze czeka�...");
    				SendClientMessage(playerid, TEAM_CYAN_COLOR, "Szpital: Witam, prosze poda� kr�tki opis zdarzenia.");
    				Mobile[playerid] = LSMC_NUMBER;
					Callin[playerid] = CALL_EMERGENCY;
                }
                case 3:
                {
    			    SendClientMessage(playerid, COLOR_ALLDEPT, "Centrala: ��cze z dyspozytorem, prosze czeka�...");
    				SendClientMessage(playerid, TEAM_CYAN_COLOR, "SheriffDep: Witam, prosze poda� kr�tki opis przest�pstwa.");
    				Mobile[playerid] = LSFD_NUMBER;
					Callin[playerid] = CALL_EMERGENCY;
                }
			}
	    }
        else if(dialogid== WINDA_SAN)
    	{
    	    if(response)
    	    {
    	        switch(listitem)
    	        {
    	            case 0://parking
    	            {
    	                SetPlayerVirtualWorld(playerid,0);
    	                SetPlayerPosEx(playerid,732.6443, -1343.4160, 13.5982);
    	                new Hour, Minute, Second;
    					gettime(Hour, Minute, Second);
    					SetPlayerTime(playerid,Hour,Minute);
    	            }
    	            case 1://recepcja
    	            {
    	                SetPlayerVirtualWorld(playerid,20);
    				    TogglePlayerControllable(playerid,0);
                        Wchodzenie(playerid);
    				    SetPlayerPosEx(playerid,666.5681, -1353.2101, 29.3031);
    				    new Hour, Minute, Second;
    					gettime(Hour, Minute, Second);
    					SetPlayerTime(playerid,Hour,Minute);
    	            }
    	            case 2://studio Victim
    	            {
    	                SetPlayerVirtualWorld(playerid,21);
    				    TogglePlayerControllable(playerid,0);
                        Wchodzenie(playerid);
    				    SetPlayerPosEx(playerid,661.8192, -1344.7736, 29.4743);
    				    SetPlayerTime(playerid,1,0);
    	            }
    	            case 3://drukarnia & studio nagran
    	            {
    	                SetPlayerVirtualWorld(playerid,22);
    				    TogglePlayerControllable(playerid,0);
                        Wchodzenie(playerid);
    				    SetPlayerPosEx(playerid,655.7669, -1376.8688, 28.6743);
    				    new Hour, Minute, Second;
    					gettime(Hour, Minute, Second);
    					SetPlayerTime(playerid,Hour,Minute);
    	            }
    	            case 4://sale konferencyjne
    	            {
    	                SetPlayerVirtualWorld(playerid,23);
    				    TogglePlayerControllable(playerid,0);
                        Wchodzenie(playerid);
    				    SetPlayerPosEx(playerid,737.4208, -1366.9336, 34.0796);
    				    new Hour, Minute, Second;
    					gettime(Hour, Minute, Second);
    					SetPlayerTime(playerid,Hour,Minute);
    	            }
    	            case 5:
    	            {
    	                SetPlayerVirtualWorld(playerid,24);
    				    TogglePlayerControllable(playerid,0);
                        Wchodzenie(playerid);
    				    SetPlayerPosEx(playerid,663.6946, -1374.4166, 27.9148);
    				    new Hour, Minute, Second;
    					gettime(Hour, Minute, Second);
    					SetPlayerTime(playerid,Hour,Minute);
    	            }
    	            case 6://dach
    	            {
    	                SetPlayerVirtualWorld(playerid,0);
    	                SetPlayerPosEx(playerid,721.5345, -1381.9717, 25.7202);
    	                new Hour, Minute, Second;
    					gettime(Hour, Minute, Second);
    					SetPlayerTime(playerid,Hour,Minute);
    	            }
    	        }
    	    }
    	}
	    else if(dialogid == WINDA_LSPD)
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0:
		            {
		            	if(IsACop(playerid) || IsABOR(playerid))
           				{
			                SetPlayerPosEx(playerid,1568.7660,-1691.4886,5.8906);
			                SetPlayerVirtualWorld(playerid,0);
			                SetPlayerInterior(playerid,0);
			                TogglePlayerControllable(playerid,0);
							Wchodzenie(playerid);
			                GameTextForPlayer(playerid, "~w~ [Poziom -1]~n~~b~Parking Dolny", 5000, 1);
							PlayerInfo[playerid][pInt] = 0;
                        }
						else
						{
							SendClientMessage(playerid, COLOR_GRAD2, "Poziom zastrze�ony dla s�u�b porz�dkowych.");
							return 1;
						}
		            }
		            case 1: {
		            	// parking gorny
		            	if(IsACop(playerid) || IsABOR(playerid))
           				{
			                SetPlayerPosEx(playerid,1570.9799,-1636.7758,13.5713); // pos gornego
			                SetPlayerVirtualWorld(playerid,0);
			                SetPlayerInterior(playerid,0);
			                TogglePlayerControllable(playerid,0);
							Wchodzenie(playerid);
			                GameTextForPlayer(playerid, "~w~ [Poziom 0]~n~~b~Parking Gorny", 5000, 1);
							PlayerInfo[playerid][pInt] = 0;
                        }
						else
						{
							SendClientMessage(playerid, COLOR_GRAD2, "Poziom zastrze�ony dla s�u�b porz�dkowych.");
							return 1;
						}
		            }
		            case 2:
		            {
		                SetPlayerPosEx(playerid,-1645.1858, 883.1620, -45.4112);
		                SetPlayerVirtualWorld(playerid,1);
		                TogglePlayerControllable(playerid,0);
						Wchodzenie(playerid);
		                GameTextForPlayer(playerid, "~w~ [Poziom 1]~n~~b~Komisariat", 5000, 1);
						PlayerInfo[playerid][pInt] = 10;
		            }
		            case 3:
		            {
		                SetPlayerPosEx(playerid,-1621.7272, 834.5807, -26.1115);
		                SetPlayerVirtualWorld(playerid,1);
		                TogglePlayerControllable(playerid,0);
						Wchodzenie(playerid);
                 		GameTextForPlayer(playerid, "~w~ [Poziom 2]~n~~b~Pokoje przesluchan", 5000, 1);
						PlayerInfo[playerid][pInt] = 10;
		            }
		            case 4:
		            {
		                SetPlayerPosEx(playerid,-1745.1101, 824.0737, -48.0110);
		                SetPlayerVirtualWorld(playerid,1);
		                TogglePlayerControllable(playerid,0);
						Wchodzenie(playerid);
	                	GameTextForPlayer(playerid, "~w~ [Poziom 3]~n~~b~Biura", 5000, 1);
						PlayerInfo[playerid][pInt] = 10;
		            }
		            case 5:
		            {
		                SetPlayerPosEx(playerid,1568.1061, 2205.3196, -50.9522);
		                SetPlayerVirtualWorld(playerid,3);
		                TogglePlayerControllable(playerid,0);
						Wchodzenie(playerid);
	                	GameTextForPlayer(playerid, "~w~ [Poziom 4]~n~~b~Sale treningowe", 5000, 1);
						PlayerInfo[playerid][pInt] = 10;
		            }
		            case 6:
		            {
						if(IsACop(playerid) || IsABOR(playerid))
						{
							SetPlayerPosEx(playerid,1565.0798, -1665.6580, 28.4782);
							SetPlayerVirtualWorld(playerid,0);
							SetPlayerInterior(playerid,0);
							GameTextForPlayer(playerid, "~w~ [Poziom 5]~n~~b~Dach", 5000, 1);
							PlayerInfo[playerid][pInt] = 0;
						}
						else
						{
							SendClientMessage(playerid, COLOR_GRAD2, "Poziom zastrze�ony dla s�u�b porz�dkowych.");
							return 1;
						}
		            }
				}
		    }
		}
   	 	else if(dialogid == 121)
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
	                {
                 		SetPlayerPosEx(playerid, 707.06085205078,-508.38107299805,27.871946334839);//salka konferencyjna
				        GameTextForPlayer(playerid, "~w~Witamy w salce konferencyjnej", 5000, 1);
				        SetPlayerVirtualWorld(playerid, 35);
				        TogglePlayerControllable(playerid, 0);
						Wchodzenie(playerid);
	                }
	                case 1:
	                {
	                    SetPlayerPosEx(playerid, 700.6748046875,-502.41955566406,23.515483856201);//biura
				        GameTextForPlayer(playerid, "~w~Projekt by Kacper Monari", 5000, 1);
				        SetPlayerVirtualWorld(playerid, 35);
				        TogglePlayerControllable(playerid, 0);
						Wchodzenie(playerid);
					}
	                case 2:
	                {
					/*
						SetPlayerPosEx(playerid, 694.27490234375,-569.04272460938,-79.225189208984);//piwnica
				        GameTextForPlayer(playerid, "~w~Mroczne piwnice i stare biura", 5000, 1);
				        SetPlayerVirtualWorld(playerid, 35);
				        TogglePlayerControllable(playerid, 0);
						Wchodzenie(playerid);*/
						sendTipMessageEx(playerid, 0x800040FF, "Wygl�da na to, �e pi�tro jest czym� przyblokowane"); 
	                }
	            }
	        }
	    }
	    if(dialogid == 122)
		{
			if(response == 1)
			{
			    switch(listitem)
			    {
			        case 0:
			        {
           				if(IsAUrzednik(playerid) || IsABOR(playerid))//zaplecze
           				{
					        SetPlayerPosEx(playerid,1412.3348388672, -1790.5777587891, 15.370599746704);
					        SetPlayerVirtualWorld(playerid,0);
					        SetPlayerInterior(playerid,0);
					        PlayerInfo[playerid][pLocal] = 255;
					        SendClientMessage(playerid, COLOR_LIGHTGREEN, " *DING* Poziom 0, Zaplecze");
						}
						else
						{
							SendClientMessage(playerid, COLOR_GRAD2, "Poziom zastrze�ony dla pracownik�w UM");
							return 1;
						}
			        }
			        case 1:
			        {
				        SetPlayerPosEx(playerid,1450.6615,-1819.2279,77.9613);//g��wna sala urz�du
				        SetPlayerVirtualWorld(playerid,50);
				        SetPlayerInterior(playerid,0);
	                    TogglePlayerControllable(playerid,0);
                        Wchodzenie(playerid);
	                    SendClientMessage(playerid, COLOR_LIGHTGREEN, ">>>> Trwa jazda na Poziom 9 - G��wna sala urz�du <<<<");
	                    SendClientMessage(playerid, COLOR_WHITE, "  --> Okienka dla interesant�w");
	                    SendClientMessage(playerid, COLOR_WHITE, "  --> Wyj�cie na plac manewrowy");
	                    SendClientMessage(playerid, COLOR_WHITE, "  --> Toalety na ka�dym skrzydle");
                     	SendClientMessage(playerid, COLOR_WHITE, "  --> Biura & Sale konferencyjne & Senat & Burmistrz & Akademia");
                     	SendClientMessage(playerid, COLOR_WHITE, "  --> Biuro ochrony - biuro kamer");
                     	SendClientMessage(playerid, COLOR_LIGHTGREEN, ">>>> Prosz� czeka�, za chwil� otworz� si� drzwi(10sek) <<<<");
                     	PlayerInfo[playerid][pLocal] = 108;
			        }
				}
			}
		}
		if(dialogid == 696)
		{
			if(response)
			{
				switch(listitem)
				{
					case 0:
					{
						if(!IsABOR(playerid)) return SendClientMessage(playerid, 0xB52E2BFF, "Te wej�cie jest tylko dla pracownik�w.");
						SetPlayerPosEx(playerid, 1498.9341,-1537.0797,67.3069);
						SetPlayerVirtualWorld (playerid, 2);
						SendClientMessage(playerid, COLOR_LIGHTGREEN, "Poziom -1, Parking wewn�trzny");
						PlayerPlaySound(playerid, 6401, 0.0, 0.0, 0.0);
					}
					case 1:
					{
						if(!IsABOR(playerid)) return SendClientMessage(playerid, 0xB52E2BFF, "Te wej�cie jest tylko dla pracownik�w.");
						SetPlayerPosEx(playerid,1772.1613,-1547.9675,9.9067);
						SetPlayerVirtualWorld (playerid, 0) ;
						TogglePlayerControllable(playerid,0);
						Wchodzenie(playerid);
						SendClientMessage(playerid, COLOR_LIGHTGREEN, "Poziom 0, Parking zewn�trzny");
						PlayerPlaySound(playerid, 6401, 0.0, 0.0, 0.0);
					}
					case 2:
					{

						SetPlayerPosEx(playerid,1496.9330, -1457.8887, 64.5854);
						GameTextForPlayer(playerid, "~w~Centrala BOR \n ~r~by abram01", 5000, 1);
						SetPlayerVirtualWorld (playerid, 80) ;
						TogglePlayerControllable(playerid,0);
						Wchodzenie(playerid);
						SendClientMessage(playerid, COLOR_LIGHTGREEN, "Poziom 1, Centrala BOR");
						PlayerPlaySound(playerid, 6401, 0.0, 0.0, 0.0);
					}
					case 3:
					{
						if(!IsABOR(playerid)) return SendClientMessage(playerid, 0xB52E2BFF, "Te wej�cie jest tylko dla pracownik�w.");
						SetPlayerPosEx(playerid, 1482.2319, -1531.1719, 70.0080);
						SetPlayerVirtualWorld (playerid, 80) ;
						TogglePlayerControllable(playerid,0);
						Wchodzenie(playerid);
						SendClientMessage(playerid, COLOR_LIGHTGREEN, "Poziom 2, Sale Treningowe");
						PlayerPlaySound(playerid, 6401, 0.0, 0.0, 0.0);
					}
					case 4:
					{
						if(!IsABOR(playerid)) return SendClientMessage(playerid, 0xB52E2BFF, "Te wej�cie jest tylko dla pracownik�w.");
						SetPlayerPosEx(playerid, 1795.4104,-1551.2864,22.9192);
						SetPlayerVirtualWorld (playerid, 0) ;
						SendClientMessage(playerid, COLOR_LIGHTGREEN, "Poziom 3, Dach");
						PlayerPlaySound(playerid, 6401, 0.0, 0.0, 0.0);
					}
				}
			}
		}
		else if(dialogid == 19)
		{
			if(response)
			{
				switch(listitem)//Winda FBI","[Poziom -1]Parking podziemny \n[Poziom 0]Parking\n[Poziom 0.5]\n Stanowe\n[Poziom 1]Recepcja\n[Poziom 2] Szatnia\n[Poziom 3] Zbrojownia \n[Poziom 4]Biura federalne \n[Poziom 5] Dyrektorat\n[Poziom 6]CID/ERT\n[Poziom 7]Sale Treningowe \n [Poziom X] Dach","Jedz","Anuluj");
				{
					case 0://parking podziemny
					{
						if(IsACop(playerid))
						{
							SetPlayerVirtualWorld(playerid,2);
							SetPlayerPosEx(playerid,1093.0625,1530.8715,6.6905);
							SendClientMessage(playerid, COLOR_LIGHTGREEN, "Poziom -1, Parking podziemny FBI");
							PlayerInfo[playerid][pLocal] = 255;
							GameTextForPlayer(playerid, "~p~by Simeone ~r~Cat", 5000, 1);
						}
						else
						{
							sendErrorMessage(playerid, "Nie masz dost�pu na ten poziom!"); 
							return 1;
						}
					}
					case 1://parking
					{
						if(IsACop(playerid))
						{
							SetPlayerVirtualWorld(playerid,0);
							SetPlayerPosEx(playerid,596.5255, -1489.2544, 15.3587);
							SendClientMessage(playerid, COLOR_LIGHTGREEN, "Poziom 0, Parking FBI");
							GameTextForPlayer(playerid, "~p~by UbunteQ", 5000, 1);
							PlayerInfo[playerid][pLocal] = 255;
						}
						else
						{
							sendErrorMessage(playerid, "Nie masz dost�pu na ten poziom!"); 
							return 1;
						}
					}
					case 2://stanowe
					{
						SetPlayerVirtualWorld(playerid, 1);
						SetPlayerPosEx(playerid, 594.05334, -1476.27490, 81.82840+0.5);
						GameTextForPlayer(playerid, "~p~Wiezienie Stanowe", 5000, 1);
						PlayerInfo[playerid][pLocal] = 255;
					
					}
					case 3://recepcja
					{
						TogglePlayerControllable(playerid,0);
						Wchodzenie(playerid);
						SetPlayerVirtualWorld(playerid,1);
						SetPlayerPosEx(playerid,586.83704, -1473.89270, 89.30576);
						SendClientMessage(playerid, COLOR_LIGHTGREEN, "Poziom 1, Recepcja");
						GameTextForPlayer(playerid, "~p~by UbunteQ & Iwan", 5000, 1);
						PlayerInfo[playerid][pLocal] = 212;
					}
					case 4://szatnia
					{
						if(IsAFBI(playerid))
						{
							TogglePlayerControllable(playerid,0);
							Wchodzenie(playerid);
							SetPlayerVirtualWorld(playerid,2);
							SetPlayerPosEx(playerid,592.65466, -1486.76575, 82.10487);
							SendClientMessage(playerid, COLOR_LIGHTGREEN, "Poziom 2, Szatnia");
							PlayerPlaySound(playerid, 6401, 0.0, 0.0, 0.0);
							GameTextForPlayer(playerid, "~p~by UbunteQ & Iwan", 5000, 1);
							PlayerInfo[playerid][pLocal] = 255;
						}
						else
						{
							sendErrorMessage(playerid, "Nie masz dost�pu na ten poziom!"); 
							return 1;
						}
					
					}
					case 5://Zbrojownia
					{
						if(IsACop(playerid))
						{
							TogglePlayerControllable(playerid,0);
							Wchodzenie(playerid);
							SetPlayerVirtualWorld(playerid,3);
							SetPlayerPosEx(playerid,591.37579, -1482.26672, 80.43560);
							SendClientMessage(playerid, COLOR_LIGHTGREEN, "Poziom 3 - Zbrojownia");
							PlayerPlaySound(playerid, 6401, 0.0, 0.0, 0.0);
							GameTextForPlayer(playerid, "~p~by UbunteQ & Iwan", 5000, 1);
							PlayerInfo[playerid][pLocal] = 255;
						}
						else
						{
							sendErrorMessage(playerid, "Nie masz dost�pu na ten poziom!"); 
							return 1;
							
						}
					}
					case 6://Biura federalne
					{
						if(IsACop(playerid))
						{
							TogglePlayerControllable(playerid,0);
							Wchodzenie(playerid);
							SetPlayerVirtualWorld(playerid,4);
							SetPlayerPosEx(playerid,596.21857, -1477.92395, 84.06664);
							SendClientMessage(playerid, COLOR_LIGHTGREEN, "Poziom 4, Biura Federalne");
							PlayerInfo[playerid][pLocal] = 255;
						}
						else
						{
							sendErrorMessage(playerid, "Nie masz dost�pu na ten poziom!"); 
							return 1;
						}
					}
					case 7://Dyrektorat
					{

						TogglePlayerControllable(playerid,0);
						Wchodzenie(playerid);
						SetPlayerVirtualWorld(playerid,5);
						SetPlayerPosEx(playerid,589.23029, -1479.66357, 91.74274);
						SendClientMessage(playerid, COLOR_LIGHTGREEN, "Poziom 5, Dyrektorat");
						PlayerInfo[playerid][pLocal] = 212;
					}
					case 8://CID ERT
					{
						SetPlayerPosEx(playerid,585.70782, -1479.54211, 99.01273);
						TogglePlayerControllable(playerid,0);
						Wchodzenie(playerid);
						SetPlayerVirtualWorld(playerid,6);
						SendClientMessage(playerid, COLOR_LIGHTGREEN, "Poziom 6, CID/ERT");
						PlayerInfo[playerid][pLocal] = 212;
					}
					case 9://sale treningowe
					{
						SetPlayerPosEx(playerid, 590.42767, -1447.62939, 80.95732);
						TogglePlayerControllable(playerid, 0);
						Wchodzenie(playerid);
						SetPlayerVirtualWorld(playerid, 7);
						SendClientMessage(playerid, COLOR_LIGHTGREEN, "Poziom 7, Sale Treningowe");
					
					}
					case 10://dach
					{
						if(IsACop(playerid))
						{
							SetPlayerVirtualWorld(playerid,0);
							SetPlayerPosEx(playerid,613.4404,-1471.9745,73.8816);
							SendClientMessage(playerid, COLOR_LIGHTGREEN, "Poziom 8, Dach");
							PlayerInfo[playerid][pLocal] = 255;
						}
						else
						{
							sendErrorMessage(playerid, "Nie masz dost�pu na ten poziom");
							return 1;
						}
					}
				}
			}
		}
	    else if(dialogid == 12)
	    {
	        if(response)
	        {
				ShowPlayerDialogEx(playerid,12,DIALOG_STYLE_LIST,"Sklep 24/7","Telefon\t\t\t\t500$\nZdrapka\t\t\t7500$\nKsi��ka telefoniczna\t\t5000$\nKostka\t\t\t\t500$\nAparat Fotograficzny\t\t5000$\nZamek\t\t\t\t10000$\nPr�dko�ciomierz\t\t5000$\nKondom\t\t\t50$\nOdtwarzacz MP3\t\t2500$\nPiwo Mruczny Gul\t\t20$\nWino Komandaos\t\t25$\nSprunk\t\t\t\t15$\nCB-Radio\t\t\t2500$\nCygara\t\t\t\t200$","KUP","WYJD�");
	            new string[256];
	            switch(listitem)
	            {
	                case 0:
					{
		                if (kaska[playerid] > 500)
						{
						    if(PlayerInfo[playerid][pTraderPerk] > 0)
						    {
								new skill = 500 / 100;
								new price = (skill)*(PlayerInfo[playerid][pTraderPerk]);
								new payout = 500 - price;
						        format(string, sizeof(string), "~r~-$%d", payout);
								GameTextForPlayer(playerid, string, 5000, 1);
								DajKase(playerid,- payout);
						    }
						    else
						    {
						        format(string, sizeof(string), "~r~-$%d", 500);
								GameTextForPlayer(playerid, string, 5000, 1);
								DajKase(playerid,-500);
						    }
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							new randphone = 10000 + random(89999);//minimum 1000  max 9999
							PlayerInfo[playerid][pPnumber] = randphone;
							format(string, sizeof(string), "   Kupi�e� telefon. Tw�j numer to: %d", randphone);
							SendClientMessage(playerid, COLOR_GRAD4, string);
							SendClientMessage(playerid, COLOR_GRAD5, "Mo�esz sprawdzi� go w ka�dej chwili wpisuj�c /stats");
							SendClientMessage(playerid, COLOR_WHITE, "WSKAZ�WKA: Wpisz /telefonpomoc aby zobaczy� komendy telefonu.");
							return 1;
						}
					}
					case 1:
					{
						if (kaska[playerid] > 7500)
						{
						    if(PlayerInfo[playerid][pTraderPerk] > 0)
						    {
								new skill = 7500 / 100;
								new price = (skill)*(PlayerInfo[playerid][pTraderPerk]);
								new payout = 7500 - price;
								DajKase(playerid,- payout);
								format(string, sizeof(string), "~r~-$%d", payout);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							else
							{
							    DajKase(playerid,-7500);
								format(string, sizeof(string), "~r~-$%d", 1000);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							new prize;
							new symb1[32]; new symb2[32]; new symb3[32];
							new randcard1 = random(10);//minimum 1000  max 9999
							new randcard2 = random(10);//minimum 1000  max 9999
							new randcard3 = random(10);//minimum 1000  max 9999
							if(randcard1 >= 5)
							{
								format(symb1, sizeof(symb1), "~b~]");
								randcard1 = 1;
							}
							else if(randcard1 <= 4 && randcard1 >= 2)
							{
								format(symb1, sizeof(symb1), "~g~]");
								randcard1 = 2;
							}
							else if(randcard1 < 2)
							{
								format(symb1, sizeof(symb1), "~y~]");
								randcard1 = 3;
							}
							if(randcard2 >= 5)
							{
								format(symb2, sizeof(symb2), "~b~]");
								randcard2 = 1;
							}
							else if(randcard2 <= 4 && randcard2 >= 2)
							{
								format(symb2, sizeof(symb2), "~g~]");
								randcard2 = 2;
							}
							else if(randcard2 < 2)
							{
								format(symb2, sizeof(symb2), "~y~]");
								randcard2 = 3;
							}
							if(randcard3 >= 5)
							{
								format(symb3, sizeof(symb3), "~b~]");
								randcard3 = 1;
							}
							else if(randcard3 <= 4 && randcard3 >= 2)
							{
								format(symb3, sizeof(symb3), "~g~]");
								randcard3 = 2;
							}
							else if(randcard3 < 2)
							{
								format(symb3, sizeof(symb3), "~y~]");
								randcard3 = 3;
							}
							if(randcard1 == randcard2 && randcard1 == randcard3)
							{
								if(randcard1 > 5)
								{
									prize = 25000;
								}
								if(randcard1 <= 4 && randcard1 >= 2)
								{
									prize = 15000;
								}
								if(randcard1 < 2)
								{
									prize = 7500;
								}
								DajKase(playerid,prize);
								format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~%s %s %s ~n~~n~~w~~g~$%d",symb1,symb2,symb3, prize);
							}
							else
							{
								format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~%s %s %s ~n~~n~~w~~r~$0",symb1,symb2,symb3);
							}
							GameTextForPlayer(playerid, string, 3000, 3);
							return 1;
						}
					}
					case 2:
					{
						if (kaska[playerid] > 5000)
						{
						    if(PlayerInfo[playerid][pTraderPerk] > 0)
						    {
								new skill = 5000 / 100;
								new price = (skill)*(PlayerInfo[playerid][pTraderPerk]);
								new payout = 5000 - price;
								DajKase(playerid,- payout);
								format(string, sizeof(string), "~r~-$%d", payout);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							else
							{
							    DajKase(playerid,-5000);
								format(string, sizeof(string), "~r~-$%d", 5000);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			                PlayerInfo[playerid][pPhoneBook] = 1;
							format(string, sizeof(string), "   Ksi��ka telefoniczna zakupiona! Mo�esz teraz sprawdza� numery graczy !");
							SendClientMessage(playerid, COLOR_GRAD4, string);
							SendClientMessage(playerid, COLOR_WHITE, "WSKAZ�WKA: Wpisz /numer <id/nick>.");
							return 1;
						}
					}
					case 3:
					{
						if (kaska[playerid] > 500)
						{
						    if(PlayerInfo[playerid][pTraderPerk] > 0)
						    {
								new skill = 500 / 100;
								new price = (skill)*(PlayerInfo[playerid][pTraderPerk]);
								new payout = 500 - price;
								DajKase(playerid,- payout);
								format(string, sizeof(string), "~r~-$%d", payout);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							else
							{
							    DajKase(playerid,-500);
								format(string, sizeof(string), "~r~-$%d", 500);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							gDice[playerid] = 1;
							format(string, sizeof(string), "   Kostka zakupiona. Mo�esz ni� rzuca� u�ywaj�c /kostka2");
							SendClientMessage(playerid, COLOR_GRAD4, string);
							return 1;
						}
					}
					case 4:
					{
						if(kaska[playerid] > 5000)
						{
						    DajKase(playerid,-5000);
						    GameTextForPlayer(playerid, "~r~-$5000", 5000, 1);
							PlayerInfo[playerid][pGun9] = 43;
							PlayerInfo[playerid][pAmmo9] += 100;
						    GivePlayerWeapon(playerid, 43, 100);
							SendClientMessage(playerid, COLOR_GRAD4, "Aparat zakupiony! Mo�esz nim teraz robi� zdj�cia!");
							return 1;
						}
					}
					case 5:
					{
						if (kaska[playerid] > 10000)
						{
							SendClientMessage(playerid, COLOR_WHITE, "   Brak Towaru!");
							return 1;
						}
					}
					case 6:
					{
						if (kaska[playerid] > 5000)
						{
							/*if(PlayerInfo[playerid][pTraderPerk] > 0)
					    	{
								new skill = 5000 / 100;
								new price = (skill)*(PlayerInfo[playerid][pTraderPerk]);
								new payout = 5000 - price;
								format(string, sizeof(string), "~r~-$%d", payout);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							else
							{
							    DajKase(playerid,-5000);
								format(string, sizeof(string), "~r~-$%d", 5000);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							format(string, sizeof(string), "Pr�dko�ciomierz zakupiony.");
							SendClientMessage(playerid, COLOR_GRAD4, string);
							SendClientMessage(playerid, COLOR_WHITE, "WSKAZ�WKA: Wpisz /licznik ");*/
							SendClientMessage(playerid, COLOR_WHITE, "   Brak Towaru!");
							return 1;
						}
					}
					case 7:
					{
						if (kaska[playerid] > 49)
						{
						    if(PlayerInfo[playerid][pTraderPerk] > 0)
					    	{
								new skill = 50 / 100;
								new price = (skill)*(PlayerInfo[playerid][pTraderPerk]);
								new payout = 50 - price;
								DajKase(playerid,- payout);
								format(string, sizeof(string), "~r~-$%d", payout);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							else
							{
							    DajKase(playerid,-50);
								format(string, sizeof(string), "~r~-$%d", 50);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							Condom[playerid] ++;
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							format(string, sizeof(string), "Kondom Zakupiony.");
							SendClientMessage(playerid, COLOR_GRAD4, string);
							return 1;
						}
					}
					case 8:
					{
						if (kaska[playerid] > 2500)
						{
						    if(PlayerInfo[playerid][pTraderPerk] > 0)
					    	{
								new skill = 2500 / 100;
								new price = (skill)*(PlayerInfo[playerid][pTraderPerk]);
								new payout = 2500 - price;
								DajKase(playerid, - payout);
								format(string, sizeof(string), "~r~-$%d", payout);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							else
							{
							    DajKase(playerid, - 2500);
								format(string, sizeof(string), "~r~-$%d", 2500);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							format(string, sizeof(string), "Odtwarzacz MP3 Zakupiony.");
							SendClientMessage(playerid, COLOR_GRAD4, string);
							SendClientMessage(playerid, COLOR_WHITE, "WSKAZ�WKA: Wpisz /muzyka");
							PlayerInfo[playerid][pCDPlayer] = 1;
							return 1;
						}
					}
					case 9:
					{
						if (kaska[playerid] > 20)
						{
						    if(PlayerInfo[playerid][pPiwo] >= 4)
						    {
						    	SendClientMessage(playerid, COLOR_GREY, "   Masz za du�o Piw, nie ud�wigniesz ju� wi�cej !");
						    }
						    if(PlayerInfo[playerid][pTraderPerk] > 0)
					    	{
								new skill = 20 / 100;
								new price = (skill)*(PlayerInfo[playerid][pTraderPerk]);
								new payout = 20 - price;
								DajKase(playerid, - payout);
								format(string, sizeof(string), "~r~-$%d", payout);
								GameTextForPlayer(playerid, string, 5000, 1);
								ShowPlayerDialogEx(playerid,12,DIALOG_STYLE_LIST,"Sklep 24/7","Telefon\t\t\t\t500$\nZdrapka\t\t\t7500$\nKsi��ka telefoniczna\t\t5000$\nKostka\t\t\t\t500$\nAparat Fotograficzny\t\t5000$\nZamek\t\t\t\t10000$\nPr�dko�ciomierz\t\t5000$\nKondom\t\t\t50$\nOdtwarzacz MP3\t\t2500$\nPiwo Mruczny Gul\t\t20$\nWino Komandaos\t\t25$\nSprunk\t\t\t\t15$\nCB-Radio\t\t\t2500$\nCygara\t\t\t\t200$","KUP","WYJD�");
							}
							else
							{
							    DajKase(playerid, - 20);
								format(string, sizeof(string), "~r~-$%d", 20);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
						    DajKase(playerid, - 20);
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							format(string, sizeof(string), "Piwo 'Mruczny Gul; zakupione.");
							SendClientMessage(playerid, COLOR_GRAD4, string);
							SendClientMessage(playerid, COLOR_WHITE, "WSKAZ�WKA: Wpisz /piwo aby wypi�");
							format(string, sizeof(string), "~r~-$%d", 20);
							GameTextForPlayer(playerid, string, 5000, 1);
							PlayerInfo[playerid][pPiwo] += 1;
							SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_BEER);
							return 1;
						}
					}
					case 10:
					{
						if (kaska[playerid] > 25)
						{
						    if(PlayerInfo[playerid][pWino] >= 4)
						    {
						    	SendClientMessage(playerid, COLOR_GREY, "   Masz za du�o Win, nie ud�wigniesz ju� wi�cej !");
						    }
						    if(PlayerInfo[playerid][pTraderPerk] > 0)
					    	{
								new skill = 25 / 100;
								new price = (skill)*(PlayerInfo[playerid][pTraderPerk]);
								new payout = 25 - price;
								DajKase(playerid, - payout);
								format(string, sizeof(string), "~r~-$%d", payout);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							else
							{
							    DajKase(playerid, - 25);
								format(string, sizeof(string), "~r~-$%d", 25);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
						    DajKase(playerid, - 25);
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							format(string, sizeof(string), "Wino 'Komandos zakupione'.");
							SendClientMessage(playerid, COLOR_GRAD4, string);
							SendClientMessage(playerid, COLOR_WHITE, "WSKAZ�WKA: Wpisz /komandos aby wypi�");
							format(string, sizeof(string), "~r~-$%d", 25);
							GameTextForPlayer(playerid, string, 5000, 1);
							PlayerInfo[playerid][pWino] += 1;
							SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_WINE);
							return 1;
						}
					}
					case 11:
					{
						if (kaska[playerid] > 15)
						{
						    if(PlayerInfo[playerid][pSprunk] >= 5)
						    {
						    	SendClientMessage(playerid, COLOR_GREY, "   Masz za du�o Sprunk�w, nie ud�wigniesz ju� wi�cej !");
						    }
						    if(PlayerInfo[playerid][pTraderPerk] > 0)
					    	{
								new skill = 15 / 100;
								new price = (skill)*(PlayerInfo[playerid][pTraderPerk]);
								new payout = 15 - price;
								DajKase(playerid, - payout);
								format(string, sizeof(string), "~r~-$%d", payout);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							else
							{
							    DajKase(playerid, - 15);
								format(string, sizeof(string), "~r~-$%d", 15);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							format(string, sizeof(string), "Sprunk zakupiony.");
							SendClientMessage(playerid, COLOR_GRAD4, string);
							SendClientMessage(playerid, COLOR_WHITE, "WSKAZ�WKA: Wpisz /sprunk aby wypi� sprunka");
							SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_SPRUNK);
							PlayerInfo[playerid][pSprunk] += 1;
							return 1;
						}
					}
					case 12:
					{
						if (kaska[playerid] > 2500)
						{
						    if(PlayerInfo[playerid][pTraderPerk] > 0)
					    	{
								new skill = 2500 / 100;
								new price = (skill)*(PlayerInfo[playerid][pTraderPerk]);
								new payout = 2500 - price;
								DajKase(playerid, - payout);
								format(string, sizeof(string), "~r~-$%d", payout);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							else
							{
							    DajKase(playerid, - 2500);
								format(string, sizeof(string), "~r~-$%d", 2500);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							format(string, sizeof(string), "CB-RADIO Zakupione.");
							SendClientMessage(playerid, COLOR_GRAD4, string);
	     					SendClientMessage(playerid, COLOR_WHITE, "WSKAZ�WKA: Wpisz /cb w pojezdzie aby rozawiwac z innymi");
							PlayerInfo[playerid][pCB] = 1;
							return 1;
						}
					}
					case 13:
					{
						if (kaska[playerid] > 200)
						{
						    if(PlayerInfo[playerid][pCygaro] >= 1)
						    {
						    	SendClientMessage(playerid, COLOR_GREY, "   Masz ju� cygara, po co ci nast�pne?");
						    }
						    if(PlayerInfo[playerid][pTraderPerk] > 0)
					    	{
								new skill = 200 / 100;
								new price = (skill)*(PlayerInfo[playerid][pTraderPerk]);
								new payout = 200 - price;
								DajKase(playerid, - payout);
								format(string, sizeof(string), "~r~-$%d", payout);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							else
							{
							    DajKase(playerid, - 200);
								format(string, sizeof(string), "~r~-$%d", 200);
								GameTextForPlayer(playerid, string, 5000, 1);
							}
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							format(string, sizeof(string), "Paczka 5 cygar zakupiona.");
							SendClientMessage(playerid, COLOR_GRAD4, string);
							SendClientMessage(playerid, COLOR_WHITE, "WSKAZ�WKA: Wpisz /cygaro aby zapali�");
							PlayerInfo[playerid][pCygaro] = 5;
							SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
							return 1;
						}
						else
						{
							SendClientMessage(playerid, COLOR_WHITE, "   Nie masz na to pieni�dzy !");
						}
					}
				}
			}
		}
		else if(dialogid == 90)
		{
		    new string[256];
		    if(response)
			{
			    if(zdarzylwpisac[playerid] == 1)
			    {
				    if(strcmp(kodbitwy, inputtext, true ) == 0 && strlen(inputtext) == 8)
				    {
				        new giveplayer[MAX_PLAYER_NAME];
				        new sendername[MAX_PLAYER_NAME];
				        GetPlayerName(bijep[playerid], giveplayer, sizeof(giveplayer));
						GetPlayerName(playerid, sendername, sizeof(sendername));
						//
				    	podczasbicia[bijep[playerid]] = 1;
				    	podczasbicia[playerid] = 0;
				    	//
				    	new randbitwa = random(30);
						//kodbitwy[playa] = (PobijText[randbitwa]);
						strmid(kodbitwy, PobijText[randbitwa], 0, strlen(PobijText[randbitwa]), 256);
						format(string, sizeof(string), "Pr�bujesz pobi� %s, za 10 sekund rostrzygnie si� bitwa!", giveplayer);
		    			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
		    			format(string, sizeof(string), "%s pr�buje ci� pobi�! Wpisz ten kod aby si� obroni�:\n%s", sendername, kodbitwy);
						ShowPlayerDialogEx(bijep[playerid], 90, DIALOG_STYLE_INPUT, "BITWA!!", string, "Wybierz", "Wyjd�");
		       			//
				    	SendClientMessage(playerid, COLOR_WHITE, "CIOS ODBITY!");
				    	ApplyAnimation(playerid, "GYMNASIUM", "GYMshadowbox", 4.0, 1, 0, 0, 1, 0);
				    	ApplyAnimation(playerid, "GYMNASIUM", "GYMshadowbox", 4.0, 1, 0, 0, 1, 0);
				    	zdarzylwpisac[playerid] = 1;
				    	zdarzylwpisac[bijep[playerid]] = 1;
				    	SetTimerEx("naczasbicie",9000,0,"d",bijep[playerid]);
				    }
				    else
				    {
				        new giveplayer[MAX_PLAYER_NAME];
				        new sendername[MAX_PLAYER_NAME];
				        GetPlayerName(bijep[playerid], giveplayer, sizeof(giveplayer));
						GetPlayerName(playerid, sendername, sizeof(sendername));
				        format(string, sizeof(string), "* %s wyprowadzi� cios i pobi� %s.", giveplayer, sendername);
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		    			format(string, sizeof(string), "%s znokautowa� ci� bez wi�kszego problemu.", giveplayer);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "Pobi�e� %s bez wi�kszego trudu.", sendername);
						SendClientMessage(bijep[playerid], COLOR_LIGHTBLUE, string);
						ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.0, 0, 0, 0, 0, 0); // Dieing of Crack
						PlayerPlaySound(playerid, 1130, 0.0, 0.0, 0.0);
						PlayerPlaySound(bijep[playerid], 1130, 0.0, 0.0, 0.0);
						TogglePlayerControllable(playerid, 0);
						TogglePlayerControllable(bijep[playerid], 1);
						PlayerCuffed[playerid] = 3;
						PlayerCuffedTime[playerid] = 45;
						pobity[playerid] = 1;
						PlayerInfo[playerid][pMuted] = 1;
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Odczekaj 45 sekund");
						SetTimerEx("pobito",45000,0,"d",bijep[playerid]);
						pobilem[bijep[playerid]] = 1;
						PlayerFixRadio(playerid);
						PlayerFixRadio(bijep[playerid]);
						SetPlayerHealth(playerid, 30.0);
						ClearAnimations(bijep[playerid]);
						ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, 1, 0, 0, 1, 0);
						ClearAnimations(playerid);
						ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, 1, 0, 0, 1, 0);
						//new
				        podczasbicia[playerid] = 0;
				        bijep[bijep[playerid]] = 0;
				        bijep[playerid] = 0;
				    }
				}
				else
				{
				    new giveplayer[MAX_PLAYER_NAME];
	       			new sendername[MAX_PLAYER_NAME];
			        GetPlayerName(bijep[playerid], giveplayer, sizeof(giveplayer));
					GetPlayerName(playerid, sendername, sizeof(sendername));
			        format(string, sizeof(string), "* %s wyprowadzi� cios i pobi� %s.", giveplayer, sendername);
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		   			format(string, sizeof(string), "%s znokautowa� ci� bez wi�kszego problemu.", giveplayer);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "Pobi�e� %s bez wi�kszego trudu.", sendername);
					SendClientMessage(bijep[playerid], COLOR_LIGHTBLUE, string);
					ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.0, 0, 0, 0, 0, 0); // Dieing of Crack
					PlayerPlaySound(playerid, 1130, 0.0, 0.0, 0.0);
					PlayerPlaySound(bijep[playerid], 1130, 0.0, 0.0, 0.0);
					TogglePlayerControllable(playerid, 0);
					TogglePlayerControllable(bijep[playerid], 1);
					PlayerCuffed[playerid] = 3;
					PlayerCuffedTime[playerid] = 45;
					pobity[playerid] = 1;
					PlayerInfo[playerid][pMuted] = 1;
					SendClientMessage(playerid, COLOR_LIGHTBLUE, "Odczekaj 45 sekund");
					SetTimerEx("pobito",45000,0,"d",bijep[playerid]);
					pobilem[bijep[playerid]] = 1;
					PlayerFixRadio(playerid);
					PlayerFixRadio(bijep[playerid]);
					SendClientMessage(playerid, COLOR_WHITE, "Wpisa�e� tekst za wolno i przegra�e�!");
					SetPlayerHealth(playerid, 30.0);
					ClearAnimations(bijep[playerid]);
					ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, 1, 0, 0, 1, 0);
					ClearAnimations(playerid);
					ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, 1, 0, 0, 1, 0);
					//new
			        podczasbicia[playerid] = 0;
			        bijep[bijep[playerid]] = 0;
			        bijep[playerid] = 0;
				}
			}
			if(!response)
			{
			    new giveplayer[MAX_PLAYER_NAME];
	   			new sendername[MAX_PLAYER_NAME];
		        GetPlayerName(bijep[playerid], giveplayer, sizeof(giveplayer));
				GetPlayerName(playerid, sendername, sizeof(sendername));
		        format(string, sizeof(string), "* %s wyprowadzi� cios i pobi� %s.", giveplayer, sendername);
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	   			format(string, sizeof(string), "%s znokautowa� ci� bez wi�kszego problemu.", giveplayer);
	   			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				format(string, sizeof(string), "Pobi�e� %s bez wi�kszego trudu.", sendername);
				SendClientMessage(bijep[playerid], COLOR_LIGHTBLUE, string);
				ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.0, 0, 0, 0, 0, 0); // Dieing of Crack
				PlayerPlaySound(playerid, 1130, 0.0, 0.0, 0.0);
				PlayerPlaySound(bijep[playerid], 1130, 0.0, 0.0, 0.0);
				TogglePlayerControllable(playerid, 0);
				TogglePlayerControllable(bijep[playerid], 1);
				PlayerCuffed[playerid] = 3;
				PlayerCuffedTime[playerid] = 45;
				pobity[playerid] = 1;
				PlayerInfo[playerid][pMuted] = 1;
				SendClientMessage(playerid, COLOR_LIGHTBLUE, "Odczekaj 45 sekund");
				SetTimerEx("pobito",45000,0,"d",bijep[playerid]);
				pobilem[bijep[playerid]] = 1;
				PlayerFixRadio(playerid);
				PlayerFixRadio(bijep[playerid]);
				SetPlayerHealth(playerid, 30.0);
				ClearAnimations(bijep[playerid]);
				ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, 1, 0, 0, 1, 0);
				ClearAnimations(playerid);
				ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, 1, 0, 0, 1, 0);
				//new
		        podczasbicia[playerid] = 0;
		        bijep[bijep[playerid]] = 0;
		        bijep[playerid] = 0;
			}
		}
		else if(dialogid == 97)
		{
		    new string[256];
		    new giveplayer[MAX_PLAYER_NAME];
			new sendername[MAX_PLAYER_NAME];
			GetPlayerName(PDkuje[playerid], giveplayer, sizeof(giveplayer));
			GetPlayerName(playerid, sendername, sizeof(sendername));
			new cops;
			//
		    if(response)
		    {
		        format(string, sizeof(string), "* %s nie stawia oporu i daje si� sku� %s.", sendername, giveplayer);
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		        format(string, sizeof(string), "Sku�e� %s.", sendername);
				SendClientMessage(PDkuje[playerid], COLOR_LIGHTBLUE, string);
	            TogglePlayerControllable(playerid, 0);
	            zakuty[playerid] = 2;
                SetTimerEx("Odmroz",10*60000,0,"d",playerid);
	            SendClientMessage(playerid, COLOR_LIGHTBLUE, "Odkujesz sie za 10 minut");
		    }
		    if(!response)
		    {
		        foreach(new i : Player)
				{
				    if(IsPlayerConnected(i))
				    {
				        if(IsACop(i))
						{
						    if(GetDistanceBetweenPlayers(playerid,i) < 5)
	     					{
	     					    cops ++;
	     					}
						}
					}
				}
				if(cops >= 3 || TazerAktywny[playerid] == 1 && cops == 2)
				{
	                format(string, sizeof(string), "* %s wyrywa si� i ucieka lecz policjanci powstrzymuj� go i skuwaj� go si��.", sendername);
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			        format(string, sizeof(string), "Sku�e� %s.", sendername);
					SendClientMessage(PDkuje[playerid], COLOR_LIGHTBLUE, string);
		            TogglePlayerControllable(playerid, 0);
		            zakuty[playerid] = 2;
		            SetTimerEx("Odmroz",10*60000,0,"d",playerid);
                    SendClientMessage(playerid, COLOR_LIGHTBLUE, "Odkujesz sie za 10 minut");
				}
				else if(cops == 2 || TazerAktywny[playerid] == 1 && cops < 2)
				{
				    new rand = random(100);
				    if(rand <= 50)
				    {
				        format(string, sizeof(string), "* %s wyrywa si� z ca�ej si�y i ucieka.", sendername);
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						PDkuje[playerid] = 0;
						PoziomPoszukiwania[playerid] += 1;
						SetPlayerCriminal(playerid, 255, "Stawianie oporu podczas aresztowania");
				    }
				    else
				    {
				        format(string, sizeof(string), "* %s wyrywa si� i ucieka lecz policjanci powstrzymuj� go i skuwaj� go si��.", sendername);
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				        format(string, sizeof(string), "Sku�e� %s.", sendername);
						SendClientMessage(PDkuje[playerid], COLOR_LIGHTBLUE, string);
			            TogglePlayerControllable(playerid, 0);
			            zakuty[playerid] = 2;
			            SetTimerEx("Odmroz",10*60000,0,"d",playerid);
			            SendClientMessage(playerid, COLOR_LIGHTBLUE, "Odkujesz sie za 10 minut");
				    }
				}
				else
				{
				    format(string, sizeof(string), "* %s wyrywa si� z ca�ej si�y i ucieka.", sendername);
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					PDkuje[playerid] = 0;
					PoziomPoszukiwania[playerid] += 1;
					SetPlayerCriminal(playerid, 255, "Stawianie oporu podczas aresztowania");
				}
		    }
		}
		else if(dialogid == 98)
		{
		    new string[256];
		    new giveplayer[MAX_PLAYER_NAME];
			new sendername[MAX_PLAYER_NAME];
			GetPlayerName(PDkuje[playerid], giveplayer, sizeof(giveplayer));
			GetPlayerName(playerid, sendername, sizeof(sendername));
			new cops;
			//
		    if(response)
		    {
		        format(string, sizeof(string), "* %s nie stawia oporu i daje si� sku� %s.", sendername, giveplayer);
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		        format(string, sizeof(string), "Sku�e� %s.", sendername);
				SendClientMessage(PDkuje[playerid], COLOR_LIGHTBLUE, string);
				zakuty[playerid] = 1;
	            TogglePlayerControllable(playerid, 0);
	            uzytekajdanki[PDkuje[playerid]] = 1;
	            SkutyGracz[PDkuje[playerid]] = playerid;
				ClearAnimations(playerid);
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CUFFED);
                SetPlayerAttachedObject(playerid, 0, 19418, 6, -0.011000, 0.028000, -0.022000, -15.600012, -33.699977,-81.700035, 0.891999, 1.000000, 1.168000);
		    }
		    if(!response)
		    {
		        foreach(new i : Player)
				{
				    if(IsPlayerConnected(i))
				    {
				        if(IsACop(i) || IsABOR(i))
						{
						    if(GetDistanceBetweenPlayers(playerid,i) < 5)
	     					{
	     					    cops ++;
	     					}
						}
					}
				}
				if(cops >= 3)
				{
	                format(string, sizeof(string), "* %s wyrywa si� i ucieka lecz policjanci powstrzymuj� go i skuwaj� go si��.", sendername);
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			        format(string, sizeof(string), "Sku�e� %s.", sendername);
					SendClientMessage(PDkuje[playerid], COLOR_LIGHTBLUE, string);
					zakuty[playerid] = 1;
		            TogglePlayerControllable(playerid, 0);
		            uzytekajdanki[PDkuje[playerid]] = 1;
		            SkutyGracz[PDkuje[playerid]] = playerid;
					SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CUFFED);
					SetPlayerAttachedObject(playerid, 0, 19418, 6, -0.011000, 0.028000, -0.022000, -15.600012, -33.699977,-81.700035, 0.891999, 1.000000, 1.168000);
				}
				else if(cops == 2)
				{
				    new rand = random(100);
				    if(rand <= 50)
				    {
				        format(string, sizeof(string), "* %s wyrywa si� z ca�ej si�y i ucieka.", sendername);
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						PDkuje[playerid] = 0;
						PoziomPoszukiwania[playerid] += 1;
						SetPlayerCriminal(playerid, 255, "Stawianie oporu podczas aresztowania");
				    }
				    else
				    {
				        format(string, sizeof(string), "* %s wyrywa si� i ucieka lecz policjanci powstrzymuj� go i skuwaj� go si��.", sendername);
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				        format(string, sizeof(string), "Sku�e� %s.", sendername);
						SendClientMessage(PDkuje[playerid], COLOR_LIGHTBLUE, string);
						zakuty[playerid] = 1;
			            TogglePlayerControllable(playerid, 0);
			            uzytekajdanki[PDkuje[playerid]] = 1;
			            SkutyGracz[PDkuje[playerid]] = playerid;
						SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CUFFED);
						SetPlayerAttachedObject(playerid, 0, 19418, 6, -0.011000, 0.028000, -0.022000, -15.600012, -33.699977,-81.700035, 0.891999, 1.000000, 1.168000);
				    }
				}
				else
				{
				    format(string, sizeof(string), "* %s wyrywa si� z ca�ej si�y i ucieka.", sendername);
				    TogglePlayerControllable(playerid, 1);
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					PDkuje[playerid] = 0;
					PoziomPoszukiwania[playerid] += 1;
					SetPlayerCriminal(playerid, 255, "Stawianie oporu podczas aresztowania");
				}
		    }
		}
		else if(dialogid == 7080)
		{
		    new string[256];
		    new giveplayer[MAX_PLAYER_NAME];
			new sendername[MAX_PLAYER_NAME];
			GetPlayerName(PDkuje[playerid], giveplayer, sizeof(giveplayer));
			GetPlayerName(playerid, sendername, sizeof(sendername));
			//
		    if(response)
		    {
		        format(string, sizeof(string), "* %s nie stawia oporu i daje si� sku� �owcy %s.", sendername, giveplayer);
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		        format(string, sizeof(string), "Sku�e� %s. Masz 2 minuty, by dostarczy� go do celi!", sendername);
				SendClientMessage(PDkuje[playerid], COLOR_LIGHTBLUE, string);
				zakuty[playerid] = 1;
	            TogglePlayerControllable(playerid, 0);
	            uzytekajdanki[PDkuje[playerid]] = 1;
	            SkutyGracz[PDkuje[playerid]] = playerid;
				ClearAnimations(playerid);
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CUFFED);
                SetPlayerAttachedObject(playerid, 0, 19418, 6, -0.011000, 0.028000, -0.022000, -15.600012, -33.699977,-81.700035, 0.891999, 1.000000, 1.168000);
		    }
		    if(!response)
		    {
				format(string, sizeof(string), "* %s wyrywa si� i rzuca si� na �owc�!", sendername);
				TogglePlayerControllable(playerid, 1);
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				PDkuje[playerid] = 0;
		    }
		}
		else if(dialogid == 160)
		{
		    if(response)
		    {
		        ShowPlayerDialogEx(playerid, 161, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� komisariat?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	         	taxitest[playerid] = 0;
			}
		}
	 	else if(dialogid == 161)
	 	{
	 	    if(response)
	 	    {
	 	        switch(listitem)
				{
					case 0:
				    {
				        ShowPlayerDialogEx(playerid, 162, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� studio SAN?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
				    }
				    case 1:
				    {
				        ShowPlayerDialogEx(playerid, 162, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� studio SAN?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
				    }
				    case 2:
				    {
				        ShowPlayerDialogEx(playerid, 162, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� studio SAN?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
				    }
				    case 3:
				    {
				        ShowPlayerDialogEx(playerid, 162, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� studio SAN?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
				    }
				    case 4:
				    {
				    	ShowPlayerDialogEx(playerid, 162, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� studio SAN?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 5:
				    {
				        ShowPlayerDialogEx(playerid, 162, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� studio SAN?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
				    }
				    case 6:
				    {
				        ShowPlayerDialogEx(playerid, 162, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� studio SAN?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
				    }
				    case 7:
				    {
				        ShowPlayerDialogEx(playerid, 162, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� studio SAN?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
				    }
				    case 8:
				    {
				        ShowPlayerDialogEx(playerid, 162, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� studio SAN?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
				    }
				    case 9:
				    {
				        ShowPlayerDialogEx(playerid, 162, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� studio SAN?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
				    }
				    case 10:
				    {
				        ShowPlayerDialogEx(playerid, 162, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� studio SAN?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
				    }
				    case 11:
				    {
				        ShowPlayerDialogEx(playerid, 162, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� studio SAN?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
				    }
				    case 12:
				    {
				        ShowPlayerDialogEx(playerid, 162, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� studio SAN?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
				    }
				    case 13:
				    {
				        ShowPlayerDialogEx(playerid, 162, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� studio SAN?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
				    }
					case 14:
				    {
				        ShowPlayerDialogEx(playerid, 162, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� studio SAN?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
				    }
				}
	 	    }
	 	    if(!response)
	 	    {
	 	        taxitest[playerid] = 0;
	 	    }
	 	}
	 	else if(dialogid == 162)
	 	{
	 	    if(response)
	 	    {
	 	        switch(listitem)
				{
				    case 0:
				    {
				    	ShowPlayerDialogEx(playerid, 163, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Fabryka Broni?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 1:
				    {
				        ShowPlayerDialogEx(playerid, 163, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Fabryka Broni?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 2:
				    {
				        ShowPlayerDialogEx(playerid, 163, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Fabryka Broni?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 3:
				    {
				        ShowPlayerDialogEx(playerid, 163, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Fabryka Broni?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 4:
				    {
				        ShowPlayerDialogEx(playerid, 163, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Fabryka Broni?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 5:
				    {
				        ShowPlayerDialogEx(playerid, 163, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Fabryka Broni?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 6:
				    {
				        ShowPlayerDialogEx(playerid, 163, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Fabryka Broni?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 7:
				    {
				        ShowPlayerDialogEx(playerid, 163, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Fabryka Broni?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 8:
				    {
				        ShowPlayerDialogEx(playerid, 163, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Fabryka Broni?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 9:
				    {
				        ShowPlayerDialogEx(playerid, 163, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Fabryka Broni?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 10:
				    {
				        ShowPlayerDialogEx(playerid, 163, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Fabryka Broni?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 11:
				    {
				        ShowPlayerDialogEx(playerid, 163, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Fabryka Broni?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 12:
				    {
				        ShowPlayerDialogEx(playerid, 163, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Fabryka Broni?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 13:
				    {
				        ShowPlayerDialogEx(playerid, 163, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Fabryka Broni?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 14:
				    {
				        ShowPlayerDialogEx(playerid, 163, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Fabryka Broni?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				}
	 	    }
	 	    if(!response)
	 	    {
	 	        taxitest[playerid] = 0;
	 	    }
	 	}
	 	else if(dialogid == 163)
	 	{
	 	    if(response)
	 	    {
	 	        switch(listitem)
				{
				    case 0:
				    {
				    	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Salon Samochodowy?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 1:
				    {
				    	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Salon Samochodowy?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 2:
				    {
				    	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Salon Samochodowy?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 3:
				    {
				    	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Salon Samochodowy?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 4:
				    {
				    	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Salon Samochodowy?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 5:
				    {
				    	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Salon Samochodowy?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 6:
				    {
				    	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Salon Samochodowy?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 7:
				    {
				    	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Salon Samochodowy?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				    case 8:
				    {
				    	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Salon Samochodowy?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 9:
				    {
				    	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Salon Samochodowy?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 10:
				    {
				    	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Salon Samochodowy?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 11:
				    {
				    	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Salon Samochodowy?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 12:
				    {
				    	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Salon Samochodowy?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 13:
				    {
				    	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Salon Samochodowy?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 14:
				    {
				    	ShowPlayerDialogEx(playerid, 164, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Salon Samochodowy?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				}
	 	    }
	 	    if(!response)
	 	    {
	 	        taxitest[playerid] = 0;
	 	    }
	 	}
	 	else if(dialogid == 164)
	 	{
	 	    if(response)
	 	    {
	 	        switch(listitem)
				{
				    case 0:
				    {
				    	ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Ko�ci�?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				    case 1:
				    {
				    	ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Ko�ci�?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 2:
				    {
				    	ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Ko�ci�?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 3:
				    {
				    	ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Ko�ci�?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
	                case 4:
				    {
				    	ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Ko�ci�?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 5:
				    {
				    	ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Ko�ci�?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 6:
				    {
				    	ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Ko�ci�?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 7:
				    {
				    	ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Ko�ci�?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 8:
				    {
				    	ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Ko�ci�?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 9:
				    {
				    	ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Ko�ci�?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				    case 10:
				    {
				    	ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Ko�ci�?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				    case 11:
				    {
				    	ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Ko�ci�?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 12:
				    {
				    	ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Ko�ci�?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 13:
				    {
				    	ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Ko�ci�?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 14:
				    {
				    	ShowPlayerDialogEx(playerid, 165, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Ko�ci�?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				}
	 	    }
	 	    if(!response)
	 	    {
	 	        taxitest[playerid] = 0;
	 	    }
	 	}
	 	else if(dialogid == 165)
	 	{
	 	    if(response)
	 	    {
	 	        switch(listitem)
				{
				    case 0:
				    {
				    	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznik Tower(biurowiec)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				    case 1:
				    {
				    	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznik Tower(biurowiec)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 2:
				    {
				    	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznik Tower(biurowiec)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 3:
				    {
				    	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznik Tower(biurowiec)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 4:
				    {
				    	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznik Tower(biurowiec)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 5:
				    {
				    	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznik Tower(biurowiec)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				    case 6:
				    {
				    	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznik Tower(biurowiec)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 7:
				    {
				    	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznik Tower(biurowiec)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 8:
				    {
				    	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznik Tower(biurowiec)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 9:
				    {
				    	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznik Tower(biurowiec)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 10:
				    {
				    	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznik Tower(biurowiec)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 11:
				    {
				    	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznik Tower(biurowiec)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 12:
				    {
				    	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznik Tower(biurowiec)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 13:
				    {
				    	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznik Tower(biurowiec)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 14:
				    {
				    	ShowPlayerDialogEx(playerid, 166, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznik Tower(biurowiec)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				}
	 	    }
	 	    if(!response)
	 	    {
	 	        taxitest[playerid] = 0;
	 	    }
	 	}
	 	else if(dialogid == 166)
	 	{
	 	    if(response)
	 	    {
	 	        switch(listitem)
				{
				    case 0:
				    {
				    	ShowPlayerDialogEx(playerid, 167, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznikowy Gun Shop?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 1:
				    {
				    	ShowPlayerDialogEx(playerid, 167, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznikowy Gun Shop?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 2:
				    {
				    	ShowPlayerDialogEx(playerid, 167, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznikowy Gun Shop?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 3:
				    {
				    	ShowPlayerDialogEx(playerid, 167, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznikowy Gun Shop?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 4:
				    {
				    	ShowPlayerDialogEx(playerid, 167, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznikowy Gun Shop?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 5:
				    {
				    	ShowPlayerDialogEx(playerid, 167, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznikowy Gun Shop?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 6:
				    {
				    	ShowPlayerDialogEx(playerid, 167, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznikowy Gun Shop?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 7:
				    {
				    	ShowPlayerDialogEx(playerid, 167, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznikowy Gun Shop?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 8:
				    {
				    	ShowPlayerDialogEx(playerid, 167, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznikowy Gun Shop?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 9:
				    {
				    	ShowPlayerDialogEx(playerid, 167, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznikowy Gun Shop?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 10:
				    {
				    	ShowPlayerDialogEx(playerid, 167, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznikowy Gun Shop?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 11:
				    {
				    	ShowPlayerDialogEx(playerid, 167, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznikowy Gun Shop?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 12:
				    {
				    	ShowPlayerDialogEx(playerid, 167, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznikowy Gun Shop?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 13:
				    {
				    	ShowPlayerDialogEx(playerid, 167, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznikowy Gun Shop?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 14:
				    {
				    	ShowPlayerDialogEx(playerid, 167, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Mrucznikowy Gun Shop?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				}
	 	    }
	 	    if(!response)
	 	    {
	 	        taxitest[playerid] = 0;
	 	    }
	 	}
	 	else if(dialogid == 167)
	 	{
	 	    if(response)
	 	    {
	 	        switch(listitem)
				{
				    case 0:
				    {
				    	ShowPlayerDialogEx(playerid, 168, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Agencja Ochrony (zk� bukmaherski)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				    case 1:
				    {
				    	ShowPlayerDialogEx(playerid, 168, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Agencja Ochrony (zk� bukmaherski)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 2:
				    {
				    	ShowPlayerDialogEx(playerid, 168, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Agencja Ochrony (zk� bukmaherski)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				    case 3:
				    {
				    	ShowPlayerDialogEx(playerid, 168, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Agencja Ochrony (zk� bukmaherski)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 4:
				    {
				    	ShowPlayerDialogEx(playerid, 168, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Agencja Ochrony (zk� bukmaherski)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 5:
				    {
				    	ShowPlayerDialogEx(playerid, 168, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Agencja Ochrony (zk� bukmaherski)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 6:
				    {
				    	ShowPlayerDialogEx(playerid, 168, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Agencja Ochrony (zk� bukmaherski)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 7:
				    {
				    	ShowPlayerDialogEx(playerid, 168, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Agencja Ochrony (zk� bukmaherski)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 8:
				    {
				    	ShowPlayerDialogEx(playerid, 168, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Agencja Ochrony (zk� bukmaherski)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 9:
				    {
				    	ShowPlayerDialogEx(playerid, 168, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Agencja Ochrony (zk� bukmaherski)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 10:
				    {
				    	ShowPlayerDialogEx(playerid, 168, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Agencja Ochrony (zk� bukmaherski)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 11:
				    {
				    	ShowPlayerDialogEx(playerid, 168, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Agencja Ochrony (zk� bukmaherski)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 12:
				    {
				    	ShowPlayerDialogEx(playerid, 168, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Agencja Ochrony (zk� bukmaherski)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 13:
				    {
				    	ShowPlayerDialogEx(playerid, 168, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Agencja Ochrony (zk� bukmaherski)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 14:
				    {
				    	ShowPlayerDialogEx(playerid, 168, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Agencja Ochrony (zk� bukmaherski)?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				}
	 	    }
	 	    if(!response)
	 	    {
	 	        taxitest[playerid] = 0;
	 	    }
	 	}
	 	else if(dialogid == 168)
	 	{
	 	    if(response)
	 	    {
	 	        switch(listitem)
				{
				    case 0:
				    {
				    	ShowPlayerDialogEx(playerid, 169, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Szpital?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 1:
				    {
				    	ShowPlayerDialogEx(playerid, 169, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Szpital?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 2:
				    {
				    	ShowPlayerDialogEx(playerid, 169, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Szpital?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 3:
				    {
				    	ShowPlayerDialogEx(playerid, 169, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Szpital?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 4:
				    {
				    	ShowPlayerDialogEx(playerid, 169, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Szpital?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 5:
				    {
				    	ShowPlayerDialogEx(playerid, 169, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Szpital?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 6:
				    {
				    	ShowPlayerDialogEx(playerid, 169, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Szpital?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 7:
				    {
				    	ShowPlayerDialogEx(playerid, 169, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Szpital?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 8:
				    {
				    	ShowPlayerDialogEx(playerid, 169, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Szpital?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 9:
				    {
				    	ShowPlayerDialogEx(playerid, 169, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Szpital?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 10:
				    {
				    	ShowPlayerDialogEx(playerid, 169, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Szpital?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 11:
				    {
				    	ShowPlayerDialogEx(playerid, 169, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Szpital?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				    case 12:
				    {
				    	ShowPlayerDialogEx(playerid, 169, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Szpital?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				    case 13:
				    {
				    	ShowPlayerDialogEx(playerid, 169, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Szpital?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 14:
				    {
				    	ShowPlayerDialogEx(playerid, 169, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Szpital?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				}
	 	    }
	 	    if(!response)
	 	    {
	 	        taxitest[playerid] = 0;
	 	    }
	 	}
	 	else if(dialogid == 169)
	 	{
	 	    if(response)
	 	    {
	 	        switch(listitem)
				{
				    case 0:
				    {
				    	ShowPlayerDialogEx(playerid, 170, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Green Bar?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 1:
				    {
				    	ShowPlayerDialogEx(playerid, 170, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Green Bar?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 2:
				    {
				    	ShowPlayerDialogEx(playerid, 170, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Green Bar?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 3:
				    {
				    	ShowPlayerDialogEx(playerid, 170, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Green Bar?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 4:
				    {
				    	ShowPlayerDialogEx(playerid, 170, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Green Bar?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 5:
				    {
				    	ShowPlayerDialogEx(playerid, 170, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Green Bar?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 6:
				    {
				    	ShowPlayerDialogEx(playerid, 170, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Green Bar?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 7:
				    {
				    	ShowPlayerDialogEx(playerid, 170, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Green Bar?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 8:
				    {
				    	ShowPlayerDialogEx(playerid, 170, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Green Bar?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 9:
				    {
				    	ShowPlayerDialogEx(playerid, 170, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Green Bar?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
				    case 10:
				    {
				    	ShowPlayerDialogEx(playerid, 170, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Green Bar?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 11:
				    {
				    	ShowPlayerDialogEx(playerid, 170, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Green Bar?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 12:
				    {
				    	ShowPlayerDialogEx(playerid, 170, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Green Bar?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 13:
				    {
				    	ShowPlayerDialogEx(playerid, 170, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Green Bar?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 14:
				    {
				    	ShowPlayerDialogEx(playerid, 170, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Green Bar?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
				}
	 	    }
	 	    if(!response)
	 	    {
	 	        taxitest[playerid] = 0;
	 	    }
	 	}
	 	else if(dialogid == 170)
	 	{
	 	    if(response)
	 	    {
	 	        switch(listitem)
				{
				    case 0:
				    {
				    	ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Bank?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				    case 1:
				    {
				    	ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Bank?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
	                    taxitest[playerid] ++;
					}
					case 2:
				    {
				    	ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Bank?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 3:
				    {
				    	ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Bank?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 4:
				    {
				    	ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Bank?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 5:
				    {
				    	ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Bank?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 6:
				    {
				    	ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Bank?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 7:
				    {
				    	ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Bank?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 8:
				    {
				    	ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Bank?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 9:
				    {
				    	ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Bank?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 10:
				    {
				    	ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Bank?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 11:
				    {
				    	ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Bank?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 12:
				    {
				    	ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Bank?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 13:
				    {
				    	ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Bank?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
					case 14:
				    {
				    	ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_LIST, "W jakiej dzielnicy znajduje si� Bank?", "Rodeo\nGanton\nGlen Park\nDowntown\nPershing Square\nEl Corona\nIdlewood\nPlaya Del Seville\nOcean Docks\nVinewood\nMarket\nJefferson\nLos Flores\nEast Beach\nEast Los Santos", "Wybierz", "Wyjd�");
					}
				}
	 	    }
	 	    if(!response)
	 	    {
	 	        taxitest[playerid] = 0;
	 	    }
	 	}
	 	else if(dialogid == 171)
	 	{
	 	    if(response)
	 	    {
	 	        switch(listitem)
				{
				    case 0:
				    {
				        if(taxitest[playerid] >= 8)
				        {
							ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_MSGBOX, "Wyniki", "Gratulacje, uda�o ci si� wyrobi� licencje taks�wkarsk�! Zostajesz taks�wkarzem. �wietnie znasz miasto.", "OK", "Wyjd�");
		                    taxitest[playerid] = 0;
		                    PlayerInfo[playerid][pJob] = 14;
					        PlayerInfo[playerid][pRank] = 0;
					        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Podpisa�e� kontrakt z firm� taks�wkars� na 5h, id� po swoj� taryf�! (Aby si� zwolni� wpisz /quitjob)");
					    }
					    else
					    {
					        ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Nie znasz miasta tak dobrze aby zosta� taks�wkarzem. Poje�dzij autobusami aby si� z nim zapozna�.", "OK", "Wyjd�");
					    }
					}
					case 1:
				    {
				        if(taxitest[playerid] >= 8)
				        {
							ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_MSGBOX, "Wyniki", "Gratulacje, uda�o ci si� wyrobi� licencje taks�wkarsk�! Zostajesz taks�wkarzem. �wietnie znasz miasto.", "OK", "Wyjd�");
		                    taxitest[playerid] = 0;
		                    PlayerInfo[playerid][pJob] = 14;
					        PlayerInfo[playerid][pRank] = 0;
					        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Podpisa�e� kontrakt z firm� taks�wkars� na 5h, id� po swoj� taryf�! (Aby si� zwolni� wpisz /quitjob)");
					    }
					    else
					    {
					        ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Nie znasz miasta tak dobrze aby zosta� taks�wkarzem. Poje�dzij autobusami aby si� z nim zapozna�.", "OK", "Wyjd�");
					    }
					}
					case 2:
				    {
				        if(taxitest[playerid] >= 8)
				        {
							ShowPlayerDialogEx(playerid, 171, DIALOG_STYLE_MSGBOX, "Wyniki", "Gratulacje, uda�o ci si� wyrobi� licencje taks�wkarsk�! Zostajesz taks�wkarzem. �wietnie znasz miasto.", "OK", "Wyjd�");
		                    taxitest[playerid] = 0;
		                    PlayerInfo[playerid][pJob] = 14;

					        PlayerInfo[playerid][pRank] = 0;
					        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Podpisa�e� kontrakt z firm� taks�wkars� na 5h, id� po swoj� taryf�! (Aby si� zwolni� wpisz /quitjob)");
					    }
					    else
					    {
					        ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Nie znasz miasta tak dobrze aby zosta� taks�wkarzem. Poje�dzij autobusami aby si� z nim zapozna�.", "OK", "Wyjd�");
					    }
					}
				    case 3:
				    {
				        if(taxitest[playerid] >= 8)
				        {
							ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Gratulacje, uda�o ci si� wyrobi� licencje taks�wkarsk�! Zostajesz taks�wkarzem. �wietnie znasz miasto.", "OK", "Wyjd�");
		                    taxitest[playerid] = 0;
		                    PlayerInfo[playerid][pJob] = 14;

					        PlayerInfo[playerid][pRank] = 0;
					        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Podpisa�e� kontrakt z firm� taks�wkars� na 5h, id� po swoj� taryf�! (Aby si� zwolni� wpisz /quitjob)");
					    }
					    else
					    {
					        ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Nie znasz miasta tak dobrze aby zosta� taks�wkarzem. Poje�dzij autobusami aby si� z nim zapozna�.", "OK", "Wyjd�");
					    }
					}
					case 4:
				    {
				        if(taxitest[playerid] >= 8)
				        {
							ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Gratulacje, uda�o ci si� wyrobi� licencje taks�wkarsk�! Zostajesz taks�wkarzem. �wietnie znasz miasto.", "OK", "Wyjd�");
		                    taxitest[playerid] = 0;
		                    PlayerInfo[playerid][pJob] = 14;

					        PlayerInfo[playerid][pRank] = 0;
					        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Podpisa�e� kontrakt z firm� taks�wkars� na 2,5h, id� po swoj� taryf�! (Aby si� zwolni� wpisz /quitjob)");
					    }
					    else
					    {
					        ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Nie znasz miasta tak dobrze aby zosta� taks�wkarzem. Poje�dzij autobusami aby si� z nim zapozna�.", "OK", "Wyjd�");
					    }
					}
					case 5:
				    {
				        if(taxitest[playerid] >= 8)
				        {
							ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Gratulacje, uda�o ci si� wyrobi� licencje taks�wkarsk�! Zostajesz taks�wkarzem. �wietnie znasz miasto.", "OK", "Wyjd�");
		                    taxitest[playerid] = 0;
		                    PlayerInfo[playerid][pJob] = 14;

					        PlayerInfo[playerid][pRank] = 0;
					        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Podpisa�e� kontrakt z firm� taks�wkars� na 2,5h, id� po swoj� taryf�! (Aby si� zwolni� wpisz /quitjob)");
					    }
					    else
					    {
					        ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Nie znasz miasta tak dobrze aby zosta� taks�wkarzem. Poje�dzij autobusami aby si� z nim zapozna�.", "OK", "Wyjd�");
					    }
					}
					case 6:
				    {
				        if(taxitest[playerid] >= 8)
				        {
							ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Gratulacje, uda�o ci si� wyrobi� licencje taks�wkarsk�! Zostajesz taks�wkarzem. �wietnie znasz miasto.", "OK", "Wyjd�");
		                    taxitest[playerid] = 0;
		                    PlayerInfo[playerid][pJob] = 14;

					        PlayerInfo[playerid][pRank] = 0;
					        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Podpisa�e� kontrakt z firm� taks�wkars� na 2,5h, id� po swoj� taryf�! (Aby si� zwolni� wpisz /quitjob)");
					    }
					    else
					    {
					        ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Nie znasz miasta tak dobrze aby zosta� taks�wkarzem. Poje�dzij autobusami aby si� z nim zapozna�.", "OK", "Wyjd�");
					    }
					}
					case 7:
				    {
				        if(taxitest[playerid] >= 8)
				        {
							ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Gratulacje, uda�o ci si� wyrobi� licencje taks�wkarsk�! Zostajesz taks�wkarzem. �wietnie znasz miasto.", "OK", "Wyjd�");
		                    taxitest[playerid] = 0;
		                    PlayerInfo[playerid][pJob] = 14;

					        PlayerInfo[playerid][pRank] = 0;
					        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Podpisa�e� kontrakt z firm� taks�wkars� na 2,5h, id� po swoj� taryf�! (Aby si� zwolni� wpisz /quitjob)");
					    }
					    else
					    {
					        ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Nie znasz miasta tak dobrze aby zosta� taks�wkarzem. Poje�dzij autobusami aby si� z nim zapozna�.", "OK", "Wyjd�");
					    }
					}
					case 8:
				    {
				        if(taxitest[playerid] >= 8)
				        {
							ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Gratulacje, uda�o ci si� wyrobi� licencje taks�wkarsk�! Zostajesz taks�wkarzem. �wietnie znasz miasto.", "OK", "Wyjd�");
		                    taxitest[playerid] = 0;
		                    PlayerInfo[playerid][pJob] = 14;

					        PlayerInfo[playerid][pRank] = 0;
					        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Podpisa�e� kontrakt z firm� taks�wkars� na 2,5h, id� po swoj� taryf�! (Aby si� zwolni� wpisz /quitjob)");
					    }
					    else
					    {
					        ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Nie znasz miasta tak dobrze aby zosta� taks�wkarzem. Poje�dzij autobusami aby si� z nim zapozna�.", "OK", "Wyjd�");
					    }
					}
					case 9:
				    {
				        if(taxitest[playerid] >= 8)
				        {
							ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Gratulacje, uda�o ci si� wyrobi� licencje taks�wkarsk�! Zostajesz taks�wkarzem. �wietnie znasz miasto.", "OK", "Wyjd�");
		                    taxitest[playerid] = 0;
		                    PlayerInfo[playerid][pJob] = 14;

					        PlayerInfo[playerid][pRank] = 0;
					        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Podpisa�e� kontrakt z firm� taks�wkars� na 2,5h, id� po swoj� taryf�! (Aby si� zwolni� wpisz /quitjob)");
					    }
					    else
					    {
					        ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Nie znasz miasta tak dobrze aby zosta� taks�wkarzem. Poje�dzij autobusami aby si� z nim zapozna�.", "OK", "Wyjd�");
					    }
					}
					case 10:
				    {
				        if(taxitest[playerid] >= 8)
				        {
							ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Gratulacje, uda�o ci si� wyrobi� licencje taks�wkarsk�! Zostajesz taks�wkarzem. �wietnie znasz miasto.", "OK", "Wyjd�");
		                    taxitest[playerid] = 0;
		                    PlayerInfo[playerid][pJob] = 14;

					        PlayerInfo[playerid][pRank] = 0;
					        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Podpisa�e� kontrakt z firm� taks�wkars� na 2,5h, id� po swoj� taryf�! (Aby si� zwolni� wpisz /quitjob)");
					    }
					    else
					    {
					        ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Nie znasz miasta tak dobrze aby zosta� taks�wkarzem. Poje�dzij autobusami aby si� z nim zapozna�.", "OK", "Wyjd�");
					    }
					}
					case 11:
				    {
				        if(taxitest[playerid] >= 8)
				        {
							ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Gratulacje, uda�o ci si� wyrobi� licencje taks�wkarsk�! Zostajesz taks�wkarzem. �wietnie znasz miasto.", "OK", "Wyjd�");
		                    taxitest[playerid] = 0;
		                    PlayerInfo[playerid][pJob] = 14;

					        PlayerInfo[playerid][pRank] = 0;
					        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Podpisa�e� kontrakt z firm� taks�wkars� na 2,5h, id� po swoj� taryf�! (Aby si� zwolni� wpisz /quitjob)");
					    }
					    else
					    {
					        ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Nie znasz miasta tak dobrze aby zosta� taks�wkarzem. Poje�dzij autobusami aby si� z nim zapozna�.", "OK", "Wyjd�");
					    }
					}
					case 12:
				    {
				        if(taxitest[playerid] >= 8)
				        {
							ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Gratulacje, uda�o ci si� wyrobi� licencje taks�wkarsk�! Zostajesz taks�wkarzem. �wietnie znasz miasto.", "OK", "Wyjd�");
		                    taxitest[playerid] = 0;
		                    PlayerInfo[playerid][pJob] = 14;

					        PlayerInfo[playerid][pRank] = 0;
					        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Podpisa�e� kontrakt z firm� taks�wkars� na 2,5h, id� po swoj� taryf�! (Aby si� zwolni� wpisz /quitjob)");
					    }
					    else
					    {
					        ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Nie znasz miasta tak dobrze aby zosta� taks�wkarzem. Poje�dzij autobusami aby si� z nim zapozna�.", "OK", "Wyjd�");
					    }
					}
					case 13:
				    {
				        if(taxitest[playerid] >= 8)
				        {
							ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Gratulacje, uda�o ci si� wyrobi� licencje taks�wkarsk�! Zostajesz taks�wkarzem. �wietnie znasz miasto.", "OK", "Wyjd�");
		                    taxitest[playerid] = 0;
		                    PlayerInfo[playerid][pJob] = 14;

					        PlayerInfo[playerid][pRank] = 0;
					        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Podpisa�e� kontrakt z firm� taks�wkars� na 2,5h, id� po swoj� taryf�! (Aby si� zwolni� wpisz /quitjob)");
					    }
					    else
					    {
					        ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Nie znasz miasta tak dobrze aby zosta� taks�wkarzem. Poje�dzij autobusami aby si� z nim zapozna�.", "OK", "Wyjd�");
					    }
					}
					case 14:
				    {
				        if(taxitest[playerid] >= 8)
				        {
							ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Gratulacje, uda�o ci si� wyrobi� licencje taks�wkarsk�! Zostajesz taks�wkarzem. �wietnie znasz miasto.", "OK", "Wyjd�");
		                    taxitest[playerid] = 0;
		                    PlayerInfo[playerid][pJob] = 14;

					        PlayerInfo[playerid][pRank] = 0;
					        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Podpisa�e� kontrakt z firm� taks�wkars� na 2,5h, id� po swoj� taryf�! (Aby si� zwolni� wpisz /quitjob)");
					    }
					    else
					    {
					        ShowPlayerDialogEx(playerid, 172, DIALOG_STYLE_MSGBOX, "Wyniki", "Nie znasz miasta tak dobrze aby zosta� taks�wkarzem. Poje�dzij autobusami aby si� z nim zapozna�.", "OK", "Wyjd�");
					    }
					}
				}
	 	    }
	 	    if(!response)
	 	    {
	 	        taxitest[playerid] = 0;
	 	    }
	 	}
	    else if(dialogid == 20)
	    {
	        if(response)
	        {
	            SendClientMessage(playerid, 0xFFFFFFFF, "Bronie przywr�cone");
	            PrzywrocBron(playerid);
				SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 10);
				SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN, 10);
	        }
		}
	    else if(dialogid == 50)
	    {
	        if(response)
	        {
				ShowPlayerDialogEx(playerid,51,DIALOG_STYLE_MSGBOX,"Dost�pne malunki woz�w","Uranus\n\n0- Niebiesko ��ty kolor\n1-Niebiesko fioletowy kolor + grafika po bokach\n2- Niebieski kolor z b�yskawicami\n3- Wyczy�� malunek\n\nJester\n\n0-��to pomara�czowy kolor z pazurami tygrysa\n1-Niebiesko fioletowy kolor z grafik� po bokach\n2-Zielony prz�d, ciemno zielony ty�\n3- Wyczy�� malunek\n\nNaci�nij DALEJ","DALEJ","WYJD�");
	        }
	    }
	    else if(dialogid == 51)
	    {
	        if(response)
	        {
	            ShowPlayerDialogEx(playerid,52,DIALOG_STYLE_MSGBOX,"Dost�pne malunki woz�w","Sultan\n\n0- Alien (fioletowy malunek)\n1- Niebieski kolor z rajdow� grafik�\n2- X-flow (niebiesko szary kolor)\n3- Wyczy�� malunek\n\nStratum\n\n0- Fioletowy kolor z t�czow� grafik�\n1- Acces (czerowny z grafik�)\n2- Sprunk\n3- Wyczy�� malunek\n\nElegy\n\n0- Niebieski kolor z p�omieniami\n1- Acces (pomara�czowy z grafik�)\n2- Fioletowy z grafik� po bokach\n3- Wyczy�� malunek\n\nNaci�nij DALEJ","DALEJ","WYJD�");
	        }
	    }
	    else if(dialogid == 52)
	    {
	        if(response)
	        {
	            ShowPlayerDialogEx(playerid,53,DIALOG_STYLE_MSGBOX,"Dost�pne malunki woz�w","Flash\n\n0- Czerwono ��ty z grafik�\n1- Fioletowo czerwony z grafik�\n2- Niebiesko fioletowy z grafik�\n3- Wyczy�� malunek\n\nBroadway\n\n0- ��te p�omienie na ca�ym aucie\n1- Czerwone p�omienie z przodu\n2 i 3- wyczy�� malunek\n\nCapmer\n\n0- Hipisowski malnuek\n1, 2 i 3 - wyszy�� malunek\n\n Tylko na wymienionych autach mo�na namalowa� malunek.","WYJD�","WYJD�");
	        }
	    }
        else if(dialogid == 501)
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
				    {
				        new playa = mechanikid[playerid];
	                    new pojazd = GetPlayerVehicleID(playa);
	                    new model = GetVehicleModel(pojazd);
	                    new zderzakid;
	                    new zderzakid2;
	                    if(model == 562)//Elegy
						{
							zderzakid = 1172;
							zderzakid2 = 1148;
						}
						else if(model == 565)//Flash
						{
						    zderzakid = 1151;
							zderzakid2 = 1152;
						}
						else if(model == 561)//Stratum
						{
						    zderzakid = 1156;
							zderzakid2 = 1157;
						}
						else if(model == 559)//Jester
						{
						    zderzakid = 1161;
							zderzakid2 = 1173;
						}
						else if(model == 558)//Uranus
						{
						    zderzakid = 1165;
							zderzakid2 = 1167;
						}
						else if(model == 560)//Sultan
						{
						    zderzakid = 1140;
							zderzakid2 = 1170;
						}
						if(zderzakid == 0 || zderzakid2 == 0)
						{
						    SendClientMessage(playerid, COLOR_WHITE, "B��D!");
						}
						else
						{
		                    new sendername[MAX_PLAYER_NAME];
		                    new giveplayer[MAX_PLAYER_NAME];
		                    new string[256];

							GetPlayerName(playerid, sendername, sizeof(sendername));
		   					GetPlayerName(playa, giveplayer, sizeof(giveplayer));
							format(string, sizeof(string), "* Zamontowa�e� nowe zderzaki graczowi %s (koszt -10 000$)",giveplayer);
			    			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
		      				format(string, sizeof(string), "* Mechanik %s zamontowa� ci w twoim %s nowe zderzaki",sendername, VehicleNames[GetVehicleModel(pojazd)-400]);
							SendClientMessage(playa, COLOR_LIGHTBLUE, string);
							format(string, sizeof(string),"* Mechanik %s wyci�ga narz�dzia i montuje nowe zderzaki w %s.", sendername, VehicleNames[GetVehicleModel(pojazd)-400]);
							ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
							DajKase(playerid, -10000);
							format(string, sizeof(string), "~r~-$%d", 10000);
							GameTextForPlayer(playerid, string, 5000, 1);
		     				PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			    			AddVehicleComponent(pojazd, zderzakid);//zderzak
			    			AddVehicleComponent(pojazd, zderzakid2);//zderzak

                            CarData[VehicleUID[pojazd][vUID]][c_Bumper][0] = zderzakid;
                            CarData[VehicleUID[pojazd][vUID]][c_Bumper][1] = zderzakid2;
                            Car_Save(VehicleUID[pojazd][vUID], CAR_SAVE_TUNE);
						}
				    }
				    case 1:
				    {
				        new playa = mechanikid[playerid];
	           			new pojazd = GetPlayerVehicleID(playa);
	           			new model = GetVehicleModel(pojazd);
	                    new zderzakid;
	                    new zderzakid2;
	                    if(model == 562)//Elegy
						{
						    zderzakid = 1171;
							zderzakid2 = 1149;
						}
						else if(model == 565)//Flash
						{
						    zderzakid = 1150;
							zderzakid2 = 1153;
						}
						else if(model == 561)//Stratum
						{
						    zderzakid = 1154;
							zderzakid2 = 1155;
						}
						else if(model == 559)//Jester
						{
						    zderzakid = 1159;
							zderzakid2 = 1160;
						}
						else if(model == 558)//Uranus
						{
						    zderzakid = 1166;
							zderzakid2 = 1168;
						}
						else if(model == 560)//Sultan
						{
						    zderzakid = 1141;
							zderzakid2 = 1169;
						}
						if(zderzakid == 0 || zderzakid2 == 0)
						{
						    SendClientMessage(playerid, COLOR_WHITE, "B��D!");
						}
						else
						{
		                    new sendername[MAX_PLAYER_NAME];
		                    new giveplayer[MAX_PLAYER_NAME];
		                    new string[256];

							GetPlayerName(playerid, sendername, sizeof(sendername));
		   					GetPlayerName(playa, giveplayer, sizeof(giveplayer));
							format(string, sizeof(string), "* Zamontowa�e� nowe zderzaki graczowi %s (koszt -10 000$)",giveplayer);
			    			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
		      				format(string, sizeof(string), "* Mechanik %s zamontowa� ci w twoim %s nowe zderzaki",sendername, VehicleNames[GetVehicleModel(pojazd)-400]);
							SendClientMessage(playa, COLOR_LIGHTBLUE, string);
							format(string, sizeof(string),"* Mechanik %s wyci�ga narz�dzia i montuje nowe zderzaki w %s.", sendername, VehicleNames[GetVehicleModel(pojazd)-400]);
							ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
							DajKase(playerid, -10000);
							format(string, sizeof(string), "~r~-$%d", 10000);
							GameTextForPlayer(playerid, string, 5000, 1);
		     				PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			    			AddVehicleComponent(pojazd, zderzakid);//zderzak
			    			AddVehicleComponent(pojazd, zderzakid2);//zderzak
                            CarData[VehicleUID[pojazd][vUID]][c_Bumper][0] = zderzakid;
                            CarData[VehicleUID[pojazd][vUID]][c_Bumper][1] = zderzakid2;
                            Car_Save(VehicleUID[pojazd][vUID], CAR_SAVE_TUNE);
						}
				    }
				}
			}
	    }
	    else if(dialogid == 502)
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
				    {
				        new playa = mechanikid[playerid];
	                    new pojazd = GetPlayerVehicleID(playa);
	                    new model = GetVehicleModel(pojazd);
	                    new zderzakid;
	                    new zderzakid2;
						if(model == 575)//brodway
						{
						    zderzakid = 1174;
						    zderzakid2 = 1176;
						}
						else if(model == 534)//remington
						{
						    zderzakid = 1179;
						    zderzakid2 = 1180;
						}
						else if(model == 536)//Blade
						{
						    zderzakid = 1182;
						    zderzakid2 = 1184;
						}
						else if(model == 567)//Savanna
						{
						    zderzakid = 1187;
						    zderzakid2 = 1189;
						}
						else if(model == 576)//Tornado
						{
						    zderzakid = 1191;
						    zderzakid2 = 1192;
						}
						if(zderzakid == 0 || zderzakid2 == 0)
						{
						    SendClientMessage(playerid, COLOR_WHITE, "B��D!");
						}
						else
						{
		                    new sendername[MAX_PLAYER_NAME];
		                    new giveplayer[MAX_PLAYER_NAME];
		                    new string[256];
							GetPlayerName(playerid, sendername, sizeof(sendername));
		   					GetPlayerName(playa, giveplayer, sizeof(giveplayer));
							format(string, sizeof(string), "* Zamontowa�e� nowe zderzaki graczowi %s (koszt -10 000$)",giveplayer);
			    			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
		      				format(string, sizeof(string), "* Mechanik %s zamontowa� ci w twoim %s nowe zderzaki",sendername, VehicleNames[GetVehicleModel(pojazd)-400]);
							SendClientMessage(playa, COLOR_LIGHTBLUE, string);
							format(string, sizeof(string),"* Mechanik %s wyci�ga narz�dzia i montuje nowe zderzaki w %s.", sendername, VehicleNames[GetVehicleModel(pojazd)-400]);
							ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
							DajKase(playerid, -10000);
							format(string, sizeof(string), "~r~-$%d", 10000);
							GameTextForPlayer(playerid, string, 5000, 1);
		     				PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			    			AddVehicleComponent(pojazd, zderzakid);//zderzak
			    			AddVehicleComponent(pojazd, zderzakid2);//zderzak
                            CarData[VehicleUID[pojazd][vUID]][c_Bumper][0] = zderzakid;
                            CarData[VehicleUID[pojazd][vUID]][c_Bumper][1] = zderzakid2;
                            Car_Save(VehicleUID[pojazd][vUID], CAR_SAVE_TUNE);
						}
				    }
				    case 1:
				    {
				        new playa = mechanikid[playerid];
				        new pojazd = GetPlayerVehicleID(playa);
				        new model = GetVehicleModel(pojazd);
				        new zderzakid;
	                    new zderzakid2;
						if(model == 575)//broadway
						{
	                        zderzakid = 1175;
						    zderzakid2 = 1177;
						}
						else if(model == 534)//remington
						{
						    zderzakid = 1178;
						    zderzakid2 = 1185;
						}
						else if(model == 536)//Blade
						{
						    zderzakid = 1181;
						    zderzakid2 = 1183;
						}
						else if(model == 567)//Savanna
						{
						    zderzakid = 1186;
						    zderzakid2 = 1188;
						}
						else if(model == 576)//Tornado
						{
						    zderzakid = 1190;
						    zderzakid2 = 1193;
						}
						if(zderzakid == 0 || zderzakid2 == 0)
						{
						    SendClientMessage(playerid, COLOR_WHITE, "B��D!");
						}
						else
						{
		                    new sendername[MAX_PLAYER_NAME];
		                    new giveplayer[MAX_PLAYER_NAME];
		                    new string[256];
							GetPlayerName(playerid, sendername, sizeof(sendername));
		   					GetPlayerName(playa, giveplayer, sizeof(giveplayer));
							format(string, sizeof(string), "* Zamontowa�e� nowe zderzaki graczowi %s (koszt -10 000$)",giveplayer);
			    			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
		      				format(string, sizeof(string), "* Mechanik %s zamontowa� ci w twoim %s nowe zderzaki",sendername, VehicleNames[GetVehicleModel(pojazd)-400]);
							SendClientMessage(playa, COLOR_LIGHTBLUE, string);
							format(string, sizeof(string),"* Mechanik %s wyci�ga narz�dzia i montuje nowe zderzaki w %s.", sendername, VehicleNames[GetVehicleModel(pojazd)-400]);
							ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
							DajKase(playerid, -10000);
							format(string, sizeof(string), "~r~-$%d", 10000);
							GameTextForPlayer(playerid, string, 5000, 1);
		     				PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			    			AddVehicleComponent(pojazd, zderzakid);//zderzak
			    			AddVehicleComponent(pojazd, zderzakid2);//zderzak
                            CarData[VehicleUID[pojazd][vUID]][c_Bumper][0] = zderzakid;
                            CarData[VehicleUID[pojazd][vUID]][c_Bumper][1] = zderzakid2;
                            Car_Save(VehicleUID[pojazd][vUID], CAR_SAVE_TUNE);
						}
				    }
				}
			}
	    }
	    else if(dialogid == 503)
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
				    {
				        new playa = mechanikid[playerid];
	                    new pojazd = GetPlayerVehicleID(playa);
	                    new sendername[MAX_PLAYER_NAME];
	                    new giveplayer[MAX_PLAYER_NAME];
	                    new string[256];

						GetPlayerName(playerid, sendername, sizeof(sendername));
	   					GetPlayerName(playa, giveplayer, sizeof(giveplayer));
						format(string, sizeof(string), "* Zamontowa�e� nowe zderzaki graczowi %s (koszt -10 000$)",giveplayer);
		    			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	      				format(string, sizeof(string), "* Mechanik %s zamontowa� ci w twoim %s nowe zderzaki",sendername, VehicleNames[GetVehicleModel(pojazd)-400]);
						SendClientMessage(playa, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string),"* Mechanik %s wyci�ga narz�dzia i montuje nowe zderzaki w %s.", sendername, VehicleNames[GetVehicleModel(pojazd)-400]);
						ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						DajKase(playerid, -10000);
						format(string, sizeof(string), "~r~-$%d", 10000);
						GameTextForPlayer(playerid, string, 5000, 1);
	     				PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		    			AddVehicleComponent(pojazd,1117);//zderzak
                        CarData[VehicleUID[pojazd][vUID]][c_Bumper][0] = 1117;
                        Car_Save(VehicleUID[pojazd][vUID], CAR_SAVE_TUNE);
				    }
				}
			}
        }
	    else if(dialogid == 876)
	    {
			if(response)
			{
			    new string[64], sendername[MAX_PLAYER_NAME];
            	GetPlayerName(playerid, sendername, sizeof(sendername));
			    switch(listitem)
			    {
			        case 0:
			        {
			            if(PlayerInfo[playerid][pGun0] == 0) return sendErrorMessage(playerid, "Nie masz broni pod tym slotem!");
						PlayerInfo[playerid][pGun0] = 0;
						PlayerInfo[playerid][pAmmo0] = 0;
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Tw�j kastet zosta� usuni�ty");
						ResetPlayerWeapons(playerid);
						SetTimerEx("UsuwanieBroniReset", 1000, 0, "d", playerid);
						
            			format(string, sizeof(string),"%s niszczy kastet i rzuca na ziemi�.", sendername);
            			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
            			
						ShowPlayerDialogEx(playerid, 876, DIALOG_STYLE_LIST, "Usuwanie broni", "Kastet\nBro� bia�a\nPistolet\nStrzelba\nPistolet maszynowy\nKarabin\nSnajperka\nOgniomiotacz\nC4\nAparat/Sprej\nKwiaty/Laska/Dildo\nSpadochron\nDetonator", "Usu�", "Wyjd�");
			        }
			        case 1:
			        {
			            if(PlayerInfo[playerid][pGun1] == 0) return sendErrorMessage(playerid, "Nie masz broni pod tym slotem!");
			            PlayerInfo[playerid][pGun1] = 0;
						PlayerInfo[playerid][pAmmo1] = 0;
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Twoja bro� bia�a zosta�a usni�ta");
						ResetPlayerWeapons(playerid);
						SetTimerEx("UsuwanieBroniReset", 1000, 0, "d", playerid);
						
						format(string, sizeof(string),"%s niszczy bro� bia�� i rzuca na ziemi�.", sendername);
            			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						ShowPlayerDialogEx(playerid, 876, DIALOG_STYLE_LIST, "Usuwanie broni", "Kastet\nBro� bia�a\nPistolet\nStrzelba\nPistolet maszynowy\nKarabin\nSnajperka\nOgniomiotacz\nC4\nAparat/Sprej\nKwiaty/Laska/Dildo\nSpadochron\nDetonator", "Usu�", "Wyjd�");
			        }
			        case 2:
			        {
			            if(PlayerInfo[playerid][pGun2] == 0) return sendErrorMessage(playerid, "Nie masz broni pod tym slotem!");
			            PlayerInfo[playerid][pGun2] = 0;
						PlayerInfo[playerid][pAmmo2] = 0;
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Tw�j pistolet zosta� usuni�ty");
						ResetPlayerWeapons(playerid);
						SetTimerEx("UsuwanieBroniReset", 1000, 0, "d", playerid);
						
						format(string, sizeof(string),"%s niszczy pistolet i rzuca na ziemi�.", sendername);
            			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						ShowPlayerDialogEx(playerid, 876, DIALOG_STYLE_LIST, "Usuwanie broni", "Kastet\nBro� bia�a\nPistolet\nStrzelba\nPistolet maszynowy\nKarabin\nSnajperka\nOgniomiotacz\nC4\nAparat/Sprej\nKwiaty/Laska/Dildo\nSpadochron\nDetonator", "Usu�", "Wyjd�");
			        }
			        case 3:
			        {
			            if(PlayerInfo[playerid][pGun3] == 0) return sendErrorMessage(playerid, "Nie masz broni pod tym slotem!");
	                    PlayerInfo[playerid][pGun3] = 0;
						PlayerInfo[playerid][pAmmo3] = 0;
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Twoja strzelba zosta�a usuni�ta");
						ResetPlayerWeapons(playerid);
						SetTimerEx("UsuwanieBroniReset", 1000, 0, "d", playerid);
						
						format(string, sizeof(string),"%s niszczy strzelb� i rzuca na ziemi�.", sendername);
            			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						ShowPlayerDialogEx(playerid, 876, DIALOG_STYLE_LIST, "Usuwanie broni", "Kastet\nBro� bia�a\nPistolet\nStrzelba\nPistolet maszynowy\nKarabin\nSnajperka\nOgniomiotacz\nC4\nAparat/Sprej\nKwiaty/Laska/Dildo\nSpadochron\nDetonator", "Usu�", "Wyjd�");
			        }
			        case 4:
			        {
			            if(PlayerInfo[playerid][pGun4] == 0) return sendErrorMessage(playerid, "Nie masz broni pod tym slotem!");
	                    PlayerInfo[playerid][pGun4] = 0;
						PlayerInfo[playerid][pAmmo4] = 0;
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Tw�j pistolet maszynowy zosta� usuni�ty");
						ResetPlayerWeapons(playerid);
						SetTimerEx("UsuwanieBroniReset", 1000, 0, "d", playerid);
						
						format(string, sizeof(string),"%s niszczy pistolet maszynowy i rzuca na ziemi�.", sendername);
            			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						ShowPlayerDialogEx(playerid, 876, DIALOG_STYLE_LIST, "Usuwanie broni", "Kastet\nBro� bia�a\nPistolet\nStrzelba\nPistolet maszynowy\nKarabin\nSnajperka\nOgniomiotacz\nC4\nAparat/Sprej\nKwiaty/Laska/Dildo\nSpadochron\nDetonator", "Usu�", "Wyjd�");
			        }
			        case 5:
			        {
			            if(PlayerInfo[playerid][pGun5] == 0) return sendErrorMessage(playerid, "Nie masz broni pod tym slotem!");
			            PlayerInfo[playerid][pGun5] = 0;
						PlayerInfo[playerid][pAmmo5] = 0;
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Tw�j karabin maszynowy zosta� usuni�ty");
						ResetPlayerWeapons(playerid);
						SetTimerEx("UsuwanieBroniReset", 1000, 0, "d", playerid);
						
						format(string, sizeof(string),"%s niszczy karabin maszynowy i rzuca na ziemi�.", sendername);
            			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						ShowPlayerDialogEx(playerid, 876, DIALOG_STYLE_LIST, "Usuwanie broni", "Kastet\nBro� bia�a\nPistolet\nStrzelba\nPistolet maszynowy\nKarabin\nSnajperka\nOgniomiotacz\nC4\nAparat/Sprej\nKwiaty/Laska/Dildo\nSpadochron\nDetonator", "Usu�", "Wyjd�");
			        }
			        case 6:
			        {
			            if(PlayerInfo[playerid][pGun6] == 0) return sendErrorMessage(playerid, "Nie masz broni pod tym slotem!");
			            PlayerInfo[playerid][pGun6] = 0;
						PlayerInfo[playerid][pAmmo6] = 0;
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Twoja snajperka zosta�a usuni�ta");
						ResetPlayerWeapons(playerid);
						SetTimerEx("UsuwanieBroniReset", 1000, 0, "d", playerid);
						
						format(string, sizeof(string),"%s niszczy snajperk� i rzuca na ziemi�.", sendername);
            			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						ShowPlayerDialogEx(playerid, 876, DIALOG_STYLE_LIST, "Usuwanie broni", "Kastet\nBro� bia�a\nPistolet\nStrzelba\nPistolet maszynowy\nKarabin\nSnajperka\nOgniomiotacz\nC4\nAparat/Sprej\nKwiaty/Laska/Dildo\nSpadochron\nDetonator", "Usu�", "Wyjd�");
			        }
			        case 7:
			        {
			            if(PlayerInfo[playerid][pGun7] == 0) return sendErrorMessage(playerid, "Nie masz broni pod tym slotem!");
			            PlayerInfo[playerid][pGun7] = 0;
						PlayerInfo[playerid][pAmmo7] = 0;
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Tw�j ogniomiotacz zosta� usuni�ty");
						ResetPlayerWeapons(playerid);
						SetTimerEx("UsuwanieBroniReset", 1000, 0, "d", playerid);
						
						format(string, sizeof(string),"%s niszczy ogniomiotacz i rzuca na ziemi�.", sendername);
            			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						ShowPlayerDialogEx(playerid, 876, DIALOG_STYLE_LIST, "Usuwanie broni", "Kastet\nBro� bia�a\nPistolet\nStrzelba\nPistolet maszynowy\nKarabin\nSnajperka\nOgniomiotacz\nC4\nAparat/Sprej\nKwiaty/Laska/Dildo\nSpadochron\nDetonator", "Usu�", "Wyjd�");
			        }
			        case 8:
			        {
			            if(PlayerInfo[playerid][pGun8] == 0) return sendErrorMessage(playerid, "Nie masz broni pod tym slotem!");
			            PlayerInfo[playerid][pGun8] = 0;
						PlayerInfo[playerid][pAmmo8] = 0;
						PlayerInfo[playerid][pGun12] = 0;
						PlayerInfo[playerid][pAmmo12] = 0;
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Twoje C4 zosta�o usuni�te");
						ResetPlayerWeapons(playerid);
						SetTimerEx("UsuwanieBroniReset", 1000, 0, "d", playerid);
						
						format(string, sizeof(string),"%s niszczy C4 i rzuca na ziemi�.", sendername);
            			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						ShowPlayerDialogEx(playerid, 876, DIALOG_STYLE_LIST, "Usuwanie broni", "Kastet\nBro� bia�a\nPistolet\nStrzelba\nPistolet maszynowy\nKarabin\nSnajperka\nOgniomiotacz\nC4\nAparat/Sprej\nKwiaty/Laska/Dildo\nSpadochron\nDetonator", "Usu�", "Wyjd�");
			        }
			        case 9:
			        {
			            if(PlayerInfo[playerid][pGun9] == 0) return sendErrorMessage(playerid, "Nie masz broni pod tym slotem!");
			            PlayerInfo[playerid][pGun9] = 0;
						PlayerInfo[playerid][pAmmo9] = 0;
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Tw�j sprej/aparat/ga�nica zosta� usuni�ty");
						ResetPlayerWeapons(playerid);
						SetTimerEx("UsuwanieBroniReset", 1000, 0, "d", playerid);
						
						format(string, sizeof(string),"%s niszczy spray/aparat/ga�nic� i rzuca na ziemi�.", sendername);
            			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						ShowPlayerDialogEx(playerid, 876, DIALOG_STYLE_LIST, "Usuwanie broni", "Kastet\nBro� bia�a\nPistolet\nStrzelba\nPistolet maszynowy\nKarabin\nSnajperka\nOgniomiotacz\nC4\nAparat/Sprej\nKwiaty/Laska/Dildo\nSpadochron\nDetonator", "Usu�", "Wyjd�");
			        }
			        case 10:
			        {
			            if(PlayerInfo[playerid][pGun10] == 0) return sendErrorMessage(playerid, "Nie masz broni pod tym slotem!");
			            PlayerInfo[playerid][pGun10] = 0;
						PlayerInfo[playerid][pAmmo10] = 0;
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Twoje kwiaty/laska/dildo zosta�o usuni�te");
						ResetPlayerWeapons(playerid);
						SetTimerEx("UsuwanieBroniReset", 1000, 0, "d", playerid);
						
						format(string, sizeof(string),"%s niszczy kwiaty/lask�/dildo i rzuca na ziemi�.", sendername);
            			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						ShowPlayerDialogEx(playerid, 876, DIALOG_STYLE_LIST, "Usuwanie broni", "Kastet\nBro� bia�a\nPistolet\nStrzelba\nPistolet maszynowy\nKarabin\nSnajperka\nOgniomiotacz\nC4\nAparat/Sprej\nKwiaty/Laska/Dildo\nSpadochron\nDetonator", "Usu�", "Wyjd�");
			        }
			        case 11:
			        {
			            if(PlayerInfo[playerid][pGun11] == 0) return sendErrorMessage(playerid, "Nie masz broni pod tym slotem!");
			            PlayerInfo[playerid][pGun11] = 0;
						PlayerInfo[playerid][pAmmo11] = 0;
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Tw�j spadochron zosta� usuni�ty");
						ResetPlayerWeapons(playerid);
						SetTimerEx("UsuwanieBroniReset", 1000, 0, "d", playerid);
						
						format(string, sizeof(string),"%s niszczy spadochron i rzuca na ziemi�.", sendername);
            			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						ShowPlayerDialogEx(playerid, 876, DIALOG_STYLE_LIST, "Usuwanie broni", "Kastet\nBro� bia�a\nPistolet\nStrzelba\nPistolet maszynowy\nKarabin\nSnajperka\nOgniomiotacz\nC4\nAparat/Sprej\nKwiaty/Laska/Dildo\nSpadochron\nDetonator", "Usu�", "Wyjd�");
			        }
			        case 12:
			        {
			            if(PlayerInfo[playerid][pGun12] == 0) return sendErrorMessage(playerid, "Nie masz broni pod tym slotem!");
			            PlayerInfo[playerid][pGun12] = 0;
						PlayerInfo[playerid][pAmmo12] = 0;
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Tw�j detonator zosta� usuni�ty");
						ResetPlayerWeapons(playerid);
						SetTimerEx("UsuwanieBroniReset", 1000, 0, "d", playerid);
						
						format(string, sizeof(string),"%s niszczy detonator i rzuca na ziemi�.", sendername);
            			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						ShowPlayerDialogEx(playerid, 876, DIALOG_STYLE_LIST, "Usuwanie broni", "Kastet\nBro� bia�a\nPistolet\nStrzelba\nPistolet maszynowy\nKarabin\nSnajperka\nOgniomiotacz\nC4\nAparat/Sprej\nKwiaty/Laska/Dildo\nSpadochron\nDetonator", "Usu�", "Wyjd�");
			        }
			    }
			}
	    }
	    else if(dialogid == 80)
		{
		    if(response)
		 	{
		 	    switch(listitem)
		 	    {
		 	        case 0:
					{
	        			ShowPlayerDialogEx(playerid, 800, DIALOG_STYLE_LIST, "Gun Shop - Pistolety", "Pistolety 9mm\t\t 2000$\nPistolet z t�umikiem\t 1000$\nDesert Eagle\t\t 6000$", "Kup", "Wr��");
					}
					case 1:
					{
					    ShowPlayerDialogEx(playerid, 801, DIALOG_STYLE_LIST, "Gun Shop - Strzelby", "Shotgun\t\t6000$", "Kup", "Wr��");
					}
					case 2:
					{
					    ShowPlayerDialogEx(playerid, 802, DIALOG_STYLE_LIST, "Gun Shop - Pistolety Maszynowe", "MP5\t\t\t5000$", "Kup", "Wr��");
					}
					case 3:
					{
					    ShowPlayerDialogEx(playerid, 803, DIALOG_STYLE_LIST, "Gun Shop - Karabiny", "M4\t\t\t10000$\nAK-47\t\t\t10000$", "Kup", "Wr��");
					}
					case 4:
					{
					    ShowPlayerDialogEx(playerid, 804, DIALOG_STYLE_LIST, "Gun Shop - Snajperki", "Rifle\t\t2000$", "Kup", "Wr��");
					}
					case 5:
					{
					    ShowPlayerDialogEx(playerid, 805, DIALOG_STYLE_LIST, "Gun Shop - Bro� bia�a", "Kij golfowy\t\t400$\nPa�ka PD\t\t300$\nBasseball\t\t700$\n�opata\t\t\t300$\nKij bilardowy\t\t100$\nKwiaty\t\t\t200$\nLaska\t\t\t600$\nKastet\t\t\t50$", "Kup", "Wr��");
					}
					case 6:
					{
					    ShowPlayerDialogEx(playerid, 806, DIALOG_STYLE_LIST, "Gun Shop - Inne", "Spadochron\t\t500$", "Kup", "Wr��");
					}
					/*case 7:
					{
					    if(kaska[playerid] > 5000)
					    {
						    SetPlayerArmour(playerid, 90);
							SetPlayerHealth(playerid, 100);
							DajKase(playerid, -5000);
							SendClientMessage(playerid, COLOR_WHITE, " **Zaplaciles 5000$ za kamizelke i �ycie");
						}
						else
						{
						    SendClientMessage(playerid, COLOR_WHITE, "Nie masz na to pieni�dzy !");
						    ShowPlayerDialogEx(playerid, 80, DIALOG_STYLE_LIST, "Gun Shop", "Pistolety\t\t>>\nStrzelby\t\t>>\nPistolety Maszynowe\t>>\nKarabiny\t\t>>\nSnajperki\t\t>>\nBro� bia�a\t\t>>\nInne\t\t\t>>\n", "Wybierz", "Wyjd�");
						}
					}*/
				}
			}
		}
		else if(dialogid == 81)
		{
		    if(response)
			{
		    	switch(listitem)
				{
	       			case 0:
			 		{
	        			if(kaska[playerid] > 25000)
						{
					        GivePlayerWeapon(playerid, 10, 1);
					        PlayerInfo[playerid][pGun10] = 10;
							PlayerInfo[playerid][pAmmo10] = 1;
							DajKase(playerid, -25000);
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kupi�e� wibrator 'Purpurowy Big Jim' za 25 000$");
						}
		    			else
					    {
	    					SendClientMessage(playerid, COLOR_GREY, "Nie sta� ci� na to!");
						}
					}
					case 1:
					{
	        			if(kaska[playerid] > 7500)
	  	 				{
					        GivePlayerWeapon(playerid, 11, 1);
					        PlayerInfo[playerid][pGun10] = 11;
							PlayerInfo[playerid][pAmmo10] = 1;
							DajKase(playerid, -7500);
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kupi�e� wibrator 'Analny Penetrator' za 7500$");
						}
		    			else
					    {
	        				SendClientMessage(playerid, COLOR_GREY, "Nie sta� ci� na to!");
						}
					}
					case 2:
					{
	        			if(kaska[playerid] > 20000)
						{
					        GivePlayerWeapon(playerid, 12, 1);
					        PlayerInfo[playerid][pGun10] = 12;
							PlayerInfo[playerid][pAmmo10] = 1;
							DajKase(playerid, -20000);
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kupi�e� wibrator 'Bia�y Intruz' za 20 000$");
						}
		    			else
					    {
	        				SendClientMessage(playerid, COLOR_GREY, "Nie sta� ci� na to!");
						}
					}
					case 3:
					{
	        			if(kaska[playerid] > 12000)
		  	 			{
					        GivePlayerWeapon(playerid, 13, 1);
					        PlayerInfo[playerid][pGun10] = 13;
							PlayerInfo[playerid][pAmmo10] = 1;
							DajKase(playerid, -12000);
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kupi�e� wibrator 'Srebrny Masturbator' za 12 000$");
						}
		    			else
					    {
	        				SendClientMessage(playerid, COLOR_GREY, "Nie sta� ci� na to!");
						}
					}
					case 4:
					{
	        			if(kaska[playerid] > 1500)
		  	 			{
					        GivePlayerWeapon(playerid, 15, 1);
					        PlayerInfo[playerid][pGun10] = 15;
							PlayerInfo[playerid][pAmmo10] = 1;
							DajKase(playerid, -1500);
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, "Lask� sado-maso za 1500$");
						}
		    			else
					    {
	        				SendClientMessage(playerid, COLOR_GREY, "Nie sta� ci� na to!");
						}
					}
					case 5:
					{
	        			if(kaska[playerid] > 500)
		  	 			{
					        GivePlayerWeapon(playerid, 14, 1);
					        PlayerInfo[playerid][pGun10] = 14;
							PlayerInfo[playerid][pAmmo10] = 1;
							DajKase(playerid, -500);
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kupi�e� kwiaty za 500$");
						}
		    			else
					    {
	        				SendClientMessage(playerid, COLOR_GREY, "Nie sta� ci� na to!");
						}
					}
					case 6:
					{
	        			if(kaska[playerid] > 50)
		  	 			{
							Condom[playerid] ++;
							PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
							DajKase(playerid, -50);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kupi�e� paczk� prezerwatyw za 50$");
						}
						else
		    			{
	        				SendClientMessage(playerid, COLOR_GREY, "Nie sta� ci� na to!");
						}
					}
				}
			}
		}
		else if(dialogid == 7371)
		{
		    if(response)
			{
	      		if(kaska[playerid] > (GunPrice[22][0])+(CenaBroni[playerid]*40))
			    {
	          		new komunikat[256];
			        GivePlayerWeapon(playerid, 30, CenaBroni[playerid]);
			        PlayerInfo[playerid][pGun5] = 30;
					PlayerInfo[playerid][pAmmo5] = CenaBroni[playerid];
					DajKase(playerid, -(GunPrice[22][0]));
					DajKase(playerid, -(CenaBroni[playerid]*40));
					format(komunikat, sizeof(komunikat), "Kupi�e� AK-47 z %d nabojami , kosztowa�o ci� to %d", CenaBroni[playerid],(GunPrice[22][0])+(CenaBroni[playerid]*40));
					SendClientMessage(playerid, COLOR_LIGHTBLUE, komunikat);
			    }
			    else
			    {
			        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci� na to!");
			        ShowPlayerDialogEx(playerid, 731, DIALOG_STYLE_INPUT, "Gun Shop - AK-47", "Wpisz ilo�� naboi(1 nab�j = 40$)", "Kup", "Wr��");
			    }
			}
			if(!response)
			{
	            ShowPlayerDialogEx(playerid, 731, DIALOG_STYLE_INPUT, "Gun Shop - AK-47", "Wpisz ilo�� naboi(1 nab�j = 40$)", "Kup", "Wr��");
			}
		}
		else if(dialogid == 800)
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0:
		            {
		                ShowPlayerDialogEx(playerid, 700, DIALOG_STYLE_INPUT, "Gun Shop - Pistolet 9mm", "Wpisz ilo�� naboi(1 nab�j = 25$)", "Kup", "Wr��");
					}
					case 1:
		            {
		                ShowPlayerDialogEx(playerid, 701, DIALOG_STYLE_INPUT, "Gun Shop - Pistolet z t�umikiem", "Wpisz ilo�� naboi(1 nab�j = 25$)", "Kup", "Wr��");
					}
					case 2:
		            {
		                ShowPlayerDialogEx(playerid, 702, DIALOG_STYLE_INPUT, "Gun Shop - Desert Eagle", "Wpisz ilo�� naboi(1 nab�j = 25$)", "Kup", "Wr��");
					}
				}
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 80, DIALOG_STYLE_LIST, "Gun Shop", "Pistolety\t\t>>\nStrzelby\t\t>>\nPistolety Maszynowe\t>>\nKarabiny\t\t>>\nSnajperki\t\t>>\nBro� bia�a\t\t>>\nInne\t\t\t>>\n", "Wybierz", "Wyjd�");
			}
		}
		else if(dialogid == 801)
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0:
		            {
		                ShowPlayerDialogEx(playerid, 710, DIALOG_STYLE_INPUT, "Gun Shop - Shotgun", "Wpisz ilo�� naboi(1 nab�j = 40$)", "Kup", "Wr��");
					}
				}
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 80, DIALOG_STYLE_LIST, "Gun Shop", "Pistolety\t\t>>\nStrzelby\t\t>>\nPistolety Maszynowe\t>>\nKarabiny\t\t>>\nSnajperki\t\t>>\nBro� bia�a\t\t>>\nInne\t\t\t>>\n", "Wybierz", "Wyjd�");
			}
		}
		else if(dialogid == 802)
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0:
		            {
		                ShowPlayerDialogEx(playerid, 720, DIALOG_STYLE_INPUT, "Gun Shop - MP5", "Wpisz ilo�� naboi(1 nab�j = 25$)", "Kup", "Wr��");
					}
				}
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 80, DIALOG_STYLE_LIST, "Gun Shop", "Pistolety\t\t>>\nStrzelby\t\t>>\nPistolety Maszynowe\t>>\nKarabiny\t\t>>\nSnajperki\t\t>>\nBro� bia�a\t\t>>\nInne\t\t\t>>\n", "Wybierz", "Wyjd�");
			}
		}
		else if(dialogid == 803)
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0:
		            {
		                ShowPlayerDialogEx(playerid, 730, DIALOG_STYLE_INPUT, "Gun Shop - M4", "Wpisz ilo�� naboi(1 nab�j = 40$)", "Kup", "Wr��");
					}
					case 1:
		            {
		                ShowPlayerDialogEx(playerid, 731, DIALOG_STYLE_INPUT, "Gun Shop - AK-47", "Wpisz ilo�� naboi(1 nab�j = 40$)", "Kup", "Wr��");
					}
				}
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 80, DIALOG_STYLE_LIST, "Gun Shop", "Pistolety\t\t>>\nStrzelby\t\t>>\nPistolety Maszynowe\t>>\nKarabiny\t\t>>\nSnajperki\t\t>>\nBro� bia�a\t\t>>\nInne\t\t\t>>\n", "Wybierz", "Wyjd�");
			}
		}
		else if(dialogid == 804)
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0:
		            {
		                ShowPlayerDialogEx(playerid, 740, DIALOG_STYLE_INPUT, "Gun Shop - Rifle", "Wpisz ilo�� naboi(1 nab�j = 50$)", "Kup", "Wr��");
					}
				}
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 80, DIALOG_STYLE_LIST, "Gun Shop", "Pistolety\t\t>>\nStrzelby\t\t>>\nPistolety Maszynowe\t>>\nKarabiny\t\t>>\nSnajperki\t\t>>\nBro� bia�a\t\t>>\nInne\t\t\t>>\n", "Wybierz", "Wyjd�");
			}
		}
		else if(dialogid == 805)
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0:
		            {
		                if(kaska[playerid] > 400)
		                {
	                     	GivePlayerWeapon(playerid, 2, 1);
	                     	PlayerInfo[playerid][pGun1] = 2;
	                     	PlayerInfo[playerid][pAmmo1] = 1;
	                     	DajKase(playerid, -400);
		                	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kupi�e� kij golfowy za 400$");
		                }
		                else
		                {
		                    SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci�!");
		                }
		            }
		            case 1:
		            {
		                if(kaska[playerid] > 300)
		                {
	                     	GivePlayerWeapon(playerid, 3, 1);
	                     	PlayerInfo[playerid][pGun1] = 3;
	                     	PlayerInfo[playerid][pAmmo1] = 1;
	                     	DajKase(playerid, -300);
		                	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kupi�e� pa�k� PD za 300$");
		                }
		                else
		                {
		                    SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci�!");
		                }
		            }
		            case 2:
		            {
		                if(kaska[playerid] > 700)
		                {
	                     	GivePlayerWeapon(playerid, 5, 1);
	                     	PlayerInfo[playerid][pGun1] = 5;
	                     	PlayerInfo[playerid][pAmmo1] = 1;
	                     	DajKase(playerid, -700);
		                	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kupi�e� bejzbola za 700$");
		                }
		                else
		                {
		                    SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci�!");
		                }
		            }
		            case 3:
		            {
		                if(kaska[playerid] > 300)
		                {
	                     	GivePlayerWeapon(playerid, 6, 1);
	                     	PlayerInfo[playerid][pGun1] = 6;
	                     	PlayerInfo[playerid][pAmmo1] = 1;
	                     	DajKase(playerid, -300);
		                	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kupi�e� �opat� za 300$");
		                }
		                else
		                {
		                    SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci�!");
		                }
		            }
		            case 4:
		            {
		                if(kaska[playerid] > 100)
		                {
	                     	GivePlayerWeapon(playerid, 7, 1);
	                     	PlayerInfo[playerid][pGun1] = 7;
	                     	PlayerInfo[playerid][pAmmo1] = 1;
	                     	DajKase(playerid, -100);
		                	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kupi�e� kij bilardowy za 100$");
		                }
		                else
		                {
		                    SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci�!");
		                }
		            }
		            case 5:
		            {
		                if(kaska[playerid] > 200)
		                {
	                     	GivePlayerWeapon(playerid, 14, 1);
	                     	PlayerInfo[playerid][pGun10] = 14;
	                     	PlayerInfo[playerid][pAmmo10] = 1;
	                     	DajKase(playerid, -200);
		                	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kupi�e� kwiaty za 200$");
		                }
		                else
		                {
		                    SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci�!");
		                }
		            }
		            case 6:
		            {
		                if(kaska[playerid] > 600)
		                {
	                     	GivePlayerWeapon(playerid, 15, 1);
	                     	PlayerInfo[playerid][pGun10] = 15;
	                     	PlayerInfo[playerid][pAmmo10] = 1;
	                     	DajKase(playerid, -600);
		                	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kupi�e� laska za 600$");
		                }
		                else
		                {
		                    SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci�!");
		                }
		            }
		            case 7:
		            {
		                if(kaska[playerid] > 50)
		                {
	                     	GivePlayerWeapon(playerid, 1, 1);
	                     	PlayerInfo[playerid][pGun0] = 1;
	                     	PlayerInfo[playerid][pAmmo0] = 1;
	                     	DajKase(playerid, -50);
		                	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kupi�e� kastet za 50$");
		                }
		                else
		                {
		                    SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci�!");
		                }
		            }
		        }
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 80, DIALOG_STYLE_LIST, "Gun Shop", "Pistolety\t\t>>\nStrzelby\t\t>>\nPistolety Maszynowe\t>>\nKarabiny\t\t>>\nSnajperki\t\t>>\nBro� bia�a\t\t>>\nInne\t\t\t>>\n", "Wybierz", "Wyjd�");
			}
		}
		else if(dialogid == 806)
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0:
		            {
		                if(kaska[playerid] > 500)
		                {
	                     	GivePlayerWeapon(playerid, 46, 1);
	                     	PlayerInfo[playerid][pGun11] = 46;
	                     	PlayerInfo[playerid][pAmmo11] = 1;
	                     	DajKase(playerid, -500);
		                	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kupi�e� spadochron za 500$");
		                }
		                else
		                {
		                    SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci�!");
		                }
					}
				}
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 80, DIALOG_STYLE_LIST, "Gun Shop", "Pistolety\t\t>>\nStrzelby\t\t>>\nPistolety Maszynowe\t>>\nKarabiny\t\t>>\nSnajperki\t\t>>\nBro� bia�a\t\t>>\nInne\t\t\t>>\n", "Wybierz", "Wyjd�");
			}
		}
		else if(dialogid == 700)
		{
		    if(response)
		    {
		        if(strlen(inputtext) < 6 && strval(inputtext) > 0)
		        {
				    new komunikat[256];
				    new naboje = strval(inputtext);
				    new cena = (naboje*25)+(2000);
				    CenaBroni[playerid] = naboje;
				    format(komunikat, sizeof(komunikat), "Kupujesz Pistolety 9mm z %d nabojami\nB�dzie ci� to kosztowa� %d$\n Czy chcesz dokona� zakupu?", naboje, cena);
			     	ShowPlayerDialogEx(playerid, 7070, DIALOG_STYLE_MSGBOX, "Kupowanie Pistolet�w 9mm", komunikat, "Tak", "Nie");
				}
				else
				{
				    SendClientMessage(playerid, COLOR_WHITE, "*** Max 100 000 naboi ***");
				}
			}
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 800, DIALOG_STYLE_LIST, "Gun Shop - Pistolety", "Pistolety 9mm\t\t 1000$\nPistolet z t�umikiem\t 500$\nDesert Eagle\t\t 3000$", "Kup", "Wr��");
		    }
		}
		else if(dialogid == 701)
		{
		    if(response)
			{
			    if(strlen(inputtext) < 6 && strval(inputtext) > 0)
		        {
				    new komunikat[256];
				    new naboje = strval(inputtext);
				    new cena = (naboje*25)+(1000);
				    CenaBroni[playerid] = naboje;
				    format(komunikat, sizeof(komunikat), "Kupujesz Pistolet z t�umikiem z %d nabojami\nB�dzie ci� to kosztowa� %d$\n Czy chcesz dokona� zakupu?", naboje, cena);
			     	ShowPlayerDialogEx(playerid, 7071, DIALOG_STYLE_MSGBOX, "Kupowanie Pistoletu z t�umikiem", komunikat, "Tak", "Nie");
	            }
				else
				{
				    SendClientMessage(playerid, COLOR_WHITE, "*** Max 100 000 naboi ***");
				}
			}
			if(!response)
			{
			    ShowPlayerDialogEx(playerid, 800, DIALOG_STYLE_LIST, "Gun Shop - Pistolety", "Pistolety 9mm\t\t 1000$\nPistolet z t�umikiem\t 500$\nDesert Eagle\t\t 3000$", "Kup", "Wr��");
			}
		}
		else if(dialogid == 702)
		{
		    if(response)
			{
			    if(strlen(inputtext) < 6 && strval(inputtext) > 0)
		        {
				    new komunikat[256];
				    new naboje = strval(inputtext);
				    new cena = (naboje*25)+(6000);
				    CenaBroni[playerid] = naboje;
				    format(komunikat, sizeof(komunikat), "Kupujesz Desert Eagle z %d nabojami\nB�dzie ci� to kosztowa� %d$\n Czy chcesz dokona� zakupu?", naboje, cena);
			     	ShowPlayerDialogEx(playerid, 7072, DIALOG_STYLE_MSGBOX, "Kupowanie Desert Eagle", komunikat, "Tak", "Nie");
	            }
				else
				{
				    SendClientMessage(playerid, COLOR_WHITE, "*** Max 100 000 naboi ***");
				}
			}
			if(!response)
			{
			    ShowPlayerDialogEx(playerid, 800, DIALOG_STYLE_LIST, "Gun Shop - Pistolety", "Pistolety 9mm\t\t 2000$\nPistolet z t�umikiem\t 1000$\nDesert Eagle\t\t 6000$", "Kup", "Wr��");
			}
		}
		else if(dialogid == 710)
		{
		    if(response)
			{
			    if(strlen(inputtext) < 6 && strval(inputtext) > 0)
		        {
				    new komunikat[256];
				    new naboje = strval(inputtext);
				    new cena = (naboje*40)+(3000);
				    CenaBroni[playerid] = naboje;
				    format(komunikat, sizeof(komunikat), "Kupujesz Shotgun z %d nabojami\nB�dzie ci� to kosztowa� %d$\n Czy chcesz dokona� zakupu?", naboje, cena);
			     	ShowPlayerDialogEx(playerid, 7170, DIALOG_STYLE_MSGBOX, "Kupowanie Shotguna", komunikat, "Tak", "Nie");
	            }
				else
				{
				    SendClientMessage(playerid, COLOR_WHITE, "*** Max 100 000 naboi ***");
				}
			}
			if(!response)
			{
			    ShowPlayerDialogEx(playerid, 801, DIALOG_STYLE_LIST, "Gun Shop - Strzelby", "Shotgun\t\t6000$", "Kup", "Wr��");
			}
		}
		else if(dialogid == 720)
		{
		    if(response)
			{
			    if(strlen(inputtext) < 6 && strval(inputtext) > 0)
		        {
				    new komunikat[256];
				    new naboje = strval(inputtext);
				    new cena = (naboje*25)+(5000);
				    CenaBroni[playerid] = naboje;
				    format(komunikat, sizeof(komunikat), "Kupujesz MP5 z %d nabojami\nB�dzie ci� to kosztowa� %d$\n Czy chcesz dokona� zakupu?", naboje, cena);
			     	ShowPlayerDialogEx(playerid, 7270, DIALOG_STYLE_MSGBOX, "Kupowanie MP5", komunikat, "Tak", "Nie");
	            }
				else
				{
				    SendClientMessage(playerid, COLOR_WHITE, "*** Max 100 000 naboi ***");
				}
			}
			if(!response)
			{
			    ShowPlayerDialogEx(playerid, 802, DIALOG_STYLE_LIST, "Gun Shop - Pistolety Maszynowe", "MP5\t\t\t5000$", "Kup", "Wr��");
			}
		}
		else if(dialogid == 730)
		{
		    if(response)
			{
			    if(strlen(inputtext) < 6 && strval(inputtext) > 0)
		        {
				    new komunikat[256];
				    new naboje = strval(inputtext);
				    new cena = (naboje*40)+(10000);
				    CenaBroni[playerid] = naboje;
				    format(komunikat, sizeof(komunikat), "Kupujesz M4 z %d nabojami\nB�dzie ci� to kosztowa� %d$\n Czy chcesz dokona� zakupu?", naboje, cena);
			     	ShowPlayerDialogEx(playerid, 7370, DIALOG_STYLE_MSGBOX, "Kupowanie M4", komunikat, "Tak", "Nie");
	            }
				else
				{
				    SendClientMessage(playerid, COLOR_WHITE, "*** Max 100 000 naboi ***");
				}
			}
			if(!response)
			{
			    ShowPlayerDialogEx(playerid, 803, DIALOG_STYLE_LIST, "Gun Shop - Karabiny", "M4\t\t\t10000$\nAK-47\t\t\t10000$", "Kup", "Wr��");
			}
		}
		else if(dialogid == 731)
		{
		    if(response)
			{
			    if(strlen(inputtext) < 6 && strval(inputtext) > 0)
		        {
				    new komunikat[256];
				    new naboje = strval(inputtext);
				    new cena = (naboje*40)+(10000);
				    CenaBroni[playerid] = naboje;
				    format(komunikat, sizeof(komunikat), "Kupujesz AK-47 z %d nabojami\nB�dzie ci� to kosztowa� %d$\n Czy chcesz dokona� zakupu?", naboje, cena);
			     	ShowPlayerDialogEx(playerid, 7371, DIALOG_STYLE_MSGBOX, "Kupowanie AK-47", komunikat, "Tak", "Nie");
	            }
				else
				{
				    SendClientMessage(playerid, COLOR_WHITE, "*** Max 100 000 naboi ***");
				}
			}
			if(!response)
			{
			    ShowPlayerDialogEx(playerid, 803, DIALOG_STYLE_LIST, "Gun Shop - Karabiny", "M4\t\t\t10000$\nAK-47\t\t\t10000$", "Kup", "Wr��");
			}
		}
		else if(dialogid == 740)
		{
		    if(response)
			{
			    if(strlen(inputtext) < 6 && strval(inputtext) > 0)
		        {
				    new komunikat[256];
				    new naboje = strval(inputtext);
				    new cena = (naboje*50)+(2000);
				    CenaBroni[playerid] = naboje;
				    format(komunikat, sizeof(komunikat), "Kupujesz Rifle z %d nabojami\nB�dzie ci� to kosztowa� %d$\n Czy chcesz dokona� zakupu?", naboje, cena);
			     	ShowPlayerDialogEx(playerid, 7470, DIALOG_STYLE_MSGBOX, "Kupowanie Rifle", komunikat, "Tak", "Nie");
	            }
				else
				{
				    SendClientMessage(playerid, COLOR_WHITE, "*** Max 100 000 naboi ***");
				}
			}
			if(!response)
			{
			    ShowPlayerDialogEx(playerid, 804, DIALOG_STYLE_LIST, "Gun Shop - Snajperki", "Rifle\t\t2000$", "Kup", "Wr��");
			}
		}
		else if(dialogid == 7070)
		{
		    if(response)
			{
			    if(kaska[playerid] > (GunPrice[13][0])+(CenaBroni[playerid]*25))
			    {
	          		new komunikat[256];
	          		//new cenabronia = (GunPrice[13][0])+(CenaBroni[playerid]*25);
			        GivePlayerWeapon(playerid, 22, CenaBroni[playerid]);
			        PlayerInfo[playerid][pGun2] = 22;
					PlayerInfo[playerid][pAmmo2] = CenaBroni[playerid];
					//DajKase(playerid, -cenabronia);
					ZabierzKase(playerid, (GunPrice[13][0]));
					ZabierzKase(playerid, (CenaBroni[playerid]*25));
					format(komunikat, sizeof(komunikat), "Kupi�e� Pistolety 9mm z %d nabojami, kosztowa�o ci� to %d", CenaBroni[playerid],(GunPrice[13][0])+(CenaBroni[playerid]*25));
					SendClientMessage(playerid, COLOR_LIGHTBLUE, komunikat);
			    }
			    else
			    {
			        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci� na to!");
			        ShowPlayerDialogEx(playerid, 700, DIALOG_STYLE_INPUT, "Gun Shop - Pistolet 9mm", "Wpisz ilo�� naboi(1 nab�j = 25$)", "Kup", "Wr��");
			    }
			}
			if(!response)
			{
			    ShowPlayerDialogEx(playerid, 700, DIALOG_STYLE_INPUT, "Gun Shop - Pistolet 9mm", "Wpisz ilo�� naboi(1 nab�j = 25$)", "Kup", "Wr��");
			}
		}
		else if(dialogid == 7071)
		{
		    if(response)
			{
	      		if(kaska[playerid] > (GunPrice[14][0])+(CenaBroni[playerid]*25))
			    {
	          		new komunikat[256];
			        GivePlayerWeapon(playerid, 23, CenaBroni[playerid]);
			        PlayerInfo[playerid][pGun2] = 23;
					PlayerInfo[playerid][pAmmo2] = CenaBroni[playerid];
	    			ZabierzKase(playerid, (GunPrice[14][0]));
					ZabierzKase(playerid, (CenaBroni[playerid]*25));
					format(komunikat, sizeof(komunikat), "Kupi�e� Pistolet z t�umikiem z %d nabojami , kosztowa�o ci� to %d", CenaBroni[playerid],(GunPrice[14][0])+(CenaBroni[playerid]*25));
					SendClientMessage(playerid, COLOR_LIGHTBLUE, komunikat);
			    }
			    else
			    {
			        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci� na to!");
			        ShowPlayerDialogEx(playerid, 701, DIALOG_STYLE_INPUT, "Gun Shop - Pistolet z t�umikiem", "Wpisz ilo�� naboi(1 nab�j = 25$)", "Kup", "Wr��");
			    }
			}
			if(!response)
			{
	            ShowPlayerDialogEx(playerid, 701, DIALOG_STYLE_INPUT, "Gun Shop - Pistolet z t�umikiem", "Wpisz ilo�� naboi(1 nab�j = 25$)", "Kup", "Wr��");
			}
		}
		else if(dialogid == 7072)
		{
		    if(response)
			{
	      		if(kaska[playerid] > (GunPrice[15][0])+(CenaBroni[playerid]*25))
			    {
	          		new komunikat[256];
			        GivePlayerWeapon(playerid, 24, CenaBroni[playerid]);
			        PlayerInfo[playerid][pGun2] = 24;
					PlayerInfo[playerid][pAmmo2] = CenaBroni[playerid];
	    			ZabierzKase(playerid, (GunPrice[15][0]));
	    			ZabierzKase(playerid, (CenaBroni[playerid]*25));
					format(komunikat, sizeof(komunikat), "Kupi�e� Desert Eagle z %d nabojami , kosztowa�o ci� to %d", CenaBroni[playerid],(GunPrice[15][0])+(CenaBroni[playerid]*25));
					SendClientMessage(playerid, COLOR_LIGHTBLUE, komunikat);
			    }
			    else
			    {
			        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci� na to!");
			        ShowPlayerDialogEx(playerid, 702, DIALOG_STYLE_INPUT, "Gun Shop - Desert Eagle", "Wpisz ilo�� naboi(1 nab�j = 25$)", "Kup", "Wr��");
			    }
			}
			if(!response)
			{
	            ShowPlayerDialogEx(playerid, 702, DIALOG_STYLE_INPUT, "Gun Shop - Desert Eagle", "Wpisz ilo�� naboi(1 nab�j = 25$)", "Kup", "Wr��");
			}
		}
		else if(dialogid == 7170)
		{
		    if(response)
			{
	      		if(kaska[playerid] > (GunPrice[19][0])+(CenaBroni[playerid]*40))
			    {
	          		new komunikat[256];
			        GivePlayerWeapon(playerid, 25, CenaBroni[playerid]);
			        PlayerInfo[playerid][pGun3] = 25;
					PlayerInfo[playerid][pAmmo3] = CenaBroni[playerid];
					ZabierzKase(playerid, (GunPrice[19][0]));
					ZabierzKase(playerid, (CenaBroni[playerid]*40));
					format(komunikat, sizeof(komunikat), "Kupi�e� Shotguna z %d nabojami , kosztowa�o ci� to %d", CenaBroni[playerid],(GunPrice[19][0])+(CenaBroni[playerid]*40));
					SendClientMessage(playerid, COLOR_LIGHTBLUE, komunikat);
			    }
			    else
			    {
			        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci� na to!");
			        ShowPlayerDialogEx(playerid, 710, DIALOG_STYLE_INPUT, "Gun Shop - Shotguna", "Wpisz ilo�� naboi(1 nab�j = 40$)", "Kup", "Wr��");
			    }
			}
			if(!response)
			{
	            ShowPlayerDialogEx(playerid, 710, DIALOG_STYLE_INPUT, "Gun Shop - Shotguna", "Wpisz ilo�� naboi(1 nab�j = 40$)", "Kup", "Wr��");
			}
		}
		else if(dialogid == 7270)
		{
		    if(response)
			{
	      		if(kaska[playerid] > (GunPrice[18][0])+(CenaBroni[playerid]*25))
			    {
	          		new komunikat[256];
			        GivePlayerWeapon(playerid, 29, CenaBroni[playerid]);
			        PlayerInfo[playerid][pGun4] = 29;
					PlayerInfo[playerid][pAmmo4] = CenaBroni[playerid];
					ZabierzKase(playerid, (GunPrice[18][0]));
					ZabierzKase(playerid, (CenaBroni[playerid]*25));
					format(komunikat, sizeof(komunikat), "Kupi�e� MP5 z %d nabojami , kosztowa�o ci� to %d", CenaBroni[playerid],(GunPrice[18][0])+(CenaBroni[playerid]*25));
					SendClientMessage(playerid, COLOR_LIGHTBLUE, komunikat);
			    }
			    else
			    {
			        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci� na to!");
			        ShowPlayerDialogEx(playerid, 720, DIALOG_STYLE_INPUT, "Gun Shop - MP5", "Wpisz ilo�� naboi(1 nab�j = 25$)", "Kup", "Wr��");
			    }
			}
			if(!response)
			{
	            ShowPlayerDialogEx(playerid, 720, DIALOG_STYLE_INPUT, "Gun Shop - MP5", "Wpisz ilo�� naboi(1 nab�j = 25$)", "Kup", "Wr��");
			}
		}
		else if(dialogid == 7370)
		{
		    if(response)
			{
	      		if(kaska[playerid] > (GunPrice[23][0])+(CenaBroni[playerid]*40))
			    {
	          		new komunikat[256];
			        GivePlayerWeapon(playerid, 31, CenaBroni[playerid]);
			        PlayerInfo[playerid][pGun5] = 31;
					PlayerInfo[playerid][pAmmo5] = CenaBroni[playerid];
					ZabierzKase(playerid, (GunPrice[23][0]));
					ZabierzKase(playerid, (CenaBroni[playerid]*40));
					format(komunikat, sizeof(komunikat), "Kupi�e� M4 z %d nabojami , kosztowa�o ci� to %d", CenaBroni[playerid],(GunPrice[23][0])+(CenaBroni[playerid]*40));
					SendClientMessage(playerid, COLOR_LIGHTBLUE, komunikat);
			    }
			    else
			    {
			        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci� na to!");
			        ShowPlayerDialogEx(playerid, 730, DIALOG_STYLE_INPUT, "Gun Shop - M4", "Wpisz ilo�� naboi(1 nab�j = 40$)", "Kup", "Wr��");
			    }
			}
			if(!response)
			{
	            ShowPlayerDialogEx(playerid, 730, DIALOG_STYLE_INPUT, "Gun Shop - M4", "Wpisz ilo�� naboi(1 nab�j = 40$)", "Kup", "Wr��");
			}
		}
		else if(dialogid == 7371)
		{
		    if(response)
			{
	      		if(kaska[playerid] > (GunPrice[22][0])+(CenaBroni[playerid]*40))
			    {
	          		new komunikat[256];
			        GivePlayerWeapon(playerid, 30, CenaBroni[playerid]);
			        PlayerInfo[playerid][pGun5] = 30;
					PlayerInfo[playerid][pAmmo5] = CenaBroni[playerid];
					ZabierzKase(playerid, (GunPrice[22][0]));
					ZabierzKase(playerid, (CenaBroni[playerid]*40));
					format(komunikat, sizeof(komunikat), "Kupi�e� AK-47 z %d nabojami , kosztowa�o ci� to %d", CenaBroni[playerid],(GunPrice[22][0])+(CenaBroni[playerid]*40));
					SendClientMessage(playerid, COLOR_LIGHTBLUE, komunikat);
			    }
			    else
			    {
			        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci� na to!");
			        ShowPlayerDialogEx(playerid, 731, DIALOG_STYLE_INPUT, "Gun Shop - AK-47", "Wpisz ilo�� naboi(1 nab�j = 40$)", "Kup", "Wr��");
			    }
			}
			if(!response)
			{
	            ShowPlayerDialogEx(playerid, 731, DIALOG_STYLE_INPUT, "Gun Shop - AK-47", "Wpisz ilo�� naboi(1 nab�j = 40$)", "Kup", "Wr��");
			}
		}
		else if(dialogid == 7470)
		{
		    if(response)
			{
	      		if(kaska[playerid] > (GunPrice[24][0])+(CenaBroni[playerid]*50))
			    {
	          		new komunikat[256];
			        GivePlayerWeapon(playerid, 33, CenaBroni[playerid]);
			        PlayerInfo[playerid][pGun6] = 33;
					PlayerInfo[playerid][pAmmo6] = CenaBroni[playerid];
					ZabierzKase(playerid, (GunPrice[24][0]));
					ZabierzKase(playerid, (CenaBroni[playerid]*50));
					format(komunikat, sizeof(komunikat), "Kupi�e� Rifle z %d nabojami , kosztowa�o ci� to %d", CenaBroni[playerid],(GunPrice[24][0])+(CenaBroni[playerid]*50));
					SendClientMessage(playerid, COLOR_LIGHTBLUE, komunikat);
			    }
			    else
			    {
			        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Nie sta� ci� na to!");
			        ShowPlayerDialogEx(playerid, 740, DIALOG_STYLE_INPUT, "Gun Shop - Rifle", "Wpisz ilo�� naboi(1 nab�j = 50$)", "Kup", "Wr��");
			    }
			}
			if(!response)
			{
	            ShowPlayerDialogEx(playerid, 740, DIALOG_STYLE_INPUT, "Gun Shop - Rifle", "Wpisz ilo�� naboi(1 nab�j = 50$)", "Kup", "Wr��");
			}
		}
	    else if(dialogid == 5000)
	    {
	        if(response)
	        {
		        switch(listitem)
				{
				    case 0:
					{
		        		ShowPlayerDialogEx(playerid,5001,DIALOG_STYLE_MSGBOX,"Linia 55","Przystanki ko�cowe:\nKo�ci� <==> Mrucznik Tower\n\nCzas przejazdu trasy: 9minut \n\nIlo�� przystank�w: 13\n\nSzczeg�owy rozpis trasy:\n Ko�ci�\n Motel Jefferson\n Glen Park\n Skate Park\n Unity Station\n Urz�d Miasta\n Bank\n Kasyno\n Market Station\n Baza San News i Restauracja\n Siedziba FBI\n Molo W�dkarskie\n Mrucznik Tower","Wr��","Wyjd�");
						//\n\nOpis:\n Wsiadaj�c do tego autobusu na pewno odwiedzisz\n ka�de miejsce naprawd� warte twojej uwagi\n Jednak z powodu du�ej liczby przystnak�w\n czas podr�y znacznie si� wyd�u�a.
					}
					case 1:
					{
					    ShowPlayerDialogEx(playerid,5001,DIALOG_STYLE_MSGBOX,"Linia 72","Przystanki ko�cowe:\nBaza Mechanik�w <==> Mrucznik Tower\n\nCzas przejazdu trasy: 3min 50s\n\nIlo�� przystank�w: 9\n\nSzczeg�owy rozpis trasy:\n Mrucznik Tower (praca prawnika i �owcy)\n Market Station\n Szpital\n AmmuNation (praca dilera broni)\n Bank)\n Urz�d Miasta (wyr�b licencji)\n Stacja Benzynowa\n Si�ownia (praca ochroniarza - sprzedaje pancerze i boksera)\n Willowfield\n Baza Mechanik�w","Wr��","Wyjd�");
						//\n\nOpis:\n Szybka linia zapewniaj�ca g��wnie cywilom szybki\n transport mi�dzy kluczowymi punktami w mie�cie\n Najwa�niejsza i najszybsza linia LSBD
					}
					case 2:
					{
					    ShowPlayerDialogEx(playerid,5001,DIALOG_STYLE_MSGBOX,"Linia 82","Przystanki ko�cowe:\nZajezdnia Commerce <==> Bay Side LV\n\nCzas przejazdu trasy:  11 minut \n\nIlo�� przystank�w:  9\n\nSzczeg�owy rozpis trasy:\n Zajezdnia Commerce / Basen 'tsunami'\n Urz�d Miasta\n Baza Mechanik�w\n Agencja Ochrony\n miasteczko Palomino Creek\n Hilltop Farm\n Dillimore\n Bluberry\n Bay Side","Wr��","Wyjd�");
						// \n Trasa po Red County jest bardzo malownicza\n za� droga do bay side usypiaj�ca\n Najd�u�sza trasa LSDB
					}
	    			case 3:
					{
					    ShowPlayerDialogEx(playerid,5001,DIALOG_STYLE_MSGBOX,"Linia 96","W Przystanki ko�cowe:\nBaza Wojskowa <==> Mrucznik Tower\n\nCzas przejazdu trasy:  ? \n\nIlo�� przystank�w:  12\n\nSzczeg�owy rozpis trasy:\n Baza Wojskowa\n Fabryka (dostawa mats�w)\n Pas Startowy \n Wiadukt\n Unity Station\n Verdant Bluffs (ty�y Urz�du Miasta)\n Zajezdnia Commerce\n Galerie Handlowe\n Burger Shot Marina\n Baza FBI\n Wypo�yczalnia aut (odbi�r mats�w)\n Mrucznik Tower","Wr��","Wyjd�");
						 //\n\nOpis:\nKolejna trasa ze wschodu na zach�d, jednak tym razem\n szlakiem mniej ucz�szczanych miejsc\n Ulubiona trasa pocz�tkuj�cych diler�w broni
					}
  					case 4:
					{
					    ShowPlayerDialogEx(playerid,5001,DIALOG_STYLE_MSGBOX,"Linia 85","Przystanki ko�cowe:\nWysypisko <==> Szpital\n\nCzas przejazdu trasy:  ? \n\nIlo�� przystank�w:  12\n\nSzczeg�owy rozpis trasy:\n Wysypisko\n Clukin Bell Willofield\n Myjnia Samochodowa\n Baza Mechanik�w\n Agencja Ochrony\n Las Colinas \n Motel Jefferson\n Glen Park\n Mrucznikowy GS\n Bank\n Szpital\n\n Opis:\n Niebezpieczna trasa prowadz�ce przez tereny prawie wszytkich gang�w","Wr��","Wyjd�");
					}
  					case 5:
					{
					    ShowPlayerDialogEx(playerid,5001,DIALOG_STYLE_MSGBOX,"Wycieczki","W budowie","Wr��","Wyjd�");
					}
  					case 6:
					{
        				 ShowPlayerDialogEx(playerid,5001,DIALOG_STYLE_MSGBOX,"Wycieczki","Informacje o wycieczkach s� zamieszczane na czatach g��wnych\n Oczywi�cie nie ma nic za darmo\n San News zarabia na reklamach za� KT tradycyjnei na biletach\n pami�taj �e na wycieczki nie bierzemy w�asnego samochodu\n lecz korzystamy z podstawionych przez organizatora autobus�w\n Wycieczka to �wietna zabawa i mn�stwo konkurs�w z nagrodami, dlatego warto si� na nich pojawia�.","Wr��","Wyjd�");
					}
					case 7:
					{
					    ShowPlayerDialogEx(playerid,5001,DIALOG_STYLE_MSGBOX,"Informacje","Z autobusu najlepiej korzysta� wtedy gdy jeste� pewien �e dana linia jest w trasie\n\nPami�taj, ze autobusy oznaczone numeremm linii poruszaj� si� zgodnie z okre�lon� tras�\n\nJak zosta� kierowc� autobusu?\nNale�y z�o�y� podanie na forum do Korporacji Transportowej\nMozna r�wnie� podj�� si� pracy kierowcy minibusa dost�pnej przy basenie","Wr��","Wyjd�");
					}
					case 8:
					{
					    ShowPlayerDialogEx(playerid,5001,DIALOG_STYLE_MSGBOX,"Komendy","Dla pasa�era:\n\n/businfo - wy�wietla informacje o autobusach\n/wezwij bus - pozwala wezwa� autobus ktory podwiezie ci� w dowolne miejsce\n/anuluj bus - kasuje wezwanie autobusu\n\n\nDla Kierowcy:\n/fare [cena] - pozwala wej�� na s�u�b� i ustali� cen� za bilet\n/trasa - rozpoczyna kurs wed�ug wyznaczonej trasy\n/zakoncztrase - przerywa tras�\n/zd - zamyka drzwi i umo�liwia ruszenie z przystanku","Wr��","Wyjd�");
					}
				}
			}
		}
		else if(dialogid == 5003 || dialogid == 5002 || dialogid == 5001)
	    {
	        if(response)
	        {
	            ShowPlayerDialogEx(playerid, 5000, DIALOG_STYLE_LIST, "Wybierz interesuj�c� ci� zagadnienie", "Linia 55\nLinia 72\nLinia 82\nLinia 96\nLinia 85\nWycieczki\nInformacje\nPomoc", "Wybierz", "Wyjd�");
	        }
	    }
	 	if(dialogid == D_PJTEST)
		{
			if(response == 1)
      	  	{
            	new __[9] = {0, 1, 2, 3, 4, 5, 6, 7, 8};
            	PlayerInfo[playerid][pPraojazdyniewylosowane] = __;
            	PrawoJazdyRandomGUITest(playerid, PlayerInfo[playerid][pPraojazdyniewylosowane], 9 - PlayerInfo[playerid][pPrawojazdypytania]);
            	return 1;
 			}
    	}
  		new question_ids[] = {3, 4, 5, 6, 7, 8, 9, 10, 21};
    	new correct_answers[][] = {"911", "tak", "30", "prawa", "trojkat", "140", "50", "120", "trojkat"};

    	new question_id = -1;

   		for(new i; i < sizeof(question_ids); i++)
    	{
        	if(dialogid == question_ids[i])
        	{
            	question_id = i;
           		break;
        	}
    	}
	   	if(question_id != -1 && response)
		{
			if((strcmp(inputtext, correct_answers[question_id], true) == 0)
        	&& strlen(inputtext) > 1)
        	{
            	PlayerInfo[playerid][pPrawojazdydobreodp] += 1;
        	}
        	KillTimer(TiPJTGBKubi[playerid]);
       		PlayerInfo[playerid][pPrawojazdypytania] += 1;

       		if(PlayerInfo[playerid][pPrawojazdypytania] == 3)
       		{
           		if(PlayerInfo[playerid][pPrawojazdydobreodp] == 3)
           		{
                	PlayerInfo[playerid][pSprawdzczyzdalprawko] = 1;
               		ShowPlayerDialogEx(playerid, 2, DIALOG_STYLE_MSGBOX, "Zda�e�!", "Gratulujemy!\r\nZda�e� test na Prawo Jazdy.\r\nZg�o� si� do Urz�dnika w celu\r\nodebrania tych dokument�w!", "OK", "");
                	PlayerInfo[playerid][pCarLic] = 2;
            	}
           		else
           		{
                	PlayerInfo[playerid][pSprawdzczyzdalprawko] = 0;
                	ShowPlayerDialogEx(playerid, 15, DIALOG_STYLE_MSGBOX, "Obla�e�!", "Obla�e�!\r\nNie zda�e� poprawnie testu\r\nna prawo jazdy!\r\nZg�o� si� za 1h", "OK", "");
           		}
		   		new string [256];
           		new playername[MAX_PLAYER_NAME];
		   		GetPlayerName(playerid, playername, sizeof(playername));
		   		format(string, sizeof(string), "* %s odk�ada d�ugopis i przesuwa test w stron� urz�dnika", playername);
		   		ProxDetector(40.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
           		PlayerInfo[playerid][pWtrakcietestprawa] = 0;
           		SetTimerEx("CleanPlayaPointsPJ", 30000, 0, "i", playerid);
		   		}
			else
 			{
 				PrawoJazdyRandomGUITest(playerid, PlayerInfo[playerid][pPraojazdyniewylosowane], 9 - PlayerInfo[playerid][pPrawojazdypytania]);
			}
		}
  		if(dialogid == 443)
		{
		    if(response)
		    {
                new lUID = PlayerInfo[playerid][pKluczeAuta];
                if(lUID == 0) return 1;

                new idx = Car_GetIDXFromUID(lUID);
                if(idx == -1) return 1;
                if(CarData[idx][c_Keys] != PlayerInfo[playerid][pUID])
                {
                    SendClientMessage(playerid, COLOR_NEWS, "Kluczyki od tego pojazdu zosta�y zabrane przez w�a�ciciela.");
                    PlayerInfo[playerid][pKluczeAuta] = 0;
                    return 1;
                }
		        switch(listitem)
				{
				    case 0://spawnuj kluczyki
				    {
			    		if(CarData[idx][c_ID] != 0)
			    		{
		                   SendClientMessage(playerid, 0xFFC0CB, "Pojazd do kt�rego masz kluczyki jest ju� zespawnowany");
		      			}
		      			else
		      			{
                            Car_Spawn(idx);
		                    SendClientMessage(playerid, 0xFFC0CB, "Tw�j pojazd zosta� zrespawnowany");
		                }
				    }
				    case 1://Znajd�
				    {
			    	    new Float:autox, Float:autoy, Float:autoz;
			    	    new pojazdszukany = CarData[idx][c_ID];
                        if(pojazdszukany == 0) return 1;
         				GetVehiclePos(pojazdszukany, autox, autoy, autoz);
         				SetPlayerCheckpoint(playerid, autox, autoy, autoz, 6);
		                SetTimerEx("SzukanieAuta",30000,0,"d",playerid);
		                SendClientMessage(playerid, 0xFFC0CB, "Jed� do czerwonego markera");

				    }
				    case 2://Poka� parking
				    {
			    	    SetPlayerCheckpoint(playerid, CarData[idx][c_Pos][0],CarData[idx][c_Pos][1],CarData[idx][c_Pos][2], 6);
		                SetTimerEx("SzukanieAuta",30000,0,"d",playerid);
		                SendClientMessage(playerid, 0xFFC0CB, "Jed� do czerwonego markera");

				    }
				}
			}
		}
		if(dialogid == D_AUTO_RESPAWN)//Potwierdzenie Respawnuj
		{
		    if(response)
		    {
			    if(kaska[playerid] >= 5000)
			    {
				    new vehicleid;

			        if((vehicleid = CarData[IloscAut[playerid]][c_ID]) != 0)
 					{
                        Car_Unspawn(vehicleid);
                        Car_Spawn(IloscAut[playerid]);

                        DajKase(playerid, -5000);
				        SendClientMessage(playerid, 0xFFC0CB, "Pojazd zosta� zrespawnowany. Koszt: {FF0000}5000$");
					}
					else
					{
					    SendClientMessage(playerid, 0xFFC0CB, "Ten pojazd nie jest zespawnowany");
					    return 1;
					}
				}
				else
				{
				    SendClientMessage(playerid, 0xFFC0CB, "Nie sta� ci�!");
				    ShowCarsForPlayer(playerid, playerid);
				}
			}
			if(!response)
			{
			    ShowCarsForPlayer(playerid, playerid);
			}
		}
		if(dialogid == D_AUTO_UNSPAWN)//Potwierdzenie Unspawnuj
		{
            if(response)
		    {
			    if(kaska[playerid] >= 5000)
			    {
				    new vehicleid;

			        if((vehicleid = CarData[IloscAut[playerid]][c_ID]) != 0)
 					{
                        Car_Unspawn(vehicleid);

                        DajKase(playerid, -5000);
				        SendClientMessage(playerid, 0xFFC0CB, "Pojazd zosta� unspawnowany. Koszt: {FF0000}5000$");
					}
					else
					{
					    SendClientMessage(playerid, 0xFFC0CB, "Ten pojazd nie jest zespawnowany");
					    return 1;
					}
				}
				else
				{
				    SendClientMessage(playerid, 0xFFC0CB, "Nie sta� ci�!");
                    ShowCarsForPlayer(playerid, playerid);
				}
			}
			if(!response)
			{
                ShowCarsForPlayer(playerid, playerid);
			}
		}
        if(dialogid == D_AUTO)
		{
            if(!response) return 1;
            new lUID = strval(inputtext);
            if(lUID < 0)
            {
                ShowCarsForPlayer(playerid, playerid);
                SendClientMessage(playerid, COLOR_RED, "� Ten pojazd jest zablokowany, skontaktuj si� z administratorem.");
                return 1;
            }

        	ShowPlayerDialogEx(playerid, D_AUTO_ACTION, DIALOG_STYLE_LIST, "Panel pojazdu", "Spawnuj\nRespawnuj\nUnspawnuj\nZnajd�\nPoka� parking\nPrzemaluj\nZ�omuj\nUsu� tuning\nRejestracja", "Wybierz", "Wyjd�");
        	IloscAut[playerid] = lUID;
            return 1;
        }
        if(dialogid == D_AUTO_ACTION)
        {
            if(!response)
            {
                ShowCarsForPlayer(playerid, playerid);
                return 1;
            }
            new lUID = IloscAut[playerid];
            switch(listitem)
            {
                case 0:
                {
                    if(CarData[lUID][c_ID] == 0)
                    {
                        Car_Spawn(lUID);
                        SendClientMessage(playerid, COLOR_WHITE, "Tw�j pojazd zosta� {2DE9B1}zespawnowany{FFFFFF}!");
                    }
                    else
                    {
                        SendClientMessage(playerid, COLOR_WHITE, "Tw�j pojazd jest ju� {2DE9B1}zespawnowany{FFFFFF}, stoi tam gdzie go zostawi�e�!");
                    }
                }
                case 1: ShowPlayerDialogEx(playerid, D_AUTO_RESPAWN, DIALOG_STYLE_MSGBOX, "Respawnuj w�z", "Czy na pewno chcesz zrespawnowa� � ten w�?\nKoszt respawnu wozu to {FF0000}5000${FFFAFA}!!!", "Respawnuj", "Anuluj");
                case 2: ShowPlayerDialogEx(playerid, D_AUTO_UNSPAWN, DIALOG_STYLE_MSGBOX, "Unspawnuj w�z", "Czy na pewno chcesz unspawnowa� ten w�?\nKoszt unspawnowania wozu to {FF0000}5000${FFFAFA}!!!", "Unspawnuj", "Anuluj");
                case 3://Znajd�
                {
                    if(CarData[lUID][c_ID] == 0) return SendClientMessage(playerid, 0xFFC0CB, "Auto nie jest zespawnowane.");
                    new Float:autox, Float:autoy, Float:autoz;
                    new pojazdszukany = CarData[lUID][c_ID];
                	GetVehiclePos(pojazdszukany, autox, autoy, autoz);
                	SetPlayerCheckpoint(playerid, autox, autoy, autoz, 6);
                    SetTimerEx("SzukanieAuta",30000,0,"d",playerid);
                    SendClientMessage(playerid, 0xFFC0CB, "Lokalizacja pojazdu zosta�a oznaczona na mapie.");
                }
                case 4://Poka� parking
                {
                    SetPlayerCheckpoint(playerid, CarData[lUID][c_Pos][0],CarData[lUID][c_Pos][1],CarData[lUID][c_Pos][2], 6);
                    SetTimerEx("SzukanieAuta",30000,0,"d",playerid);
                    SendClientMessage(playerid, 0xFFC0CB, "Lokalizacja pojazdu zosta�a oznaczona na mapie.");
                }
                case 5://Przemaluj
                {
                    if(IsPlayerInAnyVehicle(playerid))
                    {
                        if(kaska[playerid] >= 1500)
                        {
                            ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY, DIALOG_STYLE_LIST, "Wybierz Kolor 1", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
                        }
                        else
                        {
                            SendClientMessage(playerid, 0xFFC0CB, "Nie masz pieni�dzy na przemalowanie (1500$)");
                        }
                    }
                }
                case 6://Z�omuj
                {
                    if(IsPlayerInAnyVehicle(playerid))
                    {
                    	if(CarData[lUID][c_ID] == 0) return SendClientMessage(playerid, 0xFFC0CB, "Auto nie jest zespawnowane!");
                    	if(CarData[lUID][c_ID] != GetPlayerVehicleID(playerid)) return SendClientMessage(playerid, 0xFFC0CB, "Nie siedzisz w aucie, ktore chcesz zezlomowac!");
                    	ShowPlayerDialogEx(playerid, D_AUTO_DESTROY, DIALOG_STYLE_MSGBOX, "Z�omowanie wozu", "Czy na pewno chcesz zez�omowa� ten w�z? Zarobisz na tym tylko 5000$!", "Z�OMUJ", "WYJD�");
                    }
                }
                case 7://Usu� tuning/Przywr�c parking
                {
                    CarData[lUID][c_Nitro] = 0;
                    CarData[lUID][c_bHydraulika] = false;
                    CarData[lUID][c_Felgi] = 0;
                    CarData[lUID][c_Malunek] = 3;
                    CarData[lUID][c_Spoiler] = 0;
                    CarData[lUID][c_Bumper][0] = 0;
                    CarData[lUID][c_Bumper][1] = 0;
                    SendClientMessage(playerid, 0xFFC0CB, "Tuning zostanie usuni�ty przy najbli�szym respawnie.");
                }
                /*case 8://rejestracja prototyp
                {
                    ShowPlayerDialogEx(playerid, D_AUTO_REJESTRACJA, DIALOG_STYLE_INPUT, "Rejestracja", "Wprowad� nowy numer/tekst na swojej tablicy rejestracyjnej (do 5 znak�w):", "Ustaw", "Wr��");
                }*/
            }
            return 1;
        }
        else if(dialogid == D_AUTO_REJESTRACJA)
    	{
	    	new lUID = IloscAut[playerid];
	        if(!response) return RunCommand(playerid, "/car",  "");
	        if(strlen(inputtext) < 1 || strlen(inputtext) > 5)
	        {
	            RunCommand(playerid, "/car",  "");
	            SendClientMessage(playerid, COLOR_GRAD1, "Nieodpowiednia ilo�� znak�w.");
	            return 1;
	        }
	        else for (new i = 0, len = strlen(inputtext); i != len; i ++) {
			    if ((inputtext[i] >= 'A' && inputtext[i] <= 'Z') || (inputtext[i] >= 'a' && inputtext[i] <= 'z') || (inputtext[i] >= '0' && inputtext[i] <= '9') || (inputtext[i] == ' '))
					continue;
				else return SendClientMessage(playerid, COLOR_GRAD1, "U�y�e� nieodpowiednich znak�w rejestracji (tylko litery i cyfry).");
			}
	        CarData[lUID][c_Rejestracja] = strval(inputtext);
	        SendClientMessage(playerid, 0xFFC0CB, "Tablica zostanie zmieniona po respawnie.");
	        return 1;
		}
		if(dialogid == 440)//SYSTEM AUT - kategorie
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
				    {
				        ShowPlayerDialogEx(playerid, 450, DIALOG_STYLE_LIST, "Samochody sportowe", "Turismo 10mln\nInfernus 12,5mln\nBullet 8mln\nSuper GT 7,5mln\nCheetah 7mln\nBanshee 6mln\nComet 5mln\nBuffalo 3mln\nZR-350 2,5mln\nPhoenix 750tys\nEuros 4mln\nSultan 5mln\nJester 4,5mln\nElegy 4mln\nUranus 3,25mln\nAlpha 900tys\nFlash 3,52mln\nHotknife 1,3mln", "Wybierz", "Wr��");
				    }
				    case 1:
				    {
				        ShowPlayerDialogEx(playerid, 451, DIALOG_STYLE_LIST, "Samochody osobowe", "Bravura 160tys\nManana 180tys\nEsperanto 200tys\nPremier 280tys\nPrevion 150tys\nNebula 320tys\nSolair 350tys\nGlendale 280tys\nOceanic 340tys\nHermes 275tys\nSabre 300tys\nRegina 375tys\nGreenwood 275tys\nBlista Compact 500tys\nMajestic 250tys\nBuccaneer 140tys\nFortune 400tys\nCadrona 375tys\nWillard 340tys\nIntruder 385tys\nPrimo 340tys\nTahoma 390tys\nEmperor 230k\nClub 700tys\nSurnise", "Wybierz", "Wr��");
				    }
				    case 2:
				    {
				        ShowPlayerDialogEx(playerid, 452, DIALOG_STYLE_LIST, "Samochody luksusowe", "Limuzyna 5mln\nVirgo 680tys\nWashington 750tys\nStafford 1,8mln\nSentiniel 600tys\nAdmiral 860tys\nElegant 750tys\nMerit 500tys\nStratum 2,85mln\nVincent 700tys", "Wybierz", "Wr��");
				    }
				    case 3:
				    {
				        ShowPlayerDialogEx(playerid, 453, DIALOG_STYLE_LIST, "Samochody terenowe", "Rancher 600tys\nHuntley 350tys\nLandstalker 200tys\nMesa 700tys\nBF Injection 800tys\nHummer 7mln", "Wybierz", "Wr��");
				    }
				    case 4:
				    {
				        ShowPlayerDialogEx(playerid, 454, DIALOG_STYLE_LIST, "Pick-up`y", "Yosemite 350tys\nBobcat 160tys\nPicador 220tys\nSadler 180tys\nWalton 80tys\nSlamvan 4,5mln", "Wybierz", "Wr��");
				    }
				    case 5:
				    {
				        ShowPlayerDialogEx(playerid, 455, DIALOG_STYLE_LIST, "Kabriolety", "Comet 5mln\nWindsor 5,5mln\nFeltzer 1,4mln\nStalion 250tys", "Wybierz", "Wr��");
				    }
				    case 6:
				    {
				        ShowPlayerDialogEx(playerid, 456, DIALOG_STYLE_LIST, "Lowridery", "Blade 1,28mln\nSavanna 1,33mln\nRemington 1,4mln\nTornado 1,23mln\nVoodoo 1,22mln\nBroadway 1,21mln", "Wybierz", "Wr��");
				    }
				    case 7:
				    {
				        ShowPlayerDialogEx(playerid, 457, DIALOG_STYLE_LIST, "Na ka�d� kiesze�", "Clover 45tys\nTampa 40tys\nPerenniel 60tys\nGlendale(obity) 28tys\nSadler(obity) 25tys\nTurbow�zek �miesznie tanio\nSkuter 17tys", "Wybierz", "Wr��");
				    }
				    case 8:
				    {
				        ShowPlayerDialogEx(playerid, 458, DIALOG_STYLE_LIST, "Jedno�lady", "NRG-500 11,5mln\nFCR-900 8mln\nBF-400 4,5mln\nFreeway 900tys\nWayfarer 750tys\nSanchez 1,5mln\nQuad 600tys\nFaggio 17tys", "Wybierz", "Wr��");
				    }
				    case 9:
				    {
				        ShowPlayerDialogEx(playerid, 459, DIALOG_STYLE_LIST, "Inne pojazdy", "Burrito 350tys\nBandito 1,3mln\nHotknife 1,3mln\nCamper 350tys\nKamping 700tys\nHustler 550tys", "Wybierz", "Wr��");
				    }
				}
		    }
		}
		if(dialogid == 450)
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
				    {
				        ShowPlayerDialogEx(playerid, 4001, DIALOG_STYLE_MSGBOX, "Kupowanie Turismo", "Turismo\n\nCena: 10.000.000$\nPr�dko�� Maksymalna: 240km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
				        pojazdid[playerid] = 451;
				        CenaPojazdu[playerid] = 10000000;
				    }
				    case 1:
				    {
				        ShowPlayerDialogEx(playerid, 4001, DIALOG_STYLE_MSGBOX, "Kupowanie Infernusa", "Infernus\n\nCena: 12.500.000$\nPr�dko�� Maksymalna: 240km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
				        pojazdid[playerid] = 411;
				        CenaPojazdu[playerid] = 12500000;
				    }
				    case 2:
				    {
				        ShowPlayerDialogEx(playerid, 4002, DIALOG_STYLE_MSGBOX, "Kupowanie Bulleta", "Bullet\n\nCena: 8.000.000$\nPr�dko�� Maksymalna: 230km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 541;
	                    CenaPojazdu[playerid] = 8000000;
					}
				    case 3:
				    {
				        ShowPlayerDialogEx(playerid, 4003, DIALOG_STYLE_MSGBOX, "Kupowanie Super GT", "Super GT\n\nCena: 7.500.000$\nPr�dko�� Maksymalna: 230km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 506;
	                    CenaPojazdu[playerid] = 7500000;
					}
				    case 4:
				    {
				        ShowPlayerDialogEx(playerid, 4004, DIALOG_STYLE_MSGBOX, "Kupowanie Cheetah", "Cheetah\n\nCena: 7.000.000$\nPr�dko�� Maksymalna: 230km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 415;
	                    CenaPojazdu[playerid] = 7000000;
					}
				    case 5:
				    {
				        ShowPlayerDialogEx(playerid, 4005, DIALOG_STYLE_MSGBOX, "Kupowanie Banshee", "Banshee\n\nCena: 6.000.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 429;
	                    CenaPojazdu[playerid] = 6000000;
					}
				    case 6:
				    {
				        ShowPlayerDialogEx(playerid, 4006, DIALOG_STYLE_MSGBOX, "Kupowanie Cometa", "Comet\n\nCena: 5.000.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 480;
	                    CenaPojazdu[playerid] = 5000000;
					}
				    case 7:
				    {
				        ShowPlayerDialogEx(playerid, 4007, DIALOG_STYLE_MSGBOX, "Kupowanie Buffalo", "Buffalo\n\nCena: 3.000.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 402;
	                    CenaPojazdu[playerid] = 3000000;
					}
				    case 8:
				    {
				        ShowPlayerDialogEx(playerid, 4008, DIALOG_STYLE_MSGBOX, "Kupowanie ZR-350", "ZR-350\n\nCena: 2.500.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 477;
	                    CenaPojazdu[playerid] = 2500000;
					}
				    case 9:
				    {
				        ShowPlayerDialogEx(playerid, 4009, DIALOG_STYLE_MSGBOX, "Kupowanie Phoenixa", "Phoenix\n\nCena: 750.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 603;
	                    CenaPojazdu[playerid] = 750000;
					}
				    case 10:
				    {
				        ShowPlayerDialogEx(playerid, 4010, DIALOG_STYLE_MSGBOX, "Kupowanie Eurosa", "Euros\n\nCena: 4.000.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 587;
	                    CenaPojazdu[playerid] = 4000000;
					}
				    case 11:
				    {
				        ShowPlayerDialogEx(playerid, 4011, DIALOG_STYLE_MSGBOX, "Kupowanie Sultana", "Sultan\n\nCena: 5.000.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 560;
	                    CenaPojazdu[playerid] = 5000000;
					}
				    case 12:
				    {
				        ShowPlayerDialogEx(playerid, 4012, DIALOG_STYLE_MSGBOX, "Kupowanie Jestera", "Jester\n\nCena: 4.500.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 559;
	                    CenaPojazdu[playerid] = 4500000;
					}
				    case 13:
				    {
				        ShowPlayerDialogEx(playerid, 4013, DIALOG_STYLE_MSGBOX, "Kupowanie Elegy", "Elegy\n\nCena: 4.000.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 562;
	                    CenaPojazdu[playerid] = 4000000;
					}
				    case 14:
				    {
				        ShowPlayerDialogEx(playerid, 4014, DIALOG_STYLE_MSGBOX, "Kupowanie Uranusa", "Uranus\n\nCena: 3.250.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 558;
	                    CenaPojazdu[playerid] = 3250000;
					}
				    case 15:
				    {
				        ShowPlayerDialogEx(playerid, 4015, DIALOG_STYLE_MSGBOX, "Kupowanie Aplha", "Alpha\n\nCena: 900.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 602;
	                    CenaPojazdu[playerid] = 900000;
					}
				    case 16:
				    {
				        ShowPlayerDialogEx(playerid, 4016, DIALOG_STYLE_MSGBOX, "Kupowanie Flasha", "Flash\n\nCena: 3.520.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 565;
	                    CenaPojazdu[playerid] = 3520000;
					}
				    case 17:
				    {
				        ShowPlayerDialogEx(playerid, 4017, DIALOG_STYLE_MSGBOX, "Kupowanie Hotknife", "Hotknife\n\nCena: 1.300.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 434;
	                    CenaPojazdu[playerid] = 1300000;
					}
				}
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 440, DIALOG_STYLE_LIST, "Wybierz kategori� kupowanego pojazdu", "Samochody sportowe\nSamochody osobowe\nSamochody luksusowe\nSamochody terenowe\nPick-up`y\nKabriolety\nLowridery\nNa ka�d� kiesze�\nMotory\nInne pojazdy", "Wybierz", "Wyjd�");
	   		}
		}
		if(dialogid == 451)
		{
		    if(response)
		    {
		        switch(listitem)
				{
					case 0:
					{
					    ShowPlayerDialogEx(playerid, 4100, DIALOG_STYLE_MSGBOX, "Kupowanie Bravury", "Bravura\n\nCena: 160.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 401;
	                    CenaPojazdu[playerid] = 160000;
					}
					case 1:
					{
					    ShowPlayerDialogEx(playerid, 4101, DIALOG_STYLE_MSGBOX, "Kupowanie Manany", "Manana\n\nCena: 180.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 410;
	                    CenaPojazdu[playerid] = 180000;
					}
					case 2:
					{
					    ShowPlayerDialogEx(playerid, 4102, DIALOG_STYLE_MSGBOX, "Kupowanie Esperanto", "Esperanto\n\nCena: 200.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 419;
	                    CenaPojazdu[playerid] = 200000;
					}
					case 3:
					{
					    ShowPlayerDialogEx(playerid, 4103, DIALOG_STYLE_MSGBOX, "Kupowanie Premiera", "Premier\n\nCena: 280.000$\nPr�dko�� Maksymalna: 180km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 426;
	                    CenaPojazdu[playerid] = 280000;
					}
					case 4:
					{
					    ShowPlayerDialogEx(playerid, 4104, DIALOG_STYLE_MSGBOX, "Kupowanie Previona", "Previon\n\nCena: 150.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 436;
	                    CenaPojazdu[playerid] = 150000;
					}
					case 5:
					{
					    ShowPlayerDialogEx(playerid, 4105, DIALOG_STYLE_MSGBOX, "Kupowanie Nebuli", "Nebula\n\nCena: 320.000$\nPr�dko�� Maksymalna: 165km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 516;
	                    CenaPojazdu[playerid] = 320000;
					}
					case 6:
					{
					    ShowPlayerDialogEx(playerid, 4106, DIALOG_STYLE_MSGBOX, "Kupowanie Solair", "Solair\n\nCena: 350.000$\nPr�dko�� Maksymalna: 165km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 458;
	                    CenaPojazdu[playerid] = 350000;
					}
					case 7:
					{
					    ShowPlayerDialogEx(playerid, 4107, DIALOG_STYLE_MSGBOX, "Kupowanie Glendale", "Glendale\n\nCena: 280.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 466;
	                    CenaPojazdu[playerid] = 280000;
					}
					case 8:
					{
					    ShowPlayerDialogEx(playerid, 4108, DIALOG_STYLE_MSGBOX, "Kupowanie Oceanic", "Oceanic\n\nCena: 340.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 467;
	                    CenaPojazdu[playerid] = 340000;
					}
					case 9:
					{
					    ShowPlayerDialogEx(playerid, 4109, DIALOG_STYLE_MSGBOX, "Kupowanie Hermesa", "Hermes\n\nCena: 275.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 474;
	                    CenaPojazdu[playerid] = 275000;
					}
					case 10:
					{
					    ShowPlayerDialogEx(playerid, 4110, DIALOG_STYLE_MSGBOX, "Kupowanie Sabre", "Sabre\n\nCena: 300.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 475;
	                    CenaPojazdu[playerid] = 300000;
					}
					case 11:
					{
					    ShowPlayerDialogEx(playerid, 4111, DIALOG_STYLE_MSGBOX, "Kupowanie Reginy", "Regina\n\nCena: 375.000$\nPr�dko�� Maksymalna: 165km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 479;
	                    CenaPojazdu[playerid] = 375000;
					}
					case 12:
					{
					    ShowPlayerDialogEx(playerid, 4112, DIALOG_STYLE_MSGBOX, "Kupowanie Greenwooda", "Greenwood\n\nCena: 275.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 492;
	                    CenaPojazdu[playerid] = 275000;
					}
					case 13:
					{
					    ShowPlayerDialogEx(playerid, 4113, DIALOG_STYLE_MSGBOX, "Kupowanie Blisty", "Blista Compact\n\nCena: 500.000$\nPr�dko�� Maksymalna: 170km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 496;
	                    CenaPojazdu[playerid] = 500000;
					}
					case 14:
					{
					    ShowPlayerDialogEx(playerid, 4114, DIALOG_STYLE_MSGBOX, "Kupowanie Majestica", "Majestic\n\nCena: 250.000$\nPr�dko�� Maksymalna: 165km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 517;
	                    CenaPojazdu[playerid] = 250000;
					}
					case 15:
					{
					    ShowPlayerDialogEx(playerid, 4115, DIALOG_STYLE_MSGBOX, "Kupowanie Buccaneera", "Buccaneer\n\nCena: 140.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 518;
	                    CenaPojazdu[playerid] = 140000;
					}
					case 16:
					{
					    ShowPlayerDialogEx(playerid, 4116, DIALOG_STYLE_MSGBOX, "Kupowanie Fortune", "Fortune\n\nCena: 400.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 526;
	                    CenaPojazdu[playerid] = 400000;
					}
					case 17:
					{
					    ShowPlayerDialogEx(playerid, 4117, DIALOG_STYLE_MSGBOX, "Kupowanie Cadrony", "Cadrona\n\nCena: 375.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 527;
	                    CenaPojazdu[playerid] = 375000;
					}
					case 18:
					{
					    ShowPlayerDialogEx(playerid, 4118, DIALOG_STYLE_MSGBOX, "Kupowanie Willarda", "Willard\n\nCena: 340.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 529;
	                    CenaPojazdu[playerid] = 340000;
					}
					case 19:
					{
					    ShowPlayerDialogEx(playerid, 4119, DIALOG_STYLE_MSGBOX, "Kupowanie Intrudera", "Intruder\n\nCena: 385.000$\nPr�dko�� Maksymalna: 165km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 546;
	                    CenaPojazdu[playerid] = 385000;
					}
					case 20:
					{
					    ShowPlayerDialogEx(playerid, 4120, DIALOG_STYLE_MSGBOX, "Kupowanie Primo", "Primo\n\nCena: 340.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 547;
	                    CenaPojazdu[playerid] = 340000;
					}
					case 21:
					{
					    ShowPlayerDialogEx(playerid, 4121, DIALOG_STYLE_MSGBOX, "Kupowanie Tahomy", "Tahoma\n\nCena: 390.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 566;
	                    CenaPojazdu[playerid] = 390000;
					}
					case 22:
					{
					    ShowPlayerDialogEx(playerid, 4122, DIALOG_STYLE_MSGBOX, "Kupowanie Emperora", "Emperor\n\nCena: 230.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 585;
	                    CenaPojazdu[playerid] = 230000;
					}
					case 23:
					{
					    ShowPlayerDialogEx(playerid, 4123, DIALOG_STYLE_MSGBOX, "Kupowanie Cluba", "Club\n\nCena: 700.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 589;
	                    CenaPojazdu[playerid] = 700000;
					}
					case 24:
					{
					    ShowPlayerDialogEx(playerid, 4124, DIALOG_STYLE_MSGBOX, "Kupowanie Surnise", "Surnise\n\nCena: 395.000$\nPr�dko�� Maksymalna: 165km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 550;
	                    CenaPojazdu[playerid] = 395000;
					}
				}
			}
			if(!response)
			{
	            ShowPlayerDialogEx(playerid, 440, DIALOG_STYLE_LIST, "Wybierz kategori� kupowanego pojazdu", "Samochody sportowe\nSamochody osobowe\nSamochody luksusowe\nSamochody terenowe\nPick-up`y\nKabriolety\nLowridery\nNa ka�d� kiesze�\nMotory\nInne pojazdy", "Wybierz", "Wyjd�");
			}
		}
		if(dialogid == 452)
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
					{
					    ShowPlayerDialogEx(playerid, 4200, DIALOG_STYLE_MSGBOX, "Kupowanie Limuzyny", "Limuzyna\n\nCena: 5.000.000$\nPr�dko�� Maksymalna: 180km/h\nIlo�� miejsc: 4\nOpis: Pojazd posiada wn�trze do kt�rego mo�na \n\t wchodzi� i wychodzi� komend� /wejdzw", "Kup!", "Wr��");
	                    pojazdid[playerid] = 409;
	                    CenaPojazdu[playerid] = 5000000;
					}
					case 1:
					{
					    ShowPlayerDialogEx(playerid, 4201, DIALOG_STYLE_MSGBOX, "Kupowanie Virgo", "Virgo\n\nCena: 680.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 491;
	                    CenaPojazdu[playerid] = 680000;
					}
					case 2:
					{
					    ShowPlayerDialogEx(playerid, 4203, DIALOG_STYLE_MSGBOX, "Kupowanie Washington", "Washington\n\nCena: 750.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 421;
	                    CenaPojazdu[playerid] = 750000;
					}
					case 3:
					{
					    ShowPlayerDialogEx(playerid, 4203, DIALOG_STYLE_MSGBOX, "Kupowanie Stafforda", "Stafford\n\nCena: 1.800.000$\nPr�dko�� Maksymalna: 165km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 580;
	                    CenaPojazdu[playerid] = 1800000;
					}
					case 4:
					{
					    ShowPlayerDialogEx(playerid, 4204, DIALOG_STYLE_MSGBOX, "Kupowanie Sentinela", "Sentinel\n\nCena: 600.000$\nPr�dko�� Maksymalna: 165km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 405;
	                    CenaPojazdu[playerid] = 600000;
					}
					case 5:
					{
					    ShowPlayerDialogEx(playerid, 4205, DIALOG_STYLE_MSGBOX, "Kupowanie Admirala", "Admiral\n\nCena: 800.000$\nPr�dko�� Maksymalna: 165km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 445;
	                    CenaPojazdu[playerid] = 800000;
					}
					case 6:
					{
					    ShowPlayerDialogEx(playerid, 4206, DIALOG_STYLE_MSGBOX, "Kupowanie Eleganta", "Elegant\n\nCena: 750.000$\nPr�dko�� Maksymalna: 165km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 507;
	                    CenaPojazdu[playerid] = 750000;
					}
					case 7:
					{
					    ShowPlayerDialogEx(playerid, 4207, DIALOG_STYLE_MSGBOX, "Kupowanie Merita", "Merit\n\nCena: 500.000$\nPr�dko�� Maksymalna: 165km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 551;
	                    CenaPojazdu[playerid] = 500000;
					}
					case 8:
					{
					    ShowPlayerDialogEx(playerid, 4208, DIALOG_STYLE_MSGBOX, "Kupowanie Stratuma", "Stratum\n\nCena: 2.850.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 561;
	                    CenaPojazdu[playerid] = 2850000;
					}
					case 9:
					{
					    ShowPlayerDialogEx(playerid, 4209, DIALOG_STYLE_MSGBOX, "Kupowanie Vincenta", "Vincent\n\nCena: 700.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 540;
	                    CenaPojazdu[playerid] = 700000;
					}
				}
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 440, DIALOG_STYLE_LIST, "Wybierz kategori� kupowanego pojazdu", "Samochody sportowe\nSamochody osobowe\nSamochody luksusowe\nSamochody terenowe\nPick-up`y\nKabriolety\nLowridery\nNa ka�d� kiesze�\nMotory\nInne pojazdy", "Wybierz", "Wyjd�");
			}
		}
		if(dialogid == 453)
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
					{
					    ShowPlayerDialogEx(playerid, 4300, DIALOG_STYLE_MSGBOX, "Kupowanie Ranchera", "Rancher\n\nCena: 600.000$\nPr�dko�� Maksymalna: 170km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 489;
	                    CenaPojazdu[playerid] = 600000;
					}
					case 1:
					{
					    ShowPlayerDialogEx(playerid, 4301, DIALOG_STYLE_MSGBOX, "Kupowanie Huntleya", "Huntley\n\nCena: 350.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 579;
	                    CenaPojazdu[playerid] = 350000;
					}
					case 2:
					{
					    ShowPlayerDialogEx(playerid, 4302, DIALOG_STYLE_MSGBOX, "Kupowanie Landstalkera", "Landstalker\n\nCena: 200.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 400;
	                    CenaPojazdu[playerid] = 200000;
					}
					case 3:
					{
					    ShowPlayerDialogEx(playerid, 4302, DIALOG_STYLE_MSGBOX, "Kupowanie Mesy", "Mesa\n\nCena: 700.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 500;
	                    CenaPojazdu[playerid] = 700000;
					}
					case 4:
					{
					    ShowPlayerDialogEx(playerid, 4303, DIALOG_STYLE_MSGBOX, "Kupowanie BF Injection", "BF Injection\n\nCena: 800.000$\nPr�dko�� Maksymalna: 170km/h\nIlo�� miejsc: 2\nOpis: Najlepszy do lansowania si� na pla�y", "Kup!", "Wr��");
	                    pojazdid[playerid] = 424;
	                    CenaPojazdu[playerid] = 800000;
					}
					/*=========[ZABLOKOWANO Z POWODU NADU�Y� POJAZDU - 18-02-2019]=============
					case 5:
					{
					    ShowPlayerDialogEx(playerid, 4304, DIALOG_STYLE_MSGBOX, "Kupowanie Sandkinga", "Sandking\n\nCena: 4.000.000$\nPr�dko�� Maksymalna: 180km/h\nIlo�� miejsc: 2\nOpis: Sportowy w�z terenowy, kolory raczej ciemne.\nPrzejedzie przez ka�d� przeszkod�!", "Kup!", "Wr��");
	                    pojazdid[playerid] = 495;
	                    CenaPojazdu[playerid] = 4000000;
					}*/
					case 5:
					{
					    ShowPlayerDialogEx(playerid, 4304, DIALOG_STYLE_MSGBOX, "Kupowanie Hummera", "Hummer\n\nCena: 7.000.000$\nPr�dko�� Maksymalna: 180km/h\nIlo�� miejsc: 2\nOpis: Wojskowy w�z terenowy, tylko jeden kolor.", "Kup!", "Wr��");
	                    pojazdid[playerid] = 470;
	                    CenaPojazdu[playerid] = 7000000;
					}
				}
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 440, DIALOG_STYLE_LIST, "Wybierz kategori� kupowanego pojazdu", "Samochody sportowe\nSamochody osobowe\nSamochody luksusowe\nSamochody terenowe\nPick-up`y\nKabriolety\nLowridery\nNa ka�d� kiesze�\nMotory\nInne pojazdy", "Wybierz", "Wyjd�");
			}
		}
		if(dialogid == 454)
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
					{
					    ShowPlayerDialogEx(playerid, 4400, DIALOG_STYLE_MSGBOX, "Kupowanie Yosemite", "Yosemite\n\nCena: 350.000$\nPr�dko�� Maksymalna: 165km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 554;
	                    CenaPojazdu[playerid] = 350000;
					}
					case 1:
					{
					    ShowPlayerDialogEx(playerid, 4401, DIALOG_STYLE_MSGBOX, "Kupowanie Bobcata", "Bobcat\n\nCena: 160.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 422;
	                    CenaPojazdu[playerid] = 160000;
					}
					case 2:
					{
					    ShowPlayerDialogEx(playerid, 4402, DIALOG_STYLE_MSGBOX, "Kupowanie Picadora", "Picador\n\nCena: 220.000$\nPr�dko�� Maksymalna: 165km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 600;
	                    CenaPojazdu[playerid] = 220000;
					}
					case 3:
					{
					    ShowPlayerDialogEx(playerid, 4403, DIALOG_STYLE_MSGBOX, "Kupowanie Sadlera", "Sadler\n\nCena: 180.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 543;
	                    CenaPojazdu[playerid] = 180000;
					}
					case 4:
					{
					    ShowPlayerDialogEx(playerid, 4404, DIALOG_STYLE_MSGBOX, "Kupowanie Waltona", "Walton\n\nCena: 80.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 478;
	                    CenaPojazdu[playerid] = 80000;
					}
					case 5:
					{
					    ShowPlayerDialogEx(playerid, 4603, DIALOG_STYLE_MSGBOX, "Kupowanie Slamvana", "Slamvan\n\nCena: 4.500.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Van, dost�pne malunki i full tuning.", "Kup!", "Wr��");
	                    pojazdid[playerid] = 535;//dodaj slamvana slamavana
	                    CenaPojazdu[playerid] = 4500000;
					}
				}
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 440, DIALOG_STYLE_LIST, "Wybierz kategori� kupowanego pojazdu", "Samochody sportowe\nSamochody osobowe\nSamochody luksusowe\nSamochody terenowe\nPick-up`y\nKabriolety\nLowridery\nNa ka�d� kiesze�\nMotory\nInne pojazdy", "Wybierz", "Wyjd�");
			}
		}
		if(dialogid == 455)
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
					{
					    ShowPlayerDialogEx(playerid, 4500, DIALOG_STYLE_MSGBOX, "Kupowanie Cometa", "Comet\n\nCena: 5.000.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 480;
	                    CenaPojazdu[playerid] = 5000000;
					}
					case 1:
					{
					    ShowPlayerDialogEx(playerid, 4501, DIALOG_STYLE_MSGBOX, "Kupowanie Windsora", "Windsor\n\nCena: 5.550.000$\nPr�dko�� Maksymalna: 180km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 555;
	                    CenaPojazdu[playerid] = 5550000;
					}
					case 2:
					{
					    ShowPlayerDialogEx(playerid, 4502, DIALOG_STYLE_MSGBOX, "Kupowanie Feltzera", "Feltzer\n\nCena: 1.400.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 533;
	                    CenaPojazdu[playerid] = 1400000;
					}
					case 3:
					{
					    ShowPlayerDialogEx(playerid, 4503, DIALOG_STYLE_MSGBOX, "Kupowanie Staliona", "Stalion\n\nCena: 250.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 439;
	                    CenaPojazdu[playerid] = 250000;
					}
				}
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 440, DIALOG_STYLE_LIST, "Wybierz kategori� kupowanego pojazdu", "Samochody sportowe\nSamochody osobowe\nSamochody luksusowe\nSamochody terenowe\nPick-up`y\nKabriolety\nLowridery\nNa ka�d� kiesze�\nMotory\nInne pojazdy", "Wybierz", "Wyjd�");
			}
		}
		if(dialogid == 456)
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
					{
					    ShowPlayerDialogEx(playerid, 4600, DIALOG_STYLE_MSGBOX, "Kupowanie Blade", "Blade\n\nCena: 1.280.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 536;
	                    CenaPojazdu[playerid] = 1280000;
					}
					case 1:
					{
					    ShowPlayerDialogEx(playerid, 4601, DIALOG_STYLE_MSGBOX, "Kupowanie Savanny", "Savanna\n\nCena: 1.330.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 567;
	                    CenaPojazdu[playerid] = 1330000;
					}
					case 2:
					{
					    ShowPlayerDialogEx(playerid, 4602, DIALOG_STYLE_MSGBOX, "Kupowanie Remington", "Savanna\n\nCena: 1.400.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 534;
	                    CenaPojazdu[playerid] = 1400000;
					}
					case 3:
					{
					    ShowPlayerDialogEx(playerid, 4603, DIALOG_STYLE_MSGBOX, "Kupowanie Tornada", "Tornado\n\nCena: 1.230.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 576;
	                    CenaPojazdu[playerid] = 1230000;
					}
					case 4:
					{
					    ShowPlayerDialogEx(playerid, 4604, DIALOG_STYLE_MSGBOX, "Kupowanie Voodoo", "Voodoo\n\nCena: 1.220.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 412;
	                    CenaPojazdu[playerid] = 1220000;
					}
					case 5:
					{
					    ShowPlayerDialogEx(playerid, 4605, DIALOG_STYLE_MSGBOX, "Kupowanie Broadwaya", "Broadway\n\nCena: 1.210.000$\nPr�dko�� Maksymalna: 170km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 575;
	                    CenaPojazdu[playerid] = 1210000;
					}
				}
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 440, DIALOG_STYLE_LIST, "Wybierz kategori� kupowanego pojazdu", "Samochody sportowe\nSamochody osobowe\nSamochody luksusowe\nSamochody terenowe\nPick-up`y\nKabriolety\nLowridery\nNa ka�d� kiesze�\nMotory\nInne pojazdy", "Wybierz", "Wyjd�");
			}
		}
		if(dialogid == 457)
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
					{
					    ShowPlayerDialogEx(playerid, 4700, DIALOG_STYLE_MSGBOX, "Kupowanie Clovera", "Clover\n\nCena: 45.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 542;
	                    CenaPojazdu[playerid] = 45000;
					}
					case 1:
					{
					    ShowPlayerDialogEx(playerid, 4701, DIALOG_STYLE_MSGBOX, "Kupowanie Tampy", "Tampa\n\nCena: 40.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 549;
	                    CenaPojazdu[playerid] = 40000;
					}
					case 2:
					{
					    ShowPlayerDialogEx(playerid, 4701, DIALOG_STYLE_MSGBOX, "Kupowanie Perennial", "Perennial\n\nCena: 60.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 404;
	                    CenaPojazdu[playerid] = 60000;
					}
					case 3:
					{
					    ShowPlayerDialogEx(playerid, 4702, DIALOG_STYLE_MSGBOX, "Kupowanie Glendale(obity)", "Glendale(obity)\n\nCena: 28.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 604;
	                    CenaPojazdu[playerid] = 28000;
					}
					case 4:
					{
					    ShowPlayerDialogEx(playerid, 4703, DIALOG_STYLE_MSGBOX, "Kupowanie Sadler(obity)", "Sadler(obity)\n\nCena: 25.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 605;
	                    CenaPojazdu[playerid] = 25000;
					}
					case 5:
					{
					    ShowPlayerDialogEx(playerid, 4704, DIALOG_STYLE_MSGBOX, "Kupowanie Turbow�zek", "Turbow�zek\n\nCena: 7.500$\nPr�dko�� Maksymalna: 80km/h\nIlo�� miejsc: 1\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 572;
	                    CenaPojazdu[playerid] = 7500;
					}
					case 6:
					{
					    ShowPlayerDialogEx(playerid, 4705, DIALOG_STYLE_MSGBOX, "Kupowanie Skuter", "Skuter\n\nCena: 17.000$\nPr�dko�� Maksymalna: 120km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 462;
	                    CenaPojazdu[playerid] = 17000;
					}
				}
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 440, DIALOG_STYLE_LIST, "Wybierz kategori� kupowanego pojazdu", "Samochody sportowe\nSamochody osobowe\nSamochody luksusowe\nSamochody terenowe\nPick-up`y\nKabriolety\nLowridery\nNa ka�d� kiesze�\nMotory\nInne pojazdy", "Wybierz", "Wyjd�");
			}
		}
		if(dialogid == 458)
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
					{
					    ShowPlayerDialogEx(playerid, 4800, DIALOG_STYLE_MSGBOX, "Kupowanie NRG-500", "NRG-500\n\nCena: 11.500.000$\nPr�dko�� Maksymalna: 240km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 522;
	                    CenaPojazdu[playerid] = 11500000;
					}
					case 1:
					{
					    ShowPlayerDialogEx(playerid, 4801, DIALOG_STYLE_MSGBOX, "Kupowanie FCR-900", "FCR-900\n\nCena: 8.000.000$\nPr�dko�� Maksymalna: 220km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 521;
	                    CenaPojazdu[playerid] = 8000000;
					}
					case 2:
					{
					    ShowPlayerDialogEx(playerid, 4802, DIALOG_STYLE_MSGBOX, "Kupowanie BF-400", "BF-400\n\nCena: 4.500.000$\nPr�dko�� Maksymalna: 200km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 581;
	                    CenaPojazdu[playerid] = 4500000;
					}
					case 3:
					{
					    ShowPlayerDialogEx(playerid, 4803, DIALOG_STYLE_MSGBOX, "Kupowanie Freeway", "Freeway\n\nCena: 900.000$\nPr�dko�� Maksymalna: 180km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 463;
	                    CenaPojazdu[playerid] = 900000;
					}
					case 4:
					{
					    ShowPlayerDialogEx(playerid, 4804, DIALOG_STYLE_MSGBOX, "Kupowanie Wayfarer", "Wayfarer\n\nCena: 750.000$\nPr�dko�� Maksymalna: 170km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 586;
	                    CenaPojazdu[playerid] = 750000;
					}
					case 5:
					{
					    ShowPlayerDialogEx(playerid, 4805, DIALOG_STYLE_MSGBOX, "Kupowanie Sancheza", "Sanchez\n\nCena: 1.500.000$\nPr�dko�� Maksymalna: 230km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 468;
	                    CenaPojazdu[playerid] = 1500000;
					}
					case 6:
					{
					    ShowPlayerDialogEx(playerid, 4806, DIALOG_STYLE_MSGBOX, "Kupowanie Quad", "Quad\n\nCena: 600.000$\nPr�dko�� Maksymalna: 230km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 471;
	                    CenaPojazdu[playerid] = 600000;
					}
					case 7:
					{
					   	ShowPlayerDialogEx(playerid, 4807, DIALOG_STYLE_MSGBOX, "Kupowanie Skuter", "Skuter\n\nCena: 17.000$\nPr�dko�� Maksymalna: 120km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 462;
	                    CenaPojazdu[playerid] = 17000;
					}
				}
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 440, DIALOG_STYLE_LIST, "Wybierz kategori� kupowanego pojazdu", "Samochody sportowe\nSamochody osobowe\nSamochody luksusowe\nSamochody terenowe\nPick-up`y\nKabriolety\nLowridery\nNa ka�d� kiesze�\nMotory\nInne pojazdy", "Wybierz", "Wyjd�");
			}
		}
		if(dialogid == 459)
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
					{
	                    ShowPlayerDialogEx(playerid, 4900, DIALOG_STYLE_MSGBOX, "Kupowanie Burrito", "Burrito\n\nCena: 350.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 482;
	                    CenaPojazdu[playerid] = 350000;
					}
					case 1:
					{
	                    ShowPlayerDialogEx(playerid, 4901, DIALOG_STYLE_MSGBOX, "Kupowanie Bandito", "Bandito\n\nCena: 1.300.000$\nPr�dko�� Maksymalna: 170km/h\nIlo�� miejsc: 1\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 568;
	                    CenaPojazdu[playerid] = 1300000;
					}
					case 2:
					{
	                    ShowPlayerDialogEx(playerid, 4902, DIALOG_STYLE_MSGBOX, "Kupowanie Hotknife", "Hotknife\n\nCena: 1.300.000$\nPr�dko�� Maksymalna: 170km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 434;
	                    CenaPojazdu[playerid] = 1300000;
					}
					case 3:
					{
	                    ShowPlayerDialogEx(playerid, 4903, DIALOG_STYLE_MSGBOX, "Kupowanie Camper", "Camper\n\nCena: 350.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 4\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 483;
	                    CenaPojazdu[playerid] = 350000;
					}
					case 4:
					{
	                    ShowPlayerDialogEx(playerid, 4904, DIALOG_STYLE_MSGBOX, "Kupowanie Kamping", "Kamping\n\nCena: 700.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 10-15 (Ruchomy dom)\nOpis: Pojazd posiada wn�trze do kt�rego mo�na \n\t wchodzi� i wychodzi� komend� /wejdzw", "Kup!", "Wr��");
	                    pojazdid[playerid] = 508;
	                    CenaPojazdu[playerid] = 700000;
					}
					case 5:
					{
	                    ShowPlayerDialogEx(playerid, 4905, DIALOG_STYLE_MSGBOX, "Kupowanie Hustler", "Hustler\n\nCena: 550.000$\nPr�dko�� Maksymalna: 160km/h\nIlo�� miejsc: 2\nOpis: Brak", "Kup!", "Wr��");
	                    pojazdid[playerid] = 545;
	                    CenaPojazdu[playerid] = 550000;
					}
				}
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 440, DIALOG_STYLE_LIST, "Wybierz kategori� kupowanego pojazdu", "Samochody sportowe\nSamochody osobowe\nSamochody luksusowe\nSamochody terenowe\nPick-up`y\nKabriolety\nLowridery\nNa ka�d� kiesze�\nMotory\nInne pojazdy", "Wybierz", "Wyjd�");
			}
		}
		if(dialogid >= 4000 && dialogid <= 4017)
		{
		    if(response)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybierz kolor wybranego wozu");
	            ShowPlayerDialogEx(playerid, 31, DIALOG_STYLE_LIST, "Wybierz Kolor 1", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 450, DIALOG_STYLE_LIST, "Samochody sportowe", "Turismo 10mln\nInfernus 12,5mln\nBullet 8mln\nSuper GT 7,5mln\nCheetah 7mln\nBanshee 6mln\nComet 5mln\nBuffalo 3mln\nZR-350 2,5mln\nPhoenix 750tys\nEuros 4mln\nSultan 5mln\nJester 4,5mln\nElegy 4mln\nUranus 3,25mln\nAlpha 900tys\nFlash 3,52mln\nHotknife 1,3mln", "Wybierz", "Wr��");
	            pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
		    }
		}
		if(dialogid >= 4100 && dialogid <= 4124)
		{
		    if(response)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybierz kolor wybranego wozu");
	            ShowPlayerDialogEx(playerid, 31, DIALOG_STYLE_LIST, "Wybierz Kolor 1", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
		    }
		    if(!response)
		    {
	            ShowPlayerDialogEx(playerid, 451, DIALOG_STYLE_LIST, "Samochody osobowe", "Bravura 160tys\nManana 180tys\nEsperanto 200tys\nPremier 280tys\nPrevion 150tys\nNebula 320tys\nSolair 350tys\nGlendale 280tys\nOceanic 340tys\nHermes 275tys\nSabre 300tys\nRegina 375tys\nGreenwood 275tys\nBlista Compact 500tys\nMajestic 250tys\nBuccaneer 140tys\nFortune 400tys\nCadrona 375tys\nWillard 340tys\nIntruder 385tys\nPrimo 340tys\nTahoma 390tys\nEmperor 230k\nClub 700tys\nSurnise", "Wybierz", "Wr��");
	            pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
			}
		}
		if(dialogid >= 4200 && dialogid <= 4209)
		{
		    if(response)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybierz kolor wybranego wozu");
	            ShowPlayerDialogEx(playerid, 31, DIALOG_STYLE_LIST, "Wybierz Kolor 1", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
		    }
		    if(!response)
		    {
	            ShowPlayerDialogEx(playerid, 452, DIALOG_STYLE_LIST, "Samochody luksusowe", "Limuzyna 5mln\nVirgo 680tys\nWashington 750tys\nStafford 1,8mln\nSentiniel 600tys\nAdmiral 860tys\nElegant 750tys\nMerit 500tys\nStratum 2,85mln\nVincent 700tys", "Wybierz", "Wr��");
	            pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
			}
		}
		if(dialogid >= 4300 && dialogid <= 4305)
		{
		    if(response)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybierz kolor wybranego wozu");
	            ShowPlayerDialogEx(playerid, 31, DIALOG_STYLE_LIST, "Wybierz Kolor 1", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
		    }
		    if(!response)
		    {
	            ShowPlayerDialogEx(playerid, 453, DIALOG_STYLE_LIST, "Samochody terenowe", "Rancher 600tys\nHuntley 350tys\nLandstalker 200tys\nMesa 700tys\nBF Injection 800tys\nSandking 4mln\nHummer 7mln", "Wybierz", "Wr��");
	            pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
			}
		}
		if(dialogid >= 4400 && dialogid <= 4404)
		{
		    if(response)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybierz kolor wybranego wozu");
	            ShowPlayerDialogEx(playerid, 31, DIALOG_STYLE_LIST, "Wybierz Kolor 1", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
		    }
		    if(!response)
		    {
	            ShowPlayerDialogEx(playerid, 454, DIALOG_STYLE_LIST, "Pick-up`y", "Yosemite 350tys\nBobcat 160tys\nPicador 220tys\nSadler 180tys\nWalton 80tys\nSlamvan 4,5mln", "Wybierz", "Wr��");
	            pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
			}
		}
		if(dialogid >= 4500 && dialogid <= 4503)
		{
		    if(response)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybierz kolor wybranego wozu");
	            ShowPlayerDialogEx(playerid, 31, DIALOG_STYLE_LIST, "Wybierz Kolor 1", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
		    }
		    if(!response)
		    {
	            ShowPlayerDialogEx(playerid, 455, DIALOG_STYLE_LIST, "Kabriolety", "Comet 5mln\nWindsor 5,5mln\nFeltzer 1,4mln\nStalion 250tys", "Wybierz", "Wr��");
	            pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
			}
		}
		if(dialogid >= 4600 && dialogid <= 4605)
		{
		    if(response)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybierz kolor wybranego wozu");
	            ShowPlayerDialogEx(playerid, 31, DIALOG_STYLE_LIST, "Wybierz Kolor 1", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
		    }
		    if(!response)
		    {
	            ShowPlayerDialogEx(playerid, 456, DIALOG_STYLE_LIST, "Lowridery", "Blade 1,28mln\nSavanna 1,33mln\nRemington 1,4mln\nTornado 1,23mln\nVoodoo 1,22mln\nBroadway 1,21mln", "Wybierz", "Wr��");
	            pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
			}
		}
		if(dialogid >= 4700 && dialogid <= 4705)
		{
		    if(response)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybierz kolor wybranego wozu");
	            ShowPlayerDialogEx(playerid, 31, DIALOG_STYLE_LIST, "Wybierz Kolor 1", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
		    }
		    if(!response)
		    {
	            ShowPlayerDialogEx(playerid, 457, DIALOG_STYLE_LIST, "Na ka�d� kiesze�", "Clover 45tys\nTampa 40tys\nPerenniel 60tys\nGlendale(obity) 28tys\nSadler(obity) 25tys\nTurbow�zek �miesznie tanio\nSkuter 17tys", "Wybierz", "Wr��");
	            pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
			}
		}
		if(dialogid >= 4800 && dialogid <= 4807)
		{
		    if(response)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybierz kolor wybranego wozu");
	            ShowPlayerDialogEx(playerid, 31, DIALOG_STYLE_LIST, "Wybierz Kolor 1", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
		    }
		    if(!response)
		    {
	            ShowPlayerDialogEx(playerid, 458, DIALOG_STYLE_LIST, "Jedno�lady", "NRG-500 11,5mln\nFCR-900 8mln\nBF-400 4,5mln\nFreeway 900tys\nWayfarer 750tys\nSanchez 1,5mln\nQuad 600tys\nFaggio 17tys", "Wybierz", "Wr��");
	            pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
			}
		}
		if(dialogid >= 4900 && dialogid <= 4907)
		{
		    if(response)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybierz kolor wybranego wozu");
	            ShowPlayerDialogEx(playerid, 31, DIALOG_STYLE_LIST, "Wybierz Kolor 1", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
		    }
		    if(!response)
		    {
	            ShowPlayerDialogEx(playerid, 459, DIALOG_STYLE_LIST, "Inne pojazdy", "Burrito 350tys\nBandito 1,3mln\nHotknife 1,3mln\nCamper 350tys\nKamping 700tys\nHustler 550tys", "Wybierz", "Wr��");
	            pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
			}
		}
		if(dialogid == 31)
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
					{
					    KolorPierwszy[playerid] = 0;
					    ShowPlayerDialogEx(playerid, 32, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 1:
					{
	    				KolorPierwszy[playerid] = 1;
					    ShowPlayerDialogEx(playerid, 32, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 2:
					{
	    				KolorPierwszy[playerid] = 2;
					    ShowPlayerDialogEx(playerid, 32, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 3:
					{
	    				KolorPierwszy[playerid] = 3;
					    ShowPlayerDialogEx(playerid, 32, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 4:
					{
	    				KolorPierwszy[playerid] = 4;
					    ShowPlayerDialogEx(playerid, 32, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 5:
					{
	    				KolorPierwszy[playerid] = 126;
					    ShowPlayerDialogEx(playerid, 32, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 6:
					{
	    				KolorPierwszy[playerid] = 6;
					    ShowPlayerDialogEx(playerid, 32, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 7:
					{
	    				KolorPierwszy[playerid] = 7;
					    ShowPlayerDialogEx(playerid, 32, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 8:
					{
	    				KolorPierwszy[playerid] = 8;
					    ShowPlayerDialogEx(playerid, 32, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 9:
					{
	    				KolorPierwszy[playerid] = 42;
					    ShowPlayerDialogEx(playerid, 32, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 10:
					{
	    				KolorPierwszy[playerid] = 16;
					    ShowPlayerDialogEx(playerid, 32, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 11:
					{
	    				KolorPierwszy[playerid] = 20;
					    ShowPlayerDialogEx(playerid, 32, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 12:
					{
					    ShowPlayerDialogEx(playerid, 35, DIALOG_STYLE_INPUT, "Wybierz Kolor 1", "Wpisz numer koloru (od 0 do 126)", "Wybierz", "Wyjd�");
					}
				}
			}
			if(!response)
			{
			    pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
			}
		}
        else if(dialogid == 32)
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
					{
						KupowaniePojazdu(playerid, pojazdid[playerid], KolorPierwszy[playerid], 0, CenaPojazdu[playerid]);
					}
					case 1:
					{
	    				KupowaniePojazdu(playerid, pojazdid[playerid], KolorPierwszy[playerid], 1, CenaPojazdu[playerid]);
					}
					case 2:
					{
	    				KupowaniePojazdu(playerid, pojazdid[playerid], KolorPierwszy[playerid], 2, CenaPojazdu[playerid]);
					}
					case 3:
					{
	    				KupowaniePojazdu(playerid, pojazdid[playerid], KolorPierwszy[playerid], 3, CenaPojazdu[playerid]);
					}
					case 4:
					{
	    				KupowaniePojazdu(playerid, pojazdid[playerid], KolorPierwszy[playerid], 4, CenaPojazdu[playerid]);
					}
					case 5:
					{
	    				KupowaniePojazdu(playerid, pojazdid[playerid], KolorPierwszy[playerid], 126, CenaPojazdu[playerid]);
					}
					case 6:
					{
	    				KupowaniePojazdu(playerid, pojazdid[playerid], KolorPierwszy[playerid], 6, CenaPojazdu[playerid]);
					}
					case 7:
					{
	    				KupowaniePojazdu(playerid, pojazdid[playerid], KolorPierwszy[playerid], 7, CenaPojazdu[playerid]);
					}
					case 8:
					{
	    				KupowaniePojazdu(playerid, pojazdid[playerid], KolorPierwszy[playerid], 8, CenaPojazdu[playerid]);
					}
					case 9:
					{
	    				KupowaniePojazdu(playerid, pojazdid[playerid], KolorPierwszy[playerid], 42, CenaPojazdu[playerid]);
					}
					case 10:
					{
	    				KupowaniePojazdu(playerid, pojazdid[playerid], KolorPierwszy[playerid], 16, CenaPojazdu[playerid]);
					}
					case 11:
					{
	    				KupowaniePojazdu(playerid, pojazdid[playerid], KolorPierwszy[playerid], 20, CenaPojazdu[playerid]);
					}
					case 12:
					{
					    ShowPlayerDialogEx(playerid, 36, DIALOG_STYLE_INPUT, "Wybierz Kolor 2", "Wpisz numer koloru (od 0 do 126)", "Wybierz", "Wyjd�");
					}
				}
			}
			if(!response)
			{
			    pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
	            KolorPierwszy[playerid] = 0;
			}
		}
        else if(dialogid == D_AUTO_RESPRAY)
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
					{
					    KolorPierwszy[playerid] = 0;
					    ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY2, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 1:
					{
	    				KolorPierwszy[playerid] = 1;
					    ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY2, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 2:
					{
	    				KolorPierwszy[playerid] = 2;
					    ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY2, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 3:
					{
	    				KolorPierwszy[playerid] = 3;
					    ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY2, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 4:
					{
	    				KolorPierwszy[playerid] = 4;
					    ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY2, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 5:
					{
	    				KolorPierwszy[playerid] = 126;
					    ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY2, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 6:
					{
	    				KolorPierwszy[playerid] = 6;
					    ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY2, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 7:
					{
	    				KolorPierwszy[playerid] = 7;
					    ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY2, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 8:
					{
	    				KolorPierwszy[playerid] = 8;
					    ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY2, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 9:
					{
	    				KolorPierwszy[playerid] = 42;
					    ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY2, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 10:
					{
	    				KolorPierwszy[playerid] = 16;
					    ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY2, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 11:
					{
	    				KolorPierwszy[playerid] = 20;
					    ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY2, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
					}
					case 12:
					{
					    ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY_OWN, DIALOG_STYLE_INPUT, "Wybierz Kolor 1", "Wpisz numer koloru (od 0 do 126)", "Wybierz", "Wyjd�");
					}
				}
			}
		}
		else if(dialogid == D_AUTO_RESPRAY2)
		{
		    if(response)
		    {
                new veh = GetPlayerVehicleID(playerid);
		        switch(listitem)
				{
				    case 0..8:
					{
						if(IsCarOwner(playerid, veh))
						{
							ChangeVehicleColor(veh, KolorPierwszy[playerid], listitem);
							MRP_ChangeVehicleColor(veh, KolorPierwszy[playerid], listitem);
							SendClientMessage(playerid, 0xFFC0CB, "Pojazd przemalowany! -1500$");
							DajKase(playerid, -1500);
						}
					}
					case 9:
					{
                        if(IsCarOwner(playerid, veh))
						{
							ChangeVehicleColor(veh, KolorPierwszy[playerid], 42);
							MRP_ChangeVehicleColor(veh, KolorPierwszy[playerid], listitem);
							SendClientMessage(playerid, 0xFFC0CB, "Pojazd przemalowany! -1500$");
							DajKase(playerid, -1500);
						}
					}
					case 10:
					{
                        if(IsCarOwner(playerid, veh))
						{
							ChangeVehicleColor(veh, KolorPierwszy[playerid], 16);
							MRP_ChangeVehicleColor(veh, KolorPierwszy[playerid], listitem);
							SendClientMessage(playerid, 0xFFC0CB, "Pojazd przemalowany! -1500$");
							DajKase(playerid, -1500);
						}
					}
					case 11:
					{
                        if(IsCarOwner(playerid, veh))
						{
							ChangeVehicleColor(veh, KolorPierwszy[playerid], 20);
							MRP_ChangeVehicleColor(veh, KolorPierwszy[playerid], listitem);
							SendClientMessage(playerid, 0xFFC0CB, "Pojazd przemalowany! -1500$");
							DajKase(playerid, -1500);
						}
					}
					case 12:
					{
					    ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY_OWN2, DIALOG_STYLE_INPUT, "Wybierz Kolor 2", "Wpisz numer koloru (od 0 do 126)", "Wybierz", "Wyjd�");
					}
				}
			}
			if(!response)
			{
	            KolorPierwszy[playerid] = 0;
			}
		}
		else if(dialogid == 36)
		{
		    if(response)
		    {
		        if(strval(inputtext) > 0 &&  strval(inputtext) < 255)
		        {
			        KupowaniePojazdu(playerid, pojazdid[playerid], KolorPierwszy[playerid], strval(inputtext), CenaPojazdu[playerid]);
				}
				else
				{
	                ShowPlayerDialogEx(playerid, 36, DIALOG_STYLE_INPUT, "Wybierz Kolor 2", "Wpisz numer koloru (od 0 do 255)", "Wybierz", "Wyjd�");
				}
			}
		    if(!response)
			{
	            pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
	            KolorPierwszy[playerid] = 0;
			}
		}
        else if(dialogid == D_AUTO_RESPRAY_OWN)
		{
		    if(response)
		    {
		        if(strval(inputtext) > 0 &&  strval(inputtext) < 255)
		        {
			        KolorPierwszy[playerid] = strval(inputtext);
			    	ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY2, DIALOG_STYLE_LIST, "Wybierz Kolor 2", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)", "Wybierz", "Wyjd�");
				}
				else
				{
				    ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY_OWN, DIALOG_STYLE_INPUT, "Wybierz Kolor 1", "Wpisz numer koloru (od 0 do 255)", "Wybierz", "Wyjd�");
				}
			}
		    if(!response)
			{
	            KolorPierwszy[playerid] = 0;
			}
		}
		else if(dialogid == D_AUTO_RESPRAY_OWN2)
		{
		    if(response)
		    {
		    	if(strval(inputtext) > 0 &&  strval(inputtext) < 255)
		        {
                    new veh = GetPlayerVehicleID(playerid);
                    if(IsCarOwner(playerid, veh))
					{
						ChangeVehicleColor(veh, KolorPierwszy[playerid], strval(inputtext));
						MRP_ChangeVehicleColor(veh, KolorPierwszy[playerid], strval(inputtext));
						SendClientMessage(playerid, 0xFFC0CB, "Pojazd przemalowany! -1500$");
						DajKase(playerid, -1500);
					}
				}
				else
				{
	                ShowPlayerDialogEx(playerid, D_AUTO_RESPRAY_OWN2, DIALOG_STYLE_INPUT, "Wybierz Kolor 2", "Wpisz numer koloru (od 0 do 126)", "Wybierz", "Wyjd�");
				}
			}
		    if(!response)
			{
	            KolorPierwszy[playerid] = 0;
			}
		}
		else if(dialogid == D_AUTO_DESTROY)
		{
		    if(response)
		    {
		        if(IsPlayerInAnyVehicle(playerid))
				{
                    if(!IsCarOwner(playerid, GetPlayerVehicleID(playerid))) return SendClientMessage(playerid, COLOR_GRAD2, "Ten pojazd nie nale�y do Ciebie.");

			        new vehicleid = GetPlayerVehicleID(playerid);
			        new giveplayer[MAX_PLAYER_NAME];
			        GetPlayerName(playerid, giveplayer, sizeof(giveplayer));
                    new string[128];
			        format(string, sizeof(string), "Auto o ID %d zosta�o zez�omowane przez %s", CarData[VehicleUID[vehicleid][vUID]][c_UID], giveplayer);
					PayLog(string);
					RemovePlayerFromVehicleEx(playerid);
					ClearAnimations(playerid);
    				SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE);

                    for(new i=0;i<MAX_CAR_SLOT;i++)
                    {
                        if(PlayerInfo[playerid][pCars][i] == VehicleUID[vehicleid][vUID])
                            PlayerInfo[playerid][pCars][i] = 0;
                    }
                    Car_Destroy(VehicleUID[vehicleid][vUID]);

	                DajKase(playerid, 5000);
					SendClientMessage(playerid, COLOR_YELLOW, "Auto zez�omowane, dostajesz 5000$");
				}
				else
				{
				    SendClientMessage(playerid, COLOR_YELLOW, "Wsi�d� do pojazdu pojazdu");
				}
			}
		}
		//System �odzi
		if(dialogid == 400)//System �odzi - panel
		{
		    if(response)
		    {
		        switch(listitem)
		        {
	                case 0://Ponton
		            {
		                ShowPlayerDialogEx(playerid, 402, DIALOG_STYLE_MSGBOX, "Kupowanie Pontonu", "Ponton\n\nCena: 2.250.000$\nPr�dko�� Maksymalna: 120km/h\nWielkosc: Ma�y\nOpis: Ma�y, zwrotny oraz szybki ponton. Idealny do emocjonalnego p�ywania po morzu. Jego cena jest przyjazna dla pocz�tkuj�cych �eglarzy. W 2 kolorach.", "Kup!", "Wr��");
				        pojazdid[playerid] = 473;
				        CenaPojazdu[playerid] = 2250000;
		            }
		            case 1://Kuter
		            {
		                ShowPlayerDialogEx(playerid, 401, DIALOG_STYLE_MSGBOX, "Kupowanie Kutra", "Kuter\n\nCena: 3.700.000$\nPr�dko�� Maksymalna: 70km/h\nWielkosc: Spory\nOpis: Jest to wolna oraz ma�o zwrotna ��d�. Idealnie nadaje si� do �owienia ryb. Pok�ad cz�ciowo zadaszony, reszta otwarta. Dost�pny w 1 kolorze.", "Kup!", "Wr��");
				        pojazdid[playerid] = 453;
				        CenaPojazdu[playerid] = 3700000;
		            }
		            case 2://Coastguard
		            {
		                ShowPlayerDialogEx(playerid, 403, DIALOG_STYLE_MSGBOX, "Kupowanie Coastguarda", "Coastguard\n\nCena: 8.500.000$\nPr�dko�� Maksymalna: 160km/h\nWielkosc: �redni\nOpis: Dosy� szybkki oraz zwrotny statek. Nie jest zadaszony, pok�ad jest pod�u�ny. U�ywany przez ratownik�w. Malowany na 2 kolory.", "Kup!", "Wr��");
				        pojazdid[playerid] = 472;
				        CenaPojazdu[playerid] = 8500000;
		            }
		            case 3://Launch
		            {
		                ShowPlayerDialogEx(playerid, 404, DIALOG_STYLE_MSGBOX, "Kupowanie Launcha", "Launch\n\nCena: 11.000.000$\nPr�dko�� Maksymalna: 150km/h\nWielkosc: �redni\nOpis: ��d� bojowa, u�ywana przez wojsko, ma pod�u�ny kad�ub. Dost�pna jest wersja cywilna z atrap� karabinu. Nie jest zbyt zwrotna i szybka, ale ma walory bojowe. Zadaszona przednia cz��. Malowana w 1 kolorze.", "Kup!", "Wr��");
				        pojazdid[playerid] = 595;
				        CenaPojazdu[playerid] = 11000000;
		            }
		            case 4://Speeder
		            {
		                ShowPlayerDialogEx(playerid, 405, DIALOG_STYLE_MSGBOX, "Kupowanie Speedera", "Speeder\n\nCena: 13.500.000$\nPr�dko�� Maksymalna: 220km/h\nWielkosc: �redni\nOpis: Typowa motor�wka: smuk�a, du�e przyspieszenie i pr�dko��. Jej zwrotno�� nie jest zachwycaj�ca ale powinna zadowoli� wi�kszo�� u�ytkownik�w. Malowana w 1 kolorze.", "Kup!", "Wr��");
				        pojazdid[playerid] = 452;
				        CenaPojazdu[playerid] = 13500000;
		            }
		            case 5://Jetmax
		            {
				        ShowPlayerDialogEx(playerid, 407, DIALOG_STYLE_MSGBOX, "Kupowanie Jetmaxa", "Jetmax\n\nCena: 20.000.000$\nPr�dko�� Maksymalna: 220km/h\nWielkosc: Spory\nOpis: Motor�wka wy�cigowa, stworzona do du�ych pr�dko�ci. Jej cecha charakterystyczna to ogromny silnik wystaj�cy z ty�u �odzi. Malowana w 2 kolorach.", "Kup!", "Wr��");
				        pojazdid[playerid] = 493;
				        CenaPojazdu[playerid] = 20000000;
		            }
		            case 6://Tropic
		            {
		                ShowPlayerDialogEx(playerid, 406, DIALOG_STYLE_MSGBOX, "Kupowanie Tropica", "Speeder\n\nCena: 25.000.000$\nPr�dko�� Maksymalna: 160km/h\nWielkosc: Du�y\nOpis: Luksusowy jacht wycieczkowy. Posiada dwa pi�tra, miejsce mieszkalne i dach. Nie jest zwrotny ale szybki. Idealny dla bogaczy.", "Kup!", "Wr��");
				        pojazdid[playerid] = 454;
				        CenaPojazdu[playerid] = 25000000;
		            }
		            case 7://Squallo
		            {
		                ShowPlayerDialogEx(playerid, 408, DIALOG_STYLE_MSGBOX, "Kupowanie Squallo", "Squallo\n\nCena: 25.000.000$\nPr�dko�� Maksymalna: 260km/h\nWielkosc: Spory\nOpis: Motor�wka luksusowo wy�cigowa. Jej pr�dko�� jest nieprzyzwoicie du�a a wygl�d i luksus sprawi� �e b�dzie si� czu� jak prawdziwy bogacz. Malowana w 2 kolorach.", "Kup!", "Wr��");
				        pojazdid[playerid] = 446;
				        CenaPojazdu[playerid] = 25000000;
		            }
		            case 8://Jacht
		            {
		                ShowPlayerDialogEx(playerid, 409, DIALOG_STYLE_MSGBOX, "Kupowanie Jachtu", "Jacht\n\nCena: 40.000.000$\nPr�dko�� Maksymalna: 80km/h\nWielkosc: Wielki\nOpis: Jacht to statek dla ludzi kt�rzy wyprawiaj� si� w mi�dzykontynentaln� przepraw� oraz pragn� luksusu. Mo�na w nim spa� i normalnie gdy� posiada spore wn�trze. Malowany w 2 kolorach.\n((UWAGA! Pojazd posiada wn�trze do kt�rego mo�na wchodzi� komend� /wejdzw))", "Kup!", "Wr��");
				        pojazdid[playerid] = 484;
				        CenaPojazdu[playerid] = 40000000;
		            }
				}
		    }
		    if(!response)
		    {
                return 1;
		    }
		}
		if(dialogid == 410)//System samolot�w - panel
		{
		    if(response)
		    {
	     		switch(listitem)
	       		{
	         		case 0://Dodo
	          		{
		                ShowPlayerDialogEx(playerid, 411, DIALOG_STYLE_MSGBOX, "Kupowanie Dodo", "Dodo\n\nCena: 50.000.000$\nPr�dko�� lotu poziomego: 150km/h\nWielkosc: Ma�y\nOpis:", "Kup!", "Wr��");
				        pojazdid[playerid] = 593;
				        CenaPojazdu[playerid] = 50000000;
		            }
		            case 1://Cropduster
		            {
		                ShowPlayerDialogEx(playerid, 412, DIALOG_STYLE_MSGBOX, "Kupowanie Cropdustera", "Cropduster\n\nCena: 35.000.000$\nPr�dko�� lotu poziomego: 140km/h\nWielkosc: �redni\nOpis:", "Kup!", "Wr��");
				        pojazdid[playerid] = 512;
				        CenaPojazdu[playerid] = 35000000;
		            }
		            case 2://Beagle
		            {
		                ShowPlayerDialogEx(playerid, 413, DIALOG_STYLE_MSGBOX, "Kupowanie Beagle", "Beagle\n\nCena: 170.000.000$\nPr�dko�� lotu poziomego: 160km/h\nWielkosc: Spory\nOpis:", "Kup!", "Wr��");
				        pojazdid[playerid] = 511;
				        CenaPojazdu[playerid] = 170000000;
		            }
		            case 3://Stuntplane
		            {
		                ShowPlayerDialogEx(playerid, 414, DIALOG_STYLE_MSGBOX, "Kupowanie Stuntplane", "Stuntplane\n\nCena: 185.000.000$\nPr�dko�� lotu poziomego: 190km/h\nWielkosc: Ma�y\nOpis:", "Kup!", "Wr��");
				        pojazdid[playerid] = 513;
				        CenaPojazdu[playerid] = 185000000;
			     	}
	        		case 4://Nevada
		            {
		                ShowPlayerDialogEx(playerid, 415, DIALOG_STYLE_MSGBOX, "Kupowanie Nevady", "Nevada\n\nCena: 280.000.000$\nPr�dko�� lotu poziomego: 205km/h\nWielkosc: Du�y\nOpis: ((UWAGA! Pojazd posiada wn�trze do kt�rego mo�na wchodzi� komend� /wejdzw))", "Kup!", "Wr��");
				        pojazdid[playerid] = 553;
				        CenaPojazdu[playerid] = 280000000;
		            }
		            case 5://Shamal
		            {
		                ShowPlayerDialogEx(playerid, 416, DIALOG_STYLE_MSGBOX, "Kupowanie Shamala", "Shamal\n\nCena: 515.250.000$\nPr�dko�� lotu poziomego: 300km/h\nWielkosc: Du�y\nOpis: Odrzutowiec ((UWAGA! Pojazd posiada wn�trze do kt�rego mo�na wchodzi� komend� /wejdzw))", "Kup!", "Wr��");
				        pojazdid[playerid] = 519;
				        CenaPojazdu[playerid] = 515250000;
		            }
		            /*case 6://Wodolotu
		            {
		                ShowPlayerDialogEx(playerid, 417, DIALOG_STYLE_MSGBOX, "Kupowanie XXXXXXXXXX", "XXXXXXXXXX\n\nCena: .000.000$\nPr�dko�� lotu poziomego: km/h\nWielkosc: \nOpis:", "Kup!", "Wr��");
				        pojazdid[playerid] = xXx;
				        CenaPojazdu[playerid] = OOOOOOOOOOOOOOOOO;
		            }*/
				}
		    }
		    if(!response)
		    {
                return 1;
		    }
		}
		if(dialogid == 420)//System helikopter�w - panel
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0://Sparrow
		            {
		                ShowPlayerDialogEx(playerid, 421, DIALOG_STYLE_MSGBOX, "Kupowanie Sparrowa", "Sparrow\n\nCena: 125.000.000$\n�rednia pr�dko�� lotu: 160km/h\nWielkosc: Ma�y\nOpis:", "Kup!", "Wr��");
				        pojazdid[playerid] = 469;
				        CenaPojazdu[playerid] = 125000000;
		            }
		            case 1://Maverick
		            {
		                ShowPlayerDialogEx(playerid, 422, DIALOG_STYLE_MSGBOX, "Kupowanie Mavericka", "Maverick\n\nCena: 200.000.000$\n�rednia pr�dko�� lotu: 180km/h\nWielkosc: �redni\nOpis:", "Kup!", "Wr��");
				        pojazdid[playerid] = 487;
				        CenaPojazdu[playerid] = 200000000;
		            }
		            case 2://Leviathan
		            {
		                ShowPlayerDialogEx(playerid, 423, DIALOG_STYLE_MSGBOX, "Kupowanie Leviathana", "Leviathan\n\nCena: 265.000.000$\n�rednia pr�dko�� lotu: 130km/h\nWielkosc: Du�y\nOpis:", "Kup!", "Wr��");
				        pojazdid[playerid] = 417;
				        CenaPojazdu[playerid] = 265000000;
		            }
		            case 3://Raindance
		            {
		                ShowPlayerDialogEx(playerid, 424, DIALOG_STYLE_MSGBOX, "Kupowanie Raindance", "Raindance\n\nCena: 325.000.000$\n�rednia pr�dko�� lotu: 100km/h\nWielkosc: Spory\nOpis:", "Kup!", "Wr��");
				        pojazdid[playerid] = 563;
				        CenaPojazdu[playerid] = 325000000;
		            }
		        }
		    }
		    if(!response)
		    {
                return 1;
		    }
		}
		if(dialogid >= 401 && dialogid <= 409)
		{
		    if(response)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybierz kolor wybranej �odzi");
	            ShowPlayerDialogEx(playerid, 31, DIALOG_STYLE_LIST, "Wybierz Kolor 1", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)\nInny", "Wybierz", "Wyjd�");
			}
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 400, DIALOG_STYLE_LIST, "Kupowanie �odzi", "Ponton\t\t2 250 000$\nKuter\t\t3 700 000$\nCoastguard\t8 500 000$\nLaunch\t\t11 000 000$\nSpeeder\t13 500 000$\nJetmax\t\t20 000 000$\nTropic\t\t25 000 000$\nSquallo\t\t25 000 000$\nJacht\t\t40 000 000$", "Wybierz", "Wyjd�");
	            pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
			}
		}
		if(dialogid >= 411 && dialogid <= 417)
		{
		    if(response)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybierz kolor wybranego samolotu");
	            ShowPlayerDialogEx(playerid, 31, DIALOG_STYLE_LIST, "Wybierz Kolor 1", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)\nInny", "Wybierz", "Wyjd�");
			}
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 410, DIALOG_STYLE_LIST, "Kupowanie samolotu", "Dodo\t\t50 000 000$\nCropduster\t35 000 000$\nBeagle\t\t170 000 000$\nStuntplane\t185 000 000$\nNevada\t\t280 000 000$\nShamal\t\t515 250 000$", "Wybierz", "Wyjd�");
	            pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
			}
		}
		if(dialogid >= 421 && dialogid <= 424)
		{
		    if(response)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybierz kolor wybranego helikopteru");
	            ShowPlayerDialogEx(playerid, 31, DIALOG_STYLE_LIST, "Wybierz Kolor 1", "Czarny\nBialy\nJasno-niebieski\nCzerwony\nZielony\nR�owy\n��ty\nNiebieski\nSzary\nJasno-czerwony\nJasno-zielony\nFioletowy\nInny (Numer)\nInny", "Wybierz", "Wyjd�");
			}
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 420, DIALOG_STYLE_LIST, "Kupowanie Helikopteru", "Sparrow\t\t125 000 000$\nMaverick\t\t200 000 000$\nLeviathan\t\t265 000 000$\nRaindance\t\t325 000 000$", "Wybierz", "Wyjd�");
	            pojazdid[playerid] = 0;
	            CenaPojazdu[playerid] = 0;
			}
		}
		//logowanie w GUI
		if(dialogid == D_LOGIN)
		{
		    if(response)
		    {
			    if(IsPlayerConnected(playerid))
			    {
			        if(strlen(inputtext) >= 1 && strlen(inputtext) <= 64)
			        {
						OnPlayerLogin(playerid, inputtext);
					}
					else
					{
	        			SendClientMessage(playerid, COLOR_PANICRED, "Zosta�e� zkickowany za niewpisanie has�a!");
			            ShowPlayerDialogEx(playerid, 239, DIALOG_STYLE_MSGBOX, "Kick", "Zosta�e� zkickowany z powodu bezpiecze�stwa za wpisanie pustego has�a. Zapraszamy ponownie.", "Wyjd�", "");
	                    GUIExit[playerid] = 0;
	                    SetPlayerVirtualWorld(playerid, 0);
						KickEx(playerid);
					}
				}
			}
			if(!response)
			{
				SendClientMessage(playerid, COLOR_PANICRED, "Wyszed�e� z serwera, zosta�e� roz��czony. Zapraszamy ponownie!");
	            ShowPlayerDialogEx(playerid, 239, DIALOG_STYLE_MSGBOX, "Kick", "Wyszed�e� z logowania, zosta�e� roz��czony. Zapraszamy ponownie!", "Wyjd�", "");
	            GUIExit[playerid] = 0;
	            SetPlayerVirtualWorld(playerid, 0);
				KickEx(playerid);
			}
			return 1;
		}
		if(dialogid == D_REGISTER)
		{
		    if(response)
		    {
		        if(IsPlayerConnected(playerid))
			    {
			        if(strlen(inputtext) >= 1 && strlen(inputtext) <= 64)
			        {
						OnPlayerRegister(playerid, inputtext);
						GUIExit[playerid] = 0;
						SetPlayerVirtualWorld(playerid, 0);
					}
					else
					{
					    SendClientMessage(playerid, COLOR_PANICRED, "Zosta�e� zkickowany za niewpisanie has�a!");
			            ShowPlayerDialogEx(playerid, 239, DIALOG_STYLE_MSGBOX, "Kick", "Zosta�e� zkickowany z powodu bezpiecze�stwa za wpisanie pustego lub zbyt d�ugiego has�a. Zapraszamy ponownie.", "Wyjd�", "");
	                    GUIExit[playerid] = 0;
	                    SetPlayerVirtualWorld(playerid, 0);
						KickEx(playerid);
					}
				}
				return 1;
	   		}
		    if(!response)
		    {
		        SendClientMessage(playerid, COLOR_PANICRED, "Wyszed�e� z serwera, zosta�e� roz��czony. Zapraszamy ponownie!");
	            ShowPlayerDialogEx(playerid, 239, DIALOG_STYLE_MSGBOX, "Kick", "Wyszed�e� z rejestracji, zosta�e� roz��czony. Zapraszamy ponownie!", "Wyjd�", "");
				KickEx(playerid);
		    }
		}
		if(dialogid == 235)
		{
		    if(response)
		    {
		        if(strlen(inputtext) >= 1 && strlen(inputtext) <= 64)
			    {
			        if(strcmp(inputtext,"SiveMopY", false) == 0 )//WiE772Min Zi3EeL$sKoXnUBy RaTMiiN67
			        {
						weryfikacja[playerid] = 1;
                        if(PlayerInfo[playerid][pJailed] == 0)
                        {
                            lowcap[playerid] = 1;
                            ShowPlayerDialogEx(playerid, 1, DIALOG_STYLE_MSGBOX, "Serwer", "Czy chcesz si� teleportowa� do poprzedniej pozycji?", "TAK", "NIE");
                        }
                        else
                        {
                            SetSpawnInfo(playerid, PlayerInfo[playerid][pTeam], PlayerInfo[playerid][pModel], PlayerInfo[playerid][pPos_x], PlayerInfo[playerid][pPos_y], PlayerInfo[playerid][pPos_z], 1.0, -1, -1, -1, -1, -1, -1);
                            TogglePlayerSpectating(playerid, false);
							SpawnPlayer(playerid);
                        }
					}
			        else
			        {
			            SendClientMessage(playerid, COLOR_PANICRED, "Zosta�e� zkickowany.!");
				        ShowPlayerDialogEx(playerid, 239, DIALOG_STYLE_MSGBOX, "Kick", "Zosta�e� zkickowany.", "Wyjd�", "");
				        GUIExit[playerid] = 0;
				        SetPlayerVirtualWorld(playerid, 0);
						KickEx(playerid);
			        }
			    }
			    else
			    {
					SendClientMessage(playerid, COLOR_PANICRED, "Zosta�e� zkickowany za niewpisanie has�a!");
					ShowPlayerDialogEx(playerid, 239, DIALOG_STYLE_MSGBOX, "Kick", "Zosta�e� zkickowany z powodu bezpiecze�stwa za wpisanie pustego lub zbyt d�ugiego has�a. Zapraszamy ponownie.", "Wyjd�", "");
					GUIExit[playerid] = 0;
				    SetPlayerVirtualWorld(playerid, 0);
					KickEx(playerid);
			    }
		    }
		    if(!response)
		    {
		        SendClientMessage(playerid, COLOR_PANICRED, "Wyszed�e� z weryfikacji, zosta�e� roz��czony!");
	            ShowPlayerDialogEx(playerid, 239, DIALOG_STYLE_MSGBOX, "Kick", "Wyszed�e� z weryfikacji, zosta�e� roz��czony!", "Wyjd�", "");
	            GUIExit[playerid] = 0;
	            SetPlayerVirtualWorld(playerid, 0);
				KickEx(playerid);
		    }
		}
		if(dialogid == 237)
		{
		    if(response)
		    {
		        if(strlen(inputtext) >= 1 && strlen(inputtext) <= 50)
			    {
			        if(strcmp(inputtext,"TheGFPower69", false) == 0)//Zi3EeL$sKoXnUBy WiE772Min
			        {
					    weryfikacja[playerid] = 1;
					    new gf[64], nickbrusz[MAX_PLAYER_NAME];
			        	GetPlayerName(playerid, nickbrusz, sizeof(nickbrusz));
						format(gf, sizeof(gf), "Admini/%s.ini", nickbrusz);
					    if(!dini_Exists(gf))
				        {
				            dini_Create(gf);
				            dini_IntSet(gf, "Godziny_Online", 0);
							dini_FloatSet(gf, "Realna_aktywnosc", 0);
							dini_IntSet(gf, "Ilosc_Kickow", 0);
							dini_IntSet(gf, "Ilosc_Banow", 0);
				        }
					    OnPlayerLogin(playerid, "GuL973TekeSTDz4-36");
					}
			        else
			        {
			            SendClientMessage(playerid, COLOR_PANICRED, "Zosta�e� zkickowany.!");
				        ShowPlayerDialogEx(playerid, 239, DIALOG_STYLE_MSGBOX, "Kick", "Zosta�e� zkickowany.", "Wyjd�", "");
				        GUIExit[playerid] = 0;
				        SetPlayerVirtualWorld(playerid, 0);
						KickEx(playerid);
			        }
			    }
			    else
			    {
			        SendClientMessage(playerid, COLOR_PANICRED, "Zosta�e� zkickowany.!");
				    ShowPlayerDialogEx(playerid, 239, DIALOG_STYLE_MSGBOX, "Kick", "Zosta�e� zkickowany.", "Wyjd�", "");
				    GUIExit[playerid] = 0;
				    SetPlayerVirtualWorld(playerid, 0);
					KickEx(playerid);
			    }
		    }
		    if(!response)
		    {
		        SendClientMessage(playerid, COLOR_PANICRED, "Wyszed�e� z weryfikacji, zosta�e� roz��czony!");
	            ShowPlayerDialogEx(playerid, 239, DIALOG_STYLE_MSGBOX, "Kick", "Wyszed�e� z weryfikacji, zosta�e� roz��czony!", "Wyjd�", "");
	            GUIExit[playerid] = 0;
	            SetPlayerVirtualWorld(playerid, 0);
				KickEx(playerid);
		    }
		}
	 	if(dialogid == 325)
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
	                {
	                    if(Kredyty[playerid] >= 10)
	                    {
	                    	SetPlayerPosEx(playerid, 578.9954,-2194.5471,7.1380);//trampolina 5m
				        	GameTextForPlayer(playerid, "~w~Wysokosc 5m ~r~Pobrano 10 kredytow", 5000, 1);
				        	Kredyty[playerid] -= 10;
				        }
				        else
				        {
				            SendClientMessage(playerid, COLOR_GREY, "Nie masz 10 kredyt�w.");
				        }
	                }
	                case 1:
	                {
	                    if(Kredyty[playerid] >= 20)
	                    {
		                    SetPlayerPosEx(playerid, 577.5804,-2194.8018,12.1380);//trampolina 10m
					        GameTextForPlayer(playerid, "~w~Wysokosc 10m ~r~Pobrano 20 kredytow", 5000, 1);
					        Kredyty[playerid] -= 20;
	                    }
				        else
				        {
				            SendClientMessage(playerid, COLOR_GREY, "Nie masz 20 kredyt�w.");
				        }
	                }
		        }
		    }
		}
		if(dialogid == 324)//wybieralka wej�� FBI
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
					{
						SetPlayerPosEx(playerid, -653.34765625,-5448.5634765625,13.368634223938);
						TogglePlayerControllable(playerid, 0);
						SetPlayerInterior(playerid, 0);
                        Wchodzenie(playerid);
		                SetPlayerInterior(playerid, 8);
		                ShowPlayerDialogEx(playerid, 999, DIALOG_STYLE_MSGBOX, "Strzelnica FBI", "Kryta strzelnica pozwal�ca �wiczy� celno�� z deagl'a mp5 i innych broni\n Zadanie polega na zestrzeleniu jak najwi�kszej liczby manekin�w w czasie ustalonym przez prowadz�cego trening\n Ka�dy celny strza� to 1 punkt\n Obowi�zuje zasada: 1 niecelny strza� = 1 punkt mniej\n (( aby sprawdzi� ile naboi ma agent u�yj /sb [ID]))", "Rozpocznij", "Wyjd�");//Strzelnica FBI �rodek
					}
					case 1:
					{
					    new txt1[1024] = "Dzi�ki tej sprzelnicy na otwartym powietrzu mo�na �wiczy� precyzyjne i dok�adne strza�y z m4,mp5 i rifle\n Cele s� dwucz�ciowe: sk�adaj� si� z g�owy i reszty cia�a\n Zalecane s�: 3 pkt za strza� w g�ow� i 1pkt za strza� w cel\n ";
					    new txt2[512] = "W tym �wiczeniu nie przewidziano ogranicze� czasowych\n, agent oddaje strza� tylko do jednego celu zu�ywaj�c max 3 naboje\n Zniszczenie budki w kt�rej stoi cel skutkuje niezaliczeniem zadania";
					    strcat(txt1, txt2, sizeof(txt1));
					    SetPlayerPosEx(playerid, 1703.9327392578,141.29598999023,30.903503417969);
						TogglePlayerControllable(playerid, 0);
						SetPlayerInterior(playerid, 0);
                        Wchodzenie(playerid);
		                ShowPlayerDialogEx(playerid, 999, DIALOG_STYLE_MSGBOX, "Strzelnica terenowa FBI", txt1, "Rozpocznij", "Wyjd�");//sTRZELNICA TERENOWA
					}
					case 2:
					{
					    SetPlayerPosEx(playerid, 1581.8731689453,5490.7412109375,329.73870849609);
						TogglePlayerControllable(playerid, 0);
						SetPlayerInterior(playerid, 0);
						GivePlayerWeapon(playerid, 46, 1);
                        Wchodzenie(playerid);
		                ShowPlayerDialogEx(playerid, 999, DIALOG_STYLE_MSGBOX, "Wie�a spadochroniarska", "Nale�y odpowiednio przeprowadzi� atak z powietrza\n Zadanie polega na wyl�dowaniu na specjalnej tarczy, ilo�c przyznawanych punkt�w jest zale�na od precyzji l�dowania\n Dla zaawansowanych agent�w przewidziano r�wnie� trening p�ywacki\n nale�y przep�yn�� przez rur� znajduj�c� sie pod wod� i wyp�yn�� na powierzchni�.", "Rozpocznij", "Wyjd�");//spadochrin wej�cie �rodek
					}
					case 3:
					{
					    new txt1[1024] = "W opuszczonym domu przest�pcy przetrzymuj� zak�adnik�w\n Zadanie polega na zlikwidowaniu wszytkich przest�pc�w (kobiety) bez �adnych strat w cywilach ( ludzie nieuzbrojeni i m�czy�ni)\n Czas na wykonanie zadania to 1minuta\n Zu�ycie naboi to max 40\n Prowadz�cy trening musi znajdowa� si� w pomieszczeniu aby po 1 minucie podliczy� wyniki agenta\n Na torze znajduje si� 17 zak�adnik�w i 17 bandyt�w";
					    new txt2[512] = "\n Na torze znajduj� sie r�wnie� headshoty i zadanie na celno��\n Zaleca si� przyznawa� 1 pkt za przest�pce -5pkt za zak�adnika 2pkt za headshot oraz 5 pkt za manekina\n Czas powy�ej 1:30sek oraz zu�ycie wi�cej ni� 40 naboi skutkuje niezaliczeniem zadania";
					    strcat(txt1, txt2, sizeof(txt1));
					    SetPlayerPosEx(playerid, 2236.0786132813,-6891.2177734375,21.423152923584);
						TogglePlayerControllable(playerid, 0);
						SetPlayerInterior(playerid, 8);
                        Wchodzenie(playerid);
		                ShowPlayerDialogEx(playerid, 999, DIALOG_STYLE_MSGBOX, "Szturm na dom", txt1, "Kontynuuj", "Wyjd�");
					}
				}
		    }
		}
		if(dialogid == 60)//cofaczka zmian nick�w
		{
		    if(response)
		    {
				new string [64];
		        switch(listitem)
				{
				    case 0:
					{
						if (kaska[playerid] >= 60000000)
						{
							PlayerInfo[playerid][pZmienilNick] ++;
							format(string, sizeof(string), "%s[%d] cofn��e� jedn� zmian� nicku. Ilo�� wykorzystanych zmian zobaczysz w /stats.",GetNick(playerid),PlayerInfo[playerid][pUID]);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, "Koszt: 60.000.000$");
							NickLog(string);
							DajKase(playerid, -60000000);
						}
						else
						{
							SendClientMessage(playerid, COLOR_GREY, "Nie masz tyle!");
						}
					}
					case 1:
					{
						if (kaska[playerid] >= 25000000 && PlayerInfo[playerid][pExp] >= 180)
						{
							format(string, sizeof(string), "%s cofn��e� jedn� zmian� nicku. Ilo�� wykorzystanych zmian zobaczysz w /stats.",GetNick(playerid));
							NickLog(string);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, "Koszt: 25.000.000$ i 180 punkt�w respektu");
							PlayerInfo[playerid][pZmienilNick] --;
							DajKase(playerid, -25000000);
							PlayerInfo[playerid][pExp] -=180;
						}
						else
						{
							SendClientMessage(playerid, COLOR_GREY, "Nie masz tyle!");
						}
					}
					case 2:
					{
					    if (PlayerInfo[playerid][pExp] >= 340)
						{
							format(string, sizeof(string), "%s cofn��e� jedn� zmian� nicku. Ilo�� wykorzystanych zmian zobaczysz w /stats.",GetNick(playerid));
							NickLog(string);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, "Koszt: 340 punkt�w respektu");
							PlayerInfo[playerid][pZmienilNick] --;
							PlayerInfo[playerid][pExp] -=340;
						}
						else
						{
							SendClientMessage(playerid, COLOR_GREY, "Nie masz tyle!");
						}
					}
					case 3:
					{

						SendClientMessage(playerid,COLOR_P@,"|_________________________Odj�cie zmiany nicku_________________________|");
						SendClientMessage(playerid,COLOR_WHITE,"Zmiana nicku to dobra rzecz. Jednak wszytko co dobre kiedy� si� ko�czy :c ");
						SendClientMessage(playerid,COLOR_WHITE,"Dlatego umo�liwili�my wam zmiany nicku w dowolnym momencie po wykorzystaniu wszytkich 10 zmian");
						SendClientMessage(playerid,COLOR_WHITE,"Ka�da z opcji jest odpowiednio wywa�ona. Mo�emy wybra� czy wolimy zyska� zmian� cz�st� gr� czy pieni�dzmi.");
						SendClientMessage(playerid,COLOR_WHITE,"Opcja jest dost�pna tylko dla 3lvl KP poniewa� teorytycznie inni mog� zwi�kszy� limit zmian nick�w.");
						SendClientMessage(playerid,COLOR_WHITE,"Wybranie jednej z trzech opcji powoduje ODJ�CIE jednej zmiany nicku.");
						SendClientMessage(playerid,COLOR_WHITE,"Gdy zdob�dziesz ju� odj�cie zmiany nie musisz od razu zmienia� nicku od razu. Mozesz to zrobi� kiedy chcesz.");
						SendClientMessage(playerid,COLOR_P@,"|________________________>>> Pomoc <<<________________________|");
					}
				}
		    }
		}
		if(dialogid == 68)
		{
		    if(response)
		    {			
				switch(listitem)
				{
				    case 0:
					{
						ShowPlayerDialogEx(playerid,61,DIALOG_STYLE_LIST,"Wykroczenia przeciwko porz�dkowi i bezpiecze�stwu publicznemu","Art. 1. U�ywanie wulgaryzm�w do: 5SD\nArt. 2. Namawianie do pope�niania przest�pstwa do: 10SD\nArt. 3. Ekshibicjonizm do 15SD\nArt. 4. Czynno�ci o char. seks. w miejscu pub.: do 20SD\nArt. 5. Nieuzasadnionie mierzenie z broni do ludzi: do 30SD + konfiskata broni\nArt. 6. Podszywanie si� pod s�u�by porz�dkowe: od 25SD do 50SD","Cofnij","");
					}
					case 1:
					{
						ShowPlayerDialogEx(playerid,62,DIALOG_STYLE_LIST,"Posiadanie nielegalnych przedmiot�w","Art. 7. Posiadanie narkotyk�w: do 40SD + konfiskata narkotyk�w\nArt. 8. Bro� bez licencji: 40SD + konfiskata broni\nAkt o BC Bro� ci�ka: od 30 do 50SD + konfiskata broni i licencji na bro�\nKK Posiadanie materia��w: +1WL + konfiskata materia��w","Cofnij","");
					}
					case 2:
					{
						ShowPlayerDialogEx(playerid,63,DIALOG_STYLE_LIST,"Wykroczenia przeciwko mieniu i zdrowiu","Art. 9. Udzia� w b�jce: do 10SD\nArt. 10. Kradzie� pojazdu mechanicznego: do 15SD\nArt. 11. Niszczenie cudzego mienia: do 25SD\nArt. 12. Pobicie: od 10 SD do 30 SD","Cofnij","");
					}
					case 3:
					{
						ShowPlayerDialogEx(playerid,64,DIALOG_STYLE_LIST,"Wykroczenia przeciwko godno�ci osobistej","Art. 13. Zniewa�enie os�b trzecich: do 5SD\nArt. 14. Gro�by karalne: do 10SD\nArt. 15. Obraza policjanta: do 15SD\nArt. 16. Hate crime: do 20SD","Cofnij","");
					}
					case 4:
					{
						ShowPlayerDialogEx(playerid,65,DIALOG_STYLE_LIST,"Utrudnianie dzia�a� policji","Art. 17. Brak dowodu osobistego lub licencji: 5SD za ka�dy dokument\nArt. 18. Nieumy�lne utrudnienie po�cigu policyjnego: do 20SD\nArt. 19. Bierny op�r (nie reagowanie na polecenia policjanta): do 35SD","Cofnij","");
					}
					case 5:
					{
						ShowPlayerDialogEx(playerid,66,DIALOG_STYLE_LIST,"Wykroczenia przeciwko bezpiecze�stwu w ruchu drogowym","Art. 20. Brak w��czonych �wiate� w nocy: 5SD\nArt. 21. Jazda po chodniku: do 10SD\nArt. 22. Post�j w miejscu do tego nieprzeznaczonym: do 10SD\nArt. 23. Spowodowanie innego zagro�enia w ruchu drogowym: do 20SD\nArt. 24. Spowodowanie wypadku: od 10SD do 20SD\nArt. 25. Prowadzenie pod wp�ywem �rodk�w odurzaj�cych: 50SD\n\t\t + konfiskata prawa jazdy","Cofnij","");
					}
					case 6:
					{
						ShowPlayerDialogEx(playerid,67,DIALOG_STYLE_LIST,"Niew�a�ciwe korzystanie z drogi","Art. 26. Nieuzasadnione, d�ugotrwa�e przebywanie pieszego na drodze: do 5SD\nArt. 27. Z�e parkowanie: od 5SD do 10SD\nArt. 28. L�dowanie w miejscu do tego nieprzeznaczonym: 15SD\n\tArt. 28 par. 1. Powoduj�ce zagro�enie w ruchu drogowym: \n\t\tod 15SD do 30SD + konfiskata licencji pilota\nArt. 29. Posiadanie przyciemnionych szyb: 40SD + demonta� szyb","Cofnij","");
					}
					case 7:
					{
						SendClientMessage(playerid,COLOR_P@,"|_________________________Pomoc prawna_________________________|");
						SendClientMessage(playerid,COLOR_WHITE,"Stawka Dzienna (SD) - 10%% nadchodz�cej wyp�atyStawka Dzienna (SD) - 10%% nadchodz�cej wyp�aty. ");
						SendClientMessage(playerid,COLOR_WHITE,"W niejszym zbiorze zamieszczono wszytkie przewinienia za kt�re prawo przewiduje wr�czenie mandatu.");
						SendClientMessage(playerid,COLOR_WHITE,"Kary zosta�y pogrupowane na VII dzia��w aby je zobaczy� nale�y klikn�c na wybrany dzia�.");
						SendClientMessage(playerid,COLOR_WHITE,"{3CB371}Wykr. przec. bezp. i porz. pub.{FFFFFF} - zawier� g��wnie kary za �amanie zasad kultury i dobrego zachowania");
						SendClientMessage(playerid,COLOR_WHITE,"{3CB371}Wykr. przec. bezp. w ruchu drogowym {FFFFFF}- znajdziecie tutaj kary za ci�kie przewinienia zwi�zane z kierowaniem pojazdami");
						SendClientMessage(playerid,COLOR_WHITE,"{3CB371}Niew�. korzystanie z drogi{FFFFFF} - tutaj znajduj� kary lekkie przewinienia w RD oraz niedozwolone modyfikacje pojazd�w.");
						SendClientMessage(playerid,COLOR_WHITE,"");
						SendClientMessage(playerid,COLOR_WHITE,"{3CB371}PODPOWIED�:{FFFFFF}  Zamiast podawa� pe�n� nazw� wykroczenia mo�esz poda� numer artyku�u");
						SendClientMessage(playerid,COLOR_WHITE,"Przyk�adowo: mo�esz w powodzie napisa�: {CD5C5C}'art. 26KW'{FFFFFF} ZAMIAST 'nieuzasadnione, d�ugotrwa�e przebywanie pieszego na drodze'");
						SendClientMessage(playerid,COLOR_P@,"|________________________>>> Kancelaria M&M <<<________________________|");
					}
				}
		    }
		}
		if(dialogid >= 61 && dialogid <= 67)
		{
		    if(response)
		    {
				ShowPlayerDialogEx(playerid,68,DIALOG_STYLE_LIST,"Kodeks wykrocze�: wybierz dzia�","Wykroczenia przeciwko porz�dkowi i bezpiecze�stwu publicznemu\nPosiadanie nielegalnych przedmiot�w\nWykroczenia przeciwko mieniu i zdrowiu\nWykroczenia przeciwko godno�ci osobistej\nUtrudnianie dzia�a� policji\nWykroczenia przeciwko bezpiecze�stwu w ruchu drogowym\nNiew�a�ciwe korzystanie z drogi\nInformacje","Wybierz","Wyjd�");
			}
		}
		if(dialogid == 323)//wybieralka wej�� SAN
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
					{
					    if(drukarnia == 0 || PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLider] == 9)
					    {
						    SetPlayerPosEx(playerid, 1817.9636230469,-1314.1984863281,109.95202636719);
							TogglePlayerControllable(playerid, 0);
                            Wchodzenie(playerid);
			                sanwyjdz[playerid] = 1;
			                SetPlayerVirtualWorld(playerid, 0);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Drukarnia jest zamkni�ta i biura SAN s� zamkni�te");
			            }
					}
					case 1:
					{
					    if(studiovic == 0 || PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLider] == 9)
					    {
						    SetPlayerPosEx(playerid, -1768.1467285156,1537.67578125,4767.3256835938);
							TogglePlayerControllable(playerid, 0);
                            Wchodzenie(playerid);
			                SetPlayerInterior(playerid, 13);
                   			sanwyjdz[playerid] = 1;
                   			SetPlayerVirtualWorld(playerid, 0);
		                }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Studio Victim jest zamkni�te");
			            }
					}
					case 2:
					{
					    if(studiog == 0 || PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLider] == 9)
					    {
						    SetPlayerPosEx(playerid, 702.70550537109,-1382.9512939453,-93.994110107422);
							TogglePlayerControllable(playerid, 0);
                            Wchodzenie(playerid);
			                SetPlayerInterior(playerid, 13);
			                sanwyjdz[playerid] = 1;
			                SetPlayerVirtualWorld(playerid, 0);

		                }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Studio G��wne jest zamkni�te");
			            }
					}
					case 3:
					{
					    if(studion == 0 || PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLider] == 9)
					    {
						    SetPlayerPosEx(playerid, -2928.0815429688,3636.6806640625,693.05780029297);
							TogglePlayerControllable(playerid, 0);
                            Wchodzenie(playerid);
			                SetPlayerInterior(playerid, 13);
			                sanwyjdz[playerid] = 1;
			                SetPlayerVirtualWorld(playerid, 0);
		                }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Studio Nagra� jest zamkni�te");
			            }
					}
					case 4:
					{
					    if(biurosan == 0 || PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLider] == 9)
					    {
						    SetPlayerPosEx(playerid, 1833.8078613281,-1275.3975830078,109.40234375);
							TogglePlayerControllable(playerid, 0);
                            Wchodzenie(playerid);
			                sanwyjdz[playerid] = 1;
			                SetPlayerVirtualWorld(playerid, 0);
		                }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Gabinet dyrektora jest zamkni�ty");
			            }
  					}
					case 5:
					{
					    if(drukarnia == 0 || PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLider] == 9)
					    {
						    SetPlayerPosEx(playerid, 736.890625,-1373.8778076172,30.01620674133);
							TogglePlayerControllable(playerid, 0);
                            Wchodzenie(playerid);
			                SetPlayerVirtualWorld(playerid, 31);
		                }
					}
				}
		    }
		}
		if(dialogid == 322)//zamykanie studi�w SAN
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0:
				    {
				        if(drukarnia == 0)
				        {
				            drukarnia = 1;
				            SendClientMessage(playerid, COLOR_NEWS, "Drukarnia zamkni�ta");
				        }
				        else
				        {
				            drukarnia = 0;
				            SendClientMessage(playerid, COLOR_NEWS, "Drukarnia otwarta");
				        }
				    }
				    case 1:
				    {
				        if(studiovic == 0)
				        {
				            studiovic = 1;
				            SendClientMessage(playerid, COLOR_NEWS, "Studio Victim zamkni�te");
				        }
				        else
				        {
				            studiovic = 0;
				            SendClientMessage(playerid, COLOR_NEWS, "Studio Victim otwarte");
				        }
				    }
				    case 2:
				    {
				        if(studiog == 0)
				        {
				            studiog = 1;
				            SendClientMessage(playerid, COLOR_NEWS, "Studio g��wne zamkni�te");
				        }
				        else
				        {
				            studiog = 0;
				            SendClientMessage(playerid, COLOR_NEWS, "Studio g��wne otwarte");
				        }
				    }
				    case 3:
				    {
				        if(studion == 0)
				        {
				            studion = 1;
				            SendClientMessage(playerid, COLOR_NEWS, "Studio nagra� zamkni�te");
				        }
				        else
				        {
				            studion = 0;
				            SendClientMessage(playerid, COLOR_NEWS, "Studio nagra� otwarte");
				        }
				    }
				    case 4:
				    {
				        if(biurosan == 0)
				        {
				            biurosan = 1;
				            SendClientMessage(playerid, COLOR_NEWS, "Gabinet red. naczelnego zamkni�ty");
				        }
				        else
				        {
				            biurosan = 0;
				            SendClientMessage(playerid, COLOR_NEWS, "Gabinet red. naczelnego otwarty");
				        }
				    }
				}
			}
		}
		if(dialogid == 70)
		{
		    if(response)
		    {
		        ShowPlayerDialogEx(playerid, 71, DIALOG_STYLE_LIST, "Wybierz p�e�", "M�czyzna\nKobieta", "Dalej", "Wstecz");
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 71, DIALOG_STYLE_LIST, "Wybierz p�e�", "M�czyzna\nKobieta", "Dalej", "Wstecz");
		    }
		}
		if(dialogid == 71)
		{
		    if(response)
		    {
		        switch(listitem)
				{
				    case 0://men
				    {
				        ShowPlayerDialogEx(playerid, 72, DIALOG_STYLE_LIST, "Wybierz pochodzenie", "USA\nEuropa\nAzja", "Dalej", "Wstecz");//Ameryka P�nocna\nAmeryka �rodkowa\nAmeryka Po�udniowa\nAfryka\nAustralia\nEuropa Wschodnia\nEuropa Zachodnia\nAzja
	                    PlayerInfo[playerid][pSex] = 1;
	                    SendClientMessage(playerid, COLOR_NEWS, "Twoja posta� jest m�czyzn�.");
					}
				    case 1://baba
				    {
				        ShowPlayerDialogEx(playerid, 72, DIALOG_STYLE_LIST, "Wybierz pochodzenie", "USA\nEuropa\nAzja", "Dalej", "Wstecz");//Ameryka P�nocna\nAmeryka �rodkowa\nAmeryka Po�udniowa\nAfryka\nAustralia\nEuropa Wschodnia\nEuropa Zachodnia\nAzja
	                    PlayerInfo[playerid][pSex] = 2;
	                    SendClientMessage(playerid, COLOR_NEWS, "Twoja posta� jest kobiet�.");
					}
				}
			}
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 70, DIALOG_STYLE_MSGBOX, "Witaj na Mrucznik Role Play", "Witaj na serwerze Mrucznik Role Play\nJe�li jeste� tu nowy, to przygotowali�my dla ciebie 2 poradniki\nZa chwil� b�dziesz m�g� je obejrze�, lecz najpierw musisz opisa� posta� kt�r� b�dziesz gra�\n�yczymy mi�ej gry.", "Dalej", "");
		    }
		}
		if(dialogid == 72)
		{
		    if(response)
		    {
				switch(listitem)
				{
				    case 0://usa
				    {
				        PlayerInfo[playerid][pOrigin] = 1;
				        SendClientMessage(playerid, COLOR_NEWS, "Twoja posta� jest teraz obywatelem USA.");
				    }
				    case 1://europa
				    {
				        PlayerInfo[playerid][pOrigin] = 2;
				        SendClientMessage(playerid, COLOR_NEWS, "Twoja posta� jest teraz Europejskim imigrantem.");
				    }
				    case 2://azja
				    {
				        SendClientMessage(playerid, COLOR_NEWS, "Twoja posta� jest teraz Azjatyckim imigrantem.");
				        PlayerInfo[playerid][pOrigin] = 3;
				    }
				}
				ShowPlayerDialogEx(playerid, 73, DIALOG_STYLE_INPUT, "Wybierz wiek postaci", "Wpisz wiek swojej postaci (od 16 do 140 lat)", "Dalej", "Wstecz");
			}
			if(!response)
			{
			    ShowPlayerDialogEx(playerid, 71, DIALOG_STYLE_LIST, "P�e�", "M�czyzna\nKobieta", "Dalej", "Wstecz");
			}
		}
		if(dialogid == 73)
		{
		    if(response)
		    {
		        if(strlen(inputtext) > 1 && strlen(inputtext) < 4)
	            {
	                if(strval(inputtext) >= 16 && strval(inputtext) <= 140)
	                {
	                    PlayerInfo[playerid][pAge] = strval(inputtext);
						ShowPlayerDialogEx(playerid, 74, DIALOG_STYLE_MSGBOX, "Samouczek", "To ju� wszystkie dane jakie musia�e� poda�. Teraz musisz przej�� samouczek.\nAby go rozpocz�� wci�nij 'dalej'", "Dalej", "Wstecz");
	                }
	                else
	                {
	                    ShowPlayerDialogEx(playerid, 73, DIALOG_STYLE_INPUT, "Wiek postaci", "Wpisz wiek swojej postaci (od 16 do 140 lat)", "Dalej", "Wstecz");
	                }
	            }
	            else
	            {
	                ShowPlayerDialogEx(playerid, 73, DIALOG_STYLE_INPUT, "Wiek postaci", "Wpisz wiek swojej postaci (od 16 do 140 lat)", "Dalej", "Wstecz");
	            }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 72, DIALOG_STYLE_LIST, "Pochodzenie", "USA\nEuropa\nAzja", "Dalej", "Wstecz");//Ameryka P�nocna\nAmeryka �rodkowa\nAmeryka Po�udniowa\nAfryka\nAustralia\nEuropa Wschodnia\nEuropa Zachodnia\nAzja
		    }
		}
		if(dialogid == 74)
		{
            if(PlayerInfo[playerid][pLevel] > 1) return 1;
		    if(response)
		    {
		        gOoc[playerid] = 1; gNews[playerid] = 1; gFam[playerid] = 1;
				TogglePlayerControllable(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
				GUIExit[playerid] = 0;
		   		SendClientMessage(playerid, COLOR_YELLOW, "Witaj na Mrucznik Role Play serwer.");
				SendClientMessage(playerid, COLOR_WHITE, "Nie jest to serwer Full-RP ale obowi�zuj� tu podstawowe zasady RP.");
				SendClientMessage(playerid, COLOR_WHITE, "Je�li ich nie znasz przybli�e ci najwa�niejsz� zasade.");
				SendClientMessage(playerid, COLOR_LIGHTBLUE, "Obowi�zuje absolutny zakaz DeathMatch`u(DM)");
				SendClientMessage(playerid, COLOR_WHITE, "Co to jest DM? To zabijanie graczy na serwerze bez konkretnego powodu.");
				SendClientMessage(playerid, COLOR_WHITE, "Chodzi o to, �e w prawdziwym �yciu, nie zabija�by� wszystkich dooko�a.");
				SendClientMessage(playerid, COLOR_WHITE, "Wi�c je�li chcesz kogo� zabi�, musisz mie� wa�ny pow�d.");
				SendClientMessage(playerid, COLOR_WHITE, "OK, znasz ju� najwa�niejsz� zasad�, reszt� poznasz p�niej.");
	   			TutTime[playerid] = 1;
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 73, DIALOG_STYLE_INPUT, "Wiek postaci", "Wpisz wiek swojej postaci (od 16 do 140 lat)", "Dalej", "Wstecz");
		    }
		}
		if(dialogid == 123)
		{
		    if(response)
		    {
				if(DomOgladany[playerid] == 0)
				{
	                for(new i; i <= dini_Int("Domy/NRD.ini", "NrDomow"); i++)
				    {
						if(IsPlayerInRangeOfPoint(playerid, 3.0, Dom[i][hWej_X], Dom[i][hWej_Y], Dom[i][hWej_Z]))
						{
							if(Dom[i][hKupiony] == 0)
							{
	          					new deem = Dom[i][hDomNr];
						        SetPlayerPosEx(playerid, IntInfo[deem][Int_X], IntInfo[deem][Int_Y], IntInfo[deem][Int_Z]);
						        SetPlayerInterior(playerid, IntInfo[deem][Int]);
						        PlayerInfo[playerid][pDomWKJ] = i;
						        GameTextForPlayer(playerid, "~g~Masz 30 sekund", 5000, 1);
						        SendClientMessage(playerid,COLOR_PANICRED, "Masz 30 sekund do obejrzenia domu.");
						        SetTimerEx("OgladanieDOM", 30000,0,"d",playerid);
						        return 1;
							}
							else
							{
							    SendClientMessage(playerid,COLOR_GREY, "Ten dom jest kupiony, nie mo�esz go ogl�da�, skontaktuj si� z w�a�cicielem.");
							}
						}
					}
				}
				else
				{
				    SendClientMessage(playerid,COLOR_GREY, "Musisz odczeka� 3 minuty aby jeszcze raz obejrze� dom.");
				}
		    }
		}
		if(dialogid == 85)//system dom�w
		{
		    if(response)
		    {
	     		ShowPlayerDialogEx(playerid, 86, DIALOG_STYLE_MSGBOX, "Kupowanie domu - p�atno��", "P�atno�ci chcesz dokona� got�wk� czy przelewem z banku?", "Got�wka", "Przelew");
		    }
		}
		if(dialogid == 86)//system dom�w
		{
		    if(response)
		    {
		        KupowanieDomu(playerid, IDDomu[playerid], 1);
		    }
		    if(!response)
		    {
		        KupowanieDomu(playerid, IDDomu[playerid], 2);
		    }
		}
		if(dialogid == 87)//system dom�w
		{
		   	if(response)
		    {
		        ZlomowanieDomu(playerid, PlayerInfo[playerid][pDom]);
		    }
		    else
		    {
		        SendClientMessage(playerid, COLOR_NEWS, "Anulowa�e� z�omowanie");
		    }
		}
		if(dialogid == 810)
		{
		    if(response)
		    {
		        new dom = PlayerInfo[playerid][pDom];
		        switch(listitem)
		        {
		            case 0://Informacje o domu
		            {
		                new string2[512];
						new wynajem[20];
						if(Dom[dom][hWynajem] == 0)
						{
	                        wynajem = "nie";
						}
						else
						{
	                        wynajem = "tak";
						}
						new drzwi[30];
						if(Dom[dom][hZamek] == 0)
						{
	                        drzwi = "Zamkni�te";
						}
						else
						{
	                        drzwi = "Otwarte";
						}
		                format(string2, sizeof(string2), "ID domu:\t%d\nID wn�trza:\t%d\nCena domu:\t%d$\nWynajem:\t%s\nIlosc pokoi:\t%d\nPokoi wynajmowanych\t%d\nCena wynajmu:\t%d$\nO�wietlenie:\t%d\nDrzwi:\t%s", dom, Dom[dom][hDomNr], Dom[dom][hCena], wynajem, Dom[dom][hPokoje], Dom[dom][hPW], Dom[dom][hCenaWynajmu], Dom[dom][hSwiatlo], drzwi);
		                ShowPlayerDialogEx(playerid, 811, DIALOG_STYLE_MSGBOX, "G��wne informacje domu", string2, "Wr��", "Wyjd�");
		            }
		            case 1://Zamykanie domu
		            {
		                if(Dom[dom][hZamek] == 1 && AntySpam[playerid] == 1)
		                {
							ShowPlayerDialogEx(playerid, 811, DIALOG_STYLE_MSGBOX, "Zamykanie domu", "Odczekaj 10 sekund zanim zamkniesz dom ponownie.", "Wr��", "Wyjd�");
						}
						else if(Dom[dom][hZamek] == 1)
		                {
		                    SetTimerEx("AntySpamTimer",5000,0,"d",playerid);
	    					AntySpam[playerid] = 1;
							Dom[dom][hZamek] = 0;
							ShowPlayerDialogEx(playerid, 811, DIALOG_STYLE_MSGBOX, "Zamykanie domu", "Dom zosta� zamkni�ty pomy�lnie", "Wr��", "Wyjd�");
						}
						else if(Dom[dom][hZamek] == 0)
						{
						    Dom[dom][hZamek] = 1;
		                	ShowPlayerDialogEx(playerid, 811, DIALOG_STYLE_MSGBOX, "Otwieranie domu", "Dom zosta� otworzony pomy�lnie", "Wr��", "Wyjd�");
						}
					}
		            case 2://Panel wynajmu
		            {
	                    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
		            }
		            case 3://Panel dodatk�w
		            {
		                ShowPlayerDialogEx(playerid, 1230, DIALOG_STYLE_MSGBOX, "Zablokowane", "Ta opcja jest na razie w fazie produkcji", "Wr��", "Wr��");
		            }
	             	case 4://O�wietlenie
		            {
		                ShowPlayerDialogEx(playerid, 812, DIALOG_STYLE_LIST, "Wybierz o�wietlenie", "Zachodz�ce s�o�ce (21:00)\nMrok (0:00)\nDzie� (12:00)\nW�asny tryb (godzina)", "Wybierz", "Wr��");
		            }
		            case 5://Spawn
		            {
		                ShowPlayerDialogEx(playerid, 814, DIALOG_STYLE_LIST, "Wybierz typ spawnu", "Normalny spawn\nSpawn przed domem\nSpawn w domu", "Wybierz", "Wr��");
		            }
		            case 6://Kupowanie dodatk�w
		            {
						KupowanieDodatkow(playerid, dom);
		            }
		            case 7://Pomoc domu
		            {
		                ShowPlayerDialogEx(playerid, 1230, DIALOG_STYLE_MSGBOX, "Zablokowane", "Ta opcja jest na razie w fazie produkcji", "Wr��", "Wr��");
		            }
		        }
		    }
		}
		if(dialogid == 1230)
		{
		    if(response || !response)
		    {
		        if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 0)
		    	{
					ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nOtw�rz\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
				}
				else if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 1)
				{
	   				ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nZamknij\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
				}
		    }
		}
		if(dialogid == 811)
		{
		    if(response)
		    {
		        if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 0)
		    	{
					ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nOtw�rz\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
				}
				else if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 1)
				{
	   				ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nZamknij\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
				}
		    }
		}
        if(dialogid == D_INFO)
        {
            return 1;
        }
		if(dialogid == 812)
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0:// Jasne ze swiat�ami (21:00)
		            {
		                Dom[PlayerInfo[playerid][pDom]][hSwiatlo] = 21;
		                ZapiszDom(PlayerInfo[playerid][pDom]);
		                SendClientMessage(playerid, COLOR_NEWS, "O�wietlenie w domu zosta�o zmienione");
		                if(IsPlayerInRangeOfPoint(playerid, 50.0, Dom[PlayerInfo[playerid][pDom]][hInt_X], Dom[PlayerInfo[playerid][pDom]][hInt_Y], Dom[PlayerInfo[playerid][pDom]][hInt_Z]))
		                {
		                	ShowPlayerDialogEx(playerid, 812, DIALOG_STYLE_LIST, "Wybierz o�wietlenie", "Zachodz�ce s�o�ce (21:00)\nMrok (0:00)\nDzie� (12:00)\nW�asny tryb (godzina)", "Wybierz", "Wr��");
		                	SetPlayerTime(playerid, 21, 0);
		                }
		                else
		                {
		                    if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 0)
						    {
								ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nOtw�rz\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
							}
							else if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 1)
							{
							    ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nZamknij\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
							}
		                }
		            }
		            case 1:// �wiat�a w��czone (0:00)
		            {
		                Dom[PlayerInfo[playerid][pDom]][hSwiatlo] = 0;
		                ZapiszDom(PlayerInfo[playerid][pDom]);
	                    SendClientMessage(playerid, COLOR_NEWS, "O�wietlenie w domu zosta�o zmienione");
		                if(IsPlayerInRangeOfPoint(playerid, 50.0, Dom[PlayerInfo[playerid][pDom]][hInt_X], Dom[PlayerInfo[playerid][pDom]][hInt_Y], Dom[PlayerInfo[playerid][pDom]][hInt_Z]))
		                {
		                	ShowPlayerDialogEx(playerid, 812, DIALOG_STYLE_LIST, "Wybierz o�wietlenie", "Zachodz�ce s�o�ce (21:00)\nMrok (0:00)\nDzie� (12:00)\nW�asny tryb (godzina)", "Wybierz", "Wr��");
		                	SetPlayerTime(playerid, 0, 0);
		                }
		                else
		                {
		                    if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 0)
						    {
								ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nOtw�rz\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
							}
							else if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 1)
							{
							    ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nZamknij\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
							}
		                }
		            }
		            case 2:// Wy��czone �wiat�o, jasno (12:00)
		            {
		                Dom[PlayerInfo[playerid][pDom]][hSwiatlo] = 12;
		                ZapiszDom(PlayerInfo[playerid][pDom]);
		                SendClientMessage(playerid, COLOR_NEWS, "O�wietlenie w domu zosta�o zmienione");
		                if(IsPlayerInRangeOfPoint(playerid, 50.0, Dom[PlayerInfo[playerid][pDom]][hInt_X], Dom[PlayerInfo[playerid][pDom]][hInt_Y], Dom[PlayerInfo[playerid][pDom]][hInt_Z]))
		                {
		                	ShowPlayerDialogEx(playerid, 812, DIALOG_STYLE_LIST, "Wybierz o�wietlenie", "Zachodz�ce s�o�ce (21:00)\nMrok (0:00)\nDzie� (12:00)\nW�asny tryb (godzina)", "Wybierz", "Wr��");
		                	SetPlayerTime(playerid, 12, 0);
		                }
		                else
		                {
		                    if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 0)
						    {
								ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nOtw�rz\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
							}
							else if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 1)
							{
							    ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nZamknij\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
							}
		                }
	             	}
		            case 3: // W�asna godzina
		            {
						ShowPlayerDialogEx(playerid, 813, DIALOG_STYLE_INPUT, "O�wietlenie domu", "Wpisz na godzin� ma si� zmienia� czas po wejsciu do domu.\nGodziny od 7-19 s� jasne a od 20 do 6 ciemne ze �wiat�ami", "Wpisz", "Wr��");
		            }
		        }
		    }
		    if(!response)
		    {
		        if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 0)
		    	{
					ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nOtw�rz\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
				}
				else if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 1)
				{
	   				ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nZamknij\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
				}
		    }
		}
		if(dialogid == 813)
		{
		    if(response)
		    {
		        new godz = strval(inputtext);
		        new string[256];
		        if(godz >= 0 && godz <= 24 || PlayerInfo[playerid][pAdmin] >= 100)
		        {
					format(string, sizeof(string), "O�wietlenie domu zmienione na %d godzin�", godz);
					SendClientMessage(playerid, COLOR_NEWS, string);
					Dom[PlayerInfo[playerid][pDom]][hSwiatlo] = godz;
		   			ZapiszDom(PlayerInfo[playerid][pDom]);
		      		if(IsPlayerInRangeOfPoint(playerid, 50.0, Dom[PlayerInfo[playerid][pDom]][hInt_X], Dom[PlayerInfo[playerid][pDom]][hInt_Y], Dom[PlayerInfo[playerid][pDom]][hInt_Z]))
		        	{
		        		ShowPlayerDialogEx(playerid, 813, DIALOG_STYLE_INPUT, "O�wietlenie domu", "Wpisz na godzin� ma si� zmienia� czas po wejsciu do domu.\nGodziny od 7-19 s� jasne a od 20 do 6 ciemne ze �wiat�ami", "Wpisz", "Wr��");
		         		SetPlayerTime(playerid, godz, 0);
		          	}
		           	else
		            {
		            	if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 0)
				    	{
							ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nOtw�rz\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
						}
						else if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 1)
						{
		    				ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nZamknij\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
						}
		           	}
				}
				else
				{
	   				ShowPlayerDialogEx(playerid, 813, DIALOG_STYLE_INPUT, "O�wietlenie domu", "Wpisz na godzin� ma si� zmienia� czas po wejsciu do domu.\nGodziny od 7-19 s� jasne a od 20 do 6 ciemne ze �wiat�ami", "Wpisz", "Wr��");
	     			SendClientMessage(playerid, COLOR_NEWS, "Godzina o�wietlenia od 0 do 24");
	      		}
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 812, DIALOG_STYLE_LIST, "Wybierz o�wietlenie", "Zachodz�ce s�o�ce (21:00)\nMrok (0:00)\nDzie� (12:00)\nW�asny tryb (godzina)", "Wybierz", "Wr��");
		    }
		}
		if(dialogid == 814)
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0:// Normalny spawn
		            {
		                PlayerInfo[playerid][pSpawn] = 0;
		                SendClientMessage(playerid, COLOR_NEWS, "B�dziesz si� teraz spawnowa� na swoim normalnym spawnie");
		                if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 0)
	 					{
							ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nOtw�rz\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
						}
						else if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 1)
						{
						    ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nZamknij\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
						}
		                //ShowPlayerDialogEx(playerid, 814, DIALOG_STYLE_LIST, "Wybierz typ spawnu", "Normalny spawn\nSpawn przed domem\nSpawn w domu", "Wybierz", "Wr��");
		            }
		            case 1:// Spawn przed domem
		            {
		                PlayerInfo[playerid][pSpawn] = 1;
		                SendClientMessage(playerid, COLOR_NEWS, "B�dziesz si� teraz spawnowa� przed domem");
		                if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 0)
		    			{
							ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nOtw�rz\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
						}
						else if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 1)
						{
		    				ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nZamknij\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
						}
		                //ShowPlayerDialogEx(playerid, 814, DIALOG_STYLE_LIST, "Wybierz typ spawnu", "Normalny spawn\nSpawn przed domem\nSpawn w domu", "Wybierz", "Wr��");
		            }
		            case 2:// Spawn w domu
		            {
	                    PlayerInfo[playerid][pSpawn] = 2;
	                    SendClientMessage(playerid, COLOR_NEWS, "B�dziesz si� teraz spawnowa� wewn�trz domu");
	                    if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 0)
	 					{
							ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nOtw�rz\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
						}
						else if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 1)
						{
		    				ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nZamknij\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
						}
	                    //ShowPlayerDialogEx(playerid, 814, DIALOG_STYLE_LIST, "Wybierz typ spawnu", "Normalny spawn\nSpawn przed domem\nSpawn w domu", "Wybierz", "Wr��");
		            }
				}
			}
			if(!response)
			{
				if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 0)
	   			{
					ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nOtw�rz\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
				}
				else if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 1)
				{
	   				ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nZamknij\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
				}
			}
		}
		if(dialogid == 815)
		{
		    if(response)
		    {
		        new dom = PlayerInfo[playerid][pDom];
		        new string[256];
		        switch(listitem)
		        {
		            case 0:// Informacje og�lne
		            {
	                    new wynajem[50];
						if(Dom[dom][hWynajem] == 0)
						{
	                        wynajem = "nie wynajmuj";
						}
						else if(Dom[dom][hWynajem] == 1)
						{
	                        wynajem = "dla wszystkich";
						}
						else if(Dom[dom][hWynajem] == 2)
						{
	                        wynajem = "dla wybranych os�b";
						}
						else if(Dom[dom][hWynajem] == 3)
						{
						    if(Dom[dom][hWW] == 1)
						    {
	                        	wynajem = "z warunkiem (frakcja)";
	                        }
	                        else if(Dom[dom][hWW] == 2)
	                        {
	                            wynajem = "z warunkiem (rodzina)";
	                        }
	                        else if(Dom[dom][hWW] == 3)
	                        {
	                            wynajem = "z warunkiem (level)";
	                        }
	                        else if(Dom[dom][hWW] == 4)
	                        {
	                            wynajem = "z warunkiem (konto premium)";
	                        }
						}
		                format(string, sizeof(string), "Wynajem:\t%s\nCena wynajmu:\t%d$\nIlo�� pokoi:\t%d\nPokoje wynajmowane:\t%d\nPokoi do wynaj�cia:\t%d", wynajem, Dom[dom][hCenaWynajmu], Dom[dom][hPokoje], Dom[dom][hPW], Dom[dom][hPDW]);
		                ShowPlayerDialogEx(playerid, 816, DIALOG_STYLE_MSGBOX, "Og�lne informacje o wynajmie", string, "Wr��", "Wyjd�");
		            }
		            case 1:// Zarz�dzaj lokatorami
		            {
		                format(string, sizeof(string), "Lokator 1:\t%s\nLokator 2:\t%s\nLokator 3:\t%s\nLokator 4:\t%s\nLokator 5:\t%s\nLokator 6:\t%s\nLokator 7:\t%s\nLokator 8:\t%s\nLokator 9:\t%s\nLokator 10:\t%s", Dom[dom][hL1], Dom[dom][hL2], Dom[dom][hL3], Dom[dom][hL4], Dom[dom][hL5], Dom[dom][hL6], Dom[dom][hL7], Dom[dom][hL8], Dom[dom][hL9], Dom[dom][hL10]);
		                ShowPlayerDialogEx(playerid, 817, DIALOG_STYLE_LIST, "Zarz�dzanie lokatorami", string, "Eksmituj", "Wr��");
		            }
		            case 2:// Tryb wynajmu
		            {
		                ShowPlayerDialogEx(playerid, 818, DIALOG_STYLE_LIST, "Tryb wynajmu", "Brak wynajmu\nDla wszystkich\nWybrane osoby\nDla frakcji/rodziny/KP", "Wybierz", "Wr��");
		            }
		            case 3:// Cena wynajmu
		            {
		                ShowPlayerDialogEx(playerid, 824, DIALOG_STYLE_INPUT, "Cena wynajmu", "Wpisz, za ile grcze mog� wynaj�� u ciebie dom.\n(Cena do ustalenia tylko w przypadku wynajmowania dla wszystkich i wynajmu z warunkiem)", "Wybierz", "Wr��");
		            }
		            case 4:// Wiadomo�� dla wynajmuj�cych
		            {
		                ShowPlayerDialogEx(playerid, 825, DIALOG_STYLE_INPUT, "Wiadomo�� dla lokator�w", "Tu mo�esz ustali� co b�dzie si� wy�wietla� osob� kt�re wynajmuj� tw�j dom.", "Wybierz", "Wr��");
		            }
		            case 5:// Uprawnienia lokator�w
		            {
		                new taknie_z[10];
		                new taknie_d[10];
		                if(Dom[dom][hUL_Z] == 1)
		                {
		                    taknie_z = "tak";
		                }
		                else
		                {
		                    taknie_z = "nie";
		                }
		                if(Dom[dom][hUL_D] == 1)
		                {
		                    taknie_d = "tak";
		                }
		                else
		                {
		                    taknie_d = "nie";
		                }
		                format(string, sizeof(string), "Zamykanie i otwieranie drzwi:\t %s\nKorzystanie z dodatk�w:\t %s", taknie_z, taknie_d);
	                    ShowPlayerDialogEx(playerid, 8800, DIALOG_STYLE_LIST, "Uprawnienia lokator�w", string, "Zmie�", "Wr��");
		            }
		            /*case 6:// Informacja o wynajmie
		            {

		            }*/
		        }
		    }
		    if(!response)
			{
				if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 0)
	   			{
					ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nOtw�rz\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
				}
				else if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 1)
				{
	   				ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nZamknij\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
				}
			}
		}
		if(dialogid == 816)
		{
		    if(response)
			{
	            if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 0)
	   			{
					ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nOtw�rz\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
				}
				else if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 1)
				{
	   				ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nZamknij\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
				}
			}
		}
		if(dialogid == 817)
		{
		    if(response)
			{
			    new dom = PlayerInfo[playerid][pDom];
			    new string[256];
			    Dom[dom][hPW] --;
			    Dom[dom][hPDW] ++;
			    switch(listitem)
			    {
					case 0:
					{
					    format(string, sizeof(string), "Gracz %d zosta� wyeksmitowany", Dom[dom][hL1]);
					    SendClientMessage(playerid, 0xFFC0CB, string);
					    new GeT[MAX_PLAYER_NAME];
	           			format(GeT, sizeof(GeT), "Brak");
						Dom[dom][hL1] = GeT;
					    format(string, sizeof(string), "Lokator 1:\t%s\nLokator 2:\t%s\nLokator 3:\t%s\nLokator 4:\t%s\nLokator 5:\t%s\nLokator 6:\t%s\nLokator 7:\t%s\nLokator 8:\t%s\nLokator 9:\t%s\nLokator 10:\t%s\n", Dom[dom][hL1], Dom[dom][hL2], Dom[dom][hL3], Dom[dom][hL4], Dom[dom][hL5], Dom[dom][hL6], Dom[dom][hL7], Dom[dom][hL8], Dom[dom][hL9], Dom[dom][hL10]);
		       			ShowPlayerDialogEx(playerid, 817, DIALOG_STYLE_LIST, "Zarz�dzanie lokatorami", string, "Eksmituj", "Wr��");
		       			ZapiszDom(dom);
					}
					case 1:
					{
					    format(string, sizeof(string), "Gracz %d zosta� wyeksmitowany", Dom[dom][hL2]);
					    SendClientMessage(playerid, 0xFFC0CB, string);
					    new GeT[MAX_PLAYER_NAME];
	           			format(GeT, sizeof(GeT), "Brak");
						Dom[dom][hL2] = GeT;
					    format(string, sizeof(string), "Lokator 1:\t%s\nLokator 2:\t%s\nLokator 3:\t%s\nLokator 4:\t%s\nLokator 5:\t%s\nLokator 6:\t%s\nLokator 7:\t%s\nLokator 8:\t%s\nLokator 9:\t%s\nLokator 10:\t%s\n", Dom[dom][hL1], Dom[dom][hL2], Dom[dom][hL3], Dom[dom][hL4], Dom[dom][hL5], Dom[dom][hL6], Dom[dom][hL7], Dom[dom][hL8], Dom[dom][hL9], Dom[dom][hL10]);
		       			ShowPlayerDialogEx(playerid, 817, DIALOG_STYLE_LIST, "Zarz�dzanie lokatorami", string, "Eksmituj", "Wr��");
		       			ZapiszDom(dom);
					}
					case 2:
					{
					    format(string, sizeof(string), "Gracz %d zosta� wyeksmitowany", Dom[dom][hL3]);
					    SendClientMessage(playerid, 0xFFC0CB, string);
					    new GeT[MAX_PLAYER_NAME];
	           			format(GeT, sizeof(GeT), "Brak");
						Dom[dom][hL3] = GeT;
					    format(string, sizeof(string), "Lokator 1:\t%s\nLokator 2:\t%s\nLokator 3:\t%s\nLokator 4:\t%s\nLokator 5:\t%s\nLokator 6:\t%s\nLokator 7:\t%s\nLokator 8:\t%s\nLokator 9:\t%s\nLokator 10:\t%s\n", Dom[dom][hL1], Dom[dom][hL2], Dom[dom][hL3], Dom[dom][hL4], Dom[dom][hL5], Dom[dom][hL6], Dom[dom][hL7], Dom[dom][hL8], Dom[dom][hL9], Dom[dom][hL10]);
		       			ShowPlayerDialogEx(playerid, 817, DIALOG_STYLE_LIST, "Zarz�dzanie lokatorami", string, "Eksmituj", "Wr��");
		       			ZapiszDom(dom);
					}
					case 3:
					{
					    format(string, sizeof(string), "Gracz %d zosta� wyeksmitowany", Dom[dom][hL4]);
					    SendClientMessage(playerid, 0xFFC0CB, string);
					    new GeT[MAX_PLAYER_NAME];
	           			format(GeT, sizeof(GeT), "Brak");
						Dom[dom][hL4] = GeT;
					    format(string, sizeof(string), "Lokator 1:\t%s\nLokator 2:\t%s\nLokator 3:\t%s\nLokator 4:\t%s\nLokator 5:\t%s\nLokator 6:\t%s\nLokator 7:\t%s\nLokator 8:\t%s\nLokator 9:\t%s\nLokator 10:\t%s\n", Dom[dom][hL1], Dom[dom][hL2], Dom[dom][hL3], Dom[dom][hL4], Dom[dom][hL5], Dom[dom][hL6], Dom[dom][hL7], Dom[dom][hL8], Dom[dom][hL9], Dom[dom][hL10]);
		       			ShowPlayerDialogEx(playerid, 817, DIALOG_STYLE_LIST, "Zarz�dzanie lokatorami", string, "Eksmituj", "Wr��");
		       			ZapiszDom(dom);
					}
					case 4:
					{
					    format(string, sizeof(string), "Gracz %d zosta� wyeksmitowany", Dom[dom][hL5]);
					    SendClientMessage(playerid, 0xFFC0CB, string);
					    new GeT[MAX_PLAYER_NAME];
	           			format(GeT, sizeof(GeT), "Brak");
						Dom[dom][hL5] = GeT;
					    format(string, sizeof(string), "Lokator 1:\t%s\nLokator 2:\t%s\nLokator 3:\t%s\nLokator 4:\t%s\nLokator 5:\t%s\nLokator 6:\t%s\nLokator 7:\t%s\nLokator 8:\t%s\nLokator 9:\t%s\nLokator 10:\t%s\n", Dom[dom][hL1], Dom[dom][hL2], Dom[dom][hL3], Dom[dom][hL4], Dom[dom][hL5], Dom[dom][hL6], Dom[dom][hL7], Dom[dom][hL8], Dom[dom][hL9], Dom[dom][hL10]);
		       			ShowPlayerDialogEx(playerid, 817, DIALOG_STYLE_LIST, "Zarz�dzanie lokatorami", string, "Eksmituj", "Wr��");
		       			ZapiszDom(dom);
					}
					case 5:
					{
					    format(string, sizeof(string), "Gracz %d zosta� wyeksmitowany", Dom[dom][hL6]);
					    SendClientMessage(playerid, 0xFFC0CB, string);
					    new GeT[MAX_PLAYER_NAME];
	           			format(GeT, sizeof(GeT), "Brak");
						Dom[dom][hL6] = GeT;
					    format(string, sizeof(string), "Lokator 1:\t%s\nLokator 2:\t%s\nLokator 3:\t%s\nLokator 4:\t%s\nLokator 5:\t%s\nLokator 6:\t%s\nLokator 7:\t%s\nLokator 8:\t%s\nLokator 9:\t%s\nLokator 10:\t%s\n", Dom[dom][hL1], Dom[dom][hL2], Dom[dom][hL3], Dom[dom][hL4], Dom[dom][hL5], Dom[dom][hL6], Dom[dom][hL7], Dom[dom][hL8], Dom[dom][hL9], Dom[dom][hL10]);
		       			ShowPlayerDialogEx(playerid, 817, DIALOG_STYLE_LIST, "Zarz�dzanie lokatorami", string, "Eksmituj", "Wr��");
		       			ZapiszDom(dom);
					}
					case 6:
					{
					    format(string, sizeof(string), "Gracz %d zosta� wyeksmitowany", Dom[dom][hL7]);
					    SendClientMessage(playerid, 0xFFC0CB, string);
					    new GeT[MAX_PLAYER_NAME];
	           			format(GeT, sizeof(GeT), "Brak");
						Dom[dom][hL7] = GeT;
					    format(string, sizeof(string), "Lokator 1:\t%s\nLokator 2:\t%s\nLokator 3:\t%s\nLokator 4:\t%s\nLokator 5:\t%s\nLokator 6:\t%s\nLokator 7:\t%s\nLokator 8:\t%s\nLokator 9:\t%s\nLokator 10:\t%s\n", Dom[dom][hL1], Dom[dom][hL2], Dom[dom][hL3], Dom[dom][hL4], Dom[dom][hL5], Dom[dom][hL6], Dom[dom][hL7], Dom[dom][hL8], Dom[dom][hL9], Dom[dom][hL10]);
		       			ShowPlayerDialogEx(playerid, 817, DIALOG_STYLE_LIST, "Zarz�dzanie lokatorami", string, "Eksmituj", "Wr��");
		       			ZapiszDom(dom);
					}
					case 7:
					{
					    format(string, sizeof(string), "Gracz %d zosta� wyeksmitowany", Dom[dom][hL8]);
					    SendClientMessage(playerid, 0xFFC0CB, string);
					    new GeT[MAX_PLAYER_NAME];
	           			format(GeT, sizeof(GeT), "Brak");
						Dom[dom][hL8] = GeT;
					    format(string, sizeof(string), "Lokator 1:\t%s\nLokator 2:\t%s\nLokator 3:\t%s\nLokator 4:\t%s\nLokator 5:\t%s\nLokator 6:\t%s\nLokator 7:\t%s\nLokator 8:\t%s\nLokator 9:\t%s\nLokator 10:\t%s\n", Dom[dom][hL1], Dom[dom][hL2], Dom[dom][hL3], Dom[dom][hL4], Dom[dom][hL5], Dom[dom][hL6], Dom[dom][hL7], Dom[dom][hL8], Dom[dom][hL9], Dom[dom][hL10]);
		       			ShowPlayerDialogEx(playerid, 817, DIALOG_STYLE_LIST, "Zarz�dzanie lokatorami", string, "Eksmituj", "Wr��");
		       			ZapiszDom(dom);
					}
					case 8:
					{
					    format(string, sizeof(string), "Gracz %d zosta� wyeksmitowany", Dom[dom][hL9]);
					    SendClientMessage(playerid, 0xFFC0CB, string);
					    new GeT[MAX_PLAYER_NAME];
	           			format(GeT, sizeof(GeT), "Brak");
						Dom[dom][hL9] = GeT;
					    format(string, sizeof(string), "Lokator 1:\t%s\nLokator 2:\t%s\nLokator 3:\t%s\nLokator 4:\t%s\nLokator 5:\t%s\nLokator 6:\t%s\nLokator 7:\t%s\nLokator 8:\t%s\nLokator 9:\t%s\nLokator 10:\t%s\n", Dom[dom][hL1], Dom[dom][hL2], Dom[dom][hL3], Dom[dom][hL4], Dom[dom][hL5], Dom[dom][hL6], Dom[dom][hL7], Dom[dom][hL8], Dom[dom][hL9], Dom[dom][hL10]);
		       			ShowPlayerDialogEx(playerid, 817, DIALOG_STYLE_LIST, "Zarz�dzanie lokatorami", string, "Eksmituj", "Wr��");
		       			ZapiszDom(dom);
					}
					case 9:
					{
					    format(string, sizeof(string), "Gracz %d zosta� wyeksmitowany", Dom[dom][hL10]);
					    SendClientMessage(playerid, 0xFFC0CB, string);
					    new GeT[MAX_PLAYER_NAME];
	           			format(GeT, sizeof(GeT), "Brak");
						Dom[dom][hL10] = GeT;
					    format(string, sizeof(string), "Lokator 1:\t%s\nLokator 2:\t%s\nLokator 3:\t%s\nLokator 4:\t%s\nLokator 5:\t%s\nLokator 6:\t%s\nLokator 7:\t%s\nLokator 8:\t%s\nLokator 9:\t%s\nLokator 10:\t%s\n", Dom[dom][hL1], Dom[dom][hL2], Dom[dom][hL3], Dom[dom][hL4], Dom[dom][hL5], Dom[dom][hL6], Dom[dom][hL7], Dom[dom][hL8], Dom[dom][hL9], Dom[dom][hL10]);
		       			ShowPlayerDialogEx(playerid, 817, DIALOG_STYLE_LIST, "Zarz�dzanie lokatorami", string, "Eksmituj", "Wr��");
		       			ZapiszDom(dom);
					}
				}
			}
		    if(!response)
			{
	  			ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			}
		}
		if(dialogid == 818)
		{
		    if(response)
		    {
		        new dom = PlayerInfo[playerid][pDom];
		        switch(listitem)
		        {
		            case 0:// Brak wynajmu
		            {
		                new GeT[MAX_PLAYER_NAME];
	           			format(GeT, sizeof(GeT), "Brak");
						Dom[dom][hL1] = GeT;
						Dom[dom][hL2] = GeT;
						Dom[dom][hL3] = GeT;
						Dom[dom][hL4] = GeT;
						Dom[dom][hL5] = GeT;
						Dom[dom][hL6] = GeT;
						Dom[dom][hL7] = GeT;
						Dom[dom][hL8] = GeT;
						Dom[dom][hL9] = GeT;
						Dom[dom][hL10] = GeT;
					    SendClientMessage(playerid, COLOR_P@, "Nie wynajmujesz domu. Wszyscy wynajmuj�cy zostali wyeksmitowani.");
					    Dom[dom][hWynajem] = 0;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 818, DIALOG_STYLE_LIST, "Tryb wynajmu", "Brak wynajmu\nDla wszystkich\nWybrane osoby\nDla frakcji/rodziny/KP", "Wybierz", "Wr��");
		            }
		            case 1:// Wynajem dla ka�dego
		            {
	                    SendClientMessage(playerid, COLOR_P@, "Teraz ka�dy mo�e wynaj�� tw�j dom po wpisaniu komendy /wynajmuj pod drzwiami.");
					    Dom[dom][hWynajem] = 1;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 818, DIALOG_STYLE_LIST, "Tryb wynajmu", "Brak wynajmu\nDla wszystkich\nWybrane osoby\nDla frakcji/rodziny/KP", "Wybierz", "Wr��");
		            }
		            case 2:// Lokator�w ustala w�a�ciciel
		            {
					    SendClientMessage(playerid, COLOR_P@, "Teraz ty ustalasz kto ma wynajmowa� pok�j komend� /dajpokoj [id].");
					    Dom[dom][hWynajem] = 2;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 818, DIALOG_STYLE_LIST, "Tryb wynajmu", "Brak wynajmu\nDla wszystkich\nWybrane osoby\nDla frakcji/rodziny/KP", "Wybierz", "Wr��");
		            }
		            case 3:// Wynajem tylko je�eli kto� spe�nia dany warunek
		            {
	                    ShowPlayerDialogEx(playerid, 819, DIALOG_STYLE_LIST, "Warunek wynajmu", "Odpowiednia frakcja\nOdpowiednia rodzina\nOdpowiedni level\nLevel Konta Premium", "Wybierz", "Wyjd�");
		            }
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
		    }
		}
		if(dialogid == 819)
		{

		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0:// Warunek wynajmu: odpowiednia frakcja
		            {
		                ShowPlayerDialogEx(playerid, 820, DIALOG_STYLE_LIST, "Warunek wynajmu - frakcja", "Policja\nFBI\nWojsko\nSAM-ERS\nLa Cosa Nostra\nYakuza\nHitman Agency\nSA News\nTaxi Corporation\nUrz�dnicy\nGrove Street\nPurpz\nLatin Kings", "Wybierz", "Wr��");
		            }
		            case 1:// Warunek wynajmu: odpowiednia rodzina
		            {
		                ShowPlayerDialogEx(playerid, 821, DIALOG_STYLE_LIST, "Warunek wynajmu - rodzina", "Rodzina 1\nRodzina 2\nRodzina 3\nRodzina 4\nRodzina 5\nRodzina 6\nRodzina 7\nRodzina 8\nRodzina 9\nRodzina 10\nRodzina 11\nRodzina 12\nRodzina 13\nRodzina 14\nRodzina 15\nRodzina 16\nRodzina 17\nRodzina 18\nRodzina 19\nRodzina 20\n", "Wybierz", "Wr��");
		            }
		            case 2:// Warunek wynajmu: odpowiednio wysoki level
		            {
		                ShowPlayerDialogEx(playerid, 822, DIALOG_STYLE_INPUT, "Warunek wynajmu - level", "Wpisz od jakiego levelu b�dzie mo�na wynaj�� tw�j dom", "Wybierz", "Wr��");
		            }
		            case 3:// Warunek wynajmu: odpowiednio wysoki level konta premium
		            {
		                ShowPlayerDialogEx(playerid, 823, DIALOG_STYLE_INPUT, "Warunek wynajmu - KP", "Wpisz od jakiego levelu Konta Premium b�dzie mo�na wynaj�� tw�j dom", "Wybierz", "Wr��");
		            }
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 818, DIALOG_STYLE_LIST, "Tryb wynajmu", "Brak wynajmu\nDla wszystkich\nWybrane osoby\nDla frakcji/rodziny/KP", "Wybierz", "Wr��");
		    }
		}
		if(dialogid == 820)//warunek - frakcja
		{
		    if(response)
		    {
		        new dom = PlayerInfo[playerid][pDom];
		        switch(listitem)
		        {
			        case 0:
			        {
			            SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z frakcji LSPD b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 1;
			    		Dom[dom][hTWW] = 1;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 1:
			        {
			            SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z frakcji FBI b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 1;
			    		Dom[dom][hTWW] = 2;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 2:
			        {
			            SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z frakcji NG b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 1;
			    		Dom[dom][hTWW] = 3;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 3:
			        {
			            SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z frakcji SAM-ERS b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 1;
			    		Dom[dom][hTWW] = 4;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 4:
			        {
			            SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z frakcji LCN b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 1;
			    		Dom[dom][hTWW] = 5;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 5:
			        {
			            SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z frakcji YKZ b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 1;
			    		Dom[dom][hTWW] = 6;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 6:
			        {
			            SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z frakcji HA b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 1;
			    		Dom[dom][hTWW] = 8;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 7:
			        {
			            SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z frakcji SAN b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 1;
			    		Dom[dom][hTWW] = 9;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 8:
			        {
			            SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z frakcji Taxi b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 1;
			    		Dom[dom][hTWW] = 10;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 9:
			        {
			            SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z frakcji DMV b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 1;
			    		Dom[dom][hTWW] = 11;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 10:
			        {
			            SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z frakcji Grove b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 1;
			    		Dom[dom][hTWW] = 12;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 11:
			        {
			            SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z frakcji Purpz b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 1;
			    		Dom[dom][hTWW] = 13;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 12:
			        {
			            SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z frakcji Latin Kings b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 1;
			    		Dom[dom][hTWW] = 14;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
				}
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 819, DIALOG_STYLE_LIST, "Warunek wynajmu", "Odpowiednia frakcja\nOdpowiednia rodzina\nOdpowiedni level\nLevel Konta Premium", "Wybierz", "Wyjd�");
		    }
		}
		if(dialogid == 821)//warunek - rodzina
		{
		    if(response)
		    {

		        new dom = PlayerInfo[playerid][pDom];
		        switch(listitem)
		        {
		            case 0:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 1 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 0;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 1:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 2 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 1;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 2:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 3 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 2;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 3:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 4 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 3;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 4:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 5 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 4;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 5:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 6 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 5;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 6:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 7 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 6;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 7:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 8 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 7;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 8:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 9 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 8;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 9:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 10 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 9;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 10:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 11 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 10;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 11:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 12 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 11;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 12:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 13 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 12;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 13:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 14 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 13;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 14:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 15 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 14;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 15:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 16 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 15;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 16:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 17 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 16;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 17:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 18 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 17;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 18:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 19 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 18;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
			        case 19:
		            {
		            	SendClientMessage(playerid, COLOR_P@, "Teraz tylko ludzie z Rodziny 20 b�d� mogli wynajmowa� u ciebie dom.");
			    		Dom[dom][hWynajem] = 3;
			    		Dom[dom][hWW] = 2;
			    		Dom[dom][hTWW] = 19;
					    ZapiszDom(dom);
					    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
			        }
		        }
			}
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 819, DIALOG_STYLE_LIST, "Warunek wynajmu", "Odpowiednia frakcja\nOdpowiednia rodzina\nOdpowiedni level\nLevel Konta Premium", "Wybierz", "Wyjd�");
		    }
		}
		if(dialogid == 822)
		{
		    if(response)
		    {
		        new dom = PlayerInfo[playerid][pDom];
				if(strval(inputtext) >= 1 && strval(inputtext) <= 100)
				{
				    new string[256];
				    format(string, sizeof(string), "Teraz tylko ludzie z levelem wi�kszym lub r�wnym %d b�d� mogli wynajmowa� u ciebie dom.", strval(inputtext));
				    SendClientMessage(playerid, COLOR_P@, string);
		    		Dom[dom][hWynajem] = 3;
		    		Dom[dom][hWW] = 3;
		    		Dom[dom][hTWW] = strval(inputtext);
				    ZapiszDom(dom);
				    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
				}
				else
				{
				    SendClientMessage(playerid, COLOR_P@, "Level od 1 do 100.");
				    ShowPlayerDialogEx(playerid, 822, DIALOG_STYLE_INPUT, "Warunek wynajmu - level", "Wpisz od jakiego levelu b�dzie mo�na wynaj�� tw�j dom", "Wybierz", "Wr��");
				}
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 819, DIALOG_STYLE_LIST, "Warunek wynajmu", "Odpowiednia frakcja\nOdpowiednia rodzina\nOdpowiedni level\nLevel Konta Premium", "Wybierz", "Wyjd�");
		    }
		}
	    if(dialogid == 823)
		{
		    if(response)
		    {
		        new string[256];
		        new dom = PlayerInfo[playerid][pDom];
				if(strval(inputtext) == 1 || strval(inputtext) == 2 || strval(inputtext) == 3)
				{
				    format(string, sizeof(string), "Teraz tylko ludzie z Kontem Premium wi�kszym lub r�wnym %d b�d� mogli wynajmowa� u ciebie dom.", strval(inputtext));
				    SendClientMessage(playerid, COLOR_P@, string);
		    		Dom[dom][hWynajem] = 3;
		    		Dom[dom][hWW] = 4;
		    		Dom[dom][hTWW] = strval(inputtext);
				    ZapiszDom(dom);
				    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
				}
				else
				{
				    SendClientMessage(playerid, COLOR_P@, "Level KP od 1 do 3.");
				    ShowPlayerDialogEx(playerid, 823, DIALOG_STYLE_INPUT, "Warunek wynajmu - KP", "Wpisz od jakiego levelu Konta Premium b�dzie mo�na wynaj�� tw�j dom", "Wybierz", "Wr��");
				}
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 819, DIALOG_STYLE_LIST, "Warunek wynajmu", "Odpowiednia frakcja\nOdpowiednia rodzina\nOdpowiedni level\nLevel Konta Premium", "Wybierz", "Wyjd�");
		    }
		}
		if(dialogid == 824)
		{
		    new string[256];
		    if(response)
		    {
		        new dom = PlayerInfo[playerid][pDom];
				if(strval(inputtext) >= (2500*IntInfo[Dom[dom][hDomNr]][Kategoria]) && strval(inputtext) <= 1000000 && strval(inputtext) != 0)
				{
		    		Dom[dom][hCenaWynajmu] = strval(inputtext);
				    ZapiszDom(dom);
				    format(string, sizeof(string), "Cena wynajmu ustalona na %d$", strval(inputtext));
				    SendClientMessage(playerid, COLOR_P@, string);
				    ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
				}
				else
				{
				    format(string, sizeof(string), "Cena wynajmu od %d$ do 1000000$", (2500*IntInfo[Dom[dom][hDomNr]][Kategoria]));
				    SendClientMessage(playerid, COLOR_P@, string);
				    ShowPlayerDialogEx(playerid, 824, DIALOG_STYLE_INPUT, "Cena wynajmu", "Wpisz, za ile grcze mog� wynaj�� u ciebie dom.\n(Cena do ustalenia tylko w przypadku wynajmowania dla wszystkich i wynajmu z warunkiem)", "Wybierz", "Wr��");
				}
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
		    }
		}
		if(dialogid == 825)
		{
		    if(response)
		    {
		        new dom = PlayerInfo[playerid][pDom];
		        if(strlen(inputtext) >= 1 || strlen(inputtext) <= 128)
		        {
		            new message[128];
	                format(message, sizeof(message), "%s", inputtext);
	                mysql_real_escape_string(message, message);
		            Dom[dom][hKomunikatWynajmu] = message;
				    ZapiszDom(dom);
				    SendClientMessage(playerid, COLOR_P@, "Komunikat wynajmu to teraz:");
				    SendClientMessage(playerid, COLOR_WHITE, inputtext);
		            ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
		        }
		        else
		        {
		            SendClientMessage(playerid, COLOR_P@, "Wiadomo�� mo�e zawiera� od 1 do 1000 znak�w.");
		            ShowPlayerDialogEx(playerid, 825, DIALOG_STYLE_LIST, "Wiadomo�� dla lokator�w", "Tu mo�esz ustali� co b�dzie si� wy�wietla� osob� kt�re wynajmuj� tw�j dom.", "Wybierz", "Wr��");
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
		    }
		}
		if(dialogid == 826)
		{
		    if(response)
		    {
		        new dom = PlayerInfo[playerid][pDom];
		        new string[512];
		        switch(listitem)
		        {
		            case 0://Sejf
					{
					    new k;
					    new m;
					    new d;
					    if(Dom[dom][hSejf] < 10)
					    {
					        k = 100000*(Dom[dom][hSejf]+1);
					        m = 5000*(Dom[dom][hSejf]+1);
					        d = 2*(Dom[dom][hSejf]+1);
					    	format(string, sizeof(string), "Sejf - pozwala przechowywa� got�wk�, materia�y, marihuan� i heroin� w domu.\nKa�dy nast�pny poziom sejfu pozwala przechowywa� o 100 000$, 10 000 materia��w i 10 drag�w obu typ�w wi�cej\nKiedy sejf osi�gnie 10 poziom ka�dy nast�pny b�dzie mia� mo�liwo�� przechowywania o 1 000 000$, 100 000 materia��w i 20 drag�w wi�cej\n\nAby kupi� ten sejf musisz posiada� %d$, %d materia��w, %dg Marihuany i %dg Heroiny", k, m, d, d);
						}
						else
						{
						    k = 1000000*(Dom[dom][hSejf]+1);
					        m = 5000*(Dom[dom][hSejf]+1);
					        d = 2*(Dom[dom][hSejf]+1);
							format(string, sizeof(string), "Sejf - pozwala przechowywa� got�wk�, materia�y, marihuan� i heroin� w domu.\nKa�dy nast�pny poziom sejfu pozwala przechowywa� o 100 000$, 10 000 materia��w i 10 drag�w obu typ�w wi�cej\nKiedy sejf osi�gnie 10 poziom ka�dy nast�pny b�dzie mia� mo�liwo�� przechowywania o 1 000 000$, 100 000 materia��w i 20 drag�w wi�cej\n\nAby kupi� ten sejf musisz posiada� %d$, %d materia��w, %dg Marihuany i %dg Heroiny", k, m, d, d);
						}
						ShowPlayerDialogEx(playerid, 827, DIALOG_STYLE_MSGBOX, "Kupowanie sejfu", string, "KUP!", "Cofnij");
					}
					case 1://Zbrojownia
					{
					    ShowPlayerDialogEx(playerid, 1231, DIALOG_STYLE_MSGBOX, "Zablokowane", "Ta opcja jest na razie w fazie produkcji", "Wr��", "Wr��");
					    /*if(Dom[dom][hZbrojownia] == 0)
					    {
					    	ShowPlayerDialogEx(playerid, 8281, DIALOG_STYLE_MSGBOX, "Kupowanie Zbrojowni", "Zbrojownia - pozwala przechowywa� bro� w domu.\nNa pocz�tku kupujesz pomnieszczenie zbrojowni, potem mo�esz przystosowa� j� do przechowywania r�nych rodzaj�w broni, na co b�dziesz musia� wyda� dodakowe pieni�dze.\nKoszt pomieszczenia zbrojowni to 1 000 000$, wymagane jest posiadanie licencji na bro�. Po kupieniu b�dziesz m�g� przystosowywa� j� do swoich potrzeb.", "KUP!", "Cofnij");
						}
						else if(Dom[dom][hZbrojownia] == 1)
						{
						    DialogZbrojowni(playerid);
						}*/
					}
					case 2://Gara�
					{
                        ShowPlayerDialogEx(playerid, 1231, DIALOG_STYLE_MSGBOX, "Zablokowane", "Ta opcja jest obecnie przebudowywana.\nPrzepraszamy za utrudnienia.", "Wr��", "Wr��");
					    //ShowPlayerDialogEx(playerid, 829, DIALOG_STYLE_MSGBOX, "Kupowanie gara�u", "Gara� - dodaj� nowy slot dzi�ki kt�remu mo�esz posiada� o 1 auto wi�cej.\nAuto ze slotu gara�owego mo�esz prakowa� tylko 20 metr�w od domu, ka�dy nast�pny poziom kosztuje 500 000$ i zwi�ksza odleg�o�� parkowania o 20 metr�w.\nAby go kupi� potrzebujesz turbow�zek.", "KUP!", "Cofnij");
					}
					case 3://Apteczka
					{
					    if(Dom[dom][hApteczka] == 0)
					    {
	       					format(string, sizeof(string), "Apteczka - pozwala leczy� si� w domu (przywraca 100 procent HP).\n\nAby j� kupi� potrzebujesz 100 000$, piwo, 10g heroiny i 10g marihuany.");
	                        ShowPlayerDialogEx(playerid, 830, DIALOG_STYLE_MSGBOX, "Kupowanie Apteczki", string, "KUP!", "Cofnij");
						}
						else
						{
						    SendClientMessage(playerid, COLOR_P@, "Posiadasz maksymalny level apteczki (1)");
		        			KupowanieDodatkow(playerid, dom);
						}
					}
					case 4://Pancerz
					{
					    if(Dom[dom][hKami] < 9)
					    {
					        format(string, sizeof(string), "Pancerz - pozwala on za�o�y� kamizelk� kuloodporn� w domu.\nPierwszy poziom daje 10 procent pancerza a ka�dy nast�pny dodaje o 10 procent wi�cej.\n\nAby go kupi� potrzebujesz %d$, wino Komandos, Apteczk�, 50 procent pancerza i M4.", 100000*(Dom[dom][hKami]+1));
	                        ShowPlayerDialogEx(playerid, 830, DIALOG_STYLE_MSGBOX, "Kupowanie Pancerza", string, "KUP!", "Cofnij");
						}
						else
						{
						    SendClientMessage(playerid, COLOR_P@, "Posiadasz maksymalny level kamizelki (9)");
		        			KupowanieDodatkow(playerid, dom);
						}
					}
					case 5://L�dowisko
					{
					    ShowPlayerDialogEx(playerid, 832, DIALOG_STYLE_MSGBOX, "Kupowanie l�dowiska", "L�dowisko - pozwala parkowa� pojazd lataj�cy nie tylko na lotnisku ale tak�e przy swoim domu.\nPrzy 1 poziomie l�dowiska, kt�ry kosztuje 10 mln, pojazd lataj�cy mo�esz parkowa� 20 metr�w od domu. Ka�dy nast�pny poziom kosztuje 1 000 000$ i zwi�ksza t� warto�� o kolejne 20 metr�w.", "KUP!", "Cofnij");
					}
					case 6://Alarm
					{
					    ShowPlayerDialogEx(playerid, 1231, DIALOG_STYLE_MSGBOX, "Zablokowane", "Ta opcja jest na razie w fazie produkcji", "Wr��", "Wr��");
					}
					case 7://Zamek
					{
					    ShowPlayerDialogEx(playerid, 1231, DIALOG_STYLE_MSGBOX, "Zablokowane", "Ta opcja jest na razie w fazie produkcji", "Wr��", "Wr��");
					}
					case 8://Komputer
					{
					    ShowPlayerDialogEx(playerid, 1231, DIALOG_STYLE_MSGBOX, "Zablokowane", "Ta opcja jest na razie w fazie produkcji", "Wr��", "Wr��");
					}
					case 9://Sprz�t RTV
					{
					    ShowPlayerDialogEx(playerid, 1231, DIALOG_STYLE_MSGBOX, "Zablokowane", "Ta opcja jest na razie w fazie produkcji", "Wr��", "Wr��");
					}
					case 10://Zestaw hazardzisty
					{
					    /*if(Dom[dom][hHazard] < 3)
					    {
					        //format(string, sizeof(string), "Zestaw hazardzisty - pozwala gra� w r�ne gry hazardowe niewychodz�c z domu.\nPierwszy poziom daje mo�liwo�� grania w ko�o fortuny, drugi w ruletk� a trzeci w oczko. Zu�ywa on OMGXXXXWTF produkt�w domu.\n\nAby go kupi� potrzebujesz %d$", 100000*(Dom[dom][hKami]+1));
	                        //ShowPlayerDialogEx(playerid, 830, DIALOG_STYLE_MSGBOX, "Kupowanie Zestawu Hazardzisty", string, "KUP!", "Cofnij");
					    }
					    else
					    {
					        SendClientMessage(playerid, COLOR_P@, "Posiadasz wszystkie dodatki hazardowe (ko�o fortuny, ruletka i blackjack)");
		        			KupowanieDodatkow(playerid, dom);
					    }*/
					    ShowPlayerDialogEx(playerid, 1231, DIALOG_STYLE_MSGBOX, "Zablokowane", "Ta opcja jest na razie w fazie produkcji", "Wr��", "Wr��");
					}
					case 11://Szafa
					{
					    /*if(Dom[dom][hSzafa] == 0)
					    {
					    }
					    else
					    {
					        SendClientMessage(playerid, COLOR_P@, "Posiadasz maksymalny level szafy (1)");
		        			KupowanieDodatkow(playerid, dom);
					    }*/
					    ShowPlayerDialogEx(playerid, 1231, DIALOG_STYLE_MSGBOX, "Zablokowane", "Ta opcja jest na razie w fazie produkcji", "Wr��", "Wr��");
					}
					case 12://Tajemnicze dodatki
					{
					    ShowPlayerDialogEx(playerid, 1231, DIALOG_STYLE_MSGBOX, "Zablokowane", "Ta opcja jest na razie w fazie produkcji", "Wr��", "Wr��");
					}
		        }
		    }
		    if(!response)
		    {
		        if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 0)
		    	{
					ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nOtw�rz\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
				}
				else if(Dom[PlayerInfo[playerid][pDom]][hZamek] == 1)
				{
	   				ShowPlayerDialogEx(playerid, 810, DIALOG_STYLE_LIST, "Panel Domu", "Informacje o domu\nZamknij\nWynajem\nPanel dodatk�w\nO�wietlenie\nSpawn\nKup dodatki\nPomoc", "Wybierz", "Anuluj");
				}
		    }
		}
		if(dialogid == 1231)
		{
		    KupowanieDodatkow(playerid, PlayerInfo[playerid][pDom]);
		}
		if(dialogid == 827)//kupowanie sejfu
		{
		    new dom = PlayerInfo[playerid][pDom];
		    if(response)
		    {
		        new str3[256];
		    	if(Dom[dom][hSejf] < 10)
			    {
			        if(PlayerInfo[playerid][pMats] >= 5000*(Dom[dom][hSejf]+1) && PlayerInfo[playerid][pDrugs] >= 2*(Dom[dom][hSejf]+1) /*&& PlayerInfo[playerid][pZiolo] >= 2*(Dom[dom][hSejf]+1)*/)
			        {
				        if(kaska[playerid] != 0 && kaska[playerid] >= 100000*(Dom[dom][hSejf]+1))
				        {
							new dmdm = 100000*(Dom[dom][hSejf]+1);
							new matsmats = 5000*(Dom[dom][hSejf]+1);
							new dragdrag = 2*(Dom[dom][hSejf]+1);
							PlayerInfo[playerid][pMats] -= matsmats;
							//PlayerInfo[playerid][pZiolo] -= dragdrag;
							PlayerInfo[playerid][pDrugs] -= dragdrag;
							ZabierzKase(playerid, dmdm);
							format(str3, sizeof(str3), "Kupi�e� %d level Sejfu za %d$, %d drag�w oraz %d mats�w. Aby go u�y� wpisz /sejf.", Dom[dom][hSejf], dmdm, 4*Dom[dom][hSejf], matsmats);
							SendClientMessage(playerid, COLOR_P@, str3);
							format(str3, sizeof(str3), "Pojemno�� sejfu: Kasa: %d$, Materia�y: %d, Marihuana: %d, Heroina: %d", dmdm, matsmats*2, dragdrag*5, dragdrag*5);
							SendClientMessage(playerid, COLOR_P@, str3);
							Dom[dom][hSejf] ++;
							KupowanieDodatkow(playerid, dom);
							//log
							new day, month, year;
							getdate(day, month, year);
							format(str3, sizeof(str3), "[%d:%d:%d] %s [UID: %d]  kupil dodatek do domu [ID: %d] - sejf [Aktualny poziom: %d] ", day, month, year, GetNick(playerid, true), PlayerInfo[playerid][pUID], dom, Dom[dom][hSejf]);
							DomyLog(str3);
	       				}
	       				else
	       				{
				    		format(str3, sizeof(str3), "%d level sejfu kosztuje %d$, a ty tyle nie masz!", Dom[dom][hSejf]+1, 100000*(Dom[dom][hSejf]+1));
							SendClientMessage(playerid, COLOR_P@, str3);
							KupowanieDodatkow(playerid, dom);
	       				}
					}
					else
					{
		  				format(str3, sizeof(str3), "Aby kupi� sejf o levelu %d musisz mie� %d materia��w, %dg Marihuany i %dg Heroiny", Dom[dom][hSejf]+1, 5000*(Dom[dom][hSejf]+1), 2*(Dom[dom][hSejf]+1), 2*(Dom[dom][hSejf]+1));
						SendClientMessage(playerid, COLOR_P@, str3);
						KupowanieDodatkow(playerid, dom);
					}
			    }
			    else
			   	{
	      			if(PlayerInfo[playerid][pMats] >= (5000*(Dom[dom][hSejf]+1)) && PlayerInfo[playerid][pDrugs] >= (2*(Dom[dom][hSejf]+1)) /*&& PlayerInfo[playerid][pZiolo] >= (2*(Dom[dom][hSejf]+1))*/ && PlayerInfo[playerid][pLevel] >= (Dom[dom][hSejf]+1))
			       	{
				        if(kaska[playerid] != 0 && kaska[playerid] >= 1000000*((Dom[dom][hSejf]-10)+1))
				        {
	            			new dmdm = 1000000*((Dom[dom][hSejf]-10)+1);
							new matsmats = 5000*(Dom[dom][hSejf]+1);
							new dragdrag = 2*(Dom[dom][hSejf]+1);
							PlayerInfo[playerid][pMats] -= matsmats;
							//PlayerInfo[playerid][pZiolo] -= dragdrag;
							PlayerInfo[playerid][pDrugs] -= dragdrag;
							ZabierzKase(playerid, dmdm);
							format(str3, sizeof(str3), "Kupi�e� %d level Sejfu za %d$, %d drag�w oraz %d mats�w. Aby go u�y� wpisz /sejf.", Dom[dom][hSejf], 1000000*(Dom[dom][hSejf]-10), 4*Dom[dom][hSejf], 5000*Dom[dom][hSejf]);
							SendClientMessage(playerid, COLOR_P@, str3);
							format(str3, sizeof(str3), "Pojemno�� sejfu: Kasa: %d$, Materia�y: %d, Marihuana: %d, Heroina: %d", dmdm, 100000*((Dom[dom][hSejf]-10)+1), dragdrag*10, dragdrag*10);
							SendClientMessage(playerid, COLOR_P@, str3);
							Dom[dom][hSejf] ++;
							KupowanieDodatkow(playerid, dom);
							//log
							new day, month, year;
							getdate(day, month, year);
							format(str3, sizeof(str3), "[%d:%d:%d] %s [UID: %d]  kupil dodatek do domu [ID: %d] - sejf [Aktualny poziom: %d] ", day, month, year, GetNick(playerid, true), PlayerInfo[playerid][pUID], dom, Dom[dom][hSejf]);
							DomyLog(str3);
				        }
				        else
				        {
						    format(str3, sizeof(str3), "%d level sejfu kosztuje %d$, a ty tyle nie masz!", Dom[dom][hSejf]+1, 1000000*((Dom[dom][hSejf]-10)+1));
							SendClientMessage(playerid, COLOR_P@, str3);
							KupowanieDodatkow(playerid, dom);
				        }
	    			}
					else
					{
			  			format(str3, sizeof(str3), "Aby kupi� sejf o levelu %d musisz mie� %d materia��w, %dg Marihuany i %dg Heroiny oraz %d LEVEL", Dom[dom][hSejf]+1, 5000*(Dom[dom][hSejf]+1), 2*(Dom[dom][hSejf]+1), 2*(Dom[dom][hSejf]+1), (Dom[dom][hSejf]+1));
						SendClientMessage(playerid, COLOR_P@, str3);
						KupowanieDodatkow(playerid, dom);
					}
			    }
			}
		    if(!response)
		    {
	            KupowanieDodatkow(playerid, dom);
		    }
		}
		if(dialogid == 8281)//kupowanie zbrojowni
		{
		    new dom = PlayerInfo[playerid][pDom];
		    if(response)
		    {
	    		if(PlayerInfo[playerid][pGunLic] != 0)
	      		{
			        if(kaska[playerid] != 0 && kaska[playerid] >= 1000000)
			        {
			            Dom[dom][hZbrojownia] = 1;
			            DajKase(playerid, -1000000);
			            SendClientMessage(playerid, COLOR_P@, "Gratulacje, kupi�e� zbrojownie za 1 000 000$, skonfiguruj teraz co chcesz w niej przechowywa�! Aby jej u�y� wpisz /zbrojownia we wn�trzu swojego domu");
						DialogZbrojowni(playerid);
						
						new day, month, year;
						new str3[256];
						getdate(day, month, year);
						format(str3, sizeof(str3), "[%d:%d:%d] %s [UID: %d]  kupil dodatek do domu [ID: %d] - Zbrojownie", day, month, year, GetNick(playerid, true), PlayerInfo[playerid][pUID], dom);
						DomyLog(str3);
			        }
			        else
					{
					    SendClientMessage(playerid, COLOR_P@, "Nie masz 1 000 000$!");
					}
				}
				else
				{
				    SendClientMessage(playerid, COLOR_P@, "Aby kupi� zbrojownie musisz mie� pozowlenie na bro�!");
				}
		    }
		    if(!response)
		    {
	            KupowanieDodatkow(playerid, dom);
		    }
		}
		if(dialogid == 8282)//kupowanie ulepsze� zbrojowni
		{
		    new dom = PlayerInfo[playerid][pDom];
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0://Kastet ( 0 )
		            {
		            	ShowPlayerDialogEx(playerid, 8220, DIALOG_STYLE_MSGBOX, "Przystosowanie - Kastet", "Ten dodatek pozwala przechowywa� kastet w zbrojowni.\nCena przystosowania zbrojowni do przechowywania kastetu: 1 000$", "KUP!", "Cofnij");
		            }
		            case 1://Spadochron ( 11 )
		            {
		                ShowPlayerDialogEx(playerid, 8221, DIALOG_STYLE_MSGBOX, "Przystosowanie - Spadochron", "Ten dodatek pozwala przechowywa� spadochron w zbrojowni.\nCena przystosowania zbrojowni do przechowywania spadochronu: 5 000$", "KUP!", "Cofnij");
		            }
		            case 2://Sprej ga�nica i aparat ( 9 )
		            {
		                ShowPlayerDialogEx(playerid, 8222, DIALOG_STYLE_MSGBOX, "Przystosowanie - Sprej ga�nica i aparat", "Ten dodatek pozwala przechowywa� sprej ga�nic� i aparat w zbrojowni.\nCena przystosowania zbrojowni do przechowywania spreju ga�nicy i aparatu: 40 000$", "KUP!", "Cofnij");
		            }
		            case 3://Wibratory kwiaty i laska ( 10 )
		            {
		                ShowPlayerDialogEx(playerid, 8223, DIALOG_STYLE_MSGBOX, "Przystosowanie - Wibratory kwiaty i laska", "Ten dodatek pozwala przechowywa� wibratory kwiaty i lask� w zbrojowni.\nCena przystosowania zbrojowni do przechowywania wibrator�w kwiat�w i laski: 50 000$", "KUP!", "Cofnij");
		            }
		            case 4://Bro� bia�a ( 1 )
		            {
		                ShowPlayerDialogEx(playerid, 8224, DIALOG_STYLE_MSGBOX, "Przystosowanie - Bro� bia�a", "Ten dodatek pozwala przechowywa� bro� bia�� w zbrojowni.\nCena przystosowania zbrojowni do przechowywania broni bia�ej: 75 000$", "KUP!", "Cofnij");
		            }
		            case 5://Pistolety ( 2 )
		            {
		                ShowPlayerDialogEx(playerid, 8225, DIALOG_STYLE_MSGBOX, "Przystosowanie - Pistolety", "Ten dodatek pozwala przechowywa� pistolety w zbrojowni.\nCena przystosowania zbrojowni do przechowywania pistolet�w: 250 000$", "KUP!", "Cofnij");
		            }
		            case 6://Strzelby ( 3 )
		            {
		                ShowPlayerDialogEx(playerid, 8226, DIALOG_STYLE_MSGBOX, "Przystosowanie - Strzelby", "Ten dodatek pozwala przechowywa� strzelby w zbrojowni.\nCena przystosowania zbrojowni do przechowywania strzelb: 450 000$", "KUP!", "Cofnij");
		            }
		            case 7://Pistolety maszynowe ( 4 )
		            {
		                ShowPlayerDialogEx(playerid, 8227, DIALOG_STYLE_MSGBOX, "Przystosowanie - Pistolety maszynowe", "Ten dodatek pozwala przechowywa� pistolety maszynowe w zbrojowni.\nCena przystosowania zbrojowni do przechowywania pistolet�w maszynowych: 550 000$", "KUP!", "Cofnij");
		            }
		            case 8://Karabiny szturmowe ( 5 )
		            {
		                ShowPlayerDialogEx(playerid, 8228, DIALOG_STYLE_MSGBOX, "Przystosowanie - Karabiny szturmowe", "Ten dodatek pozwala przechowywa� Karabiny szturmowe w zbrojowni.\nCena przystosowania zbrojowni do przechowywania karabin�w szturmowych: 850 000$", "KUP!", "Cofnij");
		            }
		            case 9://Snajperki ( 6 )
		            {
		                ShowPlayerDialogEx(playerid, 8229, DIALOG_STYLE_MSGBOX, "Przystosowanie - Snajperki", "Ten dodatek pozwala przechowywa� snajperki w zbrojowni.\nCena przystosowania zbrojowni do przechowywania snajperek: 700 000$", "KUP!", "Cofnij");
		            }
		            case 10://Bro� ci�ka ( 7 )
		            {
		                ShowPlayerDialogEx(playerid, 8230, DIALOG_STYLE_MSGBOX, "Przystosowanie - Bro� ci�ka", "Ten dodatek pozwala przechowywa� Bro� ci�k� w zbrojowni.\nCena przystosowania zbrojowni do przechowywania broni ci�kiej: 2 000 000$", "KUP!", "Cofnij");
		            }
		            case 11://�adunki wybuchowe ( 8 )
		            {
		                ShowPlayerDialogEx(playerid, 8231, DIALOG_STYLE_MSGBOX, "Przystosowanie - �adunki wybuchowe", "Ten dodatek pozwala przechowywa� �adunki wybuchowe w zbrojowni.\nCena przystosowania zbrojowni do przechowywania �adunk�w wybuchowych: 4 000 000$", "KUP!", "Cofnij");
		            }
		        }
		    }
		    if(!response)
		    {
	            KupowanieDodatkow(playerid, dom);
		    }
		}
		if(dialogid == 830)//kupowanie apteczki
		{
		    new dom = PlayerInfo[playerid][pDom];
		    if(response)
		    {
	            new Float:HP;
				GetPlayerHealth(playerid, HP);
	   			if(/*PlayerInfo[playerid][pZiolo] >= 10 &&*/ PlayerInfo[playerid][pDrugs] >= 10 && PlayerInfo[playerid][pPiwo] >= 1 && HP >= 100 && STDPlayer[playerid] == 0)
			    {
	      			if(kaska[playerid] != 0 && kaska[playerid] >= 100000)
		        	{
				        DajKase(playerid, -100000);
						Dom[dom][hApteczka] = 1;
						//PlayerInfo[playerid][pZiolo] -= 10;
						PlayerInfo[playerid][pDrugs] -= 10;
						PlayerInfo[playerid][pPiwo] --;
						//Dom[dom][hMagazyn] --;
						SendClientMessage(playerid, COLOR_P@, "Kupi�e� Apteczk� za 100 000$, piwo oraz 10g marihuany i heroiny. Aby jej u�y� wpisz /ulecz");
						KupowanieDodatkow(playerid, dom);
						//log
						new str3[256];
						new day, month, year;
						getdate(day, month, year);
						format(str3, sizeof(str3), "[%d:%d:%d] %s [UID: %d]  kupil dodatek do domu [ID: %d] - apteczka [Aktualny LVL: %d]", day, month, year, GetNick(playerid, true), PlayerInfo[playerid][pUID], dom, Dom[dom][hApteczka]);
						DomyLog(str3);
					}
					else
					{
					    SendClientMessage(playerid, COLOR_P@, "Apteczka kosztuje 100 000$ a ty tyle nie masz!");
				       	KupowanieDodatkow(playerid, dom);
					}
			    }
			    else
			    {
					SendClientMessage(playerid, COLOR_P@, "Aby kupi� apteczk� potrzebujesz: 10g marihuany, 10g herioiny, Mrucznego Gula, brak choroby i 100 HP");
			        KupowanieDodatkow(playerid, dom);
			    }
		    }
		    if(!response)
		    {
	            KupowanieDodatkow(playerid, dom);
		    }
		}
		if(dialogid == 831)//kupowanie pancerza
		{
		    new dom = PlayerInfo[playerid][pDom];
		    if(response)
		    {
	            new Float:ARMOR;
				GetPlayerArmour(playerid, ARMOR);
			    if(PlayerInfo[playerid][pWino] >= 1 && ARMOR >= 50 && Dom[dom][hApteczka] != 0 && PlayerInfo[playerid][pGun5] == 31 && PlayerInfo[playerid][pDetSkill] >= 101 )
	   			{
					new str3[256];
		 			if(kaska[playerid] != 0 && kaska[playerid] >= 100000*(Dom[dom][hKami]+1))
		    		{
				      	new dmdm = 100000*(Dom[dom][hKami]+1);
				      	ZabierzKase(playerid, dmdm);
						Dom[dom][hKami] ++;
						PlayerInfo[playerid][pWino] --;
						//Dom[dom][hMagazyn] --;
				    	format(str3, sizeof(str3), "Kupi�e� %d level Pancerza za %d$ i wino. Aby jej u�y� wpisz /pancerz", Dom[dom][hKami], 100000*(Dom[dom][hKami]+1));
						SendClientMessage(playerid, COLOR_P@, str3);
						KupowanieDodatkow(playerid, dom);
						//log
						new day, month, year;
						getdate(day, month, year);
						format(str3, sizeof(str3), "[%d:%d:%d] %s [UID: %d]  kupil dodatek do domu [ID: %d] - pancerz [Aktualny LVL: %d]", day, month, year, GetNick(playerid, true), PlayerInfo[playerid][pUID], dom, Dom[dom][hKami]);
						DomyLog(str3);
					}
					else
					{
			    		
			    		format(str3, sizeof(str3), "%d level pancerza kosztuje %d$ a ty tyle nie masz!", Dom[dom][hKami]+1, 100000*(Dom[dom][hKami]+1));
						SendClientMessage(playerid, COLOR_P@, str3);
						KupowanieDodatkow(playerid, dom);
					}
			    }
			    else
			    {
			      	SendClientMessage(playerid, COLOR_P@, "Aby kupi� pancerz potrzebujesz: Wino Komandos, 50 procent pancerza, Apteczk�, 3 skill �owcy nagr�d i M4");
			      	KupowanieDodatkow(playerid, dom);
			    }
		    }
		    if(!response)
		    {
	            KupowanieDodatkow(playerid, dom);
		    }
		}
	    if(dialogid == 832)//kupowanie l�dowiska
		{
		    new dom = PlayerInfo[playerid][pDom];
		    if(response)
		    {
                if(Dom[dom][hLadowisko] == 0)
                {
                	if(kaska[playerid] != 0 && kaska[playerid] >= 10000000)
                	{
                	    DajKase(playerid, -10000000);
						Dom[dom][hLadowisko] = 20;
						SendClientMessage(playerid, COLOR_P@, "Kupi�e� L�dowisko za 10 000 000$. Mo�esz teraz parkowa� sw�j pojazd lataj�cy 20 metr�w od domu");
						KupowanieDodatkow(playerid, dom);
						//log
						new str3[256];
						new day, month, year;
						getdate(day, month, year);
						format(str3, sizeof(str3), "[%d:%d:%d] %s [UID: %d]  kupil dodatek do domu [ID: %d] - Ladowisko [Aktualny LVL: %d]", day, month, year, GetNick(playerid, true), PlayerInfo[playerid][pUID], dom, Dom[dom][hLadowisko]);
						DomyLog(str3);
                	}
                	else
                	{
                	    SendClientMessage(playerid, COLOR_P@, "Gara� kosztuje 10 000 000$ a ty tyle nie masz!");
			       		KupowanieDodatkow(playerid, dom);
                	}
                }
                else
                {
                    if(kaska[playerid] != 0 && kaska[playerid] >= 1000000)
                	{
                	    DajKase(playerid, -1000000);
						Dom[dom][hLadowisko] += 20;
						SendClientMessage(playerid, COLOR_P@, "Kupi�e� ulepszenie l�dowiska za 1 000 000$. Mo�esz teraz parkowa� sw�j pojazd lataj�cy o 20 metr�w wi�cej ni� poprzednio.");
						KupowanieDodatkow(playerid, dom);
						//log
						new day, month, year;
						new str3[256];
						getdate(day, month, year);
						format(str3, sizeof(str3), "[%d:%d:%d] %s [UID: %d]  kupil dodatek do domu [ID: %d] - Ladowisko [Aktualny LVL: %d]", day, month, year, GetNick(playerid, true), PlayerInfo[playerid][pUID], dom, Dom[dom][hLadowisko]);
						DomyLog(str3);
                	}
                	else
                	{
                	    SendClientMessage(playerid, COLOR_P@, "Gara� kosztuje 1 000 000$ a ty tyle nie masz!");
			       		KupowanieDodatkow(playerid, dom);
                	}
                }
		    }
		    if(!response)
		    {
	            KupowanieDodatkow(playerid, dom);
		    }
		}
		if(dialogid == 8000)
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0://Zawarto�� sejfu
		            {
		                new zawartosc[256];
	                 	new dom = PlayerInfo[playerid][pDomWKJ];
		                format(zawartosc, sizeof(zawartosc), "Zawarto�� sejfu:\n\nGot�wka:\t%d$\nMateria�y:\t%d kg\nMarihuana:\t%d gram\nHeroina:\t%d gram", Dom[dom][hS_kasa], Dom[dom][hS_mats], Dom[dom][hS_ziolo], Dom[dom][hS_drugs]);
		            	ShowPlayerDialogEx(playerid, 8001, DIALOG_STYLE_MSGBOX, "Sejf - zawarto��", zawartosc, "Cofnij", "Wyjd�");
		            }
		            case 1://W�� do sejfu
		            {
	            		ShowPlayerDialogEx(playerid, 8002, DIALOG_STYLE_LIST, "Sejf - w��", "Got�wk�\nMateria�y\nMarihuane\nHeroine", "Wybierz", "Wr��");
		            }
		            case 2://wyjmij z sejfu
		            {
		                ShowPlayerDialogEx(playerid, 8003, DIALOG_STYLE_LIST, "Sejf - wyjmij", "Got�wk�\nMateria�y\nMarihuane\nHeroine", "Wybierz", "Wr��");
		            }
		            case 3://kod do sejfu
		            {
		                if(PlayerInfo[playerid][pDom] == PlayerInfo[playerid][pDomWKJ])
		                {
		                	ShowPlayerDialogEx(playerid, 8004, DIALOG_STYLE_INPUT, "Sejf - ustalanie kodu", "Wpisz kod do sejfu w okienko poni�ej", "OK", "Wr��");
						}
						else
						{
						    SendClientMessage(playerid, COLOR_P@, "Tylko dla w�a�ciciela");
						    ShowPlayerDialogEx(playerid, 8000, DIALOG_STYLE_LIST, "Sejf", "Zawarto�� sejfu\nW�� do sejfu\nWyjmij z sejfu\nUstal kod sejfu", "Wybierz", "Anuluj");
						}
					}
		        }
		    }
		}
		if(dialogid == 8001)
		{
		    if(response)
		    {
		        ShowPlayerDialogEx(playerid, 8000, DIALOG_STYLE_LIST, "Sejf", "Zawarto�� sejfu\nW�� do sejfu\nWyjmij z sejfu\nUstal kod sejfu", "Wybierz", "Anuluj");
		    }
		}
		if(dialogid == 8002)//wk�adanie
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0://kasa
		            {
		                ShowPlayerDialogEx(playerid, 8005, DIALOG_STYLE_INPUT, "Sejf - wk�adanie", "Wpisz jak� ilo�� got�wki chcesz w�o�y� do sejfu", "W��", "Wr��");
		            }
		            case 1://matsy
		            {
		                ShowPlayerDialogEx(playerid, 8006, DIALOG_STYLE_INPUT, "Sejf - wk�adanie", "Wpisz jak� ilo�� materia��w chcesz w�o�y� do sejfu", "W��", "Wr��");
		            }
		            case 2://marycha
		            {
		                ShowPlayerDialogEx(playerid, 8008, DIALOG_STYLE_INPUT, "Sejf - wk�adanie", "Wpisz jak� ilo�� heroiny chcesz w�o�y� do sejfu", "W��", "Wr��");
		                //ShowPlayerDialogEx(playerid, 8007, DIALOG_STYLE_INPUT, "Sejf - wk�adanie", "Wpisz jak� ilo�� marihuany chcesz w�o�y� do sejfu", "W��", "Wr��");
		            }
		            case 3://heroina
		            {
		                ShowPlayerDialogEx(playerid, 8008, DIALOG_STYLE_INPUT, "Sejf - wk�adanie", "Wpisz jak� ilo�� heroiny chcesz w�o�y� do sejfu", "W��", "Wr��");
		            }
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 8000, DIALOG_STYLE_LIST, "Sejf", "Zawarto�� sejfu\nW�� do sejfu\nWyjmij z sejfu\nUstal kod sejfu", "Wybierz", "Anuluj");
		    }
		}
		if(dialogid == 8003)//wyjmowanie
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0://kasa
		            {
		                ShowPlayerDialogEx(playerid, 8009, DIALOG_STYLE_INPUT, "Sejf - wyjmowanie", "Wpisz jak� ilo�� got�wki chcesz wyj�� z sejfu", "Wyjmij", "Wr��");
		            }
		            case 1://matsy
		            {
		                ShowPlayerDialogEx(playerid, 8010, DIALOG_STYLE_INPUT, "Sejf - wyjmowanie", "Wpisz jak� ilo�� materia��w chcesz wyj�� z sejfu", "Wyjmij", "Wr��");
		            }
		            case 2://marycha
		            {
		                ShowPlayerDialogEx(playerid, 8012, DIALOG_STYLE_INPUT, "Sejf - wyjmowanie", "Wpisz jak� ilo�� heroiny chcesz wyj�� z sejfu", "Wyjmij", "Wr��");
		                //ShowPlayerDialogEx(playerid, 8011, DIALOG_STYLE_INPUT, "Sejf - wyjmowanie", "Wpisz jak� ilo�� marihuany chcesz wyj�� z sejfu", "Wyjmij", "Wr��");
		            }
		            case 3://heroina
		            {
		                ShowPlayerDialogEx(playerid, 8012, DIALOG_STYLE_INPUT, "Sejf - wyjmowanie", "Wpisz jak� ilo�� heroiny chcesz wyj�� z sejfu", "Wyjmij", "Wr��");
					}
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 8000, DIALOG_STYLE_LIST, "Sejf", "Zawarto�� sejfu\nW�� do sejfu\nWyjmij z sejfu\nUstal kod sejfu", "Wybierz", "Anuluj");
		    }
		}
		if(dialogid == 8004)//kod do sejfu
		{
		    if(response)
		    {
		        if(strlen(inputtext) >= 4 && strlen(inputtext) <= 10)
		        {
	             	new kod[64];
	                new kodplik[20];
	                format(kodplik, sizeof(kodplik), "%s", inputtext);
	                mysql_real_escape_string(kodplik, kodplik);
					Dom[PlayerInfo[playerid][pDom]][hKodSejf] = kodplik;
					ZapiszDom(PlayerInfo[playerid][pDom]);
					format(kod, sizeof(kod), "Kod do sejfu to teraz: %s", inputtext);
					ShowPlayerDialogEx(playerid, 8000, DIALOG_STYLE_LIST, "Sejf", "Zawarto�� sejfu\nW�� do sejfu\nWyjmij z sejfu\nUstal kod sejfu", "Wybierz", "Anuluj");
					ZapiszDom(PlayerInfo[playerid][pDom]);
				}
		        else
		        {
		            SendClientMessage(playerid, COLOR_P@, "Kod do sejfu od 4 do 10 znak�w");
		            ShowPlayerDialogEx(playerid, 8004, DIALOG_STYLE_INPUT, "Sejf - ustalanie kodu", "Kod twojego sejfu nie jest ustalony - musisz go ustali�.\nAby to zrobi� wpisz nowy kod do okienka poni�ej. (MIN 4 MAX 10 znak�w)", "OK", "");
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 8000, DIALOG_STYLE_LIST, "Sejf", "Zawarto�� sejfu\nW�� do sejfu\nWyjmij z sejfu\nUstal kod sejfu", "Wybierz", "Anuluj");
		    }
		}
		if(dialogid == 8005)
		{
		    if(response)
		    {
		        if(!strlen(inputtext))
		        {
	                ShowPlayerDialogEx(playerid, 8005, DIALOG_STYLE_INPUT, "Sejf - wk�adanie", "Wpisz jak� ilo�� got�wki chcesz w�o�y� do sejfu", "W��", "Wr��");
		            return 1;
				}
		        new dom = PlayerInfo[playerid][pDomWKJ];
		        new string[256];
		        new maxwloz;
		        if(Dom[dom][hSejf] <= 10)
		        {
		            maxwloz = 100000*Dom[dom][hSejf];
		        }
		        else
		        {
	                maxwloz = 1000000*(Dom[dom][hSejf]-10);
		        }
		        new wkladanie = (maxwloz-Dom[dom][hS_kasa]);
		        if(strval(inputtext) >= 1 && strval(inputtext) <= wkladanie)
		        {
		            if(strval(inputtext) <= kaska[playerid] )
		            {
						new before, after;
						before = Dom[dom][hS_kasa] ;
			            Dom[dom][hS_kasa] += strval(inputtext);
						after = Dom[dom][hS_kasa];
						dini_IntSet(string, "S_kasa", Dom[dom][hS_kasa]);
			            ZabierzKase(playerid, strval(inputtext));
			            format(string, sizeof(string), "W�o�y�e� do sejfu %d$, znajduje si� w nim teraz: %d$.", strval(inputtext), Dom[dom][hS_kasa]);
			            SendClientMessage(playerid, COLOR_P@, string);
			            ShowPlayerDialogEx(playerid, 8002, DIALOG_STYLE_LIST, "Sejf - w��", "Got�wk�\nMateria�y\nMarihuane\nHeroine", "Wybierz", "Wr��");
			            ZapiszDom(PlayerInfo[playerid][pDom]);
						format(string, sizeof(string), "Gracz %s wlozyl %d$ do sejfu. W sejfie przed: %d, po: %d", GetNick(playerid), strval(inputtext), before, after);
						PayLog(string);
					}
					else
					{
					    SendClientMessage(playerid, COLOR_P@, "Nie sta� ci� aby w�o�y� tyle do sejfu");
		            	ShowPlayerDialogEx(playerid, 8005, DIALOG_STYLE_INPUT, "Sejf - wk�adanie", "Wpisz jak� ilo�� got�wki chcesz w�o�y� do sejfu", "W��", "Wr��");
					}
				}
		        else
		        {
		            format(string, sizeof(string), "Pojemno�� sejfu to %d$. Nie mo�esz w�o�y� do niego %d$ gdy� jest ju� w nim %d$. Maksymalna stawka jak� mo�esz teraz do niego w�o�y� to %d$", maxwloz, strval(inputtext), Dom[dom][hS_kasa], wkladanie);
		            SendClientMessage(playerid, COLOR_P@, string);
		            ShowPlayerDialogEx(playerid, 8005, DIALOG_STYLE_INPUT, "Sejf - wk�adanie", "Wpisz jak� ilo�� got�wki chcesz w�o�y� do sejfu", "W��", "Wr��");
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 8000, DIALOG_STYLE_LIST, "Sejf", "Zawarto�� sejfu\nW�� do sejfu\nWyjmij z sejfu\nUstal kod sejfu", "Wybierz", "Anuluj");
		    }
		}
		if(dialogid == 8006)
		{
		    if(response)
		    {
		        if(!strlen(inputtext))
		        {
	                ShowPlayerDialogEx(playerid, 8006, DIALOG_STYLE_INPUT, "Sejf - wk�adanie", "Wpisz jak� ilo�� materia��w chcesz w�o�y� do sejfu", "W��", "Wr��");
		            return 1;
				}
		        new dom = PlayerInfo[playerid][pDomWKJ];
		        new string[256];
		        new maxwloz;
		        if(Dom[dom][hSejf] <= 10)
		        {
		            maxwloz = (5000*(Dom[dom][hSejf])*2);
				}
		        else
		        {
	                maxwloz = 100000*(Dom[dom][hSejf]-10);
		        }
		        new wkladanie = (maxwloz-Dom[dom][hS_mats]);
		        if(strval(inputtext) >= 1 && strval(inputtext) <= wkladanie)
		        {
		            if(strval(inputtext) <= PlayerInfo[playerid][pMats])
		            {
			            Dom[dom][hS_mats] += strval(inputtext);
						dini_IntSet(string, "S_mats", Dom[dom][hS_mats]);
			            PlayerInfo[playerid][pMats] -= strval(inputtext);
			            format(string, sizeof(string), "W�o�y�e� do sejfu %d mats�w, znajduje si� w nim teraz: %d mats�w.", strval(inputtext), Dom[dom][hS_mats]);
			            SendClientMessage(playerid, COLOR_P@, string);
			            ShowPlayerDialogEx(playerid, 8002, DIALOG_STYLE_LIST, "Sejf - w��", "Got�wk�\nMateria�y\nMarihuane\nHeroine", "Wybierz", "Wr��");
			            ZapiszDom(PlayerInfo[playerid][pDom]);
						format(string, sizeof(string), "Gracz %s wlozyl %d matsow do sejfu", GetNick(playerid), strval(inputtext));
						PayLog(string);
					}
					else
					{
					    SendClientMessage(playerid, COLOR_P@, "Nie sta� ci� aby w�o�y� tyle do sejfu");
		            	ShowPlayerDialogEx(playerid, 8006, DIALOG_STYLE_INPUT, "Sejf - wk�adanie", "Wpisz jak� ilo�� materia��w chcesz w�o�y� do sejfu", "W��", "Wr��");
					}
				}
		        else
		        {
		            format(string, sizeof(string), "Pojemno�� sejfu to %d mats�w. Nie mo�esz w�o�y� do niego %d mats�w gdy� jest ju� w nim %d mats�w. Maksymalna ilo�� jak� mo�esz teraz do niego w�o�y� to %d mats�w", maxwloz, strval(inputtext), Dom[dom][hS_mats], wkladanie);
		            SendClientMessage(playerid, COLOR_P@, string);
		            ShowPlayerDialogEx(playerid, 8006, DIALOG_STYLE_INPUT, "Sejf - wk�adanie", "Wpisz jak� ilo�� materia��w chcesz w�o�y� do sejfu", "W��", "Wr��");
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 8000, DIALOG_STYLE_LIST, "Sejf", "Zawarto�� sejfu\nW�� do sejfu\nWyjmij z sejfu\nUstal kod sejfu", "Wybierz", "Anuluj");
		    }
		}
		if(dialogid == 8008)
		{
		    if(response)
		    {
		        if(!strlen(inputtext))
		        {
	                ShowPlayerDialogEx(playerid, 8008, DIALOG_STYLE_INPUT, "Sejf - wk�adanie", "Wpisz jak� ilo�� heroiny chcesz w�o�y� do sejfu", "W��", "Wr��");
		            return 1;
				}
		        new dom = PlayerInfo[playerid][pDomWKJ];
		        new string[256];
		        new maxwloz;
		        if(Dom[dom][hSejf] <= 10)
		        {
		            maxwloz = (2*Dom[dom][hSejf])*5;
		        }
		        else
		        {
	                maxwloz = 2*(Dom[dom][hSejf]*10);
		        }
		        new wkladanie = (maxwloz-Dom[dom][hS_drugs]);
		        if(strval(inputtext) >= 1 && strval(inputtext) <= wkladanie)
		        {
		            if(strval(inputtext) <= PlayerInfo[playerid][pDrugs])
		            {
			            Dom[dom][hS_drugs] += strval(inputtext);
			            PlayerInfo[playerid][pDrugs] -= strval(inputtext);
			            format(string, sizeof(string), "W�o�y�e� do sejfu %d drag�w, znajduje si� w nim teraz: %d drag�w.", strval(inputtext), Dom[dom][hS_drugs]);
			            SendClientMessage(playerid, COLOR_P@, string);
			            ShowPlayerDialogEx(playerid, 8002, DIALOG_STYLE_LIST, "Sejf - w��", "Got�wk�\nMateria�y\nMarihuane\nHeroine", "Wybierz", "Wr��");
			            ZapiszDom(PlayerInfo[playerid][pDom]);
						format(string, sizeof(string), "Gracz %s wlozyl %d dragow do sejfu", GetNick(playerid), strval(inputtext));
						PayLog(string);
					}
					else
					{
					    SendClientMessage(playerid, COLOR_P@, "Nie sta� ci� aby w�o�y� tyle do sejfu");
		            	ShowPlayerDialogEx(playerid, 8008, DIALOG_STYLE_INPUT, "Sejf - wk�adanie", "Wpisz jak� ilo�� heroiny chcesz w�o�y� do sejfu", "W��", "Wr��");
					}
				}
		        else
		        {
		            format(string, sizeof(string), "Pojemno�� sejfu to %d drag�w. Nie mo�esz w�o�y� do niego %d drag�w gdy� jest ju� w nim %d drag�w. Maksymalna ilo�� jak� mo�esz teraz do niego w�o�y� to %d drag�w", maxwloz, strval(inputtext), Dom[dom][hS_drugs], wkladanie);
		            SendClientMessage(playerid, COLOR_P@, string);
		            ShowPlayerDialogEx(playerid, 8008, DIALOG_STYLE_INPUT, "Sejf - wk�adanie", "Wpisz jak� ilo�� heroiny chcesz w�o�y� do sejfu", "W��", "Wr��");
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 8000, DIALOG_STYLE_LIST, "Sejf", "Zawarto�� sejfu\nW�� do sejfu\nWyjmij z sejfu\nUstal kod sejfu", "Wybierz", "Anuluj");
		    }
		}
		if(dialogid == 8009)
		{
		    if(response)
		    {
		        if(!strlen(inputtext))
		        {
	                ShowPlayerDialogEx(playerid, 8009, DIALOG_STYLE_INPUT, "Sejf - wyjmowanie", "Wpisz jak� ilo�� got�wki chcesz wyj�� z sejfu", "Wyjmij", "Wr��");
		            return 1;
				}
		        new dom = PlayerInfo[playerid][pDomWKJ];
		        new string[256];
		        if(strval(inputtext) >= 1 && strval(inputtext) <= Dom[dom][hS_kasa])
		        {
		            Dom[dom][hS_kasa] -= strval(inputtext);
					dini_IntSet(string, "S_kasa", Dom[dom][hS_kasa]);
		            DajKase(playerid, strval(inputtext));
		            format(string, sizeof(string), "Wyj��e� z sejfu %d$. Jest w nim teraz %d$.", strval(inputtext), Dom[dom][hS_kasa]);
		            SendClientMessage(playerid, COLOR_P@, string);
		            ShowPlayerDialogEx(playerid, 8003, DIALOG_STYLE_LIST, "Sejf - wyjmij", "Got�wk�\nMateria�y\nMarihuane\nHeroine", "Wybierz", "Wr��");
					format(string, sizeof(string), "Gracz %s wyjal %d$ z sejfu", GetNick(playerid), strval(inputtext));
					PayLog(string);
		        }
		        else
		        {
		            format(string, sizeof(string), "Masz w sejfie %d$. Nie mo�esz wyj�� z niego %d$.", Dom[dom][hS_kasa], strval(inputtext));
		            SendClientMessage(playerid, COLOR_P@, string);
		            ShowPlayerDialogEx(playerid, 8009, DIALOG_STYLE_INPUT, "Sejf - wyjmowanie", "Wpisz jak� ilo�� got�wki chcesz wyj�� z sejfu", "Wyjmij", "Wr��");
		            ZapiszDom(PlayerInfo[playerid][pDom]);
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 8000, DIALOG_STYLE_LIST, "Sejf", "Zawarto�� sejfu\nW�� do sejfu\nWyjmij z sejfu\nUstal kod sejfu", "Wybierz", "Anuluj");
		    }
		}
		if(dialogid == 8010)
		{
		    if(response)
		    {
		        if(!strlen(inputtext))
		        {
	                ShowPlayerDialogEx(playerid, 8010, DIALOG_STYLE_INPUT, "Sejf - wyjmowanie", "Wpisz jak� ilo�� materia��w chcesz wyj�� z sejfu", "Wyjmij", "Wr��");
		            return 1;
				}
		        new dom = PlayerInfo[playerid][pDomWKJ];
		        new string[256];
				new firstValue = Dom[dom][hS_mats];
		        if(strval(inputtext) >= 1 && strval(inputtext) <= Dom[dom][hS_mats])
		        {
		            Dom[dom][hS_mats] -= strval(inputtext);
					new newValue = Dom[dom][hS_mats];
					dini_IntSet(string, "S_mats", Dom[dom][hS_mats]);
		            PlayerInfo[playerid][pMats] += strval(inputtext);
		            format(string, sizeof(string), "Wyj��e� z sejfu %d materia��w. Jest w nim teraz %d materia��w.", strval(inputtext), Dom[dom][hS_mats]);
		            SendClientMessage(playerid, COLOR_P@, string);
		            ShowPlayerDialogEx(playerid, 8003, DIALOG_STYLE_LIST, "Sejf - wyjmij", "Got�wk�\nMateria�y\nMarihuane\nHeroine", "Wybierz", "Wr��");
		            ZapiszDom(PlayerInfo[playerid][pDom]);
					format(string, sizeof(string), "Gracz %s wyjal %d mats z sejfu, poprzedni stan %d, nowy stan: ", GetNick(playerid), strval(inputtext), firstValue, newValue);
					PayLog(string);
		        }
		        else
		        {
		            format(string, sizeof(string), "Masz w sejfie %d materia��w. Nie mo�esz wyj�� z niego %d materia��w.", Dom[dom][hS_mats], strval(inputtext));
		            SendClientMessage(playerid, COLOR_P@, string);
		            ShowPlayerDialogEx(playerid, 8010, DIALOG_STYLE_INPUT, "Sejf - wyjmowanie", "Wpisz jak� ilo�� materia��w chcesz wyj�� z sejfu", "Wyjmij", "Wr��");
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 8000, DIALOG_STYLE_LIST, "Sejf", "Zawarto�� sejfu\nW�� do sejfu\nWyjmij z sejfu\nUstal kod sejfu", "Wybierz", "Anuluj");
		    }
		}
		/*if(dialogid == 8011)
		{
		    if(response)
		    {
		        if(!strlen(inputtext))
		        {
	                ShowPlayerDialogEx(playerid, 8011, DIALOG_STYLE_INPUT, "Sejf - wyjmowanie", "Wpisz jak� ilo�� marihuany chcesz wyj�� z sejfu", "Wyjmij", "Wr��");
		            return 1;
				}
		        new dom = PlayerInfo[playerid][pDomWKJ];
		        new string[256];
		        if(strval(inputtext) >= 1 && strval(inputtext) <= Dom[dom][hS_ziolo])
		        {
		            Dom[dom][hS_ziolo] -= strval(inputtext);
		            PlayerInfo[playerid][pZiolo] += strval(inputtext);
		            format(string, sizeof(string), "Wyj��e� z sejfu %d zio�a. Jest w nim teraz %d zio�a.", strval(inputtext), Dom[dom][hS_ziolo]);
		            SendClientMessage(playerid, COLOR_P@, string);
		            ShowPlayerDialogEx(playerid, 8003, DIALOG_STYLE_LIST, "Sejf - wyjmij", "Got�wk�\nMateria�y\nMarihuane\nHeroine", "Wybierz", "Wr��");
		        }
		        else
		        {
		            format(string, sizeof(string), "Masz w sejfie %d zio�a. Nie mo�esz wyj�� z niego %d zio�a.", Dom[dom][hS_ziolo], strval(inputtext));
		            SendClientMessage(playerid, COLOR_P@, string);
		            ShowPlayerDialogEx(playerid, 8011, DIALOG_STYLE_INPUT, "Sejf - wyjmowanie", "Wpisz jak� ilo�� marihuany chcesz wyj�� z sejfu", "Wyjmij", "Wr��");
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 8000, DIALOG_STYLE_LIST, "Sejf", "Zawarto�� sejfu\nW�� do sejfu\nWyjmij z sejfu\nUstal kod sejfu", "Wybierz", "Anuluj");
		    }
		}*/
		if(dialogid == 8012)
		{
		    if(response)
		    {
		        if(!strlen(inputtext))
		        {
	                ShowPlayerDialogEx(playerid, 8012, DIALOG_STYLE_INPUT, "Sejf - wyjmowanie", "Wpisz jak� ilo�� heroiny chcesz wyj�� z sejfu", "Wyjmij", "Wr��");
		            return 1;
				}
		        new dom = PlayerInfo[playerid][pDomWKJ];
		        new string[256];
		        if(strval(inputtext) >= 1 && strval(inputtext) <= Dom[dom][hS_drugs])
		        {
		            Dom[dom][hS_drugs] -= strval(inputtext);
					dini_IntSet(string, "S_drugs", Dom[dom][hS_drugs]);
		            PlayerInfo[playerid][pDrugs] += strval(inputtext);
		            format(string, sizeof(string), "Wyj��e� z sejfu %d drag�w. Jest w nim teraz %d drag�w.", strval(inputtext), Dom[dom][hS_drugs]);
		            SendClientMessage(playerid, COLOR_P@, string);
		            ShowPlayerDialogEx(playerid, 8003, DIALOG_STYLE_LIST, "Sejf - wyjmij", "Got�wk�\nMateria�y\nMarihuane\nHeroine", "Wybierz", "Wr��");
		            ZapiszDom(PlayerInfo[playerid][pDom]);
					format(string, sizeof(string), "Gracz %s wyjal %d dragow z sejfu", GetNick(playerid), strval(inputtext));
					PayLog(string);
		        }
		        else
		        {
		            format(string, sizeof(string), "Masz w sejfie %d heroiny. Nie mo�esz wyj�� z niego %d heroiny.", Dom[dom][hS_drugs], strval(inputtext));
		            SendClientMessage(playerid, COLOR_P@, string);
		            ShowPlayerDialogEx(playerid, 8012, DIALOG_STYLE_INPUT, "Sejf - wyjmowanie", "Wpisz jak� ilo�� heroiny chcesz wyj�� z sejfu", "Wyjmij", "Wr��");
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 8000, DIALOG_STYLE_LIST, "Sejf", "Zawarto�� sejfu\nW�� do sejfu\nWyjmij z sejfu\nUstal kod sejfu", "Wybierz", "Anuluj");
		    }
		}
		if(dialogid == 8015)
		{
		    if(response)
		    {
		        if(!strlen(inputtext))
		        {
	         		ShowPlayerDialogEx(playerid, 8015, DIALOG_STYLE_INPUT, "Sejf - wpisz kod", "Ten sejf jest zabezpieczony kodem. Aby si� do niego dosta� wpisz poprawny kod w okienko poni�ej", "Zatwierd�", "Wyjd�");
					return 1;
				}
				
				if(GetPVarInt(playerid, "kodVw") != GetPlayerVirtualWorld(playerid)) return 1;
				new kod[20];
				format(kod, sizeof(kod), "%s", Dom[PlayerInfo[playerid][pDomWKJ]][hKodSejf]);
				if(strcmp(kod, inputtext, true ) == 0)
				{
	                SendClientMessage(playerid, COLOR_GREEN, "KOD POPRAWNY!");
	                ShowPlayerDialogEx(playerid, 8000, DIALOG_STYLE_LIST, "Sejf", "Zawarto�� sejfu\nW�� do sejfu\nWyjmij z sejfu", "Wybierz", "Anuluj");
				}
				else
				{
				    SendClientMessage(playerid, COLOR_PANICRED, "Z�Y KOD!");
				    AntyWlamSejf[playerid] ++;
				    if(AntyWlamSejf[playerid] < 5)
				    {
				    	ShowPlayerDialogEx(playerid, 8015, DIALOG_STYLE_INPUT, "Sejf - wpisz kod", "Ten sejf jest zabezpieczony kodem. Aby si� do niego dosta� wpisz poprawny kod w okienko poni�ej", "Zatwierd�", "Wyjd�");
					}
					else
					{
					    SetTimerEx("ZlyKodUn",300000,0,"d",playerid);
					    SendClientMessage(playerid, COLOR_PANICRED, "Zbyt du�o nieudanych pr�b, spr�buj jeszcze raz za 5 minut!");
					    return 1;
					}
				}
			}
		}
		if(dialogid == 8800)
		{
		    if(response)
		    {
		        new dom = PlayerInfo[playerid][pDom];
		        switch(listitem)
		        {
		            case 0:
		            {
		                if(Dom[dom][hUL_Z] == 1)
		                {
		                    SendClientMessage(playerid, COLOR_P@, "Teraz tylko ty b�dziesz m�g� otwiera� i zamyka� dom");
		                    Dom[dom][hUL_Z] = 0;
		                }
		                else
		                {
		                    SendClientMessage(playerid, COLOR_P@, "Teraz wszyscy lokatorzy b�d� mogli otwiera� i zamyka� dom");
		                    Dom[dom][hUL_Z] = 1;
		                }
		                new string[256];
		                new taknie_z[10];
		                new taknie_d[10];
		                if(Dom[dom][hUL_Z] == 1)
		                {
		                    taknie_z = "tak";
		                }
		                else
		                {
		                    taknie_z = "nie";
		                }
		                if(Dom[dom][hUL_D] == 1)
		                {
		                    taknie_d = "tak";
		                }
		                else
		                {
		                    taknie_d = "nie";
		                }
		                format(string, sizeof(string), "Zamykanie i otwieranie drzwi:\t %s\nKorzystanie z dodatk�w:\t %s", taknie_z, taknie_d);
	                    ShowPlayerDialogEx(playerid, 8800, DIALOG_STYLE_LIST, "Uprawnienia lokator�w", string, "Zmie�", "Wr��");
		            }
		            case 1:
		            {
		                if(Dom[dom][hUL_D] == 1)
		                {
		                    SendClientMessage(playerid, COLOR_P@, "Teraz tylko ty b�dziesz m�g� korzysta� z dodatk�w");
		                    Dom[dom][hUL_D] = 0;
		                }
		                else
		                {
		                    SendClientMessage(playerid, COLOR_P@, "Teraz wszyscy lokatorzy b�d� mogli korzysta� z dodatk�w");
		                    Dom[dom][hUL_D] = 1;
		                }
		                new string[256];
		                new taknie_z[10];
		                new taknie_d[10];
		                if(Dom[dom][hUL_Z] == 1)
		                {
		                    taknie_z = "tak";
		                }
		                else
		                {
		                    taknie_z = "nie";
		                }
		                if(Dom[dom][hUL_D] == 1)
		                {
		                    taknie_d = "tak";
		                }
		                else
		                {
		                    taknie_d = "nie";
		                }
		                format(string, sizeof(string), "Zamykanie i otwieranie drzwi:\t %s\nKorzystanie z dodatk�w:\t %s", taknie_z, taknie_d);
	                    ShowPlayerDialogEx(playerid, 8800, DIALOG_STYLE_LIST, "Uprawnienia lokator�w", string, "Zmie�", "Wr��");
		            }
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 815, DIALOG_STYLE_LIST, "Panel wynajmu", "Informacje og�lne\nZarz�dzaj lokatorami\nTryb wynajmu\nCena wynajmu\nInfomacja dla lokator�w\nUprawnienia lokator�w", "Wybierz", "Wyjd�");
		    }
		}
		if(dialogid == 8810)
		{
		    if(response)
		    {
		        new dom = PlayerInfo[playerid][pWynajem];
		        switch(listitem)
		        {
		            case 0://Informacje o domu
		            {
		                new string2[512];
						new wynajem[20];
						if(Dom[dom][hWynajem] == 0)
						{
	                        wynajem = "nie";
						}
						else
						{
	                        wynajem = "tak";
						}
						new drzwi[30];
						if(Dom[dom][hZamek] == 0)
						{
	                        drzwi = "Zamkni�te";
						}
						else
						{
	                        drzwi = "Otwarte";
						}
		                format(string2, sizeof(string2), "ID domu:\t%d\nID wn�trza:\t%d\nCena domu:\t%d$\nWynajem:\t%s\nIlosc pokoi:\t%d\nPokoi wynajmowanych\t%d\nCena wynajmu:\t%d$\nO�wietlenie:\t%d\nDrzwi:\t%s", dom, Dom[dom][hDomNr], Dom[dom][hCena], wynajem, Dom[dom][hPokoje], Dom[dom][hPW], Dom[dom][hCenaWynajmu], Dom[dom][hSwiatlo], drzwi);
		                ShowPlayerDialogEx(playerid, 8811, DIALOG_STYLE_MSGBOX, "G��wne informacje domu", string2, "Wr��", "Wyjd�");
		            }
		            case 1://Zamknij/Otw�rz
		            {
		                if(Dom[dom][hUL_Z] == 1)
		                {
			                if(Dom[dom][hZamek] == 1)
			                {
								Dom[dom][hZamek] = 0;
								ShowPlayerDialogEx(playerid, 8811, DIALOG_STYLE_MSGBOX, "Zamykanie domu", "Dom zosta� zamkni�ty pomy�lnie", "Wr��", "Wyjd�");
							}
							else if(Dom[dom][hZamek] == 0)
							{
							    Dom[dom][hZamek] = 1;
			                	ShowPlayerDialogEx(playerid, 8811, DIALOG_STYLE_MSGBOX, "Otwieranie domu", "Dom zosta� otworzony pomy�lnie", "Wr��", "Wyjd�");
							}
						}
						else
						{
						    SendClientMessage(playerid, COLOR_P@, "W�a�cicel domu ustali�, �e nie mo�esz zamyka� ani otwiera� domu.");
		                	if(Dom[PlayerInfo[playerid][pWynajem]][hZamek] == 0)
					    	{
								ShowPlayerDialogEx(playerid, 8810, DIALOG_STYLE_LIST, "Panel Lokatora", "Informacje o domu\nZamknij\nSpawn\nPomoc", "Wybierz", "Anuluj");
							}
							else if(Dom[PlayerInfo[playerid][pWynajem]][hZamek] == 1)
							{
				   				ShowPlayerDialogEx(playerid, 8810, DIALOG_STYLE_LIST, "Panel Lokatora", "Informacje o domu\nZamknij\nSpawn\nPomoc", "Wybierz", "Anuluj");
							}
						}
		            }
		            case 2://Spawn
		            {
		                ShowPlayerDialogEx(playerid, 8812, DIALOG_STYLE_LIST, "Wybierz typ spawnu", "Normalny spawn\nSpawn przed domem\nSpawn w domu", "Wybierz", "Wr��");
		            }
		            case 3://Pomoc
		            {
		                SendClientMessage(playerid, COLOR_P@, "Ju� wkr�tce");
		                if(Dom[PlayerInfo[playerid][pWynajem]][hZamek] == 0)
				    	{
							ShowPlayerDialogEx(playerid, 8810, DIALOG_STYLE_LIST, "Panel Lokatora", "Informacje o domu\nZamknij\nSpawn\nPomoc", "Wybierz", "Anuluj");
						}
						else if(Dom[PlayerInfo[playerid][pWynajem]][hZamek] == 1)
						{
			   				ShowPlayerDialogEx(playerid, 8810, DIALOG_STYLE_LIST, "Panel Lokatora", "Informacje o domu\nZamknij\nSpawn\nPomoc", "Wybierz", "Anuluj");
						}
		            }
		        }
		    }
		}
		if(dialogid == 8811)
		{
		    if(response)
		    {
		        if(Dom[PlayerInfo[playerid][pWynajem]][hZamek] == 0)
		    	{
					ShowPlayerDialogEx(playerid, 8810, DIALOG_STYLE_LIST, "Panel Lokatora", "Informacje o domu\nZamknij\nSpawn\nPomoc", "Wybierz", "Anuluj");
				}
				else if(Dom[PlayerInfo[playerid][pWynajem]][hZamek] == 1)
				{
	   				ShowPlayerDialogEx(playerid, 8810, DIALOG_STYLE_LIST, "Panel Lokatora", "Informacje o domu\nZamknij\nSpawn\nPomoc", "Wybierz", "Anuluj");
				}
		    }
		}
		if(dialogid == 8812)
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0:// Normalny spawn
		            {
		                PlayerInfo[playerid][pSpawn] = 0;
		                SendClientMessage(playerid, COLOR_NEWS, "B�dziesz si� teraz spawnowa� na swoim normalnym spawnie");
		                if(Dom[PlayerInfo[playerid][pWynajem]][hZamek] == 0)
				    	{
							ShowPlayerDialogEx(playerid, 8810, DIALOG_STYLE_LIST, "Panel Lokatora", "Informacje o domu\nZamknij\nSpawn\nPomoc", "Wybierz", "Anuluj");
						}
						else if(Dom[PlayerInfo[playerid][pWynajem]][hZamek] == 1)
						{
			   				ShowPlayerDialogEx(playerid, 8810, DIALOG_STYLE_LIST, "Panel Lokatora", "Informacje o domu\nZamknij\nSpawn\nPomoc", "Wybierz", "Anuluj");
						}
		            }
		            case 1:// Spawn przed domem
		            {
		                PlayerInfo[playerid][pSpawn] = 1;
		                SendClientMessage(playerid, COLOR_NEWS, "B�dziesz si� teraz spawnowa� przed domem");
		                if(Dom[PlayerInfo[playerid][pWynajem]][hZamek] == 0)
				    	{
							ShowPlayerDialogEx(playerid, 8810, DIALOG_STYLE_LIST, "Panel Lokatora", "Informacje o domu\nZamknij\nSpawn\nPomoc", "Wybierz", "Anuluj");
						}
						else if(Dom[PlayerInfo[playerid][pWynajem]][hZamek] == 1)
						{
			   				ShowPlayerDialogEx(playerid, 8810, DIALOG_STYLE_LIST, "Panel Lokatora", "Informacje o domu\nZamknij\nSpawn\nPomoc", "Wybierz", "Anuluj");
						}
					}
		            case 2:// Spawn w domu
		            {
	                    PlayerInfo[playerid][pSpawn] = 2;
	                    SendClientMessage(playerid, COLOR_NEWS, "B�dziesz si� teraz spawnowa� wewn�trz domu");
	                    if(Dom[PlayerInfo[playerid][pWynajem]][hZamek] == 0)
				    	{
							ShowPlayerDialogEx(playerid, 8810, DIALOG_STYLE_LIST, "Panel Lokatora", "Informacje o domu\nZamknij\nSpawn\nPomoc", "Wybierz", "Anuluj");
						}
						else if(Dom[PlayerInfo[playerid][pWynajem]][hZamek] == 1)
						{
			   				ShowPlayerDialogEx(playerid, 8810, DIALOG_STYLE_LIST, "Panel Lokatora", "Informacje o domu\nZamknij\nSpawn\nPomoc", "Wybierz", "Anuluj");
						}
					}
				}
			}
		}
		if(dialogid >= 8220 && dialogid <= 8231)
		{
		    if(response)
		    {
		        new dom = PlayerInfo[playerid][pDom];
		        if(dialogid == 8220)
		        {
		            if(Dom[dom][hS_PG0] == 0)
		            {
		                if(kaska[playerid] >= 1 && kaska[playerid] >= 1000)
		                {
			                SendClientMessage(playerid, COLOR_NEWS, "Gratulacje, przystosowa�e� swoj� zbrojownie do przechowywania kastetu za 1 000$!");
							DajKase(playerid, -1000);
							Dom[dom][hS_PG0] = 1;
							DialogZbrojowni(playerid);
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Nie sta� ci�!");
		                	DialogZbrojowni(playerid);
						}
		            }
		            else
		            {
		                SendClientMessage(playerid, COLOR_GRAD3, "Przystosowa�e� ju� swoj� zbrojownie do przechowywania kastetu!");
		                DialogZbrojowni(playerid);
		            }
		        }
		        if(dialogid == 8221)
		        {
		            if(Dom[dom][hS_PG11] == 0)
		            {
	                    if(kaska[playerid] >= 1 && kaska[playerid] >= 5000)
		                {
			                SendClientMessage(playerid, COLOR_NEWS, "Gratulacje, przystosowa�e� swoj� zbrojownie do przechowywania spadochronu za 5 000$!");
							DajKase(playerid, -5000);
							Dom[dom][hS_PG11] = 1;
							DialogZbrojowni(playerid);
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Nie sta� ci�!");
		                	DialogZbrojowni(playerid);
						}
		            }
		            else
		            {
		                SendClientMessage(playerid, COLOR_GRAD3, "Przystosowa�e� ju� swoj� zbrojownie do przechowywania spadochronu!");
		                DialogZbrojowni(playerid);
		            }
		        }
		        if(dialogid == 8222)
		        {
		            if(Dom[dom][hS_PG9] == 0)
		            {
		                if(kaska[playerid] >= 1 && kaska[playerid] >= 50000)
		                {
			                SendClientMessage(playerid, COLOR_NEWS, "Gratulacje, przystosowa�e� swoj� zbrojownie do przechowywania sperju, ga�nicy i kamery za 50 000$!");
							DajKase(playerid, -50000);
							Dom[dom][hS_PG9] = 1;
							DialogZbrojowni(playerid);
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Nie sta� ci�!");
		                	DialogZbrojowni(playerid);
						}
		            }
		            else
		            {
		                SendClientMessage(playerid, COLOR_GRAD3, "Przystosowa�e� ju� swoj� zbrojownie do przechowywania sperju, ga�nicy i kamery!");
		                DialogZbrojowni(playerid);
		            }
		        }
		        if(dialogid == 8223)
		        {
		            if(Dom[dom][hS_PG10] == 0)
		            {
		                if(kaska[playerid] >= 1 && kaska[playerid] >= 60000)
		                {
			                SendClientMessage(playerid, COLOR_NEWS, "Gratulacje, przystosowa�e� swoj� zbrojownie do przechowywania wibrator�w, laski i kwiat�w za 60 000$!");
							DajKase(playerid, -60000);
							Dom[dom][hS_PG10] = 1;
							DialogZbrojowni(playerid);
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Nie sta� ci�!");
		                	DialogZbrojowni(playerid);
						}
		            }
		            else
		            {
		                SendClientMessage(playerid, COLOR_GRAD3, "Przystosowa�e� ju� swoj� zbrojownie do przechowywania wibrator�w, laski i kwiat�w!");
		                DialogZbrojowni(playerid);
		            }
		        }
		        if(dialogid == 8224)
		        {
		            if(Dom[dom][hS_PG1] == 0)
		            {
		                if(kaska[playerid] >= 1 && kaska[playerid] >= 75000)
		                {
			                SendClientMessage(playerid, COLOR_NEWS, "Gratulacje, przystosowa�e� swoj� zbrojownie do przechowywania broni bia�ej za 75 000$!");
							DajKase(playerid, -75000);
							Dom[dom][hS_PG1] = 1;
							DialogZbrojowni(playerid);
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Nie sta� ci�!");
		                	DialogZbrojowni(playerid);
						}
		            }
		            else
		            {
		                SendClientMessage(playerid, COLOR_GRAD3, "Przystosowa�e� ju� swoj� zbrojownie do przechowywania broni bia�ej!");
		                DialogZbrojowni(playerid);
		            }
		        }
		        if(dialogid == 8225)
		        {
		            if(Dom[dom][hS_PG2] == 0)
		            {
		                if(kaska[playerid] >= 1 && kaska[playerid] >= 250000)
		                {
			                SendClientMessage(playerid, COLOR_NEWS, "Gratulacje, przystosowa�e� swoj� zbrojownie do przechowywania pistolet�w za 250 000$!");
							DajKase(playerid, -250000);
							Dom[dom][hS_PG2] = 1;
							DialogZbrojowni(playerid);
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Nie sta� ci�!");
		                	DialogZbrojowni(playerid);
						}
		            }
		            else
		            {
		                SendClientMessage(playerid, COLOR_GRAD3, "Przystosowa�e� ju� swoj� zbrojownie do przechowywania pistolet�w!");
		                DialogZbrojowni(playerid);
		            }
		        }
		        if(dialogid == 8226)
		        {
		            if(Dom[dom][hS_PG3] == 0)
		            {
		                if(kaska[playerid] >= 1 && kaska[playerid] >= 450000)
		                {
			                SendClientMessage(playerid, COLOR_NEWS, "Gratulacje, przystosowa�e� swoj� zbrojownie do przechowywania strzelb za 450 000$!");
							DajKase(playerid, -450000);
							Dom[dom][hS_PG3] = 1;
							DialogZbrojowni(playerid);
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Nie sta� ci�!");
		                	DialogZbrojowni(playerid);
						}
		            }
		            else
		            {
		                SendClientMessage(playerid, COLOR_GRAD3, "Przystosowa�e� ju� swoj� zbrojownie do przechowywania strzelb!");
		                DialogZbrojowni(playerid);
		            }
		        }
		        if(dialogid == 8227)
		        {
		            if(Dom[dom][hS_PG4] == 0)
		            {
		                if(kaska[playerid] >= 1 && kaska[playerid] >= 550000)
		                {
			                SendClientMessage(playerid, COLOR_NEWS, "Gratulacje, przystosowa�e� swoj� zbrojownie do przechowywania pistolet�w maszynowych za 550 000$!");
							DajKase(playerid, -550000);
							Dom[dom][hS_PG4] = 1;
							DialogZbrojowni(playerid);
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Nie sta� ci�!");
		                	DialogZbrojowni(playerid);
						}
		            }
		            else
		            {
		                SendClientMessage(playerid, COLOR_GRAD3, "Przystosowa�e� ju� swoj� zbrojownie do przechowywania pistolet�w maszynowych!");
		                DialogZbrojowni(playerid);
		            }
		        }
		        if(dialogid == 8228)
		        {
		            if(Dom[dom][hS_PG5] == 0)
		            {
	                    if(kaska[playerid] >= 1 && kaska[playerid] >= 850000)
		                {
			                SendClientMessage(playerid, COLOR_NEWS, "Gratulacje, przystosowa�e� swoj� zbrojownie do przechowywania karabin�w szturmowych za 850 000$!");
							DajKase(playerid, -850000);
							Dom[dom][hS_PG5] = 1;
							DialogZbrojowni(playerid);
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Nie sta� ci�!");
		                	DialogZbrojowni(playerid);
						}
		            }
		            else
		            {
		                SendClientMessage(playerid, COLOR_GRAD3, "Przystosowa�e� ju� swoj� zbrojownie do przechowywania karabin�w szturmowych!");
		                DialogZbrojowni(playerid);
		            }
		        }
		        if(dialogid == 8229)
		        {
		            if(Dom[dom][hS_PG6] == 0)
		            {
		                if(kaska[playerid] >= 1 && kaska[playerid] >= 700000)
		                {
			                SendClientMessage(playerid, COLOR_NEWS, "Gratulacje, przystosowa�e� swoj� zbrojownie do przechowywania snajperek za 700 000$!");
							DajKase(playerid, -700000);
							Dom[dom][hS_PG6] = 1;
							DialogZbrojowni(playerid);
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Nie sta� ci�!");
		                	DialogZbrojowni(playerid);
						}
		            }
		            else
		            {
		                SendClientMessage(playerid, COLOR_GRAD3, "Przystosowa�e� ju� swoj� zbrojownie do przechowywania snajperek!");
		                DialogZbrojowni(playerid);
		            }
		        }
		        if(dialogid == 8230)
		        {
		            if(Dom[dom][hS_PG7] == 0)
		            {
		                if(kaska[playerid] >= 1 && kaska[playerid] >= 2000000)
		                {
			                SendClientMessage(playerid, COLOR_NEWS, "Gratulacje, przystosowa�e� swoj� zbrojownie do przechowywania broni ci�zkiej za 2 000 000$!");
							DajKase(playerid, -2000000);
							Dom[dom][hS_PG7] = 1;
							DialogZbrojowni(playerid);
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Nie sta� ci�!");
		                	DialogZbrojowni(playerid);
						}
		            }
		            else
		            {
		                SendClientMessage(playerid, COLOR_GRAD3, "Przystosowa�e� ju� swoj� zbrojownie do przechowywania broni ci�zkiej!");
		                DialogZbrojowni(playerid);
		            }
		        }
		        if(dialogid == 8231)
		        {
		            if(Dom[dom][hS_PG8] == 0)
		            {
		                if(kaska[playerid] >= 1 && kaska[playerid] >= 4000000)
		                {
			                SendClientMessage(playerid, COLOR_NEWS, "Gratulacje, przystosowa�e� swoj� zbrojownie do przechowywania �adunk�w wybuchowych za 4 000 000$!");
							DajKase(playerid, -4000000);
							Dom[dom][hS_PG8] = 1;
							DialogZbrojowni(playerid);
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Nie sta� ci�!");
		                	DialogZbrojowni(playerid);
						}
		            }
		            else
		            {
		                SendClientMessage(playerid, COLOR_GRAD3, "Przystosowa�e� ju� swoj� zbrojownie do przechowywania �adunk�w wybuchowych!");
		                DialogZbrojowni(playerid);
		            }
		        }
		    }
		    if(!response)
		    {
		        DialogZbrojowni(playerid);
		    }
		}
		if(dialogid == 8240)//zbrojownia
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0://Wyjmij bro�
		            {
		                WyjmijBron(playerid);
		            }
		            case 1://Schowaj bro�
		            {
		                SchowajBron(playerid);
		            }
		            case 2://Zawarto�� zbrojowni
		            {
		                ListaBroni(playerid);
		            }
		        }
		    }
		}
		if(dialogid == 8241)//wyjmowanie broni
		{
		    if(response)
		    {
		     	new BronieF[13][2];
				for(new i = 0; i < 13; i++) { GetPlayerWeaponData(playerid, i, BronieF[i][0], BronieF[i][1]); }
		        switch(listitem)
		        {
		            case 0:
		            {
		                new dom = PlayerInfo[playerid][pDom];
						if(BronieF[0][0] != 0)
						{
						    IDBroniZbrojownia[playerid] = 0;
						    ShowPlayerDialogEx(playerid, 8244, DIALOG_STYLE_MSGBOX, "Wyjmowanie broni", "Posiadasz ju� bro� typu kastet, czy chcesz j� zamieni� na kastet ze zbrojowni?", "Zamie�", "Wr��");
						}
						else
						{
							Dom[dom][hS_G0] = 0;
							PlayerInfo[playerid][pGun0] = Dom[dom][hS_G0];
							PlayerInfo[playerid][pAmmo0] = 1;
							GivePlayerWeapon(playerid, 1, 1);
						    SendClientMessage(playerid, COLOR_NEWS, "Wyj��e� kastet ze zbrojowni.");
	                        WyjmijBron(playerid);
						}
		            }
		            case 1:
		            {
		                new brondef[256];
		                new dom = PlayerInfo[playerid][pDom];
		                if(BronieF[1][0] != 0)
						{
						    IDBroniZbrojownia[playerid] = 1;
						    format(brondef, sizeof(brondef), "Posiadasz ju� bro� bia�� (%s), chcesz j� zamieni� na %s?", GunNames[BronieF[1][0]], GunNames[Dom[dom][hS_G1]]);
						    ShowPlayerDialogEx(playerid, 8244, DIALOG_STYLE_MSGBOX, "Wyjmowanie broni", brondef, "Zamie�", "Wr��");
						}
						else
						{
							Dom[dom][hS_G1] = 0;
							Dom[dom][hS_A1] = 0;
							PlayerInfo[playerid][pGun1] = Dom[dom][hS_G1];
							PlayerInfo[playerid][pAmmo1] = 1;
							GivePlayerWeapon(playerid, Dom[dom][hS_G1], 1);
							format(brondef, sizeof(brondef), "Wyj��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G1]]);
						    SendClientMessage(playerid, COLOR_NEWS, brondef);
	                        WyjmijBron(playerid);
						}
		            }
		            case 2:
		            {
		                new brondef[256];
		                new dom = PlayerInfo[playerid][pDom];
		                if(BronieF[2][0] != 0)
						{
						    if(PlayerInfo[playerid][pGun2] == Dom[dom][hS_G2])
		                    {
	                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G2]], Dom[dom][hS_A2]);
		                		ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
		                    }
		                    else
		                    {
							    IDBroniZbrojownia[playerid] = 2;
							    format(brondef, sizeof(brondef), "Posiadasz ju� pistolet (%s), chcesz go zamieni� na %s?\n(W przypadku gdy bro� jest taka sama, do obecnej broni b�dziesz m�g� doda� amunicje)", GunNames[BronieF[2][0]], GunNames[Dom[dom][hS_G2]]);
							    ShowPlayerDialogEx(playerid, 8244, DIALOG_STYLE_MSGBOX, "Wyjmowanie broni", brondef, "Zamie�", "Wr��");
							}
						}
						else
						{
							Dom[dom][hS_G2] = 0;
							Dom[dom][hS_A2] = 0;
							PlayerInfo[playerid][pGun2] = Dom[dom][hS_G2];
							PlayerInfo[playerid][pAmmo2] = Dom[dom][hS_A2];
							GivePlayerWeapon(playerid, Dom[dom][hS_G2], Dom[dom][hS_A2]);
							format(brondef, sizeof(brondef), "Wyj��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G2]]);
						    SendClientMessage(playerid, COLOR_NEWS, brondef);
	                        WyjmijBron(playerid);
						}
		            }
		            case 3:
		            {
		                new brondef[256];
		                new dom = PlayerInfo[playerid][pDom];
		                if(BronieF[3][0] != 0)
						{
						    if(PlayerInfo[playerid][pGun3] == Dom[dom][hS_G3])
		                    {
	                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G3]], Dom[dom][hS_A3]);
		                		ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
		                    }
		                    else
		                    {
							    IDBroniZbrojownia[playerid] = 3;
							    format(brondef, sizeof(brondef), "Posiadasz ju� strzelb� (%s), chcesz go zamieni� na %s?\n(W przypadku gdy bro� jest taka sama, do obecnej broni b�dziesz m�g� doda� amunicje)", GunNames[BronieF[3][0]], GunNames[Dom[dom][hS_G3]]);
							    ShowPlayerDialogEx(playerid, 8244, DIALOG_STYLE_MSGBOX, "Wyjmowanie broni", brondef, "Zamie�", "Wr��");
							}
						}
						else
						{
							Dom[dom][hS_G3] = 0;
							Dom[dom][hS_A3] = 0;
	                        PlayerInfo[playerid][pGun3] = Dom[dom][hS_G3];
							PlayerInfo[playerid][pAmmo3] = Dom[dom][hS_A3];
							GivePlayerWeapon(playerid, Dom[dom][hS_G3], Dom[dom][hS_A3]);
							format(brondef, sizeof(brondef), "Wyj��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G3]]);
						    SendClientMessage(playerid, COLOR_NEWS, brondef);
	                        WyjmijBron(playerid);
						}
		            }
		            case 4:
		            {
		                new brondef[256];
		                new dom = PlayerInfo[playerid][pDom];
		                if(BronieF[4][0] != 0)
						{
						    if(PlayerInfo[playerid][pGun4] == Dom[dom][hS_G4])
		                    {
	                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G4]], Dom[dom][hS_A4]);
		                		ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
		                    }
		                    else
		                    {
							    IDBroniZbrojownia[playerid] = 4;
							    format(brondef, sizeof(brondef), "Posiadasz ju� pistolet maszynowy (%s), chcesz go zamieni� na %s?\n(W przypadku gdy bro� jest taka sama, do obecnej broni b�dziesz m�g� doda� amunicje)", GunNames[BronieF[4][0]], GunNames[Dom[dom][hS_G4]]);
							    ShowPlayerDialogEx(playerid, 8244, DIALOG_STYLE_MSGBOX, "Wyjmowanie broni", brondef, "Zamie�", "Wr��");
							}
						}
						else
						{
							Dom[dom][hS_G4] = 0;
							Dom[dom][hS_A4] = 0;
							PlayerInfo[playerid][pGun4] = Dom[dom][hS_G4];
							PlayerInfo[playerid][pAmmo4] = Dom[dom][hS_A4];
							GivePlayerWeapon(playerid, Dom[dom][hS_G4], Dom[dom][hS_A4]);
							format(brondef, sizeof(brondef), "Wyj��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G4]]);
						    SendClientMessage(playerid, COLOR_NEWS, brondef);
	                        WyjmijBron(playerid);
						}
		            }
		            case 5:
		            {
		                new brondef[256];
		                new dom = PlayerInfo[playerid][pDom];
		                if(BronieF[5][0] != 0)
						{
						    if(PlayerInfo[playerid][pGun5] == Dom[dom][hS_G5])
		                    {
	                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G5]], Dom[dom][hS_A5]);
		                		ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
		                    }
		                    else
		                    {
							    IDBroniZbrojownia[playerid] = 5;
							    format(brondef, sizeof(brondef), "Posiadasz ju� karabin szturmowy (%s), chcesz go zamieni� na %s?\n(W przypadku gdy bro� jest taka sama, do obecnej broni b�dziesz m�g� doda� amunicje)", GunNames[BronieF[5][0]], GunNames[Dom[dom][hS_G5]]);
							    ShowPlayerDialogEx(playerid, 8244, DIALOG_STYLE_MSGBOX, "Wyjmowanie broni", brondef, "Zamie�", "Wr��");
							}
						}
						else
						{
							Dom[dom][hS_G5] = 0;
							Dom[dom][hS_A5] = 0;
							PlayerInfo[playerid][pGun5] = Dom[dom][hS_G5];
							PlayerInfo[playerid][pAmmo5] = Dom[dom][hS_A5];
							GivePlayerWeapon(playerid, Dom[dom][hS_G5], Dom[dom][hS_A5]);
							format(brondef, sizeof(brondef), "Wyj��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G5]]);
						    SendClientMessage(playerid, COLOR_NEWS, brondef);
	                        WyjmijBron(playerid);
						}
		            }
		            case 6:
		            {
		                new brondef[256];
		                new dom = PlayerInfo[playerid][pDom];
		                if(BronieF[6][0] != 0)
						{
						    if(PlayerInfo[playerid][pGun6] == Dom[dom][hS_G6])
		                    {
	                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G6]], Dom[dom][hS_A6]);
		                		ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
		                    }
		                    else
		                    {
							    IDBroniZbrojownia[playerid] = 6;
							    format(brondef, sizeof(brondef), "Posiadasz ju� snajperk� (%s), chcesz j� zamieni� na %s?\n(W przypadku gdy bro� jest taka sama, do obecnej broni b�dziesz m�g� doda� amunicje)", GunNames[BronieF[6][0]], GunNames[Dom[dom][hS_G6]]);
							    ShowPlayerDialogEx(playerid, 8244, DIALOG_STYLE_MSGBOX, "Wyjmowanie broni", brondef, "Zamie�", "Wr��");
							}
						}
						else
						{
							Dom[dom][hS_G6] = 0;
							Dom[dom][hS_A6] = 0;
							PlayerInfo[playerid][pGun6] = Dom[dom][hS_G6];
							PlayerInfo[playerid][pAmmo6] = Dom[dom][hS_A6];
							GivePlayerWeapon(playerid, Dom[dom][hS_G6], Dom[dom][hS_A6]);
							format(brondef, sizeof(brondef), "Wyj��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G6]]);
						    SendClientMessage(playerid, COLOR_NEWS, brondef);
	                        WyjmijBron(playerid);
						}
		            }
		            case 7:
		            {
		                new brondef[256];
		                new dom = PlayerInfo[playerid][pDom];
		                if(BronieF[7][0] != 0)
						{
						    if(PlayerInfo[playerid][pGun7] == Dom[dom][hS_G7])
		                    {
	                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G7]], Dom[dom][hS_A7]);
		                		ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
		                    }
		                    else
		                    {
							    IDBroniZbrojownia[playerid] = 7;
							    format(brondef, sizeof(brondef), "Posiadasz ju� bro� ci�k� (%s), chcesz j� zamieni� na %s?\n(W przypadku gdy bro� jest taka sama, do obecnej broni b�dziesz m�g� doda� amunicje)", GunNames[BronieF[7][0]], GunNames[Dom[dom][hS_G7]]);
							    ShowPlayerDialogEx(playerid, 8244, DIALOG_STYLE_MSGBOX, "Wyjmowanie broni", brondef, "Zamie�", "Wr��");
							}
						}
						else
						{
							Dom[dom][hS_G7] = 0;
							Dom[dom][hS_A7] = 0;
							PlayerInfo[playerid][pGun7] = Dom[dom][hS_G7];
							PlayerInfo[playerid][pAmmo7] = Dom[dom][hS_A7];
							GivePlayerWeapon(playerid, Dom[dom][hS_G7], Dom[dom][hS_A7]);
							format(brondef, sizeof(brondef), "Wyj��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G7]]);
						    SendClientMessage(playerid, COLOR_NEWS, brondef);
	                        WyjmijBron(playerid);
						}
		            }
		            case 8:
		            {
		                new brondef[256];
		                new dom = PlayerInfo[playerid][pDom];
		                if(BronieF[8][0] != 0)
						{
						    if(PlayerInfo[playerid][pGun8] == Dom[dom][hS_G8])
		                    {
	                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G8]], Dom[dom][hS_A8]);
		                		ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
		                    }
		                    else
		                    {
							    IDBroniZbrojownia[playerid] = 8;
							    format(brondef, sizeof(brondef), "Posiadasz ju� �adnuek wybuchowy (%s), chcesz go zamieni� na %s?\n(W przypadku gdy bro� jest taka sama, do obecnej broni b�dziesz m�g� doda� amunicje)", GunNames[BronieF[8][0]], GunNames[Dom[dom][hS_G8]]);
							    ShowPlayerDialogEx(playerid, 8244, DIALOG_STYLE_MSGBOX, "Wyjmowanie broni", brondef, "Zamie�", "Wr��");
							}
						}
						else
						{
							Dom[dom][hS_G8] = 0;
							Dom[dom][hS_A8] = 0;
							PlayerInfo[playerid][pGun8] = Dom[dom][hS_G8];
							PlayerInfo[playerid][pAmmo8] = Dom[dom][hS_A8];
							GivePlayerWeapon(playerid, Dom[dom][hS_G8], Dom[dom][hS_A8]);
							format(brondef, sizeof(brondef), "Wyj��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G8]]);
						    SendClientMessage(playerid, COLOR_NEWS, brondef);
	                        WyjmijBron(playerid);
						}
		            }
		            case 9:
		            {
		                new brondef[256];
		                new dom = PlayerInfo[playerid][pDom];
		                if(BronieF[9][0] != 0)
						{
						    if(PlayerInfo[playerid][pGun9] == Dom[dom][hS_G9])
		                    {
	                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G9]], Dom[dom][hS_A9]);
		                		ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
		                    }
		                    else
		                    {
							    IDBroniZbrojownia[playerid] = 9;
							    format(brondef, sizeof(brondef), "Posiadasz ju� %s, chcesz go zamieni� na %s?\n(W przypadku gdy bro� jest taka sama, do obecnej broni b�dziesz m�g� doda� amunicje)", GunNames[BronieF[9][0]], GunNames[Dom[dom][hS_G9]]);
							    ShowPlayerDialogEx(playerid, 8244, DIALOG_STYLE_MSGBOX, "Wyjmowanie broni", brondef, "Zamie�", "Wr��");
							}
						}
						else
						{
							Dom[dom][hS_G9] = 0;
							Dom[dom][hS_A9] = 0;
							PlayerInfo[playerid][pGun9] = Dom[dom][hS_G9];
							PlayerInfo[playerid][pAmmo9] = Dom[dom][hS_A9];
							GivePlayerWeapon(playerid, Dom[dom][hS_G9], Dom[dom][hS_A9]);
							format(brondef, sizeof(brondef), "Wyj��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G9]]);
						    SendClientMessage(playerid, COLOR_NEWS, brondef);
	                        WyjmijBron(playerid);
						}
		            }
		            case 10:
		            {
		                new brondef[256];
		                new dom = PlayerInfo[playerid][pDom];
		                if(BronieF[10][0] != 0)
						{
						    IDBroniZbrojownia[playerid] = 10;
						    format(brondef, sizeof(brondef), "Posiadasz ju� %s, chcesz go zamieni� na %s?", GunNames[BronieF[10][0]], GunNames[Dom[dom][hS_G10]]);
						    ShowPlayerDialogEx(playerid, 8244, DIALOG_STYLE_MSGBOX, "Wyjmowanie broni", brondef, "Zamie�", "Wr��");
						}
						else
						{
							Dom[dom][hS_G10] = 0;
							Dom[dom][hS_A10] = 0;
							PlayerInfo[playerid][pGun10] = Dom[dom][hS_G10];
							PlayerInfo[playerid][pAmmo10] = 1;
							GivePlayerWeapon(playerid, Dom[dom][hS_G10], 1);
							format(brondef, sizeof(brondef), "Wyj��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G10]]);
						    SendClientMessage(playerid, COLOR_NEWS, brondef);
	                        WyjmijBron(playerid);
						}
		            }
		            case 11:
		            {
		                new brondef[256];
		                new dom = PlayerInfo[playerid][pDom];
		                if(BronieF[11][0] != 0)
						{
						    IDBroniZbrojownia[playerid] = 11;
						    format(brondef, sizeof(brondef), "Posiadasz ju� %s, chcesz go zamieni� na %s?", GunNames[BronieF[11][0]], GunNames[Dom[dom][hS_G11]]);
						    ShowPlayerDialogEx(playerid, 8244, DIALOG_STYLE_MSGBOX, "Wyjmowanie broni", brondef, "Zamie�", "Wr��");
						}
						else
						{
							Dom[dom][hS_G11] = 0;
							Dom[dom][hS_A11] = 0;
							PlayerInfo[playerid][pGun11] = Dom[dom][hS_G11];
							PlayerInfo[playerid][pAmmo11] = 1;
							GivePlayerWeapon(playerid, Dom[dom][hS_G11], 1);
							format(brondef, sizeof(brondef), "Wyj��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G11]]);
						    SendClientMessage(playerid, COLOR_NEWS, brondef);
	                        WyjmijBron(playerid);
						}
		            }
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 8240, DIALOG_STYLE_LIST, "Zbrojownia", "Wyjmij bro�\nSchowaj bro�\nZawarto�� zbrojowni", "Wybierz", "Anuluj");
		    }
		}
		if(dialogid == 8242)//chowanie broni
		{
		    if(response)
		    {
		        new dom = PlayerInfo[playerid][pDom];
		        new brondef[512];
		        switch(listitem)
		        {
		            case 0:
		            {
		                if(Dom[dom][hS_PG0] >= 1)
		                {
			                if(Dom[dom][hS_G0] == 1)
			                {
			                    IDBroniZbrojownia[playerid] = 0;
							    format(brondef, sizeof(brondef), "W zbrojowni jest ju� %s, chcesz zamieni� zawarto�� na %s?", GunNames[1], GunNames[1]);
							    ShowPlayerDialogEx(playerid, 8246, DIALOG_STYLE_MSGBOX, "Chowanie broni", brondef, "Zamie�", "Wr��");
			                }
			                else
			                {
				                format(brondef, sizeof(brondef), "Schowa�e� %s do zbrojowni", GunNames[PlayerInfo[playerid][pGun0]]);
				    			SendClientMessage(playerid, COLOR_NEWS, brondef);
				    			Dom[dom][hS_G0] = 1;
								PlayerInfo[playerid][pGun0] = 0;
								PlayerInfo[playerid][pAmmo0] = 0;
				                ResetPlayerWeapons(playerid);
				                PrzywrocBron(playerid);
				                SchowajBron(playerid);
				            }
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Twoja zbrojownia nie jest przystosowana do przechowywania kastetu.");
						    SchowajBron(playerid);
						}
		            }
		            case 1:
		            {
		                if(Dom[dom][hS_PG1] >= 1)
		                {
		                    if(Dom[dom][hS_G1] >= 1)
			                {
			                    IDBroniZbrojownia[playerid] = 1;
							    format(brondef, sizeof(brondef), "W zbrojowni jest ju� %s, chcesz zamieni� zawarto�� na %s?", GunNames[Dom[dom][hS_G1]], GunNames[PlayerInfo[playerid][pGun1]]);
							    ShowPlayerDialogEx(playerid, 8246, DIALOG_STYLE_MSGBOX, "Chowanie broni", brondef, "Zamie�", "Wr��");
			                }
			                else
			                {
				                format(brondef, sizeof(brondef), "Schowa�e� %s do zbrojowni", GunNames[PlayerInfo[playerid][pGun1]]);
				    			SendClientMessage(playerid, COLOR_NEWS, brondef);
				    			Dom[dom][hS_G1] = PlayerInfo[playerid][pGun1];
				    			Dom[dom][hS_A1] = 1;
								PlayerInfo[playerid][pGun1] = 0;
								PlayerInfo[playerid][pAmmo1] = 0;
				                ResetPlayerWeapons(playerid);
				                PrzywrocBron(playerid);
				                SchowajBron(playerid);
							}
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Twoja zbrojownia nie jest przystosowana do przechowywania broni bia�ej.");
						    SchowajBron(playerid);
						}
		            }
		            case 2:
		            {
		                if(Dom[dom][hS_PG2] >= 1)
		                {
			                if(Dom[dom][hS_G2] >= 1)
			                {
			                    if(PlayerInfo[playerid][pGun2] == Dom[dom][hS_G2])
			                    {
		                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G2]], PlayerInfo[playerid][pGun2]);
			                		ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			                    }
			                    else
			                    {
				                    IDBroniZbrojownia[playerid] = 2;
								    format(brondef, sizeof(brondef), "W zbrojowni jest ju� %s, chcesz zamieni� zawarto�� na %s?", GunNames[Dom[dom][hS_G2]], GunNames[PlayerInfo[playerid][pGun2]]);
								    ShowPlayerDialogEx(playerid, 8246, DIALOG_STYLE_MSGBOX, "Chowanie broni", brondef, "Zamie�", "Wr��");
								}
							}
			                else
			                {
				                format(brondef, sizeof(brondef), "Schowa�e� %s do zbrojowni", GunNames[PlayerInfo[playerid][pGun2]]);
				    			SendClientMessage(playerid, COLOR_NEWS, brondef);
				    			Dom[dom][hS_G2] = PlayerInfo[playerid][pGun2];
				    			Dom[dom][hS_A2] = PlayerInfo[playerid][pAmmo2];
								PlayerInfo[playerid][pGun2] = 0;
								PlayerInfo[playerid][pAmmo2] = 0;
				                ResetPlayerWeapons(playerid);
				                PrzywrocBron(playerid);
				                SchowajBron(playerid);
							}
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Twoja zbrojownia nie jest przystosowana do przechowywania pistolet�w.");
						    SchowajBron(playerid);
						}
		            }
		            case 3:
		            {
		                if(Dom[dom][hS_PG3] >= 1)
		                {
			                if(Dom[dom][hS_G3] >= 1)
			                {
			                    if(PlayerInfo[playerid][pGun3] == Dom[dom][hS_G3])
			                    {
		                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G3]], PlayerInfo[playerid][pGun3]);
			                		ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			                    }
			                    else
			                    {
				                    IDBroniZbrojownia[playerid] = 3;
								    format(brondef, sizeof(brondef), "W zbrojowni jest ju� %s, chcesz zamieni� zawarto�� na %s?", GunNames[Dom[dom][hS_G3]], GunNames[PlayerInfo[playerid][pGun3]]);
								    ShowPlayerDialogEx(playerid, 8246, DIALOG_STYLE_MSGBOX, "Chowanie broni", brondef, "Zamie�", "Wr��");
								}
							}
			                else
			                {
				                format(brondef, sizeof(brondef), "Schowa�e� %s do zbrojowni", GunNames[PlayerInfo[playerid][pGun3]]);
				    			SendClientMessage(playerid, COLOR_NEWS, brondef);
				    			Dom[dom][hS_G3] = PlayerInfo[playerid][pGun3];
				    			Dom[dom][hS_A3] = PlayerInfo[playerid][pAmmo3];
								PlayerInfo[playerid][pGun3] = 0;
								PlayerInfo[playerid][pAmmo3] = 0;
				                ResetPlayerWeapons(playerid);
				                PrzywrocBron(playerid);
							  	SchowajBron(playerid);
							}
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Twoja zbrojownia nie jest przystosowana do przechowywania strzelb.");
						    SchowajBron(playerid);
						}
		            }
		            case 4:
		            {
		                if(Dom[dom][hS_PG4] >= 1)
		                {
			                if(Dom[dom][hS_G4] >= 1)
			                {
			                    if(PlayerInfo[playerid][pGun4] == Dom[dom][hS_G4])
			                    {
		                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G4]], PlayerInfo[playerid][pGun4]);
			                		ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			                    }
			                    else
			                    {
				                    IDBroniZbrojownia[playerid] = 4;
								    format(brondef, sizeof(brondef), "W zbrojowni jest ju� %s, chcesz zamieni� zawarto�� na %s?", GunNames[Dom[dom][hS_G4]], GunNames[PlayerInfo[playerid][pGun4]]);
								    ShowPlayerDialogEx(playerid, 8246, DIALOG_STYLE_MSGBOX, "Chowanie broni", brondef, "Zamie�", "Wr��");
								}
							}
			                else
			                {
				                format(brondef, sizeof(brondef), "Schowa�e� %s do zbrojowni", GunNames[PlayerInfo[playerid][pGun4]]);
				    			SendClientMessage(playerid, COLOR_NEWS, brondef);
				    			Dom[dom][hS_G4] = PlayerInfo[playerid][pGun4];
				    			Dom[dom][hS_A4] = PlayerInfo[playerid][pAmmo4];
								PlayerInfo[playerid][pGun4] = 0;
								PlayerInfo[playerid][pAmmo4] = 0;
				                ResetPlayerWeapons(playerid);
				                PrzywrocBron(playerid);
				                SchowajBron(playerid);
							}
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Twoja zbrojownia nie jest przystosowana do przechowywania pistolet�w maszynowych.");
						    SchowajBron(playerid);
						}
		            }
		            case 5:
		            {
		                if(Dom[dom][hS_PG5] >= 1)
		                {
			                if(Dom[dom][hS_G5] >= 1)
			                {
			                    if(PlayerInfo[playerid][pGun5] == Dom[dom][hS_G5])
			                    {
		                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G5]], PlayerInfo[playerid][pGun5]);
			                		ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			                    }
			                    else
			                    {
				                    IDBroniZbrojownia[playerid] = 5;
								    format(brondef, sizeof(brondef), "W zbrojowni jest ju� %s, chcesz zamieni� zawarto�� na %s?", GunNames[Dom[dom][hS_G5]], GunNames[PlayerInfo[playerid][pGun5]]);
								    ShowPlayerDialogEx(playerid, 8246, DIALOG_STYLE_MSGBOX, "Chowanie broni", brondef, "Zamie�", "Wr��");
								}
							}
			                else
			                {
				                format(brondef, sizeof(brondef), "Schowa�e� %s do zbrojowni", GunNames[PlayerInfo[playerid][pGun5]]);
				    			SendClientMessage(playerid, COLOR_NEWS, brondef);
				    			Dom[dom][hS_G5] = PlayerInfo[playerid][pGun5];
				    			Dom[dom][hS_A5] = PlayerInfo[playerid][pAmmo5];
								PlayerInfo[playerid][pGun5] = 0;
								PlayerInfo[playerid][pAmmo5] = 0;
				                ResetPlayerWeapons(playerid);
				                PrzywrocBron(playerid);
				                SchowajBron(playerid);
							}
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Twoja zbrojownia nie jest przystosowana do przechowywania karabin�w maszynowych.");
						    SchowajBron(playerid);
						}
		            }
		            case 6:
		            {
		                if(Dom[dom][hS_PG6] >= 1)
		                {
			                if(Dom[dom][hS_G6] >= 1)
			                {
			                    if(PlayerInfo[playerid][pGun6] == Dom[dom][hS_G6])
			                    {
		                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G6]], PlayerInfo[playerid][pGun6]);
			                		ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			                    }
			                    else
			                    {
				                    IDBroniZbrojownia[playerid] = 6;
								    format(brondef, sizeof(brondef), "W zbrojowni jest ju� %s, chcesz zamieni� zawarto�� na %s?", GunNames[Dom[dom][hS_G6]], GunNames[PlayerInfo[playerid][pGun6]]);
								    ShowPlayerDialogEx(playerid, 8246, DIALOG_STYLE_MSGBOX, "Chowanie broni", brondef, "Zamie�", "Wr��");
								}
							}
			                else
			                {
				                format(brondef, sizeof(brondef), "Schowa�e� %s do zbrojowni", GunNames[PlayerInfo[playerid][pGun6]]);
				    			SendClientMessage(playerid, COLOR_NEWS, brondef);
				    			Dom[dom][hS_G6] = PlayerInfo[playerid][pGun6];
				    			Dom[dom][hS_A6] = PlayerInfo[playerid][pAmmo6];
								PlayerInfo[playerid][pGun6] = 0;
								PlayerInfo[playerid][pAmmo6] = 0;
				                ResetPlayerWeapons(playerid);
				                PrzywrocBron(playerid);
				                SchowajBron(playerid);
							}
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Twoja zbrojownia nie jest przystosowana do przechowywania snajperek.");
						    SchowajBron(playerid);
						}
		            }
		            case 7:
		            {
		                if(Dom[dom][hS_PG7] >= 1)
		                {
			                if(Dom[dom][hS_G7] >= 1)
			                {
			                    if(PlayerInfo[playerid][pGun7] == Dom[dom][hS_G7])
			                    {
		                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G7]], PlayerInfo[playerid][pGun7]);
			                		ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			                    }
			                    else
			                    {
				                    IDBroniZbrojownia[playerid] = 7;
								    format(brondef, sizeof(brondef), "W zbrojowni jest ju� %s, chcesz zamieni� zawarto�� na %s?", GunNames[Dom[dom][hS_G7]], GunNames[PlayerInfo[playerid][pGun7]]);
								    ShowPlayerDialogEx(playerid, 8246, DIALOG_STYLE_MSGBOX, "Chowanie broni", brondef, "Zamie�", "Wr��");
								}
							}
			                else
			                {
				                format(brondef, sizeof(brondef), "Schowa�e� %s do zbrojowni", GunNames[PlayerInfo[playerid][pGun7]]);
				    			SendClientMessage(playerid, COLOR_NEWS, brondef);
				    			Dom[dom][hS_G7] = PlayerInfo[playerid][pGun7];
				    			Dom[dom][hS_A7] = PlayerInfo[playerid][pAmmo7];
								PlayerInfo[playerid][pGun7] = 0;
								PlayerInfo[playerid][pAmmo7] = 0;
				                ResetPlayerWeapons(playerid);
				                PrzywrocBron(playerid);
				                SchowajBron(playerid);
							}
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Twoja zbrojownia nie jest przystosowana do przechowywania broni ci�kiej.");
						    SchowajBron(playerid);
						}
		            }
		            case 8:
		            {
		                if(Dom[dom][hS_PG8] >= 1)
		                {
			                if(Dom[dom][hS_G8] >= 1)
			                {
			                    if(PlayerInfo[playerid][pGun8] == Dom[dom][hS_G8])
			                    {
		                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G8]], PlayerInfo[playerid][pGun8]);
			                		ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			                    }
			                    else
			                    {
				                    IDBroniZbrojownia[playerid] = 8;
								    format(brondef, sizeof(brondef), "W zbrojowni jest ju� %s, chcesz zamieni� zawarto�� na %s?", GunNames[Dom[dom][hS_G8]], GunNames[PlayerInfo[playerid][pGun8]]);
								    ShowPlayerDialogEx(playerid, 8246, DIALOG_STYLE_MSGBOX, "Chowanie broni", brondef, "Zamie�", "Wr��");
								}
							}
			                else
			                {
				                format(brondef, sizeof(brondef), "Schowa�e� %s do zbrojowni", GunNames[PlayerInfo[playerid][pGun8]]);
				    			SendClientMessage(playerid, COLOR_NEWS, brondef);
				    			Dom[dom][hS_G8] = PlayerInfo[playerid][pGun8];
				    			Dom[dom][hS_A8] = PlayerInfo[playerid][pAmmo8];
								PlayerInfo[playerid][pGun8] = 0;
								PlayerInfo[playerid][pAmmo8] = 0;
				                ResetPlayerWeapons(playerid);
				                PrzywrocBron(playerid);
				                SchowajBron(playerid);
							}
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Twoja zbrojownia nie jest przystosowana do przechowywania �adunk�w wybuchowych.");
						    SchowajBron(playerid);
						}
		            }
		            case 9:
		            {
		                if(Dom[dom][hS_PG9] >= 1)
		                {
			                if(Dom[dom][hS_G9] >= 1)
			                {
			                    if(PlayerInfo[playerid][pGun9] == Dom[dom][hS_G9])
			                    {
		                            format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G9]], PlayerInfo[playerid][pGun9]);
			                		ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			                    }
			                    else
			                    {
				                    IDBroniZbrojownia[playerid] = 9;
								    format(brondef, sizeof(brondef), "W zbrojowni jest ju� %s, chcesz zamieni� zawarto�� na %s?", GunNames[Dom[dom][hS_G9]], GunNames[PlayerInfo[playerid][pGun9]]);
								    ShowPlayerDialogEx(playerid, 8246, DIALOG_STYLE_MSGBOX, "Chowanie broni", brondef, "Zamie�", "Wr��");
								}
							}
			                else
			                {
				                format(brondef, sizeof(brondef), "Schowa�e� %s do zbrojowni", GunNames[PlayerInfo[playerid][pGun9]]);
				    			SendClientMessage(playerid, COLOR_NEWS, brondef);
				    			Dom[dom][hS_G9] = PlayerInfo[playerid][pGun9];
				    			Dom[dom][hS_A9] = PlayerInfo[playerid][pAmmo9];
								PlayerInfo[playerid][pGun9] = 0;
								PlayerInfo[playerid][pAmmo9] = 0;
				                ResetPlayerWeapons(playerid);
				                PrzywrocBron(playerid);
				                SchowajBron(playerid);
							}
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Twoja zbrojownia nie jest przystosowana do przechowywania spreju/ga�nicy/aparatu.");
						    SchowajBron(playerid);
						}
		            }
		            case 10:
		            {
	                    if(Dom[dom][hS_PG10] >= 1)
		                {
			                if(Dom[dom][hS_G10] >= 1)
			                {
			                    IDBroniZbrojownia[playerid] = 10;
							    format(brondef, sizeof(brondef), "W zbrojowni jest ju� %s, chcesz zamieni� zawarto�� na %s?", GunNames[Dom[dom][hS_G10]], GunNames[PlayerInfo[playerid][pGun10]]);
							    ShowPlayerDialogEx(playerid, 8246, DIALOG_STYLE_MSGBOX, "Chowanie broni", brondef, "Zamie�", "Wr��");
			                }
			                else
			                {
				                format(brondef, sizeof(brondef), "Schowa�e� %s do zbrojowni", GunNames[PlayerInfo[playerid][pGun10]]);
				    			SendClientMessage(playerid, COLOR_NEWS, brondef);
				    			Dom[dom][hS_G10] = PlayerInfo[playerid][pGun10];
				    			Dom[dom][hS_A10] = 1;
								PlayerInfo[playerid][pGun10] = 0;
								PlayerInfo[playerid][pAmmo10] = 0;
				                ResetPlayerWeapons(playerid);
				                PrzywrocBron(playerid);
				                SchowajBron(playerid);
							}
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Twoja zbrojownia nie jest przystosowana do przechowywania kwiat�w/lasek/wibrator�w.");
						    SchowajBron(playerid);
						}
		            }
		            case 11:
		            {
		                if(Dom[dom][hS_PG11] >= 1)
		                {
			                if(Dom[dom][hS_G11] >= 1)
			                {
			                    IDBroniZbrojownia[playerid] = 11;
							    format(brondef, sizeof(brondef), "W zbrojowni jest ju� %s, chcesz zamieni� zawarto�� na %s?", GunNames[Dom[dom][hS_G11]], GunNames[PlayerInfo[playerid][pGun11]]);
							    ShowPlayerDialogEx(playerid, 8246, DIALOG_STYLE_MSGBOX, "Chowanie broni", brondef, "Zamie�", "Wr��");
			                }
			                else
			                {
				                format(brondef, sizeof(brondef), "Schowa�e� %s do zbrojowni", GunNames[PlayerInfo[playerid][pGun11]]);
				    			SendClientMessage(playerid, COLOR_NEWS, brondef);
				    			Dom[dom][hS_G11] = PlayerInfo[playerid][pGun11];
				    			Dom[dom][hS_A11] = 1;
								PlayerInfo[playerid][pGun11] = 0;
								PlayerInfo[playerid][pAmmo11] = 0;
				                ResetPlayerWeapons(playerid);
				                PrzywrocBron(playerid);
				                SchowajBron(playerid);
				            }
			            }
						else
						{
						    SendClientMessage(playerid, COLOR_GRAD3, "Twoja zbrojownia nie jest przystosowana do przechowywania spadochronu.");
						    SchowajBron(playerid);
						}
		            }
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 8240, DIALOG_STYLE_LIST, "Zbrojownia", "Wyjmij bro�\nSchowaj bro�\nZawarto�� zbrojowni", "Wybierz", "Anuluj");
		    }
		}
		if(dialogid == 8243)//lista/usuwanie broni
		{
		    if(response)
		    {
		        new dom = PlayerInfo[playerid][pDom];
		        switch(listitem)
		        {
		            case 0:
		            {
		                new brondef[256];
		                Dom[dom][hS_G0] = 0;
						format(brondef, sizeof(brondef), "Usun��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G0]]);
		    			SendClientMessage(playerid, COLOR_NEWS, brondef);
	        			ListaBroni(playerid);
		            }
		            case 1:
		            {
		                new brondef[256];
		                Dom[dom][hS_G1] = 0;
		                Dom[dom][hS_A1] = 0;
						format(brondef, sizeof(brondef), "Usun��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G1]]);
		    			SendClientMessage(playerid, COLOR_NEWS, brondef);
	        			ListaBroni(playerid);
		            }
		            case 2:
		            {
		                new brondef[256];
		                Dom[dom][hS_G2] = 0;
		                Dom[dom][hS_A2] = 0;
						format(brondef, sizeof(brondef), "Usun��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G2]]);
		    			SendClientMessage(playerid, COLOR_NEWS, brondef);
	        			ListaBroni(playerid);
		            }
		            case 3:
		            {
		                new brondef[256];
		                Dom[dom][hS_G3] = 0;
		                Dom[dom][hS_A3] = 0;
						format(brondef, sizeof(brondef), "Usun��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G3]]);
		    			SendClientMessage(playerid, COLOR_NEWS, brondef);
	        			ListaBroni(playerid);
		            }
		            case 4:
		            {
		                new brondef[256];
		                Dom[dom][hS_G4] = 0;
		                Dom[dom][hS_A4] = 0;
						format(brondef, sizeof(brondef), "Usun��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G4]]);
		    			SendClientMessage(playerid, COLOR_NEWS, brondef);
	        			ListaBroni(playerid);
		            }
		            case 5:
		            {
		                new brondef[256];
		                Dom[dom][hS_G5] = 0;
		                Dom[dom][hS_A5] = 0;
						format(brondef, sizeof(brondef), "Usun��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G5]]);
		    			SendClientMessage(playerid, COLOR_NEWS, brondef);
	        			ListaBroni(playerid);
		            }
		            case 6:
		            {
		                new brondef[256];
		                Dom[dom][hS_G6] = 0;
		                Dom[dom][hS_A6] = 0;
						format(brondef, sizeof(brondef), "Usun��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G6]]);
		    			SendClientMessage(playerid, COLOR_NEWS, brondef);
	        			ListaBroni(playerid);
		            }
		            case 7:
		            {
		                new brondef[256];
		                Dom[dom][hS_G7] = 0;
		                Dom[dom][hS_A7] = 0;
						format(brondef, sizeof(brondef), "Usun��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G7]]);
		    			SendClientMessage(playerid, COLOR_NEWS, brondef);
	        			ListaBroni(playerid);
		            }
		            case 8:
		            {
		                new brondef[256];
		                Dom[dom][hS_G8] = 0;
		                Dom[dom][hS_A8] = 0;
						format(brondef, sizeof(brondef), "Usun��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G8]]);
		    			SendClientMessage(playerid, COLOR_NEWS, brondef);
	        			ListaBroni(playerid);
		            }
		            case 9:
		            {
		                new brondef[256];
		                Dom[dom][hS_G9] = 0;
		                Dom[dom][hS_A9] = 0;
						format(brondef, sizeof(brondef), "Usun��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G9]]);
		    			SendClientMessage(playerid, COLOR_NEWS, brondef);
	        			ListaBroni(playerid);
		            }
		            case 10:
		            {
		                new brondef[256];
		                Dom[dom][hS_G10] = 0;
		                Dom[dom][hS_A10] = 0;
						format(brondef, sizeof(brondef), "Usun��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G10]]);
		    			SendClientMessage(playerid, COLOR_NEWS, brondef);
	        			ListaBroni(playerid);
		            }
		            case 11:
		            {
		                new brondef[256];
		                Dom[dom][hS_G11] = 0;
		                Dom[dom][hS_A11] = 0;
						format(brondef, sizeof(brondef), "Usun��e� %s ze zbrojowni", GunNames[Dom[dom][hS_G11]]);
		    			SendClientMessage(playerid, COLOR_NEWS, brondef);
	        			ListaBroni(playerid);
		            }
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 8240, DIALOG_STYLE_LIST, "Zbrojownia", "Wyjmij bro�\nSchowaj bro�\nZawarto�� zbrojowni", "Wybierz", "Anuluj");
		    }
		}
		if(dialogid == 8244)
		{
		    if(response)
		    {
		        new dom = PlayerInfo[playerid][pDom];
		        if(IDBroniZbrojownia[playerid] == 0)
		        {
		            SendClientMessage(playerid, COLOR_NEWS, "Wymieni�e� kastet na kastet");
		            Dom[dom][hS_G0] = 0;
		        }
		        if(IDBroniZbrojownia[playerid] == 1)
		        {
	       			new brondef[256];
	          		format(brondef, sizeof(brondef), "Wymieni�e� %s na %s", GunNames[PlayerInfo[playerid][pGun1]], GunNames[Dom[dom][hS_G1]]);
	            	SendClientMessage(playerid, COLOR_NEWS, brondef);
					PlayerInfo[playerid][pGun1] = Dom[dom][hS_G1];
	                PlayerInfo[playerid][pAmmo1] = Dom[dom][hS_A1];
	                Dom[dom][hS_G1] = 0;
	                Dom[dom][hS_A1] = 0;
		        }
		        if(IDBroniZbrojownia[playerid] == 2)
		        {
	 				new brondef[256];
	          		format(brondef, sizeof(brondef), "Wymieni�e� %s na %s", GunNames[PlayerInfo[playerid][pGun2]], GunNames[Dom[dom][hS_G2]]);
	            	SendClientMessage(playerid, COLOR_NEWS, brondef);
					PlayerInfo[playerid][pGun2] = Dom[dom][hS_G2];
	                PlayerInfo[playerid][pAmmo2] = Dom[dom][hS_A2];
	                Dom[dom][hS_G2] = 0;
	                Dom[dom][hS_A2] = 0;
		        }
		        if(IDBroniZbrojownia[playerid] == 3)
		        {
	      			new brondef[256];
		       		format(brondef, sizeof(brondef), "Wymieni�e� %s na %s", GunNames[PlayerInfo[playerid][pGun3]], GunNames[Dom[dom][hS_G3]]);
		        	SendClientMessage(playerid, COLOR_NEWS, brondef);
					PlayerInfo[playerid][pGun3] = Dom[dom][hS_G3];
	    			PlayerInfo[playerid][pAmmo3] = Dom[dom][hS_A3];
	       			Dom[dom][hS_G3] = 0;
	          		Dom[dom][hS_A3] = 0;
		        }
		        if(IDBroniZbrojownia[playerid] == 4)
		        {
	      			new brondef[256];
		       		format(brondef, sizeof(brondef), "Wymieni�e� %s na %s", GunNames[PlayerInfo[playerid][pGun4]], GunNames[Dom[dom][hS_G4]]);
		        	SendClientMessage(playerid, COLOR_NEWS, brondef);
					PlayerInfo[playerid][pGun4] = Dom[dom][hS_G4];
	    			PlayerInfo[playerid][pAmmo4] = Dom[dom][hS_A4];
	       			Dom[dom][hS_G4] = 0;
	          		Dom[dom][hS_A4] = 0;
		        }
		        if(IDBroniZbrojownia[playerid] == 5)
		        {
	      			new brondef[256];
	       			format(brondef, sizeof(brondef), "Wymieni�e� %s na %s", GunNames[PlayerInfo[playerid][pGun5]], GunNames[Dom[dom][hS_G5]]);
	         		SendClientMessage(playerid, COLOR_NEWS, brondef);
					PlayerInfo[playerid][pGun5] = Dom[dom][hS_G5];
	    			PlayerInfo[playerid][pAmmo5] = Dom[dom][hS_A5];
	       			Dom[dom][hS_G5] = 0;
	          		Dom[dom][hS_A5] = 0;
		        }
		        if(IDBroniZbrojownia[playerid] == 6)
		        {
	      			new brondef[256];
	     			format(brondef, sizeof(brondef), "Wymieni�e� %s na %s", GunNames[PlayerInfo[playerid][pGun6]], GunNames[Dom[dom][hS_G6]]);
		           	SendClientMessage(playerid, COLOR_NEWS, brondef);
					PlayerInfo[playerid][pGun6] = Dom[dom][hS_G6];
					PlayerInfo[playerid][pAmmo6] = Dom[dom][hS_A6];
	    			Dom[dom][hS_G6] = 0;
	   				Dom[dom][hS_A6] = 0;
		        }
		        if(IDBroniZbrojownia[playerid] == 7)
		        {
	      			new brondef[256];
		       		format(brondef, sizeof(brondef), "Wymieni�e� %s na %s", GunNames[PlayerInfo[playerid][pGun7]], GunNames[Dom[dom][hS_G7]]);
		        	SendClientMessage(playerid, COLOR_NEWS, brondef);
					PlayerInfo[playerid][pGun7] = Dom[dom][hS_G7];
				    PlayerInfo[playerid][pAmmo7] = Dom[dom][hS_A7];
				    Dom[dom][hS_G7] = 0;
				    Dom[dom][hS_A7] = 0;
		        }
		        if(IDBroniZbrojownia[playerid] == 8)
		        {
		       		new brondef[256];
	       			format(brondef, sizeof(brondef), "Wymieni�e� %s na %s", GunNames[PlayerInfo[playerid][pGun8]], GunNames[Dom[dom][hS_G8]]);
		           	SendClientMessage(playerid, COLOR_NEWS, brondef);
					PlayerInfo[playerid][pGun8] = Dom[dom][hS_G8];
	    			PlayerInfo[playerid][pAmmo8] = Dom[dom][hS_A8];
	   				Dom[dom][hS_G8] = 0;
	       			Dom[dom][hS_A8] = 0;
		        }
		        if(IDBroniZbrojownia[playerid] == 9)
		        {
	      			new brondef[256];
	       			format(brondef, sizeof(brondef), "Wymieni�e� %s na %s", GunNames[PlayerInfo[playerid][pGun9]], GunNames[Dom[dom][hS_G9]]);
	         		SendClientMessage(playerid, COLOR_NEWS, brondef);
					PlayerInfo[playerid][pGun9] = Dom[dom][hS_G9];
	    			PlayerInfo[playerid][pAmmo9] = Dom[dom][hS_A9];
	       			Dom[dom][hS_G9] = 0;
	          		Dom[dom][hS_A9] = 0;
		        }
		        if(IDBroniZbrojownia[playerid] == 10)
		        {
	       			new brondef[256];
	          		format(brondef, sizeof(brondef), "Wymieni�e� %s na %s", GunNames[PlayerInfo[playerid][pGun10]], GunNames[Dom[dom][hS_G10]]);
	            	SendClientMessage(playerid, COLOR_NEWS, brondef);
					PlayerInfo[playerid][pGun10] = Dom[dom][hS_G10];
	                PlayerInfo[playerid][pAmmo10] = Dom[dom][hS_A10];
	                Dom[dom][hS_G10] = 0;
	                Dom[dom][hS_A10] = 0;
		        }
		        if(IDBroniZbrojownia[playerid] == 11)
		        {
	       			new brondef[256];
	          		format(brondef, sizeof(brondef), "Wymieni�e� %s na %s", GunNames[PlayerInfo[playerid][pGun11]], GunNames[Dom[dom][hS_G11]]);
	            	SendClientMessage(playerid, COLOR_NEWS, brondef);
					PlayerInfo[playerid][pGun11] = Dom[dom][hS_G11];
	                PlayerInfo[playerid][pAmmo11] = Dom[dom][hS_A11];
	                Dom[dom][hS_G11] = 0;
	                Dom[dom][hS_A11] = 0;
		        }
	            WyjmijBron(playerid);
	            ResetPlayerWeapons(playerid);
		        PrzywrocBron(playerid);
		    }
		    if(!response)
		    {
		        IDBroniZbrojownia[playerid] = 0;
		        WyjmijBron(playerid);
		    }
		}
		if(dialogid == 8245)
		{
		    if(response)
		    {
		        new dom = PlayerInfo[playerid][pDom];
		        new brondef[256];
		        if(IDBroniZbrojownia[playerid] == 2)
		        {
		   			PlayerInfo[playerid][pAmmo2] += Dom[dom][hS_A2];
		      		GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun2], Dom[dom][hS_A2]);
		      		Dom[dom][hS_G2] = 0;
					Dom[dom][hS_A2] = 0;
		            format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo2], GunNames[PlayerInfo[playerid][pGun2]]);
		            SendClientMessage(playerid, COLOR_NEWS, brondef);
				}
				if(IDBroniZbrojownia[playerid] == 3)
		        {
		   			PlayerInfo[playerid][pAmmo3] += Dom[dom][hS_A3];
		      		GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun3], Dom[dom][hS_A3]);
		      		Dom[dom][hS_G3] = 0;
					Dom[dom][hS_A3] = 0;
		            format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo3], GunNames[PlayerInfo[playerid][pGun3]]);
		            SendClientMessage(playerid, COLOR_NEWS, brondef);
				}
				if(IDBroniZbrojownia[playerid] == 4)
		        {
		   			PlayerInfo[playerid][pAmmo4] += Dom[dom][hS_A4];
		      		GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun4], Dom[dom][hS_A4]);
		      		Dom[dom][hS_G4] = 0;
					Dom[dom][hS_A4] = 0;
		            format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo4], GunNames[PlayerInfo[playerid][pGun4]]);
		            SendClientMessage(playerid, COLOR_NEWS, brondef);
				}
				if(IDBroniZbrojownia[playerid] == 5)
		        {
		   			PlayerInfo[playerid][pAmmo5] += Dom[dom][hS_A5];
		      		GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun5], Dom[dom][hS_A5]);
		      		Dom[dom][hS_G5] = 0;
					Dom[dom][hS_A5] = 0;
		            format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo5], GunNames[PlayerInfo[playerid][pGun5]]);
		            SendClientMessage(playerid, COLOR_NEWS, brondef);
				}
				if(IDBroniZbrojownia[playerid] == 6)
		        {
		   			PlayerInfo[playerid][pAmmo6] += Dom[dom][hS_A6];
		      		GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun6], Dom[dom][hS_A6]);
		      		Dom[dom][hS_G6] = 0;
					Dom[dom][hS_A6] = 0;
		            format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo6], GunNames[PlayerInfo[playerid][pGun6]]);
		            SendClientMessage(playerid, COLOR_NEWS, brondef);
				}
				if(IDBroniZbrojownia[playerid] == 7)
		        {
		   			PlayerInfo[playerid][pAmmo7] += Dom[dom][hS_A7];
		      		GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun7], Dom[dom][hS_A7]);
		      		Dom[dom][hS_G7] = 0;
					Dom[dom][hS_A7] = 0;
		            format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo7], GunNames[PlayerInfo[playerid][pGun7]]);
		            SendClientMessage(playerid, COLOR_NEWS, brondef);
				}
				if(IDBroniZbrojownia[playerid] == 8)
		        {
		   			PlayerInfo[playerid][pAmmo8] += Dom[dom][hS_A8];
		      		GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun8], Dom[dom][hS_A8]);
		      		Dom[dom][hS_G8] = 0;
					Dom[dom][hS_A8] = 0;
		            format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo8], GunNames[PlayerInfo[playerid][pGun8]]);
		            SendClientMessage(playerid, COLOR_NEWS, brondef);
				}
				if(IDBroniZbrojownia[playerid] == 9)
		        {
		   			PlayerInfo[playerid][pAmmo9] += Dom[dom][hS_A9];
		      		GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun9], Dom[dom][hS_A9]);
		      		Dom[dom][hS_G9] = 0;
					Dom[dom][hS_A9] = 0;
		            format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo9], GunNames[PlayerInfo[playerid][pGun9]]);
		            SendClientMessage(playerid, COLOR_NEWS, brondef);
				}
				WyjmijBron(playerid);
			}
		    if(!response)
		    {
		        new dom = PlayerInfo[playerid][pDom];
		        if(strlen(inputtext) >= 1 && strlen(inputtext) <= 6 && strval(inputtext) >= 1 && strval(inputtext) <= 100000)
		        {
		            new brondef[512];
		            if(IDBroniZbrojownia[playerid] == 2)
			        {
			            if(strval(inputtext) < Dom[dom][hS_A2])
			            {
			                Dom[dom][hS_A2] -= strval(inputtext);
			                PlayerInfo[playerid][pAmmo2] += strval(inputtext);
			                GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun2], strval(inputtext));
			                format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo2], GunNames[PlayerInfo[playerid][pGun2]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz tyle naboi w zbrojowni lub pr�bujesz wzi��� wszystkie. Aby wzi��c wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G2]], Dom[dom][hS_A2]);
			                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        if(IDBroniZbrojownia[playerid] == 3)
			        {
			            if(strval(inputtext) < Dom[dom][hS_A3])
			            {
			                Dom[dom][hS_A3] -= strval(inputtext);
			                PlayerInfo[playerid][pAmmo3] += strval(inputtext);
			                GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun3], strval(inputtext));
			                format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo3], GunNames[PlayerInfo[playerid][pGun3]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz tyle naboi w zbrojowni lub pr�bujesz wzi��� wszystkie. Aby wzi��c wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G3]], Dom[dom][hS_A3]);
			                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        if(IDBroniZbrojownia[playerid] == 4)
			        {
			            if(strval(inputtext) < Dom[dom][hS_A4])
			            {
			                Dom[dom][hS_A4] -= strval(inputtext);
			                PlayerInfo[playerid][pAmmo4] += strval(inputtext);
			                GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun4], strval(inputtext));
			                format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo4], GunNames[PlayerInfo[playerid][pGun4]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz tyle naboi w zbrojowni lub pr�bujesz wzi��� wszystkie. Aby wzi��c wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G4]], Dom[dom][hS_A4]);
			                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        if(IDBroniZbrojownia[playerid] == 5)
			        {
			            if(strval(inputtext) < Dom[dom][hS_A5])
			            {
			                Dom[dom][hS_A5] -= strval(inputtext);
			                PlayerInfo[playerid][pAmmo5] += strval(inputtext);
			                GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun5], strval(inputtext));
			                format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo5], GunNames[PlayerInfo[playerid][pGun5]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz tyle naboi w zbrojowni lub pr�bujesz wzi��� wszystkie. Aby wzi��c wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G5]], Dom[dom][hS_A5]);
			                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        if(IDBroniZbrojownia[playerid] == 6)
			        {
			            if(strval(inputtext) < Dom[dom][hS_A6])
			            {
			                Dom[dom][hS_A6] -= strval(inputtext);
			                PlayerInfo[playerid][pAmmo6] += strval(inputtext);
			                GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun6], strval(inputtext));
			                format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo6], GunNames[PlayerInfo[playerid][pGun6]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz tyle naboi w zbrojowni lub pr�bujesz wzi��� wszystkie. Aby wzi��c wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G6]], Dom[dom][hS_A6]);
			                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        if(IDBroniZbrojownia[playerid] == 7)
			        {
			            if(strval(inputtext) < Dom[dom][hS_A7])
			            {
			                Dom[dom][hS_A7] -= strval(inputtext);
			                PlayerInfo[playerid][pAmmo7] += strval(inputtext);
			                GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun7], strval(inputtext));
			                format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo7], GunNames[PlayerInfo[playerid][pGun7]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz tyle naboi w zbrojowni lub pr�bujesz wzi��� wszystkie. Aby wzi��c wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G7]], Dom[dom][hS_A7]);
			                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        if(IDBroniZbrojownia[playerid] == 8)
			        {
			            if(strval(inputtext) < Dom[dom][hS_A8])
			            {
			                Dom[dom][hS_A8] -= strval(inputtext);
			                PlayerInfo[playerid][pAmmo8] += strval(inputtext);
			                GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun8], strval(inputtext));
			                format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo8], GunNames[PlayerInfo[playerid][pGun8]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz tyle naboi w zbrojowni lub pr�bujesz wzi��� wszystkie. Aby wzi��c wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G8]], Dom[dom][hS_A8]);
			                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        if(IDBroniZbrojownia[playerid] == 9)
			        {
			            if(strval(inputtext) < Dom[dom][hS_A9])
			            {
			                Dom[dom][hS_A9] -= strval(inputtext);
			                PlayerInfo[playerid][pAmmo9] += strval(inputtext);
			                GivePlayerWeapon(playerid, PlayerInfo[playerid][pGun9], strval(inputtext));
			                format(brondef, sizeof(brondef), "Masz teraz %d naboi w swoim %s", PlayerInfo[playerid][pAmmo9], GunNames[PlayerInfo[playerid][pGun9]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz tyle naboi w zbrojowni lub pr�bujesz wzi��� wszystkie. Aby wzi��c wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G9]], Dom[dom][hS_A9]);
			                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        WyjmijBron(playerid);
		        }
		        else
		        {
		            SendClientMessage(playerid, COLOR_NEWS, "Ilo�� naboi od 1 do 100 000");
		         	if(IDBroniZbrojownia[playerid] == 2)
			        {
		                new info[512];
						format(info, sizeof(info), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G2]], Dom[dom][hS_A2]);
		                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", info, "Wszystko", "Naboje");
		            	return 1;
		            }
			        if(IDBroniZbrojownia[playerid] == 3)
			        {
		                new info[512];
						format(info, sizeof(info), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G3]], Dom[dom][hS_A3]);
		                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", info, "Wszystko", "Naboje");
		            	return 1;
		        	}
			        if(IDBroniZbrojownia[playerid] == 4)
			        {
		                new info[512];
						format(info, sizeof(info), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G4]], Dom[dom][hS_A4]);
		                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", info, "Wszystko", "Naboje");
		            	return 1;
			        }
			        if(IDBroniZbrojownia[playerid] == 5)
			        {
		                new info[512];
						format(info, sizeof(info), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G5]], Dom[dom][hS_A5]);
		                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", info, "Wszystko", "Naboje");
		            	return 1;
			        }
			        if(IDBroniZbrojownia[playerid] == 6)
			        {
		                new info[512];
						format(info, sizeof(info), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G6]], Dom[dom][hS_A6]);
		                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", info, "Wszystko", "Naboje");
		            	return 1;
			        }
			        if(IDBroniZbrojownia[playerid] == 7)
			        {
		                new info[512];
						format(info, sizeof(info), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G7]], Dom[dom][hS_A7]);
		                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", info, "Wszystko", "Naboje");
		            	return 1;
			        }
			        if(IDBroniZbrojownia[playerid] == 8)
		        	{
		                new info[512];
						format(info, sizeof(info), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G8]], Dom[dom][hS_A8]);
		                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", info, "Wszystko", "Naboje");
		            	return 1;
			        }
			        if(IDBroniZbrojownia[playerid] == 9)
			        {
		                new info[512];
						format(info, sizeof(info), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz wyj�� ca�� bro� z nabojami lub wyj�� okre�lon� ilo�� naboi.\nJe�eli chcesz wyj�� naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G9]], Dom[dom][hS_A9]);
		                ShowPlayerDialogEx(playerid, 8245, DIALOG_STYLE_INPUT, "Wyjmowanie amunicji", info, "Wszystko", "Naboje");
						return 1;
					}
		        }
		    }
		}
		if(dialogid == 8246)
		{
		    if(response)
		    {
		        new brondef[256];
		        new dom = PlayerInfo[playerid][pDom];
		        if(IDBroniZbrojownia[playerid] == 0)
		        {
		            Dom[dom][hS_G0] = 1;
	          		PlayerInfo[playerid][pGun0] = 0;
	    			PlayerInfo[playerid][pAmmo0] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s", GunNames[1]);
					SendClientMessage(playerid, COLOR_NEWS, brondef);
				}
				if(IDBroniZbrojownia[playerid] == 1)
		        {
		            Dom[dom][hS_G1] = PlayerInfo[playerid][pGun1];
	          		Dom[dom][hS_A1] = 1;
	          		PlayerInfo[playerid][pGun1] = 0;
	    			PlayerInfo[playerid][pAmmo1] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s", GunNames[Dom[dom][hS_G1]]);
					SendClientMessage(playerid, COLOR_NEWS, brondef);
				}
		        if(IDBroniZbrojownia[playerid] == 2)
		        {
		            Dom[dom][hS_G2] = PlayerInfo[playerid][pGun2];
	          		Dom[dom][hS_A2] = PlayerInfo[playerid][pAmmo2];
	          		PlayerInfo[playerid][pGun2] = 0;
	    			PlayerInfo[playerid][pAmmo2] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G2]], Dom[dom][hS_A2]);
				}
				if(IDBroniZbrojownia[playerid] == 3)
		        {
		            Dom[dom][hS_G3] = PlayerInfo[playerid][pGun3];
	          		Dom[dom][hS_A3] = PlayerInfo[playerid][pAmmo3];
	          		PlayerInfo[playerid][pGun3] = 0;
	    			PlayerInfo[playerid][pAmmo3] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G3]], Dom[dom][hS_A3]);
				}
				if(IDBroniZbrojownia[playerid] == 4)
		        {
		            Dom[dom][hS_G4] = PlayerInfo[playerid][pGun4];
	          		Dom[dom][hS_A4] = PlayerInfo[playerid][pAmmo4];
	          		PlayerInfo[playerid][pGun4] = 0;
	    			PlayerInfo[playerid][pAmmo4] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G4]], Dom[dom][hS_A4]);
				}
				if(IDBroniZbrojownia[playerid] == 5)
		        {
		            Dom[dom][hS_G5] = PlayerInfo[playerid][pGun5];
	          		Dom[dom][hS_A5] = PlayerInfo[playerid][pAmmo5];
	          		PlayerInfo[playerid][pGun5] = 0;
	    			PlayerInfo[playerid][pAmmo5] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G5]], Dom[dom][hS_A5]);
				}
				if(IDBroniZbrojownia[playerid] == 6)
		        {
		            Dom[dom][hS_G6] = PlayerInfo[playerid][pGun6];
	          		Dom[dom][hS_A6] = PlayerInfo[playerid][pAmmo6];
	          		PlayerInfo[playerid][pGun6] = 0;
	    			PlayerInfo[playerid][pAmmo6] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G6]], Dom[dom][hS_A6]);
				}
				if(IDBroniZbrojownia[playerid] == 7)
		        {
		            Dom[dom][hS_G7] = PlayerInfo[playerid][pGun7];
	          		Dom[dom][hS_A7] = PlayerInfo[playerid][pAmmo7];
	          		PlayerInfo[playerid][pGun7] = 0;
	    			PlayerInfo[playerid][pAmmo7] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G7]], Dom[dom][hS_A7]);
				}
				if(IDBroniZbrojownia[playerid] == 8)
		        {
		            Dom[dom][hS_G8] = PlayerInfo[playerid][pGun8];
	          		Dom[dom][hS_A8] = PlayerInfo[playerid][pAmmo8];
	          		PlayerInfo[playerid][pGun8] = 0;
	    			PlayerInfo[playerid][pAmmo8] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G8]], Dom[dom][hS_A8]);
				}
				if(IDBroniZbrojownia[playerid] == 9)
		        {
		            Dom[dom][hS_G9] = PlayerInfo[playerid][pGun9];
	          		Dom[dom][hS_A9] = PlayerInfo[playerid][pAmmo9];
	          		PlayerInfo[playerid][pGun9] = 0;
	    			PlayerInfo[playerid][pAmmo9] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G9]], Dom[dom][hS_A9]);
				}
				if(IDBroniZbrojownia[playerid] == 10)
		        {
		            Dom[dom][hS_G10] = PlayerInfo[playerid][pGun10];
	          		Dom[dom][hS_A10] = 1;
	          		PlayerInfo[playerid][pGun10] = 0;
	    			PlayerInfo[playerid][pAmmo10] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s", GunNames[Dom[dom][hS_G10]]);
					SendClientMessage(playerid, COLOR_NEWS, brondef);
				}
				if(IDBroniZbrojownia[playerid] == 11)
		        {
		            Dom[dom][hS_G11] = PlayerInfo[playerid][pGun11];
	          		Dom[dom][hS_A11] = 1;
	          		PlayerInfo[playerid][pGun11] = 0;
	    			PlayerInfo[playerid][pAmmo11] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s", GunNames[Dom[dom][hS_G11]]);
					SendClientMessage(playerid, COLOR_NEWS, brondef);
				}
				ResetPlayerWeapons(playerid);
				PrzywrocBron(playerid);
	            SchowajBron(playerid);
			}
			if(!response)
			{
			    SchowajBron(playerid);
			}
		}
		if(dialogid == 8247)
		{
			if(response)
			{
			    new dom = PlayerInfo[playerid][pDom];
			    new brondef[256];
			    if(IDBroniZbrojownia[playerid] == 2)
		        {
	          		Dom[dom][hS_A2] += PlayerInfo[playerid][pAmmo2];
	          		PlayerInfo[playerid][pGun2] = 0;
	    			PlayerInfo[playerid][pAmmo2] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G2]], Dom[dom][hS_A2]);
					SendClientMessage(playerid, COLOR_NEWS, brondef);
		        }
		        if(IDBroniZbrojownia[playerid] == 3)
		        {
	          		Dom[dom][hS_A3] += PlayerInfo[playerid][pAmmo3];
	          		PlayerInfo[playerid][pGun3] = 0;
	    			PlayerInfo[playerid][pAmmo3] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G3]], Dom[dom][hS_A3]);
					SendClientMessage(playerid, COLOR_NEWS, brondef);
		        }
		        if(IDBroniZbrojownia[playerid] == 4)
		        {
	          		Dom[dom][hS_A4] += PlayerInfo[playerid][pAmmo4];
	          		PlayerInfo[playerid][pGun4] = 0;
	    			PlayerInfo[playerid][pAmmo4] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G4]], Dom[dom][hS_A4]);
					SendClientMessage(playerid, COLOR_NEWS, brondef);
		        }
		        if(IDBroniZbrojownia[playerid] == 5)
		        {
	          		Dom[dom][hS_A5] += PlayerInfo[playerid][pAmmo5];
	          		PlayerInfo[playerid][pGun5] = 0;
	    			PlayerInfo[playerid][pAmmo5] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G5]], Dom[dom][hS_A5]);
					SendClientMessage(playerid, COLOR_NEWS, brondef);
		        }
		        if(IDBroniZbrojownia[playerid] == 6)
		        {
	          		Dom[dom][hS_A6] += PlayerInfo[playerid][pAmmo6];
	          		PlayerInfo[playerid][pGun6] = 0;
	    			PlayerInfo[playerid][pAmmo6] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G6]], Dom[dom][hS_A6]);
					SendClientMessage(playerid, COLOR_NEWS, brondef);
		        }
		        if(IDBroniZbrojownia[playerid] == 7)
		        {
	          		Dom[dom][hS_A7] += PlayerInfo[playerid][pAmmo7];
	          		PlayerInfo[playerid][pGun7] = 0;
	    			PlayerInfo[playerid][pAmmo7] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G7]], Dom[dom][hS_A7]);
					SendClientMessage(playerid, COLOR_NEWS, brondef);
		        }
		        if(IDBroniZbrojownia[playerid] == 8)
		        {
	          		Dom[dom][hS_A8] += PlayerInfo[playerid][pAmmo8];
	          		PlayerInfo[playerid][pGun8] = 0;
	    			PlayerInfo[playerid][pAmmo8] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G8]], Dom[dom][hS_A8]);
					SendClientMessage(playerid, COLOR_NEWS, brondef);
		        }
		        if(IDBroniZbrojownia[playerid] == 9)
		        {
	          		Dom[dom][hS_A9] += PlayerInfo[playerid][pAmmo9];
	          		PlayerInfo[playerid][pGun9] = 0;
	    			PlayerInfo[playerid][pAmmo9] = 0;
			       	format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %s z %d nabojami", GunNames[Dom[dom][hS_G9]], Dom[dom][hS_A9]);
					SendClientMessage(playerid, COLOR_NEWS, brondef);
		        }
		        ResetPlayerWeapons(playerid);
				PrzywrocBron(playerid);
	            SchowajBron(playerid);
			}
			if(!response)
			{
	            new dom = PlayerInfo[playerid][pDom];
		        if(strlen(inputtext) >= 1 && strlen(inputtext) <= 6 && strval(inputtext) >= 1 && strval(inputtext) <= 100000)
		        {
		            new brondef[512];
		            if(IDBroniZbrojownia[playerid] == 2)
			        {
	                    if(strval(inputtext) < PlayerInfo[playerid][pAmmo2])
			            {
			                PlayerInfo[playerid][pAmmo2] -= strval(inputtext);
			                Dom[dom][hS_A2] += strval(inputtext);
			                format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %d naboi do %s", Dom[dom][hS_A2], GunNames[Dom[dom][hS_G2]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz przy sobie tyle naboi lub pr�bujesz schowa� wszystkie. Aby schowa� wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G2]], PlayerInfo[playerid][pGun2]);
	   						ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        if(IDBroniZbrojownia[playerid] == 3)
			        {
	                    if(strval(inputtext) < PlayerInfo[playerid][pAmmo3])
			            {
			                PlayerInfo[playerid][pAmmo3] -= strval(inputtext);
			                Dom[dom][hS_A3] += strval(inputtext);
			                format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %d naboi do %s", Dom[dom][hS_A3], GunNames[Dom[dom][hS_G3]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz przy sobie tyle naboi lub pr�bujesz schowa� wszystkie. Aby schowa� wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G3]], PlayerInfo[playerid][pGun3]);
	   						ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        if(IDBroniZbrojownia[playerid] == 4)
			        {
	                    if(strval(inputtext) < PlayerInfo[playerid][pAmmo4])
			            {
			                PlayerInfo[playerid][pAmmo4] -= strval(inputtext);
			                Dom[dom][hS_A4] += strval(inputtext);
			                format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %d naboi do %s", Dom[dom][hS_A4], GunNames[Dom[dom][hS_G4]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz przy sobie tyle naboi lub pr�bujesz schowa� wszystkie. Aby schowa� wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G4]], PlayerInfo[playerid][pGun4]);
	   						ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        if(IDBroniZbrojownia[playerid] == 5)
			        {
	                    if(strval(inputtext) < PlayerInfo[playerid][pAmmo5])
			            {
			                PlayerInfo[playerid][pAmmo5] -= strval(inputtext);
			                Dom[dom][hS_A5] += strval(inputtext);
			                format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %d naboi do %s", Dom[dom][hS_A5], GunNames[Dom[dom][hS_G5]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz przy sobie tyle naboi lub pr�bujesz schowa� wszystkie. Aby schowa� wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G5]], PlayerInfo[playerid][pGun5]);
	   						ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        if(IDBroniZbrojownia[playerid] == 6)
			        {
	                    if(strval(inputtext) < PlayerInfo[playerid][pAmmo6])
			            {
			                PlayerInfo[playerid][pAmmo6] -= strval(inputtext);
			                Dom[dom][hS_A6] += strval(inputtext);
			                format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %d naboi do %s", Dom[dom][hS_A6], GunNames[Dom[dom][hS_G6]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz przy sobie tyle naboi lub pr�bujesz schowa� wszystkie. Aby schowa� wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G6]], PlayerInfo[playerid][pGun6]);
	   						ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        if(IDBroniZbrojownia[playerid] == 7)
			        {
	                    if(strval(inputtext) < PlayerInfo[playerid][pAmmo7])
			            {
			                PlayerInfo[playerid][pAmmo7] -= strval(inputtext);
			                Dom[dom][hS_A7] += strval(inputtext);
			                format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %d naboi do %s", Dom[dom][hS_A7], GunNames[Dom[dom][hS_G7]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz przy sobie tyle naboi lub pr�bujesz schowa� wszystkie. Aby schowa� wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G7]], PlayerInfo[playerid][pGun7]);
	   						ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        if(IDBroniZbrojownia[playerid] == 8)
			        {
	                    if(strval(inputtext) < PlayerInfo[playerid][pAmmo8])
			            {
			                PlayerInfo[playerid][pAmmo8] -= strval(inputtext);
			                Dom[dom][hS_A8] += strval(inputtext);
			                format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %d naboi do %s", Dom[dom][hS_A8], GunNames[Dom[dom][hS_G8]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz przy sobie tyle naboi lub pr�bujesz schowa� wszystkie. Aby schowa� wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G8]], PlayerInfo[playerid][pGun8]);
	   						ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        if(IDBroniZbrojownia[playerid] == 9)
			        {
	                    if(strval(inputtext) < PlayerInfo[playerid][pAmmo9])
			            {
			                PlayerInfo[playerid][pAmmo9] -= strval(inputtext);
			                Dom[dom][hS_A9] += strval(inputtext);
			                format(brondef, sizeof(brondef), "W zbrojowni znajduje si� teraz %d naboi do %s", Dom[dom][hS_A9], GunNames[Dom[dom][hS_G9]]);
	            			SendClientMessage(playerid, COLOR_NEWS, brondef);
			            }
			            else
			            {
			                SendClientMessage(playerid, COLOR_NEWS, "Nie masz przy sobie tyle naboi lub pr�bujesz schowa� wszystkie. Aby schowa� wszystkie naboje kliknij 'Wszystko'");
							format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G9]], PlayerInfo[playerid][pGun9]);
	   						ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
			            	return 1;
			            }
			        }
			        ResetPlayerWeapons(playerid);
					PrzywrocBron(playerid);
		            SchowajBron(playerid);
				}
				else
				{
				    new brondef[512];
				    if(IDBroniZbrojownia[playerid] == 2)
				    {
				    	format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G2]], PlayerInfo[playerid][pGun2]);
				    }
				    if(IDBroniZbrojownia[playerid] == 3)
				    {
				    	format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G3]], PlayerInfo[playerid][pGun3]);
				    }
				    if(IDBroniZbrojownia[playerid] == 4)
				    {
				    	format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G4]], PlayerInfo[playerid][pGun4]);
				    }
				    if(IDBroniZbrojownia[playerid] == 5)
				    {
				    	format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G5]], PlayerInfo[playerid][pGun5]);
				    }
				    if(IDBroniZbrojownia[playerid] == 6)
				    {
				    	format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G6]], PlayerInfo[playerid][pGun6]);
				    }
				    if(IDBroniZbrojownia[playerid] == 7)
				    {
				    	format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G7]], PlayerInfo[playerid][pGun7]);
				    }
				    if(IDBroniZbrojownia[playerid] == 8)
				    {
				    	format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G8]], PlayerInfo[playerid][pGun8]);
				    }
				    if(IDBroniZbrojownia[playerid] == 9)
				    {
				    	format(brondef, sizeof(brondef), "Masz t� sam� bro� przy sobie i w zbrojowni.\nMo�esz schowa� ca�� bro� z nabojami lub schowa� okre�lon� ilo�� naboi.\nJe�eli chcesz schowa� tylko naboje, wpisz ilo�� poni�ej i kliknij 'Naboje'\n\n\nBro�: %s\t\tAmunicja: %d", GunNames[Dom[dom][hS_G9]], PlayerInfo[playerid][pGun9]);
				    }
					ShowPlayerDialogEx(playerid, 8247, DIALOG_STYLE_INPUT, "Chowanie amunicji", brondef, "Wszystko", "Naboje");
				    SendClientMessage(playerid, COLOR_NEWS, "Ilo�� naboi od 1 do 100 000");
				}
			}
		}
		if(dialogid == 495)
		{
		    if(response)
		    {
                new lider = GetPlayerOrg(playerid);
		        switch(listitem)
		        {
		            case 0:
		            {
                        new stan[128];
                        format(stan, sizeof(stan), "{F8F8FF}Stan sejfu:\t\t{008000}%d$", Sejf_Rodziny[lider]);
		                ShowPlayerDialogEx(playerid, 496, DIALOG_STYLE_LIST, "Sejf rodzinny - stan", stan, "Wr��", "Wr��");
		            }
		            case 1:
		            {
		                new stan[128];
		                format(stan, sizeof(stan), "{F8F8FF}Stan sejfu:\t\t{008000}%d$", Sejf_Rodziny[lider]);
						ShowPlayerDialogEx(playerid, 497, DIALOG_STYLE_INPUT, "Sejf rodzinny - wyp�acanie", stan, "Wyp�a�", "Wr��");
		            }
		            case 2:
		            {
		                new stan[128];
		                format(stan, sizeof(stan), "{F8F8FF}Stan sejfu:\t\t{008000}%d$", Sejf_Rodziny[lider]);
						ShowPlayerDialogEx(playerid, 498, DIALOG_STYLE_INPUT, "Sejf rodzinny - wp�acanie", stan, "Wp�a�", "Wr��");
		            }
		        }
		    }
		}
		if(dialogid == 496)
		{
		    if(response || !response)
		    {
		        ShowPlayerDialogEx(playerid, 495, DIALOG_STYLE_LIST, "Sejf rodzinny", "Stan\nWyp�a�\nWp�a�", "Wybierz", "Wyjd�");
		    }
		}
		if(dialogid == 497)
		{
		    if(response)
		    {
                if(!IsNumeric(inputtext))
                {
                    SendClientMessage(playerid, -1, "To nie jest liczba!");
                    ShowPlayerDialogEx(playerid, 495, DIALOG_STYLE_LIST, "Sejf rodzinny", "Stan\nWyp�a�\nWp�a�", "Wybierz", "Wyjd�");
                    return 1;
                }
                new kasa = strval(inputtext);
                new lider = GetPlayerOrg(playerid);
		        if((strlen(inputtext) >= 1 && strlen(inputtext) <= 9) && kasa > 0 )
		        {
		            if(kasa <= Sejf_Rodziny[lider])
		            {
		                new nick[MAX_PLAYER_NAME];
		                GetPlayerName(playerid, nick, sizeof(nick));

                        SejfR_Add(lider, -kasa);
						PlayerInfo[playerid][pAccount] += kasa;

			            new komunikat[256];
			            format(komunikat, sizeof(komunikat), "Wyp�aci�e� %d$ z sejfu rodzinnego. Jest w nim teraz %d$. Wyp�acone pieni�dze s� teraz na twoim koncie bankowym.", kasa, Sejf_Rodziny[lider]);
			            SendClientMessage(playerid, COLOR_P@, komunikat);
			            format(komunikat, sizeof(komunikat), "Lider %s wyplacil %d$ z sejfu rodziny nr %d. Jest w nim teraz %d$", nick, kasa, lider, Sejf_Rodziny[lider]);
			            PayLog(komunikat);
                        SejfR_Save(lider);
						ShowPlayerDialogEx(playerid, 495, DIALOG_STYLE_LIST, "Sejf rodzinny", "Stan\nWyp�a�\nWp�a�", "Wybierz", "Wyjd�");
					}
					else
					{
	    				SendClientMessage(playerid, COLOR_P@, "W sejfie nie znajduje si� a� tyle");
					    new stan[256];
		             	format(stan, sizeof(stan), "{F8F8FF}Stan sejfu:\t{008000}%d$", Sejf_Rodziny[lider]);
						ShowPlayerDialogEx(playerid, 497, DIALOG_STYLE_INPUT, "Sejf rodzinny - wyp�acanie", stan, "Wyp�a�", "Wr��");
					}
				}
		        else
		        {
		            new stan[256];
	             	format(stan, sizeof(stan), "{F8F8FF}Stan sejfu:\t{008000}%d$", Sejf_Rodziny[lider]);
					ShowPlayerDialogEx(playerid, 497, DIALOG_STYLE_INPUT, "Sejf rodzinny - wyp�acanie", stan, "Wyp�a�", "Wr��");
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 495, DIALOG_STYLE_LIST, "Sejf rodzinny", "Stan\nWyp�a�\nWp�a�", "Wybierz", "Wyjd�");
		    }
		}
		if(dialogid == 498)
		{
		    if(response)
		    {
                if(!IsNumeric(inputtext))
                {
                    SendClientMessage(playerid, -1, "To nie jest liczba!");
                    ShowPlayerDialogEx(playerid, 495, DIALOG_STYLE_LIST, "Sejf rodzinny", "Stan\nWyp�a�\nWp�a�", "Wybierz", "Wyjd�");
                    return 1;
                }
                new kasa = strval(inputtext);
                new lider = GetPlayerOrg(playerid);
		        if((strlen(inputtext) >= 1 && strlen(inputtext) <= 9) && kasa > 0 )
		        {
		            if(kaska[playerid] >= kasa)
		            {
                        if(Sejf_Rodziny[lider] + kasa > 1_000_000_000)
                        {
                            SendClientMessage(playerid, -1, "Sejf si� przepe�ni!");
                            return 1;
                        }
		                new nick[MAX_PLAYER_NAME];
		                GetPlayerName(playerid, nick, sizeof(nick));

		                ZabierzKase(playerid, kasa);
                        SejfR_Add(lider, kasa);

			            new komunikat[256];
			            format(komunikat, sizeof(komunikat), "Wp�aci�e� %d$ do sejfu rodzinnego. Jest w nim teraz %d$.", kasa, Sejf_Rodziny[lider]);
			            SendClientMessage(playerid, COLOR_P@, komunikat);
			            format(komunikat, sizeof(komunikat), "Lider %s wplacil %d$ do sejfu rodziny nr %d. Jest w nim teraz %d$", nick, kasa, lider, Sejf_Rodziny[lider]);
			            PayLog(komunikat);
                        SejfR_Save(lider);
			            ShowPlayerDialogEx(playerid, 495, DIALOG_STYLE_LIST, "Sejf rodzinny", "Stan\nWyp�a�\nWp�a�", "Wybierz", "Wyjd�");
					}
					else
					{
					    SendClientMessage(playerid, COLOR_P@, "Nie masz a� tyle przy sobie !");
					    new stan[256];
		                format(stan, sizeof(stan), "{F8F8FF}Stan sejfu:\t{008000}%d$", Sejf_Rodziny[lider]);
						ShowPlayerDialogEx(playerid, 498, DIALOG_STYLE_INPUT, "Sejf rodzinny - wp�acanie", stan, "Wp�a�", "Wr��");
					}
				}
		        else
		        {
		            new stan[256];
	                format(stan, sizeof(stan), "{F8F8FF}Stan sejfu:\t{008000}%d$", Sejf_Rodziny[lider]);
					ShowPlayerDialogEx(playerid, 498, DIALOG_STYLE_INPUT, "Sejf rodzinny - wp�acanie", stan, "Wp�a�", "Wr��");
		        }
		    }
		    if(!response)
		    {
		        ShowPlayerDialogEx(playerid, 495, DIALOG_STYLE_LIST, "Sejf rodzinny", "Stan\nWyp�a�\nWp�a�", "Wybierz", "Wyjd�");
		    }
		}
        if(dialogid == 666)
		{
		    if(response)
		    {
		        new veh = GetPlayerVehicleID(playerid);
		        new dont_override = false;
		        new engine,lights,alarm,doors,bonnet,boot,objective;
		        GetVehicleParamsEx(veh,engine,lights,alarm,doors,bonnet,boot,objective);

		        new komunikat[256];

                if(strfind(inputtext, "�wiat�a") != -1)
                {
                    if(lights == VEHICLE_PARAMS_ON)
					{
						SetVehicleParamsEx(veh,engine,VEHICLE_PARAMS_OFF,alarm,doors,bonnet,boot,objective);
					}
					else
					{
						SetVehicleParamsEx(veh,engine,VEHICLE_PARAMS_ON,alarm,doors,bonnet,boot,objective);
					}
                }
                else if(strfind(inputtext, "Maska") != -1)
                {
                    if(bonnet == VEHICLE_PARAMS_ON)
					{
						SetVehicleParamsEx(veh,engine,lights,alarm,doors,VEHICLE_PARAMS_OFF,boot,objective);
					}
					else
					{
						SetVehicleParamsEx(veh,engine,lights,alarm,doors,VEHICLE_PARAMS_ON,boot,objective);
					}
                }
                else if(strfind(inputtext, "Baga�nik") != -1)
                {
                    if(boot == VEHICLE_PARAMS_ON)
			 		{
						SetVehicleParamsEx(veh,engine,lights,alarm,doors,bonnet,VEHICLE_PARAMS_OFF,objective);
					}
					else
					{
						SetVehicleParamsEx(veh,engine,lights,alarm,doors,bonnet,VEHICLE_PARAMS_ON,objective);
					}
                }
                else if(strfind(inputtext, "CB-Radio") != -1)
                {
                    if(!cbradijo[playerid])
                	{
                		cbradijo[playerid] = 1;
                		SendClientMessage(playerid, COLOR_WHITE, "   CB-radio wy��czone !");
                	}
                	else
                	{
                		cbradijo[playerid] = 0;
                		SendClientMessage(playerid,0xff00ff, "   CB-radio w��czone !");
                	}
                }
                else if(strfind(inputtext, "Neony") != -1)
                {
                    new sendername[MAX_PLAYER_NAME];
					GetPlayerName(playerid, sendername, sizeof(sendername));
				    if(VehicleUID[veh][vNeon])
					{
						DestroyDynamicObject(VehicleUID[veh][vNeonObject][0]);
			     		DestroyDynamicObject(VehicleUID[veh][vNeonObject][1]);
				        VehicleUID[veh][vNeon] = false;
				        format(komunikat, sizeof(komunikat), "* %s naciska przycisk i gasi neony.", sendername);
						ProxDetector(30.0, playerid, komunikat, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				    }
				    else
				    {
						if(PlayerInfo[playerid][pDonateRank] > 0)
			            {
							VehicleUID[veh][vNeonObject][0] = CreateDynamicObject(CarData[VehicleUID[veh][vUID]][c_Neon], 0.0,0.0,0.0, 0, 0, 0);
                            AttachDynamicObjectToVehicle(VehicleUID[veh][vNeonObject][0], veh, -0.8, 0.0, -0.5, 0.0, 0.0, 0.0);
				       		VehicleUID[veh][vNeonObject][1] = CreateDynamicObject(CarData[VehicleUID[veh][vUID]][c_Neon], 0.0,0.0,0.0, 0, 0, 0);
                            AttachDynamicObjectToVehicle(VehicleUID[veh][vNeonObject][1], veh, 0.8, 0.0, -0.5, 0.0, 0.0, 0.0);
						}
						else
						{
							VehicleUID[veh][vNeonObject][0] = CreateDynamicObject(18652, 0.0,0.0,0.0, 0, 0, 0);
                            AttachDynamicObjectToVehicle(VehicleUID[veh][vNeonObject][0], veh, -0.8, 0.0, -0.5, 0.0, 0.0, 0.0);
				       		VehicleUID[veh][vNeonObject][1] = CreateDynamicObject(18652, 0.0,0.0,0.0, 0, 0, 0);
                            AttachDynamicObjectToVehicle(VehicleUID[veh][vNeonObject][1], veh, 0.8, 0.0, -0.5, 0.0, 0.0, 0.0);
						}
                        VehicleUID[veh][vNeon] = true;
                        format(komunikat, sizeof(komunikat), "* %s naciska przycisk i w��cza neony.", sendername);
						ProxDetector(30.0, playerid, komunikat, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				    }
                }
				else if(strfind(inputtext, "Mrucznik Radio") != -1)
                {
					if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
					{
						foreach(new i : Player)
						{
							if(IsPlayerInVehicle(i, veh))
							{
								PlayAudioStreamForPlayer(i, "http://4stream.pl:18434");
								SetPVarInt(i, "sanlisten", 3);
							}
						}
					}
                }
                else if(strfind(inputtext, "Radio SAN1") != -1)
                {
                    if(RadioSANUno[0] != EOF)
                    {
                        if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
                        {
                            //new veh;
							veh = GetPlayerVehicleID(playerid);

                            foreach(new i : Player)
                            {
                                if(IsPlayerInVehicle(i, veh))
                                {
                                    PlayAudioStreamForPlayer(i, RadioSANUno);
                                    SetPVarInt(i, "sanlisten", 1);
                                }
                            }
                        }
                    }
                }
                else if(strfind(inputtext, "Radio SAN2") != -1)
                {
                    if(RadioSANDos[0] != EOF)
                    {
                        if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
                        {
                            foreach(new i : Player)
                            {
                                if(IsPlayerInVehicle(i, veh))
                                {
                                    PlayAudioStreamForPlayer(i, RadioSANDos);
                                    SetPVarInt(i, "sanlisten", 2);
                                }
                            }
                        }
                    }
                }
                else if(strfind(inputtext, "Wlasny Stream") != -1)
                {
                    if(!response) return 1;
                    dont_override = true;
                    if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
                    	ShowPlayerDialogEx(playerid, 670, DIALOG_STYLE_INPUT, "W�asny stream", "Wklej poni�ej link do streama", "Start", "Wr��");
                    }
                }
                else if(strfind(inputtext, "Wy��cz radio") != -1)
                {
                    if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
                    {
                        foreach(new i : Player)
                        {
                            if(IsPlayerInVehicle(i, veh))
                            {
                                StopAudioStreamForPlayer(i);
                                SetPVarInt(i, "sanlisten", 0);
                            }
                        }
                    }
                }
                //
			    new taknieL[64];
			    new taknieBON[64];
			    new taknieBOT[64];
			    GetVehicleParamsEx(veh,engine,lights,alarm,doors,bonnet,boot,objective);
                if(lights == 1) format(taknieL, sizeof(taknieL), "Wy��cz");
				else format(taknieL, sizeof(taknieL), "W��cz");
				if(bonnet == 1) format(taknieBON, sizeof(taknieBON), "Zamknij");
				else format(taknieBON, sizeof(taknieBON), "Otw�rz");
				if(boot == 1) format(taknieBOT, sizeof(taknieBOT), "Zamknij");
				else format(taknieBOT, sizeof(taknieBOT), "Otw�rz");
                //
                format(komunikat, sizeof(komunikat), "�wiat�a (%s)\nMaska (%s)\nBaga�nik (%s)", taknieL, taknieBON, taknieBOT);
                //
                if(PlayerInfo[playerid][pCB])
                {
                    new cbr[16];
                    if(cbradijo[playerid]) format(cbr, 16, "W��cz");
                    else format(cbr, 16, "Wy��cz");
                    format(komunikat, sizeof(komunikat), "%s\nCB-Radio (%s)", komunikat, cbr);
                }
                if(CarData[VehicleUID[veh][vUID]][c_Neon] != 0 || veh >= 475 && veh <= 483)
				{
				    new taknieNeo[16];
					if(VehicleUID[veh][vNeon]) format(taknieNeo, sizeof(taknieNeo), "Wy��cz");
					else format(taknieNeo, sizeof(taknieNeo), "W��cz");
                    format(komunikat, sizeof(komunikat), "%s\nNeony (%s)", komunikat, taknieNeo);
				}
                //
                format(komunikat, sizeof(komunikat), "%s\nMrucznik Radio\nRadio SAN1\nRadio SAN2\nWlasny Stream\nWy��cz radio", komunikat); //+ 35char
                //
                if(!dont_override) ShowPlayerDialogEx(playerid, 666, DIALOG_STYLE_LIST, "Deska rozdzielcza", komunikat, "Wybierz", "Anuluj");
		    }
		}
		else if(dialogid == 670) {
			if(response)
			{
				new veh = GetPlayerVehicleID(playerid);
				//if(IsAValidURL(inputtext))
				//{
				if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
					foreach(new i : Player) {
						if(IsPlayerInVehicle(i, veh)) {
							PlayAudioStreamForPlayer(i, inputtext);
						}
					}
					SetPVarString(playerid, "radioUrl", inputtext);
					SetPVarInt(playerid, "sanlisten", 3);
				}
				//}
			}
			return 1;
		}
        else if(dialogid == 667)
        {
            if(!response) return 1;
            SetPVarInt(playerid, "sanradio", listitem);
            ShowPlayerDialogEx(playerid, 669, DIALOG_STYLE_LIST, "Wybierz muzyk�", "Mrucznik Radio\nDisco polo\nDance100\nPrzeboje\nHip hop\nParty\nW�asna", "Wybierz", "Anuluj");

        }
        else if(dialogid == 669)
        {
            if(!response) return 1;
            if(GetPVarInt(playerid, "sanradio") == 0)
            {
                switch(listitem)
                {
                    case 0: format(RadioSANUno, sizeof(RadioSANUno), "http://4stream.pl:18434");
                    case 1: format(RadioSANUno, sizeof(RadioSANUno), "http://www.polskastacja.pl/play/aac_discopolo.pls");
                    case 2: format(RadioSANUno, sizeof(RadioSANUno), "http://www.polskastacja.pl/play/aac_dance100.pls");
                    case 3: format(RadioSANUno, sizeof(RadioSANUno), "http://www.polskastacja.pl/play/aac_mnt.pls");
                    case 4: format(RadioSANUno, sizeof(RadioSANUno), "http://www.polskastacja.pl/play/aac_hiphop.pls");
                    case 5: format(RadioSANUno, sizeof(RadioSANUno), "http://www.polskastacja.pl/play/aac_party.pls");
                    case 6: return ShowPlayerDialogEx(playerid, 668, DIALOG_STYLE_INPUT, "Podaj adres URL", "Prosz� wprowadzi� adres URL muzyki dla stacji SAN 01", "Wybierz", "Anuluj");
                }
                foreach(new i : Player)
                {
                    if(IsPlayerInAnyVehicle(i))
                    {
                        if(GetPVarInt(i, "sanlisten") == 1)
                        {
                            PlayAudioStreamForPlayer(i, RadioSANUno);
                        }
                    }
                }
            }
            else //sanradio == 1
            {
                switch(listitem)
                {
                    case 0: format(RadioSANDos, sizeof(RadioSANDos), "http://4stream.pl:18240");
                    case 1: format(RadioSANDos, sizeof(RadioSANDos), "http://www.polskastacja.pl/play/aac_discopolo.pls");
                    case 2: format(RadioSANDos, sizeof(RadioSANDos), "http://www.polskastacja.pl/play/aac_dance100.pls");
                    case 3: format(RadioSANDos, sizeof(RadioSANDos), "http://www.polskastacja.pl/play/aac_mnt.pls");
                    case 4: format(RadioSANDos, sizeof(RadioSANDos), "http://www.polskastacja.pl/play/aac_hiphop.pls");
                    case 5: format(RadioSANDos, sizeof(RadioSANDos), "http://www.polskastacja.pl/play/aac_party.pls");
                    case 6: return ShowPlayerDialogEx(playerid, 668, DIALOG_STYLE_INPUT, "Podaj adres URL", "Prosz� wprowadzi� adres URL muzyki dla stacji SAN 02", "Wybierz", "Anuluj");
                }
                foreach(new i : Player)
                {
                    if(IsPlayerInAnyVehicle(i))
                    {
                        if(GetPVarInt(i, "sanlisten") == 2)
                        {
                            PlayAudioStreamForPlayer(i, RadioSANDos);
                        }
                    }
                }
            }
            SendClientMessage(playerid, COLOR_GRAD2, " Zmieni�e� nadawan� stacj�.");
        }
        if(dialogid == 668)
        {
            if(!response) return 1;
            new radio = GetPVarInt(playerid, "sanradio");
            if(!radio)
            {
                format(RadioSANUno, 128, "%s", inputtext);
                foreach(new i : Player)
                {
                    if(IsPlayerInAnyVehicle(i))
                    {
                        if(GetPVarInt(i, "sanlisten") == 1)
                        {
                            PlayAudioStreamForPlayer(i, RadioSANUno);
                        }
                    }
                }

            }
            else
            {
                format(RadioSANDos, 128, "%s", inputtext);
                foreach(new i : Player)
                {
                    if(IsPlayerInAnyVehicle(i))
                    {
                        if(GetPVarInt(i, "sanlisten") == 2)
                        {
                            PlayAudioStreamForPlayer(i, RadioSANDos);
                        }
                    }
                }
            }
            SendClientMessage(playerid, COLOR_GRAD2, " Zmieni�e� nadawan� stacj�.");
        }
		if(dialogid == 765)
		{
		    if(response)
		    {
		        switch(listitem)
		        {
                    case 0: format(SANrepertuar, sizeof(SANrepertuar), "http://s1.slotex.pl:7170");
                    case 1: format(SANrepertuar, sizeof(SANrepertuar), "http://4stream.pl:18240");
		            case 2: format(SANrepertuar, sizeof(SANrepertuar), "http://www.polskastacja.pl/play/aac_discopolo.pls");
                    case 3: format(SANrepertuar, sizeof(SANrepertuar), "http://www.polskastacja.pl/play/aac_dance100.pls");
                    case 4: format(SANrepertuar, sizeof(SANrepertuar), "http://www.polskastacja.pl/play/aac_mnt.pls");
                    case 5: format(SANrepertuar, sizeof(SANrepertuar), "http://www.polskastacja.pl/play/aac_hiphop.pls");
                    case 6: format(SANrepertuar, sizeof(SANrepertuar), "http://www.polskastacja.pl/play/aac_party.pls");
                    case 7: return ShowPlayerDialogEx(playerid, 767, DIALOG_STYLE_INPUT, "Podaj adres URL", "Prosz� wprowadzi� adres URL do wybranego utworu", "Wybierz", "Anuluj");
		        }
                ShowPlayerDialogEx(playerid, 766, DIALOG_STYLE_LIST, "Wybierz zasi�g", "Bardzo ma�y zasi�g\nMa�y zasi�g\n�redni zasi�g\nDu�y zasi�g", "Wybierz", "Anuluj");
		    }
		}
        if(dialogid == 766)
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0: SANzasieg = 10.0;
                    case 1: SANzasieg = 20.0;
                    case 2: SANzasieg = 35.0;
                    case 3: SANzasieg = 50.0;
				}
                new Float:x1,Float:y1,Float:z1, Float:a1, nick[MAX_PLAYER_NAME], string[256];
				GetPlayerPos(playerid,x1,y1,z1);
				GetPlayerFacingAngle(playerid, a1);
				GetPlayerName(playerid, nick, sizeof(nick));
				SANradio = CreateDynamicObject(2232, x1, y1, z1-0.3, 0, 0, a1-180);
				SANx = x1;
				SANy = y1;
				SANz = z1;
                SAN3d = CreateDynamic3DTextLabel("G�o�nik SAN", COLOR_NEWS, x1, y1, z1+0.5, 10.5, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1);
				format(string, sizeof(string), "* %s stawia g�o�nik na ziemi i w��cza.", nick);
				ProxDetector(10.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SendClientMessage(playerid, COLOR_NEWS, "Ustawi�e� g�o�nik SAN. Aby go wy��czy� wpisz /glosnik");
                //
                foreach(new i : Player)
                {
                    if(IsPlayerConnected(i))
                    {
                        if(!GetPVarInt(i, "sanaudio"))
                        {
                            if(PlayerToPoint(SANzasieg, i, SANx, SANy, SANz))
                            {
                                PlayAudioStreamForPlayer(i, SANrepertuar, SANx, SANy, SANz, SANzasieg, 1);
                                SetPVarInt(i, "sanaudio", 1);
                            }
                        }
                    }
                }
                //
			}
		}
		else if(dialogid == 767)
        {
            if(!response) return 1;
            format(SANrepertuar, 128, inputtext);
            ShowPlayerDialogEx(playerid, 766, DIALOG_STYLE_LIST, "Wybierz zasi�g", "Bardzo ma�y zasi�g\nMa�y zasi�g\n�redni zasi�g\nDu�y zasi�g", "Wybierz", "Anuluj");
        }
        else if(dialogid == 1401)
		{
		    if(response)
		    {
		        new string[256];
		        switch(listitem)
		        {
		            case 0://Bia�y
		            {
						format(string, sizeof(string), "Bia�e neony zosta�y zamontowane w twoim %s. Koszt: 3 500 000$. Aby je w��czy� wpisz /dr", VehicleNames[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
						SendClientMessage(playerid, COLOR_WHITE, string);
                        CarData[IloscAut[playerid]][c_Neon] = 18652;
                        PlayerPlaySound(playerid, 1141, 0.0, 0.0, 0.0);
                        DajKase(playerid, -3500000);
		            }
		            case 1://��ty
		            {
						format(string, sizeof(string), "��te neony zosta�y zamontowane w twoim %s. Koszt: 3 500 000$. Aby je w��czy� wpisz /dr", VehicleNames[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
						SendClientMessage(playerid, 0xDAA520FF, string);
                        CarData[IloscAut[playerid]][c_Neon] = 18650;
                        PlayerPlaySound(playerid, 1141, 0.0, 0.0, 0.0);
                        DajKase(playerid, -3500000);
		            }
		            case 2://Zielony
		            {
						format(string, sizeof(string), "Zielone neony zosta�y zamontowane w twoim %s. Koszt: 3 500 000$. Aby je w��czy� wpisz /dr", VehicleNames[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
						SendClientMessage(playerid, COLOR_LIGHTGREEN, string);
                        CarData[IloscAut[playerid]][c_Neon] = 18649;
                        PlayerPlaySound(playerid, 1141, 0.0, 0.0, 0.0);
                        DajKase(playerid, -3500000);
		            }
		            case 3://Niebieski
		            {

						format(string, sizeof(string), "Niebieskie neony zosta�y zamontowane w twoim %s. Koszt: 3 500 000$. Aby je w��czy� wpisz /dr", VehicleNames[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
                        CarData[IloscAut[playerid]][c_Neon] = 18648;
                        PlayerPlaySound(playerid, 1141, 0.0, 0.0, 0.0);
                        DajKase(playerid, -3500000);

		            }
		            case 4://Czerwony
		            {

						format(string, sizeof(string), "Czerwone neony zosta�y zamontowane w twoim %s. Koszt: 3 500 000$. Aby je w��czy� wpisz /dr", VehicleNames[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
						SendClientMessage(playerid, COLOR_RED, string);
                        CarData[IloscAut[playerid]][c_Neon] = 18647;
                        PlayerPlaySound(playerid, 1141, 0.0, 0.0, 0.0);
                        DajKase(playerid, -3500000);

		            }
		            case 5://R�owy
		            {
						format(string, sizeof(string), "R�owe neony zosta�y zamontowane w twoim %s. Koszt: 3 500 000$. Aby je w��czy� wpisz /dr", VehicleNames[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
						SendClientMessage(playerid, COLOR_PURPLE, string);
                        CarData[IloscAut[playerid]][c_Neon] = 18651;
                        PlayerPlaySound(playerid, 1141, 0.0, 0.0, 0.0);
                        DajKase(playerid, -3500000);
		            }
		        }
                Car_Save(IloscAut[playerid], CAR_SAVE_TUNE);
		    }
		}
		else if(dialogid == 1403)
		{
		    if(response)
		    {
				new string[128];
		        switch(listitem)
		        {
					
		            case 0:
		            {
						if(GetPlayerMoney(playerid) >= onePoolPrice)
						{
							format(string, sizeof(string), "Pani Janina m�wi: Oto pakiet 50 kredyt�w za jedyne %d$.", onePoolPrice);
							SendClientMessage(playerid, COLOR_WHITE, string);
							Kredyty[playerid] += 50;
							ZabierzKase(playerid, onePoolPrice);
							SejfR_Add(43, onePoolPrice);
							SejfR_Save(43);
							poolCashStats = poolCashStats+onePoolPrice;
							poolCreditStatus = poolCreditStatus+50;
						}
						else
						{
							sendErrorMessage(playerid, "Nie masz wystarczaj�cej ilo�ci got�wki!"); 
							return 1;
						}
		            }
		            case 1:
		            {
						if(GetPlayerMoney(playerid) >= twoPoolPrice)
						{
							format(string, sizeof(string), "Pani Janina m�wi: Oto pakiet 100 kredyt�w za jedyne %d$.", twoPoolPrice);
							SendClientMessage(playerid, COLOR_WHITE, string);
							Kredyty[playerid] += 100;
							ZabierzKase(playerid, twoPoolPrice); 
							SejfR_Add(43, twoPoolPrice);
							SejfR_Save(43);
							poolCreditStatus = poolCreditStatus+100;
							poolCashStats = poolCashStats+twoPoolPrice;
						}
						else
						{
							sendErrorMessage(playerid, "Nie masz wystarczaj�cej ilo�ci got�wki!"); 
							return 1;
						}
		            }
		            case 2://Zielony
		            {
						if(GetPlayerMoney(playerid) >= threePoolPrice)
						{
							format(string, sizeof(string), "Pani Janina m�wi: Oto pakiet 250 kredyt�w za jedyne %d$.", threePoolPrice);
							SendClientMessage(playerid, COLOR_WHITE, string);
							Kredyty[playerid] += 250;
							ZabierzKase(playerid, threePoolPrice);
							SejfR_Add(43, threePoolPrice);
							SejfR_Save(43);
							poolCreditStatus = poolCreditStatus+250;
							poolCashStats = poolCashStats+threePoolPrice;
						}
						else
						{
							sendErrorMessage(playerid, "Nie masz wystarczaj�cej ilo�ci got�wki!"); 
							return 1;
						}
		            }
		            case 3://Niebieski
		            {
						if(GetPlayerMoney(playerid) >= fourPoolPrice)
						{
							format(string, sizeof(string), "Pani Janina m�wi: Oto pakiet 500 kredyt�w za jedyne %d$.", fourPoolPrice);
							SendClientMessage(playerid, COLOR_WHITE, string);
							Kredyty[playerid] += 500;
							ZabierzKase(playerid, fourPoolPrice);
							SejfR_Add(43, fourPoolPrice);
							SejfR_Save(43);
							poolCreditStatus = poolCreditStatus+500;
							poolCashStats = poolCashStats+fourPoolPrice;
						}
						else
						{
							sendErrorMessage(playerid, "Nie masz wystarczaj�cej ilo�ci got�wki!"); 
							return 1;
						}
		            }
		        }
				return 1;
		    }
		}
		else if(dialogid == 1093)//panel lidera basenu
		{
			if(response)
			{
				new string[128];
				switch(listitem)
				{
					case 0://Otw�rz/zamknij basen
					{
						if(poolStatus == 0)
						{
							poolStatus = 1;
							sendTipMessage(playerid, "Otworzy�e� basen Tsunami");
							format(string, sizeof(string), "%s otworzy� basen.", GetNick(playerid, true));
							SendNewFamilyMessage(43, TEAM_BLUE_COLOR, string);
						}
						else
						{
							poolStatus = 0;
							sendTipMessage(playerid, "Zamkn��e� basen Tsunami");
							format(string, sizeof(string), "%s zamkn�� basen - Koniec p�ywania!", GetNick(playerid, true));
							SendNewFamilyMessage(43, TEAM_BLUE_COLOR, string);
						
						}
					}
					case 1://Zmie� cen� kredytu
					{
						ShowPlayerDialogEx(playerid, 1096, DIALOG_STYLE_LIST, "Mrucznik Role Play - Basen Tsunami", "1. Dzieci�cy\n2. Podstawowy\n3.Zaawansowany\n4.Premium", "Akceptuj", "Wr��"); 
					}
					case 2://Ustal muzyk�
					{
						sendTipMessage(playerid, "Ju� nied�ugo!"); 
					}
					case 3://Wy�lij wiadomo��
					{
						format(string, sizeof(string), "%s u�y� komunikatu basenu", GetNick(playerid, true));
						SendAdminMessage(COLOR_RED, string); //Wiadomo�� dla @
						SendClientMessageToAll(COLOR_WHITE, "|___________ Basen Tsunami ___________|");
						format(string, sizeof(string), "Plusk Plusk - Basen Tsunami otwarty! Zapraszamy do najlepszego obiektu rekreacyjnego w mie�cie!");
						SendClientMessageToAll(COLOR_BLUE, string);
					}
				}
				return 1;
			}
		}
		else if(dialogid == 1095)//pusty dialog basenu - statystyk
		{
			if(response)
			{
				sendTipMessage(playerid, "Nie za dobrze wygl�daj� te statystki! Popraw je!");
				return 1;
			}
		}
		else if(dialogid == 1096)
		{
			if(response)
			{
				new string[128];
				switch(listitem)
				{
					case 0:
					{
						format(string, sizeof(string), "{C0C0C0}Wpisz poni�ej now� kwot� dla pakietu {00FFFF}dzieci�cego\n{C0C0C0}Aktualna cena to: {37AC45}%d$", onePoolPrice);
						ShowPlayerDialogEx(playerid, 1097, DIALOG_STYLE_INPUT, "Mrucznik Role Play - Basen Tsunami", string, "Akceptuj", "Odrzu�"); 
						SetPVarInt(playerid, "wyborPoziomuKredytow", 1);
					}
					case 1:
					{	
						format(string, sizeof(string), "{C0C0C0}Wpisz poni�ej now� kwot� dla pakietu {00FFFF}dzieci�cego\n{C0C0C0}Aktualna cena to: {37AC45}%d$", twoPoolPrice);
						ShowPlayerDialogEx(playerid, 1097, DIALOG_STYLE_INPUT, "Mrucznik Role Play - Basen Tsunami", string, "Akceptuj", "Odrzu�"); 
						SetPVarInt(playerid, "wyborPoziomuKredytow", 2);
					}
					case 2:
					{
						format(string, sizeof(string), "{C0C0C0}Wpisz poni�ej now� kwot� dla pakietu {00FFFF}dzieci�cego\n{C0C0C0}Aktualna cena to: {37AC45}%d$", threePoolPrice);
						ShowPlayerDialogEx(playerid, 1097, DIALOG_STYLE_INPUT, "Mrucznik Role Play - Basen Tsunami", string, "Akceptuj", "Odrzu�"); 
						SetPVarInt(playerid, "wyborPoziomuKredytow", 3);
					}
					case 3:
					{
						
						format(string, sizeof(string), "{C0C0C0}Wpisz poni�ej now� kwot� dla pakietu {00FFFF}dzieci�cego\n{C0C0C0}Aktualna cena to: {37AC45}%d$", fourPoolPrice);
						ShowPlayerDialogEx(playerid, 1097, DIALOG_STYLE_INPUT, "Mrucznik Role Play - Basen Tsunami", string, "Akceptuj", "Odrzu�"); 
						SetPVarInt(playerid, "wyborPoziomuKredytow", 4);
					}
				}
				return 1;
			}
		}
		else if(dialogid == 1097)
		{
			if(response)
			{
				new pricePool = FunkcjaK(inputtext);
				if(GetPVarInt(playerid, "wyborPoziomuKredytow") == 1)
				{
					if(pricePool <= 300000)
					{
						if(pricePool > 1)
						{
							onePoolPrice = pricePool;
							sendTipMessage(playerid, "Ustali�e� now� cen�!");
						}
						else
						{
							sendErrorMessage(playerid, "Cena musi by� wi�ksza ni� 1 dolar!"); 
							return 1;
						}
					}
					else
					{
						sendErrorMessage(playerid, "Przekroczy�e� maksymaln� kwot�!"); 
					}
					return 1;
				
				}
				if(GetPVarInt(playerid, "wyborPoziomuKredytow") == 2)
				{
					if(pricePool <= 450000)
					{
						if(pricePool > 1)
						{
							twoPoolPrice = pricePool;
							sendTipMessage(playerid, "Ustali�e� now� cen�!");
						}
						else
						{
							sendErrorMessage(playerid, "Kwota musi by� wi�ksza ni� 1 dolar!");
							return 1;
						}
					}
					else
					{
						sendErrorMessage(playerid, "Przekroczy�e� maksymaln� kwot�!"); 
					}
					return 1;
				}
				if(GetPVarInt(playerid, "wyborPoziomuKredytow") == 3)
				{
					if(pricePool <= 600000)
					{
						if(pricePool > 1)
						{
							threePoolPrice = pricePool;
							sendTipMessage(playerid, "Ustali�e� now� cen�!");
						}
						else
						{
							sendErrorMessage(playerid, "Kwota musi by� wi�ksza ni� 1 dolar!"); 
							return 1;
						}
					}
					else
					{
						sendErrorMessage(playerid, "Przekroczy�e� maksymaln� kwot�!"); 
					}		
					return 1;
				}
				if(GetPVarInt(playerid, "wyborPoziomuKredytow") == 4)
				{
					if(pricePool <= 1000000)
					{
						if(pricePool > 1)
						{
							fourPoolPrice = pricePool;
							sendTipMessage(playerid, "Ustali�e� now� cen�!");
						}
						else
						{
							sendErrorMessage(playerid, "Kwota musi by� wi�ksza ni� 1 dolar!"); 
							return 1;
						}
					}
					else
					{
						sendErrorMessage(playerid, "Przekroczy�es maksymaln� kwot�!"); 
					}
					return 1;
				}
			}
		
		}
		else if(dialogid == 1402)//rupxnup
		{
            if(response || !response)
		    {
		        new string[256];
		        switch(listitem)
		        {
		            case 0://Bia�y
		            {
						format(string, sizeof(string), "Bia�e neony zosta�y zamontowane w twoim %s. Aby je w��czy� wpisz /dr", VehicleNames[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
						SendClientMessage(playerid, COLOR_WHITE, string);
                        CarData[IloscAut[playerid]][c_Neon] = 18652;
                        PlayerPlaySound(playerid, 1141, 0.0, 0.0, 0.0);
		            }
		            case 1://��ty
		            {
						format(string, sizeof(string), "��te neony zosta�y zamontowane w twoim %s. Aby je w��czy� wpisz /dr", VehicleNames[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
						SendClientMessage(playerid, 0xDAA520FF, string);
                        CarData[IloscAut[playerid]][c_Neon] = 18650;
                        PlayerPlaySound(playerid, 1141, 0.0, 0.0, 0.0);
		            }
		            case 2://Zielony
		            {
						format(string, sizeof(string), "Zielone neony zosta�y zamontowane w twoim %s. Aby je w��czy� wpisz /dr", VehicleNames[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
						SendClientMessage(playerid, COLOR_LIGHTGREEN, string);
                        CarData[IloscAut[playerid]][c_Neon] = 18649;
                        PlayerPlaySound(playerid, 1141, 0.0, 0.0, 0.0);
		            }
		            case 3://Niebieski
		            {

						format(string, sizeof(string), "Niebieskie neony zosta�y zamontowane w twoim %s. Aby je w��czy� wpisz /dr", VehicleNames[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
                        CarData[IloscAut[playerid]][c_Neon] = 18648;
                        PlayerPlaySound(playerid, 1141, 0.0, 0.0, 0.0);
		            }
		            case 4://Czerwony
		            {

						format(string, sizeof(string), "Czerwone neony zosta�y zamontowane w twoim %s. Aby je w��czy� wpisz /dr", VehicleNames[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
						SendClientMessage(playerid, COLOR_RED, string);
                        CarData[IloscAut[playerid]][c_Neon] = 18647;
                        PlayerPlaySound(playerid, 1141, 0.0, 0.0, 0.0);
		            }
		            case 5://R�owy
		            {
						format(string, sizeof(string), "R�owe neony zosta�y zamontowane w twoim %s. Aby je w��czy� wpisz /dr", VehicleNames[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
						SendClientMessage(playerid, COLOR_PURPLE, string);
                        CarData[IloscAut[playerid]][c_Neon] = 18651;
                        PlayerPlaySound(playerid, 1141, 0.0, 0.0, 0.0);
		            }
		        }
                Car_Save(IloscAut[playerid], CAR_SAVE_TUNE);
		    }
		}
		else if(dialogid == 1410)//Panel tras
		{
		    if(response)
		    {
				new string[256];
		        switch(listitem)
				{
				    case 0://Poka� trasy
				    {
						ShowPlayerDialogEx(playerid, 1411, DIALOG_STYLE_LIST, "Wszystkie trasy:", ListaWyscigow(), "Wi�cej", "Wyjd�");
				    }
				    case 1://Zorganizuj wy�cig
				    {
						new ow = IsAWyscigOrganizowany();
						if(ow == -1)
						{
							if(Scigamy == 666)
							{
								ShowPlayerDialogEx(playerid, 1412, DIALOG_STYLE_LIST, "Organizowanie wy�cigu. Dost�pne trasy:", ListaWyscigow(), "Zorganizuj", "Wr��");
							}
							else
							{
								format(string, sizeof(string), "Obecnie wy�cig %s jest zorganizowany. Poczekaj a� si� sko�czy.", Wyscig[Scigamy][wNazwa]);
								SendClientMessage(playerid, COLOR_GREY, string);
							}
						}
						else
						{
							format(string, sizeof(string), "Gracz %s organizuje wy�cig. Poczekaj a� sko�czy.", GetNick(ow));
							SendClientMessage(playerid, COLOR_GREY, string);
						}
				    }
				    case 2://Edytuj tras�
				    {
						new ow = IsAWyscigOrganizowany();
						if(ow == -1)
						{
							if(Scigamy == 666)
							{
								ShowPlayerDialogEx(playerid, 1413, DIALOG_STYLE_LIST, "Edytowanie. Dost�pne trasy:", ListaWyscigow(), "Edytuj", "Wr��");
							}
							else
							{
								format(string, sizeof(string), "Obecnie wy�cig %s jest zorganizowany. Poczekaj a� si� sko�czy.", Wyscig[Scigamy][wNazwa]);
								SendClientMessage(playerid, COLOR_GREY, string);
							}
						}
						else
						{
							format(string, sizeof(string), "Gracz %s organizuje wy�cig. Poczekaj a� sko�czy.", GetNick(ow));
							SendClientMessage(playerid, COLOR_GREY, string);
						}
				    }
				    case 3://Usu� tras�
				    {
						new ow = IsAWyscigOrganizowany();
						if(ow == -1)
						{
							if(Scigamy == 666)
							{
								ShowPlayerDialogEx(playerid, 1414, DIALOG_STYLE_LIST, "Usuwanie. Dost�pne trasy:", ListaWyscigow(), "Usu�", "Wr��");
							}
							else
							{
								format(string, sizeof(string), "Obecnie wy�cig %s jest zorganizowany. Poczekaj a� si� sko�czy.", Wyscig[Scigamy][wNazwa]);
								SendClientMessage(playerid, COLOR_GREY, string);
							}
						}
						else
						{
							format(string, sizeof(string), "Gracz %s organizuje wy�cig. Poczekaj a� sko�czy.", GetNick(ow));
							SendClientMessage(playerid, COLOR_GREY, string);
						}
				    }
				}
				return 1;
		    }
		}
		if(dialogid == 1411)//Poka� trasy. Wi�cej informacji
		{
			if(response)
			{
			    if(Wyscig[listitem][wStworzony] == 1)
			    {
				    new komunikat[1024];
					new wklej[256];
					if(Wyscig[listitem][wTypCH] == 0)
					{
						strcat(wklej, "{7CFC00}Typ checkpoint�w:{FFFFFF} Normalne\n");
					}
					else
					{
	    				strcat(wklej, "{7CFC00}Typ checkpoint�w:{FFFFFF} Ko�a\n");
					}
					if(Wyscig[listitem][wRozmiarCH] == 10.0)
					{
						strcat(wklej, "{7CFC00}Rozmiar checkpoint�w:{FFFFFF} Ogromne\n");
					}
					else if(Wyscig[listitem][wRozmiarCH] == 7.5)
					{
						strcat(wklej, "{7CFC00}Rozmiar checkpoint�w:{FFFFFF} Du�e\n");
					}
					else if(Wyscig[listitem][wRozmiarCH] == 5)
					{
	    				strcat(wklej, "{7CFC00}Rozmiar checkpoint�w:{FFFFFF} �rednie\n");
					}
					else if(Wyscig[listitem][wRozmiarCH] == 2.5)
					{
						strcat(wklej, "{7CFC00}Rozmiar checkpoint�w:{FFFFFF} Ma�e\n");
					}
					else if(Wyscig[listitem][wRozmiarCH] == 1)
					{
	    				strcat(wklej, "{7CFC00}Rozmiar checkpoint�w:{FFFFFF} Mini\n");
					}
	   				format(komunikat, sizeof(komunikat), "{7CFC00}Nazwa:{FFFFFF} %s\n{7CFC00}Opis:{FFFFFF} %s\n{7CFC00}Nagroda:{FFFFFF} %d$\n%s\n{7CFC00}Ilo�� checkpoint�w:{FFFFFF} %d\n{7CFC00}Rekord toru:{FFFFFF} %s - %d:%d", Wyscig[listitem][wNazwa], Wyscig[listitem][wOpis], Wyscig[listitem][wNagroda], wklej, Wyscig[listitem][wCheckpointy]+1, Wyscig[listitem][wRekordNick], Wyscig[listitem][wRekordCzas]);
	    			ShowPlayerDialogEx(playerid, 1415, DIALOG_STYLE_MSGBOX, "{7CFC00}Informacje o wy�cigu{FFFFFF}", komunikat, "Wr��", "");
	    		}
	    		else
	    		{
					SendClientMessage(playerid, COLOR_GREY, "Ta trasa nie zosta�a jeszcze stworzona!");
					ShowPlayerDialogEx(playerid, 1411, DIALOG_STYLE_LIST, "Wszystkie trasy:", ListaWyscigow(), "Wi�cej", "Wyjd�");
	    		}
				return 1;
			}
			if(!response)
			{
				if(IsANoA(playerid))
 				{
 				    if(PlayerInfo[playerid][pRank] >= 4)
 				    {
						ShowPlayerDialogEx(playerid, 1410, DIALOG_STYLE_LIST, "Panel wy�cig�w: Wybierz opcj�", "Poka� trasy\nZorganizuj wy�cig\nEdytuj tras�\nUsu� tras�", "Wybierz", "Anuluj");
					}
					else
					{
					    ShowPlayerDialogEx(playerid, 1410, DIALOG_STYLE_LIST, "Panel wy�cig�w: Wybierz opcj�", "Poka� trasy\nZorganizuj wy�cig", "Wybierz", "Anuluj");
					}
 				}
				return 1;
			}
		}
		if(dialogid == 1412)//organizuj wy�cig
		{
		    if(response)
		    {
		        if(Wyscig[listitem][wStworzony] == 1)
			    {
			        new naglowek[64];
					format(naglowek, sizeof(naglowek), "Organizacja wy�cigu '%s'", Wyscig[listitem][wNazwa]);
		       		new komunikat[256];
		       		format(komunikat, sizeof(komunikat), "Aby zorganizowa� ten wyscig musisz ponie�� koszty:\nNagroda dla wygranego: {FF0000}%d${B0C4DE}\nKoszt postawienia checkpoint�w: {FF0000}%d${B0C4DE}\nRazem: {FF0000}%d${B0C4DE}\nJe�eli chcesz kontynuowa�, wci�nij \"Dalej\"", Wyscig[listitem][wNagroda], (Wyscig[listitem][wCheckpointy]+1)*2000, Wyscig[listitem][wNagroda]+((Wyscig[listitem][wCheckpointy]+1)*2000));
			        ShowPlayerDialogEx(playerid, 1416, DIALOG_STYLE_MSGBOX, naglowek, komunikat, "Dalej", "Wr��");
			        tworzenietrasy[playerid] = listitem;
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "Ta trasa nie zosta�a jeszcze stworzona!");
					ShowPlayerDialogEx(playerid, 1412, DIALOG_STYLE_LIST, "Organizowanie wy�cigu. Dost�pne trasy:", ListaWyscigow(), "Zorganizuj", "Wr��");
				}
				return 1;
		    }
		    if(!response)
		    {
		        if(IsANoA(playerid))
 				{
 				    if(PlayerInfo[playerid][pRank] >= 4)
 				    {
						ShowPlayerDialogEx(playerid, 1410, DIALOG_STYLE_LIST, "Panel wy�cig�w: Wybierz opcj�", "Poka� trasy\nZorganizuj wy�cig\nEdytuj tras�\nUsu� tras�", "Wybierz", "Anuluj");
					}
					else
					{
					    ShowPlayerDialogEx(playerid, 1410, DIALOG_STYLE_LIST, "Panel wy�cig�w: Wybierz opcj�", "Poka� trasy\nZorganizuj wy�cig", "Wybierz", "Anuluj");
					}
 				}
				return 1;
		    }
		}
		if(dialogid == 1413)//edytuj trase
		{
		    if(response)
		    {
		        if(Wyscig[listitem][wStworzony] == 1)
			    {
			        ShowPlayerDialogEx(playerid, 1430, DIALOG_STYLE_LIST, "Edycja trasy: Wybierz co chcesz edytowa�", "Nazw�\nOpis\nNagrod�", "Wybierz", "Anuluj");
			        tworzenietrasy[playerid] = listitem;
                }
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "Ta trasa nie zosta�a jeszcze stworzona!");
					ShowPlayerDialogEx(playerid, 1413, DIALOG_STYLE_LIST, "Edytowanie. Dost�pne trasy:", ListaWyscigow(), "Edytuj", "Wr��");
				}
				return 1;
			}
			if(!response)
		    {
                if(IsANoA(playerid))
 				{
 				    if(PlayerInfo[playerid][pRank] >= 4)
 				    {
						ShowPlayerDialogEx(playerid, 1410, DIALOG_STYLE_LIST, "Panel wy�cig�w: Wybierz opcj�", "Poka� trasy\nZorganizuj wy�cig\nEdytuj tras�\nUsu� tras�", "Wybierz", "Anuluj");
					}
					else
					{
					    ShowPlayerDialogEx(playerid, 1410, DIALOG_STYLE_LIST, "Panel wy�cig�w: Wybierz opcj�", "Poka� trasy\nZorganizuj wy�cig", "Wybierz", "Anuluj");
					}
 				}
				return 1;
			}
		}
		if(dialogid == 1414)//usu� trase
		{
		    if(response)
		    {
		        if(Wyscig[listitem][wStworzony] == 1)
			    {
			        new naglowek[64];
					format(naglowek, sizeof(naglowek), "Usuwanie wy�cigu '%s'", Wyscig[listitem][wNazwa]);
			        ShowPlayerDialogEx(playerid, 1417, DIALOG_STYLE_MSGBOX, naglowek, "{FF0000}UWAGA!{B0C4DE} Na pewno chcesz usun�� ten wy�cig?\nZostanie on bezpowrotnie zlikwidowany!\nNa pewno chcesz kontynuowa�?", "Usu�", "Wr��");
			        tworzenietrasy[playerid] = listitem;
                }
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "Ta trasa nie zosta�a jeszcze stworzona!");
					ShowPlayerDialogEx(playerid, 1414, DIALOG_STYLE_LIST, "Usuwanie. Dost�pne trasy:", ListaWyscigow(), "Usu�", "Wr��");
				}
				return 1;
		    }
		    if(!response)
		    {
		        if(IsANoA(playerid))
 				{
 				    if(PlayerInfo[playerid][pRank] >= 4)
 				    {
						ShowPlayerDialogEx(playerid, 1410, DIALOG_STYLE_LIST, "Panel wy�cig�w: Wybierz opcj�", "Poka� trasy\nZorganizuj wy�cig\nEdytuj tras�\nUsu� tras�", "Wybierz", "Anuluj");
					}
					else
					{
					    ShowPlayerDialogEx(playerid, 1410, DIALOG_STYLE_LIST, "Panel wy�cig�w: Wybierz opcj�", "Poka� trasy\nZorganizuj wy�cig", "Wybierz", "Anuluj");
					}
 				}
				return 1;
		    }
		}
		if(dialogid == 1415)//informacje o wy�cigu
		{
		    if(response || !response)
		    {
				ShowPlayerDialogEx(playerid, 1411, DIALOG_STYLE_LIST, "Wszystkie trasy:", ListaWyscigow(), "Wi�cej", "Wyjd�");
				return 1;
		    }
		}
		if(dialogid == 1416)//Akceptowanie organizowania
		{
		    if(response)
			{
				if(kaska[playerid] >= Wyscig[tworzenietrasy[playerid]][wNagroda] && Wyscig[tworzenietrasy[playerid]][wNagroda] > 0 && kaska[playerid] > 0)
				{
					new sendername[MAX_PLAYER_NAME];
					new komunikat[128];
					GetPlayerName(playerid, sendername, sizeof(sendername));
					format(komunikat, sizeof(komunikat), "Komunikat frakcyjny: {FFFFFF}%s zorganizowa� wy�cig %s", sendername, Wyscig[tworzenietrasy[playerid]][wNazwa]);
					SendFamilyMessage(15, COLOR_YELLOW, komunikat);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wy�cig zorganizowany! Udaj si� na start i zapro� osoby do wyscigu komend� /wyscig [id].");
					SetPlayerRaceCheckpoint(playerid,1,wCheckpoint[tworzenietrasy[playerid]][0][0], wCheckpoint[tworzenietrasy[playerid]][0][1], wCheckpoint[tworzenietrasy[playerid]][0][2],wCheckpoint[tworzenietrasy[playerid]][1][0], wCheckpoint[tworzenietrasy[playerid]][1][1], wCheckpoint[tworzenietrasy[playerid]][1][2], 10);
					ZabierzKase(playerid, (Wyscig[tworzenietrasy[playerid]][wCheckpointy]+1)*2000);
					Sejf_Add(FRAC_NOA, (Wyscig[tworzenietrasy[playerid]][wCheckpointy]+1)*2000);
					ZabierzKase(playerid, Wyscig[tworzenietrasy[playerid]][wNagroda]);
					owyscig[playerid] = tworzenietrasy[playerid];
					tworzenietrasy[playerid] = 666;
					
					format(komunikat, sizeof(komunikat), "%s zorganizowal wyscig %s (koszt: %d, nagroda: %d)", sendername, Wyscig[tworzenietrasy[playerid]][wNazwa], (Wyscig[tworzenietrasy[playerid]][wCheckpointy]+1)*2000, Wyscig[tworzenietrasy[playerid]][wNagroda]);
					PayLog(komunikat);
				}
				else
				{
					SendClientMessage(playerid, COLOR_PANICRED, "Nie sta� ci� na zorganizowanie tego wy�cigu!!");
					tworzenietrasy[playerid] = 666;
					ShowPlayerDialogEx(playerid, 1412, DIALOG_STYLE_LIST, "Organizowanie wy�cigu. Dost�pne trasy:", ListaWyscigow(), "Zorganizuj", "Wr��");
				}
			}
		    if(!response)
		    {
				tworzenietrasy[playerid] = 666;
				ShowPlayerDialogEx(playerid, 1412, DIALOG_STYLE_LIST, "Organizowanie wy�cigu. Dost�pne trasy:", ListaWyscigow(), "Zorganizuj", "Wr��");
		    }
			return 1;
		}
		if(dialogid == 1417)//usu� trase
		{
		    if(response)
			{
			    Wyscig[tworzenietrasy[playerid]][wStworzony] = 0;
				strcat(Wyscig[tworzenietrasy[playerid]][wNazwa], "Wolne", 20);
				strcat(Wyscig[tworzenietrasy[playerid]][wOpis], "", 50);
				Wyscig[tworzenietrasy[playerid]][wCheckpointy] = 0;
				Wyscig[tworzenietrasy[playerid]][wNagroda] = 0;
				Wyscig[tworzenietrasy[playerid]][wTypCH] = 0;
				Wyscig[tworzenietrasy[playerid]][wRozmiarCH] = 0;
				for(new ii; ii<26; ii++)
				{
					wCheckpoint[tworzenietrasy[playerid]][ii][0] = 0;
			  		wCheckpoint[tworzenietrasy[playerid]][ii][1] = 0;
			    	wCheckpoint[tworzenietrasy[playerid]][ii][2] = 0;
			    }
			    printf("Trasa %d zlikwidowana", tworzenietrasy[playerid]);
				SendClientMessage(playerid, COLOR_RED, "Trasa pomy�lnie zlikwidowana!");
				tworzenietrasy[playerid] = 666;
			    if(PlayerInfo[playerid][pRank] >= 4)
 			    {
					ShowPlayerDialogEx(playerid, 1410, DIALOG_STYLE_LIST, "Panel wy�cig�w: Wybierz opcj�", "Poka� trasy\nZorganizuj wy�cig\nEdytuj tras�\nUsu� tras�", "Wybierz", "Anuluj");
				}
				else
				{
				    ShowPlayerDialogEx(playerid, 1410, DIALOG_STYLE_LIST, "Panel wy�cig�w: Wybierz opcj�", "Poka� trasy\nZorganizuj wy�cig", "Wybierz", "Anuluj");
				}
				return 1;
			}
			if(!response)
			{
				tworzenietrasy[playerid] = 666;
				ShowPlayerDialogEx(playerid, 1414, DIALOG_STYLE_LIST, "Usuwanie. Dost�pne trasy:", ListaWyscigow(), "Usu�", "Wr��");
				return 1;
			}
		}
		if(dialogid == 1430)//opcje edycji
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0://Nazw�
		            {
		                ShowPlayerDialogEx(playerid, 1431, DIALOG_STYLE_INPUT, "Kreator wy�cig�w: Nazwa", "Wpisz nazw� wy�cigu. Maksymalnie 20 znak�w", "Edytuj", "Wr��");
		            }
		            case 1://Opis
		            {
		                ShowPlayerDialogEx(playerid, 1432, DIALOG_STYLE_INPUT, "Kreator wy�cig�w: Opis", "Wpisz opis trasy. Maksymalnie 50 znak�w", "Edytuj", "Wr��");
		            }
		            case 2://Nagrode
		            {
		                ShowPlayerDialogEx(playerid, 1433, DIALOG_STYLE_INPUT, "Kreator wy�cig�w: Nagroda", "Wpisz nagrod� jak� dostanie zwyci�zca wy�cigu.\nMinimalna stawka to 10 000$ a maksymalna to 10 000 000$", "Edytuj", "Wr��");
		            }
		        }
				return 1;
		    }
		    if(!response)
		    {
				tworzenietrasy[playerid] = 666;
				ShowPlayerDialogEx(playerid, 1413, DIALOG_STYLE_LIST, "Edytowanie. Dost�pne trasy:", ListaWyscigow(), "Edytuj", "Wr��");
				return 1;
			}
		}
		if(dialogid == 1431)
		{
		    if(response)
		    {
				if(Scigamy == 666)
				{
					if(strlen(inputtext) > 1 && strlen(inputtext) <= 20)
					{
						format(Wyscig[tworzenietrasy[playerid]][wNazwa], 20, "%s", inputtext);
						new string[128];
						format(string, sizeof(string), "Nazwa wy�cigu pomy�lnie zmieniona na: {FFFFFF}%s", inputtext);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						ZapiszTrase(tworzenietrasy[playerid]);
						ShowPlayerDialogEx(playerid, 1430, DIALOG_STYLE_LIST, "Edycja trasy: Wybierz co chcesz edytowa�", "Nazw�\nOpis\nNagrod�", "Wybierz", "Anuluj");
					}
					else
					{
						SendClientMessage(playerid, COLOR_GREY, "Nazwa nie mo�e by� pusta/zbyt du�o znak�w!");
						ShowPlayerDialogEx(playerid, 1431, DIALOG_STYLE_INPUT, "Kreator wy�cig�w: Nazwa", "Wpisz nazw� wy�cigu. Maksymalnie 20 znak�w", "Edytuj", "Wr��");
					}
				}
				else
				{
					ShowPlayerDialogEx(playerid, 1430, DIALOG_STYLE_LIST, "Edycja trasy: Wybierz co chcesz edytowa�", "Nazw�\nOpis\nNagrod�", "Wybierz", "Anuluj");
					SendClientMessage(playerid, COLOR_PANICRED, "Trwa wy�cig, nie mo�na edytowa�!");
				}
				return 1;
		    }
		    if(!response)
			{
			    ShowPlayerDialogEx(playerid, 1430, DIALOG_STYLE_LIST, "Edycja trasy: Wybierz co chcesz edytowa�", "Nazw�\nOpis\nNagrod�", "Wybierz", "Anuluj");
				return 1;
			}
		}
		if(dialogid == 1432)
		{
            if(response)
		    {
				if(Scigamy == 666)
				{
					if(strlen(inputtext) > 1 && strlen(inputtext) <= 50)
					{
						format(Wyscig[tworzenietrasy[playerid]][wOpis], 50, "%s", inputtext);
						new string[128];
						format(string, sizeof(string), "Opis wy�cigu pomy�lnie zmieniony na: {FFFFFF}%s", inputtext);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						ZapiszTrase(tworzenietrasy[playerid]);
						ShowPlayerDialogEx(playerid, 1430, DIALOG_STYLE_LIST, "Edycja trasy: Wybierz co chcesz edytowa�", "Nazw�\nOpis\nNagrod�", "Wybierz", "Anuluj");
					}
					else
					{
						SendClientMessage(playerid, COLOR_GREY, "Nazwa nie mo�e by� pusta/zbyt du�o znak�w!");
						ShowPlayerDialogEx(playerid, 1432, DIALOG_STYLE_INPUT, "Kreator wy�cig�w: Opis", "Wpisz opis trasy. Maksymalnie 50 znak�w", "Edytuj", "Wr��");
					}
				}
				else
				{
					ShowPlayerDialogEx(playerid, 1430, DIALOG_STYLE_LIST, "Edycja trasy: Wybierz co chcesz edytowa�", "Nazw�\nOpis\nNagrod�", "Wybierz", "Anuluj");
					SendClientMessage(playerid, COLOR_PANICRED, "Trwa wy�cig, nie mo�na edytowa�!");
				}
				return 1;
    		}
		    if(!response)
			{
			    ShowPlayerDialogEx(playerid, 1430, DIALOG_STYLE_LIST, "Edycja trasy: Wybierz co chcesz edytowa�", "Nazw�\nOpis\nNagrod�", "Wybierz", "Anuluj");
				return 1;
			}
		}
		if(dialogid == 1433)
		{
		    if(response)
		    {
				if(Scigamy == 666)
				{
					if(strval(inputtext) >= 10000 && strval(inputtext) <= 100000000)
					{
						Wyscig[tworzenietrasy[playerid]][wNagroda] = strval(inputtext);
						new string[128];
						format(string, sizeof(string), "Nagroda wy�cigu pomy�lnie zmieniona na: {FFFFFF}%d$", strval(inputtext));
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						ZapiszTrase(tworzenietrasy[playerid]);
						ShowPlayerDialogEx(playerid, 1430, DIALOG_STYLE_LIST, "Edycja trasy: Wybierz co chcesz edytowa�", "Nazw�\nOpis\nNagrod�", "Wybierz", "Anuluj");
					}
					else
					{
						ShowPlayerDialogEx(playerid, 1433, DIALOG_STYLE_INPUT, "Kreator wy�cig�w: Nagroda", "Wpisz nagrod� jak� dostanie zwyci�zca wy�cigu.\nMinimalna stawka to 10 000$ a maksymalna to 10 000 000$", "Edytuj", "Wr��");
					}
				}
				else
				{
					ShowPlayerDialogEx(playerid, 1430, DIALOG_STYLE_LIST, "Edycja trasy: Wybierz co chcesz edytowa�", "Nazw�\nOpis\nNagrod�", "Wybierz", "Anuluj");
					SendClientMessage(playerid, COLOR_PANICRED, "Trwa wy�cig, nie mo�na edytowa�!");
				}
				return 1;
		    }
		    if(!response)
			{
			    ShowPlayerDialogEx(playerid, 1430, DIALOG_STYLE_LIST, "Edycja trasy: Wybierz co chcesz edytowa�", "Nazw�\nOpis\nNagrod�", "Wybierz", "Anuluj");
				return 1;
			}
		}
		if(dialogid == 1420)//Tworzenie wy�cigu. Wybieranie slotu
		{
			if(response)
			{
				if(Wyscig[listitem][wStworzony] == 0)
				{
				    tworzenietrasy[playerid] = listitem;
				    ShowPlayerDialogEx(playerid, 1421, DIALOG_STYLE_LIST, "Kreator wy�cig�w: Wybierz typ checkpoint�w", "Normalne\nKo�a", "Wybierz", "Cofnij");
				}
				else
				{
                    new string[1024];
    				for(new i=0; i<sizeof(Wyscig); i++)
					{
					    if(Wyscig[i][wStworzony] == 1)
					    {
						    format(string, sizeof(string), "%s%s\n", string, Wyscig[i][wNazwa]);
						}
						else
						{
						    strcat(string, "Wolny\n");
						}
					}
     				ShowPlayerDialogEx(playerid, 1420, DIALOG_STYLE_LIST, "Kreator wy�cig�w: Wybierz slot", string, "Wybierz", "Anuluj");
     				SendClientMessage(playerid, COLOR_GREY, "Slot zaj�ty!");
				}
				return 1;
			}
			if(!response)
			{
				ShowPlayerDialogEx(playerid, 1410, DIALOG_STYLE_LIST, "Panel wy�cig�w: Wybierz opcj�", "Poka� trasy\nZorganizuj wy�cig\nEdytuj tras�\nUsu� tras�", "Wybierz", "Anuluj");
				return 1;
			}
		}
		if(dialogid == 1421)//Tworzenie wy�cigu. Wybieranie typu checkpointu
		{
			if(response)
			{
			    if(listitem == 1)
			    {
			    	Wyscig[tworzenietrasy[playerid]][wTypCH] = 3;
				}
				else
				{
				    Wyscig[tworzenietrasy[playerid]][wTypCH] = 0;
				}
			    ShowPlayerDialogEx(playerid, 1422, DIALOG_STYLE_LIST, "Kreator wy�cig�w: Wybierz rozmiar checkpoint�w", "Ogromne\nDu�e\n�rednie\nMa�e\nMini", "Wybierz", "Wr��");
				return 1;
			}
			if(!response)
			{
			    tworzenietrasy[playerid] = 666;
			    new string[1024];
				for(new i=0; i<sizeof(Wyscig); i++)
				{
					if(Wyscig[i][wStworzony] == 1)
					{
						format(string, sizeof(string), "%s%s\n", string, Wyscig[i][wNazwa]);
					}
					else
					{
						strcat(string, "Wolny\n");
					}
				}
     			ShowPlayerDialogEx(playerid, 1420, DIALOG_STYLE_LIST, "Kreator wy�cig�w: Wybierz slot", string, "Wybierz", "Anuluj");
				return 1;
			}
		}
		if(dialogid == 1422)//Tworzenie wy�cigu. Wybieranie wielko�ci checkpointu
		{
			if(response)
			{
			    switch(listitem)
				{
				    case 0://Ogromne
				    {
				        Wyscig[tworzenietrasy[playerid]][wRozmiarCH] = 10.0;//rupxnup
				    }
				    case 1://Du�e
				    {
				        Wyscig[tworzenietrasy[playerid]][wRozmiarCH] = 7.5;
				    }
				    case 2://�rednie
				    {
				        Wyscig[tworzenietrasy[playerid]][wRozmiarCH] = 5.0;
				    }
				    case 3://Ma�e
				    {
				        Wyscig[tworzenietrasy[playerid]][wRozmiarCH] = 2.5;
				    }
				    case 4://Mini
				    {
				        Wyscig[tworzenietrasy[playerid]][wRozmiarCH] = 1.0;
				    }
				}
				ShowPlayerDialogEx(playerid, 1423, DIALOG_STYLE_INPUT, "Kreator wy�cig�w: Nazwa", "Wpisz nazw� wy�cigu. Maksymalnie 20 znak�w", "Dalej", "");
				return 1;
   			}
			if(!response)
			{
			    Wyscig[tworzenietrasy[playerid]][wTypCH] = 0;
			    ShowPlayerDialogEx(playerid, 1421, DIALOG_STYLE_LIST, "Kreator wy�cig�w: Wybierz typ checkpoint�w", "Normalne\nKo�a", "Wybierz", "Wr��");
			}
		}
		if(dialogid == 1423)//Tworzenie wy�cigu. Wypisywanie nazwy
		{
		    if(strlen(inputtext) > 1 && strlen(inputtext) <= 20)
			{
			    format(Wyscig[tworzenietrasy[playerid]][wNazwa], 20, "%s", inputtext);
			    ShowPlayerDialogEx(playerid, 1424, DIALOG_STYLE_INPUT, "Kreator wy�cig�w: Opis", "Wpisz opis trasy. Maksymalnie 50 znak�w", "Dalej", "");
			}
		    else
			{
			    SendClientMessage(playerid, COLOR_GREY, "Nazwa nie mo�e by� pusta/zbyt du�o znak�w!");
			    ShowPlayerDialogEx(playerid, 1423, DIALOG_STYLE_INPUT, "Kreator wy�cig�w: Nazwa", "Wpisz nazw� wy�cigu. Maksymalnie 20 znak�w", "Dalej", "");
			}
		}
		if(dialogid == 1424)//Tworzenie wy�cigu. Wpisywanie opisu
		{
		    if(strlen(inputtext) > 1 && strlen(inputtext) <= 50)
			{
			    format(Wyscig[tworzenietrasy[playerid]][wOpis], 50, "%s", inputtext);
			    ShowPlayerDialogEx(playerid, 1425, DIALOG_STYLE_INPUT, "Kreator wy�cig�w: Nagroda", "Wpisz nagrod� jak� dostanie zwyci�zca wy�cigu.\nMinimalna stawka to 10 000$ a maksymalna to 10 000 000$", "Dalej", "");
			}
		    else
			{
				SendClientMessage(playerid, COLOR_GREY, "Opis nie mo�e by� pusty/zbyt du�o znak�w!");
			    ShowPlayerDialogEx(playerid, 1424, DIALOG_STYLE_INPUT, "Kreator wy�cig�w: Opis", "Wpisz opis trasy. Maksymalnie 50 znak�w", "Dalej", "");
			}
		}
		if(dialogid == 1425)//Tworzenie wy�cigu. Nagroda
		{
			if(strval(inputtext) >= 10000 && strval(inputtext) <= 10000000)
			{
			    Wyscig[tworzenietrasy[playerid]][wNagroda] = strval(inputtext);
			    ShowPlayerDialogEx(playerid, 1426, DIALOG_STYLE_MSGBOX, "Kreator wy�cig�w: Tworzenie trasy", "Poda�e� ju� wszystkie wymagane informacje.\nMo�esz przej�� do tworzenia trasy lub anulowa� proces tworzenia.\nAby postawi� czekpoint wpisz /checkpoint\nAby postawi� mete i zako�czyc tworzenie trasy, wpisz /meta\nAby przej�� dalej, naci�nnij \"Dalej\"", "Dalej", "Usu�");
			}
			else
			{
			    ShowPlayerDialogEx(playerid, 1425, DIALOG_STYLE_INPUT, "Kreator wy�cig�w: Nagroda", "Wpisz nagrod� jak� dostanie zwyci�zca wy�cigu.\nMinimalna stawka to 10 000$ a maksymalna to 10 000 000$", "Dalej", "");
			}
		}
		if(dialogid == 1426)//Tworzenie wy�cigu. Przej�cie do tworzenia trasy
		{
		    if(response)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Aby stworzy� checkpoint wpisz /checkpoint. Aby usun�� ostatnio postawiony checkpoint wpisz /checkpoint-usun. Aby zako�czy� tworzenie i postawi� finisz, wpisz /meta");
		        SendClientMessage(playerid, COLOR_LIGHTBLUE, "Maksymalna ilo�� checkpoint�w to 50.");
		    }
		    if(!response)
		    {
		        format(Wyscig[tworzenietrasy[playerid]][wOpis], 50, "");
		        format(Wyscig[tworzenietrasy[playerid]][wNazwa], 20, "");
		        Wyscig[tworzenietrasy[playerid]][wTypCH] = 0;
		        Wyscig[tworzenietrasy[playerid]][wRozmiarCH] = 0;
		        tworzenietrasy[playerid] = 666;
		    }
		}
		if(dialogid == 1427)//Tworzenie wy�cigu. Koniec tworzenia trasy
		{
		    if(response)
		    {
		        //testowanie wy�cigu
		    }
		}
        /*
		if(dialogid == 7004)//wybiera�ka GUI
	   	{
		   	if(response == 1)
		    {
			   	switch(listitem)
			   	{
				   	case 0://Lekarz
				   	{
					   	PlayerInfo[playerid][pSkin] = 70;
					   	SetPlayerSkin(playerid, 70);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Skin ID: 70 jest teraz twoim nowym skinem frakcyjnym.");
					}
					case 1://Sanitariusz Latynos
					{
						PlayerInfo[playerid][pSkin] = 275;
					   	SetPlayerSkin(playerid, 275);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 275");
					}
					case 2://Sanitariusz Murzyn
					{
						PlayerInfo[playerid][pSkin] = 274;
					   	SetPlayerSkin(playerid, 274);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 274");
					}
					case 3://Sanitariusz Bia�y
					{
						PlayerInfo[playerid][pSkin] = 276;
					   	SetPlayerSkin(playerid, 276);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 276");
					}
					case 4://Lekarka
					{
						PlayerInfo[playerid][pSkin] = 219;
					   	SetPlayerSkin(playerid, 219);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 219");
					}
					case 5://Piel�gniarka Latynoska
					{
						PlayerInfo[playerid][pSkin] = 69;
					   	SetPlayerSkin(playerid, 69);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano 69");
					}
					case 6://Piel�gniarka Murzynka
					{
						PlayerInfo[playerid][pSkin] = 148;
					   	SetPlayerSkin(playerid, 148);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 148");
					}
					case 7://Piel�gniarka Bia�a
					{
						PlayerInfo[playerid][pSkin] = 216;
					   	SetPlayerSkin(playerid, 216);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 216");
					}
				}
   			}
  		}
  		//	--------------------------------------------------------------
 		if(dialogid == 7001)//wybiera�ka GUI
	   	{
		   	if(response == 1)
		    {
			   	switch(listitem)
			   	{
				   	case 0://Policjant bia�y(Pulaski)
				   	{
						new skin = (PlayerInfo[playerid][pSex] == 2) ? 93 : 266;
						PlayerInfo[playerid][pSkin] = skin;
						SetPlayerSkin(playerid, skin);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Zmieni�e� sw�j uniform.");
					}
					case 1://Policjant tempeny
					{
						new skin = (PlayerInfo[playerid][pSex] == 2) ? 211 : 265;
						PlayerInfo[playerid][pSkin] = skin;
						SetPlayerSkin(playerid, skin);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Zmieni�e� sw�j uniform.");
					}
					case 2://Policjant Latynos
					{	
						new skin = (PlayerInfo[playerid][pSex] == 2) ? 192 : 267;
						PlayerInfo[playerid][pSkin] = skin;
						SetPlayerSkin(playerid, skin);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Zmieni�e� sw�j uniform.");
					}
					case 3://Policjant bia�y
					{	
						new skin = (PlayerInfo[playerid][pSex] == 2) ? 148 : 280;
						PlayerInfo[playerid][pSkin] = skin;
						SetPlayerSkin(playerid, skin);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Zmieni�e� sw�j uniform.");
					}
					case 4://Policjant bia�y(z w�sem)
					{	
						new skin = (PlayerInfo[playerid][pSex] == 2) ? 141 : 281;
						PlayerInfo[playerid][pSkin] = skin;
						SetPlayerSkin(playerid, skin);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "Zmieni�e� sw�j uniform.");
					}
					case 5://Policjant z Las Venturas
					{
						PlayerInfo[playerid][pSkin] = 282;
					   	SetPlayerSkin(playerid, 282);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 282");
					}
					case 6://Policjant w kapeluszu
					{
						PlayerInfo[playerid][pSkin] = 283;
					   	SetPlayerSkin(playerid, 283);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano 283");
					}
					case 7://Policjant w kasku
					{
						PlayerInfo[playerid][pSkin] = 284;
					   	SetPlayerSkin(playerid, 284);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 284");
					}
					case 8://Policjant w SWAT
					{
						PlayerInfo[playerid][pSkin] = 285;
					   	SetPlayerSkin(playerid, 285);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 285");
					}
					case 9://Kadet
					{
						PlayerInfo[playerid][pSkin] = 71;
					   	SetPlayerSkin(playerid, 71);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 71");
					}
				}
   			}
  		}
  		//	--------------------------------------------------------------
 		if(dialogid == 7003)//wybiera�ka GUI
	   	{
		   	if(response == 1)
		    {
			   	switch(listitem)
			   	{
				   	case 0://Poborowy
				   	{
					   	PlayerInfo[playerid][pSkin] = 287;
					   	SetPlayerSkin(playerid, 287);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Skin ID: 287 jest teraz twoim nowym skinem frakcyjnym.");
					}
					case 1://SZEREGOWY
					{
						PlayerInfo[playerid][pSkin] = 287;
					   	SetPlayerSkin(playerid, 287);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 287");
					}
					case 2://KAPRAL
					{
						PlayerInfo[playerid][pSkin] = 287;
					   	SetPlayerSkin(playerid, 287);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 287");
					}
					case 3://PORUCZNIK
					{
						PlayerInfo[playerid][pSkin] = 287;
					   	SetPlayerSkin(playerid, 287);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 287");
					}
					case 4://MAJOR
					{
						PlayerInfo[playerid][pSkin] = 287;
					   	SetPlayerSkin(playerid, 287);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 287");
					}
					case 5://PU�KOWNIK
					{
						PlayerInfo[playerid][pSkin] = 287;
					   	SetPlayerSkin(playerid, 287);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano 287");
					}
					case 6://GERA�
					{
						PlayerInfo[playerid][pSkin] = 287;
					   	SetPlayerSkin(playerid, 287);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID:287");
					}
					case 7://SWAT
					{
						PlayerInfo[playerid][pSkin] = 285;
					   	SetPlayerSkin(playerid, 285);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 285");
					}
					case 8://Kobiekta
					{
						PlayerInfo[playerid][pSkin] = 191;
					   	SetPlayerSkin(playerid, 191);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 191");
					}
				}
   			}
  		}
  			//	--------------------------------------------------------------
 		if(dialogid == 7002)//wybiera�ka GUI
	   	{
		   	if(response == 1)
		    {
			   	switch(listitem)
			   	{
				   	case 0://Kadet
				   	{
					   	PlayerInfo[playerid][pSkin] = 286;
					   	SetPlayerSkin(playerid, 286);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Skin ID: 286 jest teraz twoim nowym skinem frakcyjnym.");
					}
					case 1://Agent Federalny
					{
						PlayerInfo[playerid][pSkin] = 165;
					   	SetPlayerSkin(playerid, 165);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 165");
					}
					case 2://Agent �ledczy
					{
						PlayerInfo[playerid][pSkin] = 166;
					   	SetPlayerSkin(playerid, 166);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 166");
					}
					case 3://Koordynator �ledczy
					{
						PlayerInfo[playerid][pSkin] = 165;
					   	SetPlayerSkin(playerid, 165);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 165");
					}
					case 4://Tajny Agent
					{
						PlayerInfo[playerid][pSkin] = 166;
					   	SetPlayerSkin(playerid, 166);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 166");
					}
					case 5://Agent Specjalny
					{
						PlayerInfo[playerid][pSkin] = 165;
					   	SetPlayerSkin(playerid, 165);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano 165");
					}
					case 6://Dyrektor
					{
						PlayerInfo[playerid][pSkin] = 295;
					   	SetPlayerSkin(playerid, 295);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 295");
					}
				}
   			}
  		}
  			//	--------------------------------------------------------------
 		if(dialogid == 7006)//wybiera�ka GUI (Yakuza to rangi 5/6) Z�E SKINY
	   	{
		   	if(response == 1)
		    {
			   	switch(listitem)
			   	{
				   	case 0://Ochrona 1
				   	{
					   	PlayerInfo[playerid][pSkin] = 163;
					   	SetPlayerSkin(playerid, 163);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Skin ID: 163 jest teraz twoim nowym skinem frakcyjnym.");
					}
					case 1://Technik 1
					{
						PlayerInfo[playerid][pSkin] = 164;
					   	SetPlayerSkin(playerid, 164);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 164");
					}
					case 2://Ochrona 2
					{
						PlayerInfo[playerid][pSkin] = 164;
					   	SetPlayerSkin(playerid, 164);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 164");
					}
					case 3://Technik 2
					{
						PlayerInfo[playerid][pSkin] = 164;
					   	SetPlayerSkin(playerid, 164);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 164");
					}
					case 4://Shatei
					{
	    				if(PlayerInfo[playerid][pRank] <= 2)
		 				{
						PlayerInfo[playerid][pSkin] = 287;
					   	SetPlayerSkin(playerid, 287);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 287");
					   	}
		   				else
					   	{
						   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Musisz mie� minimum 2 rang� aby wybra� ten skin!");
					   	}
					}
					case 5://Gosho
					{
	    				if(PlayerInfo[playerid][pRank] <= 2)
		 				{
						PlayerInfo[playerid][pSkin] = 287;
					   	SetPlayerSkin(playerid, 287);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 287");
					 	}
		   				else
					   	{
						   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Musisz mie� minimum 2 rang� aby wybra� ten skin!");
					   	}
					}
					case 6://Taka Hosho
					{
	    				if(PlayerInfo[playerid][pRank] <= 2)
		 				{
						PlayerInfo[playerid][pSkin] = 287;
					   	SetPlayerSkin(playerid, 287);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 287");
					   	}
		   				else
					   	{
						   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Musisz mie� minimum 2 rang� aby wybra� ten skin!");
					   	}
					}
    				case 7://Daimao
					{
	    				if(PlayerInfo[playerid][pRank] <= 5)
		 				{
						PlayerInfo[playerid][pSkin] = 186;
					   	SetPlayerSkin(playerid, 186);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybranoskin ID: 186");
					   	}
		   				else
					   	{
						   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Musisz mie� minimum 5 rang� aby wybra� ten skin!");
					   	}
					}
					case 8://Oyabun
					{
	    				if(PlayerInfo[playerid][pRank] <= 5)
		 				{
						PlayerInfo[playerid][pSkin] = 120;
					   	SetPlayerSkin(playerid, 120);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 120");
					   	}
		   				else
					   	{
						   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Musisz mie� minimum 5 rang� aby wybra� ten skin!");
					   	}
					}
				}
   			}
  		}
//Ykz Koniec
	//	--------------------------------------------------------------
 		if(dialogid == 7011)//wybiera�ka GUI DMV
	   	{
		   	if(response == 1)
		    {
			   	switch(listitem)
			   	{
				   	case 0://Sta�ysta
				   	{
					   	PlayerInfo[playerid][pSkin] = 76;
					   	SetPlayerSkin(playerid, 76);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Skin ID: 76 jest teraz twoim nowym skinem frakcyjnym.");
					}
					case 1://Sta�ysta1
					{
						PlayerInfo[playerid][pSkin] = 60;
					   	SetPlayerSkin(playerid, 60);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 60");
					}
					case 2://Egzaminator
					{
						PlayerInfo[playerid][pSkin] = 59;
					   	SetPlayerSkin(playerid, 59);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 59");
					}
					case 3://Egzaminator1
					{
						PlayerInfo[playerid][pSkin] = 150;
					   	SetPlayerSkin(playerid, 150);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 150");
					}
					case 4://Instruktor
					{
						PlayerInfo[playerid][pSkin] = 150;
					   	SetPlayerSkin(playerid, 150);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 150");
					}
					case 5://Instruktor1
					{
						PlayerInfo[playerid][pSkin] = 59;
					   	SetPlayerSkin(playerid, 59);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano 59");
					}
					case 6://Urz�dnik
					{
						PlayerInfo[playerid][pSkin] = 240;
					   	SetPlayerSkin(playerid, 240);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 240");
					}
					case 7://Urz�dnik1
					{
						PlayerInfo[playerid][pSkin] = 150;
					   	SetPlayerSkin(playerid, 150);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 150");
					}
					case 8://Menager
					{
						PlayerInfo[playerid][pSkin] = 150;
					   	SetPlayerSkin(playerid, 150);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 150");
					}
					case 9://Menager1
					{
						PlayerInfo[playerid][pSkin] = 240;
					   	SetPlayerSkin(playerid, 240);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 240");
					}
					case 10://Z-ca Burmistrza
					{
						PlayerInfo[playerid][pSkin] =  141;
					   	SetPlayerSkin(playerid, 141);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 141");
					}
					case 11://Z-ca Burmistrza1
					{
						PlayerInfo[playerid][pSkin] = 57;
					   	SetPlayerSkin(playerid, 57);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 57");
					}
					case 12://Burmistrz
					{
						PlayerInfo[playerid][pSkin] = 147;
					   	SetPlayerSkin(playerid, 147);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 147");
					}
				}
   			}
  		}
//----------------------------------
 		if(dialogid == 7016)//wybiera�ka GUI WPS
	   	{
		   	if(response == 1)
		    {
			   	switch(listitem)
			   	{
				   	case 0://�ysy
				   	{
					   	PlayerInfo[playerid][pSkin] = 112;
					   	SetPlayerSkin(playerid, 112);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Skin ID: 112 jest teraz twoim nowym skinem frakcyjnym.");
					}
					case 1://sko�nooki skin
					{
						PlayerInfo[playerid][pSkin] = 121;
					   	SetPlayerSkin(playerid, 121);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 121");
					}
					case 2://wsiowy kox
					{
						PlayerInfo[playerid][pSkin] = 206;
					   	SetPlayerSkin(playerid, 206);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 206");
					}
					case 3://tirowiec
					{
						PlayerInfo[playerid][pSkin] = 202;
					   	SetPlayerSkin(playerid, 202);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 202");
					}
					case 4://stary metal
					{
						PlayerInfo[playerid][pSkin] = 133;
					   	SetPlayerSkin(playerid, 133);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 133");
					}
					case 5://�pun
					{
						PlayerInfo[playerid][pSkin] = 291;
					   	SetPlayerSkin(playerid, 291);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano 291");
					}
					case 6://Skin�wa
					{
						PlayerInfo[playerid][pSkin] = 191;
					   	SetPlayerSkin(playerid, 191);
					   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Wybrano skin ID: 191");
					}
				}
   			}
  		}
        if(dialogid == D_UNIFORM_RSC)
        {
            if(PlayerInfo[playerid][pFMember] != FAMILY_RSC) return 1;
            new skin = strval(inputtext);
		   	SetPlayerSkin(playerid, skin);
		   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Przebra�es si� na chwile.");
        }
        if(7007 <= dialogid <= 7010 || 7012 <= dialogid <= 7015 || dialogid == 7017)
        {
            if(dialogid - GetPlayerFraction(playerid) != 7000) return 1;
            new skin = strval(inputtext);
            PlayerInfo[playerid][pSkin] = skin;
		   	SetPlayerSkin(playerid, skin);
		   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Zmieni�e� sw�j uniform.");
        }
        if(dialogid == D_UNIFORM_LCN)
        {
            if(!response) return 1;
            new skin;
            switch(listitem)
            {
                case 0: skin = 98;
                case 1: skin = 111;
                case 2: skin = 113;
                case 3: skin = 124;
                case 4: skin = 125;
                case 5: skin = 126;
                case 6: skin = 214;
                case 7: skin = 272;
                case 8: skin = 40;
                default: skin = PlayerInfo[playerid][pSkin];
            }
            PlayerInfo[playerid][pSkin] = skin;
		   	SetPlayerSkin(playerid, skin);
		   	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Zmieni�e� sw�j uniform.");

        }  */
	   	if(dialogid == 8155)//SYstem autobus�w - tablice
	   	{
		   	if(response == 1)
		    {
			   	switch(listitem)
			   	{
				   	case 0:
				   	{
				   		if(PlayerInfo[playerid][pNatrasiejest] == 0)
						{
						    if( (PlayerInfo[playerid][pJob] == 10 && PlayerInfo[playerid][pCarSkill] >= 50) || PlayerInfo[playerid][pMember] == 10 ||PlayerInfo[playerid][pLider] == 10)
						    {
							    PlayerInfo[playerid][pLinia55]=1;
								SendClientMessage(playerid, COLOR_YELLOW, " Rozpoczynasz wyznaczon� tras�. Pod��aj za sygna�em GPS.");
								SetPlayerCheckpoint(playerid, 2215.8428,-1436.8223,23.4033, 4); // Ustawiamy pocz�tkowy CP
								CP[playerid] = 551; //Przypisek CP do dalszych
								PlayerInfo[playerid][pNatrasiejest] = 1; //Kierowca jest w trasie
	   							Przystanek(playerid, COLOR_BLUE, "Linia nr. 55\n{808080}Dojazd do trasy.\nWszytkie przystanki NA ��DANIE (N/�)");
	   							SetTimerEx("AntyBusCzit", 60000*6, 0, "d", playerid);
	   							BusCzit[playerid] = 1;
							}
							else
							{
							    SendClientMessage(playerid, COLOR_GREY, " Potrzebujesz 2skill aby rozpocz�� t� tras�");
							}
   						}
				    	else
						{
							SendClientMessage(playerid, COLOR_GREY, " Jeste� ju� w trasie !");
						}
				   	}
				   	case 1:
				   	{
				   		if(PlayerInfo[playerid][pNatrasiejest] == 0)
						{
							    PlayerInfo[playerid][pLinia72]= 1;
								SendClientMessage(playerid, COLOR_YELLOW, " Rozpoczynasz wyznaczon� tras�. Pod��aj za sygna�em GPS.");
								SetPlayerCheckpoint(playerid, 2818.4243,-1576.9399,10.9287, 4);
								CP[playerid] = 721;
								PlayerInfo[playerid][pNatrasiejest] = 1;
					   			Przystanek(playerid, COLOR_NEWS, "Linia nr. 72 (dojazd)\n{808080}Kierunek: BAZA MECHANIK�W (p�tla) \nWszytkie przystanki NA ��DANIE (N/�)");
					   			SetTimerEx("AntyBusCzit", 60000*5, 0, "d", playerid);
	   							BusCzit[playerid] = 1;
	   					}
				   		else
						{
							SendClientMessage(playerid, COLOR_GREY, " Jeste� ju� w trasie !");
						}
				   	}
				   	case 2:
					{
						if(PlayerInfo[playerid][pNatrasiejest] == 0)
						{
						 	if( (PlayerInfo[playerid][pJob] == 10 && PlayerInfo[playerid][pCarSkill] >= 200) || PlayerInfo[playerid][pMember] == 10 ||PlayerInfo[playerid][pLider] == 10)
						    {
							    PlayerInfo[playerid][pLinia96]= 1;
								SendClientMessage(playerid, COLOR_YELLOW, " Rozpoczynasz wyznaczon� tras�. Pod��aj za sygna�em GPS");
								SetPlayerCheckpoint(playerid, 2687.6597,-2406.9775,13.6017, 4);
								CP[playerid] = 961;
								PlayerInfo[playerid][pNatrasiejest] = 1;
								Przystanek(playerid, COLOR_GREEN, "Linia nr. 96\n{808080}Dojazd do trasy.\nWszytkie przystanki NA ��DANIE (N/�)");
								SetTimerEx("AntyBusCzit", 60000*6, 0, "d", playerid);
	   							BusCzit[playerid] = 1;
 							}
							else
							{
							    SendClientMessage(playerid, COLOR_GREY, " Potrzebujesz 4skill aby rozpocz�� t� tras�");
							}
						}
						else
						{
							SendClientMessage(playerid, COLOR_GREY, " Jeste� ju� w trasie !");
						}
					}
					case 3:
					{
						if(PlayerInfo[playerid][pNatrasiejest] == 0)
						{
							if( (PlayerInfo[playerid][pJob] == 10 && PlayerInfo[playerid][pCarSkill] >= 400) || PlayerInfo[playerid][pMember] == 10 ||PlayerInfo[playerid][pLider] == 10)
						    {
							    PlayerInfo[playerid][pLinia82]= 1;
								SendClientMessage(playerid, COLOR_YELLOW, " Rozpoczynasz wyznaczon� tras�. Pod��aj za sygna�em GPS");
								SetPlayerCheckpoint(playerid, 1173.1520,-1825.2843,13.1789, 4);
								CP[playerid] = 821;
								PlayerInfo[playerid][pNatrasiejest] = 1;
								Przystanek(playerid,COLOR_YELLOW, "Linia nr. 82\n{808080}Dojazd do trasy.\nWszytkie przystanki NA ��DANIE (N/�)");
								SetTimerEx("AntyBusCzit", 60000*8, 0, "d", playerid);
	   							BusCzit[playerid] = 1;
                            }
							else
							{
							    SendClientMessage(playerid, COLOR_GREY, " Potrzebujesz 5skill aby rozpocz�� t� tras�");
							}
						}
						else
						{
							SendClientMessage(playerid, COLOR_GREY, " Jeste� ju� w trasie !");
						}
					}
					case 4:
					{
						if(PlayerInfo[playerid][pNatrasiejest] == 0)
						{
							if( (PlayerInfo[playerid][pJob] == 10 && PlayerInfo[playerid][pCarSkill] >= 100) || PlayerInfo[playerid][pMember] == 10 ||PlayerInfo[playerid][pLider] == 10)
						    {
							    PlayerInfo[playerid][pLinia96]= 1;
								SendClientMessage(playerid, COLOR_YELLOW, " Rozpoczynasz wyznaczon� tras�. Pod��aj za sygna�em GPS");
								SetPlayerCheckpoint(playerid, 2119.7363,-1896.8149,13.1345, 4);
								CP[playerid] = 501;
								PlayerInfo[playerid][pNatrasiejest] = 1;
								Przystanek(playerid, COLOR_GREEN, "Linia nr. 85\n{808080}Dojazd do trasy.\nWszytkie przystanki NA ��DANIE (N/�)");
								SetTimerEx("AntyBusCzit", 60000*6, 0, "d", playerid);
	   							BusCzit[playerid] = 1;
 							}
							else
							{
							    SendClientMessage(playerid, COLOR_GREY, " Potrzebujesz 3skill aby rozpocz�� t� tras�");
							}
						}
						else
						{
							SendClientMessage(playerid, COLOR_GREY, " Jeste� ju� w trasie !");
						}
					}
					case 5:
					{
						if(PlayerInfo[playerid][pNatrasiejest] == 0)
						{
							if( (PlayerInfo[playerid][pJob] == 10 && PlayerInfo[playerid][pCarSkill] >= 400) || PlayerInfo[playerid][pMember] == 10 && PlayerInfo[playerid][pRank] >= 4 ||PlayerInfo[playerid][pLider] == 10)
						    {
								Przystanek(playerid, COLOR_BLUE, "Wycieczka\nKoszt: 7500$\n Wi�cej informacji u kierowcy.");
				    			/*BusDrivers += 1; TransportDuty[playerid] = 2; TransportValue[playerid]= 15000;
							    GetPlayerName(playerid,sendername,sizeof(sendername));
			    				format(string, sizeof(string), "Przewodnik %s zaprasza wszytkich na wycieczk� autobusow�, koszt: $15000", sendername, TransportValue[playerid]);
			    				OOCNews(TEAM_GROVE_COLOR,string);*/
 							}
							else
							{
							    SendClientMessage(playerid, COLOR_GREY, " Potrzebujesz 5skill lub 4 rangi aby organizowa� wycieczki.");
							}
						}
						else
						{
							SendClientMessage(playerid, COLOR_GREY, " Jeste� ju� w trasie !");
						}
					}
					case 6:
					{
				    	if(PlayerInfo[playerid][pJob] == 10)
			    			{
           						SetPlayerCheckpoint(playerid, 1138.5,-1738.3,13.5, 4);
								CP[playerid]=1201;
								PlayerInfo[playerid][pLinia55] = 0;
								PlayerInfo[playerid][pLinia72] = 0;
								PlayerInfo[playerid][pLinia82] = 0;
								PlayerInfo[playerid][pLinia96] = 0;
								PlayerInfo[playerid][pNatrasiejest] = 0;
								SendClientMessage(playerid, COLOR_YELLOW, " Rozpoczynasz zjazd do zajezdni, wskazuje j� sygna� GPS. ");
				       			Przystanek(playerid, COLOR_BLUE, "Linia ZAJ \n Kierunek: Zajezdnia Commerce\n {808080}Zatrzymuje si� na przystankach");
				       			SendClientMessage(playerid, COLOR_ALLDEPT, " KT przypomina: {C0C0C0}Odstawiony do zajezdni autobus to szcz�liwy autobus :) ");
							}
							else if (PlayerInfo[playerid][pMember] == 10 ||PlayerInfo[playerid][pLider] == 10)
							{
								SetPlayerCheckpoint(playerid, 2431.2551,-2094.0959,13.5469, 4);
								CP[playerid]=1200;
								PlayerInfo[playerid][pLinia55] = 0;
								PlayerInfo[playerid][pLinia72] = 0;
								PlayerInfo[playerid][pLinia82] = 0;
								PlayerInfo[playerid][pLinia96] = 0;
								PlayerInfo[playerid][pNatrasiejest] = 0;
								SendClientMessage(playerid, COLOR_YELLOW, " Rozpoczynasz zjazd do zajezdni, wskazuje j� sygna� GPS. ");
				       			Przystanek(playerid, COLOR_BLUE, "Linia ZAJ \n Kierunek: Zajezdnia Ocean Docks\n {808080}Zatrzymuje si� na przystankach");
				       			SendClientMessage(playerid, COLOR_ALLDEPT, " LSBD przypomina: {C0C0C0}Odstawiony do zajezdni autobus to szcz�liwy autobus :) ");
							}
				   	}
				   	case 7:
				   	{
						SendClientMessage(playerid, COLOR_YELLOW, "|_____________Obja�nienia_____________|");
						SendClientMessage(playerid, COLOR_GREEN, "{FF00FF}50$/p {FFFFF0}- okre�la premi� za ka�dy przystanek");
						SendClientMessage(playerid, COLOR_GREEN, "{FF00FF}5min{FFFFF0} - orientacyjny czas przejazdy ca�ej trasy (dwa okr��enia)");
						SendClientMessage(playerid, COLOR_GREEN, "{FF00FF}13p{FFFFF0} - liczba przystank�w na trasie");
						SendClientMessage(playerid, COLOR_GREEN, "{FF00FF}/businfo{FFFFF0} - wy�wietla informacje o systemie autobus�w (w budowie)");
						SendClientMessage(playerid, COLOR_GREEN, "{FF00FF}/zakoncztrase{FFFFF0} - przerywa wykonywan� tras� i zmienia tablic� na domy�ln�");
						SendClientMessage(playerid, COLOR_GREEN, "{FF00FF}/zd{FFFFF0} - zamyka drzwi w autobusie i umo�liwa dalsz� jazd�");
						SendClientMessage(playerid, COLOR_GREEN, "Wyp�at� za przejechane przystanki otrzymuje si� DOPIERO po przejechaniu ca�ej trasy!");
						SendClientMessage(playerid, COLOR_GREEN, "{FF00FF}Podpowied�:{FFFFF0} najszybsze zarobki gwarantuje linia 72");
						SendClientMessage(playerid, COLOR_YELLOW, "|_____________>>LSBD<<_____________|");
					}
			   	}
		   	}
	   	}
   }
   
	if(dialogid == 1888)
	{
	    if(response)
	    {
	        if(IsPlayerAdmin(playerid))
	        {
	            new gf[256];
				dini_IntSet("Admini/weryfikacje.ini", "ilosc", dini_Int("Admini/weryfikacje.ini", "ilosc")+1);
    			new i = dini_Int("Admini/weryfikacje.ini", "ilosc");
 		    	format(gf, sizeof(gf), "Nick_%d", i);
   				dini_Set("Admini/weryfikacje.ini", gf, inputtext);
	        	ShowPlayerDialogEx(playerid, 1889, DIALOG_STYLE_INPUT, "Tworzenie weryfikacji", "Wpisz weryfikacje", "Stw�rz", "");
			}
	    }
	}
	if(dialogid == 1889)
	{
	    if(IsPlayerAdmin(playerid))
     	{
     	    new gf[256], gf2[MAX_PLAYER_NAME];
     	    new i = dini_Int("Admini/weryfikacje.ini", "ilosc");
     	    format(gf, sizeof(gf), "Weryfikacja_%d", i);
     	    format(gf2, sizeof(gf2), "Nick_%d", i);
     	    dini_Set("Admini/weryfikacje.ini", gf, inputtext);
     	    format(gf, sizeof(gf), "Weryfikacja utworzona pomy�lnie.\nNick: %s\nWeryfikacja: %s", dini_Get("Admini/weryfikacje.ini", gf2), dini_Get("Admini/weryfikacje.ini", gf));
            ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_INPUT, "Tworzenie weryfikacji", gf, "OK", "");
      	}
	}

    //IBIZA
    if(dialogid==DIALOG_IBIZA_IBIZA)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: //sejf
				{
					ShowPlayerDialogEx(playerid, DIALOG_IBIZA_SEJF, DIALOG_STYLE_LIST, "Sejf Klubu Ibiza", "Wpisz /sejfr", "Wr��", "");
					return 1;
				}
				case 1: //drzwi
				{
					if(IbizaZamek)
					{
						IbizaZamek=false;
						SendClientMessage(playerid, 0x00FF00FF, "Otworzy�e� klub!");
					}
					else
					{
						IbizaZamek=true;
						SendClientMessage(playerid, 0xFF0000FF, "Zamkn��e� klub!");
					}
				}
				case 2: //cena biletu
				{
					ShowPlayerDialogEx(playerid, DIALOG_IBIZA_BILET_CENA, DIALOG_STYLE_INPUT, "Zmiana ceny biletu", "Wpisz poni�ej now� cen� biletu dla Ibiza Club", "Zmie�", "Anuluj");
					return 1;
				}
				case 3: //ceny na barze
				{
					new string[300];
					for(new i=0; i< sizeof IbizaDrinkiCeny; i++)
					{
						format(string, sizeof string, "%s%d. %s - $%d\n", string, i+1, IbizaDrinkiNazwy[i], IbizaDrinkiCeny[i]);
					}
					ShowPlayerDialogEx(playerid, DIALOG_IBIZA_CENNIK_ZMIEN, DIALOG_STYLE_LIST, "Cennik drink�w", string, "Zmie�", "Wr��");
					return 1;
				}
				case 4: //barierki
				{
					if(IbizaBarierki)
					{
						MoveDynamicObject(IbizaBarierkiObiekty[0], 1953.8400, -2470.7100, 14.0833, 2.0  );
						MoveDynamicObject(IbizaBarierkiObiekty[1], 1951.9301, -2470.8201, 14.0691, 2.0  );
						MoveDynamicObject(IbizaBarierkiObiekty[2], 1950.0100, -2470.8701, 14.0762, 2.0  );
						IbizaBarierki=false;
					}
					else
					{
						MoveDynamicObject(IbizaBarierkiObiekty[0], 1953.8400000,-2470.7100000,14.9000000, 2.0  );
						MoveDynamicObject(IbizaBarierkiObiekty[1], 1951.9300, -2470.8200, 14.9000, 2.0  );
						MoveDynamicObject(IbizaBarierkiObiekty[2], 1950.0100000,-2470.8700000,14.9000000, 2.0  );
						IbizaBarierki=true;
					}
				}
				case 5:
				{
					MikserDialog(playerid);
					return 1;
				}
				case 6:
				{
					ShowPlayerDialogEx(playerid, DIALOG_IBIZA_PARKIET, DIALOG_STYLE_LIST, "Zmiana parkietu", "Piasek\nDrewniane panele\nKolorowe kafelki", "Zmie�", "Anuluj");
					return 1;
				}
				case 7:
				{
					if(IbizaBiuro) //otwarte
					{
						IbizaBiuro=false;
						SendClientMessage(playerid, 0xFF0000FF, "Zamkn��e� biuro");
					}
					else //zamkniete
					{
						IbizaBiuro= true;
						SendClientMessage(playerid, 0x00FF00FF, "Otworzy�e� biuro");
					}
				}
				case 8:
				{
					if(IbizaDach) //otwarte
					{
						IbizaDach=false;
						SendClientMessage(playerid, 0xFF0000FF, "Zamkn��e� wyj�cie na dach");
					}
					else //zamkniete
					{
						IbizaDach= true;
						SendClientMessage(playerid, 0x00FF00FF, "Otworzy�e� wyj�cie na dach");
					}

				}
			}
			return PrezesDialog(playerid);
		}


	}
	if(dialogid==DIALOG_IBIZA_PARKIET)
	{
		if(response)
		{
			if(listitem==IbizaParkiet) {SendClientMessage(playerid, -1, "Ten parkiet jest obiecnie ustawiony"); return  ShowPlayerDialogEx(playerid, DIALOG_IBIZA_PARKIET, DIALOG_STYLE_LIST, "Zmiana parkietu", "Piasek\nDrewniane panele\nKolorowe kafelki", "Zmie�", "Anuluj"); }
			//niszczenie obiektu
			switch(IbizaParkiet)
			{
				case 0: //piach
				{
					DestroyDynamicObject(IbizaPiasek[0]);
					DestroyDynamicObject(IbizaPiasek[1]);
					DestroyDynamicObject(IbizaPiasek[2]);
					DestroyDynamicObject(IbizaPiasek[3]);
				}
				case 1: //drewno
				{
					DestroyDynamicObject(IbizaPodloga[0]);
				}
				case 2: //kafle
				{
					DestroyDynamicObject(IbizaPodloga[1]);
				}
			}
			//tworzenie nowego
			switch(listitem)
			{
				case 0: //piach
				{
					IbizaPiasek[0] = CreateDynamicObject(19377,1939.8800000,-2485.0000000,12.5500000,0.0000000,90.0000000,0.0000000, 1, 0, -1);
					IbizaPiasek[1] = CreateDynamicObject(19377,1950.3800000,-2485.0000000,12.5500000,0.0000000,90.0000000,0.0000000, 1, 0, -1);
					IbizaPiasek[2] = CreateDynamicObject(19377,1939.8800000,-2494.6300000,12.5500000,0.0000000,90.0000000,0.0000000, 1, 0, -1);
					IbizaPiasek[3] = CreateDynamicObject(19377,1950.3800000,-2494.6300000,12.5500000,0.0000000,90.0000000,0.0000000, 1, 0, -1);
				}
				case 1:
				{
					IbizaPodloga[0] = CreateDynamicObject(18783, 1944.61, -2490.16, 10.13,   0.00, 0.00, 0.00, 1, 0, -1);
				}
				case 2:
				{
					IbizaPodloga[1] = CreateDynamicObject(19129, 1944.68, -2490.16, 12.59,   0.00, 0.00, 0.00, 1, 0, -1);
				}

			}
			IbizaOdswiezObiekty();
			IbizaParkiet = listitem;
		}
		return PrezesDialog(playerid);

	}
	if(dialogid==DIALOG_IBIZA_BILET_CENA)
	{
		if(response)
		{
            if(!IsNumeric(inputtext)) return SendClientMessage(playerid, 0xFF0000FF, "Niepoprawna kwota");
			new cena = strval(inputtext);
            if(cena < 0 || cena > 1000000) return SendClientMessage(playerid, 0xFF0000FF, "Niepoprawna kwota (od 0 do 1kk)");
			IbizaBilet = cena;
			new string[128];
			format(string, sizeof string, "Zmieni�e� cen� biletu do Ibizy na %d$", cena);
			SendClientMessage(playerid, 0x00FF00FF, string);
		}
		return PrezesDialog(playerid);
	}
	if(dialogid==DIALOG_IBIZA_CENNIK_ZMIEN)
	{
		if(response)
		{
			new string[128];
			format(string, sizeof string, "Wpisz now� cen� dla drinka %s", IbizaDrinkiNazwy[listitem]);
			ShowPlayerDialogEx(playerid, DIALOG_IBIZA_CENNIK_ZMIEN_2, DIALOG_STYLE_INPUT, "Cennik drink�w", string, "Zmie�", "Anuluj");
			SetPVarInt(playerid, "CenaDrinka", listitem);
		}
		else PrezesDialog(playerid);
		return 1;
	}
	if(dialogid==DIALOG_IBIZA_CENNIK_ZMIEN_2)
	{
		if(response)
		{
            if(!IsNumeric(inputtext)) return SendClientMessage(playerid, 0xFF0000FF, "Niepoprawna kwota");
			new hajsy=strval(inputtext);
            if(hajsy < 0 || hajsy > 1000000) return SendClientMessage(playerid, 0xFF0000FF, "Niepoprawna kwota (od 0 do 1kk)");
			new index = GetPVarInt(playerid, "CenaDrinka");
			IbizaDrinkiCeny[index] = hajsy;
			DeletePVar(playerid, "CenaDrinka");
			new string[128];
			format(string, sizeof string, "Zmieni�e� cen� drinka %s na %d$", IbizaDrinkiNazwy[index], IbizaDrinkiCeny[index]);
			SendClientMessage(playerid, -1, string);
		}
		new string[300];
		for(new i=0; i< sizeof IbizaDrinkiCeny; i++)
		{
			format(string, sizeof string, "%s%d. %s - $%d\n", string, i+1, IbizaDrinkiNazwy[i], IbizaDrinkiCeny[i]);
		}
		ShowPlayerDialogEx(playerid, DIALOG_IBIZA_CENNIK_ZMIEN, DIALOG_STYLE_LIST, "Cennik drink�w", string, "Zmie�", "Wr��");
	}
	/*if(dialogid==DIALOG_IBIZA_SEJF)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: //zawarto��
				{
					new hajs, string[128];
					hajs = IbizaZawartoscSejfu();
					format(string, sizeof string, "W sejfie jest %d$", hajs);
					ShowPlayerDialogEx(playerid, DIALOG_IBIZA_INFO, DIALOG_STYLE_MSGBOX, "Ibiza Sejf", string, "Ok", "");
				}
				case 1: //Wp�ata
				{
					ShowPlayerDialogEx(playerid, DIALOG_IBIZA_WPLATA, DIALOG_STYLE_INPUT, "Wp�ata do sejfu", "Wpisz poni�ej kwot� jak� chcia�by� wp�aci� do sejfu", "Wp�a�", "Anuluj");
				}
				case 2: //Wyp�ata
				{
					ShowPlayerDialogEx(playerid, DIALOG_IBIZA_WYPLATA, DIALOG_STYLE_INPUT, "Wyp�ata pieni�dzy z sejfu", "Wpisz poni�ej kwot� jak� chcia�by� wyp�aci� z sejfu", "Wyp�a�", "Anuluj");
				}
			}
		}
		else PrezesDialog(playerid);
		return 1;
	}
	if(dialogid==DIALOG_IBIZA_WYPLATA)
	{
		if(response)
		{
			new hajs = strval(inputtext);
			if(hajs <=0) return SendClientMessage(playerid, 0xFF0000FF, "Niepoprawna kwota");
			new sejf = IbizaZawartoscSejfu();
			if(hajs > sejf) return SendClientMessage(playerid, -1, "W sejfie nie ma tyle pieni�dzy");
			DajKase(playerid, hajs); //HAJS  doda� dodawanie pieni�dzy graczowi do struktury
			IbizaWplac(-hajs);
			new string[128];
			format(string, sizeof string, "Wyp�aci�e� %d$ z sejfu Ibizy", hajs);
			SendClientMessage(playerid, -1, string);
            format(string, sizeof string, "Lider %s wyp�aci� %d$ z Ibizy", GetNick(playerid), hajs);
            PayLog(string);
		}
		return ShowPlayerDialogEx(playerid, DIALOG_IBIZA_SEJF, DIALOG_STYLE_LIST, "Sejf Klubu Ibiza", "Zawarto��\nWp�ata\nWyp�ata", "Wybierz", "Wr��");
	}
	if(dialogid==DIALOG_IBIZA_WPLATA)
	{
		if(response)
		{
			new hajs = strval(inputtext);
			if(hajs<=0) return SendClientMessage(playerid, 0xFF0000FF, "Niepoprawna kwota");
			if(hajs > GetPlayerMoney(playerid)) return SendClientMessage(playerid, -1, "Nie masz tyle hajsu"); //HAJS zamieni� GetPlayerMoney na pobranie ze struktury
			DajKase(playerid, -hajs); //HAJS zabra� pieni�dze ze struktury
			IbizaWplac(hajs);
			new string[128];
			format(string, sizeof string, "Wp�aci�e� %d$ do sejfu Ibizy", hajs);
			SendClientMessage(playerid, -1, string);
            format(string, sizeof string, "Lider %s wp�aci� %d$ do Ibizy", GetNick(playerid), hajs);
            PayLog(string);
		}
		return ShowPlayerDialogEx(playerid, DIALOG_IBIZA_SEJF, DIALOG_STYLE_LIST, "Sejf Klubu Ibiza", "Zawarto��\nWp�ata\nWyp�ata", "Wybierz", "Wr��");
	}*/
	if(dialogid==DIALOG_IBIZA_MIKSER)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: //stream
				{
					ShowPlayerDialogEx(playerid, DIALOG_IBIZA_STREAM, DIALOG_STYLE_LIST, "Wyb�r streama", "W�asny link\nClub Party\nEnergy Sound", "Wybierz", "Wr��");
					return 1;
				}
				case 1: //telebim
				{
					ShowPlayerDialogEx(playerid, DIALOG_IBIZA_TELEBIM, DIALOG_STYLE_LIST, "Telebim opcje", "Zmie� tekst\nZmie� kolor\nAnimacja\nCzcionka", "Wybierz", "Wr��");
					return 1;
				}
				case 2: //�wiat�a
				{
					if(IbizaSwiatla)
					{
						WylaczSwiatla();
						IbizaSwiatla = false;
					}
					else
					{
						WlaczSwiatla();
						IbizaSwiatla = true;
					}
				}
				case 3: //strobo
				{
					if(!IbizaStrobo)	 //w��cz
					{

						IbizaStroboObiekty[0] = CreateDynamicObject(354,1930.5400000,-2494.5100000,21.3700000,0.0000000,0.0000000,-5.6400000,1, 0, -1);
						IbizaStroboObiekty[1] = CreateDynamicObject(354,1930.7100000,-2492.0900000,21.1800000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[2] = CreateDynamicObject(354,1930.7100000,-2489.4900000,21.0800000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[3] = CreateDynamicObject(354,1930.7400000,-2487.0700000,21.1700000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[4] = CreateDynamicObject(354,1930.6900000,-2484.4700000,21.3600000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[5] = CreateDynamicObject(354,1934.3000000,-2479.9000000,12.5800000,0.0000000,0.0000000,0.4200000,1, 0, -1);
						IbizaStroboObiekty[6] = CreateDynamicObject(354,1934.3800000,-2499.5800000,12.5500000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[7] = CreateDynamicObject(354,1955.7200000,-2479.9700000,12.5800000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[8] = CreateDynamicObject(354,1955.8100000,-2499.5500000,12.5700000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[9] = CreateDynamicObject(354,1937.4000000,-2467.5600000,21.9100000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[10] = CreateDynamicObject(354,1939.4400000,-2467.4400000,21.9200000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[11] = CreateDynamicObject(354,1941.4900000,-2467.5200000,21.9300000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[12] = CreateDynamicObject(354,1943.4600000,-2467.5500000,21.9200000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[13] = CreateDynamicObject(354,1945.7600000,-2467.7400000,21.9300000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[14] = CreateDynamicObject(354,1935.8700000,-2471.1600000,14.5100000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[15] = CreateDynamicObject(354,1947.6300000,-2471.0700000,14.4900000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[16] = CreateDynamicObject(354,1944.4300000,-2466.3200000,14.4800000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[17] = CreateDynamicObject(354,1939.5800000,-2466.3200000,14.4500000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[18] = CreateDynamicObject(354,1958.4000000,-2470.3600000,14.4600000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[19] = CreateDynamicObject(354,1957.4700000,-2477.8700000,22.1700000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[20] = CreateDynamicObject(354,1958.7100000,-2487.0000000,21.1700000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[21] = CreateDynamicObject(354,1958.6500000,-2488.7100000,21.0900000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[22] = CreateDynamicObject(354,1958.6800000,-2490.2000000,21.1300000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[23] = CreateDynamicObject(354,1958.3500000,-2497.4500000,21.9200000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[24] = CreateDynamicObject(354,1949.5700000,-2503.1500000,23.4000000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[25] = CreateDynamicObject(354,1944.7700000,-2503.3100000,23.3800000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[26] = CreateDynamicObject(354,1942.6700000,-2503.2700000,23.3400000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaStroboObiekty[27] = CreateDynamicObject(354,1937.2100000,-2503.2100000,23.3500000,0.0000000,0.0000000,0.0000000,1, 0, -1);
						IbizaOdswiezObiekty();
						IbizaStrobo = true;
					}
					else //off
					{
						for(new i=0; i<28; i++)
						{
							DestroyDynamicObject(IbizaStroboObiekty[i]);
						}
						IbizaStrobo = false;
					}
				}
				case 4: //dym
				{

					if(!IbizaDym)
					{
						IbizaDymObiekty[0] = CreateDynamicObject(2780,1932.4400000,-2502.9500000,23.7500000,0.0000000,0.0000000,139.2600000, 1, 0, -1, 600.0); //Object number 0
						IbizaDymObiekty[1] = CreateDynamicObject(2780,1958.9700000,-2503.2600000,17.1300000,0.0000000,0.0000000,-132.7800000, 1, 0, -1, 600.0); //Object number 1
						IbizaDymObiekty[2] = CreateDynamicObject(2780,1944.4800000,-2489.7100000,5.3100000,0.0000000,0.0000000,0.0000000, 1, 0, -1, 600.0); //Object number 2
						IbizaDymObiekty[3] = CreateDynamicObject(2780,1941.2600000,-2475.9900000,7.8100000,0.0000000,0.0000000,0.0000000, 1, 0, -1, 600.0); //Object number 3
						IbizaDymObiekty[4] = CreateDynamicObject(2780,1954.3000000,-2496.6800000,5.0900000,0.0000000,0.0000000,0.0000000, 1, 0, -1, 600.0); //Object number 4
						IbizaDymObiekty[5] = CreateDynamicObject(2780,1954.5900000,-2482.4500000,5.9500000,0.0000000,0.0000000,0.0000000, 1, 0, -1, 600.0); //Object number 5						IbizaDymObiekty[6] = CreateDynamicObject(2780,1937.0200000,-2481.9100000,5.6900000,0.0000000,0.0000000,0.0000000, 1, 0, -1, 600.0); //Object number 6
						IbizaDymObiekty[7] = CreateDynamicObject(2780,1937.4100000,-2497.8000000,5.6900000,0.0000000,0.0000000,0.0000000, 1, 0, -1, 600.0); //Object number 7
						IbizaDymObiekty[8] = CreateDynamicObject(2780,1928.8200000,-2472.6500000,20.3400000,0.0000000,0.0000000,132.5400000, 1, 0, -1, 600.0); //Object number 8
						IbizaDymObiekty[9] = CreateDynamicObject(2780,1950.6400000,-2468.2800000,20.7200000,0.0000000,0.0000000,-20.7000000, 1, 0, -1, 600.0); //Object number 9
						IbizaDym = true;
						IbizaOdswiezObiekty();
					}
					else //wy��cz
					{
						for(new i=0; i<10; i++)
						{
							DestroyDynamicObject(IbizaDymObiekty[i]);
						}
						IbizaDym=false;
					}
				}
				case 5: //rury
				{
					if(!IbizaRury) //wysu�
					{
						MoveDynamicObject(IbizaRuryObiekty[0], 1936.6000, -2482.1799, 13.8000, 2.0);
						MoveDynamicObject(IbizaRuryObiekty[1], 1953.6300, -2482.1299, 13.8000, 2.0);
						MoveDynamicObject(IbizaRuryObiekty[2], 1936.5900, -2497.4700, 13.8000, 2.0);
						MoveDynamicObject(IbizaRuryObiekty[3], 1953.6500, -2497.4600, 13.8000, 2.0);
						MoveDynamicObject(IbizaKafle[0], 1936.5900000,-2482.1700000,12.6000, 2.0);
						MoveDynamicObject(IbizaKafle[1],1953.6400000,-2482.1300000,12.6000, 2.0);
						MoveDynamicObject(IbizaKafle[2], 1953.6500000,-2497.4700000,12.6000, 2.0);
						MoveDynamicObject(IbizaKafle[3], 1936.6100000,-2497.4700000,12.6000, 2.0);
						IbizaRury = true;

					}
					else //schowaj
					{
						MoveDynamicObject(IbizaRuryObiekty[0], 1936.6000, -2482.1799, 11.0000, 2.0);
						MoveDynamicObject(IbizaRuryObiekty[1], 1953.6300, -2482.1299, 11.0000, 2.0);
						MoveDynamicObject(IbizaRuryObiekty[2], 1936.5900, -2497.4700, 11.0000, 2.0);
						MoveDynamicObject(IbizaRuryObiekty[3], 1953.6500, -2497.4600, 11.0000, 2.0);
						MoveDynamicObject(IbizaKafle[0], 1936.5900000,-2482.1700000,12.5084, 2.0);
						MoveDynamicObject(IbizaKafle[1],1953.6400000,-2482.1300000,12.5084, 2.0);
						MoveDynamicObject(IbizaKafle[2] ,1953.6500000,-2497.4700000,12.5084, 2.0);
						MoveDynamicObject(IbizaKafle[3], 1936.6100000,-2497.4700000,12.5084, 2.0);
						IbizaRury = false;
					}
				}
			}
			MikserDialog(playerid);
		}
		return 1;
	}

	if(dialogid==DIALOG_IBIZA_STREAM)
	{
		if(response)
		{
			if(listitem==0)
			{
				ShowPlayerDialogEx(playerid, DIALOG_IBIZA_STREAM_WLASNY, DIALOG_STYLE_INPUT, "W�asny stream", "Wklej poni�ej link do streama", "Wybierz", "Wr��");
				return 1;
			}
			else
			{
				IbizaStreamID = listitem;
				WlaczStream(listitem);
			}
		}
		return MikserDialog(playerid);
	}
	if(dialogid==DIALOG_IBIZA_STREAM_WLASNY)
	{
		if(response)
		{
			if(strlen(inputtext) > 128) return SendClientMessage(playerid, -1, "Podany link jest zbyt d�ugi");
			format(IbizaStream[0], 128, "%s", inputtext);
			IbizaStreamID = 0;
			WlaczStream(0);
		}
		else
		{
			ShowPlayerDialogEx(playerid, DIALOG_IBIZA_STREAM, DIALOG_STYLE_LIST, "Wyb�r streama", "W�asny link\nClub Party\nEnergy Sound", "Wybierz", "Wr��");

		}
		return MikserDialog(playerid);
	}

	if(dialogid==DIALOG_IBIZA_TELEBIM)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: //tekst
				{
					ShowPlayerDialogEx(playerid, DIALOG_IBIZA_TEKST, DIALOG_STYLE_INPUT, "Zmiana tekstu", "Wpisz poni�ej takst jaki ma by�\nwy�wietlony na telebimie (MAX 18 znak�w)", "Zmie�", "Wr��");
				}
				case 1: //kolor
				{
					ShowPlayerDialogEx(playerid, DIALOG_IBIZA_KOLOR, DIALOG_STYLE_LIST, "Zmiana koloru", "Bia�y\nPomara�czowy\nNiebieski\nZielony\n��ty", "Zmie�", "Wr��");

				}
				case 2: //animacja
				{
					ShowPlayerDialogEx(playerid, DIALOG_IBIZA_ANIM, DIALOG_STYLE_LIST, "Opcje animacji", "W��cz\nWy��cz", "Zmie�", "Wr��");
				}
				case 3: //czcionka
				{
					ShowPlayerDialogEx(playerid, DIALOG_IBIZA_CZCIONKA, DIALOG_STYLE_LIST, "Wyb�r czcionki", "Arial\nVerdana\nCourier New\nComic Sans MS\nTahoma", "Zmie�", "Wr��");
				}

			}

		}
		else MikserDialog(playerid);

		return 1;

	}
	if(dialogid==DIALOG_IBIZA_ANIM)
	{
		if(response)
		{
			if(listitem == 0)
			{
				if(Telebim[tRuchomy]) return SendClientMessage(playerid, -1, "Animacja jest ju� w�aczona!");
				if(Telebim[tWRuchu] ) return SendClientMessage(playerid, -1, "Poczekaj a� animacja sko�czy sw�j cykl!!!");
				new dl = strlen(Telebim[tTekst]);
				format(Telebim[tTekstAnim], sizeof Telebim[tTekstAnim], "");
				for(new i; i<38+(2*dl); i++)
				{
					format(Telebim[tTekstAnim], sizeof Telebim[tTekstAnim], "%s%s", Telebim[tTekstAnim], IBIZA_WYPELNIENIE);
				}
				format(Telebim[tTekstAnim], sizeof(Telebim[tTekstAnim]), "%s%s|", Telebim[tTekstAnim], Telebim[tTekst]);
				SetDynamicObjectMaterialText(Telebim[tID], 0 , Telebim[tTekstAnim],  Telebim[tSize], Telebim[tCzcionka], Telebim[tFSize], Telebim[tBold], Telebim[tCzcionkaKolor], Telebim[tBackg], Telebim[tAli]);
				Telebim[tRuchomy] = 1;
				Telebim[tWRuchu] = 1;
				SetTimerEx("TelebimAnim", Telebim[tSzybkosc], false, "d", strlen(Telebim[tTekstAnim]));
				SendClientMessage(playerid, -1, "W��czy�e� animacje");
			}
			else
			{
				if(!Telebim[tRuchomy]) return SendClientMessage(playerid, -1, "Animacje jest ju� wy��czona!");
				Telebim[tRuchomy] = 0;
				SendClientMessage(playerid, -1, "Wy��czy�e� animacje");
			}
			MikserDialog(playerid);
		}
		else
		{
			ShowPlayerDialogEx(playerid, DIALOG_IBIZA_TELEBIM, DIALOG_STYLE_LIST, "Telebim opcje", "Zmie� tekst\nZmie� kolor\nAnimacja\nCzcionka", "Wybierz", "Wr��");
		}
		return 1;

	}
	if(dialogid==DIALOG_IBIZA_CZCIONKA)
	{
		if(response)
		{
			format(Telebim[tCzcionka], sizeof Telebim[tCzcionka], "%s", IbizaCzcionkiTelebim[listitem]);
			SetDynamicObjectMaterialText(Telebim[tID], 0 , Telebim[tTekst],  Telebim[tSize], Telebim[tCzcionka], Telebim[tFSize], Telebim[tBold], Telebim[tCzcionkaKolor], Telebim[tBackg], Telebim[tAli]);
			SendClientMessage(playerid, -1, "Zmieni�e� czcionk�");
			MikserDialog(playerid);
		}
		else
		{
			ShowPlayerDialogEx(playerid, DIALOG_IBIZA_TELEBIM, DIALOG_STYLE_LIST, "Telebim opcje", "Zmie� tekst\nZmie� kolor\nAnimacja\nCzcionka", "Wybierz", "Wr��");
		}
		return 1;

	}
	if(dialogid==DIALOG_IBIZA_KOLOR)
	{
		if(response)
		{
			Telebim[tCzcionkaKolor] = IbizaKoloryTelebim[listitem];
			SetDynamicObjectMaterialText(Telebim[tID], 0 , Telebim[tTekst],  Telebim[tSize], Telebim[tCzcionka], Telebim[tFSize], Telebim[tBold], Telebim[tCzcionkaKolor], Telebim[tBackg], Telebim[tAli]);
			SendClientMessage(playerid, -1, "Zmieni�e� kolor napisu");
			MikserDialog(playerid);
		}
		else
		{
			ShowPlayerDialogEx(playerid, DIALOG_IBIZA_TELEBIM, DIALOG_STYLE_LIST, "Telebim opcje", "Zmie� tekst\nZmie� kolor\nAnimacja\nCzcionka", "Wybierz", "Wr��");
		}
		return 1;
	}
	if(dialogid==DIALOG_IBIZA_TEKST)
	{
		if(response)
		{
			if( strlen(inputtext) > DLUGOSC_TELEBIMA-1 )
			{
				SendClientMessage(playerid, 0xFF0000FF, "Podany tekst jest za d�ugi");
				ShowPlayerDialogEx(playerid, DIALOG_IBIZA_TEKST, DIALOG_STYLE_INPUT, "Zmiana tekstu", "Wpisz poni�ej takst jaki ma by�\nwy�wietlony na telebimie (MAX 18 znak�w)", "Ustaw", "Anuluj");
			}
			else
			{
				if(Telebim[tRuchomy] || Telebim[tWRuchu] ) return SendClientMessage(playerid, -1, "Nie mo�esz zmieni� tekstu podczas dzia�ania animacji, najpierw j� zatrzymaj!");
				format(Telebim[tTekst], sizeof Telebim[tTekst], "%s", inputtext);
				SetDynamicObjectMaterialText(Telebim[tID], 0 , Telebim[tTekst],  Telebim[tSize], Telebim[tCzcionka], Telebim[tFSize], Telebim[tBold], Telebim[tCzcionkaKolor], Telebim[tBackg], Telebim[tAli]);
				SendClientMessage(playerid, 0x00FF00FF, "Zmieni�e� napis na telebimie");
				MikserDialog(playerid);

			}
			return 1;
		}
		else
		{
			ShowPlayerDialogEx(playerid, DIALOG_IBIZA_TELEBIM, DIALOG_STYLE_LIST, "Telebim opcje", "Zmie� tekst\nZmie� kolor\nAnimacja\nCzcionka", "Wybierz", "Wr��");
			return 1;
		}
	}

	if(dialogid==DIALOG_IBIZA_BILET)
	{
		new string[128];
		new id = GetPVarInt(playerid, "IbizaBiletSell");
		if(response)
		{
			//if(PlayerInfo[playerid][pCash] < IbizaBilet) return SendClientMessage(playerid, -1, "Nie masz wystarczaj�cej ilo�ci pieni�dzy");
			new hajs = kaska[playerid]; //HAJS - zamiast GetPlayerMoney pobranie hajsu ze struktury
			if(hajs < IbizaBilet)
			{
				SendClientMessage(id, -1, "Ten gracz nie ma tyle kasy");
				return SendClientMessage(playerid, -1, "Nie masz wystarczaj�cej ilo�ci pieni�dzy");
			}
			else
			{
				//PlayerInfo[playerid][pCash]-=IbizaBilet;
				ZabierzKase(playerid, IbizaBilet); //HAJS co� takiego jak wy�ej, nwm dok�adnie jak macie
				SejfR_Add(FAMILY_IBIZA, IbizaBilet);
				SetPVarInt(playerid, "IbizaBilet", 1);
				format(string, sizeof string, "%s kupi�� od Ciebie bilet", PlayerName(playerid));
				SendClientMessage(id, 0x0080D0FF, string);
				format(string, sizeof string, "Kupi�e� bilet do Ibiza Club za %d$", IbizaBilet);
				SendClientMessage(playerid, 0x00FF00FF, string);
			}
		}
		else
		{
			format(string, sizeof string, "Gracz %s nie zgodzi�� si� na kupno biletu", PlayerName(playerid));
			SendClientMessage(id, 0xFF0030FF, string);

		}
		DeletePVar(playerid, "IbizaBiletSell");
		return 1;
	}
	if(dialogid==DIALOG_IBIZA_BAR)
	{
		new string[128];
		new id = GetPVarInt(playerid, "IbizaBar");
		if(response)
		{

			new hajs = kaska[playerid]; //HAJS zmieni� na pobieranie ze struktury
			new drink = GetPVarInt(playerid, "IbizaDrink");
			if(hajs >=IbizaDrinkiCeny[drink]) //if(PlayerInfo[playerid][pCash] >= IbizaDrinkiCeny[drink] )
			{
				ZabierzKase(playerid, IbizaDrinkiCeny[drink]); //HAJS zabranie pieni�dzy ze struktury
				SejfR_Add(FAMILY_IBIZA, IbizaDrinkiCeny[drink]);
				SetPlayerSpecialAction(playerid, 22);
				//DO   **Marcepan_Marks kupuje w barze [nazwa drinka]**

			}
			else
			{
				SendClientMessage(playerid, -1, "Nie masz wystarczaj�cej ilo�ci pieni�dzy");
				format(string, sizeof string, "Klient %s nie ma tyle pieni�dzy", PlayerName(playerid));
				SendClientMessage(id, 0xB52E2BFF, string);
			}


		}
		else
		{
			format(string, sizeof string, "Gracz %s nie zgodzi�� si� na kupno drinka", PlayerName(playerid));
			SendClientMessage(id, 0xB52E2BFF, string);
		}
		DeletePVar(playerid, "IbizaBar");
		DeletePVar(playerid, "IbizaDrink");
		return 1;
	}
    if(dialogid == DIALOG_ELEVATOR_SAD)
    {
        if(response)
        {
			switch(listitem)
			{
			    case 0:
				{
				    if(SadWindap1 == 0 || GetPlayerOrg(playerid) == FAMILY_SAD)
					{
				    	SetPlayerPosEx(playerid, 1327.6746, -1324.7770, 39.9210);
				    	GameTextForPlayer(playerid, "~r~Hol sadu ~n~ by abram01", 6000, 1);
				    	SetPlayerVirtualWorld ( playerid, 500 );
                    	Wchodzenie(playerid);
                    	SetPlayerWeather(playerid, 3);//Pogoda
            			SetPlayerTime(playerid, 14, 0);//Czas
					}
					else sendErrorMessage(playerid, "Ten poziom zosta� zablokowany przez pracownika S�du!");
				}
				case 1:
    			{
    			    if(SadWindap2 == 0 || GetPlayerOrg(playerid) == FAMILY_SAD)
					{
						SetPlayerPosEx(playerid, 1289.0969, -1292.7489, 35.9681);
						GameTextForPlayer(playerid, "~r~Sad Stanu San Andreas ~n~ by abram01", 6000, 1);
						SetPlayerVirtualWorld (playerid, 501 );
                    	Wchodzenie(playerid);
                    	SetPlayerWeather(playerid, 3);//Pogoda
            			SetPlayerTime(playerid, 14, 0);//Czas
                    }
					else sendErrorMessage(playerid, "Ten poziom zosta� zablokowany przez pracownika S�du!");
				}
				case 2:
				{
				    if(SadWindap3 == 0 || GetPlayerOrg(playerid) == FAMILY_SAD)
					{
				    	SetPlayerPosEx(playerid,1310.3494, -1361.7319, 39.0876);
				    	GameTextForPlayer(playerid, "~r~Biura urzednikow sadowych ~n~ by abram01", 8000, 1);
				    	SetPlayerVirtualWorld ( playerid, 502 );
                    	Wchodzenie(playerid);
                    	SetPlayerWeather(playerid, 3);//Pogoda
            			SetPlayerTime(playerid, 14, 0);//Czas
                    }
					else sendErrorMessage(playerid, "Ten poziom zosta� zablokowany przez pracownika S�du!");
				}
                case 3:
				{
				    if(SadWindap4 == 0 || GetPlayerOrg(playerid) == FAMILY_SAD)
					{
				    	SetPlayerPosEx(playerid,1310.0021, -1319.7189, 35.5984);
				    	SetPlayerVirtualWorld ( playerid, 0 );
				    	SetPlayerWeather(playerid, ServerWeather);
    					SetPlayerTime(playerid, ServerTime, 0);
                    	Wchodzenie(playerid);
                    }
					else sendErrorMessage(playerid, "Ten poziom zosta� zablokowany przez pracownika S�du!");

				}
			}
		}
	}
    else if(dialogid == D_SERVERINFO)
    {
        if(response) return 1;
        TextDrawHideForPlayer(playerid, TXD_Info);
        return 1;
    }
    else if(dialogid == D_ORGS)
    {
        if(!response) return 1;
        new lStr[512];
        for(new i=0;i<MAX_ORG;i++)
        {
            if(!orgIsValid(i)) continue;
            if(orgType(i) == listitem)
            {
                format(lStr, 512, "%s{000000}%d\t{FFFFFF}%s\n", lStr, OrgInfo[i][o_UID], OrgInfo[i][o_Name]);
            }
        }
        if(strlen(lStr) > 3)
        {
            ShowPlayerDialogEx(playerid, D_ORGS_SELECT, DIALOG_STYLE_LIST, "Lista organizacji", lStr, "Cz�onkowie", "Wr��");
        }
        return 1;
    }
    else if(dialogid == D_ORGS_SELECT)
    {
        if(!response) return RunCommand(playerid, "/organizacje",  "");
        new id = strval(inputtext);
        new lStr[16];
        valstr(lStr, id);
        RunCommand(playerid, "/organizacje",  lStr);
        return 1;
    }
    else if(dialogid == D_CREATE)
    {
        if(!response) return 1;
        new lStr[256];
        switch(listitem)
        {
            case 1:
            {
                if(!Uprawnienia(playerid, ACCESS_MAKEFAMILY)) return SendClientMessage(playerid, COLOR_RED, "Brak uprawnie�");
                for(new i=0;i<sizeof(OrgTypes);i++)
                {
                    format(lStr, 256, "%s%d.\t%s\n", lStr, i+1, OrgTypes[i]);
                }
                ShowPlayerDialogEx(playerid, D_CREATE_ORG, DIALOG_STYLE_LIST, "Tworzenie organizacji", lStr, "Dalej", "Wr��");
            }
        }
        return 1;
    }
    else if(dialogid == D_EDIT)
    {
        if(!response) return 1;
        new lStr[1024];
        switch(listitem)
        {
            case 1:
            {
                if(!Uprawnienia(playerid, ACCESS_MAKEFAMILY)) return SendClientMessage(playerid, COLOR_RED, "Brak uprawnie�");
                for(new i=0;i<MAX_ORG;i++)
                {
                    if(!orgIsValid(i)) continue;
                    format(lStr, 1024, "%s%d.\t%s\n", lStr, i, OrgInfo[i][o_Name]);
                }
                ShowPlayerDialogEx(playerid, D_EDIT_ORG, DIALOG_STYLE_LIST, "Edycja organizacji", lStr, "Dalej", "Wr��");
            }
            case 2:
            {
                if(!Uprawnienia(playerid, ACCESS_EDITCAR)) return SendClientMessage(playerid, COLOR_RED, "Brak uprawnie�");
                new Float:x, Float:y, Float:z;
                GetPlayerPos(playerid, x ,y ,z);
                for(new i=0;i<MAX_VEHICLES;i++)
                {
                    if(VehicleUID[i][vUID] == 0) continue;
                    if(GetVehicleDistanceFromPoint(i, x, y, z) < 15.0)
                    {
                        format(lStr, 1024, "%s%d � %s (%d)\n", lStr, CarData[VehicleUID[i][vUID]][c_UID], VehicleNames[GetVehicleModel(i)-400], i);
                    }
                }
                strcat(lStr, "Wprowad� UID pojazdu, kt�ry chcesz edytowa�:");
                ShowPlayerDialogEx(playerid, D_EDIT_CAR, DIALOG_STYLE_INPUT, "{8FCB04}Edycja {FFFFFF}pojazd�w", lStr, "Dalej", "Wr��");
            }
            case 3:
            {
                if(!Uprawnienia(playerid, ACCESS_EDITRANG)) return SendClientMessage(playerid, COLOR_RED, "Brak uprawnie�");

                ShowPlayerDialogEx(playerid, D_EDIT_RANG, DIALOG_STYLE_LIST, "{8FCB04}Edycja {FFFFFF}rang", "Frakcja\nOrganizacja", "Wybierz", "Wr��");
            }
        }
        return 1;
    }
    //TWORZENIE ORGANIZACJI
    else if(dialogid == D_CREATE_ORG)
    {
        if(!response) return RunCommand(playerid, "/stworz",  "");
        SetPVarInt(playerid, "create_org_typ", listitem);
        ShowPlayerDialogEx(playerid, D_CREATE_ORG_NAME, DIALOG_STYLE_INPUT, "Tworzenie organizacji", "Wprowadz nazw� rodziny:", "Dalej", "Wr��");
        return 1;
    }
    else if(dialogid == D_CREATE_ORG_NAME)
    {
        if(!response) return RunCommand(playerid, "/stworz",  "");
        if(strlen(inputtext) > 31 || strlen(inputtext) < 1) return ShowPlayerDialogEx(playerid, D_CREATE_ORG_NAME, DIALOG_STYLE_INPUT, "Tworzenie organizacji", "Wprowadz nazw� rodziny:", "Dalej", "Wr��");
        SetPVarString(playerid, "create_org_name", inputtext);
        new lStr[256] = "Wybierz wolny slot (ID)\n";
        new lTab[MAX_ORG];
        for(new i=0;i<MAX_ORG;i++)
        {
            if(OrgInfo[i][o_UID] != 0)
            {
                lTab[i] = OrgInfo[i][o_UID];
            }
        }
        new bool:lFree=true;
        for(new i=1;i<=MAX_ORG;i++)
        {
            lFree=true;
            for(new j=0;j<MAX_ORG;j++) if(lTab[j] == i) lFree=false;

            if(lFree) format(lStr, 256, "%s%d\n", lStr, i);
        }
        ShowPlayerDialogEx(playerid, D_CREATE_ORG_UID, DIALOG_STYLE_LIST, "Tworzenie organizacji", lStr, "Dalej", "Wr��");
        return 1;
    }
    else if(dialogid == D_CREATE_ORG_UID)
    {
        if(!response) return ShowPlayerDialogEx(playerid, D_CREATE_ORG_NAME, DIALOG_STYLE_INPUT, "Tworzenie organizacji", "Wprowadz nazw� rodziny:", "Dalej", "Wr��");
        new id = strval(inputtext);
        if(orgIsValid(orgID(id))) return SendClientMessage(playerid, -1, "Kolizja UID?");
        new lStr[128];
        GetPVarString(playerid, "create_org_name", lStr, 32);
        orgAdd(GetPVarInt(playerid, "create_org_typ"),lStr, id, orgGetFreeSlot());
        format(lStr, 128, "Stworzono organizacj� typu %s o nazwie %s UID %d", OrgTypes[GetPVarInt(playerid, "create_org_typ")], lStr, id);
        SendClientMessage(playerid, COLOR_GREEN, lStr);
        return 1;
    }
    //EDYCJA ORGANIZACJI
    else if(dialogid == D_EDIT_ORG)
    {
        if(!response) return RunCommand(playerid, "/edytuj",  "");
        SetPVarInt(playerid, "edit_org", strval(inputtext));
        ShowPlayerDialogEx(playerid, D_EDIT_ORG_LIST, DIALOG_STYLE_LIST, "Edycja organizacji", "Zmie� typ\nZmie� nazw�\nUsu� lidera(�w)\nUsu� organizacje", "Wybierz", "Wr��");
        return 1;
    }
    else if(dialogid == D_EDIT_ORG_LIST)
    {
        if(!response) return RunCommand(playerid, "/edytuj",  "");
        new lStr[256];
        switch(listitem)
        {
            case 0:
            {
                for(new i=0;i<sizeof(OrgTypes);i++)
                {
                    format(lStr, 256, "%s%d.\t%s\n", lStr, i+1, OrgTypes[i]);
                    ShowPlayerDialogEx(playerid, D_EDIT_ORG_TYP, DIALOG_STYLE_LIST, "Edycja", lStr, "Zmie�", "Wr��");
                }
            }
            case 1:
            {
                ShowPlayerDialogEx(playerid, D_EDIT_ORG_NAME, DIALOG_STYLE_INPUT, "Edycja", "Wprowad� now� nazw�", "Zmie�", "Wr��");
            }
            case 2:
            {
                SendClientMessage(playerid, COLOR_GREEN, "W budowie");
            }
            case 3:
            {
                if(!Uprawnienia(playerid, ACCESS_DELETEORG)) return SendClientMessage(playerid, COLOR_RED, "Brak uprawnie�");
                ShowPlayerDialogEx(playerid, D_EDIT_ORG_DELETE, DIALOG_STYLE_MSGBOX, "Potwierdzenie", "Czy na pewno chcesz usun�� organizacj�?", "Usu�", "Wr��");
            }
        }
        return 1;
    }
    else if(dialogid == D_EDIT_ORG_TYP)
    {
        if(!response) return RunCommand(playerid, "/edytuj",  "");
        new id = GetPVarInt(playerid, "edit_org"), lStr[128];
        OrgInfo[id][o_Type] = listitem;
        format(lStr, 128, "Zmieniono typ organizacji %s na %s", OrgInfo[id][o_Name], OrgTypes[listitem]);
        SendClientMessage(playerid, COLOR_GREEN, lStr);

        orgSave(id, ORG_SAVE_TYPE_BASIC);
        return 1;
    }
    else if(dialogid == D_EDIT_ORG_NAME)
    {
        if(!response) return RunCommand(playerid, "/edytuj",  "");
        new id = GetPVarInt(playerid, "edit_org"), lStr[128];
        if(strlen(inputtext) > 31 || strlen(inputtext) < 1) return ShowPlayerDialogEx(playerid, D_EDIT_ORG_NAME, DIALOG_STYLE_INPUT, "Edycja", "Wprowad� now� nazw�", "Zmie�", "Wr��");
        format(lStr, 128, "Zmieniono nazw� organizacji %s na %s", OrgInfo[id][o_Name], inputtext);
        SendClientMessage(playerid, COLOR_GREEN, lStr);
        orgSetName(id, inputtext);

        orgSave(id, ORG_SAVE_TYPE_DESC);
        return 1;
    }
    else if(dialogid == D_EDIT_ORG_DELETE)
    {
        if(!response) return RunCommand(playerid, "/edytuj",  "");
        new id = GetPVarInt(playerid, "edit_org"), lStr[128];
        format(lStr, 128, "Usuni�to organizacj� %s.", OrgInfo[id][o_Name]);
        SendClientMessage(playerid, COLOR_GREEN, lStr);
        format(lStr, 128, "Organizacja usuni�ta przez %s.", GetNick(playerid));
        foreach(new i : Player)
        {
            if(GetPlayerOrg(i) == OrgInfo[id][o_UID])
            {
                SendClientMessage(i, COLOR_RED, lStr);
                orgUnInvitePlayer(i);
            }
        }

        format(lStr, 128, "UPDATE `mru_konta` SET `FMember`=0, `Rank`=0 WHERE `FMember`='%d'", OrgInfo[id][o_UID]);
        mysql_query(lStr);

        format(lStr, 128, "DELETE FROM `mru_org` WHERE `UID`='%d'", OrgInfo[id][o_UID]);
        mysql_query(lStr);

        format(lStr, 128, "UPDATE `mru_strefy` SET `gang`=0 WHERE `gang`='%d'", OrgInfo[id][o_UID]);
        mysql_query(lStr);

        for(new j=0;j<MAX_ZONES;j++)
        {
            if(ZoneControl[j]-100 == OrgInfo[id][o_UID])
            {
                GangZoneShowForAll(j, 0xC6E2F144);
                ZoneControl[j] = 0;
            }
        }

        OrgInfo[id][o_UID] = 0;
        OrgInfo[id][o_Type] = 0;
        strdel(OrgInfo[id][o_Name], 0, 32);
        strdel(OrgInfo[id][o_Motd], 0, 128);
        return 1;
    }
    //EDYCJA POJAZD�W
    else if(dialogid == D_EDIT_CAR)
    {
        if(!response) return RunCommand(playerid, "/edytuj",  "");
        new lStr[1024];
        if(strval(inputtext) == 0)
        {
            new Float:x, Float:y, Float:z;
            GetPlayerPos(playerid, x ,y ,z);
            for(new i=0;i<MAX_VEHICLES;i++)
            {
                if(VehicleUID[i][vUID] == 0) continue;
                if(GetVehicleDistanceFromPoint(i, x, y, z) < 15.0)
                {
                    format(lStr, 1024, "%s%d � %s (%d)\n", lStr, CarData[VehicleUID[i][vUID]][c_UID], VehicleNames[GetVehicleModel(i)-400], i);
                }
            }
            strcat(lStr, "Wprowad� UID pojazdu, kt�ry chcesz edytowa�:");
            ShowPlayerDialogEx(playerid, D_EDIT_CAR, DIALOG_STYLE_INPUT, "Edycja pojazd�w", lStr, "Dalej", "Wr��");
            return 1;
        }
        new lID = Car_GetIDXFromUID(strval(inputtext));
        if(lID == -1)
        {
            SendClientMessage(playerid, COLOR_GRAD2, "Pojazd nie by� wczytany do systemu, inicjalizacja ...");
            lID = Car_LoadEx(strval(inputtext));
            if(lID == -1) return SendClientMessage(playerid, COLOR_GRAD2, "... brak pojazdu w bazie.");
        }

        SetPVarInt(playerid, "edit-car", lID);
        ShowCarEditDialog(playerid);
        return 1;
    }
    else if(dialogid == D_EDIT_CAR_MENU)
    {
        if(!response) return RunCommand(playerid, "/edytuj",  "");
        new car = GetPVarInt(playerid, "edit-car");
        if(CarData[car][c_UID] == 0) return 1;
        switch(listitem)
        {
            case 0:
            {
                ShowPlayerDialogEx(playerid, D_EDIT_CAR_MODEL, DIALOG_STYLE_INPUT, "{8FCB04}Edycja {FFFFFF}pojazd�w", "Wprowad� model pojazdu:", "Ustaw", "Wr��");
            }
            case 1:
            {
                ShowPlayerDialogEx(playerid, D_EDIT_CAR_OWNER, DIALOG_STYLE_LIST, "{8FCB04}Edycja {FFFFFF}pojazd�w", "Brak\nFrakcja\nOrganizacja\nGracz\nPraca\nSpecjalny\nPubliczny", "Wybierz", "Wr��");
            }
            case 2:
            {
                ShowPlayerDialogEx(playerid, D_EDIT_CAR_RANG, DIALOG_STYLE_INPUT, "{8FCB04}Edycja {FFFFFF}pojazd�w", "Wprowad� rang� (dla frakcji/org) lub skill dla pracy:", "Ustaw", "Wr��");
            }
			case 3:
			{
				ShowPlayerDialogEx(playerid, 1089, DIALOG_STYLE_INPUT, "{8FCB04}Edycja {FFFFFF}opisu", "Wprowad� nowy opis dla pojazdu:", "Ustaw", "Wr��");
			}
            case 4:
            {
                CarData[car][c_HP] = 1000.0;
                if(CarData[car][c_ID] != 0)
                {
                    SetVehicleHealth(CarData[car][c_ID], 1000.0);
                }
                Car_Save(car, CAR_SAVE_STATE);
            }
            case 5:
            {
				new VW = GetPlayerVirtualWorld(playerid);
                new veh = CarData[car][c_ID];
                new Float:X, Float:Y, Float:Z, Float:A;
                GetVehiclePos(veh, X, Y, Z);
                GetVehicleZAngle(veh, A);
                CarData[car][c_Pos][0] = X;
                CarData[car][c_Pos][1] = Y;
                CarData[car][c_Pos][2] = Z;
				CarData[car][c_VW] = VW; //Zapisywanie VirtualWorldu
                CarData[car][c_Rot] = A;
                Car_Save(CarData[car][c_ID], CAR_SAVE_STATE);
                Car_Unspawn(veh);
                Car_Spawn(car);
                new string[128];
				format(string, 128, "Zmieniono parking dla pojazdu %s [ID: %d] [UID: %d] [VW: %d]", VehicleNames[GetVehicleModel(veh)-400], veh, CarData[car][c_UID], CarData[car][c_VW]);
				SendClientMessage(playerid, 0xFFC0CB, string);
            }
            case 6:
            {
                CarData[car][c_Keys] = 0;
                Car_Save(car, CAR_SAVE_OWNER);
            }
            case 7:
            {
                SetPVarInt(playerid, "car_edit_color", 1);
                ShowPlayerDialogEx(playerid, D_EDIT_CAR_COLOR, DIALOG_STYLE_INPUT, "{8FCB04}Edycja {FFFFFF}pojazd�w", "Podaj nowy kolor (od 0 do 255).", "Ustaw", "Wr��");
            }
            case 8:
            {
                SetPVarInt(playerid, "car_edit_color", 2);
                ShowPlayerDialogEx(playerid, D_EDIT_CAR_COLOR, DIALOG_STYLE_INPUT, "{8FCB04}Edycja {FFFFFF}pojazd�w", "Podaj nowy kolor (od 0 do 255).", "Ustaw", "Wr��");
            }
        }
        return 1;
    }
	else if(dialogid == 1089)
	{
		if(!response) return ShowCarEditDialog(playerid);
		sendTipMessage(playerid, "Trwaj� prace!"); 
	
		return 1;
	}
    else if(dialogid == D_EDIT_CAR_MODEL)
    {
        if(!response) return ShowCarEditDialog(playerid);
        if(strval(inputtext) < 400 || strval(inputtext) > 611)
        {
            SendClientMessage(playerid, COLOR_GRAD2, "Nieprawid�owy model pojazdu.");
            return ShowCarEditDialog(playerid);
        }
        new car = GetPVarInt(playerid, "edit-car");
        new Float:x, Float:y, Float:z, Float:a, bool:dotp=false;
        if(CarData[car][c_ID] != 0)
        {
            GetVehiclePos(CarData[car][c_ID], x, y, z);
            GetVehicleZAngle(CarData[car][c_ID], a);
            Car_Unspawn(CarData[car][c_ID], true);
            dotp=true;
        }
		new oldmodel = CarData[car][c_Model];
        CarData[car][c_Model] = strval(inputtext);
        Car_Save(car, CAR_SAVE_STATE);
        if(dotp)
        {
            Car_Spawn(car);
            SetVehiclePos(CarData[car][c_ID], x, y, z);
            SetVehicleZAngle(CarData[car][c_ID], a);
        }
		
		//logi
		new string[128];
		format(string, sizeof(string), "%s zmienil model pojazdu %d z %d na %d", GetNick(playerid), CarData[car][c_UID], oldmodel, CarData[car][c_Model]);
		ActionLog(string);
        return 1;
    }
    else if(dialogid == D_EDIT_CAR_RANG)
    {
        if(!response) return ShowCarEditDialog(playerid);
        if(strval(inputtext) < 0)
        {
            SendClientMessage(playerid, COLOR_GRAD2, "Nieprawid�owa ranga.");
            return ShowCarEditDialog(playerid);
        }
        new car = GetPVarInt(playerid, "edit-car");

        CarData[car][c_Rang] = strval(inputtext);
        Car_Save(car, CAR_SAVE_OWNER);
        ShowCarEditDialog(playerid);
        return 1;
    }
    else if(dialogid == D_EDIT_CAR_OWNER)
    {
        if(!response) return ShowCarEditDialog(playerid);
        SetPVarInt(playerid, "edit_car_ownertype", listitem);
        new car = GetPVarInt(playerid, "edit-car");
        new string[512];
        switch(listitem)
        {
            case 0:
            {
                new lSlot;
                if(CarData[car][c_OwnerType] == CAR_OWNER_PLAYER)
                {
                    new lUID = Car_GetOwner(car);
					if(lUID != 0)
					{
						foreach(new i : Player)
						{
							if(PlayerInfo[i][pUID] == lUID)
							{
								for(new j=0;j<MAX_CAR_SLOT;j++)
								{
									if(PlayerInfo[i][pCars][j] == car)
									{
										PlayerInfo[i][pCars][j] = 0;
										lSlot = j+1;
										break;
									}
								}

								format(string, sizeof(string), " Usuni�to pojazd ze slotu %d graczowi %s.", lSlot, GetNick(i));
								SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
								format(string, sizeof(string), "%s usun�� pojazd %s ze slotu %d (UID: %d) /edytuj - pojazd", GetNick(playerid), GetNick(i), lSlot, lUID);
								StatsLog(string);

								//Car_SortPlayerCars(i);
								break;
							}
						}
					}
                }
                CarData[car][c_OwnerType] = 0;
                Car_Save(car, CAR_SAVE_OWNER);
				
				format(string, sizeof(string), "Wykonano zmiane pojazdu %d ownertype 0 - %s", car, GetNick(playerid));
				StatsLog(string);
            }
            case 1:
            {
                for(new i=0;i<sizeof(FractionNames);i++)
                {
                    format(string, 512, "%s%d\t%s\n", string, i, FractionNames[i]);
                }
                ShowPlayerDialogEx(playerid, D_EDIT_CAR_OWNER_APPLY, DIALOG_STYLE_INPUT, "{8FCB04}Edycja {FFFFFF}pojazd�w", string, "Ustaw", "Wr��");
                return 1;
            }
            case 2:
            {
                ShowPlayerDialogEx(playerid, D_EDIT_CAR_OWNER_APPLY, DIALOG_STYLE_INPUT, "{8FCB04}Edycja {FFFFFF}pojazd�w", "Podaj UID organizacji:", "Ustaw", "Wr��");
                return 1;
            }
            case 3:
            {
                ShowPlayerDialogEx(playerid, D_EDIT_CAR_OWNER_APPLY, DIALOG_STYLE_INPUT, "{8FCB04}Edycja {FFFFFF}pojazd�w", "Podaj UID gracza:", "Ustaw", "Wr��");
                return 1;
            }
            case 4:
            {
                ShowPlayerDialogEx(playerid, D_EDIT_CAR_OWNER_APPLY, DIALOG_STYLE_INPUT, "{8FCB04}Edycja {FFFFFF}pojazd�w", "Podaj ID pracy:", "Ustaw", "Wr��");
                return 1;
            }
            case 5:
            {
                ShowPlayerDialogEx(playerid, D_EDIT_CAR_OWNER_APPLY, DIALOG_STYLE_INPUT, "{8FCB04}Edycja {FFFFFF}pojazd�w", "Podaj typ pojazdu specjalnego:\n\n1. Wypo�yczalnia\n2. GoKart\n3. �u�el", "Ustaw", "Wr��");
                return 1;
            }
            case 6:
            {
                new lSlot;
                if(CarData[car][c_OwnerType] == CAR_OWNER_PLAYER)
                {
                    new lUID = Car_GetOwner(car);
					if(lUID != 0)
					{
						foreach(new i : Player)
						{
							if(PlayerInfo[i][pUID] == lUID)
							{
								for(new j=0;j<MAX_CAR_SLOT;j++)
								{
									if(PlayerInfo[i][pCars][j] == car)
									{
										PlayerInfo[i][pCars][j] = 0;
										lSlot = j+1;
										break;
									}
								}

								format(string, sizeof(string), " Usuni�to pojazd ze slotu %d graczowi %s.", lSlot, GetNick(i));
								SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
								format(string, sizeof(string), "%s usun�� pojazd %s ze slotu %d (UID: %d) /edytuj - pojazd", GetNick(playerid), GetNick(i), lSlot, lUID);
								StatsLog(string);

								//Car_SortPlayerCars(i);
								break;
							}
						}
					}
                }
                CarData[car][c_OwnerType] = 6;
                Car_Save(car, CAR_SAVE_OWNER);
				
				format(string, sizeof(string), "Wykonano zmiane pojazdu %d ownertype 6 - %s", car, GetNick(playerid));
				StatsLog(string);
            }
        }
        ShowCarEditDialog(playerid);
        return 1;
    }
    else if(dialogid == D_EDIT_CAR_OWNER_APPLY)
    {
        if(!response) return ShowCarEditDialog(playerid);
        new typ = GetPVarInt(playerid, "edit_car_ownertype");
        new car = GetPVarInt(playerid, "edit-car");
        if(strval(inputtext) < 0) return ShowCarEditDialog(playerid);

        new lSlot, string[128];
        if(CarData[car][c_OwnerType] == CAR_OWNER_PLAYER)
        {
            new lUID = Car_GetOwner(car);
			if(lUID != 0)
			{
				foreach(new i : Player)
				{
					if(PlayerInfo[i][pUID] == lUID)
					{
						for(new j=0;j<MAX_CAR_SLOT;j++)
						{
							if(PlayerInfo[i][pCars][j] == car)
							{
								PlayerInfo[i][pCars][j] = 0;
								lSlot = j+1;
								break;
							}
						}

						format(string, sizeof(string), " Usuni�to pojazd ze slotu %d graczowi %s.", lSlot, GetNick(i));
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "%s usun�� pojazd %s ze slotu %d (UID: %d) /edytuj - pojazd", GetNick(playerid), GetNick(i), lSlot, lUID);
						StatsLog(string);

						//Car_SortPlayerCars(i);
						break;
					}
				}
			}
        }
		
        if(typ == CAR_OWNER_PLAYER)
        {
            foreach(new i : Player)
            {
                if(PlayerInfo[i][pUID] == strval(inputtext))
                {
                    Car_MakePlayerOwner(i, car);
                    break;
                }
            }
        }
		CarData[car][c_OwnerType] = typ;
		CarData[car][c_Owner] = strval(inputtext);
		
		format(string, sizeof(string), "Wykonano zmiane pojazdu %d ownertype %d owner %d - %s", car, typ, strval(inputtext), GetNick(playerid));
		StatsLog(string);
		Car_Save(car, CAR_SAVE_OWNER);
		
        ShowCarEditDialog(playerid);
        return 1;
    }
    else if(dialogid == D_EDIT_CAR_COLOR)
    {
        if(!response) return ShowCarEditDialog(playerid);
        if(strval(inputtext) < 0 || strval(inputtext) > 255)
        {
            SendClientMessage(playerid, COLOR_GRAD2, "Nieprawid�owy kolor.");
            return ShowCarEditDialog(playerid);
        }
        new car = GetPVarInt(playerid, "edit-car");

        if(GetPVarInt(playerid, "car_edit_color") == 1)
		{
			MRP_ChangeVehicleColor(CarData[car][c_ID], strval(inputtext), CarData[car][c_Color][1]);
            ChangeVehicleColor(CarData[car][c_ID], strval(inputtext), CarData[car][c_Color][1]);
		}
        else
		{
			MRP_ChangeVehicleColor(CarData[car][c_ID], CarData[car][c_Color][0], strval(inputtext));
            ChangeVehicleColor(CarData[car][c_ID], CarData[car][c_Color][0], strval(inputtext));
		}

        ShowCarEditDialog(playerid);
        return 1;
    }
    //EDYCJA    RANG
    else if(dialogid == D_EDIT_RANG)
    {
        if(!response) return RunCommand(playerid, "/edytuj",  "");
        new string[512];
        SetPVarInt(playerid, "edit_rang_typ", listitem);
        if(listitem == 0)
        {
            for(new i=0;i<sizeof(FractionNames);i++)
            {
                format(string, 512, "%s%d\t%s\n", string, i, FractionNames[i]);
            }
            format(string, 512, "%s\n\nWprowad� UID frakcji:", string);
            ShowPlayerDialogEx(playerid, D_EDIT_RANG_2, DIALOG_STYLE_INPUT, "{8FCB04}Edycja {FFFFFF}rang", string, "Wybierz", "Wr��");
        }
        else
        {
            ShowPlayerDialogEx(playerid, D_EDIT_RANG_2, DIALOG_STYLE_INPUT, "{8FCB04}Edycja {FFFFFF}rang", "Wprowad� UID organizacji (/rodziny UID):", "Wybierz", "Wr��");
        }
        return 1;
    }
    else if(dialogid == D_EDIT_RANG_2)
    {
        if(!response) return ShowPlayerDialogEx(playerid, D_EDIT_RANG, DIALOG_STYLE_LIST, "{8FCB04}Edycja {FFFFFF}rang", "Frakcja\nOrganizacja", "Wybierz", "Wr��");
        new typ = GetPVarInt(playerid, "edit_rang_typ");
        new id = strval(inputtext);
        if(typ == 0)
        {
            if(id < 1 || id > 17) return ShowPlayerDialogEx(playerid, D_EDIT_RANG, DIALOG_STYLE_LIST, "{8FCB04}Edycja {FFFFFF}rang", "Frakcja\nOrganizacja", "Wybierz", "Wr��");
        }
        else
        {
            new uid = orgID(id);
            if(!orgIsValid(uid)) return ShowPlayerDialogEx(playerid, D_EDIT_RANG, DIALOG_STYLE_LIST, "{8FCB04}Edycja {FFFFFF}rang", "Frakcja\nOrganizacja", "Wybierz", "Wr��");
        }
        SetPVarInt(playerid, "edit_rang_id", id);
        EDIT_ShowRangNames(playerid, typ, id, true);
        return 1;
    }
    else if(dialogid == D_EDIT_RANG_SET)
    {
        if(!response) return ShowPlayerDialogEx(playerid, D_EDIT_RANG, DIALOG_STYLE_LIST, "{8FCB04}Edycja {FFFFFF}rang", "Frakcja\nOrganizacja", "Wybierz", "Wr��");
        SetPVarInt(playerid, "edit_rang_index", listitem);
        ShowPlayerDialogEx(playerid, D_EDIT_RANG_NAME, DIALOG_STYLE_INPUT, "{8FCB04}Edycja {FFFFFF}rang", "Podaj now� nazw� dla rangi.\n{FF0000}Je�eli chcesz usun�� rang�, wpisz minus (-)", "Ustaw", "Wr��");
        return 1;
    }
    else if(dialogid == D_EDIT_RANG_NAME)
    {
        if(!response) return EDIT_ShowRangNames(playerid, GetPVarInt(playerid, "edit_rang_typ"), GetPVarInt(playerid, "edit_rang_id"), true);
        new idx = GetPVarInt(playerid, "edit_rang_index");
        if(strlen(inputtext) < 1 || strlen(inputtext) > 24)
        {
            SendClientMessage(playerid, COLOR_GRAD2, "D�ugosc od 1 do 24");
            ShowPlayerDialogEx(playerid, D_EDIT_RANG_NAME, DIALOG_STYLE_INPUT, "{8FCB04}Edycja {FFFFFF}rang", "Podaj now� nazw� dla rangi.\n{FF0000}Je�eli chcesz usun�� rang�, wpisz minus (-)", "Ustaw", "Wr��");
            return 1;
        }
        new typ = GetPVarInt(playerid, "edit_rang_typ");
        new id = GetPVarInt(playerid, "edit_rang_id");
        new name[20];
        mysql_real_escape_string(inputtext, name);
        if(inputtext[0] == '-')
        {
            if(typ == 0) strdel(FracRang[id][idx], 0, MAX_RANG_LEN);
            else if(typ == 1) strdel(FamRang[id][idx], 0, MAX_RANG_LEN);
        }
        else
        {
            if(typ == 0) format(FracRang[id][idx], MAX_RANG_LEN, "%s", name);
            else if(typ == 1) format(FamRang[id][idx], MAX_RANG_LEN, "%s", name);
        }
        //EDIT_SaveRangs(typ, id);
        RANG_ApplyChanges[typ][id] = true;
        EDIT_ShowRangNames(playerid, typ, id, true);
        return 1;
    }
    //30.10
    else if(dialogid == D_TRANSPORT)
    {
        if(!response) return 1;
        new lStr[256];

        new skill, level = PlayerInfo[playerid][pTruckSkill];

        if(level <= 50) skill = 1;
        else if(level >= 51 && level <= 100) skill = 2;
        else if(level >= 101 && level <= 200) skill = 3;
        else if(level >= 201 && level <= 400) skill = 4;
        else if(level >= 401) skill = 5;

        switch(listitem)
        {
            case 0:
            {
                if(PlayerInfo[playerid][pTruckSkill] < 200) return SendClientMessage(playerid, COLOR_GRAD2, " Szybkie zlecenia dost�pne od 4 poziomu umiej�tno�ci!");
                for(new i=0;i<sizeof(TransportJobData);i++)
                {
                    if(TransportJobData[i][eTJDStartX] != 0 && TransportJobData[i][eTJDEndX] != 0)
                    {
                        if(TransportJobData[i][eTJDMoney] >= 5000 && skill < 5) continue;
                        format(lStr, 256, "%s%d\t%s\n", lStr, i, TransportJobData[i][eTJDName]);
                    }
                }
                ShowPlayerDialogEx(playerid, D_TRANSPORT_LIST, DIALOG_STYLE_LIST, "Szybkie zlecenie", lStr, "Wybierz", "Wr��");
                return 0;
            }
            case 1:
            {
                if(!IsPlayerInRangeOfPoint(playerid, 10.0, TransportJobData[0][eTJDStartX], TransportJobData[0][eTJDStartY], TransportJobData[0][eTJDStartZ]))
                {
                    SetPlayerCheckpoint(playerid, TransportJobData[0][eTJDStartX], TransportJobData[0][eTJDStartY], TransportJobData[0][eTJDStartZ], 5.0);
                    SendClientMessage(playerid, COLOR_GRAD2, "Zlecenie mo�esz wybra� w swoim centrum pracy.");
                    return 0;
                }


                for(new i=0;i<sizeof(TransportJobData);i++)
                {
                    if(TransportJobData[i][eTJDStartX] == 0 && TransportJobData[i][eTJDEndX] != 0)
                    {
                        if(TransportJobData[i][eTJDMoney] >= 5000 && skill < 5) continue;
                        if(TransportJobData[i][eTJDMoney] >= 3500 && skill < 4) continue;
                        if(TransportJobData[i][eTJDMoney] >= 2500 && skill < 3) continue;
                        format(lStr, 256, "%s%d\t%s\n", lStr, i, TransportJobData[i][eTJDName]);
                    }
                }
                ShowPlayerDialogEx(playerid, D_TRANSPORT_LIST, DIALOG_STYLE_LIST, "Planowane zlecenie", lStr, "Wybierz", "Wr��");
            }
        }
    }
    else if(dialogid == D_TRANSPORT_LIST)
    {
        //TODO: if(!response) return RunCommand(playerid, "/zlecenie",  "");
        new idx = strval(inputtext);
        SetPVarInt(playerid, "trans_idx", idx);
        new lStr[256];
        format(lStr, 256, "TOWAR PRZEWO�ONY:\t%s\nMAX. DOCH�D:\t$%d\nILO�� TOWARU:\t%d\nPOTRZEBNE MATERIA�Y: %d\n\nCzy chcesz przyj�� zlecenie?", TransportJobData[idx][eTJDName],TransportJobData[idx][eTJDMoney], TransportJobData[idx][eTJDMaxItems], TransportJobData[idx][eTJDMats]);

        ShowPlayerDialogEx(playerid, D_TRANSPORT_ACCEPT, DIALOG_STYLE_MSGBOX, "Akceptacja", lStr, "Gotowe!", "Anuluj");
    }
    else if(dialogid == D_TRANSPORT_ACCEPT)
    {
        //TODO: if(!response) return RunCommand(playerid, "/zlecenie",  "");
        new idx = GetPVarInt(playerid, "trans_idx");
        new lStr[128];
        if(TransportJobData[idx][eTJDMats] > TJD_Materials)
        {
            SendClientMessage(playerid, COLOR_GRAD2, "W magazynie na ma tylu materia��w. Wsi�d� w w�zek wid�owy i do�aduj magazyn!");
            return 0;
        }
        TJD_Materials -= TransportJobData[idx][eTJDMats];
        TJD_UpdateLabel();

        format(lStr, 128, "Przyj�to zlecenie. Twoim zadaniem jest transport %s. Udaj si� do punktu.", TransportJobData[idx][eTJDName]);
        SendClientMessage(playerid, COLOR_YELLOW, lStr);

        SetPVarInt(playerid, "trans", ((idx)*2)+1);
        if(TransportJobData[idx][eTJDStartX] != 0) SetPlayerCheckpoint(playerid, TransportJobData[idx][eTJDStartX], TransportJobData[idx][eTJDStartY], TransportJobData[idx][eTJDStartZ], 5.0);
        else
        {
            SetPlayerCheckpoint(playerid, TransportJobData[0][eTJDStartX], TransportJobData[0][eTJDStartY], TransportJobData[0][eTJDStartZ], 5.0);
        }
    }
    else if(dialogid == D_DODATKI_TYP)
    {
        if(!response) return 1;
        if(listitem == 2 && !MRP_IsInPolice(playerid)) return sendTipMessageEx(playerid, COLOR_GRAD2, "Nie jestes w policji!");
        if(listitem == 4 && !MRP_IsInGang(playerid)) return sendTipMessageEx(playerid, COLOR_GRAD2, "Nie jestes w gangu!");
        CallRemoteFunction("SEC_Dodatki_Show", "dd", playerid, listitem);
        return 1;
    }
    else if(dialogid == D_WINDA_LSFD)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
				{
			 			SetPlayerPosEx(playerid, 1745.8119,-1129.8972,24.0781);
                        SetPlayerVirtualWorld(playerid, 0);
				}
                case 1:
				{
						SetPlayerPosEx(playerid, 1746.2399,-1128.2211,227.8059);
                        SetPlayerVirtualWorld(playerid, 22);
                        Wchodzenie(playerid);
				}
                case 2:
				{
						SetPlayerPosEx(playerid, 1745.8934,-1129.6250,47.2859);
                        SetPlayerVirtualWorld(playerid, 23);
                        Wchodzenie(playerid);
				}
                case 3:
				{
						SetPlayerPosEx(playerid, 1745.8119,-1129.8972,46.5700);
                        SetPlayerVirtualWorld(playerid, 0);
				}
            }
        }
        return 1;
    }
    else if(dialogid == D_SUPPORT_LIST)
    {
        SetPVarInt(playerid, "support_dialog", 0);
        if(!response)
            return 1;
        new id = strval(inputtext);
        if(!TICKET[id][suppValid]) return 1;
        new pid = TICKET[id][suppCaller];
        Support_ClearTicket(id);

        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, Unspec[playerid][Coords][0], Unspec[playerid][Coords][1], Unspec[playerid][Coords][2]);
        Unspec[playerid][sPint] = GetPlayerInterior(playerid);
        Unspec[playerid][sPvw] = GetPlayerVirtualWorld(playerid);

        GetPlayerPos(pid, x, y, z);
        SetPlayerPosEx(playerid, x, y, z);
        SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(pid));
        SetPlayerInterior(playerid, GetPlayerInterior(pid));
        Wchodzenie(playerid);
        Wchodzenie(pid);
        SetPVarInt(playerid, "validticket", 1);
        new str[128];
        format(str, 64, "SUPPORT: %s oferuje Ci pomoc, skorzystaj z tego!", GetNick(playerid));
        SendClientMessage(pid, COLOR_YELLOW, str);
        format(str, 128, "SUPPORT: Pomagasz teraz %s. Aby wr�ci� do poprzedniej pozycji wpisz /ticketend", GetNick(pid));
        SendClientMessage(playerid, COLOR_YELLOW, str);
		if(GetPVarInt(playerid, "dutyadmin") == 1)
		{
			iloscZapytaj[playerid] = iloscZapytaj[playerid]+1;
		}

        return 1;
    }
//====================[KONTO BANKOWE]========================================
//By Simeone 25-12-2018
	//==================[G��WNE OKNO DIALOGOWE]=======================================
	else if(dialogid == 1067)
	{
		if(response)
        {
			//Zmienne u�yte do dzia�ania dialogu
			new string[128];
			new giveplayer[MAX_PLAYER_NAME];
			GetPlayerName(playerid, giveplayer, sizeof(giveplayer));
			new FracGracza = PlayerInfo[playerid][pLider];
		
            switch(listitem)
            {
				
				
				//dzia�anie dialogu
                case 0://Stan konta
				{
					format(string, sizeof(string), "{C0C0C0}Witaj {800080}%s{C0C0C0},\nObecny stan konta: {80FF00}%d$", giveplayer, PlayerInfo[playerid][pAccount]);
					ShowPlayerDialogEx(playerid, 1080, DIALOG_STYLE_MSGBOX, "Stan Konta", string, "Okej", "");
				}
                case 1://Wp�a�
				{
					format(string, sizeof(string), "Konto Bankowe >> %s", giveplayer);
					ShowPlayerDialogEx(playerid, 1068, DIALOG_STYLE_INPUT, string, "Wpisz poni�ej kwot�, kt�r� chcesz wp�aci�", "Wykonaj", "Odrzu�");
				}
                case 2://Wyp�a�
				{
					
					format(string, sizeof(string), "Konto Bankowe >> %s", giveplayer);
					ShowPlayerDialogEx(playerid, 1071, DIALOG_STYLE_INPUT, string, "Wpisz poni�ej kwot�, kt�r� chcesz wyp�aci�", "Wykonaj", "Odrzu�");
				}
                case 3://Przelew do osoby
				{
					
					format(string, sizeof(string), "Konto Bankowe >> %s >> Przelew", giveplayer);
					ShowPlayerDialogEx(playerid, 1072, DIALOG_STYLE_INPUT, string, "Wpisz poni�ej ID odbiorcy", "Wykonaj", "Odrzu�");
				}
				case 4://>>Konto frakcji
				{
					if(GetPlayerFraction(playerid) != 0)
					{
						if(PlayerInfo[playerid][pLider] != 0)
						{
							format(string, sizeof(string), ">> %s >> %s", giveplayer, FractionNames[FracGracza]);
							ShowPlayerDialogEx(playerid, 1069, DIALOG_STYLE_LIST, string, "Stan Konta\nPrzelew do osoby\nPrzelew do frakcji\nWp�a�\nWyp�a�\n<< Twoje konto", "Wybierz", "Wyjd�");
						}
						else
						{
							sendErrorMessage(playerid, "Nie jeste� liderem frakcji!"); 
							return 1;
						}
					}	
					else
					{
						sendErrorMessage(playerid, "Nie jeste� we frakcji!");
						return 1;
					}
					
				}
				case 5://Konto rodziny
				{
					sendErrorMessage(playerid, "Ju� wkr�tce!"); 
				}
				
            }
			return 1;
        }
	
	}
	//===============[WP�ATA NA SWOJE KONTO]=========================
	else if(dialogid == 1068)
	{
		if(response)
	    {
			if(gPlayerLogged[playerid] == 1)
			{
				new string[128];
				new money = strval(inputtext);
				money = FunkcjaK(inputtext);//--Funkcja wp�acania na k
				if (money > kaska[playerid] || money < 1)
				{
					sendTipMessage(playerid, "Nie masz tyle \\ B��dna kwota!");
					return 1;
				}
				if(PlayerInfo[playerid][pAccount] + money > 2_000_000_000)
				{
					sendTipMessage(playerid, "Konto bankowe przepe�nione, mo�emy przechowywa� nie wi�cej ni� 2 miliardy!");
					return 1;
				}
				ZabierzKase(playerid, money);
				new currentFunds = PlayerInfo[playerid][pAccount];
				SendClientMessage(playerid, COLOR_WHITE, "|___ {80FF00}STAN KONTA {FFFFFF}___|");
				format(string, sizeof(string), "  Poprzedni stan: {80FF00}$%d", currentFunds);
				SendClientMessage(playerid, COLOR_GRAD2, string);
				PlayerInfo[playerid][pAccount] = money + PlayerInfo[playerid][pAccount];
				format(string, sizeof(string), "  Depozyt: {80FF00}$%d", money);
				SendClientMessage(playerid, COLOR_GRAD4, string);
				SendClientMessage(playerid, COLOR_GRAD6, "|-----------------------------------------|");
				format(string, sizeof(string), "  Nowy stan: {80FF00}$%d", PlayerInfo[playerid][pAccount]);
				SendClientMessage(playerid, COLOR_WHITE, string);
				
				format(string, sizeof(string), "Gracz UID: %d, Nick: %s wplacil na swoje konto %d$, nowy stan: %d$", PlayerInfo[playerid][pUID], GetNick(playerid), money, PlayerInfo[playerid][pAccount]);
				PayLog(string);
			}	
			return 1;
		}
	}
	//====================[DIALOG === KONTO FRAKCJI]==============================
	else if(dialogid == 1069)
	{
		if(response)
        {
		
			//Zmienne i funkcje
			new FracGracza = PlayerInfo[playerid][pLider];//Nazwa frakcji gracza
			new string[256];
			new StanSejfuFrac[128];//drugi string specjalnie do stanu konta frakcji
			new stan = Sejf_Frakcji[GetPlayerFraction(playerid)];//Stan sejfu frakcji
			new giveplayer[MAX_PLAYER_NAME];//Gracz odbieraj�cy
			GetPlayerName(playerid, giveplayer, sizeof(giveplayer));
            switch(listitem)
            {
				
				
				//Case'y i dzia�anie kodu
				
				case 0://=======================>>Sprawd� stan konta organizacji
				{	
					format(string, sizeof(string), "{C0C0C0}Witaj {800080}%s{C0C0C0},\nPomy�lnie zalogowano na:{80FF00}%s\n{C0C0C0}Obecny stan konta: {80FF00}%d$", giveplayer, FractionNames[FracGracza],Sejf_Frakcji[GetPlayerFraction(playerid)]);
					ShowPlayerDialogEx(playerid, 1080, DIALOG_STYLE_MSGBOX, "Stan Konta", string, "Okej", "");
				}
				case 1://=======================>>Przelew z konta frakcji na konto gracza
				{
					
					format(string, sizeof(string), ">> %s", FractionNames[FracGracza]);
					ShowPlayerDialogEx(playerid, 1075, DIALOG_STYLE_INPUT, string, "Wpisz poni�ej ID odbiorcy", "Wykonaj", "Odrzu�");
				}
				case 2://=======================>>Przelew z konta frakcji na konto frakcji 
				{
					if(IsAPrzestepca(playerid))
					{
						sendTipMessage(playerid, "Organizacje przest�pcze musz� znale�� lepszy (cichszy) spos�b na przelew"); 
						return 1;
					}
					format(string, sizeof(string), ">> %s", FractionNames[FracGracza]);
					ShowPlayerDialogEx(playerid, 1098, DIALOG_STYLE_LIST, string, "LSPD\nFBI\nLSFD\nLSMC\nDMV\nUSSS\nSN\nKT\nNOA", "Dalej", "Powr�t"); 
				
				}
				case 3://=======================>>Wp�a� na konto frakcji
				{
					format(string, sizeof(string), "%s", FractionNames[FracGracza]); 
					ShowPlayerDialogEx(playerid, 1077, DIALOG_STYLE_INPUT, string, "Wpisz poni�ej kwot�, jak� chcesz wp�aci�", "Wykonaj", "Odrzu�"); 
				}
				case 4://=======================>>Wyp�a� z konta frakcji
				{
					
					
					format(string, sizeof(string), "%s", FractionNames[FracGracza]);
					format(StanSejfuFrac, sizeof(StanSejfuFrac), "Stan konta: {80FF00}%d\n{C0C0C0}Wpisz poni�ej kwot� jak� chcesz wyp�aci�", stan);
					ShowPlayerDialogEx(playerid, 1078, DIALOG_STYLE_INPUT, string, StanSejfuFrac, "Wykonaj", "Odrzu�"); 
				}
				case 5://=======================>>Powr�t do g��wnego panelu
				{	
					
					format(string, sizeof(string), "Konto Bankowe >> %s", giveplayer);
					ShowPlayerDialogEx(playerid, 1067, DIALOG_STYLE_LIST, string, "Stan konta\n\nWp�a�\nWyp�a�\n>>Frakcyjne\n>>Rodzinne", "Wybierz", "Wyjd�");
				
				}
			
			
			}
			return 1;
		}
		
	}
	//============[DIALOG - WYBIERZ DO KOGO PRZELA� KASE]===================
	//LSPD\nFBI\nLSFD\nLSMC\nDMV\nUSSS\nSN\nKT\nNOA
	else if(dialogid == 1098)
	{
		if(response)
        {
			new string[128];
			switch(listitem)
			{
				case 0:
				{
					SetPVarInt(playerid, "PrzelewFrakcjaFrakcja", 1);
					format(string, sizeof(string), "Wpisz w poni�szym polu kwot�,\nkt�r� masz zamiar przela�.\n\nWykonujesz przelew do frakcji: LSPD");
					ShowPlayerDialogEx(playerid, 1099, DIALOG_STYLE_INPUT, "Przelew do LSPD", string, "Wykonaj", "Odrzu�"); 
				}
				case 1:
				{
					SetPVarInt(playerid, "PrzelewFrakcjaFrakcja", 2);
					format(string, sizeof(string), "Wpisz w poni�szym polu kwot�,\nkt�r� masz zamiar przela�.\n\nWykonujesz przelew do frakcji: FBI");
					ShowPlayerDialogEx(playerid, 1099, DIALOG_STYLE_INPUT, "Przelew do FBI", string, "Wykonaj", "Odrzu�"); 
				}
				case 2:
				{
					SetPVarInt(playerid, "PrzelewFrakcjaFrakcja", 17);
					format(string, sizeof(string), "Wpisz w poni�szym polu kwot�,\nkt�r� masz zamiar przela�.\n\nWykonujesz przelew do frakcji: LSFD");
					ShowPlayerDialogEx(playerid, 1099, DIALOG_STYLE_INPUT, "Przelew do LSFD", string, "Wykonaj", "Odrzu�"); 
				}
				case 3:
				{
					SetPVarInt(playerid, "PrzelewFrakcjaFrakcja", 4);
					format(string, sizeof(string), "Wpisz w poni�szym polu kwot�,\nkt�r� masz zamiar przela�.\n\nWykonujesz przelew do frakcji: LSMC");
					ShowPlayerDialogEx(playerid, 1099, DIALOG_STYLE_INPUT, "Przelew do LSMC", string, "Wykonaj", "Odrzu�"); 
				}
				case 4:
				{
					SetPVarInt(playerid, "PrzelewFrakcjaFrakcja", 11);
					format(string, sizeof(string), "Wpisz w poni�szym polu kwot�,\nkt�r� masz zamiar przela�.\n\nWykonujesz przelew do frakcji: DMV");
					ShowPlayerDialogEx(playerid, 1099, DIALOG_STYLE_INPUT, "Przelew do DMV", string, "Wykonaj", "Odrzu�"); 
				}
				case 5:
				{
					SetPVarInt(playerid, "PrzelewFrakcjaFrakcja", 7);
					format(string, sizeof(string), "Wpisz w poni�szym polu kwot�,\nkt�r� masz zamiar przela�.\n\nWykonujesz przelew do frakcji: USSS");
					ShowPlayerDialogEx(playerid, 1099, DIALOG_STYLE_INPUT, "Przelew do USSS", string, "Wykonaj", "Odrzu�"); 
				}
				case 6:
				{
					SetPVarInt(playerid, "PrzelewFrakcjaFrakcja", 9);
					format(string, sizeof(string), "Wpisz w poni�szym polu kwot�,\nkt�r� masz zamiar przela�.\n\nWykonujesz przelew do frakcji: SN");
					ShowPlayerDialogEx(playerid, 1099, DIALOG_STYLE_INPUT, "Przelew do SN", string, "Wykonaj", "Odrzu�"); 
				}
				case 7:
				{
					SetPVarInt(playerid, "PrzelewFrakcjaFrakcja", 10);
					format(string, sizeof(string), "Wpisz w poni�szym polu kwot�,\nkt�r� masz zamiar przela�.\n\nWykonujesz przelew do frakcji: KT");
					ShowPlayerDialogEx(playerid, 1099, DIALOG_STYLE_INPUT, "Przelew do KT", string, "Wykonaj", "Odrzu�"); 
				}
				case 8:
				{
					SetPVarInt(playerid, "PrzelewFrakcjaFrakcja", 15);
					format(string, sizeof(string), "Wpisz w poni�szym polu kwot�,\nkt�r� masz zamiar przela�.\n\nWykonujesz przelew do frakcji: NOA");
					ShowPlayerDialogEx(playerid, 1099, DIALOG_STYLE_INPUT, "Przelew do NOA", string, "Wykonaj", "Odrzu�"); 
				}
			
			}
			return 1;
		}
	}
	else if(dialogid == 1099)
	{
		if(response)
		{
			new string[128];
			new bigstring[256];
			new money = FunkcjaK(inputtext);
			new frakcja = GetPlayerFraction(playerid);
			new frac = GetPVarInt(playerid, "PrzelewFrakcjaFrakcja");
			if(money > 0)
			{
				if(frac == frakcja)
				{
					sendErrorMessage(playerid, "Nie mo�esz przela� got�wki do w�asnej frakcji!"); 
					return 1;
				}
				if(Sejf_Frakcji[frakcja] < money)
				{
					sendErrorMessage(playerid, "W sejfie twojej frakcji nie ma a� takiej ilo�ci got�wki!"); 
					return 1;
				}
				if(Sejf_Frakcji[frac] >= 1_500_000_000)
				{
					format(string, sizeof(string), "Sejf %s wylewa si�! Kwota 1,5kkk przekroczona", FractionNames[frac]);
					sendErrorMessage(playerid, string);
					return 1;
				}
				//KOMUNIKATY:
				format(string, sizeof(string), "Dokona�e� przelewu na konto frakcji %s w wysoko�ci %d", FractionNames[frac], money);
				sendTipMessage(playerid, string);
				
				
				format(bigstring, sizeof(bigstring), "%s dokona� przelewu na konto %s z konta %s w wysoko�ci %d",
				GetNick(playerid, true),
				FractionNames[frac], 
				FractionNames[frakcja], money);
				SendLeaderRadioMessage(frakcja, COLOR_LIGHTGREEN, bigstring);
				
				format(bigstring, sizeof(bigstring), "Twoja frakcja otrzyma�a przelew od lidera %s [%s] w wysoko�ci %d", 
				FractionNames[frakcja],
				GetNick(playerid, true), money);
				
				SendLeaderRadioMessage(frac, COLOR_RED, "===================================");
				SendLeaderRadioMessage(frac, COLOR_LIGHTGREEN, bigstring);
				SendLeaderRadioMessage(frac, COLOR_RED, "==================================="); 
				
				//LOG
				format(bigstring, sizeof(bigstring), "Lider %s - %s [UID: %d] dokona� przelewu na konto %s w wysoko�ci %d", 
				FractionNames[frakcja], 
				GetNick(playerid, true),
				PlayerInfo[playerid][pUID],
				FractionNames[frac], money);
				PayLog(bigstring);
				
				//Powiadomienie dla admin�w
				if(money >= 2_500_000)
				{
					SendAdminMessage(COLOR_GREEN, "============[ADM-LOG]===========");
					format(string, sizeof(string), "Przelewaj�cy: %s [%d]", GetNick(playerid, true), playerid);
					SendAdminMessage(COLOR_WHITE, string);
					format(string, sizeof(string), "Z konta: %s", FractionNames[frakcja]);
					SendAdminMessage(COLOR_WHITE, string);
					format(string, sizeof(string), "Na konto: %s", FractionNames[frac]);
					SendAdminMessage(COLOR_WHITE, string);
					format(string, sizeof(string), "Kwota: %d", money);
					SendAdminMessage(COLOR_WHITE, string);
					SendAdminMessage(COLOR_GREEN, "================================");
				}
				//czynno�ci
				Sejf_Add(frac, money);
				Sejf_Add(frakcja, -money);
				Sejf_Save(frac);
				Sejf_Save(frakcja);
			}
			else
			{
				sendTipMessage(playerid, "B��dna kwota");
			}
		}
		else
		{
			sendTipMessage(playerid, "Odrzucono akcj� przelewu"); 
			return 1;
		}
	
	}
	//============[DIALOG INFORMACYJNY (INFO) -> Zwrot Marcepana]============
	else if(dialogid == 1080)
	{
		if(response)
        {
            SendClientMessage(playerid, COLOR_WHITE, "Marcepan Marks m�wi: Do zobaczenia!");
			return 1;
        }
		else
		{
			SendClientMessage(playerid, COLOR_WHITE, "Marcepan Marks m�wi: Do zobaczenia! Zapraszamy ponownie do Verte Bank");
			return 1;
		}
       
	
	}
	else if(dialogid == 1071)//wyp�ata z swojego konta
	{
		if(response)
	    {
			if(gPlayerLogged[playerid] == 1)
			{
				new string[128];
				new money = strval(inputtext);
				money = FunkcjaK(inputtext);//--Funkcja wp�acania na k
				
				if (money > PlayerInfo[playerid][pAccount] || money < 1)//Zabezpieczenie
				{
					sendTipMessage(playerid, "Nie masz tyle \\ B��dna kwota");
					return 1;
				}
				
				//Komunikaty:
				new currentFunds = PlayerInfo[playerid][pAccount];
				SendClientMessage(playerid, COLOR_WHITE, "|___ {80FF00}STAN KONTA {FFFFFF}___|");
				format(string, sizeof(string), "  Poprzedni stan: {80FF00}$%d", currentFunds);
				SendClientMessage(playerid, COLOR_GRAD2, string);
				format(string, sizeof(string), "  Depozyt: {80FF00}$-%d", money);
				SendClientMessage(playerid, COLOR_GRAD4, string);
				//Czynno�ci:
				DajKase(playerid, money);
				PlayerInfo[playerid][pAccount] -= money;
				//Komunikaty:
				SendClientMessage(playerid, COLOR_GRAD6, "|-----------------------------------------|");
				format(string, sizeof(string), "  Nowy stan: {80FF00}$%d", PlayerInfo[playerid][pAccount]);
				SendClientMessage(playerid, COLOR_WHITE, string);
				
				format(string, sizeof(string), "Gracz UID: %d, Nick: %s wyplacil ze swojego konta %d$, nowy stan: %d$", PlayerInfo[playerid][pUID], GetNick(playerid), money, PlayerInfo[playerid][pAccount]);
				PayLog(string);
			}	
			return 1;
		}
	
	}
	//============[PRZELEWY OD GRACZA DO GRACZA = ID ODBIORCY]===================================
	else if(dialogid == 1072)//Przelew
	{
		if(!response)
	    {
			sendErrorMessage(playerid, "Odrzucono akcje przelewu!");
		}
		else//Je�li przejdzie dalej
		{
			new string[128];
			new giveplayerid = strval(inputtext);
			if(GetPlayerVirtualWorld(giveplayerid) == 1488)
			{
				sendErrorMessage(playerid, "Ten gracz jest w trakcie logowania!"); 
				return 1;
			}
			if (IsPlayerConnected(giveplayerid) && gPlayerLogged[giveplayerid])
			{
				if(giveplayerid != playerid)
				{
					SetPVarInt(playerid, PVAR_PRZELEW_ID, giveplayerid);
					format(string, sizeof(string), "Wpisz poni�ej sum�, ktor� chcesz przela� do %s", GetNick(giveplayerid));
					ShowPlayerDialogEx(playerid, 1073, DIALOG_STYLE_INPUT, ">>Przelew >> 1  >> 2 ", string, "Wykonaj", "Odrzu�");
				}
				else
				{
					sendErrorMessage(playerid, "Nie mo�esz przela� got�wki samemu sobie!");
					return 1;
				}
			}
			else
			{
				sendErrorMessage(playerid, "Nie ma takiego gracza!"); 
				return 1;
			}
			return 1;
		}
	
	
	}
	//================[PRZELEWY DO GRACZA OD GRACZA = Czynno�ci + Kwota przelewu]========================
	else if(dialogid == 1073)
	{
		if(!response)
	    {
			sendErrorMessage(playerid, "Odrzucono akcje przelewu!"); 
		}
		else//Je�li kliknie "TAK"
		{
			new string[128];
			new sendername[MAX_PLAYER_NAME];
			new giveplayer[MAX_PLAYER_NAME];
			new giveplayerid = GetPVarInt(playerid, PVAR_PRZELEW_ID);
			new money = FunkcjaK(inputtext);//Zbugowany string 
			GetPlayerName(playerid, sendername, sizeof(sendername));
			GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
			
			if(money >= 1 && money <= PlayerInfo[playerid][pAccount])//Zabezpieczenie 
			{
				if(PlayerInfo[giveplayerid][pAccount]+money > MAX_MONEY_IN_BANK)
				{
					sendErrorMessage(playerid, "Gracz do kt�rego pr�bowa�e� przela� got�wk� - ma zbyt du�o pieni�dzy na koncie."); 
					return 1;
				}
				if(!IsPlayerConnected(giveplayerid))
				{
					sendErrorMessage(playerid, "Gracz, do kt�rego pr�bowa�e� przela� got�wk� wyszed� z serwera!"); 
					return 1;
				}
				//Czynno�ci:
				PlayerInfo[playerid][pAccount] -= money;
				PlayerInfo[giveplayerid][pAccount] += money;
				
				//komunikaty:
				format(string, sizeof(string), "Otrzyma�e� przelew w wysoko�ci %d$ od %s . Pieni�dze znajduj� si� na twoim koncie.", money, sendername);
				SendClientMessage(giveplayerid, COLOR_RED, string);
				
				format(string, sizeof(string), "Wys�a�e� przelew dla %s w wysoko�ci %d$. Pieni�dze zosta�y pobrane z twojego konta bankowego", giveplayer, money);
				SendClientMessage(playerid, COLOR_RED, string); 
				
				format(string, sizeof(string), "Gracz UID: %d, Nick: %s dokonal przelewu %d$ dla gracza %s uid: %d, nowy stan: %d$", 
					PlayerInfo[playerid][pUID], 
					sendername, 
					money, 
					giveplayer, 
					PlayerInfo[giveplayerid][pUID], 
					PlayerInfo[playerid][pAccount]);
				PayLog(string);
				
				if(money >= 5_000_000)//Wiadomosc dla adminow
				{
					SendAdminMessage(COLOR_YELLOW, string);
					return 1;
				}
			}
			else//Je�li pr�buje oszuka� (brak got�wki, b��dnie wpisana kwota)
			{
				sendErrorMessage(playerid, "B��dna kwota || Nie masz takiej ilo�ci got�wki na swoim koncie!"); 
				return 1;
			}
			return 1;
		}
		
	
	
	}
	//=================[DIALOG ZWROTNY --> Zwraca nas do "Twoje Konto"]=================
	else if(dialogid == 1074)
	{
		if(response)//Je�eli TAK
		{
			new string[128];
			new giveplayer[MAX_PLAYER_NAME];
			GetPlayerName(playerid, giveplayer, sizeof(giveplayer));
			new frakcja = PlayerInfo[playerid][pLider];
			format(string, sizeof(string), ">> %s >> %s", giveplayer, FractionNames[frakcja]);
			ShowPlayerDialogEx(playerid, 1069, DIALOG_STYLE_LIST, string, "Stan Konta\nPrzelew do osoby\nPrzelew do frakcji\nWp�a�\nWyp�a�\n<< Twoje konto", "Wybierz", "Wyjd�");
			return 1;
		}

	}
	else if(dialogid == 1075)//Pobieranie ID odbiorcy - przelew z konta frakcji
	{
		if(!response)
	    {
			sendErrorMessage(playerid, "Nie uzupe�ni�e� ID odbiorcy!"); 
		}
		else
		{
			new string[128];
			new frakcja = PlayerInfo[playerid][pLider];
			new giveplayerid = strval(inputtext);
			if(IsPlayerConnected(giveplayerid) && gPlayerLogged[giveplayerid])
			{
				SetPVarInt(playerid, PVAR_PRZELEW_ID, giveplayerid);
				format(string, sizeof(string), "Odbiorca: %s\nWysy�aj�cy: %s\nWpisz poni�ej kwot�, kt�ra ma zosta� przelana na jego konto.", GetNick(giveplayerid), FractionNames[frakcja]); 
				ShowPlayerDialogEx(playerid, 1076, DIALOG_STYLE_INPUT, "Przelewy frakcji >> ID >> Kwota", string, "Wykonaj", "Odrzu�"); 
				
			}
			else
			{
				sendErrorMessage(playerid, "Nie ma na serwerze takiego gracza!"); 
				return 1;
			}
			return 1;
		}
	}
	else if(dialogid == 1076)//Wpisywanie kwoty i ca�o�� funkcji - przelew z konta organizacji na gracza
	{
		if(!response)
		{
		
			sendErrorMessage(playerid, "Odrzucono akcj� przelewu"); 
			return 1;
		}
		else
		{
			new string[256];
			new sendername[MAX_PLAYER_NAME];//Nadawca
			new giveplayer[MAX_PLAYER_NAME];//Odbiorca
			new giveplayerid = GetPVarInt(playerid, PVAR_PRZELEW_ID);
			new money = FunkcjaK(inputtext);
			new frakcja = GetPlayerFraction(playerid);
			
			GetPlayerName(playerid, sendername, sizeof(sendername));
			GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
			
			if(money <= 0 || money > Sejf_Frakcji[frakcja])
			{
				sendErrorMessage(playerid, "Nieprawid�owa kwota przelewu!"); 
				return 1;
			}
			if(!IsPlayerConnected(giveplayerid))
			{
				sendErrorMessage(playerid, "Gracz, do kt�rego pr�bowa�e� przela� got�wk� wyszed� z serwera!"); 
				return 1;
			}
			if(PlayerInfo[giveplayerid][pAccount]+money > MAX_MONEY_IN_BANK)
			{
				sendErrorMessage(playerid, "Gracz do kt�rego pr�bowa�e� przela� got�wk� - ma zbyt du�o pieni�dzy na koncie."); 
				return 1;
			}
			
			PlayerInfo[giveplayerid][pAccount] += money;
			Sejf_Add(frakcja, -money);
			Sejf_Save(frakcja);
			
			format(string, sizeof(string), ">>>Otrzyma�e� przelew w wysoko�ci %d$, od lidera %s -> %s", money, FractionNames[frakcja], sendername); 
			SendClientMessage(giveplayerid, COLOR_RED, string);
			
			format(string, sizeof(string), ">>>Wys�a�e� przelew w wysoko�ci %d$, na konto %s, z konta %s", money, giveplayer, FractionNames[frakcja]); 
			SendClientMessage(playerid, COLOR_RED, string);
			
			format(string, sizeof(string), ">>>Lider %s[%d] wys�a� %d$ na konto %s[%d]", sendername, playerid, money, giveplayer, giveplayerid);
			SendLeaderRadioMessage(frakcja, COLOR_LIGHTGREEN, string);
			
			format(string, sizeof(string), "Gracz UID: %d, Nick: %s dokonal przelewu frakcyjnego (frakcja %d) %d$ dla gracza %s uid: %d, nowy stan: %d$", 
					PlayerInfo[playerid][pUID], 
					sendername, 
					frakcja,
					money, 
					giveplayer, 
					PlayerInfo[giveplayerid][pUID], 
					Sejf_Frakcji[frakcja]);
			PayLog(string);
				
			if(money >= 2500000)//Warning dla admin�w, gdy gracz przekroczy 2.5kk 
			{
				SendAdminMessage(COLOR_YELLOW, "|======[ADM-WARNING]======|"); 
				format(string, sizeof(string), "%s[%d] wykona� przelew %d$ na konto %s[%d]", sendername, playerid, money, giveplayer, giveplayerid); 
				SendAdminMessage(COLOR_WHITE, string); 
				format(string, sizeof(string), "Frakcja gracza(z sejfu): %s", FractionNames[frakcja]);
				SendAdminMessage(COLOR_WHITE, string);
				SendAdminMessage(COLOR_YELLOW, "|=========================|");
			}
			return 1;
		}
	}
	//=================[WP�ATA NA KONTO ORGANIZACJI]=================
	else if(dialogid == 1077)
	{
		if(!response)
		{
		
			sendErrorMessage(playerid, "Odrzucono akcj� wp�aty"); 
			return 1;
		}
		else
		{
			new money = FunkcjaK(inputtext);
			new frakcja = GetPlayerFraction(playerid);
			new sendername[MAX_PLAYER_NAME];
			GetPlayerName(playerid, sendername, sizeof(sendername));
			if(money >= 1)
			{
				if(money <= kaska[playerid])
				{
					new string[128];
					Sejf_Add(frakcja, money);
					Sejf_Save(frakcja);
					ZabierzKase(playerid, money); 
					format(string, sizeof(string), "Lider %s wp�aci� %d$ na konto organizacji", sendername, money); 
					SendLeaderRadioMessage(frakcja, COLOR_LIGHTGREEN, string); 
					
					format(string, sizeof(string), "Gracz UID: %d, Nick: %s wplacil na konto frakcyjne (frakcja %d) %d$, nowy stan: %d$", 
						PlayerInfo[playerid][pUID], 
						sendername, 
						frakcja,
						money,
						Sejf_Frakcji[frakcja]);
					PayLog(string);
				}
				else
				{
					sendErrorMessage(playerid, "Nie masz tyle!"); 
					return 1;
				}
			
			}
			else
			{
				sendErrorMessage(playerid, "B��dna kwota transakcji");
				return 1;
			}
		
			return 1;
		}
	
	
	}
	//=================[WyP�ATA Z KONTA ORGANIZACJI]=================
	else if(dialogid == 1078)
	{
		if(!response)
		{
			sendErrorMessage(playerid, "Odrzucono akcj� wyp�aty"); 
			return 1;
		}
		else
		{
			new money = FunkcjaK(inputtext);
			new frakcja = GetPlayerFraction(playerid); 
			new sendername[MAX_PLAYER_NAME];
			GetPlayerName(playerid, sendername, sizeof(sendername));
			if(money >= 1)
			{
				if(money <= Sejf_Frakcji[frakcja])
				{
					new string[128];
					Sejf_Add(frakcja, -money);
					Sejf_Save(frakcja);
					DajKase(playerid, money); 
					format(string, sizeof(string), "Lider %s wyp�aci� %d$ z konta organizacji", sendername, money); 
					SendLeaderRadioMessage(frakcja, COLOR_LIGHTGREEN, string); 
					
					format(string, sizeof(string), "Gracz UID: %d, Nick: %s wyplacil z konta frakcyjnego (frakcja %d) %d$, nowy stan: %d$", 
						PlayerInfo[playerid][pUID], 
						sendername, 
						frakcja,
						money,
						Sejf_Frakcji[frakcja]);
					PayLog(string);
					
					if(money >= 2000000)
					{
						
						SendAdminMessage(COLOR_YELLOW, "|======[ADM-WARNING]======|");
						SendAdminMessage(COLOR_WHITE, string);
						SendAdminMessage(COLOR_YELLOW, "|=========================|");
						
					
					}
				}
				else
				{
					sendErrorMessage(playerid, "W sejfie twojej organizacji nie ma takiej kwoty!"); 
					return 1;
				}
			
			}
			else
			{
				sendErrorMessage(playerid, "B��dna kwota transakcji!");
				return 1;
			}
		
			return 1;
		}
	
	
	}
//=================[KONIEC]========================
	else if(dialogid == 1090)//Dialog do kupna bilet�w KT --> Poci�g
	{
		if(!response)
        {
			new string[128];
            format(string, sizeof(string), "* %s jest strasznie rozstargniony i zdecydowa� odej�� od maszyny bez biletu.", GetNick(playerid, true));//Ciekawostka - niezdecydowany
			ProxDetector(10.0, playerid, string, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE);
			return 1;
        }
		else
		{
			if(IsAtTicketMachine(playerid))
			{
				new sendername[MAX_PLAYER_NAME];
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(kaska[playerid] >= CenaBiletuPociag)				        
				{
					ZabierzKase(playerid, CenaBiletuPociag);
					Sejf_Add(FRAC_KT, TransportValue[playerid]);//Posiada wewn�trzne Sejf_Save
					PlayerInfo[playerid][pBiletpociag] = 1;
					new string[128]; 
					format(string, sizeof(string), "Zakupi�e� bilet za %d$", CenaBiletuPociag); 
					sendTipMessage(playerid, string);
					format(string, sizeof(string), "%s[ID: %d] zakupi� bilet za %d$", sendername, playerid, CenaBiletuPociag); 
					SendLeaderRadioMessage(FRAC_KT, COLOR_LIGHTGREEN, string);
						
					format(string, sizeof(string), "* %s zakupi� bilet do poci�gu za %d$, schowa� go do kieszeni.", GetNick(playerid, true), CenaBiletuPociag);
					ProxDetector(10.0, playerid, string, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE);
				}
				else
				{
					sendErrorMessage(playerid, "Nie masz wystarczaj�cej ilo�ci got�wki!"); 
					return 1;
				}
			}
			else
			{
				sendErrorMessage(playerid, "Nie jeste� przy maszynie do kupna bilet�w!"); 
				return 1;
			}
		}
	}
	else if(dialogid == 1091)
	{
		if(!response)
        {
			sendErrorMessage(playerid, "Aby zej�� ze s�u�by wpisz /adminduty"); 
			return 1;
        }
	
	}
	else if(dialogid == 1092)//Ca�uj - komenda - potwierdzenie
	{
		if(response)
		{
			if(ProxDetectorS(5.5, playerid, kissPlayerOffer[playerid]))
			{
				new string[128];
				format(string, sizeof(string),"* %s kocha %s wi�c ca�uj� si�.", GetNick(playerid, true), GetNick(kissPlayerOffer[playerid], true));
				ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				format(string, sizeof(string), "%s m�wi: Kocham ci�.", GetNick(kissPlayerOffer[playerid], true));
				ProxDetector(20.0, playerid, string, COLOR_WHITE,COLOR_WHITE,COLOR_WHITE,COLOR_WHITE,COLOR_WHITE);
				format(string, sizeof(string), "%s m�wi: Ja ciebie te�.", GetNick(playerid, true));
				ProxDetector(20.0, playerid, string, COLOR_WHITE,COLOR_WHITE,COLOR_WHITE,COLOR_WHITE,COLOR_WHITE);
				ApplyAnimation(playerid, "KISSING", "Playa_Kiss_02", 4.0, 0, 0, 0, 0, 0);
				ApplyAnimation(kissPlayerOffer[playerid], "KISSING", "Playa_Kiss_01", 4.0, 0, 0, 0, 0, 0);
				
				//zerowanie zmiennych:
				kissPlayerOffer[playerid] = 0;
			}
			else
			{
				sendTipMessage(playerid, "Mi�o�� Ci uciek�a!"); 
				return 1;
			}
		}
		if(!response)
		{
			
			new string[128];
			format(string, sizeof(string), "* %s spojrza�(a) na %s i stwierdzi�(a), �e nie chce si� ca�owa�!", GetNick(playerid, true), GetNick(kissPlayerOffer[playerid], true));
			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		
			return 1;
		}
	
	}
    else if(dialogid == 7079)
	{
		if(response)
		{
		    if(HireCar[playerid] == 0)
			{
			    TogglePlayerControllable(playerid, 1);
				RemovePlayerFromVehicleEx(playerid);
				HireCar[playerid] = 0;
				return 0;
			}
    		/*if(PlayerInfo[playerid][pDonateRank] == 0)
			{
				sendTipMessageEx(playerid, COLOR_GRAD2, "Ten pojazd wypo�yczy� mo�e tylko Konto Premium!");
				TogglePlayerControllable(playerid, 1);
				RemovePlayerFromVehicleEx(playerid);
				HireCar[playerid] = 0;
				return 0;
			}*/
    		new veh = HireCar[playerid];
    		if(veh == 0) return 1;
    		if(Car_GetOwner(veh) != RENT_CAR || Car_GetOwnerType(veh) != CAR_OWNER_SPECIAL)
			{
				sendTipMessageEx(playerid, COLOR_GRAD2, "Tego pojazdu nie mo�na wypo�yczy�.");
				TogglePlayerControllable(playerid, 1);
				RemovePlayerFromVehicleEx(playerid);
				HireCar[playerid] = 0;
				return 0;
			}
    		if(CarData[VehicleUID[veh][vUID]][c_Rang] != 0)
			{
			    sendTipMessageEx(playerid, COLOR_GRAD2, "Ten pojazd jest aktualnie wypo�yczony przez inn� osob�.");
			    TogglePlayerControllable(playerid, 1);
				RemovePlayerFromVehicleEx(playerid);
				HireCar[playerid] = 0;
				return 0;
			}
   			if(GetPVarInt(playerid, "rentTimer") != 0)
   			{
   				sendTipMessageEx(playerid, COLOR_GRAD2, "Aktualnie wypo�yczasz pewien pojazd.");
   				TogglePlayerControllable(playerid, 1);
				RemovePlayerFromVehicleEx(playerid);
				HireCar[playerid] = 0;
				return 0;
			}
			if(kaska[playerid] < BIKE_COST)
   			{
   				sendErrorMessage(playerid, "Nie masz tyle kasy!");
				return 0;
			}
    		CarData[VehicleUID[veh][vUID]][c_Rang] = (playerid+1);

    		SetPVarInt(playerid, "rentTimer", SetTimerEx("UnhireRentCar", 15*60*1000, 0, "ii", playerid, veh));

    		TogglePlayerControllable(playerid, 1);
    		ZabierzKase(playerid, BIKE_COST); 
    		HireCar[playerid] = veh;
    		SetPVarInt(playerid, "rentCar", veh);
		}
		if(!response)
		{
			sendTipMessageEx(playerid, COLOR_GRAD2, "Odrzuci�e� propozycj� wypo�yczenia pojazdu.");
			TogglePlayerControllable(playerid, 1);
			RemovePlayerFromVehicleEx(playerid);
			HireCar[playerid] = 0;
		}
	}
	else if(dialogid == 1010)
	{
		if(response)
		{
			new string[128];
			switch(listitem)
			{
				case 0:
				{
					if(!IsPlayerAttachedObjectSlotUsed(playerid, 1))
					{
						//komunikaty
						format(string, sizeof(string), "%s zak�ada na siebie %s", GetNick(playerid, true), GetObjectName(PlayerAdds[playerid][pSlot1]));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						//czynno�ci
						GetObjectBone(playerid, PlayerAdds[playerid][pSlot1]);
						SetPlayerAttachedObject(playerid, 0, PlayerAdds[playerid][pSlot1], boneIDzmienna[playerid]);
						EditAttachedObject(playerid, 0); 
					}
					else
					{
						sendErrorMessage(playerid, "U�ywasz ju� tego slota"); 
						return 1;
					}
				}
				case 1:
				{
					if(!IsPlayerAttachedObjectSlotUsed(playerid, 2))
					{
						//komunikaty
						format(string, sizeof(string), "%s zak�ada na siebie %s", GetNick(playerid, true), GetObjectName(PlayerAdds[playerid][pSlot2]));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						//czynno�ci
						GetObjectBone(playerid, PlayerAdds[playerid][pSlot2]);
						SetPlayerAttachedObject(playerid, 2, PlayerAdds[playerid][pSlot2], boneIDzmienna[playerid]);
						EditAttachedObject(playerid, 2);
					}
					else
					{
						sendErrorMessage(playerid, "U�ywasz ju� tego slota"); 
						return 1;
					}
				
				}
				case 2:
				{
					if(!IsPlayerAttachedObjectSlotUsed(playerid, 3))
					{
						//komunikaty
						format(string, sizeof(string), "%s zak�ada na siebie %s", GetNick(playerid, true), GetObjectName(PlayerAdds[playerid][pSlot3]));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						//czynno�ci
						GetObjectBone(playerid, PlayerAdds[playerid][pSlot3]);
						SetPlayerAttachedObject(playerid, 3, PlayerAdds[playerid][pSlot3], boneIDzmienna[playerid]);
						EditAttachedObject(playerid, 3);
					}
					else
					{
						sendErrorMessage(playerid, "U�ywasz ju� tego slota"); 
						return 1;
					}
				
				}
				case 3:
				{
					if(!IsPlayerAttachedObjectSlotUsed(playerid, 4))
					{
						//komunikaty
						format(string, sizeof(string), "%s zak�ada na siebie %s", GetNick(playerid, true), GetObjectName(PlayerAdds[playerid][pSlot4]));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						//czynno�ci
						GetObjectBone(playerid, PlayerAdds[playerid][pSlot4]);
						SetPlayerAttachedObject(playerid, 4, PlayerAdds[playerid][pSlot4], boneIDzmienna[playerid]);
						EditAttachedObject(playerid, 4);
					}
					else
					{
						sendErrorMessage(playerid, "U�ywasz ju� tego slota"); 
						return 1;
					}
				}
				case 4:
				{
					if(!IsPlayerAttachedObjectSlotUsed(playerid, 5))
					{
						//komunikaty
						format(string, sizeof(string), "%s zak�ada na siebie %s", GetNick(playerid, true), GetObjectName(PlayerAdds[playerid][pSlot5]));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						//czynno�ci
						GetObjectBone(playerid, PlayerAdds[playerid][pSlot5]);
						SetPlayerAttachedObject(playerid, 5, PlayerAdds[playerid][pSlot5], boneIDzmienna[playerid]);
						EditAttachedObject(playerid, 5);
					}
					else
					{
						sendErrorMessage(playerid, "U�ywasz ju� tego slota"); 
						return 1;
					}
				}
				case 5:
				{
					if(!IsPlayerAttachedObjectSlotUsed(playerid, 6))
					{
						//komunikaty
						format(string, sizeof(string), "%s zak�ada na siebie %s", GetNick(playerid, true), GetObjectName(PlayerAdds[playerid][pSlot6]));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						//czynno�ci
						GetObjectBone(playerid, PlayerAdds[playerid][pSlot6]);
						SetPlayerAttachedObject(playerid, 6, PlayerAdds[playerid][pSlot6], boneIDzmienna[playerid]);
						EditAttachedObject(playerid, 6);
					}
					else
					{
						sendErrorMessage(playerid, "U�ywasz ju� tego slota!"); 
						return 1;
					}
				}
				case 6:
				{
					if(!IsPlayerAttachedObjectSlotUsed(playerid, 7))
					{
						//komunikaty
						format(string, sizeof(string), "%s zak�ada na siebie %s", GetNick(playerid, true), GetObjectName(PlayerAdds[playerid][pSlot7]));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						//czynno�ci
						GetObjectBone(playerid, PlayerAdds[playerid][pSlot7]);
						SetPlayerAttachedObject(playerid, 7, PlayerAdds[playerid][pSlot7], boneIDzmienna[playerid]);
						EditAttachedObject(playerid, 7);
					}
					else
					{
						sendErrorMessage(playerid, "U�ywasz ju� tego slota"); 
						return 1;
					}
				}
				case 7:
				{
					if(!IsPlayerAttachedObjectSlotUsed(playerid, 8))
					{
						//komunikaty
						format(string, sizeof(string), "%s zak�ada na siebie %s", GetNick(playerid, true), GetObjectName(PlayerAdds[playerid][pSlot8]));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						//czynno�ci
						GetObjectBone(playerid, PlayerAdds[playerid][pSlot8]);
						SetPlayerAttachedObject(playerid, 8, PlayerAdds[playerid][pSlot8], boneIDzmienna[playerid]);
						EditAttachedObject(playerid, 8);
					}
					else
					{
						sendErrorMessage(playerid, "U�ywasz ju� tego slota"); 
						return 1;
					}
				}
				case 8:
				{
					if(!IsPlayerAttachedObjectSlotUsed(playerid, 9))
					{
						//komunikaty
						format(string, sizeof(string), "%s zak�ada na siebie %s", GetNick(playerid, true), GetObjectName(PlayerAdds[playerid][pSlot9]));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						//czynno�ci
						GetObjectBone(playerid, PlayerAdds[playerid][pSlot9]);
						SetPlayerAttachedObject(playerid, 9, PlayerAdds[playerid][pSlot9], boneIDzmienna[playerid]);
						EditAttachedObject(playerid, 9);
					}
					else
					{
						sendErrorMessage(playerid, "U�ywasz ju� tego slota"); 
						return 1;
					}
					
				}
				case 9:
				{
					if(!IsPlayerAttachedObjectSlotUsed(playerid, 10))
					{
						//komunikaty
						format(string, sizeof(string), "%s zak�ada na siebie %s", GetNick(playerid, true), GetObjectName(PlayerAdds[playerid][pSlot10]));
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						//czynno�ci
						GetObjectBone(playerid, PlayerAdds[playerid][pSlot10]);
						SetPlayerAttachedObject(playerid, 10, PlayerAdds[playerid][pSlot10], boneIDzmienna[playerid]);
						EditAttachedObject(playerid, 10);
					}
					else
					{
						sendErrorMessage(playerid, "U�ywasz ju� tego slota!");
						return 1;
					}
				}
			}
			return 1;
		}
		if(!response)
		{
			sendTipMessage(playerid, "Wy��czy�e� dialog ubioru"); 
			return 1;
		}
		
	}
	else if(dialogid == 1012)
	{
		if(!response)
		{
			sendTipMessage(playerid, "Wy��czy�e� dialog tras"); 
			return 1;
		}
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					SetPlayerCheckpoint(playerid, 2005.9244,-1442.3917,13.5631, 3);
					sendTipMessage(playerid, "Trasa rozpoczyna si� spod szpitala, udaj si� tam!");
					sendTipMessage(playerid, "Aby anulowa� wpisz /stopbieg"); 
					SetPVarInt(playerid, "RozpoczalBieg", 1);
				}
				case 1:
				{
					SetPlayerCheckpoint(playerid, 806.4952,-1334.9512,13.5469, 3);
					sendTipMessage(playerid, "Trasa rozpoczyna si� spod metra udaj si� tam!");
					sendTipMessage(playerid, "Aby anulowa� wpisz /stopbieg"); 
					SetPVarInt(playerid, "RozpoczalBieg", 1);
				}
				case 3:
				{
					sendTipMessage(playerid, "Aktualnie trwaj� prace nad t� tras�!"); 
				}
				case 4:
				{
					sendTipMessage(playerid, "Aktualnie trwaj� prace nad t� tras�!"); 
				}
				case 5:
				{
					sendTipMessage(playerid, "Aktualnie trwaj� prace nad t� tras�!"); 
				}
			}
			return 1;
		}
	}
	else if(dialogid == 9666)//dialog tak/nie admina
	{
		if(response)
		{
			sendTipMessage(playerid, "Zag�osowa�e� na TAK!"); 
			glosowanie_admina_tak++;
			SetPVarInt(playerid, "glosowal_w_ankiecie", 1);
			return 1;
		}
		if(!response)
		{
			sendTipMessage(playerid, "Zag�osowa�e� na NIE!"); 
			glosowanie_admina_nie++;
			SetPVarInt(playerid, "glosowal_w_ankiecie", 1); 
			return 1;
		}
	}
	else if(dialogid == D_KONTAKTY_DZWON)
	{
		if(response)
		{
			new string[12];
			format(string, sizeof(string), "%d", Kontakty[playerid][PobierzIdKontaktuZDialogu(playerid, listitem)][eNumer]);
			RunCommand(playerid, "/dzwon",  string);
		}
	}
	else if(dialogid == D_KONTAKTY_SMS)
	{
		if(response)
		{
			SetPVarInt(playerid, "kontakty-dialog-slot", PobierzIdKontaktuZDialogu(playerid, listitem));
			ShowPlayerDialogEx(playerid, D_KONTAKTY_SMS_WIADOMOSC, DIALOG_STYLE_INPUT, "Kontakty - SMS", "Wprowad� wiadomo��:", "Wy�lj SMS", "Zamknij");
		}
	}
	else if(dialogid == D_KONTAKTY_SMS_WIADOMOSC)
	{
		if(response)
		{
			//todo numer
			new string[256];
			format(string, sizeof(string), "%d %s", Kontakty[playerid][GetPVarInt(playerid, "kontakty-dialog-slot")][eNumer], inputtext);
			RunCommand(playerid, "/sms",  string);
		}
	}
	else if(dialogid == D_KONTAKTY_EDYTUJ)
	{
		if(response)
		{
			SetPVarInt(playerid, "kontakty-dialog-slot", PobierzIdKontaktuZDialogu(playerid, listitem));
			ShowPlayerDialogEx(playerid, D_KONTAKTY_EDYTUJ_NOWA_NAZWA, DIALOG_STYLE_INPUT, "Kontakty - edytuj", "Wprowad� now� nazw� kontaktu.\nMaksymalnie "#MAX_KONTAKT_NAME" znaki", "Zmie�", "Anuluj");
		}
	}
	else if(dialogid == D_KONTAKTY_EDYTUJ_NOWA_NAZWA)
	{
		if(response)
		{
			EdytujKontakt(playerid, GetPVarInt(playerid, "kontakty-dialog-slot"), inputtext);
			SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kontakt edytowany.");
		}
	}
	else if(dialogid == D_KONTAKTY_USUN)
	{
		if(response)
		{
			UsunKontakt(playerid, PobierzIdKontaktuZDialogu(playerid, listitem));
			SendClientMessage(playerid, COLOR_LIGHTBLUE, "Kontakt usuni�ty.");
		}
	}
	else if(dialogid == D_KONTAKTY_LISTA)
	{
		if(response)
		{
			SendClientMessage(playerid, COLOR_WHITE, inputtext);
		}
	}
	return 0;
}
//ondialogresponse koniec