Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ABE2E6B00A6
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 22:15:04 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1D3F1sE031417
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Feb 2009 12:15:01 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B73F45DE50
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 12:15:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C59E45DE4E
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 12:15:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 30CF81DB8041
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 12:15:01 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E0EBA1DB8040
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 12:14:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 2/2 v2] vmscan: clip swap_cluster_max in shrink_all_memory()
In-Reply-To: <20090213091615.28e6a689.minchan.kim@barrios-desktop>
References: <20090213091615.28e6a689.minchan.kim@barrios-desktop>
Message-Id: <20090213121412.0A67.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Feb 2009 12:14:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Nigel Cunningham <ncunningham-lkml@crca.org.au>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: MinChan Kim <minchan.kim@gmail.com>
> Acked-by: Nigel Cunningham <ncunningham@crca.org.au>
> Acked-by: "Rafael J. Wysocki" <rjw@sisk.pl>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Rik van Riel <riel@redhat.com>
> 
> 
> ---
>  mm/vmscan.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 172e394..ed329c4 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2114,7 +2114,6 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
>  	struct scan_control sc = {
>  		.gfp_mask = GFP_KERNEL,
>  		.may_unmap = 0,
> -		.swap_cluster_max = nr_pages,
>  		.may_writepage = 1,
>  		.isolate_pages = isolate_pages_global,
>  	};
> @@ -2156,6 +2155,7 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
>  			unsigned long nr_to_scan = nr_pages - sc.nr_reclaimed;
>  
>  			sc.nr_scanned = 0;
> +			sc.swap_cluster_max = nr_to_scan;
>  			shrink_all_zones(nr_to_scan, prio, pass, &sc);
>  			if (sc.nr_reclaimed >= nr_pages) 
>  				goto out;

good catch.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
