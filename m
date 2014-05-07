Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2556B6B009D
	for <linux-mm@kvack.org>; Wed,  7 May 2014 18:06:59 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id z60so1830478qgd.4
        for <linux-mm@kvack.org>; Wed, 07 May 2014 15:06:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id hc9si4998695qcb.10.2014.05.07.15.06.58
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 15:06:58 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 2/2] mm/compaction: avoid rescanning pageblocks in isolate_freepages
Date: Wed,  7 May 2014 18:06:32 -0400
Message-Id: <536aae82.09d7e50a.0434.fffff7e6SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <1399464550-26447-2-git-send-email-vbabka@suse.cz>
References: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com> <1399464550-26447-1-git-send-email-vbabka@suse.cz> <1399464550-26447-2-git-send-email-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, b.zolnierkie@samsung.com, mina86@mina86.com, cl@linux.com, Rik van Riel <riel@redhat.com>

On Wed, May 07, 2014 at 02:09:10PM +0200, Vlastimil Babka wrote:
> The compaction free scanner in isolate_freepages() currently remembers PFN of
> the highest pageblock where it successfully isolates, to be used as the
> starting pageblock for the next invocation. The rationale behind this is that
> page migration might return free pages to the allocator when migration fails
> and we don't want to skip them if the compaction continues.
> 
> Since migration now returns free pages back to compaction code where they can
> be reused, this is no longer a concern. This patch changes isolate_freepages()
> so that the PFN for restarting is updated with each pageblock where isolation
> is attempted. Using stress-highalloc from mmtests, this resulted in 10%
> reduction of the pages scanned by the free scanner.
> 
> Note that the somewhat similar functionality that records highest successful
> pageblock in zone->compact_cached_free_pfn, remains unchanged. This cache is
> used when the whole compaction is restarted, not for multiple invocations of
> the free scanner during single compaction.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> ---
>  v2: no changes, just keep patches together

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
