Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A4AE96B0036
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 19:42:25 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so11486512pab.37
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 16:42:25 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id qf5si13528700pac.47.2014.04.16.16.42.23
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 16:42:24 -0700 (PDT)
Date: Thu, 17 Apr 2014 08:43:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm/compaction: make isolate_freepages start at
 pageblock boundary
Message-ID: <20140416234309.GE27534@bbox>
References: <5342BA34.8050006@suse.cz>
 <1397553507-15330-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397553507-15330-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Heesub Shin <heesub.shin@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

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

Acked-by: Minchan Kim <minchan@kernel.org>

-stable stuff?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
