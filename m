Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE48F6B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 00:32:19 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id n6so1622622pfg.19
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 21:32:19 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id r3si703763plb.307.2017.11.28.21.32.18
        for <linux-mm@kvack.org>;
        Tue, 28 Nov 2017 21:32:18 -0800 (PST)
Date: Wed, 29 Nov 2017 14:38:17 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2] mm/cma: fix alloc_contig_range ret code/potential leak
Message-ID: <20171129053817.GB8125@js1304-P5Q-DELUXE>
References: <15cf0f39-43f9-8287-fcfe-f2502af59e8a@oracle.com>
 <20171122185214.25285-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171122185214.25285-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Wed, Nov 22, 2017 at 10:52:14AM -0800, Mike Kravetz wrote:
> If the call __alloc_contig_migrate_range() in alloc_contig_range
> returns -EBUSY, processing continues so that test_pages_isolated()
> is called where there is a tracepoint to identify the busy pages.
> However, it is possible for busy pages to become available between
> the calls to these two routines.  In this case, the range of pages
> may be allocated.   Unfortunately, the original return code (ret
> == -EBUSY) is still set and returned to the caller.  Therefore,
> the caller believes the pages were not allocated and they are leaked.
> 
> Update comment to indicate that allocation is still possible even if
> __alloc_contig_migrate_range returns -EBUSY.  Also, clear return code
> in this case so that it is not accidentally used or returned to caller.
> 
> Fixes: 8ef5849fa8a2 ("mm/cma: always check which page caused allocation failure")
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Good catch!!

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
