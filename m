Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 040356B0253
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 02:38:33 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id g13so4075679pln.20
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 23:38:32 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id m11si4458771pls.698.2017.11.30.23.38.31
        for <linux-mm@kvack.org>;
        Thu, 30 Nov 2017 23:38:31 -0800 (PST)
Date: Fri, 1 Dec 2017 16:44:33 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch 14/15] mm/vmstat.c: walk the zone in pageblock_nr_pages
 steps
Message-ID: <20171201074432.GA21404@js1304-P5Q-DELUXE>
References: <5a20831b.ULuDgReaEYdaW2tL%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5a20831b.ULuDgReaEYdaW2tL%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, zhongjiang@huawei.com

On Thu, Nov 30, 2017 at 02:15:55PM -0800, akpm@linux-foundation.org wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> Subject: mm/vmstat.c: walk the zone in pageblock_nr_pages steps
> 
> when walking the zone, we can happens to the holes. we should not
> align MAX_ORDER_NR_PAGES, so it can skip the normal memory.

Even if this change is applied, we could skip the normal memory in
some corner cases.

However, pagetypeinfo_showblockcount_print() that is highly related to
this function also jumps to the next pageblock when it found invalid
pfn so this patch make the code more consistent.

Therefore,

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
