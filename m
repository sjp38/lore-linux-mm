Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB101pG4028084
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 1 Dec 2008 09:01:51 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 31B9345DD7A
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 09:01:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0698145DE54
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 09:01:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C83FF1DB803A
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 09:01:50 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EB1B1DB803B
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 09:01:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: vmscan: protect zone rotation stats by lru lock
In-Reply-To: <E1L6qr1-0003Qv-Re@cmpxchg.org>
References: <E1L6qr1-0003Qv-Re@cmpxchg.org>
Message-Id: <20081201090003.816E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  1 Dec 2008 09:01:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> +	spin_lock_irq(&zone->lru_lock);
>  	/*
>  	 * Count referenced pages from currently used mappings as
>  	 * rotated, even though they are moved to the inactive list.
>  	 * This helps balance scan pressure between file and anonymous
>  	 * pages in get_scan_ratio.
>  	 */
>  	zone->recent_rotated[!!file] += pgmoved;
>  
>  	/*
>  	 * Move the pages to the [file or anon] inactive list.
>  	 */
>  	pagevec_init(&pvec, 1);
>  
>  	pgmoved = 0;
>  	lru = LRU_BASE + file * LRU_FILE;
> -	spin_lock_irq(&zone->lru_lock);
>  	while (!list_empty(&l_inactive)) {
>  		page = lru_to_page(&l_inactive);

I think this patch is needed for 2.6.28.
please CC to lkml and linus at your next post.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
