Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA31037
	for <linux-mm@kvack.org>; Fri, 27 Feb 1998 06:00:55 -0500
Date: Fri, 27 Feb 1998 10:58:34 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: [2x PATCH] page map aging & improved kswap logic
In-Reply-To: <199802270929.KAA28081@boole.fs100.suse.de>
Message-ID: <Pine.LNX.3.91.980227105614.17899A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Feb 1998, Dr. Werner Fink wrote:

> > The kswapd logic is almost completely redone. Basically,
> > kswapd tries (free_pages_high - nr_free_pages) times to
> > free a page, but when memory becomes tighter, the number
> > of tries become even higher.
> 
> Is the explicit call of run_task_queue(&tq_disk) really needed?
> Maybe setting of the __GFP_WAIT flag would work in the same manner:
> 
>         gfp_mask = __GFP_IO;
>         if (atomic_read(&nr_async_pages) >= SWAP_CLUSTER_MAX)
>                 gfp_mask |= __GFP_WAIT;

Wouldn't that just mean that the pages that are
swapped out from now on will be done synchronously?

What I wanted kswapd to do, was to select SWAP_CLUSTER_MAX
pages and swap them out in _one_ I/O operation. Because
this should save head movement, it might give us an improvement
over syncing each swapped page seperately.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
