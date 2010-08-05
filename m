Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6773B60020C
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 11:26:53 -0400 (EDT)
Message-ID: <4C5AD823.8020004@redhat.com>
Date: Thu, 05 Aug 2010 11:26:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/7] vmscan: synchrounous lumpy reclaim use lock_page()
 instead trylock_page()
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com> <20100805151304.31C0.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100805151304.31C0.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On 08/05/2010 02:13 AM, KOSAKI Motohiro wrote:
> When synchrounous lumpy reclaim, there is no reason to give up to
> reclaim pages even if page is locked. We use lock_page() instead
> trylock_page() in this case.
>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
