Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4D18F8D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 06:27:02 -0400 (EDT)
Date: Fri, 29 Oct 2010 11:26:46 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 09/10] vmscan: Do not writeback filesystem pages in
	direct reclaim
Message-ID: <20101029102646.GI4896@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie> <1283770053-18833-10-git-send-email-mel@csn.ul.ie> <20101028215046.GA15586@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101028215046.GA15586@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 28, 2010 at 05:50:46PM -0400, Christoph Hellwig wrote:
> Looks like this once again didn't get merged for 2.6.37.  Any reason
> for that?
> 

There are still concerns as to whether this is a good idea or or whether we
are papering over the fact that there are too many dirty pages at the end
of the LRU. The tracepoints necessary to track the dirty pages encountered
went in this cycle as well as some writeback and congestion-waiting changes.
I was waiting for some of the writeback churn to die down before
revisiting this. The ideal point to reach is "we hardly ever encounter
dirty pages so disabling direct writeback has no impact".

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
