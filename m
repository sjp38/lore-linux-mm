Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 620BC90010C
	for <linux-mm@kvack.org>; Mon,  2 May 2011 06:32:24 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9CB063EE0C1
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:32:21 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F89945DE92
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:32:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C9FC45DE91
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:32:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FE89E08003
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:32:21 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 034C61DB803B
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:32:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] Check PageUnevictable in lru_deactivate_fn
In-Reply-To: <c7a7b3ceafe4fdc4bc038774374504827c01481f.1304261567.git.minchan.kim@gmail.com>
References: <cover.1304261567.git.minchan.kim@gmail.com> <c7a7b3ceafe4fdc4bc038774374504827c01481f.1304261567.git.minchan.kim@gmail.com>
Message-Id: <20110502193353.2D59.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  2 May 2011 19:32:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>

> The lru_deactivate_fn should not move page which in on unevictable lru
> into inactive list. Otherwise, we can meet BUG when we use isolate_lru_pages
> as __isolate_lru_page could return -EINVAL.
> It's really BUG and let's fix it.
> 
> Reported-by: Ying Han <yinghan@google.com>
> Tested-by: Ying Han <yinghan@google.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/swap.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index a83ec5a..2e9656d 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -429,6 +429,9 @@ static void lru_deactivate_fn(struct page *page, void *arg)
>  	if (!PageLRU(page))
>  		return;
>  
> +	if (PageUnevictable(page))
> +		return;
> +

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
