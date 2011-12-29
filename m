Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id D574E6B006E
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 00:06:54 -0500 (EST)
Received: by qabg40 with SMTP id g40so6521231qab.14
        for <linux-mm@kvack.org>; Wed, 28 Dec 2011 21:06:53 -0800 (PST)
Message-ID: <4EFBF56B.9050800@gmail.com>
Date: Thu, 29 Dec 2011 00:06:51 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: test PageSwapBacked in lumpy reclaim
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils> <alpine.LSU.2.00.1112282033260.1362@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112282033260.1362@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org

(12/28/11 11:35 PM), Hugh Dickins wrote:
> Lumpy reclaim does well to stop at a PageAnon when there's no swap, but
> better is to stop at any PageSwapBacked, which includes shmem/tmpfs too.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>
> ---
>   mm/vmscan.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> --- mmotm.orig/mm/vmscan.c	2011-12-28 12:32:02.000000000 -0800
> +++ mmotm/mm/vmscan.c	2011-12-28 16:49:36.463201033 -0800
> @@ -1222,7 +1222,7 @@ static unsigned long isolate_lru_pages(u
>   			 * anon page which don't already have a swap slot is
>   			 * pointless.
>   			 */
> -			if (nr_swap_pages<= 0&&  PageAnon(cursor_page)&&
> +			if (nr_swap_pages<= 0&&  PageSwapBacked(cursor_page)&&
>   			!PageSwapCache(cursor_page))
>   				break;

It seems obvious.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
