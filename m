Received: from localhost (bcrl@localhost)
	by kvack.org (8.8.7/8.8.7) with SMTP id BAA08009
	for <linux-mm@kvack.org>; Thu, 18 Dec 1997 01:01:26 -0500
Date: Thu, 18 Dec 1997 01:01:25 -0500 (EST)
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: pageable page tables
Message-ID: <Pine.LNX.3.95.971218010023.7940B-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

---Forwarded---
Date: Thu, 18 Dec 1997 00:02:43 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
X-Sender: riel@mirkwood.dummy.home
Reply-To: H.H.vanRiel@fys.ruu.nl
To: Pavel Machek <pavel@Elf.mj.gts.cz>
cc: linux-mm@kvack.org
Subject: Re: pageable page tables
In-Reply-To: <19971217221425.30735@Elf.mj.gts.cz>
Message-ID: <Pine.LNX.3.91.971218000000.887A-100000@mirkwood.dummy.home>
Approved: ObHack@localhost
Organization: none
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII

On Wed, 17 Dec 1997, Pavel Machek wrote:

> No, it would not fail, as no single process eats 5 minutes. And even
> with SCHED_BG you would load rest of the system: you would load disk
> subsystem. Often, disk subsystem is more important than CPU.

This is exactly the place where SCHED_BG works. By
suspending all but one of the jobs, a heavy multi-user
machine only has to worry about the interactive jobs,
and the disk I/O of _one_ SCHED_BG job...

> > > > And when free memory stays below free_pages_low for more
> > > > than 5 seconds, we can choose to have even normal processes
> > > > queued for some time (in order to reduce paging)
> 
> Too many heuristics?

That doesn't really matter if they aren't used very
often... We only have to check the free memory from
swap_tick (we already do) and call a special routine
for suspending / waking up the SCHED_BG jobs

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
