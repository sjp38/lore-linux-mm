Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 765EA6B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 23:48:30 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id fp1so18498433pdb.19
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 20:48:30 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id on8si12610537pdb.242.2014.12.29.20.48.27
        for <linux-mm@kvack.org>;
        Mon, 29 Dec 2014 20:48:29 -0800 (PST)
Date: Tue, 30 Dec 2014 13:48:27 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] CMA: Fix the bug that CMA's page number is
 substructed twice
Message-ID: <20141230044826.GC4588@js1304-P5Q-DELUXE>
References: <1419500608-11656-1-git-send-email-zhuhui@xiaomi.com>
 <1419500608-11656-2-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1419500608-11656-2-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: m.szyprowski@samsung.com, mina86@mina86.com, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, pintu.k@samsung.com, weijie.yang@samsung.com, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, vbabka@suse.cz, laurent.pinchart+renesas@ideasonboard.com, rientjes@google.com, sasha.levin@oracle.com, liuweixing@xiaomi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, teawater@gmail.com

On Thu, Dec 25, 2014 at 05:43:26PM +0800, Hui Zhu wrote:
> In Joonsoo's CMA patch "CMA: always treat free cma pages as non-free on
> watermark checking" [1], it changes __zone_watermark_ok to substruct CMA
> pages number from free_pages if system use CMA:
> 	if (IS_ENABLED(CONFIG_CMA) && z->managed_cma_pages)
> 		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);

Hello, 

In fact, without that patch, watermark checking has a problem in current kernel.
If there is reserved CMA region, watermark check for high order
allocation is done loosly. See following thread.

https://lkml.org/lkml/2014/5/30/320

Your patch can fix this situation, so, how about submitting this patch
separately?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
