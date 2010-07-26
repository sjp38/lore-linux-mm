Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DBE516B024D
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 23:17:48 -0400 (EDT)
Date: Mon, 26 Jul 2010 11:17:44 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background
 writeback
Message-ID: <20100726031744.GA9489@localhost>
References: <20100723094515.GD5043@localhost>
 <20100723105719.GE5300@csn.ul.ie>
 <20100725192955.40D5.A69D9226@jp.fujitsu.com>
 <20100726030813.GA7668@localhost>
 <4C4CFCE9.8070303@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C4CFCE9.8070303@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 11:11:37AM +0800, Rik van Riel wrote:
> On 07/25/2010 11:08 PM, Wu Fengguang wrote:
> 
> > We do need some throttling under memory pressure. However stall time
> > more than 1s is not acceptable. A simple congestion_wait() may be
> > better, since it waits on _any_ IO completion (which will likely
> > release a set of PG_reclaim pages) rather than one specific IO
> > completion. This makes much smoother stall time.
> > wait_on_page_writeback() shall really be the last resort.
> > DEF_PRIORITY/3 means 1/16=6.25%, which is closer.
> 
> I agree with the max 1 second stall time, but 6.25% of
> memory could be an awful lot of pages to scan on a system
> with 1TB of memory :)

I totally ignored the 1TB systems out of this topic, because in such
systems, <PAGE_ALLOC_COSTLY_ORDER pages are easily available? :)

> Not sure what the best approach is, just pointing out
> that DEF_PRIORITY/3 may be too much for large systems...

What if DEF_PRIORITY/3 is used under PAGE_ALLOC_COSTLY_ORDER?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
