Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id C65996B0044
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 12:33:22 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so2624955eaa.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 09:33:21 -0800 (PST)
Date: Wed, 21 Nov 2012 18:33:16 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/46] Automatic NUMA Balancing V4
Message-ID: <20121121173316.GA29311@gmail.com>
References: <1353493312-8069-1-git-send-email-mgorman@suse.de>
 <20121121165342.GH8218@suse.de>
 <20121121170306.GA28811@gmail.com>
 <20121121172011.GI8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121121172011.GI8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> On Wed, Nov 21, 2012 at 06:03:06PM +0100, Ingo Molnar wrote:
> > 
> > * Mel Gorman <mgorman@suse.de> wrote:
> > 
> > > On Wed, Nov 21, 2012 at 10:21:06AM +0000, Mel Gorman wrote:
> > > > 
> > > > I am not including a benchmark report in this but will be posting one
> > > > shortly in the "Latest numa/core release, v16" thread along with the latest
> > > > schednuma figures I have available.
> > > > 
> > > 
> > > Report is linked here https://lkml.org/lkml/2012/11/21/202
> > > 
> > > I ended up cancelling the remaining tests and restarted with
> > > 
> > > 1. schednuma + patches posted since so that works out as
> > 
> > Mel, I'd like to ask you to refer to our tree as numa/core or 
> > 'numacore' in the future. Would such a courtesy to use the 
> > current name of our tree be possible?
> > 
> 
> Sure, no problem.

Thanks!

I ran a quick test with your 'balancenuma v4' tree and while 
numa02 and numa01-THREAD-ALLOC performance is looking good, 
numa01 performance does not look very good:

                    mainline    numa/core      balancenuma-v4
     numa01:           340.3       139.4          276 secs

97% slower than numa/core.

I did a quick SPECjbb 32-warehouses run as well:

                                numa/core      balancenuma-v4
      SPECjbb  +THP:               655 k/sec      607 k/sec

Here it's 7.9% slower.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
