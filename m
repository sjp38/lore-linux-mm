Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9746B004F
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 20:46:40 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5N0hZko026721
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 18:43:35 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5N0lvcm206490
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 18:47:57 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5N0lumj024151
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 18:47:57 -0600
Date: Tue, 23 Jun 2009 06:17:16 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH] fix bad page removal from LRU (Was Re:
	[RFC][PATCH] cgroup: fix permanent wait in rmdir
Message-ID: <20090623004716.GD8642@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090622183707.dd9e665b.kamezawa.hiroyu@jp.fujitsu.com> <20090622105231.GA17242@elte.hu> <20090623085755.9cf75da2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090623085755.9cf75da2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-23 08:57:55]:

> I think this is a fix for the problem. Sorry for regression.
> fix for "memcg: fix lru rotation in isolate_pages" patch in 2.6.30-git18.
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> A page isolated is "cursor_page" not "page".
> This causes list corruption finally.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/vmscan.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6.30-git18/mm/vmscan.c
> ===================================================================
> --- linux-2.6.30-git18.orig/mm/vmscan.c
> +++ linux-2.6.30-git18/mm/vmscan.c
> @@ -932,7 +932,7 @@ static unsigned long isolate_lru_pages(u
>  				continue;
>  			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
>  				list_move(&cursor_page->lru, dst);
> -				mem_cgroup_del_lru(page);
> +				mem_cgroup_del_lru(cursor_page);
>  				nr_taken++;
>  				scan++;
>  			}

Good catch!

Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
