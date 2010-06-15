Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A24416B01B4
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 19:20:53 -0400 (EDT)
Date: Wed, 16 Jun 2010 09:20:09 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
Message-ID: <20100615232009.GT6590@dastard>
References: <1276514273-27693-12-git-send-email-mel@csn.ul.ie>
 <20100614231144.GG6590@dastard>
 <20100614162143.04783749.akpm@linux-foundation.org>
 <20100615003943.GK6590@dastard>
 <20100614183957.ad0cdb58.akpm@linux-foundation.org>
 <20100615032034.GR6590@dastard>
 <20100614211515.dd9880dc.akpm@linux-foundation.org>
 <20100615063643.GS6590@dastard>
 <20100615102822.GA4010@ioremap.net>
 <20100615105538.GI6138@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615105538.GI6138@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Evgeniy Polyakov <zbr@ioremap.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 08:55:38PM +1000, Nick Piggin wrote:
> On Tue, Jun 15, 2010 at 02:28:22PM +0400, Evgeniy Polyakov wrote:
> > On Tue, Jun 15, 2010 at 04:36:43PM +1000, Dave Chinner (david@fromorbit.com) wrote:
> > Per-mapping sorting will not do anything good in this case, even if
> > files were previously created in a good facion being placed closely and
> > so on, and only block layer will find a correlation between adjacent
> > blocks in different files. But with existing queue management it has
> > quite a small opportunity, and that's what I think Andrew is arguing
> > about.
> 
> The solution is not to sort pages on their way to be submitted either,
> really.
> 
> What I do in fsblock is to maintain a block-nr sorted tree of dirty
> blocks. This works nicely because fsblock dirty state is properly
> synchronized with page dirty state.

How does this work with delayed allocation where there is no block
number associated with the page until writeback calls the allocation
routine?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
