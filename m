Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 966D66B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 00:31:50 -0400 (EDT)
Message-ID: <51F9E4A6.2090909@redhat.com>
Date: Thu, 01 Aug 2013 00:31:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 3/3] mm: page_alloc: fair zone allocator policy
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org> <1374267325-22865-4-git-send-email-hannes@cmpxchg.org> <20130801025636.GC19540@bbox>
In-Reply-To: <20130801025636.GC19540@bbox>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/31/2013 10:56 PM, Minchan Kim wrote:

> Yes, it's not really slow path because it could return to normal status
> without calling significant slow functions by reset batchcount of
> prepare_slowpath.
>
> I think it's tradeoff and I am biased your approach although we would
> lose a little performance because fair aging would recover the loss by
> fastpath's overhead. But who knows? Someone has a concern.
>
> So we should mention about such problems.

If the atomic operation in the fast path turns out to be a problem,
I suspect we may be able to fix it by using per-cpu counters, and
consolidating those every once in a while.

However, it may be good to see whether there is a problem in the
first place, before adding complexity.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
