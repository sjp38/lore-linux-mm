Message-ID: <43D96987.8090608@jp.fujitsu.com>
Date: Fri, 27 Jan 2006 09:29:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/9] Reducing fragmentation using zones v4
References: <20060126184305.8550.94358.sendpatchset@skynet.csn.ul.ie>
In-Reply-To: <20060126184305.8550.94358.sendpatchset@skynet.csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi, Mel-san

Mel Gorman wrote:
> Changelog since v4
>   o Minor bugs
>   o ppc64 can specify kernelcore
>   o Ability to disable use of ZONE_EASYRCLM at boot time
>   o HugeTLB uses ZONE_EASYRCLM
>   o Add drain-percpu caches for testing
>   o boot-parameter documentation added
> 

Could you add this patch to your set ?
This was needed to boot my x86 machine without HIGHMEM.

-- Kame

Index: linux-2.6.16-rc1-mm3/mm/highmem.c
===================================================================
--- linux-2.6.16-rc1-mm3.orig/mm/highmem.c
+++ linux-2.6.16-rc1-mm3/mm/highmem.c
@@ -225,9 +225,10 @@ static __init int init_emergency_pool(vo
  	struct sysinfo i;
  	si_meminfo(&i);
  	si_swapinfo(&i);
-
+#ifdef CONFIG_HIGHMEM   /* we can add HIGHMEM after boot */
  	if (!i.totalhigh)
  		return 0;
+#endif

  	page_pool = mempool_create(POOL_SIZE, page_pool_alloc, page_pool_free, NULL);
  	if (!page_pool)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
