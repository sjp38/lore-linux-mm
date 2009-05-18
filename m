Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1E6C86B005A
	for <linux-mm@kvack.org>; Sun, 17 May 2009 22:40:50 -0400 (EDT)
Received: by gxk20 with SMTP id 20so6019719gxk.14
        for <linux-mm@kvack.org>; Sun, 17 May 2009 19:41:25 -0700 (PDT)
Date: Mon, 18 May 2009 11:40:53 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in
 case of no swap space V3
Message-Id: <20090518114053.ed5af657.minchan.kim@barrios-desktop>
In-Reply-To: <20090518023404.GB5869@localhost>
References: <20090514231555.f52c81eb.minchan.kim@gmail.com>
	<20090518023404.GB5869@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: MinChan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 18 May 2009 10:34:04 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Thu, May 14, 2009 at 11:15:55PM +0900, MinChan Kim wrote:
>  
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 2f9d555..621708f 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1577,7 +1577,7 @@ static void shrink_zone(int priority, struct zone *zone,
> >  	 * Even if we did not try to evict anon pages at all, we want to
> >  	 * rebalance the anon lru active/inactive ratio.
> >  	 */
> > -	if (inactive_anon_is_low(zone, sc))
> > +	if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
> >  		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
> 
> There's another "if (inactive_anon_is_low) shrink_active_list;"
> occurrence to be fixed in balance_pgdat()? Otherwise:

I add Rik's comment. Of course, I agree his opinion. 

"If we are close to running out of swap space, with
swapins freeing up swap space on a regular basis,
I believe we do want to do aging on the active
pages, just so we can pick a decent page to swap
out next time swap space becomes available."

> Acked-by: Wu Fengguang <fengguang.wu@intel.com>

Thanks for spending your time for my patch. Wu Fengguang :)

-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
