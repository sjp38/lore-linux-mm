Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 6CBB36B0073
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 10:48:31 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so10668744ghr.14
        for <linux-mm@kvack.org>; Fri, 06 Jul 2012 07:48:30 -0700 (PDT)
Date: Fri, 6 Jul 2012 23:48:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH 02/26] mm, mpol: Remove NUMA_INTERLEAVE_HIT
Message-ID: <20120706144820.GC2328@barrios>
References: <20120316144028.036474157@chello.nl>
 <20120316144240.234456258@chello.nl>
 <20120706103255.GA23680@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120706103255.GA23680@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Hannes,

I alreay sent a patch about that but didn't have a reply from
Peter/Ingo.

https://lkml.org/lkml/2012/7/3/477

On Fri, Jul 06, 2012 at 12:32:55PM +0200, Johannes Weiner wrote:
> Hi Peter,
> 
> On Fri, Mar 16, 2012 at 03:40:30PM +0100, Peter Zijlstra wrote:
> > Since the NUMA_INTERLEAVE_HIT statistic is useless on its own; it wants
> > to be compared to either a total of interleave allocations or to a miss
> > count, remove it.
> > 
> > Fixing it would be possible, but since we've gone years without these
> > statistics I figure we can continue that way.
> > 
> > This cleans up some of the weird MPOL_INTERLEAVE allocation exceptions.
> > 
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > ---
> 
> > @@ -111,7 +111,6 @@ enum zone_stat_item {
> >  	NUMA_HIT,		/* allocated in intended node */
> >  	NUMA_MISS,		/* allocated in non intended node */
> >  	NUMA_FOREIGN,		/* was intended here, hit elsewhere */
> > -	NUMA_INTERLEAVE_HIT,	/* interleaver preferred this zone */
> >  	NUMA_LOCAL,		/* allocation from local node */
> >  	NUMA_OTHER,		/* allocation from other node */
> >  #endif
> 
> Can you guys include/fold this?
> 
> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: fix vmstat names-values off-by-one
> 
> "mm/mpol: Remove NUMA_INTERLEAVE_HIT" removed the NUMA_INTERLEAVE_HIT
> item from the zone_stat_item enum, but left the corresponding name
> string for it in the vmstat_text array.  As a result, all counters
> that follow it have their name offset by one from their value.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmstat.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 1bbbbd9..e4db312 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -717,7 +717,6 @@ const char * const vmstat_text[] = {
>  	"numa_hit",
>  	"numa_miss",
>  	"numa_foreign",
> -	"numa_interleave",
>  	"numa_local",
>  	"numa_other",
>  #endif
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
