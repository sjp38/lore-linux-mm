Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3562D6B01B4
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 05:53:38 -0400 (EDT)
Date: Thu, 1 Jul 2010 10:53:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 01/14] vmscan: Fix mapping use after free
Message-ID: <20100701095318.GE31741@csn.ul.ie>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie> <1277811288-5195-2-git-send-email-mel@csn.ul.ie> <AANLkTilwzGf2rikXYAe4Evl41lqjk8voVSG4ICfAgUI1@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <AANLkTilwzGf2rikXYAe4Evl41lqjk8voVSG4ICfAgUI1@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 29, 2010 at 11:27:05PM +0900, Minchan Kim wrote:
> On Tue, Jun 29, 2010 at 8:34 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > From: Nick Piggin <npiggin@suse.de>
> >
> > Use lock_page_nosync in handle_write_error as after writepage we have no
> > reference to the mapping when taking the page lock.
> >
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> Trivial.
> Please modify description of the function if you have a next turn.
> "run sleeping lock_page()" -> "run sleeping lock_page_nosync"
> 

Fixed, thanks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
