Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 92E666B0070
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 16:28:01 -0500 (EST)
Date: Thu, 15 Nov 2012 21:27:54 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Benchmark results: "Enhanced NUMA scheduling with adaptive
 affinity"
Message-ID: <20121115212754.GW8218@suse.de>
References: <20121112160451.189715188@chello.nl>
 <20121112184833.GA17503@gmail.com>
 <20121115100805.GS8218@suse.de>
 <50A53A00.5060904@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50A53A00.5060904@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>

On Thu, Nov 15, 2012 at 01:52:48PM -0500, Rik van Riel wrote:
> On 11/15/2012 05:08 AM, Mel Gorman wrote:
> >On Mon, Nov 12, 2012 at 07:48:33PM +0100, Ingo Molnar wrote:
> >>Here are some preliminary performance figures, comparing the
> >>vanilla kernel against the CONFIG_SCHED_NUMA=y kernel.
> >>
> >>Java SPEC benchmark, running on a 4 node, 64 GB, 32-way server
> >>system (higher numbers are better):
> >
> >Ok, I used a 4-node, 64G, 48-way server system. We have different CPUs
> >but the same number of nodes. In case it makes a difference each of my
> >machines nodes are the same size.
> 
> Mel, do you have info on exactly what model system you
> were running these tests on?
> 

Dell PowerEdge R810
CPU Intel(R) Xeon(R) CPU E7- 4807 @ 1.87GHz
RAM 64G
Single disk

4 JVMs, one per node
SpecJBB configured to run in multi JVM configuration
No special binding
JVM switches -Xmx12882m

All run through an unreleased version of MMTests. I'll make a release of
mmtests either tomorrow or Monday when I get the chance.

> Obviously your results are very different from the ones
> that Ingo saw. It would be most helpful if we could find
> a similar system in one of the Red Hat labs, so Ingo can
> play around with it and see what's going on :)
> 

Also compare how the benchmark is actually configured and which figures
he's reporting. I'm posting up the throughput for each warehouse and the
peak throughput.

It is possible Ingo's figures are based on other patches in the tip tree
that have not been identified. If that's the case it's interesting in
itself.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
