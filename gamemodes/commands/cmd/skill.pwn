//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//-------------------------------------------------[ skill ]-------------------------------------------------//
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

YCMD:skill(playerid, params[], help)
{
	new string[128];
	new level;
	if( sscanf(params, "d", level))
	{
		SendClientMessage(playerid, COLOR_WHITE, "|__________________ Skill Info __________________|");
		SendClientMessage(playerid, COLOR_WHITE, "U�YJ: /skill [numer]");
		SendClientMessage(playerid, COLOR_GREY, "| 1: �owca Nagr�d        6: Rybak");
		SendClientMessage(playerid, COLOR_GREY, "| 2: Prawnik             7: Mechanik");
		SendClientMessage(playerid, COLOR_GREY, "| 3: Prostytutka         8: Busiarz");
		SendClientMessage(playerid, COLOR_GREY, "| 4: Diler Drag�w        9: Boxer");
		SendClientMessage(playerid, COLOR_GREY, "| 5: Z�odziej aut        10: Diler Broni");
		SendClientMessage(playerid, COLOR_GREY, "| 11: Kurier             12: --------");
		SendClientMessage(playerid, COLOR_WHITE, "|________________________________________________|");
		return 1;
	}

	if (level == 1)//�owca nagr�d
	{
		level = PlayerInfo[playerid][pDetSkill];
		if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci �owcy Nagr�d s� na poziomie = 1."); format(string, sizeof(string), "Musisz znale�� %d ludzi aby zwi�kszy� skill.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci �owcy Nagr�d s� na poziomie = 2."); format(string, sizeof(string), "Musisz znale�� %d ludzi aby zwi�kszy� skill.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci �owcy Nagr�d s� na poziomie = 3."); format(string, sizeof(string), "Musisz znale�� %d ludzi aby zwi�kszy� skill.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci �owcy Nagr�d s� na poziomie = 4."); format(string, sizeof(string), "Musisz znale�� %d ludzi aby zwi�kszy� skill.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci �owcy Nagr�d s� na poziomie = 5."); }
	}
	else if (level == 2)//Lawyer
	{
		level = PlayerInfo[playerid][pLawSkill];
		if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Prawnika s� na poziomie = 1."); format(string, sizeof(string), "Musisz uwolni� %d ludzi aby zwi�kszy� skill.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Prawnika s� na poziomie = 2."); format(string, sizeof(string), "Musisz uwolni� %d ludzi aby zwi�kszy� skill.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Prawnika s� na poziomie = 3."); format(string, sizeof(string), "Musisz uwolni� %d ludzi aby zwi�kszy� skill.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Prawnika s� na poziomie = 4."); format(string, sizeof(string), "Musisz uwolni� %d ludzi aby zwi�kszy� skill.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Prawnika s� na poziomie = 5."); }
	}
	else if (level == 3)//Whore
	{
		level = PlayerInfo[playerid][pSexSkill];
		if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Sexu s� na poziomie = 1."); format(string, sizeof(string), "Musisz wyrucha� %d ludzi aby zwi�kszy� skill.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Sexu s� na poziomie = 2."); format(string, sizeof(string), "Musisz wyrucha� %d ludzi aby zwi�kszy� skill.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Sexu s� na poziomie = 3."); format(string, sizeof(string), "Musisz wyrucha� %d ludzi aby zwi�kszy� skill.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Sexu s� na poziomie = 4."); format(string, sizeof(string), "Musisz wyrucha� %d ludzi aby zwi�kszy� skill.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Sexu s� na poziomie = 5."); }
	}
	else if (level == 4)//Drugs Dealer
	{
		level = PlayerInfo[playerid][pDrugsSkill];
		if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Dilera drag�w s� na poziomie = 1."); format(string, sizeof(string), "Musisz sprzeda� dragi %d ludziom aby zwi�kszy� skill up.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Dilera drag�w s� na poziomie = 2."); format(string, sizeof(string), "Musisz sprzeda� dragi %d ludziom aby zwi�kszy� skill up.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Dilera drag�w s� na poziomie = 3."); format(string, sizeof(string), "Musisz sprzeda� dragi %d ludziom aby zwi�kszy� skill up.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Dilera drag�w s� na poziomie = 4."); format(string, sizeof(string), "Musisz sprzeda� dragi %d ludziom aby zwi�kszy� skill up.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Dilera drag�w s� na poziomie = 5."); }
	}
	else if (level == 5)//Car Jacker
	{
		level = PlayerInfo[playerid][pJackSkill];
		if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Z�odzieja Aut s� na poziomie = 1."); format(string, sizeof(string), "Musisz ukra�� %d aut aby zwi�kszy� skill.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Z�odzieja Aut s� na poziomie = 2."); format(string, sizeof(string), "Musisz ukra�� %d aut aby zwi�kszy� skill.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Z�odzieja Aut s� na poziomie = 3."); format(string, sizeof(string), "Musisz ukra�� %d aut aby zwi�kszy� skill.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Z�odzieja Aut s� na poziomie = 4."); format(string, sizeof(string), "Musisz ukra�� %d aut aby zwi�kszy� skill.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Z�odzieja Aut s� na poziomie = 5."); }
	}
	/*else if (level == 6)//News Reporter
	{
		level = PlayerInfo[playerid][pNewsSkill];
		if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Reportera s� na poziomie = 1."); format(string, sizeof(string), "Musisz napisa� %d news�w aby zwi�kszy� skill.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Reportera s� na poziomie = 2."); format(string, sizeof(string), "Musisz napisa� %d news�w aby zwi�kszy� skill.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Reportera s� na poziomie = 3."); format(string, sizeof(string), "Musisz napisa� %d news�w aby zwi�kszy� skill.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Reportera s� na poziomie = 4."); format(string, sizeof(string), "Musisz napisa� %d news�w aby zwi�kszy� skill.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Reportera s� na poziomie = 5."); }
	}*/
	else if (level == 6)//Fishing
	{
		level = PlayerInfo[playerid][pFishSkill];
		if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci W�dkowania s� na poziomie = 1."); format(string, sizeof(string), "Musisz z�owi� %d ryb aby zwi�kszy� skill.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci W�dkowania s� na poziomie = 2."); format(string, sizeof(string), "Musisz z�owi� %d ryb aby zwi�kszy� skill.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci W�dkowania s� na poziomie = 3."); format(string, sizeof(string), "Musisz z�owi� %d ryb aby zwi�kszy� skill.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci W�dkowania s� na poziomie = 4."); format(string, sizeof(string), "Musisz z�owi� %d ryb aby zwi�kszy� skill.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci W�dkowania s� na poziomie = 5."); }
	}
	else if (level == 7)//Car Mechanic
	{
		level = PlayerInfo[playerid][pMechSkill];
		if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Mechanika s� na poziomie = 1."); format(string, sizeof(string), "Musisz da� %d us�ug aby zwi�kszy� skill.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Mechanika s� na poziomie = 2."); format(string, sizeof(string), "Musisz da� %d us�ug aby zwi�kszy� skill.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Mechanika s� na poziomie = 3."); format(string, sizeof(string), "Musisz da� %d us�ug aby zwi�kszy� skill.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Mechanika s� na poziomie = 4."); format(string, sizeof(string), "Musisz da� %d us�ug aby zwi�kszy� skill.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Mechanika s� na poziomie = 5."); }
	}
	else if (level == 8)//Car Dealer
	{
		level = PlayerInfo[playerid][pCarSkill];
		if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Kierowcy Autobusu s� na poziomie = 1."); format(string, sizeof(string), "Musisz wykona� %d tras aby zwi�kszy� skill.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Kierowcy Autobusu s� na poziomie = 2."); format(string, sizeof(string), "Musisz wykona� %d tras aby zwi�kszy� skill.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Kierowcy Autobusu s� na poziomie = 3."); format(string, sizeof(string), "Musisz wykona� %d tras aby zwi�kszy� skill.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Kierowcy Autobusu s� na poziomie = 4."); format(string, sizeof(string), "Musisz wykona� %d tras aby zwi�kszy� skill.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Kierowcy Autobusu s� na poziomie = 5."); }
	}
	else if (level == 9)//Boxer
	{
		level = PlayerInfo[playerid][pBoxSkill];
		if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Boksera s� na poziomie = 1."); format(string, sizeof(string), "Musisz wygra� %d rund aby zwi�kszy� skill.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Boksera s� na poziomie = 2."); format(string, sizeof(string), "Musisz wygra� %d rund aby zwi�kszy� skill.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Boksera s� na poziomie = 3."); format(string, sizeof(string), "Musisz wygra� %d rund aby zwi�kszy� skill.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Boksera s� na poziomie = 4."); format(string, sizeof(string), "Musisz wygra� %d rund aby zwi�kszy� skill.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Boksera s� na poziomie = 5."); }
	}
	else if (level == 10)//Diler Broni
	{
		level = PlayerInfo[playerid][pGunSkill];
		if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Dilera Broni s� na poziomie = 1."); format(string, sizeof(string), "Musisz sprzeda� %d broni aby zwi�kszy� skill.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Dilera Broni s� na poziomie = 2."); format(string, sizeof(string), "Musisz sprzeda� %d broni aby zwi�kszy� skill.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Dilera Broni s� na poziomie = 3."); format(string, sizeof(string), "Musisz sprzeda� %d broni aby zwi�kszy� skill.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Dilera Broni s� na poziomie = 4."); format(string, sizeof(string), "Musisz sprzeda� %d broni aby zwi�kszy� skill.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Dilera Broni s� na poziomie = 5."); }
	}
    else if (level == 11)//Kurier
	{
		level = PlayerInfo[playerid][pTruckSkill];
		if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Kuriera s� na poziomie = 1."); format(string, sizeof(string), "Musisz przewiezc %d paczek aby zwi�kszy� skill.", (50 - level)*5); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Kuriera s� na poziomie = 2."); format(string, sizeof(string), "Musisz przewiezc %d paczek aby zwi�kszy� skill.", (100 - level)*5); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Kuriera s� na poziomie = 3."); format(string, sizeof(string), "Musisz przewiezc %d paczek aby zwi�kszy� skill.", (200 - level)*5); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Kuriera s� na poziomie = 4."); format(string, sizeof(string), "Musisz przewiezc %d paczek aby zwi�kszy� skill.", (400 - level)*5); SendClientMessage(playerid, COLOR_YELLOW, string); }
		else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Twoje umiej�tno�ci Kuriera s� na poziomie = 5."); }
	}
	else
	{
        return RunCommand(playerid, "/skill",  "");
	}
    return 1;
}
