Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA11682
	for <linux-mm@kvack.org>; Thu, 12 Nov 1998 05:02:33 -0500
Date: Thu, 12 Nov 1998 09:48:26 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] Patch to Memory Subsystem ... (Needed?)
In-Reply-To: <m0zdmYp-001hXmC@haystack.BOGUS_NET>
Message-ID: <Pine.LNX.3.96.981112093820.16355B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Karl J. Runge" <runge@crl.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Nov 1998, Karl J. Runge wrote:

> Forgive my intrusion, I have been using Linux for about 5 years, and
> am a decent C programmer, but certainly not a kernel hacker
> (however, at least I am not afraid to at _look_ at the kernel code). 

I guess that qualifies you as someone to pay decent
attention to :)

[SNIP dual ppro/64M 128M swap half full is sluggish]

> Is this inescapable because I am that far into swap?

I don't know how much swap I/O is going on, but it certainly
shouldn't be as bad as you describe.

I know my 72MB machine feels great when GIMP is 120 MB
in swap and paging a lot (not thashing though).

OTOH, if the working set of your machine is larger than
the amount of physical memory you have, I guess the
machine will be thrashing...

> I am looking to buy more RAM, but I still feel something is not
> right.  I have used kernels 2.0.35, 2.1.88, 2.1.112, and now
> 2.1.127. Perhaps it was better in 2.0.x but I cannot be sure (that
> was some time ago). I would be willing to experiment with swap
> parameters my setup, perhaps via some sysctl interface to kswapd? Is
> there such a beast? 

There is documentation in Documentation/sysctl/, but
it is currently out of date because Linus is ignoring
the patch I sent him.

> I have noticed Solaris recently added something that distinguishes
> between file I/O and system I/O at: 
> 
>  http://www.sun.com/sun-on-net/performance/priority_paging.html

I'll check it out.

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
