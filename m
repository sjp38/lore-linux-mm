Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AC0C06B02A6
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 12:30:10 -0400 (EDT)
Received: by pxi7 with SMTP id 7so1183715pxi.14
        for <linux-mm@kvack.org>; Wed, 28 Jul 2010 09:30:04 -0700 (PDT)
Date: Thu, 29 Jul 2010 01:29:53 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] vmscan: remove wait_on_page_writeback() from pageout()
Message-ID: <20100728162953.GB5401@barrios-desktop>
References: <20100728071705.GA22964@localhost>
 <AANLkTimaj6+MzY5Aa_xqi75zKy1fDOQV5QiQjdX8jgm7@mail.gmail.com>
 <20100728084654.GA26776@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100728084654.GA26776@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 28, 2010 at 04:46:54PM +0800, Wu Fengguang wrote:
> And the wait page-by-page behavior of pageout(SYNC) will lead to very
> long stall time if running into some range of dirty pages. So it's bad
> idea anyway to call wait_on_page_writeback() inside pageout().

Although we remove it in pageout, shrink_page_list still has it.
So it would result in long stall. And it is for lumpy reclaim which 
means it's a trade-off, I think. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
