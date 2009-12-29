Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E6E6460021B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 23:05:38 -0500 (EST)
Received: by pxi2 with SMTP id 2so7540260pxi.11
        for <linux-mm@kvack.org>; Mon, 28 Dec 2009 20:05:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091228164451.A687.A69D9226@jp.fujitsu.com>
References: <20091228164451.A687.A69D9226@jp.fujitsu.com>
Date: Tue, 29 Dec 2009 13:05:37 +0900
Message-ID: <28c262360912282005x68315a62l7ffde637febc7646@mail.gmail.com>
Subject: Re: [PATCH 1/4] vmstat: remove zone->lock from walk_zones_in_node
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 28, 2009 at 4:47 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> The zone->lock is one of performance critical locks. Then, it shouldn't
> be hold for long time. Currently, we have four walk_zones_in_node()
> usage and almost use-case don't need to hold zone->lock.

I agree.

We can use walk_zone_in_node freely to show the information related to zone.

- frag_show_print : the number of free pages per order.
- pagetypeinfo_showfree_print : the number of free page per migration type
- pagetypeinfo_showblockcount_print : the number of pages in zone per
migration type
- zoneinfo_show_print : many info about zone.

Do we want to show exact value? No.
If we want it, it's not enough zone->lock only.
After all, All of things would be transient value.

>
> Thus, this patch move locking responsibility from walk_zones_in_node
> to its sub function. Also this patch kill unnecessary zone->lock taking.
>
> Cc: Mel Gorman <mel@csn.ul.ie>
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
