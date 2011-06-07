Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 54ADE6B0082
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 11:14:22 -0400 (EDT)
Received: by pwi12 with SMTP id 12so3458222pwi.14
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 08:14:19 -0700 (PDT)
Date: Wed, 8 Jun 2011 00:14:12 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 3/4] mm: memory-failure: Fix isolated page count during
 memory failure
Message-ID: <20110607151412.GJ1686@barrios-laptop>
References: <1307459225-4481-1-git-send-email-mgorman@suse.de>
 <1307459225-4481-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1307459225-4481-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Sattler <tsattler@gmx.de>, Ury Stankevich <urykhy@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Jun 07, 2011 at 04:07:04PM +0100, Mel Gorman wrote:
> From: Minchan Kim <minchan.kim@gmail.com>
> 
> From: Minchan Kim <minchan.kim@gmail.com>
> 
> Pages isolated for migration are accounted with the vmstat counters
> NR_ISOLATE_[ANON|FILE]. Callers of migrate_pages() are expected to
> increment these counters when pages are isolated from the LRU. Once
> the pages have been migrated, they are put back on the LRU or freed
> and the isolated count is decremented.
> 
> Memory failure is not properly accounting for pages it isolates
> causing the NR_ISOLATED counters to be negative. On SMP builds,
> this goes unnoticed as negative counters are treated as 0 due to
> expected per-cpu drift. On UP builds, the counter is treated by
> too_many_isolated() as a large value causing processes to enter D
> state during page reclaim or compaction. This patch accounts for
> pages isolated by memory failure correctly.
> 
> [mgorman@suse.de: Updated changelog]
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

I was about to resend this patch with your updated description.
Thanks! Mel.

-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
