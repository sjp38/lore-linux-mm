Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA11448
	for <linux-mm@kvack.org>; Tue, 14 Apr 1998 20:02:36 -0400
Date: Wed, 15 Apr 1998 00:58:58 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: H.H.vanRiel@phys.uu.nl
Subject: Kswapd future (was: Re: new kmod.c - debuggers and testers needed)
In-Reply-To: <199804142127.OAA09136@sun4.apsoft.com>
Message-ID: <Pine.LNX.3.91.980415005704.875A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Perry Harrington <pedward@sun4.apsoft.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Apr 1998, Perry Harrington wrote:

> > On Tue, 7 Apr 1998, Perry Harrington wrote:
> > 
> > >                                                           Threads
> > > are useful in their appropriate context, and kswapd, and kmod would benefit
> > > from them.
> > 
> > Hmm, maybe it would be useful for kswapd and bdflush to fork()
> > off threads to do the actual disk I/O, so the main thread won't
> > be blocked and paused... This could remove some bottlenecks.
> 
> I was thinking that kswapd could use some of it's spare time to do an LRU
> paging scan, consolidate free space, and possibly do remapping of process
> memory spaces to make them more efficient (map pages to contiguous chunks
> of memory and swap).

Unfortunately, kswapd doesn't have such a thing as 'spare time'.
It is a kernel daemon that does what's neccessary, but we want
to keep it's CPU/IO footprint absolutely minimal since all other
applications are more important...

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
