Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 21ED66B01F1
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 05:56:42 -0400 (EDT)
Date: Mon, 30 Aug 2010 10:56:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v2 2/2] compaction: fix COMPACTPAGEFAILED counting
Message-ID: <20100830095623.GH19556@csn.ul.ie>
References: <1282664620-4539-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1282664620-4539-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 25, 2010 at 12:43:40AM +0900, Minchan Kim wrote:
> Now update_nr_listpages doesn't have a role. That's because
> lists passed is always empty just after calling migrate_pages.
> The migrate_pages cleans up page list which have failed to migrate
> before returning by aaa994b3.
> 
>  [PATCH] page migration: handle freeing of pages in migrate_pages()
> 
>  Do not leave pages on the lists passed to migrate_pages().  Seems that we will
>  not need any postprocessing of pages.  This will simplify the handling of
>  pages by the callers of migrate_pages().
> 
> At that time, we thought we don't need any postprocessing of pages.
> But the situation is changed. The compaction need to know the number of
> failed to migrate for COMPACTPAGEFAILED stat
> 
> This patch makes new rule for caller of migrate_pages to call putback_lru_pages.
> So caller need to clean up the lists so it has a chance to postprocess the pages.
> [suggested by Christoph Lameter]
> 
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Andi Kleen <andi@firstfloor.org>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Looks good and it passed basic testing.

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
