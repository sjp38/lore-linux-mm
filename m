Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA04649
	for <linux-mm@kvack.org>; Tue, 8 Dec 1998 09:16:10 -0500
Date: Tue, 8 Dec 1998 14:51:31 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <199812081235.MAA02355@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981208144925.16426H-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Billy Harvey <Billy.Harvey@thrillseeker.net>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Dec 1998, Stephen C. Tweedie wrote:
> On Tue, 8 Dec 1998 03:31:25 +0100 (CET), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > On a swapout, we will scan ahead of where we are (p->swap_address)
> > and swap out the next number of pages too. 
> 
> Yes, but be aware that for good performance you need to combine this
> with a mechanism to ensure swap space does not become fragmented,
> and you also need a swap-behind mechanism for sequential accesses
> (so that if an application is scanning a data set sequentially, the
> un-accessed space behind the current application "cursor" is being
> removed from memory just as fast as the stuff about to be accessed
> is being brought in).

And we also want a nice swapout clustering algorithm and
an awful lot of other stuff as well. I think we should
work on that stuff in the 'vacuum' period when 2.2 stabilizes
and 2.3 hasn't split off yet. Then we can merge the changes
in 2.3.very_small so we don't hold up the tree and give
something else the chance to hold it up again and again...

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
