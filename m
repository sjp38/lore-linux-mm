Received: from ns.weiden.de (ns.weiden.de [193.203.186.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA11587
	for <linux-mm@kvack.org>; Tue, 3 Mar 1998 11:11:29 -0500
Date: Tue, 3 Mar 1998 17:10:28 +0100 (MET)
From: "Michael L. Galbraith" <mikeg@weiden.de>
Subject: Re: [PATCH] kswapd fix & logic improvement
In-Reply-To: <Pine.LNX.3.91.980303083346.16214A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980303161235.2407A-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Mar 1998, Rik van Riel wrote:

> On Tue, 3 Mar 1998, Michael L. Galbraith wrote:
> 
> > I was able to stimulate a 'swap-attack' which took almost a hour to
> > recover control from.
> > 
> > 2.1.89pre5 + swap patch
> 
> To 'recover from' or 'handle' your attack (180+ mb working
> set on an 80 mb machine) is going to need 'real' swapping,
> ie. the temporary suspension of processes to reduce VM load.
> 
> I'd like you to try to even start your stress test under a
> normal kernel (it'll probably work, but not without the
> neccesary oom()s and signal 7s).
> 

I've run much larger working sets on this machine without either
losing control or having the tasks killed. I've run simulations
which ate 400+ Mb. The realtime aspect was a joke, but it worked.

> This patch is only an improvement for normal use. Anyways,
> thrashing can't be combatted by paging algorithms, no matter
> how good.
> 

OK.. thought you wanted it pounded upon.

It was running fine with all tasks being scheduled smoothly until
something triggered a mega-thrash.

> I'll be working on the swapping daemon as soon as I've got
> the current patch sorted out...
> 

Turned out the kswapd messages weren't related to the thrashing.
I would have seen it if I hadn't jumped straight into X.

	-Mike
