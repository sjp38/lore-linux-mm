Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA10626
	for <linux-mm@kvack.org>; Thu, 18 Dec 1997 12:06:32 -0500
Date: Thu, 18 Dec 1997 15:46:58 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: SCHED_BG
In-Reply-To: <19971218143357.10435@Elf.mj.gts.cz>
Message-ID: <Pine.LNX.3.91.971218154302.16734B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@Elf.mj.gts.cz>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Dec 1997, Pavel Machek wrote:

> > > No, it would not fail, as no single process eats 5 minutes. And even
> > > with SCHED_BG you would load rest of the system: you would load disk
> > > subsystem. Often, disk subsystem is more important than CPU.
> > 
> > This is exactly the place where SCHED_BG works. By
> > suspending all but one of the jobs, a heavy multi-user
> > machine only has to worry about the interactive jobs,
> > and the disk I/O of _one_ SCHED_BG job...
> 
> Disk I/O of one job is just enough to make machine pretty annoying for
> interactive use. Try make dep on background. (And: I assume that
> usualy there will be <=1 SCHED_BG job.)

Not on a multi-user machine...

And: on my machine (3 disks) I can run several makes before
it becomes annoying (about 5). That's quite good considering
the fact that I only have 24megs of RAM (just 4 more than you,
Pavel)

And when I get the other disks back (one broke, so I get two
smaller ones in return:), my system will run even slicker...
It's all a matter of strategic placement of your files...

Maybe you should also read the Multiple-Disk-HOWTO or 
Partioning-HOWTO, or whatever it's called this week :)

My mmap-age patch will also help quite a bit...

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
