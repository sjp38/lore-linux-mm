Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F15DE6B0085
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 06:04:31 -0500 (EST)
Date: Thu, 2 Dec 2010 12:04:04 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/7] mm: vmscan: Convert lumpy_mode into a bitmask
Message-ID: <20101202110404.GW15564@cmpxchg.org>
References: <1290440635-30071-1-git-send-email-mel@csn.ul.ie>
 <1290440635-30071-3-git-send-email-mel@csn.ul.ie>
 <20101201102732.GK15564@cmpxchg.org>
 <20101201105029.GL13268@csn.ul.ie>
 <20101201112116.GR15564@cmpxchg.org>
 <20101201115633.GO13268@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101201115633.GO13268@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 01, 2010 at 11:56:33AM +0000, Mel Gorman wrote:
> On Wed, Dec 01, 2010 at 12:21:16PM +0100, Johannes Weiner wrote:
> > On Wed, Dec 01, 2010 at 10:50:29AM +0000, Mel Gorman wrote:
> > > On Wed, Dec 01, 2010 at 11:27:32AM +0100, Johannes Weiner wrote:
> > > > On Mon, Nov 22, 2010 at 03:43:50PM +0000, Mel Gorman wrote:
> > > > > + * lumpy_mode determines how the inactive list is shrunk
> > > > > + * LUMPY_MODE_SINGLE: Reclaim only order-0 pages
> > > > > + * LUMPY_MODE_ASYNC:  Do not block
> > > > > + * LUMPY_MODE_SYNC:   Allow blocking e.g. call wait_on_page_writeback
> > > > > + * LUMPY_MODE_CONTIGRECLAIM: For high-order allocations, take a reference
> > > > > + *			page from the LRU and reclaim all pages within a
> > > > > + *			naturally aligned range
> > > > 
> > > > I find those names terribly undescriptive.  It also strikes me as an
> > > > odd set of flags.  Can't this be represented with less?
> > > > 
> > > > 	LUMPY_MODE_ENABLED
> > > > 	LUMPY_MODE_SYNC
> > > > 
> > > > or, after the rename,
> > > > 
> > > > 	RECLAIM_MODE_HIGHER	= 1
> > > > 	RECLAIM_MODE_SYNC	= 2
> > > > 	RECLAIM_MODE_LUMPY	= 4
> > > 
> > > My problem with that is you have to infer what the behaviour is from what the
> > > flags "are not" as opposed to what they are. For example, !LUMPY_MODE_SYNC
> > > implies LUMPY_MODE_ASYNC instead of specifying LUMPY_MODE_ASYNC.
> > 
> > Sounds like a boolean value to me.  And it shows: you never actually
> > check for RECLAIM_MODE_ASYNC in the code, you just always set it to
> > the opposite of RECLAIM_MODE_SYNC - the flag which is actually read.
> 
> If you insist, the ASYNC flag can be dropped. I found it easier to flag
> what behaviour was expected than infer it.

It seems to be a matter of taste and nobody else seems to care, so I
am not insisting.  Let's just keep it as it is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
