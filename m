Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD58828E1
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 02:45:52 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g127so26388197ith.3
        for <linux-mm@kvack.org>; Sun, 19 Jun 2016 23:45:52 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id r35si16251975ioi.154.2016.06.19.23.45.51
        for <linux-mm@kvack.org>;
        Sun, 19 Jun 2016 23:45:51 -0700 (PDT)
Date: Mon, 20 Jun 2016 15:48:16 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 0/6] Introduce ZONE_CMA
Message-ID: <20160620064816.GB13747@js1304-P5Q-DELUXE>
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160526080454.GA11823@shbuild888>
 <20160527052820.GA13661@js1304-P5Q-DELUXE>
 <20160527062527.GA32297@shbuild888>
 <20160527064218.GA14858@js1304-P5Q-DELUXE>
 <20160527072702.GA7782@shbuild888>
 <5763A909.8080907@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5763A909.8080907@hisilicon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: Feng Tang <feng.tang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Rui Teng <rui.teng@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Yiping Xu <xuyiping@hisilicon.com>, "fujun (F)" <oliver.fu@hisilicon.com>, Zhuangluan Su <suzhuangluan@hisilicon.com>, Dan Zhao <dan.zhao@hisilicon.com>, saberlily.xia@hisilicon.com

On Fri, Jun 17, 2016 at 03:38:49PM +0800, Chen Feng wrote:
> Hi Kim & feng,
> 
> Thanks for the share. In our platform also has the same use case.
> 
> We only let the alloc with GFP_HIGHUSER_MOVABLE in memory.c to use cma memory.
> 
> If we add zone_cma, It seems can resolve the cma migrate issue.
> 
> But when free_hot_cold_page, we need let the cma page goto system directly not the pcp.
> It can be fail while cma_alloc and cma_release. If we alloc the whole cma pages which
> declared before.

Hmm...I'm not sure I understand your explanation. So, if I miss
something, please let me know. We calls drain_all_pages() when
isolating pageblock and alloc_contig_range() also has one
drain_all_pages() calls to drain pcp pages. And, after pageblock isolation,
freed pages belonging to MIGRATE_ISOLATE pageblock will go to the
buddy directly so there would be no problem you mentioned. Isn't it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
