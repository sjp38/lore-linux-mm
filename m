Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 4514C6B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 16:58:50 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 10/31] mm/mpol: Remove NUMA_INTERLEAVE_HIT
References: <20121025121617.617683848@chello.nl>
	<20121025124833.247790041@chello.nl>
Date: Thu, 25 Oct 2012 13:58:48 -0700
In-Reply-To: <20121025124833.247790041@chello.nl> (Peter Zijlstra's message of
	"Thu, 25 Oct 2012 14:16:27 +0200")
Message-ID: <m2txtiqnef.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Ingo Molnar <mingo@kernel.org>

Peter Zijlstra <a.p.zijlstra@chello.nl> writes:

> Since the NUMA_INTERLEAVE_HIT statistic is useless on its own; it wants
> to be compared to either a total of interleave allocations or to a miss
> count, remove it.

NACK, as already posted several times.

This breaks the numactl test suite, which is the only way currently to
test interleaving.

Please don't ignore review feedback.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
