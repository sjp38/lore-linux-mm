Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 587CB6B0032
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 06:36:35 -0400 (EDT)
Date: Tue, 16 Jul 2013 12:35:36 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 16/18] sched: Avoid overloading CPUs on a preferred NUMA
 node
Message-ID: <20130716103536.GI23818@dyad.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-17-git-send-email-mgorman@suse.de>
 <20130715200321.GN17211@twins.programming.kicks-ass.net>
 <20130716082342.GF5055@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130716082342.GF5055@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 16, 2013 at 09:23:42AM +0100, Mel Gorman wrote:
> On Mon, Jul 15, 2013 at 10:03:21PM +0200, Peter Zijlstra wrote:
> > On Mon, Jul 15, 2013 at 04:20:18PM +0100, Mel Gorman wrote:
> > > ---
> > > +	src_eff_load = 100 + (imbalance_pct - 100) / 2;
> > > +	src_eff_load *= power_of(src_cpu);
> > > +	src_eff_load *= src_load + effective_load(tg, src_cpu, -weight, -weight);
> > 
> > So did you try with this effective_load() term 'missing'?
> > 
> 
> Yes, it performed worse in tests. Looking at it, I figured that it would
> have to perform worse unless effective_load regularly returns negative
> values.

In this case it would return negative, seeing as we put a negative in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
