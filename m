Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 8E0416B005A
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 11:47:49 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1832598pbb.14
        for <linux-mm@kvack.org>; Wed, 25 Jul 2012 08:47:48 -0700 (PDT)
Date: Wed, 25 Jul 2012 08:47:45 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 16/34] mm: compaction: Allow compaction to isolate dirty
 pages
Message-ID: <20120725154745.GB18901@kroah.com>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
 <1343050727-3045-17-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343050727-3045-17-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Stable <stable@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 23, 2012 at 02:38:29PM +0100, Mel Gorman wrote:
> commit a77ebd333cd810d7b680d544be88c875131c2bd3 upstream.
> 
> Stable note: Not tracked in Bugzilla. A fix aimed at preserving page aging
> 	information by reducing LRU list churning had the side-effect of
> 	reducing THP allocation success rates. This was part of a series
> 	to restore the success rates while preserving the reclaim fix.
> 
> Commit [39deaf85: mm: compaction: make isolate_lru_page() filter-aware]
> noted that compaction does not migrate dirty or writeback pages and
> that is was meaningless to pick the page and re-add it to the LRU list.
> 
> What was missed during review is that asynchronous migration moves
> dirty pages if their ->migratepage callback is migrate_page() because
> these can be moved without blocking. This potentially impacted
> hugepage allocation success rates by a factor depending on how many
> dirty pages are in the system.
> 
> This patch partially reverts 39deaf85 to allow migration to isolate
> dirty pages again. This increases how much compaction disrupts the
> LRU but that is addressed later in the series.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Note, the changelog here differs from what is in Linus's tree by a LOT.
I took the version in Linus's tree instead.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
