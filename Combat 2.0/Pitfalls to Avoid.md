# The Rate of Fire throttle
aka, the infamous "rez queue". There is a server-side limit to how many objects or 'rez calls' an avatar's scripted attachments can spawn before the region enacts a restriction. 
This restriction freezes all scripts for attachments or objects attempting to spawn additional objects. It should be noted that ESTATE MANAGERS (confirmed) and potentially land moderation (needs more testing) are NOT affected by this restriction within the regions they manage.

You will know you have this issue if the weapons become unresponsive to gestures or commands, are 'stuck firing' without actually spawning bullets, and fail to recognize various control inputs. Note that script events are NOT consistently queued while the restriction is imposed. Weapons which function via looping toggles are very vulnerable as they most likely will immediately resume firing once the restriction is lifted and may even re-trigger the restriction as a result.

This restriction is separate from global rezqueue but is part of the same system. The global rezqueue is triggered during the same time window that this restriction is imposed against avatars, however is it generally shorter than the targetted restrictions in duration. The throttle sits around 1800 to 2000 RPM (30 to 33 calls per second) under ideal conditions, but it is affected by latency and region load. It is possible to easily hit the limit at 1000RPM during high region load or activity, and considerably easier the higher the RPM of the weapon beyond this.
The restriction is applied to all attachments that attempt to spawn an object so long as the avatar continues to exceed the limit. Keep weapons around 600 to 750 RPM will make it so it is rare it hit these conditions consistently, as well as shorten the duration of any such incident due to the low overall rate of rezzing. That said, duration is largely dependent on how high the average rez-calls are and function is restored once the avatar drops below the acceptable limit. It is likely calculated in the same way script-time is.

Since 2016, most of my weapons have been hitscan and thus rarely hit this limit. Even as I transitioned back to physical rounds, my guns rarely exceed 600RPM due to this reason among others. As always, there is no replacement for extensive testing. This behaviour was introduced between 2018 and 2019 from my best recollection and has drastically affected many weapons made prior. As with all changes of this nature, it is to prevent griefing but like with all such changes, it failed to fix the actual problem and introduced new ones.
I would argue for an overall switch to hitscan weapons going forward but the community has made it clear that is not a direction they will ever wish to persue.

If you are looking to avoid the issue, I would strongly recommend keeping weapons under 1000 RPM. If your weapon does exceed this, avoid going beyond 1100RPM as this greatly narrows your tolerance window and extends the duration of the restrictions imposed. Weapons should be designed with this problem in mind.

# Enduring effects
Post-Combat 2.0, the need to have individual spawn parcels has become obsolete. The same applies to changing ideology in regards to vehicle respawning.
In the case of avatars, functions like llGetHealth allow us to more actively monitor a target's health state and prevent blackscreening. The same *should* be true for vehicles but in practice has been inconsistent. 
More effort and coordination will need to be made to prevent objects from improperly damaging vehicles or avatars past the kill-point.
