Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA12339
	for <linux-mm@kvack.org>; Tue, 3 Mar 1998 14:01:19 -0500
Date: Tue, 3 Mar 1998 18:16:17 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: [PATCH] kswapd fix & logic improvement
In-Reply-To: <Pine.LNX.3.95.980303161235.2407A-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.3.91.980303181105.414D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Michael L. Galbraith" <mikeg@weiden.de>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Mar 1998, Michael L. Galbraith wrote:

> > To 'recover from' or 'handle' your attack (180+ mb working
> > set on an 80 mb machine) is going to need 'real' swapping,
> > ie. the temporary suspension of processes to reduce VM load.
> 
> I've run much larger working sets on this machine without either
> losing control or having the tasks killed. I've run simulations
> which ate 400+ Mb. The realtime aspect was a joke, but it worked.

When allocation is done piece-by-piece, and there's only
one big process which is faulting all the time, all known
Linux kernels can handle it (more or less).

> > This patch is only an improvement for normal use. Anyways,
> > thrashing can't be combatted by paging algorithms, no matter
> > how good.
> 
> OK.. thought you wanted it pounded upon.

You were right about that. I wanted to be sure that my
patch was at least as solid as the old code before it
gets merged into the kernel. Judging from the reports
I got, it is. In fact, most people have reported a big
improvement, and some people have pounded and ground it
to a crawl (without being able to make it crash).

> It was running fine with all tasks being scheduled smoothly until
> something triggered a mega-thrash.

Once you start thrashing, only real swapping is an option
to save performance (somewhat).

> > I'll be working on the swapping daemon as soon as I've got
> > the current patch sorted out...
> 
> Turned out the kswapd messages weren't related to the thrashing.
> I would have seen it if I hadn't jumped straight into X.

Ahh, yes. X allocates a _lot_ of memory at once, and then
the damn thing _uses_ it at once... This is guaranteed to
make kswapd a bit nervous, both with or without my patch.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
