Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 9F6166B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 02:46:29 -0400 (EDT)
Date: Mon, 8 Oct 2012 15:50:35 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: compaction: Iron out isolate_freepages_block() and
 isolate_freepages_range() -fix2
Message-ID: <20121008065035.GB13817@bbox>
References: <20120927112911.GA25959@avionic-0098.mockup.avionic-design.de>
 <20120927151159.4427fc8f.akpm@linux-foundation.org>
 <20120928054330.GA27594@bbox>
 <20121004140017.GW29125@suse.de>
 <20121005095945.GC29125@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121005095945.GC29125@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thierry Reding <thierry.reding@avionic-design.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>

On Fri, Oct 05, 2012 at 10:59:45AM +0100, Mel Gorman wrote:
> Thierry reported offline that the strict check "mm: compaction: Iron out
> isolate_freepages_block() and isolate_freepages_range() -fix1" check is
> still too strict because it's possible for more pages to be isolated
> than required. This patch corrects the check.
> 
> There are still CMA-related problems but they are "somewhere else" yet
> to be determined.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
