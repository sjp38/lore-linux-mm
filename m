Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA00628
	for <linux-mm@kvack.org>; Tue, 7 Jul 1998 12:31:20 -0400
Date: Tue, 7 Jul 1998 17:54:46 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <199807071201.NAA00934@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980707175139.18757A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Jul 1998, Stephen C. Tweedie wrote:
> On Mon, 6 Jul 1998 21:28:42 +0200 (CEST), Andrea Arcangeli
> <arcangeli@mbox.queen.it> said:
> 
> > It would be nice if it would be swapped out _only_ pages that are not used
> > in the past half an hour. If kswapd would run in such way I would thank
> > you a lot instead of being irritate ;-).
> 
> ?? Some people will want to keep anything used within the last half
> hour; in other cases, 5 minutes idle should qualify for a swapout.  On
> the compilation benchmarks I run on 6MB machines, any page not used
> within the past 10 seconds or so should be history!

There's a good compromize between balancing per-page
and per-process. We can simply declare the last X
(say 8) pages of a process holy unless that process
has slept for more than Y (say 5) seconds.

As a temporary measure, you can tune swapctl to
have an age_cluster_fract of 128 and an
age_cluster_min of 0; this will leave the 8 last
pages of an app in memory, whatever happens...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
