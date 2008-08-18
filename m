Date: Mon, 18 Aug 2008 09:24:22 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: show free swap as signed
In-Reply-To: <Pine.LNX.4.64.0808152149320.7958@blonde.site>
References: <Pine.LNX.4.64.0808152149320.7958@blonde.site>
Message-Id: <20080818092248.6C26.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@saeurebad.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Adjust <Alt><SysRq>m show_swap_cache_info() to show "Free swap" as a
> signed long: the signed format is preferable, because during swapoff
> nr_swap_pages can legitimately go negative, so makes more sense thus
> (it used to be shown redundantly, once as signed and once as unsigned).
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
> No big deal, but I hope for 2.6.27.
> 
>  mm/swap_state.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- 2.6.27-rc3/mm/swap_state.c	2008-08-06 08:36:20.000000000 +0100
> +++ linux/mm/swap_state.c	2008-08-13 04:33:56.000000000 +0100
> @@ -60,7 +60,7 @@ void show_swap_cache_info(void)
>  	printk("Swap cache stats: add %lu, delete %lu, find %lu/%lu\n",
>  		swap_cache_info.add_total, swap_cache_info.del_total,
>  		swap_cache_info.find_success, swap_cache_info.find_total);
> -	printk("Free swap  = %lukB\n", nr_swap_pages << (PAGE_SHIFT - 10));
> +	printk("Free swap  = %ldkB\n", nr_swap_pages << (PAGE_SHIFT - 10));
>  	printk("Total swap = %lukB\n", total_swap_pages << (PAGE_SHIFT - 10));
>  }

makes sense.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
