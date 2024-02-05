//-----------------------------------------------<< Komenda >>-----------------------------------------------//
//------------------------------------------------[ ukradnij ]-----------------------------------------------//
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


#define DAMAGES_PENALTY_CALC_CONST 1.64										//1 + 0.8^2
#define DAMAGES_PENALTY_CALC_EXP_CONST 0.65959498911480940622032627544671	// 4/3 * ln(DAMAGES_PENALTY_CALC_CONST)
#define EULER_NUMBER 2.7182818284590452353602874713527

#define REWARD_MODEL_DIVISOR 100
#define HOT_STUFF_BONUS 2
#define VERY_HOT_STUFF_BONUS 3
#define LSPD_UPDATE_PERIOD_MS 5000
#define LSPD_GPS_DURATION_SHORT_MS 30000 
#define LSPD_GPS_DURATION_LONG_MS 180000 
#define LSPD_GPS_DURATION_DELUXE_MS 540000 
#define LSPD_GPS_CHANCE_PERCENT 33
#define LSPD_LONG_GPS_CHANCE 5
#define DELUXE_CAR_REWARD 48000
#define COOLDOWN_1_S 600
#define COOLDOWN_2_S 540
#define COOLDOWN_3_S 480
#define COOLDOWN_4_S 420
#define COOLDOWN_5_S 360


new SELLCAR1[] = { 3000, 3124, 3245, 3349, 3475, 3574, 3636, 3762, 3895, 3946, 4000 };
new SELLCAR2[] = { 4099, 4135, 4255, 4378, 4457, 4563, 4614, 4721, 4878, 4988, 5000 };
new SELLCAR3[] = { 5058, 5175, 5212, 5377, 5454, 5555, 5678, 5751, 5865, 5964, 6000 };
new SELLCAR4[] = { 6077, 6123, 6275, 6378, 6422, 6565, 6613, 6752, 6897, 6911, 7000 };
new SELLCAR5[] = { 7100, 7200, 7300, 7400, 7500};

new ukradnij_szansa_lspd = LSPD_GPS_CHANCE_PERCENT;
new ukradnij_szansa_lspd_kryt = LSPD_LONG_GPS_CHANCE;


EnableCarThiefCheckpoint(playerid)
{
	if(stole_a_car[playerid])
	{
		new Float:chop_shop_pos[3];
		new is_car_deluxe = (stole_a_car_lspd_bonus[playerid] == 3);
		ChooseChopShop(playerid, chop_shop_pos, is_car_deluxe);
		SendClientMessage(playerid, COLOR_YELLOW, "Dostarcz ukradziony pojazd do dziupli - jej lokalizacja zosta³a zaznaczona na mapie.");
		SendClientMessage(playerid, COLOR_YELLOW, "Postaraj siê jechaæ ostro¿nie - im mniej uszkodzisz pojazd, tym wiêcej zarobisz.");

		stole_a_car_checkpoint[playerid][0] = CreateDynamicMapIcon(chop_shop_pos[0], chop_shop_pos[1], chop_shop_pos[2], 0, 0xFF1111FF, -1, -1, playerid, 6000.0, MAPICON_GLOBAL_CHECKPOINT);
		stole_a_car_checkpoint[playerid][1] = CreateDynamicCircle(chop_shop_pos[0], chop_shop_pos[1], 16.0, -1, -1, playerid);
	}
}


DestroyCarThiefLSPDMapIcon(playerid)
{
	new icon_id = stole_a_car_lspd_map_icon[playerid];

	if(IsValidDynamicMapIcon(icon_id))
	{
		DestroyDynamicMapIcon(icon_id);
	}
 
	if(stole_a_car_timers_ids[playerid][0] != -1)
	{
		KillTimer(stole_a_car_timers_ids[playerid][0]);
		stole_a_car_timers_ids[playerid][0] = -1;
	}

	if(stole_a_car_timers_ids[playerid][1] != -1)
	{
		KillTimer(stole_a_car_timers_ids[playerid][1]);
		stole_a_car_timers_ids[playerid][1] = -1;
	}

	stole_a_car_lspd_map_icon[playerid] = -1;

	return 1;
}


// Wybieranie dziupli metod¹ ruletkow¹ https://en.wikipedia.org/wiki/Fitness_proportionate_selection
static ChooseChopShop(playerid, chop_shop_pos[], is_car_deluxe)
{
		new Float:chop_shops_positions[3][3];

		if(is_car_deluxe)
		{
			chop_shops_positions[0] = {-1548.3618, 123.6438, 3.2966};
			chop_shops_positions[1] = {577.5023, 1222.4153, 11.7113};
			chop_shops_positions[2] = {2282.3511, -2018.0242, 13.4167};
		}
		else
		{
			chop_shops_positions[0] = {2282.3511, -2018.0242, 13.4167};
			chop_shops_positions[1] = {1410.6040, -135.5417, 22.2146};
			chop_shops_positions[2] = {-419.6872, -1737.5532, 7.9339};
		}

		new Float:cs_distances[sizeof(chop_shops_positions)], Float:cs_distance_sum = 0.0, Float:cs_distance_roulette_sum = 0.0;
		new Float:chop_shop_random = float(true_random(100)) / 100.0, chop_shop_id = 0;

		for(new i = 0; i < sizeof(chop_shops_positions); i++)
		{
			new Float:cs_pos_x = chop_shops_positions[i][0], Float:cs_pos_y = chop_shops_positions[i][1], Float:cs_pos_z = chop_shops_positions[i][2];
			cs_distances[i] = GetPlayerDistanceFromPoint(playerid, cs_pos_x, cs_pos_y, cs_pos_z);
			cs_distance_sum += cs_distances[i];
		}

		chop_shop_random *= cs_distance_sum;
		for(new i = 0; i < sizeof(chop_shops_positions); i++)
		{
			if(cs_distances[i] + cs_distance_roulette_sum >= chop_shop_random)
			{
				chop_shop_id = i;
				break;
			}

			cs_distance_roulette_sum += cs_distances[i];
		}

		chop_shop_pos[0] = chop_shops_positions[chop_shop_id][0];
		chop_shop_pos[1] = chop_shops_positions[chop_shop_id][1];
		chop_shop_pos[2] = chop_shops_positions[chop_shop_id][2];
}


static CountLSPDMembersOnDuty(lspd_members[], &lspd_members_count, &lspd_members_counted)
{
	if(!lspd_members_counted)
	{
		foreach(new i : Player)
		{
			if(IsPlayerConnected(i) && (PlayerInfo[i][pLider] == 1 || PlayerInfo[i][pMember] == 1) && OnDuty[i])
			{
				lspd_members[lspd_members_count++] = i;
				PlayerPlaySound(i, 45400, 0.0, 0.0, 0.0);
			}
		}

		lspd_members_counted = true;
	}
}


static UkradnijVerify(playerid, veh_id)
{
	if(PlayerInfo[playerid][pJob] != JOB_CARTHIEF)
	{
		sendTipMessageEx(playerid, COLOR_GREY, "Nie jesteœ z³odziejem aut!");
		return 0;
	}

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
	{
		sendTipMessageEx(playerid, COLOR_GREY, "Nie znajdujesz siê w pojeŸdzie jako kierowca!");
		return 0;
	}

	if(veh_id > CAR_End)
	{
		sendTipMessageEx(playerid, COLOR_GREY, "Pojazd, w którym siê znajdujesz ma za dobre zabezpieczenia, by zostaæ przyjêtym w dziupli!");
		return 0;
	}

	if(KradniecieWozu[playerid] != veh_id)
	{
		sendTipMessageEx(playerid, COLOR_GREY, "Najpierw uruchom silnik (u¿yj /kradnij)!");
		return 0;		
	}

	if(PlayerOnMission[playerid] > 0)
	{
		sendTipMessageEx(playerid, COLOR_GREY, "Jesteœ na misji, nie mo¿esz tego u¿yæ!");
		return 0;
	}

	if(stole_a_car[playerid])
	{
		sendTipMessageEx(playerid, COLOR_GREY, "U¿y³eœ ju¿ /ukradnij w tym pojeŸdzie!");
		return 0;
	}

	if(PlayerInfo[playerid][pCarTime] != 0)
	{
		new komunikat[128];
		format(komunikat, sizeof(komunikat), "Ukrad³eœ ju¿ wczeœniej wóz, poczekaj %d sekund a¿ policja siê uspokoi!", PlayerInfo[playerid][pCarTime]);
		sendTipMessageEx(playerid, COLOR_GREY, komunikat);
		return 0;
	}

	return 1;
}


static CalculateRewardAfterCarDamages(veh_id, reward_no_damages)
{
	new Float:veh_health = 0.0, Float:multiplier = 0.0;
	GetVehicleHealth(veh_id, veh_health);
	veh_health /= 1000.0;

	if(veh_health >= 0.9)
	{
		return reward_no_damages;
	}

	if(veh_health < 0.25001)
	{
		return floatround(float(reward_no_damages) / 5.0, floatround_ceil);
	}

	new Float:veh_damages = 1 - veh_health;
	multiplier = floatpower(EULER_NUMBER, veh_damages * DAMAGES_PENALTY_CALC_EXP_CONST);
	multiplier = DAMAGES_PENALTY_CALC_CONST - multiplier;
	multiplier = floatsqroot(multiplier);
	multiplier += 0.2;

	new Float:reward_f = float(reward_no_damages) * multiplier;
	return floatround(reward_f, floatround_ceil);
}


static EndCarThiefMission(playerid)
{
	stole_a_car[playerid] = 0;
	stole_a_car_lspd_bonus[playerid] = 0;

	if(IsValidDynamicMapIcon(stole_a_car_checkpoint[playerid][0]))
	{
		DestroyDynamicMapIcon(stole_a_car_checkpoint[playerid][0]);
		stole_a_car_checkpoint[playerid][0] = -1;
	}

	if(IsValidDynamicArea(stole_a_car_checkpoint[playerid][1]))
	{
		DestroyDynamicArea(stole_a_car_checkpoint[playerid][1]);
		stole_a_car_checkpoint[playerid][1] = -1;
	}

	DestroyCarThiefLSPDMapIcon(playerid);
}


static GetBonusRewardFromCarModel(veh_id)
{
	for(new i; i < sizeof(veh_prices); i++)
	{
		if(veh_prices[i][VEH_PRICES_MODEL_ID] == GetVehicleModel(veh_id))
		{
			return veh_prices[i][VEH_PRICES_PRICE] / REWARD_MODEL_DIVISOR;
		}
	}

	return -1;
}


YCMD:ukradnij(playerid, params[], help)
{
    if(!IsPlayerConnected(playerid))
   	{
		return 1;
	}

	new veh_id = GetPlayerVehicleID(playerid);

	if(!UkradnijVerify(playerid, veh_id))
	{
		return 1;
	}

	new lspd_members[MAX_PLAYERS];
	new lspd_members_count = 0, lspd_members_counted = false;
	new deluxe_car = false;

	for(new i = 0; i < sizeof(deluxe_cars_for_stealing_ids); i++)
	{
		if(veh_id == deluxe_cars_for_stealing_ids[i])
		{
			CountLSPDMembersOnDuty(lspd_members, lspd_members_count, lspd_members_counted);
			if(lspd_members_count < 3)
			{
				sendTipMessageEx(playerid, COLOR_GREY,  "¯adna dziupla nie chce obecnie przyj¹æ tego pojazdu! Spróbuj ponownie póŸniej.");
				return 1;
			}

			deluxe_car = true;
			break;
		}
	}

	new lspd_detect_random_roll = true_random(100) + 1;
	if(deluxe_car || lspd_detect_random_roll <= ukradnij_szansa_lspd)
	{
		new Float:thief_pos_x, Float:thief_pos_y, Float:thief_pos_z;
		new komunikat[128];
		new map_icon_color = 0x1111FFFF;

		CountLSPDMembersOnDuty(lspd_members, lspd_members_count, lspd_members_counted);

		if(lspd_members_count > 0)
		{
			if(deluxe_car)
			{
				format(komunikat, sizeof(komunikat), "HQ: Systemy lokalizacji namierzy³y z³odzieja aut, UWAGA - porusza siê %s - pozycja zosta³a zaznaczona na mapie w MDT.", VehicleNames[GetVehicleModel(veh_id)-400]);
				SendFamilyMessage(FRAC_LSPD, COLOR_RED, komunikat, true);
				
				stole_a_car_timers_ids[playerid][1] = SetTimerEx("FinishLSPDCarThiefTracking", LSPD_GPS_DURATION_DELUXE_MS, false, "i", playerid);

				SendClientMessage(playerid, COLOR_LIGHTRED, "NIEZWYKLE gor¹cy towar - dosta³eœ cynk, ¿e swoj¹ kradzie¿¹ wzbudzi³eœ ogromne zainteresowanie policji!");
				format(komunikat, sizeof(komunikat), "Twój kontakt da ci namiary na dziuplê za ok. %d minut. Mo¿esz liczyæ na bardzo du¿¹ premiê!", LSPD_GPS_DURATION_DELUXE_MS / 60000);
				SendClientMessage(playerid, COLOR_LIGHTRED, komunikat);
			
				stole_a_car_seconds_to_find_cp[playerid] = LSPD_GPS_DURATION_DELUXE_MS / 1000;
				stole_a_car_lspd_bonus[playerid] = 3;
				map_icon_color = 0xFF00FFFF;
			}
			else if(lspd_detect_random_roll <= ukradnij_szansa_lspd_kryt)
			{
				format(komunikat, sizeof(komunikat), "HQ: Systemy lokalizacji namierzy³y z³odzieja aut, porusza siê %s - pozycja zosta³a zaznaczona na mapie w MDT.", VehicleNames[GetVehicleModel(veh_id)-400]);
				SendFamilyMessage(FRAC_LSPD, COLOR_LIGHTRED, komunikat, true);
				
				stole_a_car_timers_ids[playerid][1] = SetTimerEx("FinishLSPDCarThiefTracking", LSPD_GPS_DURATION_LONG_MS, false, "i", playerid);

				SendClientMessage(playerid, COLOR_LIGHTRED, "BARDZO gor¹cy towar - dosta³eœ cynk, ¿e swoj¹ kradzie¿¹ wzbudzi³eœ du¿e zainteresowanie policji!");
				format(komunikat, sizeof(komunikat), "Twój kontakt da ci namiary na dziuplê za ok. %d minut. Mo¿esz liczyæ na du¿¹ premiê!", LSPD_GPS_DURATION_LONG_MS / 60000);
				SendClientMessage(playerid, COLOR_LIGHTRED, komunikat);

				stole_a_car_seconds_to_find_cp[playerid] = LSPD_GPS_DURATION_LONG_MS / 1000;
				stole_a_car_lspd_bonus[playerid] = 2;
			}
			else
			{
				format(komunikat, sizeof(komunikat), "HQ: Kamery namierzy³y z³odzieja aut, porusza siê %s - pozycja zosta³a zaznaczona na mapie w MDT.", VehicleNames[GetVehicleModel(veh_id)-400]);
				SendFamilyMessage(FRAC_LSPD, COLOR_LIGHTRED, komunikat, true);

				stole_a_car_timers_ids[playerid][1] = SetTimerEx("FinishLSPDCarThiefTracking", LSPD_GPS_DURATION_SHORT_MS, false, "i", playerid);

				SendClientMessage(playerid, COLOR_LIGHTRED, "Gor¹cy towar - dosta³eœ cynk, ¿e swoj¹ kradzie¿¹ wzbudzi³eœ zainteresowanie policji!");
				format(komunikat, sizeof(komunikat), "Twój kontakt da ci namiary na dziuplê za ok. %d sekund. Mo¿esz liczyæ na premiê!", LSPD_GPS_DURATION_SHORT_MS / 1000);
				SendClientMessage(playerid, COLOR_LIGHTRED, komunikat);
			
				stole_a_car_seconds_to_find_cp[playerid] = LSPD_GPS_DURATION_SHORT_MS / 1000;
				stole_a_car_lspd_bonus[playerid] = 1;
			}

			GetPlayerPos(playerid, thief_pos_x, thief_pos_y, thief_pos_z);
			stole_a_car_lspd_map_icon[playerid] = CreateDynamicMapIconEx(thief_pos_x, thief_pos_y, thief_pos_z, 0, map_icon_color, MAPICON_GLOBAL_CHECKPOINT, 4200.00, 
																		{-1}, {-1}, lspd_members, {STREAMER_TAG_AREA:-1}, 0, 1, 1, lspd_members_count, 1);
			stole_a_car_timers_ids[playerid][0] = SetTimerEx("UpdateCarThiefLSPDMapIcon", LSPD_UPDATE_PERIOD_MS, true, "i", playerid);

			if(PoziomPoszukiwania[playerid] < 2)
			{
				PoziomPoszukiwania[playerid] = 2;
				SetPlayerCriminal(playerid, INVALID_PLAYER_ID, "Kradzie¿ pojazdu mechanicznego.");
			}
		}
	}

	if(stole_a_car_lspd_bonus[playerid] == 0) // W przeciwnym wypadku ma to miejsce dopiero bo wy³¹czeniu policyjnego GPSa - patrz: FinishLSPDCarThiefTracking
	{
		EnableCarThiefCheckpoint(playerid);
	}

	stole_a_car[playerid] = 1;
	SetTimerEx("AntiTeleportCarThief", 30000, false, "d", playerid);
	stole_a_car_anti_tp[playerid] = 1;

	return 1;
}


hook OnPlayerEnterDynamicArea(playerid, areaid)
{
	if(stole_a_car_checkpoint[playerid][1] == areaid)
	{
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || GetPlayerVehicleID(playerid) > CAR_End)
		{
			SendClientMessage(playerid, COLOR_GREY, "Nie jestes w pojeŸdzie nadaj¹cym siê do sprzeda¿y w dziupli!");
			return 1;
		}

		new veh_id = GetPlayerVehicleID(playerid);
		new veh_model_bonus_reward = GetBonusRewardFromCarModel(veh_id);

		if(veh_model_bonus_reward == -1){
			SendClientMessage(playerid, COLOR_GREY, "Nie jestes w pojeŸdzie nadaj¹cym siê do sprzeda¿y w dziupli!");
			return 1;
		}

		if(stole_a_car_anti_tp[playerid])
		{
			SendPunishMessage(sprintf("AdmCmd: %s zostal zkickowany przez Admina: Marcepan_Marks, powód: teleport (z³odziej aut)", GetNickEx(playerid)), playerid);
        	Log(punishmentLog, INFO, "%s dosta³ kicka od antycheata, powód: teleport (z³odziej aut)");
        	KickEx(playerid);
        	return 1;
		}

		PlayerInfo[playerid][pJackSkill] ++;

		if(PlayerInfo[playerid][pJackSkill] == 50)
		{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój skill z³odzieja samochodów wynosi teraz 2, bêdziesz wiêcej zarabiaæ oraz szybciej ukraœæ nowe auto."); }
		else if(PlayerInfo[playerid][pJackSkill] == 100)
		{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój skill z³odzieja samochodów wynosi teraz 3, bêdziesz wiêcej zarabiaæ oraz szybciej ukraœæ nowe auto."); }
		else if(PlayerInfo[playerid][pJackSkill] == 200)
		{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój skill z³odzieja samochodów wynosi teraz 4, bêdziesz wiêcej zarabiaæ oraz szybciej ukraœæ nowe auto."); }
		else if(PlayerInfo[playerid][pJackSkill] == 400)
		{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój skill z³odzieja samochodów wynosi teraz 5, bêdziesz najwiêcej zarabiaæ oraz najszybciej kraœæ auta."); }
		
		new level = PlayerInfo[playerid][pJackSkill], reward = 0, cooldown = 0, premiaTekst[64] = "";
		if(level >= 0 && level <= 50)
		{
			new rand = random(sizeof(SELLCAR1));
			reward = SELLCAR1[rand];
			cooldown = COOLDOWN_1_S;
		}
		else if(level >= 51 && level <= 100)
		{
			new rand = random(sizeof(SELLCAR2));
			reward = SELLCAR2[rand];
			cooldown = COOLDOWN_2_S;
		}
		else if(level >= 101 && level <= 200)
		{
			new rand = random(sizeof(SELLCAR3));
			reward = SELLCAR3[rand];
			cooldown = COOLDOWN_3_S;
		}
		else if(level >= 201 && level <= 400)
		{
			new rand = random(sizeof(SELLCAR4));
			reward = SELLCAR4[rand];
			cooldown = COOLDOWN_4_S;
		}
		else if(level >= 401)
		{
			new rand = random(sizeof(SELLCAR4));
			reward = SELLCAR5[rand];
			cooldown = COOLDOWN_5_S;
		}


		if(stole_a_car_lspd_bonus[playerid] == 3)
		{
			premiaTekst = " (niezwykle gor¹cy towar)";
			reward += DELUXE_CAR_REWARD;
		}
		else
		{
			reward += veh_model_bonus_reward;
		}

		reward = CalculateRewardAfterCarDamages(veh_id, reward);

		if(stole_a_car_lspd_bonus[playerid] == 1)
		{
			format(premiaTekst, sizeof(premiaTekst), " (mno¿nik %i%%%% za gor¹cy towar)", HOT_STUFF_BONUS*100);
			reward *= HOT_STUFF_BONUS;
		}
		else if(stole_a_car_lspd_bonus[playerid] == 2)
		{
			format(premiaTekst, sizeof(premiaTekst), " (mno¿nik %i%%%% za BARDZO gor¹cy towar)", VERY_HOT_STUFF_BONUS*100);
			reward *= VERY_HOT_STUFF_BONUS;			
		}

		new string[128];
		format(string, sizeof(string), "Sprzeda³eœ pojazd za $%d%s. Kolejny pojazd mo¿esz ukraœæ za %i minut.", reward, premiaTekst, cooldown / 60);
		SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

		DajKase(playerid, reward); //moneycheat
		PlayerInfo[playerid][pCarTime] = cooldown;

		RemovePlayerFromVehicleEx(playerid);
		if(stole_a_car_lspd_bonus[playerid] == 3)
		{
			RemoveDeluxeCarForStealing(veh_id);
		}
		else
		{
			RespawnVehicleEx(veh_id);
		}

		EndCarThiefMission(playerid);

		return 1;
	}
}


hook OnPlayerDisconnect(playerid, reason)
{
	EndCarThiefMission(playerid);
}


hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if((stole_a_car[playerid] || stole_a_car_checkpoint[playerid][0] != -1 || stole_a_car_checkpoint[playerid][1] != -1) && oldstate == PLAYER_STATE_DRIVER)
	{
		EndCarThiefMission(playerid);

		PlayerInfo[playerid][pCarTime] = 60;
		sendTipMessageEx(playerid, COLOR_LIGHTRED, "Opuœci³eœ pojazd - próba kradzie¿y zakoñczy³a siê niepowodzeniem.");
	}
}


//---------------------------------------
// TODO: DO WYWALENIA - POMOCNICZE

YCMD:zerujukradnij(playerid, params[], help)
{
	new id;
	if(sscanf(params, "k<fix>", id)) return sendTipMessage(playerid, "U¿yj /zerujukradnij [ID]");
	if(!IsPlayerConnected(id)) return sendErrorMessage(playerid, "Nie ma takiego gracza.");
	PlayerInfo[id][pCarTime] = 0;
	SendClientMessage(playerid, COLOR_GRAD2, "Zdjêto cooldown na /ukradnij.");
	SendClientMessage(id, COLOR_GRAD2, "Admin zdj¹³ ci cooldown na /ukradnij.");
}

YCMD:zmienszanselspd(playerid, params[], help)
{
	new szansa, komunikat[128];
	if(sscanf(params, "d", szansa)) return sendTipMessage(playerid, "U¿yj /zmienszanselspd [szansa]");
	ukradnij_szansa_lspd = szansa;
	format(komunikat, sizeof(komunikat), "Zmieniono szansê na zauwa¿enie /ukradnij przez LSPD na %d%%.", ukradnij_szansa_lspd);
	SendClientMessage(playerid, COLOR_GRAD2, komunikat);
}

YCMD:zmienszanselspdkryt(playerid, params[], help)
{
	new szansa, komunikat[128];
	if(sscanf(params, "d", szansa)) return sendTipMessage(playerid, "U¿yj /zmienszansekrytlspd [szansa]");
	ukradnij_szansa_lspd_kryt = szansa;
	format(komunikat, sizeof(komunikat), "Zmieniono szansê kryt. na zauwa¿enie /ukradnij przez LSPD na %d%%.", ukradnij_szansa_lspd_kryt);
	SendClientMessage(playerid, COLOR_GRAD2, komunikat);
}

YCMD:tesciwo(playerid, params[], help)
{
	DestroyVehicle(13);
	new randcol = random(126);
	new randcol2 = 1;
	new car = 12;
	AddStaticVehicleEx(411, CarSpawns[car][pos_x], CarSpawns[car][pos_y], CarSpawns[car][pos_z], CarSpawns[car][z_angle], randcol, randcol2, -1);
}

//---------------------------------------


#undef DAMAGES_PENALTY_CALC_CONST
#undef DAMAGES_PENALTY_CALC_EXP_CONST
#undef EULER_NUMBER

#undef REWARD_MODEL_DIVISOR
#undef HOT_STUFF_BONUS
#undef VERY_HOT_STUFF_BONUS
#undef LSPD_UPDATE_PERIOD_MS
#undef LSPD_GPS_DURATION_SHORT_MS 
#undef LSPD_GPS_DURATION_LONG_MS 
#undef LSPD_GPS_DURATION_DELUXE_MS 
#undef LSPD_GPS_CHANCE_PERCENT
#undef LSPD_LONG_GPS_CHANCE
#undef DELUXE_CAR_REWARD
#undef COOLDOWN_1_S
#undef COOLDOWN_2_S
#undef COOLDOWN_3_S
#undef COOLDOWN_4_S
#undef COOLDOWN_5_S
