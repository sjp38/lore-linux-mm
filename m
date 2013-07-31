Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id A77D76B0032
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 03:54:54 -0400 (EDT)
Date: Wed, 31 Jul 2013 08:54:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/18] sched: Track NUMA hinting faults on per-node basis
Message-ID: <20130731075451.GE2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-3-git-send-email-mgorman@suse.de>
 <20130729101059.GC3008@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130729101059.GC3008@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 29, 2013 at 12:10:59PM +0200, Peter Zijlstra wrote:
> On Mon, Jul 15, 2013 at 04:20:04PM +0100, Mel Gorman wrote:
> > +++ b/kernel/sched/fair.c
> > @@ -815,7 +815,14 @@ void task_numa_fault(int node, int pages, bool migrated)
> >  	if (!sched_feat_numa(NUMA))
> >  		return;
> >  
> > -	/* FIXME: Allocate task-specific structure for placement policy here */
> > +	/* Allocate buffer to track faults on a per-node basis */
> > +	if (unlikely(!p->numa_faults)) {
> > +		int size = sizeof(*p->numa_faults) * nr_node_ids;
> > +
> > +		p->numa_faults = kzalloc(size, GFP_KERNEL);
> 
> We should probably stick a __GFP_NOWARN in there.
> 

Yes.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
