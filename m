Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA22180
	for <linux-mm@kvack.org>; Thu, 30 Apr 1998 17:20:14 -0400
Date: Thu, 30 Apr 1998 22:57:02 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Out of VM idea
In-Reply-To: <8790ootnpp.fsf@atlas.infra.CARNet.hr>
Message-ID: <Pine.LNX.3.91.980430225256.1311H-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: George <greerga@nidhogg.ham.muohio.edu>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 29 Apr 1998, Zlatko Calusic wrote:

> > You can tune the buffermem & pagecache amount of memory
> > in /proc/sys/vm/{buffermem,pagecache}.
> 
> Every time before he starts compiling, and then return to old values
> when he's finished?
> 
> IMNSHO, kernel should be autotuning.

How do you propose we should do this? The round-robin
deallocation and on-demand allocation of buffer/user
pages are somewhat auto-tuning.
Maybe we should age the page cache & buffermem pages
to achieve a more LRU-like discarding scheme (the
buffer pages are thrown out randomly at the moment).

> > But why your system has 4 MB of free memory I really
> > don't know...

> 	if (nr_free_pages > num_physpages >> 4)
> 		return nr+1;
> 
> With 64MB of memory, last 4MB are almost never used!!!

I believe George said something about my patch, with
which the number should be lower.
Anyway, the freepages number should be sysctl tunable,
together with kswapd agressiveness and clustering
size.

> MM in last kernels is not very good.

True, but maybe Linus will integrate my patch, which
makes the kernel behave somewhat more predictable, and
which has a builtin low/high watermark so thrashing is
reduced.

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.phys.uu.nl/~riel/          | <H.H.vanRiel@phys.uu.nl> |
+-------------------------------------------+--------------------------+
