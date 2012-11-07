Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 25CEE6B0062
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 05:49:46 -0500 (EST)
Date: Wed, 7 Nov 2012 10:49:40 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 15/19] mm: numa: Add fault driven placement and migration
Message-ID: <20121107104940.GU8218@suse.de>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <1352193295-26815-16-git-send-email-mgorman@suse.de>
 <509967D9.7050706@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <509967D9.7050706@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 06, 2012 at 02:41:13PM -0500, Rik van Riel wrote:
> On 11/06/2012 04:14 AM, Mel Gorman wrote:
> >From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> >
> >NOTE: This patch is based on "sched, numa, mm: Add fault driven
> >	placement and migration policy" but as it throws away all the policy
> >	to just leave a basic foundation I had to drop the signed-offs-by.
> >
> >This patch creates a bare-bones method for setting PTEs pte_numa in the
> >context of the scheduler that when faulted later will be faulted onto the
> >node the CPU is running on.  In itself this does nothing useful but any
> >placement policy will fundamentally depend on receiving hints on placement
> >from fault context and doing something intelligent about it.
> >
> >Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Excellent basis for implementing a smarter NUMA
> policy.
> 
> Not sure if such a policy should be implemented
> as a replacement for this patch, or on top of it...
> 

I'm expecting on top of it. As a POC, I'm looking at implementing the CPU
Follows Memory algorithm (mostly from autonuma) on top of this but using the
home-node logic from schednuma to handle how processes get scheduled. MORON
will need to relax to take the home node into account to avoid fighting
the home-node decisions. task_numa_fault() determines if the home node
needs to change based on statistics it gathers from faults. So far I am
keeping within the framework but it is still a WIP.

> Either way, thank you for cleaning up all of the
> NUMA base code, while I was away at conferences
> and stuck in airports :)
> 

My pleasure. Thanks a lot for reviewing this!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
