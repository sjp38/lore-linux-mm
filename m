Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 7FBB26B0033
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 05:26:29 -0400 (EDT)
Date: Tue, 30 Jul 2013 11:26:22 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 00/10] Improve numa scheduling by consolidating tasks
Message-ID: <20130730092622.GN3008@twins.programming.kicks-ass.net>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
 <20130730081755.GF3008@twins.programming.kicks-ass.net>
 <20130730082001.GG3008@twins.programming.kicks-ass.net>
 <20130730090345.GA22201@linux.vnet.ibm.com>
 <20130730091021.GM3008@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130730091021.GM3008@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Jul 30, 2013 at 11:10:21AM +0200, Peter Zijlstra wrote:
> On Tue, Jul 30, 2013 at 02:33:45PM +0530, Srikar Dronamraju wrote:
> > * Peter Zijlstra <peterz@infradead.org> [2013-07-30 10:20:01]:
> > 
> > > On Tue, Jul 30, 2013 at 10:17:55AM +0200, Peter Zijlstra wrote:
> > > > On Tue, Jul 30, 2013 at 01:18:15PM +0530, Srikar Dronamraju wrote:
> > > > > Here is an approach that looks to consolidate workloads across nodes.
> > > > > This results in much improved performance. Again I would assume this work
> > > > > is complementary to Mel's work with numa faulting.
> > > > 
> > > > I highly dislike the use of task weights here. It seems completely
> > > > unrelated to the problem at hand.
> > > 
> > > I also don't particularly like the fact that it's purely process based.
> > > The faults information we have gives much richer task relations.
> > > 
> > 
> > With just pure fault information based approach, I am not seeing any
> > major improvement in tasks/memory consolidation. I still see memory
> > spread across different nodes and tasks getting ping-ponged to different
> > nodes. And if there are multiple unrelated processes, then we see a mix
> > of tasks of different processes in each of the node.
> 
> The fault thing isn't finished. Mel explicitly said it doesn't yet have
> inter-task relations. And you run everything in a VM which is like a big
> nasty mangler for anything sane.

Also, the last time you posted this, I already said that if you'd use
the faults data to do grouping you'd get similar reseults. Task weight
is a completely unrelated and random measure. I think you even conceded
this.

So I really don't get why you're still using task weight for this.

Also, Ingo already showed that you can get task grouping from the fault
information itself, no need to use mm information to do this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
