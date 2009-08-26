Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 403226B010F
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 22:02:41 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7Q22dPN006410
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 26 Aug 2009 11:02:39 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5153645DE79
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 11:02:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FDA945DE6E
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 11:02:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 18DB2E18004
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 11:02:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C4CE7E18001
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 11:02:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm/vmscan: remove page_queue_congested() comment
In-Reply-To: <1251226422-17878-1-git-send-email-macli@brc.ubc.ca>
References: <1251226422-17878-1-git-send-email-macli@brc.ubc.ca>
Message-Id: <20090826111156.9A23.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 26 Aug 2009 11:02:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

> Commit 084f71ae5c(kill page_queue_congested()) removed page_queue_congested().
> Remove the page_queue_congested() comment in vmscan pageout() too.
> 
> Signed-off-by: Vincent Li <macli@brc.ubc.ca>
> ---
>  mm/vmscan.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 848689a..1219ceb 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -366,7 +366,6 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
>  	 * block, for some throttling. This happens by accident, because
>  	 * swap_backing_dev_info is bust: it doesn't reflect the
>  	 * congestion state of the swapdevs.  Easy to fix, if needed.
> -	 * See swapfile.c:page_queue_congested().
>  	 */
>  	if (!is_page_cache_freeable(page))
>  		return PAGE_KEEP;

Thanks for carefully review and followup fixes.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
