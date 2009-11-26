Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 22F546B0083
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 21:54:39 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAQ2sa9Q011808
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 26 Nov 2009 11:54:36 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 13C4A45DE51
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 11:54:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E58E145DE4C
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 11:54:35 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CBE591DB805A
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 11:54:35 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A31A1DB8040
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 11:54:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan : simplify code
In-Reply-To: <1259201628-26935-1-git-send-email-shijie8@gmail.com>
References: <1259201628-26935-1-git-send-email-shijie8@gmail.com>
Message-Id: <20091126113128.5A65.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 26 Nov 2009 11:54:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> simplify the code for shrink_inactive_list.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>
> ---
>  mm/vmscan.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 777af57..0a3cf75 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1166,10 +1166,8 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
>  		__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
>  		__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
>  
> -		reclaim_stat->recent_scanned[0] += count[LRU_INACTIVE_ANON];
> -		reclaim_stat->recent_scanned[0] += count[LRU_ACTIVE_ANON];
> -		reclaim_stat->recent_scanned[1] += count[LRU_INACTIVE_FILE];
> -		reclaim_stat->recent_scanned[1] += count[LRU_ACTIVE_FILE];
> +		reclaim_stat->recent_scanned[0] += nr_anon;
> +		reclaim_stat->recent_scanned[1] += nr_file;
>  
>  		spin_unlock_irq(&zone->lru_lock);

Thank you.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
