Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 79A536B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 08:09:01 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id m15so3487651wgh.29
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 05:09:01 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id fd8si12375335wic.26.2014.07.10.05.09.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 05:09:00 -0700 (PDT)
Date: Thu, 10 Jul 2014 08:08:57 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/6] mm: Move zone->pages_scanned into a vmstat counter
Message-ID: <20140710120857.GK29639@cmpxchg.org>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
 <1404893588-21371-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404893588-21371-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Wed, Jul 09, 2014 at 09:13:05AM +0100, Mel Gorman wrote:
> zone->pages_scanned is a write-intensive cache line during page reclaim
> and it's also updated during page free. Move the counter into vmstat to
> take advantage of the per-cpu updates and do not update it in the free
> paths unless necessary.
> 
> On a small UMA machine running tiobench the difference is marginal. On a
> 4-node machine the overhead is more noticable. Note that automatic NUMA
> balancing was disabled for this test as otherwise the system CPU overhead
> is unpredictable.
> 
>           3.16.0-rc3  3.16.0-rc3  3.16.0-rc3
>              vanillarearrange-v5   vmstat-v5
> User          746.94      759.78      774.56
> System      65336.22    58350.98    32847.27
> Elapsed     27553.52    27282.02    27415.04
> 
> Note that the overhead reduction will vary depending on where exactly
> pages are allocated and freed.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
