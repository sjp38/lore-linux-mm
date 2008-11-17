Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAH0EtZQ032719
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 17 Nov 2008 09:14:55 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CC2A445DE54
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 09:14:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E29245DE51
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 09:14:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 257951DB803E
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 09:14:54 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 93E351DB803F
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 09:14:53 +0900 (JST)
Date: Mon, 17 Nov 2008 09:14:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] memcg: handle swap caches build fix
Message-Id: <20081117091413.4a123b7d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0811162046080.5813@blonde.site>
References: <Pine.LNX.4.64.0811162046080.5813@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 16 Nov 2008 20:52:22 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> Fix to build error when CONFIG_SHMEM=y but CONFIG_SWAP is not set:
> mm/shmem.c: In function ‘shmem_unuse_inode’:
> mm/shmem.c:927: error: implicit declaration of function ‘mem_cgroup_cache_charge_swapin’
> 
> Yes, there's a lot of code in mm/shmem.c which only comes into play when
> CONFIG_SWAP=y: better than this quick fix would be to restructure shmem.c
> with all swap stuff in a separate file; that's on my mind, but now is not
> the moment for it.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Thanks! (>_<

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
> Fix should follow or be merged into memcg-handle-swap-caches.patch
> 
>  include/linux/swap.h |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> --- mmotm/include/linux/swap.h	2008-11-16 17:33:25.000000000 +0000
> +++ linux/include/linux/swap.h	2008-11-16 20:18:27.000000000 +0000
> @@ -442,6 +442,12 @@ static inline swp_entry_t get_swap_page(
>  #define has_swap_token(x) 0
>  #define disable_swap_token() do { } while(0)
>  
> +static inline int mem_cgroup_cache_charge_swapin(struct page *page,
> +			struct mm_struct *mm, gfp_t mask, bool locked)
> +{
> +	return 0;
> +}
> +
>  #endif /* CONFIG_SWAP */
>  #endif /* __KERNEL__*/
>  #endif /* _LINUX_SWAP_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
