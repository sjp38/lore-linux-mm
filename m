Received: from atlas.infra.CARNet.hr (zcalusic@atlas.infra.CARNet.hr [161.53.160.131])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA16057
	for <linux-mm@kvack.org>; Wed, 29 Apr 1998 15:48:17 -0400
Subject: Re: Out of VM idea
References: <Pine.LNX.3.91.980429071621.20465B-100000@mirkwood.dummy.home>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 29 Apr 1998 21:46:58 +0200
In-Reply-To: Rik van Riel's message of "Wed, 29 Apr 1998 07:19:51 +0200 (MET DST)"
Message-ID: <8790ootnpp.fsf@atlas.infra.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: George <greerga@nidhogg.ham.muohio.edu>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

> On Tue, 28 Apr 1998, George wrote:
> > On Tue, 28 Apr 1998, Rik van Riel wrote:
> > 
> > >Following some observations from Michael Remski (sent
> > >to me by private e-mail), I've come to the conlusion
> > >that we really should do something about out-of-VM
> > >situations.
> > 
> > At the moment, (2.1.98), I can lock my 64 MB machine up with a 'make
> > MAKE='make -j20' zImage'.
> > 
> > At the time of memory death:
> > * It has 4 megabytes of free pages.
> > * It has 6 megabytes of buffer memory.
> > * But it dies because it has 0 swap left.
> > 
> > Those hard limits on memory how much memory to not grab should definitely
> > go. 
> 
> You can tune the buffermem & pagecache amount of memory
> in /proc/sys/vm/{buffermem,pagecache}.

Every time before he starts compiling, and then return to old values
when he's finished?

IMNSHO, kernel should be autotuning.

> But why your system has 4 MB of free memory I really
> don't know...

mm/page_alloc.c (in free_memory_available()):

	/*
	 * If we have more than about 6% of all memory free,
	 * consider it to be good enough for anything.
	 * It may not be, due to fragmentation, but we
	 * don't want to keep on forever trying to find
	 * free unfragmented memory.
	 */
	if (nr_free_pages > num_physpages >> 4)
		return nr+1;

With 64MB of memory, last 4MB are almost never used!!!

MM in last kernels is not very good.

Except Stephens great improvements of the swapping system, where he
did a really good job, I believe we did a step backward with recent
changes.

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	  (A)bort, (R)etry, (P)retend this never happened...
