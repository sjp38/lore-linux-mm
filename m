From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] Revert "mm/memory-hotplug: fix lowmem count overflow
 when offline pages"
Date: Sun, 4 Aug 2013 15:49:56 +0800
Message-ID: <27662.2366662652$1375602624@news.gmane.org>
References: <1375260602-2462-1-git-send-email-jy0922.shim@samsung.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1V5t4z-00085F-AK
	for glkm-linux-mm-2@m.gmane.org; Sun, 04 Aug 2013 09:50:17 +0200
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 02E1C6B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 03:50:13 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 4 Aug 2013 13:12:51 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 75E07E004F
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 13:20:11 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r747p6RG32178356
	for <linux-mm@kvack.org>; Sun, 4 Aug 2013 13:21:07 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r747nwnx005701
	for <linux-mm@kvack.org>; Sun, 4 Aug 2013 13:19:58 +0530
Content-Disposition: inline
In-Reply-To: <1375260602-2462-1-git-send-email-jy0922.shim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonyoung Shim <jy0922.shim@samsung.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, liuj97@gmail.com, kosaki.motohiro@gmail.com

On Wed, Jul 31, 2013 at 05:50:02PM +0900, Joonyoung Shim wrote:
>This reverts commit cea27eb2a202959783f81254c48c250ddd80e129.
>
>Fixed to adjust totalhigh_pages when hot-removing memory by commit
>3dcc0571cd64816309765b7c7e4691a4cadf2ee7, so that commit occurs
>duplicated decreasing of totalhigh_pages.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Joonyoung Shim <jy0922.shim@samsung.com>
>---
>The commit cea27eb2a202959783f81254c48c250ddd80e129 is only for stable,
>is it right?
>
> mm/page_alloc.c | 4 ----
> 1 file changed, 4 deletions(-)
>
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index b100255..2b28216 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -6274,10 +6274,6 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
> 		list_del(&page->lru);
> 		rmv_page_order(page);
> 		zone->free_area[order].nr_free--;
>-#ifdef CONFIG_HIGHMEM
>-		if (PageHighMem(page))
>-			totalhigh_pages -= 1 << order;
>-#endif
> 		for (i = 0; i < (1 << order); i++)
> 			SetPageReserved((page+i));
> 		pfn += (1 << order);
>-- 
>1.8.1.2
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
