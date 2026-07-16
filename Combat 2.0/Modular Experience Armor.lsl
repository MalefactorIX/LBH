//DATA KEYS
list menu=["Ballistic","Thermal","Tesla","Plate","Flak"];
string cver="LABSv2.0";//Current script version
key qid;//Key used to track data requests
string armorname="Ballistic Armor";
string armortype="ballisticarmor";//Data key used for armor data. Determines resistances and max HP.
/*Valid types:
- Ballistic Armor: Focuses on stopping normal damage and nothing else.
- Blast Armor: Focuses on blocking explosive damage.
- Flame Armor: Focuses on blocking flame damage.
- Tesla Armor: Focuses on blocking lightning damage.
- Plate Armor: Focuses on blocking physical damage
*/
string datatype;//Tells the script what data we're waiting on
//FUNCTIONS
//The actual code
integer mhp=200;//How much damage the armor can take before no longer providing support
integer hp=mhp;
//Less = less damage taken
integer disallowed=1;//Tells the script whether or not damage adjustment is enabled.
updatetext()
{
    if((integer)llGetEnv("allow_damage_adjust")>0)
    {
        disallowed=0;
        vector color=<0.5, 0.75, 1.0>;
        if(hp<1)color=<0.75,0.0,0.0>;
        llSetLinkPrimitiveParamsFast(-4,[PRIM_TEXT,
        "[LABS Armor]\n "+(string)hp+" / "+(string)mhp,
        //+"\nReduction: "+(string)(100-llFloor(100.0*ballres))+"%",
        color,1.0]);
    }
    else
    {
        disallowed=1;
        llSetLinkPrimitiveParamsFast(-4,[PRIM_TEXT,
        "[LABS Armor]\nDisabled by Region",
        <0.75, 0.0, 0.0>,1.0]);
        llOwnerSay("Damage adjustment disabled in region. Armor will not function");
    }
}
list bl;//Prevents avatars listed from doing damage (anti-grief)
integer bad(string uuid)
{
    if(llListFindList(bl,["bad"])>-1)return 1;
    else return 0;
}
integer losenforcer;//If true, normal damage requires line-of-sight to source to be applied. This will prevent guns from dealing damage through walls, terrain, or cover, but will cause issues with specific weapon types that are not updated to use a different damage type (explosives, lingering effects)
integer los(vector init, key source)
{
    vector pos=(vector)((string)llGetObjectDetails(source,[OBJECT_POS]));
    vector size=llGetAgentSize(source);
    if(size==ZERO_VECTOR)return 1;//Returns if the avatar being sourced is not in region, assume the source object is environmental. NOTE: Enviromental effects should not use damage type 0 or this feature should be disabled in region settings to prevent it from blocking such environmental effects. You can also deed the object to the land group.
    size=<0.0,0.0,size.z*0.5>;//Used to offset additional raycast checks.
    list ray=llCastRay(init,pos,[RC_REJECT_TYPES,RC_REJECT_AGENTS]);//root check
    if(llList2Integer(ray,-1)<1)return 1;
    ray=llCastRay(init+size,pos+size,[RC_REJECT_TYPES,RC_REJECT_AGENTS]);//head check
    if(llList2Integer(ray,-1)<1)return 1;
    ray=llCastRay(init-size,pos-size,[RC_REJECT_TYPES,RC_REJECT_AGENTS]);//feet check
    if(llList2Integer(ray,-1)<1)return 1;
    ray=llCastRay(init-size,pos+size,[RC_REJECT_TYPES,RC_REJECT_AGENTS]);//69 check
    if(llList2Integer(ray,-1)<1)return 1;
    return 0;//If all checks fail, the hit is considered invalid
}
//RESISTANCE VALUES
float ballres=1;//Value 0 to 1 that indicates how much NORMAL (0) damage should be reduced by
float thermalres=1;//Value 0 to 1 that indicates how much FIRE and COLD (5,3) damage should be reduced by
float lightres=1;//Value 0 to 1 that indicates how much LIGHTNING (4) damage should be reduced by
float physres=1;//Value 0 to 1 that indicates how much BLUNGEON, PIERCING, and SLASHING (2,8,12) damage should be reduced by
float blastres=1;//Value 0 to 1 that indicates how much FORCE and EXPLOSIVE (6,102) damage should be reduced by
//It should be noted that the lower the number, the higher the resistance. if the number is negative. Negative numbers will cause attacks to heal the user instead.
default
{
    state_entry()
    {
        //llDamage(llGetOwner(),-1000.0,0);
        datatype="ver";
        qid=llReadKeyValue("LABSVersion");
        //LABS=Linden Armored Body System
    }
    attach(key id)
    {
        if(id)llResetScript();
    }
    changed(integer c)
    {
        if(c&CHANGED_REGION)llResetScript();
    }
    on_damage(integer d)//https://youtu.be/Rqw4z1nJ5W4?si=L4Lfc8SRSRyv_N3x
    {
        //llSay(0,"damage");
        //if(hp<1)return;//Do not do stuff if the armor is broken
        //Above is disabled due to impact protection
        while(d--)//Note: This runs the list backwards
        {
            list damage=llDetectedDamage(d);
            integer type=llList2Integer(damage, 1);
            integer amt=llList2Integer(damage,0);//Yes, I'm aware this truncates. I don't care.
            if(amt>1000)amt=100;//Anti-grief
            if(amt<-1000)amt=0;
            //curamt,type,orgamt
            if(bad(llDetectedOwner(d)))llAdjustDamage(d,0);//Blacklist negation
            else if(type==DAMAGE_TYPE_IMPACT)//Impact damage is stupid and dumb and stupid
                llAdjustDamage(d,0);
            if(type==0&&losenforcer)
            {
                if(los(llGetPos(),llDetectedOwner(d))<1)llAdjustDamage(d,0);
                //Enforce Line-of-sight to stop killing people through objects. Only affects normal damage (which is what people should be using)
            }
            //else if(type)return;//If type is not 0, don't change stuff
            else if(hp>0&&amt>0)//Handles damage
            {
                integer newamt;
                if(type==0&&ballres!=1.0)//normal damage resistance
                {
                    newamt=llFloor(amt*ballres);
                    llAdjustDamage(d,newamt);
                }
                else if(type==4&&lightres!=0.0)
                {
                    newamt=llFloor(amt*lightres);
                    llAdjustDamage(d,newamt);
                }
                else if(type==5||type==3)//thermal damage resistance
                {
                    if(thermalres!=1.0)
                    {
                        newamt=llFloor(amt*thermalres);
                        llAdjustDamage(d,newamt);
                    }
                }
                else if(type==6||type==102)//blast damage resistance
                {
                    if(blastres!=1.0)
                    {
                        if(blastres!=1.0)
                        {
                            newamt=llFloor(amt*blastres);
                            llAdjustDamage(d,newamt);
                        }
                    }
                }
                else if(type==2||type==8||type==12)
                {
                    //bludgeoning, piercing, and slashing respectively
                    if(physres!=1.0)
                    {
                        newamt=llFloor(amt*physres);
                        llAdjustDamage(d,newamt);
                    }
                }
                if(newamt)hp-=amt-newamt;//If we adjusted anything, subtract it from our armor's HP.
            }
            else if(amt<0&&type==101)//Armor repair llDamage(user,negative_number,101);
            {
                    hp-=amt;
                    if(hp>mhp)hp=mhp;
            }
            //else the damage is negative and will heal the user
        }
        if(hp<0)hp=0;//Prevents HP from reporting negative values
    }
    final_damage(integer d)
    {
        //llSay(0,"final");
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
            if(datatype=="ver")
            {
                if(llSubStringIndex(data,cver)>-1)
                {
                    llOwnerSay("[NOTICE]\nVersion is up to date!");
                    //hp=mhp;
                    //updatetext();
                    llListen(9100,"",llGetOwner(),"");
                    datatype="armortype";
                    qid=llReadKeyValue(armortype);
                }
                else
                {
                    llOwnerSay("[ERROR]\nItem is not up to date or is no longer supported. Please grab the latest copy where available");
                    state off;
                }
            }
            else if(datatype=="armortype")
            {
                list params=llCSV2List(llGetSubString(data,2,-1));
                //csv format: name,maxhp,ballres,thermalres,lightres,physres,blastres,
                armorname=llList2String(params,0);
                mhp=(integer)llList2String(params,1);
                ballres=(float)llList2String(params,2);
                thermalres=(float)llList2String(params,3);
                lightres=(float)llList2String(params,4);
                physres=(float)llList2String(params,5);
                blastres=(float)llList2String(params,6);
                llSetObjectDesc(data);//Stores data in description for visual verification.
                hp=mhp;
                llOwnerSay("[SUCCESS]\n"+armorname+" configuration obtained successfully. Damage modifiers displayed below:"
                +"\nBallistic: "+(string)(100-llFloor(100.0*ballres))+"%"
                +"\nThermal: "+(string)(100-llFloor(100.0*thermalres))+"%"
                +"\nLightning: "+(string)(100-llFloor(100.0*lightres))+"%"
                +"\nPhysical: "+(string)(100-llFloor(100.0*physres))+"%"
                +"\nBlast: "+(string)(100-llFloor(100.0*blastres))+"%");
                updatetext();
                llDamage(llGetOwner(),1000,-9999);//Kills person so they can't hotswap armors on the battlefield
                datatype="regionconfig";
                qid=llReadKeyValue(llGetRegionName()+"_LABSCONFIG");
            }
            else if(datatype=="regionconfig")
            {
                bl=llCSV2List(llGetSubString(data,2,-1));
                //csv format: losenforcer,blacklist,blacklist,blacklist...
                losenforcer=(integer)llList2String(bl,0);

            }
        }
        else if(datatype=="ver")
        {
            llOwnerSay("[ERROR "+llGetSubString(data,2,-1)+"]\nStartup Failed due to an experience error during version checking. Armor is disabled");
            state off;
        }
        else if(datatype=="regionconfig")
        {
            losenforcer=0;
            bl=[];
            llOwnerSay("[WARNING "+llGetSubString(data,2,-1)+"]\nThere was an error grabbing region armor configuration. It likely does not exist. Global configuration has been applied.");
            //Global config disables LOS Enforcer and blacklist
        }
        else
        {
            llOwnerSay("[ERROR "+llGetSubString(data,2,-1)+"]\nThere was an error when attempting to grab armor configuarion. There may be a system mismatch. Armor will be disabled.");
            state off;
        }
    }
    listen(integer chan, string name, key id, string message)
    {
        message=llToLower(message);
        if(message=="menu")llDialog(id,"Choose an armor type",menu,9100);
        else
        {
            armortype=message+"armor";
            datatype="armortype";
            qid=llReadKeyValue(armortype);
            llOwnerSay("Attempting to load data for "+llToUpper(message)+" armor");
        }
    }
}
state off
{
    on_rez(integer p)
    {
        llResetScript();
    }
    changed(integer c)
    {
        if(c&CHANGED_REGION)llResetScript();
    }
}
