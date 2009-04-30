Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F24716B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 20:13:02 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3U0DCAc001426
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 30 Apr 2009 09:13:13 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 778AE45DE59
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:13:12 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 58E0045DE54
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:13:12 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 48766E38008
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:13:12 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E3B231DB803A
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:13:11 +0900 (JST)
Date: Thu, 30 Apr 2009 09:11:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [cleanup][PATCH] memcg: remove mem_cgroup_cache_charge_swapin()
Message-Id: <20090430091141.9168cedf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090429120956.2969b4e4.d-nishimura@mtf.biglobe.ne.jp>
References: <20090429120956.2969b4e4.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 29 Apr 2009 12:09:56 +0900
Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:

> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> memcg: remove mem_cgroup_cache_charge_swapin()
> 
> mem_cgroup_cache_charge_swapin() isn't used any more, so remove no-op definition
> of it in header file.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  include/linux/swap.h |    6 ------
>  1 files changed, 0 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 62d8143..caf0767 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -431,12 +431,6 @@ static inline swp_entry_t get_swap_page(void)
>  #define has_swap_token(x) 0
>  #define disable_swap_token() do { } while(0)
>  
> -static inline int mem_cgroup_cache_charge_swapin(struct page *page,
> -			struct mm_struct *mm, gfp_t mask, bool locked)
> -{
> -	return 0;
> -}
> -
>  #endif /* CONFIG_SWAP */
>  #endif /* __KERNEL__*/
>  #endif /* _LINUX_SWAP_H */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
