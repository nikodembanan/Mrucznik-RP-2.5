//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//-----------------------------------------------[ screenshot ]-----------------------------------------------//
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
// Autor: werem
// Data utworzenia: 20.04.2020

// Opis:
/*

*/


// Notatki skryptera:
/*
	
*/
YCMD:screenshot(playerid, params[], help)
{
    if(IsPlayerConnected(playerid))
    {
        if(!Worek_MamWorek[playerid])
        {
            if(!GetPVarInt(playerid, "HasScreenFilter"))
            {
                Have_Worek(playerid);
                SetPVarInt(playerid, "HasScreenFilter", 1);
            }
            else
            {
                UnHave_Worek(playerid);
                DeletePVar(playerid, "HasScreenFilter");
            }
        }
        else sendErrorMessage(playerid, "Masz na sobie za�o�ony worek!");
    }
    return 1;
}