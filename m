Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id DAA25382
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 03:07:33 -0500
Date: Wed, 25 Nov 1998 07:41:41 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <19981124214432.2922.qmail@sidney.remcomp.fr>
Message-ID: <Pine.LNX.3.96.981125073253.30767B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: jfm2@club-internet.fr
Cc: sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 24 Nov 1998 jfm2@club-internet.fr wrote:

> Agreed, the important feature is the stopping one of the processes
> when critically short of memory.  Swapping is only a trick for
> getting more bandwidth at the expenses of pushing in an out of
> memory a greater amount of process space so there is no proof it is
> faster than letting other processes steal memory page by page from
> the now stopped process. 

When the mythical swapin readahead will be merged, we can
gain some ungodly amount of speed almost for free. I don't
know if we'll ever implement the scheduling tricks...

I do have a few ideas for the scheduling stuff though, with
RSS limits (we can safely implement those when the swap cache
trick is implemented) and the keeping of a few statistics,
we will be able to implement the swapping tricks.

Without swapin readahead, we'll be unable to implement them
properly however :(

> > > And now we are at it: in 2.0 I found a deamon can be killed by the
> > > system if it runs out of VM.  
> > 
> > Same on any BSD.
> 
> Say the Web or database server can be deemed important enough for it
> not being killed just because some dim witt is playing with the GIMP
> at the console and the GIMP has allocated 80 Megs.

I sounds remarkably like you want my Out Of Memory killer
patch. This patch tries to remove the randomness in killing
a process when you're OOM by carefully selecting a process
based on a lot of different factors (size, age, CPU used,
suid, root, IOPL, etc).

It needs to be cleaned up, ported to 2.1.129 and improved
a little bit though... After that it should be ready for
inclusion in the kernel.

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
