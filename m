Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA11678
	for <linux-mm@kvack.org>; Fri, 4 Dec 1998 09:15:56 -0500
Date: Fri, 4 Dec 1998 15:02:56 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <199812041134.LAA01682@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981204150030.15134N-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 1998, Stephen C. Tweedie wrote:
> On Thu, 3 Dec 1998 18:56:34 +0100 (CET), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > The swapin enhancement consists of a simple swapin readahead.
> 
> One odd thing about the readahead: you don't start the readahead until
> _after_ you have synchronously read in the first swap page of the
> cluster.  Surely it is better to do the readahead first, so that you
> are submitting one IO to disk, not two?

This would severely suck when something else would be doing
a run_taskqueue(&tq_disk). It would mean that we'd read
n+1..n+15 before n itself.

OTOH, if the disk is lightly loaded it would be an advantage.
I will try it shortly (but don't know how to measure the
results :)...

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
