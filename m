Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7D76B0055
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 12:10:05 -0400 (EDT)
Date: Thu, 6 Aug 2009 17:10:06 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/4] Add some trace events for the page allocator v4
Message-ID: <20090806161005.GD6915@csn.ul.ie>
References: <1249574827-18745-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1249574827-18745-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: riel@redhat.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 06, 2009 at 05:07:01PM +0100, Mel Gorman wrote:
> This is V4 of a patchset to add some trace points for the page allocator. The
> largest changes in this version is performance improvements and expansion
> of the post-processing script as well as some documentation. There were minor changes
> elsewhere that are described in the changelog.
> 

Cack, the subject should be 0/6 of course, not 0/4

> <SNIP>
> 
>  Documentation/trace/events-kmem.txt                |  107 ++++++
>  .../postprocess/trace-pagealloc-postprocess.pl     |  356 ++++++++++++++++++++
>  Documentation/trace/tracepoint-analysis.txt        |  327 ++++++++++++++++++
>  include/trace/events/kmem.h                        |  177 ++++++++++
>  mm/page_alloc.c                                    |   16 +-
>  5 files changed, 982 insertions(+), 1 deletions(-)
>  create mode 100644 Documentation/trace/events-kmem.txt
>  create mode 100755 Documentation/trace/postprocess/trace-pagealloc-postprocess.pl
>  create mode 100644 Documentation/trace/tracepoint-analysis.txt
> 
> Mel Gorman (6):
>   tracing, page-allocator: Add trace events for page allocation and
>     page freeing
>   tracing, page-allocator: Add trace events for anti-fragmentation
>     falling back to other migratetypes
>   tracing, page-allocator: Add trace event for page traffic related to
>     the buddy lists
>   tracing, page-allocator: Add a postprocessing script for
>     page-allocator-related ftrace events
>   tracing, documentation: Add a document describing how to do some
>     performance analysis with tracepoints
>   tracing, documentation: Add a document on the kmem tracepoints
> 

Similarly, I should have stripped this junk away before tending. The
real diffstat is below. Sorry

>  Documentation/trace/events-kmem.txt                |  107 ++++++
>  .../postprocess/trace-pagealloc-postprocess.pl     |  356 ++++++++++++++++++++
>  Documentation/trace/tracepoint-analysis.txt        |  327 ++++++++++++++++++
>  include/trace/events/kmem.h                        |  177 ++++++++++
>  mm/page_alloc.c                                    |   15 +-
>  5 files changed, 981 insertions(+), 1 deletions(-)
>  create mode 100644 Documentation/trace/events-kmem.txt
>  create mode 100755 Documentation/trace/postprocess/trace-pagealloc-postprocess.pl
>  create mode 100644 Documentation/trace/tracepoint-analysis.txt
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
