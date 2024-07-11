//Prevents those not linked up with the experience from damaging your stuff
integer mhp=50;//Maximum HP
integer hp=mhp;//Current HP
//Positive Numbers Deal Damage
//Negative Numbers Restore Health
integer atcap=25;
//Damage Processor
integer textprim=1;
vector color=<0.2,1.0,0.2>;
key qid;
integer amt;
damage(key tid)
{
    hp-=amt;
    integer dchan=-(integer)("0x" + llGetSubString(llMD5String(tid,0), 4, 7));
    llRegionSayTo(tid,dchan,"lba,LBA hit for "+(string)amt+" HP");
    if(hp<1)die();
    else update();
}

update()//SetText
{
    llSetLinkPrimitiveParamsFast(1,[PRIM_DESC,"LBA.v.LBHE,"+(string)hp+","+(string)mhp+","+(string)atcap+",NPC",
        PRIM_LINK_TARGET,textprim,PRIM_TEXT,"[LBHE]\n "+(string)hp+" / "+(string)mhp+" HP",color,1.0]);
        //In order: Current HP, Max HP, Max AT accepted, Max healing accepted (Not implemented)
}
vector init;
die()
{
    //Add extra shit here
    llSetLinkPrimitiveParamsFast(1,[PRIM_DESC,"DEAD,NPC",PRIM_PHANTOM,1,
        PRIM_LINK_TARGET,textprim,PRIM_TEXT,"[DEAD]",<1.0,0.0,0.0>,1.0
        ]);
    llLinkParticleSystem(-1,[]);
    llSleep(5.0);
    //llSetRegionPos(init);
    //llResetScript();//Debug
    llDie();//Otherwise, use this
}
vector tar(key id)
{
    vector av=(vector)((string)llGetObjectDetails(id,[OBJECT_POS]));
    return av;
}
key user;
key gen;//Object rezzer
key me;
integer hear;
boot()
{
    user=llGetOwner();
    me=llGetKey();
    gen=(string)llGetObjectDetails(me,[OBJECT_REZZER_KEY]);
    if(hear)llListenRemove(hear);
    integer hex=(integer)("0x" + llGetSubString(llMD5String((string)me,0), 0, 3));
    hear=llListen(hex,"","","");
    //llSetTimerEvent(5.0);//Used for auto-delete.
    update();
}
default
{
    state_entry()
    {
        llSetStatus(STATUS_PHANTOM,0);
        init=llGetPos();
        boot();
    }
    on_rez(integer p)
    {
        /*if(p>1)//Allows HUD/Objects to set HP value when rezzed with a param, otherwise uses default
        {
            mhp=p;
            if(mhp>100)mhp=100;
            hp=mhp;
        }*/
        boot();
        if(p)
        {
            init=llGetPos();
            llListen(-910,"",gen,"die");
        }
    }
    listen(integer chan, string name, key id, string message)
    {
        //[ALWAYS] USE llRegionSayTo(). Do not flood the channel with useless garbage that'll poll every object in listening range.
        if(qid)return;
        list parse=llParseString2List(message,[","],[" "]);
        if(llList2Key(parse,0)==me)//targetcheck
        {
            amt=llList2Integer(parse,-1);
            if(amt<1)return;//No healing allowed
            else if(amt>atcap)amt=atcap;
            vector pos=llGetPos();
            if(llAbs(amt)<666)qid=llReadKeyValue((string)llGetOwnerKey(id)+"_DATA");
        }
        else if(id==gen)llDie();
    }
    dataserver(key id, string data)
    {
        if(qid!=id)return;
        else if((integer)llGetSubString(data,0,0))
        {
            data=llGetSubString(data,2,-1);
            list parse=llCSV2List(data);
            string tid=llList2String(parse,0);  //Parameter is the UUID of the object that syncs players
            if((integer)llList2String(parse,3)>0  //This parameters is the current HP of the target
                &&tar(tid)!=ZERO_VECTOR) //Checks to make sure object is on
                    damage(tid);
            //else llSay(0,"Hit recieved. Ignored due to missing health or sync object.");
        }
        //else llSay(0,"Hit recieved. Ignored due to experience error: "+llGetExperienceErrorMessage((integer)llGetSubString(data,2,-1)));
        qid="";
    }
    /*collision_start(integer c)//Enable this block if you want to support legacy collisions.
    {
        if(llVecMag(llDetectedVel(0))>40.0)
        {
            hp-=c;
            if(hp<1)die();//llDie();
            else update();
        }
    }*/
    /*timer()//Auto-deleter. Will kill object if avatar leaves the region or spawning object is removed.
    {
        if(tar(gen))return;
        llDie();
    }*/
}
