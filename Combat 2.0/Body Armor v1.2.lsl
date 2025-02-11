string cver="LABSv1.0";//Current script version
//LABS=Light Armor Body System
string keyvalue;//Name of experience key that stores data
string regionname;//Used for region-specific keys
key qid;//Current dataserver query
//The actual code
integer mhp=200;//How much damage the armor can take before no longer providing support
integer hp=mhp;
float reduct=0.25;//Value 0 to 1 that indicates how much damage should be reduced by
//Less = less damage taken
updatetext()
{
    if((integer)llGetEnv("allow_damage_adjust")>0)llSetLinkPrimitiveParamsFast(-4,[PRIM_TEXT,
        "[Heavy CS2 Armor]\n "+(string)hp+" / "+(string)mhp+
        "\nReduction: "+(string)(100-llFloor(100.0*reduct))+"%",
        <1.0,1.0,1.0>,0.0]);
    else llOwnerSay("Damage adjustment disabled in region");
}
list bl;//Prevents owner UUIDs from dealing damage while this item is worn.
list wl=[104,8];//What damage types to allow through without adjustment
integer bad(string uuid)
{
    if(llListFindList(bl,[uuid])>-1)return 1;
    else return 0;
}

default
{
    state_entry()
    {
        regionname=llGetRegionName();
        keyvalue="STRATUMWEAPONAUTH";
        llDamage(llGetOwner(),-1000.0,0);
        qid=llReadKeyValue(keyvalue);
    }
    changed(integer c)
    {
        if(c&CHANGED_TELEPORT||c&CHANGED_REGION)//Updates the blacklist whenever respawning or changing regions 
        {
            regionname=llGetRegionName();
            keyvalue=regionname+"_LLCS_Blacklist";//Pulls blacklist for current region
            qid=llReadKeyValue(keyvalue);
        }
    }
    attach(key id)
    {
        if(id)llResetScript();
    }
    on_damage(integer d)//https://youtu.be/Rqw4z1nJ5W4?si=L4Lfc8SRSRyv_N3x
    {
        //if(hp<1)return;//Do not do stuff if the armor is broken
        while(d--&&hp>0)//Note: This runs the list backwards
        {
            list damage=llDetectedDamage(d);
            integer type=llList2Integer(damage, 1);
            //curamt,type,orgamt
            if(type==DAMAGE_TYPE_IMPACT||bad(llDetectedOwner(d)))
                llAdjustDamage(d,0);
            //else if(type)return;//If type is not 0, don't change stuff
            else if(llListFindList(wl,[type])<0)//Checks to see if the damage type is not to be modified
            {
                integer amt=llList2Integer(damage,0);
                integer newamt=llFloor(amt*reduct);
                if(amt>0&&hp>0)//Damage
                {
                    llAdjustDamage(d,newamt);
                    if(type==0||type==4)hp-=amt-newamt;
                }
                else if(amt<0) //Healing
                {
                    hp-=amt;
                    if(hp>mhp)hp=mhp;
                }
            }
        }
        if(hp<0)hp=0;//Prevents HP from reporting negative values
    }
    final_damage(integer d)
    {
        updatetext();//Once all damage is processed, update text
    }
    on_death()
    {
        //llOwnerSay("Dead");
        hp=mhp;
        updatetext();
    }
    dataserver(key id, string data)
    {
        if(id!=qid)return;
        else if((integer)llGetSubString(data,0,0))
        {
            data=llGetSubString(data,2,-1);//Removes success index
            if(keyvalue=="STRATUMWEAPONAUTH")//Are we checking the version?
            {
                if(llSubStringIndex(data,cver)>-1)
                {
                    llOwnerSay("Version is up to date!");
                    hp=mhp;
                    updatetext();
                    keyvalue=regionname+"_LLCS_Blacklist";//Pulls blacklist for current region
                    qid=llReadKeyValue(keyvalue);
                }
                else
                {
                    llOwnerSay("[ERROR] Item is not up to date or is no longer supported. Please grab the latest copy where available");
                    state off;
                }
            }
            else if(keyvalue==regionname+"_LLCS_Blacklist")//Are we checking the blacklist?
            {
                bl=llCSV2List(data);//Updates blacklist with stored data
            }
        }
        else
        {
            if(keyvalue==regionname+"_LLCS_Blacklist")bl=[];//Clears blacklist if there isn't one
            else
            {
                llOwnerSay("System Failed due to an experience error ["+llGetSubString(data,2,-1)+"]\nData Type: "+keyvalue);
                state off;
            }
        }
    }
}
state off
{
    on_rez(integer p)
    {
        llResetScript();
    }
}
