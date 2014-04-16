Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 747596B0073
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 11:47:23 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id r5so12117098qcx.18
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 08:47:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id jl9si9283336qcb.54.2014.04.16.08.47.22
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 08:47:22 -0700 (PDT)
Message-ID: <534EA601.8040104@redhat.com>
Date: Wed, 16 Apr 2014 11:47:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm/compaction: make isolate_freepages start at pageblock
 boundary
References: <5342BA34.8050006@suse.cz> <1397553507-15330-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1397553507-15330-1-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Heesub Shin <heesub.shin@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>

On 04/15/2014 05:18 AM, Vlastimil Babka wrote:
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
>     a hole spanning the beginning of a pageblock
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

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
