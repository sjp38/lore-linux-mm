Received: from atrey.karlin.mff.cuni.cz (root@atrey.karlin.mff.cuni.cz [195.113.31.123])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA05900
	for <linux-mm@kvack.org>; Wed, 17 Dec 1997 16:31:08 -0500
Message-ID: <19971217221425.30735@Elf.mj.gts.cz>
Date: Wed, 17 Dec 1997 22:14:25 +0100
From: Pavel Machek <pavel@Elf.mj.gts.cz>
Subject: Re: pageable page tables
References: <19971210161108.02428@Elf.mj.gts.cz> <Pine.LNX.3.91.971212074748.466A-100000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.91.971212074748.466A-100000@mirkwood.dummy.home>; from Rik van Riel on Fri, Dec 12, 1997 at 07:57:16AM +0100
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@fys.ruu.nl
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > Not sure this is good idea.
> 
> Many systems use something like NQS for large jobs, but
> this would be a nice scheme for 'medium' jobs. The
> machine at our school, for instance, has a 5minute CPU
> limit (per process)...
> Doing a large compile (glibc :-) on such a machine would
> not only fail, but it would also annoy other users. This
> SCHED_BG scheme doesn't really load the rest of the system...

No, it would not fail, as no single process eats 5 minutes. And even
with SCHED_BG you would load rest of the system: you would load disk
subsystem. Often, disk subsystem is more important than CPU.

> > > And when free memory stays below free_pages_low for more
> > > than 5 seconds, we can choose to have even normal processes
> > > queued for some time (in order to reduce paging)
> 
> someone else have an opinion on this?

Too many heuristics?

								Pavel
-- 
I'm really pavel@atrey.karlin.mff.cuni.cz. 	   Pavel
Look at http://atrey.karlin.mff.cuni.cz/~pavel/ ;-).
