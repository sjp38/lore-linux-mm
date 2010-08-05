Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9A27F6B02B1
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 11:07:10 -0400 (EDT)
Received: by pzk33 with SMTP id 33so2859948pzk.14
        for <linux-mm@kvack.org>; Thu, 05 Aug 2010 08:08:22 -0700 (PDT)
Date: Fri, 6 Aug 2010 00:08:12 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 5/7] vmscan: kill dead code in shrink_inactive_list()
Message-ID: <20100805150812.GD2985@barrios-desktop>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
 <20100805151415.31C6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100805151415.31C6.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 05, 2010 at 03:14:47PM +0900, KOSAKI Motohiro wrote:
> When synchrounous lumy reclaim occur, page_list have gurantee to
> don't have active page because now page activation in shrink_page_list()
> always disable lumpy reclaim.
> 
> Then, This patch remove virtual dead code.
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
