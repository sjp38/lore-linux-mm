Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A3A1B6B005C
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 19:32:46 -0400 (EDT)
Date: Wed, 12 Aug 2009 08:31:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/6] tracing, page-allocator: Add trace events for page allocation and page freeing
In-Reply-To: <1249918915-16061-2-git-send-email-mel@csn.ul.ie>
References: <1249918915-16061-1-git-send-email-mel@csn.ul.ie> <1249918915-16061-2-git-send-email-mel@csn.ul.ie>
Message-Id: <20090811163939.9ADF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, Li Ming Chun <macli@brc.ubc.ca>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> This patch adds trace events for the allocation and freeing of pages,
> including the freeing of pagevecs.  Using the events, it will be known what
> struct page and pfns are being allocated and freed and what the call site
> was in many cases.
> 
> The page alloc tracepoints be used as an indicator as to whether the workload
> was heavily dependant on the page allocator or not. You can make a guess based
> on vmstat but you can't get a per-process breakdown. Depending on the call
> path, the call_site for page allocation may be __get_free_pages() instead
> of a useful callsite. Instead of passing down a return address similar to
> slab debugging, the user should enable the stacktrace and seg-addr options
> to get a proper stack trace.
> 
> The pagevec free tracepoint has a different usecase. It can be used to get
> a idea of how many pages are being dumped off the LRU and whether it is
> kswapd doing the work or a process doing direct reclaim.

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
