Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA13742
	for <linux-mm@kvack.org>; Fri, 4 Dec 1998 15:50:54 -0500
Date: Fri, 4 Dec 1998 21:47:04 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <Pine.LNX.3.96.981204192244.28834B-100000@ferret.lmh.ox.ac.uk>
Message-ID: <Pine.LNX.3.96.981204214235.28282A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chris Evans <chris@ferret.lmh.ox.ac.uk>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 1998, Chris Evans wrote:
> On Thu, 3 Dec 1998, Rik van Riel wrote:
> 
> > here is a patch (against 2.1.130, but vs. 2.1.131 should
> > be trivial) that improves the swapping performance both
> > during swapout and swapin and contains a few minor fixes.
> 
> I'm very interested in performance for sequential swapping. This
> occurs in for example scientific applications which much sweep
> through vast arrays much larger than physical RAM. 
> 
> This is one area in which FreeBSD stomps on us. Theoretically it
> should be possible to get swap with readahead pulling pages into RAM
> at disk speed. 

We're not at that point yet, not at all :(

We probably could put in an algorithm that does that as
well, but the current patch consists mainly of a proof-
of-concept (read really stupid) readahead algorithm :)

The advantage of that algorithm however is that it doesn't
incur any extra disk seeks (only linear readahead inside
the swap area). The way kswapd swaps out things this might
also help with the readahead of tiled date, etc...

I will compile a new patch (against 2.1.130 again, since
2.1.131 contains mostly VM mistakes that I want reversed)
this weekend...

regards,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
