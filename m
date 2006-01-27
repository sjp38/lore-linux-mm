Message-ID: <43D96C41.6020103@jp.fujitsu.com>
Date: Fri, 27 Jan 2006 09:41:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 0/9] Reducing fragmentation using zones
 v4
References: <20060126184305.8550.94358.sendpatchset@skynet.csn.ul.ie> <43D96987.8090608@jp.fujitsu.com>
In-Reply-To: <43D96987.8090608@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Could you add this patch to your set ?
> This was needed to boot my x86 machine without HIGHMEM.
> 
Sorry, I sent a wrong patch..
This is correct one.
-- Kame

Index: linux-2.6.16-rc1-mm3/mm/highmem.c
===================================================================
--- linux-2.6.16-rc1-mm3.orig/mm/highmem.c
+++ linux-2.6.16-rc1-mm3/mm/highmem.c
@@ -225,9 +225,6 @@ static __init int init_emergency_pool(vo
  	struct sysinfo i;
  	si_meminfo(&i);
  	si_swapinfo(&i);
-
-	if (!i.totalhigh)
-		return 0;

  	page_pool = mempool_create(POOL_SIZE, page_pool_alloc, page_pool_free, NULL);
  	if (!page_pool)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
