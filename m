Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 3A6CE6B0039
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 11:51:57 -0400 (EDT)
Date: Thu, 1 Aug 2013 16:51:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/18] Basic scheduler support for automatic NUMA
 balancing V5
Message-ID: <20130801155151.GH2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <20130725103620.GM27075@twins.programming.kicks-ass.net>
 <20130731103052.GR2296@suse.de>
 <20130731104814.GA3008@twins.programming.kicks-ass.net>
 <20130731115719.GT2296@suse.de>
 <20130731153018.GD3008@twins.programming.kicks-ass.net>
 <20130731161141.GX2296@suse.de>
 <20130731163903.GG3008@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130731163903.GG3008@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 31, 2013 at 06:39:03PM +0200, Peter Zijlstra wrote:
> On Wed, Jul 31, 2013 at 05:11:41PM +0100, Mel Gorman wrote:
> > RSS was another option it felt as arbitrary as a plain delay.
> 
> Right, it would avoid 'small' programs getting scanning done with the
> rationale that their cost isn't that large since they don't have much
> memory to begin with.
> 

Yeah, but it's not necessarily true. Whatever value we pick there can be
an openmp process that fits in there.

> The same can be said for tasks that don't run much -- irrespective of
> how much absolute runtime they've gathered.
> 
> Is there any other group of tasks that we do not want to scan?
> 

strcmp(p->comm, ....)


> Maybe if we can list all the various exclusions we can get to a proper
> quantifier that way.
> 
> So far we've got:
> 
>  - doesn't run long
>  - doesn't run much
>  - doesn't have much memory
> 

- does not have sysV shm sections

> > Should I revert 5bca23035391928c4c7301835accca3551b96cc2 with an
> > explanation that it potentially is completely useless in the purely
> > multi-process shared case?
> 
> Yeah I suppose so..

Will do.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
