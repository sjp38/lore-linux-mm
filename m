Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E38A06B007D
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 21:54:13 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C2sAZf008615
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 12 Jan 2010 11:54:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C33645DE60
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:54:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D14A45DE4D
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:54:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EB30F1DB803B
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:54:09 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A6A291DB8037
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:54:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] mm/page_alloc : relieve the zone->lock's pressure for allocation
In-Reply-To: <1263184634-15447-2-git-send-email-shijie8@gmail.com>
References: <1263184634-15447-1-git-send-email-shijie8@gmail.com> <1263184634-15447-2-git-send-email-shijie8@gmail.com>
Message-Id: <20100112115246.B395.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Jan 2010 11:54:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>   The __mod_zone_page_state() only require irq disabling,
> it does not require the zone's spinlock. So move it out of
> the guard region of the spinlock to relieve the pressure for
> allocation.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


> ---
>  mm/page_alloc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 23df1ed..00aa83a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -961,8 +961,8 @@ static int rmqueue_single(struct zone *zone, unsigned long count,
>  		set_page_private(page, migratetype);
>  		list = &page->lru;
>  	}
> -	__mod_zone_page_state(zone, NR_FREE_PAGES, -i);
>  	spin_unlock(&zone->lock);
> +	__mod_zone_page_state(zone, NR_FREE_PAGES, -i);
>  	return i;
>  }
>  
> -- 
> 1.6.5.2
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
