Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz [195.113.31.123])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA09811
	for <linux-mm@kvack.org>; Thu, 18 Dec 1997 09:18:16 -0500
Message-ID: <19971218143357.10435@Elf.mj.gts.cz>
Date: Thu, 18 Dec 1997 14:33:57 +0100
From: Pavel Machek <pavel@Elf.mj.gts.cz>
Subject: Re: pageable page tables
References: <19971217221425.30735@Elf.mj.gts.cz> <Pine.LNX.3.91.971218000000.887A-100000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.91.971218000000.887A-100000@mirkwood.dummy.home>; from Rik van Riel on Thu, Dec 18, 1997 at 12:02:43AM +0100
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@fys.ruu.nl
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > No, it would not fail, as no single process eats 5 minutes. And even
> > with SCHED_BG you would load rest of the system: you would load disk
> > subsystem. Often, disk subsystem is more important than CPU.
> 
> This is exactly the place where SCHED_BG works. By
> suspending all but one of the jobs, a heavy multi-user
> machine only has to worry about the interactive jobs,
> and the disk I/O of _one_ SCHED_BG job...

Disk I/O of one job is just enough to make machine pretty annoying for
interactive use. Try make dep on background. (And: I assume that
usualy there will be <=1 SCHED_BG job.)

								Pavel

-- 
I'm really pavel@atrey.karlin.mff.cuni.cz. 	   Pavel
Look at http://atrey.karlin.mff.cuni.cz/~pavel/ ;-).
