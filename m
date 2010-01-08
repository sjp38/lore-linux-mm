Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9E160021B
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 18:03:19 -0500 (EST)
Date: Fri, 8 Jan 2010 15:02:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] page allocator: fix update NR_FREE_PAGES only as
 necessary
Message-Id: <20100108150251.4854d565.akpm@linux-foundation.org>
In-Reply-To: <20100104144332.96A2.A69D9226@jp.fujitsu.com>
References: <1262571730-2778-1-git-send-email-shijie8@gmail.com>
	<20100104122138.f54b7659.minchan.kim@barrios-desktop>
	<20100104144332.96A2.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon,  4 Jan 2010 14:52:36 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1227,10 +1227,10 @@ again:
>  		}
>  		spin_lock_irqsave(&zone->lock, flags);
>  		page = __rmqueue(zone, order, migratetype);
> -		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
>  		spin_unlock(&zone->lock);
>  		if (!page)
>  			goto failed;
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
>  	}
>  
>  	__count_zone_vm_events(PGALLOC, zone, 1 << order);

hm, yes, OK, obviously better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
