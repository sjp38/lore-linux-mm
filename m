Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 39B686B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 02:49:25 -0400 (EDT)
Date: Mon, 8 Oct 2012 15:53:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: compaction: Iron out isolate_freepages_block() and
 isolate_freepages_range() -fix1
Message-ID: <20121008065330.GC13817@bbox>
References: <20120927112911.GA25959@avionic-0098.mockup.avionic-design.de>
 <20120927151159.4427fc8f.akpm@linux-foundation.org>
 <20120928054330.GA27594@bbox>
 <20121004140017.GW29125@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121004140017.GW29125@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thierry Reding <thierry.reding@avionic-design.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>

On Thu, Oct 04, 2012 at 03:00:17PM +0100, Mel Gorman wrote:
> The following patch is still missing from linux-next/akpm so am
> resending in case it got lost in the mess.
> 
> 
> CMA is reported to be broken in next-20120926. Minchan Kim pointed out
> that this was due to nr_scanned != total_isolated in the case of CMA
> because PageBuddy pages are one scan but many isolations in CMA. This
> patch should address the problem.
> 
> This patch is a fix for
> mm-compaction-acquire-the-zone-lock-as-late-as-possible-fix-2.patch
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Andrew, please fold this into [1] and pick.
Mel, Thanks for seeing this problem while I enjoy holiday.

[1] mm: compaction: Iron out isolate_freepages_block() and isolate_freepages_range() -fix2
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
