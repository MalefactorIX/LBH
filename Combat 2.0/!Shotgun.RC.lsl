//Proof of concept because reeeeeeeEEEEEEEEEEEEあああああああああああああああああ sensor shotguns 

//This is made to be easy to read and configure. As such, there are way more variables than optimal. This will mostly impact script memory. However, if used as a node, this issue shouldn't impact weapon performance.

//This script offers no tracer feedback as is, create your own or improvise \o/

//This script lacks edge detection for limited range, but the unlimited range option does not have this limitation. When using the unlimited range option, spread will continue to extend beyond the max value at the same rate set in the calculations. When not using edge detection, raycast tends to return nulls but since we're firing multiple rays per shot, this will have minimal impact on reliability.

integer unlimit;//Toggles whether or not you want all pellets to fly to the region edge.
float range=100.0;//How far the shotgun can shoot before not being able to hit anything.
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
vector tar(key id)
{
   return (vector)((string)llGetObjectDetails(id,[OBJECT_POS]));
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
fire()//THE PART THAT DOES SHIT
{
    vector cpos=llGetCameraPos();
    rotation rot=llGetCameraRot();
    integer pellets=8;//How many pellets per shot
    float base_damage=45.0;//How much damage per pellet
    float min_damage=15.0;//Min damage per pellet
    float falloff=0.5;//How many damage per meter to decay damage
    float forange=20.0;//At what range does damage decay start
    integer type;//The flag used for LLDamage for type (leave 0 or unset unless using special ammo, ie. flechette)
    list data;//Stores data for valid hits for bulk processing
    while(pellets--)
    {
        list ray;
        if(unlimit)ray=llCastRay(cpos,GetRegionEdge(cpos,shot()*rot),[RC_REJECT_TYPES,RC_REJECT_PHYSICAL,RC_DATA_FLAGS,RC_GET_ROOT_KEY,RC_MAX_HITS,2]);
        else ray=llCastRay(cpos,cpos+((shot()*rot)*range),[RC_REJECT_TYPES,RC_REJECT_PHYSICAL,RC_DATA_FLAGS,RC_GET_ROOT_KEY,RC_MAX_HITS,2]);//Does not feature edge detection.
        if(llList2Integer(ray,-1)>0)//Checks to see if we hit something
        {
            key hit=llList2Key(ray,0);//Pulls the UUID of what we hit
            if(hit==o)hit=llList2Key(ray,2);//Prevents us from shooting ourselves
            if(llGetAgentSize(hit))//Checks to see if what we hit was an avatar, if anything
            {
                //DAMAGE CALULATIONS
                float damage=base_damage;
                float dist=llVecDist(cpos,tar(hit));
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
            //You can technically add LBA support here as an 'else if'
        }
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
