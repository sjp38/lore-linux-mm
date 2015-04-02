Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6CD6B0038
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 03:33:09 -0400 (EDT)
Received: by pddn5 with SMTP id n5so81226418pdd.2
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 00:33:09 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id p1si6352499pdg.50.2015.04.02.00.33.07
        for <linux-mm@kvack.org>;
        Thu, 02 Apr 2015 00:33:08 -0700 (PDT)
Date: Thu, 2 Apr 2015 16:33:41 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm: cma: add trace events for CMA allocations and
 freeings
Message-ID: <20150402073340.GA13158@js1304-P5Q-DELUXE>
References: <1427895103-9431-1-git-send-email-s.strogin@partner.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427895103-9431-1-git-send-email-s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Sasha Levin <sasha.levin@oracle.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gioh.kim@lge.com, stefan.strogin@gmail.com

Hello,

On Wed, Apr 01, 2015 at 04:31:43PM +0300, Stefan Strogin wrote:
> Add trace events for cma_alloc() and cma_release().
> 
> The cma_alloc tracepoint is used both for successful and failed allocations,
> in case of allocation failure pfn=-1UL is stored and printed.
> 
> Signed-off-by: Stefan Strogin <stefan.strogin@gmail.com>
> ---
> 
> Took out from the patch set "mm: cma: add some debug information for CMA" v4
> (http://thread.gmane.org/gmane.linux.kernel.mm/129903) because of probable
> uselessness of the rest of the patches.

I think that patch 5/5 in previous submission is handy and
simple to merge. Although we can calculate it by using bitmap,
it would be good to get that information(used size and maxchunk size)
directly.


> @@ -414,6 +416,8 @@ struct page *cma_alloc(struct cma *cma, unsigned int count, unsigned int align)
>  		start = bitmap_no + mask + 1;
>  	}
>  
> +	trace_cma_alloc(page ? pfn : -1UL, page, count);
> +

I think that tracing align is also useful.
Is there any reason not to include it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
