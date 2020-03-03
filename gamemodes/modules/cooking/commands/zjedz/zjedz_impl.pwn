//-----------------------------------------------<< Source >>------------------------------------------------//
//                                                   zjedz                                                   //
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
// Autor: mrucznik
// Data utworzenia: 03.03.2020


//

//------------------<[ Implementacja: ]>-------------------
command_zjedz_Impl(playerid)
{
	new string[128];
	new sendername[MAX_PLAYER_NAME];
    
    if(PlayerBoxing[playerid] > 0)
    {
        sendTipMessageEx(playerid, COLOR_GREY, "Nie mo�esz je�� kiedy walczysz na ringu !");
        return 1;
    }
    new cookid;
    if( sscanf(params, "d", cookid))
    {
        sendTipMessage(playerid, "U�yj /jedz [numer potrawy]");
        return 1;
    }

    if(cookid < 1 || cookid > 5) { sendTipMessageEx(playerid, COLOR_GREY, "   Numer potrawy od 1 do 5"); return 1; }
    else if(cookid == 1 && Cooking[playerid][pCWeight1] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Nie ugotowa�e� �adnej potrawy pod numerem(1) !"); return 1; }
    else if(cookid == 2 && Cooking[playerid][pCWeight2] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Nie ugotowa�e� �adnej potrawy pod numerem(2) !"); return 1; }
    else if(cookid == 3 && Cooking[playerid][pCWeight3] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Nie ugotowa�e� �adnej potrawy pod numerem(3) !"); return 1; }
    else if(cookid == 4 && Cooking[playerid][pCWeight4] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Nie ugotowa�e� �adnej potrawy pod numerem(4) !"); return 1; }
    else if(cookid == 5 && Cooking[playerid][pCWeight5] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Nie ugotowa�e� �adnej potrawy pod numerem(5) !"); return 1; }
    GetPlayerName(playerid, sendername, sizeof(sendername));
    new Float:health;
    if(GetPlayerHealth(playerid, health) < 80)
    {
        new hp = 0;
        switch (cookid)
        {
            case 1:
            {
                if(Cooking[playerid][pCookID1] == 16 || Cooking[playerid][pCookID1] == 18)
                {//Dolphin or Turtle
                    PoziomPoszukiwania[playerid] += 1;
                    SetPlayerCriminal(playerid,INVALID_PLAYER_ID, "Spo�ywanie zagro�onych gatunk�w");
                }
                if(Cooking[playerid][pCookID1] == 31 && random(2) == 1) //wuhan bat
                {
                    InfectPlayer(playerid, KORONAWIRUS);
                    SendClientMessage(playerid, COLOR_RED, "Zarazi�e� si� coronawirusem! Lepiej id� do lekarza.");
                }
                SetPlayerHealth(playerid, health + (Cooking[playerid][pCWeight1]));
                hp = Cooking[playerid][pCWeight1];
                format(string, sizeof(string), "* %s zjada %s.", sendername, Cooking[playerid][pCook][0]);
                ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                format(string, sizeof(string), "* Zjad�e� %s wa��c� %d, dosta�e� wi�cej �ycia."[pCook][0][playerid][pCook1], hp);
                SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
            }
            case 2:
            {
                if(Cooking[playerid][pCookID2] == 16 || Cooking[playerid][pCookID2] == 18)
                {//Dolphin or Turtle
                    PoziomPoszukiwania[playerid] += 1;
                    SetPlayerCriminal(playerid,INVALID_PLAYER_ID, "Spo�ywanie zagro�onych gatunk�w");
                }
                if(Cooking[playerid][pCookID2] == 31 && random(2) == 1) //wuhan bat
                {
                    InfectPlayer(playerid, KORONAWIRUS);
                    SendClientMessage(playerid, COLOR_RED, "Zarazi�e� si� coronawirusem! Lepiej id� do lekarza.");
                }
                SetPlayerHealth(playerid, health + (Cooking[playerid][pCWeight2] / 3));
                hp = Cooking[playerid][pCWeight2];
                format(string, sizeof(string), "* %s zjada %s.", sendername, Cooking[playerid][pCook][1]);
                ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                format(string, sizeof(string), "* Zjad�e� %s wa��c� %d, dosta�e� wi�cej �ycia."[pCook][1][playerid][pCook][1], hp);
                SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
            }
            case 3:
            {
                if(Cooking[playerid][pCookID3] == 16 || Cooking[playerid][pCookID3] == 18)
                {//Dolphin or Turtle
                    PoziomPoszukiwania[playerid] += 1;
                    SetPlayerCriminal(playerid,INVALID_PLAYER_ID, "Spo�ywanie zagro�onych gatunk�w");
                }
                if(Cooking[playerid][pCookID3] == 31 && random(2) == 1) //wuhan bat
                {
                    InfectPlayer(playerid, KORONAWIRUS);
                    SendClientMessage(playerid, COLOR_RED, "Zarazi�e� si� coronawirusem! Lepiej id� do lekarza.");
                }
                SetPlayerHealth(playerid, health + (Cooking[playerid][pCWeight3] / 3));
                hp = Cooking[playerid][pCWeight3];
                format(string, sizeof(string), "* %s zjada %s.", sendername, Cooking[playerid][pCook][2]);
                ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                format(string, sizeof(string), "* Zjad�e� %s o wadze %d, dosta�e� wi�cej �ycia.",Cooki[pCook][2]rid][pCook][2], hp);
                SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
            }
            case 4:
            {
                if(Cooking[playerid][pCookID4] == 16 || Cooking[playerid][pCookID4] == 18)
                {//Dolphin or Turtle
                    PoziomPoszukiwania[playerid] += 1;
                    SetPlayerCriminal(playerid,INVALID_PLAYER_ID, "Spo�ywanie zagro�onych gatunk�w");
                }
                if(Cooking[playerid][pCookID4] == 31 && random(2) == 1) //wuhan bat
                {
                    InfectPlayer(playerid, KORONAWIRUS);
                    SendClientMessage(playerid, COLOR_RED, "Zarazi�e� si� coronawirusem! Lepiej id� do lekarza.");
                }
                SetPlayerHealth(playerid, health + (Cooking[playerid][pCWeight4] / 3));
                hp = Cooking[playerid][pCWeight4];
                format(string, sizeof(string), "* %s zjada %s.", sendername, Cooking[playerid][pCook][3]);
                ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                format(string, sizeof(string), "* Zjad�e� %s o wadze %d, dosta�e� wi�cej �ycia.",Cooki[pCook][3]rid][pCook][3], hp);
                SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
            }
            case 5:
            {
                if(Cooking[playerid][pCookID5] == 16 || Cooking[playerid][pCookID5] == 18)
                {//Dolphin or Turtle
                    PoziomPoszukiwania[playerid] += 1;
                    SetPlayerCriminal(playerid,INVALID_PLAYER_ID, "Spo�ywanie zagro�onych gatunk�w");
                }
                if(Cooking[playerid][pCookID5] == 31 && random(2) == 1) //wuhan bat
                {
                    InfectPlayer(playerid, KORONAWIRUS);
                    SendClientMessage(playerid, COLOR_RED, "Zarazi�e� si� coronawirusem! Lepiej id� do lekarza.");
                }
                SetPlayerHealth(playerid, health + (Cooking[playerid][pCWeight5] / 3));
                hp = Cooking[playerid][pCWeight5];
                format(string, sizeof(string), "* %s zjada %s.", sendername, Cooking[playerid][pCook][4]);
                ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
                format(string, sizeof(string), "* Zjad�e� %s o wadze %d, dosta�e� wi�cej �ycia.",Cooki[pCook][4]rid][pCook][4], hp);
                SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
            }
        }
        ClearCookingID(playerid, cookid);

        if(random(20) == 0) //5% szans na zatrucie
        {
            InfectPlayer(playerid, ZATRUCIE);
        }
    }
    else
    {
        sendTipMessageEx(playerid, COLOR_GREY, "Tw�j poziom �ycia jest za wysoki, mo�esz je�� od 80 HP !");
        return 1;
    }
    return 1;
}

//end