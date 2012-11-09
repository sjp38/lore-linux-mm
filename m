Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id E1AE46B004D
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 03:49:45 -0500 (EST)
Message-ID: <509CC42E.1040200@redhat.com>
Date: Fri, 09 Nov 2012 03:51:58 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/31] numa/core patches
References: <20121025121617.617683848@chello.nl> <20121030122032.GC3888@suse.de>
In-Reply-To: <20121030122032.GC3888@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On 10/30/2012 08:20 AM, Mel Gorman wrote:
> On Thu, Oct 25, 2012 at 02:16:17PM +0200, Peter Zijlstra wrote:
>> Hi all,
>>
>> Here's a re-post of the NUMA scheduling and migration improvement
>> patches that we are working on. These include techniques from
>> AutoNUMA and the sched/numa tree and form a unified basis - it
>> has got all the bits that look good and mergeable.
>>
>
> Thanks for the repost. I have not even started a review yet as I was
> travelling and just online today. It will be another day or two before I can
> start but I was at least able to do a comparison test between autonuma and
> schednuma today to see which actually performs the best. Even without the
> review I was able to stick on similar vmstats as was applied to autonuma
> to give a rough estimate of the relative overhead of both implementations.

Peter, Ingo,

do you have any comments on the performance measurements
by Mel?

Any ideas on how to fix sched/numa or numa/core?

At this point, I suspect the easiest way forward might be
to merge the basic infrastructure from Mel's combined
tree (in -mm? in -tip?), so we can experiment with different
NUMA placement policies on top.

That way we can do apples to apples comparison of the
policies, and figure out what works best, and why.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
