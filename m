Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 58C01600815
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 10:40:44 -0400 (EDT)
Date: Tue, 27 Jul 2010 15:40:26 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 8/8] vmscan: Kick flusher threads to clean pages when
	reclaim is encountering dirty pages
Message-ID: <20100727144026.GC5300@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-9-git-send-email-mel@csn.ul.ie> <20100726072832.GB13076@localhost> <20100726092616.GG5300@csn.ul.ie> <20100726112709.GB6284@localhost> <20100726125717.GS5300@csn.ul.ie> <20100726131008.GE11947@localhost> <20100727133513.GZ5300@csn.ul.ie> <20100727142412.GA4771@localhost> <20100727143423.GA5057@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100727143423.GA5057@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 27, 2010 at 10:34:23PM +0800, Wu Fengguang wrote:
> > If you plan to keep wakeup_flusher_threads(), a simpler form may be
> > sufficient, eg.
> > 
> >         laptop_mode ? 0 : (nr_dirty * 16)
> 
> This number is not sensitive because the writeback code may well round
> it up to some more IO efficient value (currently 4MB). AFAIK the
> nr_pages parameters passed by all existing flusher callers are some
> rule-of-thumb value, and far from being an exact number.
> 

I get that it's a rule of thumb but decided I would still pass in some value
related to nr_dirty that was bounded in some manner.  Currently, that bound
is 4MB but maybe it should have been bound to MAX_WRITEBACK_PAGES (which is
4MB for x86, but could be anything depending on the base page size).

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
