Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA30226
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 08:04:01 -0500
Date: Mon, 7 Dec 1998 13:02:04 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: 2.1.131 first impressions
In-Reply-To: <19981207005145.A832@tantalophile.demon.co.uk>
Message-ID: <Pine.LNX.3.96.981207125304.23360E-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jamie Lokier <lkd@tantalophile.demon.co.uk>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Dec 1998, Jamie Lokier wrote:

> I've just switched from 2.1.129 to 2.1.131 + Rik's "fastest VM system"
> patch, and I have to say, nice!
> 
> Disk activity
> =============
> 
> Something's changed.  Can't say whether it's the main tree changes or
> Rik's mm changes (I haven't tried plain 2.1.131).

Both. Stephen's changes to shrink_mmap() really have a huge
influence on performance.

> I'm not using any swap either (well, 16k on a 64MB system).  It feels
> faster somehow anyway.

The not-using-any-swap part comes both from Stephen's improvement
and my change to vmscan.c; we now quit a swap_out() loop earlier
and we do (over?-)agressive pruning of the page and buffer caches.

> Well, apart from Squid which still spends a few minutes grinding
> away at the disk when it starts.  I would like to find a way to fix
> this, it's probably the most thrashy thing my disk has to handle and
> it does slow down everything else for a while quite significantly. 

This could be a side effect of a too agressive pruning of the
caches. We should fix this.

> Netscape still hits the disk very hard when it starts, and takes what
> seems like just as long.  Netscape is pretty quick to start the second
> time though (about 3 seconds), so it's definitely a paging thing.  Is
> there anything which could be done with paging
> read-ahead/read-behind/read-cleverer to make Netscape not thrash the
> disk when it starts?

No, not really. When Netscape starts it is not in cache yet :)

I agree that we should do better readbehind though. I am
currently designing a nice algorithm for deciding whether
to do read-ahead, read-behind, a bit of both or a lot of
both. It is mainly focused at swap I/O though...

File I/O might be better served with a slightly different
algorithm, so we need a volunteer for that... If you are
that volunteer: linux-mm@kvack.org is the list to be.

regards,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
