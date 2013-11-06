Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6C47F6B0126
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 18:41:26 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id p10so220186pdj.36
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 15:41:26 -0800 (PST)
Received: from psmtp.com ([74.125.245.113])
        by mx.google.com with SMTP id pl8si394787pbb.224.2013.11.06.15.41.22
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 15:41:23 -0800 (PST)
Date: Wed, 6 Nov 2013 15:41:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: cma: free cma page to buddy instead of being cpu
 hot page
Message-Id: <20131106154120.477a4cd83f8fb120d4d4f6cf@linux-foundation.org>
In-Reply-To: <20131106064302.GC30958@bbox>
References: <1382960569-6564-1-git-send-email-zhang.mingjun@linaro.org>
	<20131029093322.GA2400@suse.de>
	<20131105134448.7677d6febbfff4721373be4b@linux-foundation.org>
	<20131106064302.GC30958@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, zhang.mingjun@linaro.org, m.szyprowski@samsung.com, haojian.zhuang@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mingjun Zhang <troy.zhangmingjun@linaro.org>

On Wed, 6 Nov 2013 15:43:02 +0900 Minchan Kim <minchan@kernel.org> wrote:

> > The added overhead is pretty small - just a comparison of a local with
> > a constant.  And that cost is not incurred for MIGRATE_UNMOVABLE,
> > MIGRATE_RECLAIMABLE and MIGRATE_MOVABLE, which are the common cases
> > (yes?).
> 
> True but bloat code might affect icache so we should be careful.
> And what Mel has a concern is about zone->lock, which would be more contended.
> I agree his opinion.
> 
> In addition, I think the gain is marginal because normally CMA is big range
> so free_contig_range in dma release path will fill per_cpu_pages with freed pages
> easily so it could drain per_cpu_pages frequently so race which steal page from
> per_cpu_pages is not big, I guess.
> 
> Morever, we could change free_contig_range with batch_free_page which would
> be useful for other cases if they want to free many number of pages
> all at once.
> 
> The bottom line is we need *number and real scenario* for that.

Well yes, quantitative results are always good to have with a patch like
this.

It doesn't actually compile (missing a "}"), which doesn't inspire
confidence.  I'll make the patch go away for now

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
