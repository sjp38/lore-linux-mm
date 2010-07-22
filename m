Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0E20A6B02A8
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 05:02:39 -0400 (EDT)
Date: Thu, 22 Jul 2010 17:02:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background
 writeback
Message-ID: <20100722090231.GA27947@localhost>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-8-git-send-email-mel@csn.ul.ie>
 <20100719142145.GD12510@infradead.org>
 <20100719144046.GR13117@csn.ul.ie>
 <20100722085210.GA26714@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722085210.GA26714@localhost>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Sorry, please ignore this hack, it's non sense..

> 
> --- linux-next.orig/mm/vmscan.c	2010-07-22 16:36:58.000000000 +0800
> +++ linux-next/mm/vmscan.c	2010-07-22 16:39:57.000000000 +0800
> @@ -1217,7 +1217,8 @@ static unsigned long shrink_inactive_lis
>  			count_vm_events(PGDEACTIVATE, nr_active);
>  
>  			nr_freed += shrink_page_list(&page_list, sc,
> -							PAGEOUT_IO_SYNC);
> +					priority < DEF_PRIORITY / 3 ?
> +					PAGEOUT_IO_SYNC : PAGEOUT_IO_ASYNC);
>  		}
>  
>  		nr_reclaimed += nr_freed;
 
Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
