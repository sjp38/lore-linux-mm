Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8BCF96B005D
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 19:32:51 -0400 (EDT)
Date: Wed, 12 Aug 2009 08:31:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/6] tracing, page-allocator: Add trace event for page traffic related to the buddy lists
In-Reply-To: <1249918915-16061-4-git-send-email-mel@csn.ul.ie>
References: <1249918915-16061-1-git-send-email-mel@csn.ul.ie> <1249918915-16061-4-git-send-email-mel@csn.ul.ie>
Message-Id: <20090811164030.9AE2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, Li Ming Chun <macli@brc.ubc.ca>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The page allocation trace event reports that a page was successfully allocated
> but it does not specify where it came from. When analysing performance,
> it can be important to distinguish between pages coming from the per-cpu
> allocator and pages coming from the buddy lists as the latter requires the
> zone lock to the taken and more data structures to be examined.
> 
> This patch adds a trace event for __rmqueue reporting when a page is being
> allocated from the buddy lists. It distinguishes between being called
> to refill the per-cpu lists or whether it is a high-order allocation.
> Similarly, this patch adds an event to catch when the PCP lists are being
> drained a little and pages are going back to the buddy lists.
> 
> This is trickier to draw conclusions from but high activity on those
> events could explain why there were a large number of cache misses on a
> page-allocator-intensive workload. The coalescing and splitting of buddies
> involves a lot of writing of page metadata and cache line bounces not to
> mention the acquisition of an interrupt-safe lock necessary to enter this
> path.

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
