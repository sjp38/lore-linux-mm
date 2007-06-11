Date: Mon, 11 Jun 2007 09:57:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 10 of 16] stop useless vm trashing while we wait the
 TIF_MEMDIE task to exit
In-Reply-To: <20070611165032.GJ7443@v2.random>
Message-ID: <Pine.LNX.4.64.0706110952001.16068@schroedinger.engr.sgi.com>
References: <24250f0be1aa26e5c6e3.1181332988@v2.random>
 <Pine.LNX.4.64.0706081446200.3646@schroedinger.engr.sgi.com>
 <20070609015944.GL9380@v2.random> <Pine.LNX.4.64.0706082000370.5145@schroedinger.engr.sgi.com>
 <20070609140552.GA7130@v2.random> <20070609143852.GB7130@v2.random>
 <Pine.LNX.4.64.0706110905080.15326@schroedinger.engr.sgi.com>
 <20070611165032.GJ7443@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Andrea Arcangeli wrote:

> On Mon, Jun 11, 2007 at 09:07:59AM -0700, Christoph Lameter wrote:
> > Filtering tasks is a very expensive operation on huge systems. We have had 
> 
> Come on, oom_kill.c only happens at oom time, after the huge complex
> processing has figured out it's time to call into oom_kill.c, how can
> you care about the performance of oom_kill.c?  Apparently some folks
> prefer to panic when oom triggers go figure...

Its pretty bad if a large system sits for hours just because it cannot 
finish its OOM processing. We have reports of that taking 4 hours!

> In turn killing the current task so that oom_kill.c is faster, is
> quite a dubious argument.

It avoids repeated scans over a super sized tasklist with heavy lock 
contention. 4 loops for every OOM kill! If a number of processes will be 
OOM killed then it will take hours to sort out the lock contention.

Want this as a a SUSE bug?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
