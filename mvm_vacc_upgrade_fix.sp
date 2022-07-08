#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2>
#include <tf2attributes>

public Plugin:myinfo = 
{
    name = "[MVM] Vaccinator Upgrade Fix",
    author = "Rowedahelicon",
    description = "A fix for the vaccinator not scaling uber time with the uber duration upgrade.",
    version = "1.0",
    url = "https://www.rowedahelicon.com"
}

public OnPluginStart()
{
    HookEvent("player_chargedeployed", playerUbered);
}

public Action playerUbered(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid")); // Get Healer's userid
    new client_healed = GetClientOfUserId(GetEventInt(event, "targetid")); // Get Healed's userid

    if(GetClientTeam(client) == 3){ return Plugin_Handled; }

    new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
    if (GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == 998)
    {
        Address pAttrib = TF2Attrib_GetByDefIndex(weapon, 314);
        if (!IsValidAddress(view_as<Address>(pAttrib)))
        {
            return Plugin_Handled;
        }

        new Float:amount;

        switch (TF2Attrib_GetRefundableCurrency(pAttrib))
        {
            case 250:
            {
                amount = 4.5;
            }
            case 500:
            {
                amount = 5.5;
            }
            case 750:
            {
                amount = 6.5;
            }
        }  

        if(!IsValidClient(client)){ return Plugin_Handled; }
        if(!IsValidClient(client_healed)){ return Plugin_Handled; }

        switch (GetEntProp(weapon, Prop_Send, "m_nChargeResistType"))
        {
            case 0:
            {
                TF2_AddCondition(client, TFCond:TFCond_UberBulletResist, amount);
                TF2_AddCondition(client_healed, TFCond:TFCond_UberBulletResist, amount);
            }
            case 1:
            {
                TF2_AddCondition(client, TFCond:TFCond_UberBlastResist, amount);
                TF2_AddCondition(client_healed, TFCond:TFCond_UberBlastResist, amount);
            }
            case 2:
            {
                TF2_AddCondition(client, TFCond:TFCond_UberFireResist, amount);
                TF2_AddCondition(client_healed, TFCond:TFCond_UberFireResist, amount);
            }
        }  
    }  

    return Plugin_Continue;

}

stock bool IsValidAddress(Address pAddress)
{
	static Address Address_MinimumValid = view_as<Address>(0x10000);
	if (pAddress == Address_Null)
		return false;
	return unsigned_compare(view_as<int>(pAddress), view_as<int>(Address_MinimumValid)) >= 0;
}

stock int unsigned_compare(int a, int b) {
	if (a == b)
		return 0;
	if ((a >>> 31) == (b >>> 31))
		return ((a & 0x7FFFFFFF) > (b & 0x7FFFFFFF)) ? 1 : -1;
	return ((a >>> 31) > (b >>> 31)) ? 1 : -1;
}

stock bool IsValidClient( client ) 
{
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
        return false; 
     
    return true; 
}
