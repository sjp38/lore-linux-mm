Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 688596B0221
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 07:45:44 -0400 (EDT)
Date: Tue, 15 Jun 2010 12:45:24 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/12] Avoid overflowing of stack during page reclaim V2
Message-ID: <20100615114523.GF26788@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <20100614151011.GA24948@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100614151011.GA24948@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 14, 2010 at 11:10:11AM -0400, Christoph Hellwig wrote:
> On Mon, Jun 14, 2010 at 12:17:41PM +0100, Mel Gorman wrote:
> > This is a merging of two series - the first of which reduces stack usage
> > in page reclaim and the second which writes contiguous pages during reclaim
> > and avoids writeback in direct reclaimers.
> 
> This stuff looks good to me from the filesystem POV.
> 
> You might want to throw in a follow on patch to remove the PF_MEMALLOC
> checks from the various ->writepage methods.
> 

Will do, thanks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
