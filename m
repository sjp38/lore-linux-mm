Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 709866B0072
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 14:50:48 -0500 (EST)
Date: Fri, 16 Nov 2012 20:50:18 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Benchmark results: "Enhanced NUMA scheduling with adaptive
 affinity"
Message-ID: <20121116195018.GA8908@redhat.com>
References: <20121112160451.189715188@chello.nl>
 <20121112184833.GA17503@gmail.com>
 <20121115100805.GS8218@suse.de>
 <CA+55aFyEJwRvQezg3oKg71Nk9+1QU7qwvo0BH4ykReKxNhFJRg@mail.gmail.com>
 <50A566FA.2090306@redhat.com>
 <20121116141428.GZ8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121116141428.GZ8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>

Hi,

On Fri, Nov 16, 2012 at 02:14:28PM +0000, Mel Gorman wrote:
> With some shuffling the question on what to consider for merging
> becomes
> 
>
> 1. TLB optimisation patches 1-3?	 	Patches  1-3

I assume you mean simply reshuffling 33-35 as 1-3.

> 2. Stats for migration?				Patches  4-6
> 3. Common NUMA infrastructure?			Patches  7-21
> 4. Basic fault-driven policy, stats, ratelimits	Patches 22-35
> 
> Patches 36-43 are complete cabbage and should not be considered at this
> stage. It should be possible to build the placement policies and the
> scheduling decisions from schednuma, autonuma, some combination of the
> above or something completely different on top of patches 1-35.
> 
> Peter, Ingo, Andrea?

The patches 1-35 looks a great foundation so I think they'd be an
ideal candidate for a first upstream inclusion.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
