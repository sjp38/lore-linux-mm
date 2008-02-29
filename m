Date: Fri, 29 Feb 2008 20:53:45 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 05/21] define page_file_cache() function
In-Reply-To: <20080228192928.335536700@redhat.com>
References: <20080228192908.126720629@redhat.com> <20080228192928.335536700@redhat.com>
Message-Id: <20080229204230.670B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> Index: linux-2.6.25-rc2-mm1/mm/swap_state.c
> ===================================================================
> --- linux-2.6.25-rc2-mm1.orig/mm/swap_state.c	2008-02-19 16:23:09.000000000 -0500
> +++ linux-2.6.25-rc2-mm1/mm/swap_state.c	2008-02-27 14:36:57.000000000 -0500
> @@ -82,6 +82,7 @@ int add_to_swap_cache(struct page *page,
>  		if (!error) {
>  			page_cache_get(page);
>  			SetPageSwapCache(page);
> +			SetPageSwapBacked(page);
>  			set_page_private(page, entry.val);
>  			total_swapcache_pages++;
>  			__inc_zone_page_state(page, NR_FILE_PAGES);

hmm,
What do you think NR_FILE_PAGES counted?
SetPageSwapBacked() and increase NR_FILE_PAGES is a bit strange.

but I am worried now.
because if change it, make a incompatibility... ;)


- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
