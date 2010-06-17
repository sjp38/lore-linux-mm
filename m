Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 062476B01AF
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 06:46:43 -0400 (EDT)
Date: Thu, 17 Jun 2010 11:46:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 09/12] vmscan: Setup pagevec as late as possible in
	shrink_page_list()
Message-ID: <20100617104623.GB25567@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <1276514273-27693-10-git-send-email-mel@csn.ul.ie> <20100616164801.9d3c0d99.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100616164801.9d3c0d99.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2010 at 04:48:01PM -0700, Andrew Morton wrote:
> On Mon, 14 Jun 2010 12:17:50 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > shrink_page_list() sets up a pagevec to release pages as according as they
> > are free. It uses significant amounts of stack on the pagevec. This
> > patch adds pages to be freed via pagevec to a linked list which is then
> > freed en-masse at the end. This avoids using stack in the main path that
> > potentially calls writepage().
> > 
> 
> hm, spose so.  I cen't see any trivial way to eliminate the local
> pagevec there.
> 
> > +	if (pagevec_count(&freed_pvec))
> > +		__pagevec_free(&freed_pvec);
> > ...
> > -	if (pagevec_count(&freed_pvec))
> > -		__pagevec_free(&freed_pvec);
> 
> That's an open-coded pagevec_free().
> 

Fair point, will correct. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
