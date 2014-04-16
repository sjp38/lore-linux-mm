Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8776B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:52:34 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so10158964pde.15
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 18:52:34 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id dg5si11778949pbc.93.2014.04.15.18.52.32
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 18:52:33 -0700 (PDT)
Date: Wed, 16 Apr 2014 10:52:59 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/2] mm/compaction: make isolate_freepages start at
 pageblock boundary
Message-ID: <20140416015259.GA17841@js1304-P5Q-DELUXE>
References: <5342BA34.8050006@suse.cz>
 <1397553507-15330-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397553507-15330-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Heesub Shin <heesub.shin@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Tue, Apr 15, 2014 at 11:18:26AM +0200, Vlastimil Babka wrote:
> The compaction freepage scanner implementation in isolate_freepages() starts
> by taking the current cc->free_pfn value as the first pfn. In a for loop, it
> scans from this first pfn to the end of the pageblock, and then subtracts
> pageblock_nr_pages from the first pfn to obtain the first pfn for the next
> for loop iteration.
> 
> This means that when cc->free_pfn starts at offset X rather than being aligned
> on pageblock boundary, the scanner will start at offset X in all scanned
> pageblock, ignoring potentially many free pages. Currently this can happen when
> a) zone's end pfn is not pageblock aligned, or
> b) through zone->compact_cached_free_pfn with CONFIG_HOLES_IN_ZONE enabled and
>    a hole spanning the beginning of a pageblock
> 
> This patch fixes the problem by aligning the initial pfn in isolate_freepages()
> to pageblock boundary. This also allows to replace the end-of-pageblock
> alignment within the for loop with a simple pageblock_nr_pages increment.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Reported-by: Heesub Shin <heesub.shin@samsung.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> ---
>  mm/compaction.c | 22 ++++++++++++----------
>  1 file changed, 12 insertions(+), 10 deletions(-)

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
