Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA10454
	for <linux-mm@kvack.org>; Tue, 3 Mar 1998 06:01:27 -0500
Date: Tue, 3 Mar 1998 08:39:30 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: [PATCH] kswapd fix & logic improvement
In-Reply-To: <Pine.LNX.3.95.980303073840.437A-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.3.91.980303083346.16214A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Michael L. Galbraith" <mikeg@weiden.de>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Mar 1998, Michael L. Galbraith wrote:

> I was able to stimulate a 'swap-attack' which took almost a hour to
> recover control from.
> 
> 2.1.89pre5 + swap patch

The attack you mention is going to affect _every_ kernel
out there. It's just that without my patch a lot of
random processes are going to be killed with signal 7 (sigbus).

Now kswapd is somewhat better to keep up with things, it
will remain swapping, instead of killing...

To 'recover from' or 'handle' your attack (180+ mb working
set on an 80 mb machine) is going to need 'real' swapping,
ie. the temporary suspension of processes to reduce VM load.

I'd like you to try to even start your stress test under a
normal kernel (it'll probably work, but not without the
neccesary oom()s and signal 7s).

This patch is only an improvement for normal use. Anyways,
thrashing can't be combatted by paging algorithms, no matter
how good.

I'll be working on the swapping daemon as soon as I've got
the current patch sorted out...

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
