Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA26549
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 08:25:23 -0500
Date: Wed, 25 Nov 1998 14:08:47 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <199811251227.MAA00808@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981125140245.8544A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, jfm2@club-internet.fr, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Nov 1998, Stephen C. Tweedie wrote:
> On Wed, 25 Nov 1998 07:41:41 +0100 (CET), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > I do have a few ideas for the scheduling stuff though, with
> > RSS limits (we can safely implement those when the swap cache
> > trick is implemented) and the keeping of a few statistics,
> > we will be able to implement the swapping tricks.
> 
> Rick, get real: when will you work out how the VM works?  We can
> safely implement RSS limits *today*, and have been able to since
> 2.1.89.  <grin> It's just a matter of doing a vmscan on the current
> process whenever it exceeds its own RSS limit.  The mechanism is all
> there. 

If we tried to implement RSS limits now, it would mean that
the large task(s) we limited would be continuously thrashing
and keep the I/O subsystem busy -- this impacts the rest of
the system a lot.

With the new scheme, we can implement the RSS limit, but the
truly busily used pages would simply stay inside the swap cache,
freeing up I/O bandwidth (at the cost of some memory) for the
rest of the system.

I think that with the new scheme the balancing will be so
much better that we can implement RSS limits without a
negative impact on the rest of the system. With the current
VM system RSS limits would probably hamper the performance
the rest of the system gets.

We might want to perform the scheduling tricks for over-RSS
processes however. Without swap readahead I really don't see
any way we could run them without keeping back the rest of
the system too much...

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
