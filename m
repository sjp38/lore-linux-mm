Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9CAA36B02AC
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 09:54:31 -0400 (EDT)
Received: by pwj7 with SMTP id 7so67914pwj.14
        for <linux-mm@kvack.org>; Thu, 05 Aug 2010 06:55:13 -0700 (PDT)
Date: Thu, 5 Aug 2010 22:55:04 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/7] vmscan: synchronous lumpy reclaim don't call
 congestion_wait()
Message-ID: <20100805135504.GA2985@barrios-desktop>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
 <20100805151229.31BD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100805151229.31BD.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 05, 2010 at 03:13:03PM +0900, KOSAKI Motohiro wrote:
> congestion_wait() mean "waiting quueue congestion is cleared".
> That said, if the system have plenty dirty pages and flusher thread push
> new request to IO queue conteniously, IO queue are not cleared
> congestion status for long time. thus, congestion_wait(HZ/10) become
> almostly equivalent schedule_timeout(HZ/10).
> 
> However, synchronous lumpy reclaim donesn't need this
> congestion_wait() at all. shrink_page_list(PAGEOUT_IO_SYNC) are
> using wait_on_page_writeback() and it provide sufficient waiting.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
