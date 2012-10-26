Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 8425E6B0071
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 03:59:25 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hq4so191098wib.2
        for <linux-mm@kvack.org>; Fri, 26 Oct 2012 00:59:23 -0700 (PDT)
Date: Fri, 26 Oct 2012 09:59:19 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 10/31] mm/mpol: Remove NUMA_INTERLEAVE_HIT
Message-ID: <20121026075919.GA18211@gmail.com>
References: <20121025121617.617683848@chello.nl>
 <20121025124833.247790041@chello.nl>
 <m2txtiqnef.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m2txtiqnef.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>


* Andi Kleen <andi@firstfloor.org> wrote:

> Peter Zijlstra <a.p.zijlstra@chello.nl> writes:
> 
> > Since the NUMA_INTERLEAVE_HIT statistic is useless on its 
> > own; it wants to be compared to either a total of interleave 
> > allocations or to a miss count, remove it.
> >
> > Fixing it would be possible, but since we've gone years 
> > without these statistics I figure we can continue that way.
> >
> > Also NUMA_HIT fully includes NUMA_INTERLEAVE_HIT so users 
> > might switch to using that.
> >
> > This cleans up some of the weird MPOL_INTERLEAVE allocation 
> > exceptions.
> 
> NACK, as already posted several times.
> 
> This breaks the numactl test suite, which is the only way 
> currently to test interleaving.

This patch is not essential to the NUMA series so I've zapped it 
from the patch queue and fixed up the roll-on effects.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
