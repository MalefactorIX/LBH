float h=1.05;//Height from root to ground
integer los(vector start, vector end, integer invert, integer iff)
{
    list ray;
    if(invert)ray=llCastRay(end,start,[RC_REJECT_TYPES,RC_REJECT_AGENTS|RC_REJECT_PHYSICAL,RC_DATA_FLAGS,RC_GET_ROOT_KEY]);
    else ray=llCastRay(start,end,[RC_REJECT_TYPES,RC_REJECT_AGENTS|RC_REJECT_PHYSICAL,RC_DATA_FLAGS,RC_GET_ROOT_KEY]);

    if(llList2Integer(ray,-1)<1)return 1;//Nothing blocked the ray
    else if(iff)
    {
        if(llList2Key(ray,0)==me)return 1;//Hit self
        else
        {
            //llOwnerSay("Hit "+llKey2Name(llList2Key(ray,0)));
            return 0;
        }
    }
    else return 0;
}
vector losvec(vector start,vector end)
{
    //llOwnerSay((string)start));
    list ray=llCastRay(start,end,[RC_REJECT_TYPES,RC_REJECT_AGENTS|RC_REJECT_PHYSICAL,RC_DATA_FLAGS,RC_GET_ROOT_KEY]);
    vector pos =llList2Vector(ray,1);
    /*if(pos)llRegionSayTo(llGetOwner(),0,"I've picked this position: "+(string)pos);
    else llRegionSayTo(llGetOwner(),0,"I did not find a valid position to go to!");*/
    return pos;
}
integer air;
integer path(vector target,vector init,float dist)
{
    if(target==ZERO_VECTOR)
    {
        standme();
        return 0;
    }
    float dif=(1.0/dist)*0.75;
    if(dist>5.0)dif=1.0/dist;//Makes sure the NPC runs at a set pace instead of constantly increasing with the dist
    //The timer updates 10 times a second. dif determines how much distance is covered of the total distance to target.
    //So if the distance is 100m, we want to use a smaller number to maintain the same update rate, but a larger number if we are closer. We can do this by dividing 1 by distance. So at 100m, we only move 1m and at 5m, we still only move 1m.
    //Do rotation
    rotation rot=llRotBetween(<1.0,0.0,0.0>,llVecNorm(<target.x,target.y,init.z>-init));
    //Do targetpos
     target=init+llVecNorm(target-init)*(dist*dif);//The part that clamps movement distance per update
     //llSay(0,(string)target);
     list ray=llCastRay(target,<target.x,target.y,init.z-(h+5.0)>,[RC_REJECT_TYPES,RC_REJECT_AGENTS,RC_DATA_FLAGS,RC_GET_ROOT_KEY,RC_MAX_HITS,1]);
    vector alt=llList2Vector(ray,1);
    if(alt)//Raycast to ground to check to see if falling
    {
        if(llList2Key(ray,0)!=me)
        {
            if(air)
            {
                llStopObjectAnimation(jumpp);
                air=0;
            }
            target.z=alt.z+h;
            float ground=llGround(target);
            if(target.z<ground)target.z=ground+h;
        }
    }
    else
    {
        if(!air)
        {
            ++air;
            llResetTime();
            llStartObjectAnimation(jumpp);
        }
        float fall=init.z-(9.8*llGetTime());
        ray=llCastRay(init,<init.x,init.y,fall>,[RC_REJECT_TYPES,RC_REJECT_AGENTS,RC_DATA_FLAGS,RC_GET_ROOT_KEY,RC_MAX_HITS,1]);
        vector airpos=llList2Vector(ray,1);
        if(airpos)target=<airpos.x,airpos.y,airpos.z+h>;
        else airpos=<init.x,init.y,fall>;
        target=airpos;
    }
    if(target.x>253.0)target.x=253.0;
    else if(target.x<2.0)target.x=2.0;
    if(target.y>253.0)target.y=253.0;
    else if(target.y<2.0)target.y=2.0;
    llRotLookAt(rot,1.0,0.2);//Doesn't work while object is physical, something to note if you don't use non-phys movement
    //if(llVecDist(target,init)>10.0)llRegionSayTo(llGetOwner(),0,"Moved more than 10 meters!\nTarget: "+(string)target+"\nInitial Position:"+(string)init+"\nDif: "+(string)dif);
    if(!air)
    {
        if(llVecDist(target,lastpos)<1.0&&lastpos!=ZERO_VECTOR)
        {
            lastpos=ZERO_VECTOR;
            standme();
            llResetTime();
        }
        else if(dist>5.0)move(1);
        else move(0);
    }
    return llSetRegionPos(target);

}
vector tar(key id)
{
    vector av=(vector)((string)llGetObjectDetails(id,[OBJECT_POS]));
    return av;
}
vector lastpos;
key me;
key follow;
//AO
string walk="W";
string stand="S";
string run="Guy Run";
//string cro="CrouchMe";
string jumpp="Jump 3";
string melee="attack";
string cast="PRAISECAST";
standme()
{
    llStartObjectAnimation(stand);
    llStopObjectAnimation(walk);
    llStopObjectAnimation(run);
}
move(integer r)
{
    llStopObjectAnimation(stand);
    if(r)
    {
        llStartObjectAnimation(run);
        llStopObjectAnimation(walk);
    }
    else
    {
        llStartObjectAnimation(walk);
        llStopObjectAnimation(run);
    }
}
stopallanims()
{
     list name=llGetObjectAnimationNames();
    integer l=llGetListLength(name);
    while(l--)llStopObjectAnimation(llList2String(name,l));
}
reset()
{
    llSetTimerEvent(0.0);
    llSensorRemove();
    //stopallanims();
    standme();
}
start()
{
    llSensorRepeat("","",1,96.0,PI,1.0);
    llSetTimerEvent(0.1);
}
//EXP
string npckey="NPCKat";
key qid;
default
{
    state_entry()
    {
        //stand=cro;
        llSetStatus(STATUS_ROTATE_X|STATUS_ROTATE_Y,0);
        llListen(0,"",llGetOwner(),"");
        me=llGetKey();
        reset();
        standme();
    }
    on_rez(integer p)
    {
        me=llGetKey();
        standme();
    }
    link_message(integer s, integer n, string m, key id)
    {
        if(m=="start")start();
        else if(id)follow=id;
        else if(m=="reset")reset();
    }
    listen(integer chan, string name, key id, string message)
    {
        if(message=="dbug")
        {
            vector start=llGetPos();
            vector target=tar(id);
            float dist=llVecDist(start,target);
            list ray=llCastRay(start+<0.0,0.0,h>,target,[RC_REJECT_TYPES,RC_REJECT_AGENTS,RC_DATA_FLAGS,RC_GET_ROOT_KEY,RC_MAX_HITS,1]);
            key hit=llList2Key(ray,0);
            string text="I am "+(string)dist+" meters from you. 
            ";
            if(llKey2Name(hit))
            {
                if(hit==me)text+="Path is clear
                ";
                else text+=llKey2Name(hit)+" is blocking the way
                ";
            }
            llSay(0,text+"And the following animations are playing:
            "+llDumpList2String(llGetObjectAnimationNames(),"|"));
        }
        else if(message=="reset")reset();
        else if(message=="follow")
        {
            llSensorRepeat("","",1,96.0,PI,1.0);
            llSetTimerEvent(0.1);
            follow=id;
        }
        else if(message=="die")llDie();
    }
    dataserver(key id, string data)
    {
        if(id!=qid)return;
        else if((integer)llGetSubString(data,0,0))
        {
            data=llGetSubString(data,2,-1);
            list parse=llCSV2List(data);
            string tid=llList2String(parse,0);
            if(llKey2Name(tid))
            {
                key oid=llGetOwnerKey(tid);
                integer chan=-(integer)("0x" + llGetSubString(llMD5String(oid,0), 3, 6));
                if(chan>0)chan=-chan;//Makes sure the channel stays under 0
                if((integer)llList2String(parse,3)>0)
                {
                    llStopObjectAnimation(melee);
                    llTriggerSound("0bcb9cef-f029-7ecc-d58c-7556dc5747d3",1.0);
                    llStartObjectAnimation(melee);
                    //llSay(0,tid+","+(string)chan);
                    llRegionSayTo(tid,chan,"npc,90,2,9,"+npckey);
                }
                else
                {
                    standme();
                    llStartObjectAnimation(cast);
                    llTriggerSound("ab96c3b3-8c46-23d1-9a80-9490114fc1bc",1.0);
                    llSleep(2.0);
                    llRezObject("Lightning Storm",tar(oid),ZERO_VECTOR,ZERO_ROTATION,1);
                    llRegionSayTo(tid,chan,"respawn");
                    llStopObjectAnimation(cast);
                    follow="";
                }
            }
            else follow="";
        }
        qid="";

    }
    sensor(integer d)
    {
        vector dpos=tar(follow);
        vector gpos=llGetPos();
        if(follow)
        {
            if(los(gpos,dpos,1,1))
            {
                if(llVecDist(gpos,dpos)<3.0)
                {
                    if(qid)return;
                    else if(llGetTime()>1.0)
                    {
                        llResetTime();
                        qid=llReadKeyValue((string)follow+"_DATA");
                    }
                }
                return;
            }
            else follow="";//Break lock if we lose LOS
        }
        integer i;
        while(i<d)
        {
            key tid=llDetectedKey(i);
            vector size=llGetAgentSize(tid);
            dpos=llDetectedPos(i)+<0.0,0.0,size.z*0.5>;
            if(los(gpos,dpos,1,1))
            {
                follow=tid;
                i=d;
            }
            ++i;
        }
    }
    no_sensor()
    {
        if(follow)
        {
            if(!los(llGetPos(),tar(follow),1,1))follow="";//Don't break lock unless we lose line-of-sight
        }
    }
    timer()
    {
        if(follow)
        {
            vector dpos=tar(follow);
            vector gpos=llGetPos();
            float dist=llVecDist(dpos,gpos);
            if(dist<2.0)standme();
            else if(los(gpos,dpos,1,1))path(dpos,gpos,dist);
            else
            {
                follow="";
                standme();
            }
        }
        else
        {
            vector gpos=llGetPos();
            if(lastpos)//Are we still moving to a specific location?
            {
                path(lastpos,gpos,llVecDist(gpos,lastpos));
                return;
            }
            else if(llGetTime()>15.0)
            {
                vector dpos=gpos+<llFrand(510.)-255,llFrand(510.)-255.0,0.0>;
                if(dpos.x>250)dpos.x=250.0;
                else if(dpos.x<5.0)dpos.x=5.0;
                if(dpos.y>250)dpos.y=250.0;
                else if(dpos.y<5.0)dpos.y=5.0;
                vector tpos=losvec(gpos,dpos);
                if(tpos!=ZERO_VECTOR)
                {
                    tpos=tpos-llVecNorm(tpos-gpos)*3.0;
                    if(los(gpos,tpos,0,0))
                    {
                        llResetTime();
                        lastpos=tpos;//If we have a specific location, use that. Move to about 5m from it so it doesn't clip into a wall.
                        path(lastpos,gpos,llVecDist(dpos,lastpos));
                    }
                    //else llOwnerSay("Found a position but failed LOS: "+(string)tpos);
                }
                else standme();
            }
        }
    }
}
