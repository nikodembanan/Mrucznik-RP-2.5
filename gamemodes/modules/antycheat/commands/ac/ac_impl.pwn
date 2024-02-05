//-----------------------------------------------<< Source >>------------------------------------------------//
//                                                     ac                                                    //
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
// Autor: Mrucznik
// Data utworzenia: 16.09.2019


//

//------------------<[ Implementacja: ]>-------------------
mru_ac_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    #pragma unused inputtext
    if(dialogid == DIALOG_AC_PANEL)
    {
        if(response)
        {
            new string[256];
            DynamicGui_SetDialogValue(playerid, listitem);

            for(new eNexACAdditionalSettings:i; i<eNexACAdditionalSettings; i++)
            {
                strcat(string, GetNexACAdditionalSettingName(i));
                strcat(string, "\n");
            }
            ShowPlayerDialogEx(playerid, DIALOG_AC_PANEL_CHANGE, DIALOG_STYLE_LIST, "Panel Anty-Cheat'a", 
                string,
                "Ustaw", "Wyjd�");
        }
        return 1;
    }
    else if(dialogid == DIALOG_AC_PANEL_CHANGE)
    {
        if(response)
        {
            new code = DynamicGui_GetDialogValue(playerid);
            new eNexACAdditionalSettings:type = eNexACAdditionalSettings:listitem;
            NexACSaveCode(code, type);
            Log(adminLog, INFO, "Admin %s ustawi� funkcj� anty-cheata %s[%d] na %s", 
                GetPlayerLogName(playerid), NexACDecodeCode(code), code, GetNexACAdditionalSettingName(type));
            ac_ShowDialog(playerid);
        }
        return 1;
    }
    return 0;
}

ac_ShowDialog(playerid)
{
    new string[70*sizeof(nexac_ac_names)];
    for(new i; i<sizeof(nexac_ac_names); i++)
    {
        if(IsAntiCheatEnabled(i)) 
        {
            strcat(string, sprintf("{00FF00}%s[%d] - %s{FFFFFF}\n", nexac_ac_names[i], i, GetNexACAdditionalSettingName(nexac_additional_settings[i])));
        }
        else
        {
            strcat(string, sprintf("{FF0000}%s[%d] - OFF{FFFFFF}\n", nexac_ac_names[i], i));
        }
    }
    ShowPlayerDialogEx(playerid, DIALOG_AC_PANEL, DIALOG_STYLE_LIST, "Panel Anty-Cheat'a", string, "Zmie�", "Wyjd�");
}

command_ac_Impl(playerid)
{
    if(PlayerInfo[playerid][pAdmin] >= 1000 || IsAScripter(playerid))
	{
        ac_ShowDialog(playerid);
	}
    return 1;
}

//end