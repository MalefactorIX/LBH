//Proof of concept because reeeeeeeEEEEEEEEEEEEあああああああああああああああああ sensor shotguns

//This is made to be easy to read and configure. As such, there are way more variables than optimal. This will mostly impact script memory. However, if used as a node, this issue shouldn't impact weapon performance.

//This script lacks edge detection for limited range, but the unlimited range option does not have this limitation. When using the unlimited range option, spread will continue to extend beyond the max value at the same rate set in the calculations. When not using edge detection, raycast tends to return nulls but since we're firing multiple rays per shot, this will have minimal impact on reliability.

integer unlimit=1;//Toggles whether or not you want all pellets to fly to the region edge.
float range=100.0;//How far the shotgun can shoot before not being able to hit anything in limited mode, affects spread of both modes.
vector shot()//Returns a vector for represents the deviation for a shot.
{
    float base=5.0;//Determines the magnitude of spread based off range. Higher = more
    /*Spread works based on range. As its set by default, it's 5m at 100m meter. Increasing the range will narrow the spread, reducing the range will increase it. To visualize, tape a cone and increase its length
    You can also change the base value itself, so if you want it to be 10m wide at 100 meters, you change the base value to 10
    Note that the spread is a diameter from the center of the shot. So 10m wide spread would be a 5m radius around the center.*/
    float half=base*0.5;//Used in calculations, do not touch.
    vector vec=llVecNorm(<range,llFrand(base)-half,llFrand(base)-half>);//RNGs all the things
    return vec;
}
vector GetRegionEdge(vector start, vector dir)
{
    float scaleGuess;
    float scaleFactor = 4095.99;
    if (dir.x)
    {
        scaleFactor = ((dir.x > 0) * 255.99 -start.x) / dir.x;
    }
    if (dir.y)
    {
        scaleGuess = ((dir.y > 0) * 255.99 - start.y) / dir.y;
        if (scaleGuess < scaleFactor) scaleFactor = scaleGuess;
    }
    if (dir.z)
    {
        scaleGuess = ((dir.z > 0) * 4095.99 - start.z) / dir.z;
        if (scaleGuess < scaleFactor) scaleFactor = scaleGuess;
    }
    return start + dir * scaleFactor;
}
lba(key targ,integer hex,string dmg)//Message relay for LBA damage
{
    if(hex)llRegionSayTo(targ,hex,(string)targ+","+dmg);
    else llRegionSayTo(targ,-500,(string)targ+",damage,"+dmg);
}
fire()//THE PART THAT DOES SHIT
{
    vector cpos=llGetCameraPos();
    rotation rot=llGetCameraRot();
    integer pellets=8;//How many pellets per shot
    float base_damage=45.0;//How much damage per pellet
    float min_damage=15.0;//Min damage per pellet
    integer lba_damage=1;//LBA damage per pellet
    float falloff=0.5;//How many damage per meter to decay damage
    float forange=20.0;//At what range does damage decay start
    integer type;//The flag used for LLDamage for type (leave 0 or unset unless using special ammo, ie. flechette)
    list data;//Stores data for valid hits for bulk processing
    list lbadata;
    list posdata;//Data used for tracers
    while(pellets--)
    {
        list ray;
        vector epos;
        if(unlimit)
        {
            epos=GetRegionEdge(cpos,shot()*rot);
            ray=llCastRay(cpos,epos,[RC_REJECT_TYPES,RC_REJECT_PHYSICAL,RC_DATA_FLAGS,RC_GET_ROOT_KEY,RC_MAX_HITS,2]);
        }
        else
        {
            epos=cpos+((shot()*rot)*range);
            ray=llCastRay(cpos,epos,[RC_REJECT_TYPES,RC_REJECT_PHYSICAL,RC_DATA_FLAGS,RC_GET_ROOT_KEY,RC_MAX_HITS,2]);//Does not feature edge detection.
        }
        if(llList2Integer(ray,-1)>0)//Checks to see if we hit something
        {
            key hit=llList2Key(ray,0);//Pulls the UUID of what we hit
            vector tar=llList2Vector(ray,1);
            if(hit==o)//Prevents us from shooting ourselves
            {
                hit=llList2Key(ray,2);
                tar=llList2Vector(ray,3);
                if(tar)posdata+=tar;//Adds valid hits to a list
                else posdata+=epos;//Else adds where ray stopped

            }
            else
            {
                if(tar)posdata+=tar;//Adds valid hits to a list
                else posdata+=epos;//Else adds where ray stopped
            }
            if(llGetAgentSize(hit))//Checks to see if what we hit was an avatar, if anything
            {
                //DAMAGE CALULATIONS
                float damage=base_damage;
                float dist=llVecDist(cpos,tar);
                if(dist>forange)//Are we suffering from falloff?
                {
                    damage-=falloff*(dist-forange);
                    if(damage<min_damage)damage=min_damage;//Minimum cap
                }
                //HIT LOG
                integer l=llListFindList(data,[hit]);//Checks to see if they were hit by another pellet
                if(l<0)data+=[hit,damage];//No previous data, so add it here
                else
                {
                    ++l;
                    data=llListReplaceList(data,[llList2Float(data,l)+damage],l,l);//Adds damage to existing entry
                }
            }
            else //LBA suppoer
            {
                integer l=llListFindList(lbadata,[hit]);
                if(l<0)//No previously recorded LBA data for this hit
                {
                    string desc=llList2String(llGetObjectDetails(hit,[OBJECT_DESC]),0);
                    if(desc!=""&&(llGetSubString(desc,0,1)=="v."||llGetSubString(desc,0,5)=="LBA.v."))
                    {
                        integer hex=(integer)("0x" + llGetSubString(llMD5String((string)hit,0), 0, 3));
                        if(llGetSubString(desc,0,5)!="LBA.v.")hex=0;
                        lbadata+=[hit,hex,lba_damage];
                    }
                }
                else //Updates existing damage
                {
                    l+=2;
                    lbadata=llListReplaceList(lbadata,[llList2Integer(lbadata,l)+lba_damage],l,l);
                }
            }
        }
        else posdata+=epos;//If no hits, adds the end of ray to the position list
    }
    integer l=llGetListLength(data);
    integer i;
    while(i<l)//Goes through list and deals all damage in 1 instance per target
    {
        key hit=llList2Key(data,i);
        float damage=llList2Float(data,i+1);
        if(llGetParcelFlags(llGetPos())&PARCEL_FLAG_ALLOW_DAMAGE)//Checks to see if we're somewhere with damage enabled before attempting to deal damage
            llDamage(hit,damage,type);
        //llOwnerSay("Hit "+llKey2Name(hit)+" for "+(string)llFloor(damage));//Not recommended but offers a simple hit report for debugging. Best to use a dedicated hud with combat log support to track damage.
        i+=2;
    }
    l=llGetListLength(lbadata);
    //if(l)llSay(0,llDumpList2String(lbadata,","));
    //else llSay(0,"Null list");
    i=0;
    while(i<l)
    {
        lba(llList2Key(lbadata,i),llList2Integer(lbadata,i+1),(string)llList2Integer(lbadata,i+2));
        i+=3;
    }
    list rezparams=[REZ_POS,cpos,0,1,
        REZ_ROT,ZERO_ROTATION,0,
        REZ_PARAM,1,
        REZ_PARAM_STRING,llDumpList2String(posdata,";")];
    /*if(llGetListLength(posdata))*/llRezObjectWithParams("[UwU]Scatter.RCS",rezparams);
    //else llSay(0,"No position data");
}
key o;//Owner key
default
{
    state_entry()
    {
        o=llGetOwner();
        llRequestPermissions(o,0x400);
    }

    attach(key id)
    {
        if(id)
        {
            o=id;
            llRequestPermissions(o,0x400);
        }
    }
    link_message(integer s, integer n, string m, key id)
    {
        //llMessageLinked(-4,1,"","");//Fires node
        if(n)fire();
    }
}
