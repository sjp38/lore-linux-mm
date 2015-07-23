Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 702C99003C7
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 14:34:15 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so5995698wib.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 11:34:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bq1si32246462wib.68.2015.07.23.11.34.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Jul 2015 11:34:13 -0700 (PDT)
Subject: Re: [PATCH] mm, page_isolation: make set/unset_migratetype_isolate()
 file-local
References: <1437630002-25936-1-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B133A1.3050403@suse.cz>
Date: Thu, 23 Jul 2015 20:34:09 +0200
MIME-Version: 1.0
In-Reply-To: <1437630002-25936-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 07/23/2015 07:40 AM, Naoya Horiguchi wrote:
> Nowaday, set/unset_migratetype_isolate() is defined and used only in
> mm/page_isolation, so let's limit the scope within the file.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  include/linux/page-isolation.h | 5 -----
>  mm/page_isolation.c            | 5 +++--
>  2 files changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git v4.2-rc2.orig/include/linux/page-isolation.h v4.2-rc2/include/linux/page-isolation.h
> index 2dc1e1697b45..047d64706f2a 100644
> --- v4.2-rc2.orig/include/linux/page-isolation.h
> +++ v4.2-rc2/include/linux/page-isolation.h
> @@ -65,11 +65,6 @@ undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
>  			bool skip_hwpoisoned_pages);
>  
> -/*
> - * Internal functions. Changes pageblock's migrate type.
> - */
> -int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages);
> -void unset_migratetype_isolate(struct page *page, unsigned migratetype);
>  struct page *alloc_migrate_target(struct page *page, unsigned long private,
>  				int **resultp);
>  
> diff --git v4.2-rc2.orig/mm/page_isolation.c v4.2-rc2/mm/page_isolation.c
> index 32fdc1df05e5..4568fd58f70a 100644
> --- v4.2-rc2.orig/mm/page_isolation.c
> +++ v4.2-rc2/mm/page_isolation.c
> @@ -9,7 +9,8 @@
>  #include <linux/hugetlb.h>
>  #include "internal.h"
>  
> -int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
> +static int set_migratetype_isolate(struct page *page,
> +				bool skip_hwpoisoned_pages)
>  {
>  	struct zone *zone;
>  	unsigned long flags, pfn;
> @@ -72,7 +73,7 @@ int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
>  	return ret;
>  }
>  
> -void unset_migratetype_isolate(struct page *page, unsigned migratetype)
> +static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>  {
>  	struct zone *zone;
>  	unsigned long flags, nr_pages;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
