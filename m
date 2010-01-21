Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E585E6B00A3
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 05:11:27 -0500 (EST)
Date: Thu, 21 Jan 2010 10:11:12 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC-PATCH 0/7] Memory Compaction v1
Message-ID: <20100121101112.GH5154@csn.ul.ie>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie> <20100121115636.73BA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100121115636.73BA.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 21, 2010 at 12:12:11PM +0900, KOSAKI Motohiro wrote:
> Hi Mel,
> 
> Sorry, I haven't read this patch at all.
> 
> > The time differences are marginal but bear in mind that this is an ideal
> > case of mostly unmapped buffer pages. On nice set of results is between
> > allocations 13-18 where no pages were reclaimed, some compaction occured
> > and 300 huge pages were allocated in 0.16 seconds. Furthermore, compaction
> > allocated a high higher percentage of memory (91% of RAM as huge pages).
> > 
> > The downside appears to be that the compaction kernel reclaimed even more
> > pages than the vanilla kernel. However, take the cut-off point of 880 pages
> > that both kernels succeeded. The vanilla kernel had reclaimed 105132 pages
> > at that point. The kernel with compaction had reclaimed 59071, less than
> > half of what the vanilla kernel reclaimed. i.e. the bulk of pages reclaimed
> > with the compaction kernel were to get from 87% of memory allocated to 91%
> > as huge pages.
> > 
> > These results would appear to be an encouraging enough start.
> > 
> > Comments?
> 
> I think "Total pages reclaimed" increasing is not good thing ;)

First, I made a mistake in the patch. With the bug fixed, they're
reduced. See the post later in the thread
http://lkml.org/lkml/2010/1/6/215

> Honestly, I haven't understand why your patch increase reclaimed and
> the exactly meaning of the your tool's rclm field.
> 
> Can you share your mesurement script? May I run the same test?
> 

Unfortunately at the moment it's part of a mini-testgrid setup I run out
of the house. It doesn't lend itself to being stand-alone. I'll break it
out as part of the next release.

> I like this patch, but I don't like increasing reclaim. I'd like to know
> this patch require any vmscan change and/or its change mitigate the issue.
> 

With the bug repaired, reclaims go from 105132 to 45935 with more huge
pages allocated so right now, no special action is required.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
