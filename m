Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 690C46B003C
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 10:59:46 -0400 (EDT)
Date: Thu, 27 Jun 2013 16:59:39 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/6] Basic scheduler support for automatic NUMA balancing
Message-ID: <20130627145939.GW28407@twins.programming.kicks-ass.net>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372257487-9749-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 26, 2013 at 03:37:59PM +0100, Mel Gorman wrote:
> It's several months overdue and everything was quiet after 3.8 came out
> but I recently had a chance to revisit automatic NUMA balancing for a few
> days. I looked at basic scheduler integration resulting in the following
> small series. Much of the following is heavily based on the numacore series
> which in itself takes part of the autonuma series from back in November. In
> particular it borrows heavily from Peter Ziljstra's work in "sched, numa,
> mm: Add adaptive NUMA affinity support" but deviates too much to preserve
> Signed-off-bys. As before, if the relevant authors are ok with it I'll
> add Signed-off-bys (or add them yourselves if you pick the patches up).
> 
> This is still far from complete and there are known performance gaps between
> this and manual binding where possible and depending on the workload between
> it and interleaving when hard bindings are not an option.  As before,
> the intention is not to complete the work but to incrementally improve
> mainline and preserve bisectability for any bug reports that crop up. This
> will allow us to validate each step and keep reviewer stress to a minimum.

Yah..

Except for the few things I've already replied to; and a very strong
urge to run:

  sed -e 's/NUMA_BALANCE/SCHED_NUMA/g' -e 's/numa_balance/sched_numa/'

on both the tree and these patches I'm all for merging this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
