Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id A30D06B0062
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 11:52:32 -0400 (EDT)
Date: Thu, 1 Nov 2012 15:52:26 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 30/31] sched, numa, mm: Implement slow start for working
 set sampling
Message-ID: <20121101155226.GE3888@suse.de>
References: <20121025121617.617683848@chello.nl>
 <20121025124834.720647725@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121025124834.720647725@chello.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Thu, Oct 25, 2012 at 02:16:47PM +0200, Peter Zijlstra wrote:
> Add a 1 second delay before starting to scan the working set of
> a task and starting to balance it amongst nodes.
> 
> [ note that before the constant per task WSS sampling rate patch
>   the initial scan would happen much later still, in effect that
>   patch caused this regression. ]
> 
> The theory is that short-run tasks benefit very little from NUMA
> placement: they come and go, and they better stick to the node
> they were started on. As tasks mature and rebalance to other CPUs
> and nodes, so does their NUMA placement have to change and so
> does it start to matter more and more.
> 

Yeah, ok. It's done by wall time, right? Should it be CPU time in case
it spent the first second asleep?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
