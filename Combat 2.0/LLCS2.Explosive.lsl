vector vel;
vector color=<1.0,0.5,0.0>;
boom(vector pos, integer timed)
{
    llSetLinkPrimitiveParamsFast(-1,[PRIM_PHYSICS,0,PRIM_PHANTOM,1,PRIM_COLOR,-1,ZERO_VECTOR,0.0,PRIM_GLOW,-1,0.0]);
    if(timed)
    {
        vel=pos;
        return;
    }
    vector off=vel*=0.075;
    list ray=llCastRay(pos-off,pos+off,[]);//Backstracks impact area to keep the grenade from clipping through walls
    vector raypos=llList2Vector(ray,1);
    if(raypos)llSetRegionPos(vel=raypos);
    else vel=pos;
    llSensor("","",AGENT,5.0,PI);
    llParticleSystem([
        PSYS_PART_FLAGS,            PSYS_PART_EMISSIVE_MASK|PSYS_PART_FOLLOW_VELOCITY_MASK|PSYS_PART_INTERP_COLOR_MASK|PSYS_PART_INTERP_SCALE_MASK,
        PSYS_SRC_PATTERN,           PSYS_SRC_PATTERN_EXPLODE,
        PSYS_PART_START_COLOR,    color,
        PSYS_PART_END_COLOR,      color,
        PSYS_PART_START_ALPHA,      0.5,
        PSYS_PART_END_ALPHA,        0.0,
        PSYS_PART_START_GLOW,        0.1,
        PSYS_PART_START_SCALE,      <9.0,9.0,0.0>,
        PSYS_PART_END_SCALE,        <9.0,9.0,0.0>,
        PSYS_PART_MAX_AGE,          0.5,
        PSYS_SRC_ACCEL,             <0.0,0.0,1.0>,
        PSYS_SRC_TEXTURE,           "8738201d-ec3d-288a-7d65-031211f9fee7",
        PSYS_SRC_BURST_RATE,        .05,
        PSYS_SRC_ANGLE_BEGIN,       0.0,
        PSYS_SRC_ANGLE_END,        PI,
        PSYS_SRC_BURST_PART_COUNT,  10,
        PSYS_SRC_BURST_RADIUS,      2.0,
        PSYS_SRC_BURST_SPEED_MIN,   1.0,
        PSYS_SRC_BURST_SPEED_MAX,   5.0,
        PSYS_SRC_MAX_AGE, 0.0]);
        llTriggerSound("01729e19-162b-699d-d45a-357a9d5e3656",1.0);
}
integer dmg=15;
purge(integer hex,key targ, string name)
{
    //llOwnerSay("/me landed a direct hit to "+name);
    if(hex)llRegionSayTo(targ,hex,(string)targ+","+(string)dmg);
    else llRegionSayTo(targ,-500,(string)targ+",damage,"+(string)dmg);
}
default
{
    on_rez(integer p)
    {
        vel=llGetVel();//Ideally you can use a timer event to keep this updated but that's on you.
    }
    collision_start(integer c)
    {
        boom(llGetPos(),0);
        key hit=llDetectedKey(0);
        string desc=llList2String(llGetObjectDetails(hit,[OBJECT_DESC]),0);
        if(desc!=""&&(llGetSubString(desc,0,1)=="v."||llGetSubString(desc,0,5)=="LBA.v."))
        {
            integer hex=(integer)("0x" + llGetSubString(llMD5String((string)hit,0), 0, 3));
            if(llGetSubString(desc,0,5)!="LBA.v.")hex=0;
            purge(hex,hit,llDetectedName(0));
        }
        //llMessageLinked(-4,1,"",hit);//Used for proximity LBA in a second script. We pass the UUID of the object struck directly to avoid applying damage twice
    }
    land_collision_start(vector c)
    {
        boom(c,0);
    }
    sensor(integer d)
    {
        while(d--)
        {
            key hit=llDetectedKey(d);
            list ray=llCastRay(llDetectedPos(d),vel,[RC_REJECT_TYPES,RC_REJECT_AGENTS]);
            if(llList2Vector(ray,1)==ZERO_VECTOR)llDamage(hit,100.0,6);
        }
        llSleep(1.0);//Delay death for LBA processing
        llDie();
    }
    no_sensor()
    {
        llSleep(1.0);//Delay death for LBA processing
        llDie();
    }
}
