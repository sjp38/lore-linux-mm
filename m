Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1483A6B004D
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 14:56:59 -0400 (EDT)
Date: Mon, 10 Aug 2009 20:56:33 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/6] Add some trace events for the page allocator v6
Message-ID: <20090810185633.GA1130@elte.hu>
References: <1249918915-16061-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1249918915-16061-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, Li Ming Chun <macli@brc.ubc.ca>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* Mel Gorman <mel@csn.ul.ie> wrote:

> This is V6 of a patchset to add some tracepoints of interest when analysing
> the page allocator. The only changes since the last revision were to fix a
> minor error in the post-processing script and to add a reviewed-by to one
> of the patches.
> 
> Can we get a yey/nay on whether these should be merged or not?

It's up to Andrew - from an instrumentation POV it all looks fine to 
me:

   Reviewed-by: Ingo Molnar <mingo@elte.hu>

With the highlight of the patchset being the very low cross section 
it has to regular MM code/hacking:

>  mm/page_alloc.c                                    |   13 +-

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
