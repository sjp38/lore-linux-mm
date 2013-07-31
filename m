Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id B91466B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 05:49:19 -0400 (EDT)
Date: Wed, 31 Jul 2013 10:49:14 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 16/18] sched: Avoid overloading CPUs on a preferred NUMA
 node
Message-ID: <20130731094914.GN2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-17-git-send-email-mgorman@suse.de>
 <20130717105423.GC17211@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130717105423.GC17211@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 17, 2013 at 12:54:23PM +0200, Peter Zijlstra wrote:
> On Mon, Jul 15, 2013 at 04:20:18PM +0100, Mel Gorman wrote:
> > +static long effective_load(struct task_group *tg, int cpu, long wl, long wg);
> 
> And this

> -- which suggests you always build with cgroups enabled?

Yes, the test kernel configuration is one taken from an opensuse kernel
with a bunch of unnecessary drivers removed.

> I generally
> try and disable all that nonsense when building new stuff, the scheduler is a
> 'lot' simpler that way. Once that works make it 'interesting' again.
> 

Understood. I'll disable CONFIG_CGROUPS in the next round of testing which
will be based against 3.11-rc3 once I plough this set of feedback.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
