Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 7FE576B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 09:46:18 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so5811035pad.14
        for <linux-mm@kvack.org>; Tue, 09 Oct 2012 06:46:17 -0700 (PDT)
Date: Tue, 9 Oct 2012 22:46:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: compaction: fix bit ranges in
 {get,clear,set}_pageblock_skip()
Message-ID: <20121009134608.GB3244@barrios>
References: <201210091343.47857.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201210091343.47857.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Thierry Reding <thierry.reding@avionic-design.de>, Peter Ujfalusi <peter.ujfalusi@ti.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Kyungmin Park <kyungmin.park@samsung.com>, linux-mm@kvack.org

On Tue, Oct 09, 2012 at 01:43:47PM +0200, Bartlomiej Zolnierkiewicz wrote:
> From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Subject: [PATCH] mm: compaction: fix bit ranges in {get,clear,set}_pageblock_skip() 
> 
> {get,clear,set}_pageblock_skip() use incorrect bit ranges (please compare
> to bit ranges used by {get,set}_pageblock_flags() used for migration types)
> and can overwrite pageblock migratetype of the next pageblock in the bitmap.
> 
> This fix is needed for "mm: compaction: cache if a pageblock was scanned and
> no pages were isolated" patch.
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> Tested-by: Thierry Reding <thierry.reding@avionic-design.de>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Peter Ujfalusi <peter.ujfalusi@ti.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
Acked-by: Minchan Kim <minchan@kernel.org>

Good spot. Thanks, Bart!

-- 
Kind Regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
