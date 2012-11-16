Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 527B16B0096
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:26:02 -0500 (EST)
Date: Fri, 16 Nov 2012 16:25:56 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Benchmark results: "Enhanced NUMA scheduling with adaptive
 affinity"
Message-ID: <20121116162556.GD8218@suse.de>
References: <20121112160451.189715188@chello.nl>
 <20121112184833.GA17503@gmail.com>
 <20121115100805.GS8218@suse.de>
 <20121116155626.GA4271@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121116155626.GA4271@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>

On Fri, Nov 16, 2012 at 04:56:26PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > It is important to know how this was configured. I was running 
> > one JVM per node and the JVMs were sized that they should fit 
> > in the node. [...]
> 
> That is not what I tested: as I described it in the mail I 
> tested 32 warehouses: i.e. spanning the whole system.
> 

Good (sortof) because that's my preferred explanation as to why we are
seeing different results. Different machines and different kernels would
be a lot more problematic.

> You tested 4 parallel JVMs running one per node, right?
> 

4 parallel JVMs sized so they they could fit one-per-node. However, I did
*not* bind them to nodes because that would be completely pointless for
this type of test.

I've queued up another set of tests and added a single-JVM configuration
to the mix. The kernels will have debugging, lockstat enabled and will
be running two passes with the second pass running profiling so the
results will not be directly comparable. However, I'll keep a close eye
on the Single vs Multi JVM results.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
