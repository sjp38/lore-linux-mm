Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D36CE6B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 01:49:08 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] SLQB slab allocator (try 2)
Date: Wed, 4 Feb 2009 17:48:40 +1100
References: <20090123154653.GA14517@wotan.suse.de> <200902032136.26022.nickpiggin@yahoo.com.au> <20090203112226.GG9840@csn.ul.ie>
In-Reply-To: <20090203112226.GG9840@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902041748.41801.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 03 February 2009 22:22:26 Mel Gorman wrote:
> On Tue, Feb 03, 2009 at 09:36:24PM +1100, Nick Piggin wrote:

> > But it will be interesting to try looking at some of the tests where
> > SLQB has larger regressions, so that might give me something to go on
> > if I can lay my hands on speccpu2006...
>
> I can generate profile runs although it'll take 3 days to gather it all
> together unless I target specific tests (the worst ones to start with
> obviously). The suite has a handy feature called monitor hooks that allows
> a pre and post script to run for each test which I use it to start/stop
> oprofile and gather one report per benchmark. I didn't use it for this run
> as profiling affects the outcome (7-9% overhead).
>
> I do have detailed profile data available for sysbench, both per thread run
> and the entire run but with the instruction-level included, it's a lot of
> data to upload. If you still want it, I'll start it going and it'll get up
> there eventually.

It couldn't hurt, but it's usually tricky to read anything out of these from
CPU cycle profiles. Especially if they are due to cache or tlb effects (which
tend to just get spread out all over the profile).

slabinfo (for SLUB) and slqbinfo (for SLQB) activity data could be interesting
(invoke with -AD).


> > I'd be interested to see how slub performs if booted with
> > slub_min_objects=1 (which should give similar order pages to SLAB and
> > SLQB).
>
> I'll do this before profiling as only one run is required and should
> only take a day.
>
> Making spec actually build is tricky so I've included a sample config for
> x86-64 below that uses gcc and the monitor hooks in case someone else is in
> the position to repeat the results.

Thanks. I don't know if we have a copy of spec 2006 I can use, but I'll ask
around.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
