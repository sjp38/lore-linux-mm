Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 15D196B02A3
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 11:06:47 -0400 (EDT)
Date: Wed, 21 Jul 2010 16:06:29 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/8] vmscan: Do not writeback filesystem pages in
	direct reclaim
Message-ID: <20100721150629.GB13117@csn.ul.ie>
References: <1279545090-19169-5-git-send-email-mel@csn.ul.ie> <20100719221420.GA16031@cmpxchg.org> <20100720134555.GU13117@csn.ul.ie> <20100720220218.GE16031@cmpxchg.org> <20100721115250.GX13117@csn.ul.ie> <20100721130435.GH16031@cmpxchg.org> <20100721133857.GY13117@csn.ul.ie> <20100721142819.GA10480@cmpxchg.org> <20100721143118.GA13117@csn.ul.ie> <20100721143955.GB10480@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100721143955.GB10480@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 21, 2010 at 04:39:56PM +0200, Johannes Weiner wrote:
> On Wed, Jul 21, 2010 at 03:31:19PM +0100, Mel Gorman wrote:
> > On Wed, Jul 21, 2010 at 04:28:44PM +0200, Johannes Weiner wrote:
> > > On Wed, Jul 21, 2010 at 02:38:57PM +0100, Mel Gorman wrote:
> > > > @@ -858,7 +872,7 @@ keep:
> > > >  
> > > >  	free_page_list(&free_pages);
> > > >  
> > > > -	list_splice(&ret_pages, page_list);
> > > 
> > > This will lose all retry pages forever, I think.
> > > 
> > 
> > Above this is
> > 
> > while (!list_empty(page_list)) {
> > 	...
> > }
> > 
> > page_list should be empty and keep_locked is putting the pages on ret_pages
> > already so I think it's ok.
> 
> But ret_pages is function-local.  Putting them back on the then-empty
> page_list is to give them back to the caller, otherwise they are lost
> in a dead stack slot.
> 

Bah, you're right, it is repaired now. /me slaps self. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
