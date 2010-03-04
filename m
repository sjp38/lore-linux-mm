Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A3F496B004D
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 23:06:38 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2446acN016995
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 4 Mar 2010 13:06:36 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F2A545DE4F
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:06:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E7FB45DE4D
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:06:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 091761DB8040
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:06:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 86FB91DB8050
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:06:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: Fix some coding styles on mm/ tree
In-Reply-To: <20100304110916.GA3197@localhost.localdomain>
References: <20100304110916.GA3197@localhost.localdomain>
Message-Id: <20100304130509.D653.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  4 Mar 2010 13:06:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: wzt.wzt@gmail.com
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c26986c..fbe2793 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1327,9 +1327,9 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	 * zone->pages_scanned is used for detect zone's oom
>  	 * mem_cgroup remembers nr_scan by itself.
>  	 */
> -	if (scanning_global_lru(sc)) {
> +	if (scanning_global_lru(sc))
>  		zone->pages_scanned += pgscanned;
> -	}
> +
>  	reclaim_stat->recent_scanned[file] += nr_taken;
>  
>  	__count_zone_vm_events(PGREFILL, zone, pgscanned);

Probably this part is my fault. 

Thanks! Zhitong.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
