Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1DBEF6B01F2
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 20:56:53 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7V0unGJ017985
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 31 Aug 2010 09:56:50 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DB8F45DE4E
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 09:56:49 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8260545DE4C
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 09:56:49 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 69E741DB8013
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 09:56:49 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 298071DB8012
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 09:56:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap system
In-Reply-To: <AANLkTikbs9sUVLhE4sWWVw8uEqY=v6SCdJ_6FLhXY6HW@mail.gmail.com>
References: <AANLkTinqm0o=AfmgFy+SpZ1mrdekRnjeXvs_7=OcLii8@mail.gmail.com> <AANLkTikbs9sUVLhE4sWWVw8uEqY=v6SCdJ_6FLhXY6HW@mail.gmail.com>
Message-Id: <20100831095542.87CA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 31 Aug 2010 09:56:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Ying Han <yinghan@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 1b145e6..0b8a3ce 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1747,7 +1747,7 @@ static void shrink_zone(int priority, struct zone *zone,
>          * Even if we did not try to evict anon pages at all, we want to
>          * rebalance the anon lru active/inactive ratio.
>          */
> -       if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
> +       if (nr_swap_pges > 0 && inactive_anon_is_low(zone, sc))

Sorry, I don't find any difference. What is your intention?


>                 shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
> 
>         throttle_vm_writeout(sc->gfp_mask);
> 
> But Andrew merged middle version.
> I will send this patch again.
> 
> Thanks.
> 
> -- 
> Kind regards,
> Minchan Kim



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
