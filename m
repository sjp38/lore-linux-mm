Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EEECE6B0033
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 11:59:51 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in __vm_enough_memory
References: <20111012160202.GA18666@sgi.com>
	<20111012120118.e948f40a.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1110121452220.31218@router.home>
	<20111013150642.GC6169@csn.ul.ie>
Date: Thu, 13 Oct 2011 08:59:49 -0700
In-Reply-To: <20111013150642.GC6169@csn.ul.ie> (Mel Gorman's message of "Thu,
	13 Oct 2011 16:06:42 +0100")
Message-ID: <m2hb3c287e.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@gentwo.org>, Andrew Morton <akpm@linux-foundation.org>, Dimitri Sivanich <sivanich@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Mel Gorman <mel@csn.ul.ie> writes:
>
> If vm_enough_memory is being heavily hit as well, it implies that this
> workload is mmap-intensive which is pretty inefficient in itself. I

Saw it with tmpfs originally. No need to be mmap intensive. Just
do lots of IOs on tmpfs.

> guess it would also apply to workloads that are malloc-intensive for
> large buffers but I'd expect the cache line bounces to only dominate if
> there was little or no computation on the resulting buffers.

I think you severly underestimate the costs of bouncing cache lines
on >2S.

> As a result, I wonder how realistic is this test workload and who useful
> fixing this problem is in general?

It's kind of bad if tmpfs doesn't scale.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
