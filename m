Date: Fri, 24 Feb 2006 11:52:20 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] [RFC] for_each_page_in_zone [1/1]
Message-ID: <20060224105220.GA1662@elf.ucw.cz>
References: <20060224171518.29bae84b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060224171518.29bae84b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi!

> This patch defines for_each_page_in_zone() macro. This replaces
> routine like this:
> ==from==
> for(i = 0; i < zone->zone_spanned_pages; i++) {
> 	if (!pfn_valid(pfn + i))
> 		continue;
> 	page = pfn_to_page(zone->zone_start_pfn + i);
> 	.....
> ==
> ==to==
> for_each_page_in_zone(page,zone) {
> 	....
> }
> ==
> This can be used by many places in kernel/power/snapshot.c
> 
> This patch is against 2.6.16-rc4-mm1 and has no dependency to other pathces.
> I did compile test and booted, but I don't have a hardware which touches codes
> I modified. so...please check.

Patch looks good to me. I'll try it later today.

> Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Index: testtree/include/linux/mmzone.h
> ===================================================================
> --- testtree.orig/include/linux/mmzone.h
> +++ testtree/include/linux/mmzone.h
> @@ -472,6 +472,26 @@ extern struct pglist_data contig_page_da
>  
>  #endif /* !CONFIG_NEED_MULTIPLE_NODES */
>  
> +/*
> + * these function uses suitable algorythm for each memory model

"These functions use suitable algorithm for each memory model"?

								Pavel
-- 
Web maintainer for suspend.sf.net (www.sf.net/projects/suspend) wanted...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
