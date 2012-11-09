Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id CEC7C6B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 09:43:12 -0500 (EST)
Date: Fri, 9 Nov 2012 15:42:57 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 00/19] Foundation for automatic NUMA balancing
Message-ID: <20121109144257.GA26870@redhat.com>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1352193295-26815-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Mel,

On Tue, Nov 06, 2012 at 09:14:36AM +0000, Mel Gorman wrote:
> This series addresses part of the integration and sharing problem by
> implementing a foundation that either the policy for schednuma or autonuma
> can be rebased on. The actual policy it implements is a very stupid
> greedy policy called "Migrate On Reference Of pte_numa Node (MORON)".
> While stupid, it can be faster than the vanilla kernel and the expectation
> is that any clever policy should be able to beat MORON. The advantage is
> that it still defines how the policy needs to hook into the core code --
> scheduler and mempolicy mostly so many optimisations (s uch as native THP
> migration) can be shared between different policy implementations.

I haven't had much time to look into it yet, because I've been
attending KVM Forum the last few days, but this foundation looks ok
with me as a starting base and I ack it for merging it upstream. I'll
try to rebase on top of this and send you some patches.

> Patch 14 adds a MPOL_MF_LAZY mempolicy that an interested application can use.
> 	On the next reference the memory should be migrated to the node that
> 	references the memory.

This approach of starting with a stripped down foundation won't allow
for easy backportability anyway, so merging the userland API at the
first step shouldn't provide any benefit for the work that is ahead of
us. I would leave this for later and not part of the foundation.

All we need is a failsafe runtime and boot time turn off knob, just in
case.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
