Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 68CF46B004D
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 05:46:46 -0400 (EDT)
Date: Sat, 29 Aug 2009 17:46:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm/memory-failure: remove CONFIG_UNEVICTABLE_LRU
	config option
Message-ID: <20090829094642.GB20128@localhost>
References: <1251486553-23181-1-git-send-email-macli@brc.ubc.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1251486553-23181-1-git-send-email-macli@brc.ubc.ca>
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 29, 2009 at 03:09:13AM +0800, Vincent Li wrote:
> Commit 683776596 (remove CONFIG_UNEVICTABLE_LRU config option) removed this config option.
> Removed it from mm/memory-failure too.

Good catch!

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

> Signed-off-by: Vincent Li <macli@brc.ubc.ca>
> ---
>  mm/memory-failure.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index f78d9fc..2bc4c50 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -587,10 +587,8 @@ static struct page_state {
>  	{ sc|dirty,	sc|dirty,	"swapcache",	me_swapcache_dirty },
>  	{ sc|dirty,	sc,		"swapcache",	me_swapcache_clean },
>  
> -#ifdef CONFIG_UNEVICTABLE_LRU
>  	{ unevict|dirty, unevict|dirty,	"unevictable LRU", me_pagecache_dirty},
>  	{ unevict,	unevict,	"unevictable LRU", me_pagecache_clean},
> -#endif
>  
>  #ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
>  	{ mlock|dirty,	mlock|dirty,	"mlocked LRU",	me_pagecache_dirty },
> -- 
> 1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
