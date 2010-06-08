Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 969B36B01CC
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 14:49:17 -0400 (EDT)
Date: Tue, 8 Jun 2010 14:49:14 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: RFC: dirty_ratio back to 40%
Message-ID: <20100608184913.GA12154@infradead.org>
References: <4BF51B0A.1050901@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BF51B0A.1050901@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Did this patch get merged somewhere?

On Thu, May 20, 2010 at 07:20:42AM -0400, Larry Woodman wrote:
> We've seen multiple performance regressions linked to the lower(20%)
> dirty_ratio.  When performing enough IO to overwhelm the background
> flush daemons the percent of dirty pagecache memory quickly climbs
> to the new/lower dirty_ratio value of 20%.  At that point all
> writing processes are forced to stop and write dirty pagecache pages
> back to disk.  This causes performance regressions in several
> benchmarks as well as causing
> a noticeable overall sluggishness.  We all know that the dirty_ratio is
> an integrity vs performance trade-off but the file system journaling
> will cover any devastating effects in the event of a system crash.
> 
> Increasing the dirty_ratio to 40% will regain the performance loss seen
> in several benchmarks.  Whats everyone think about this???
> 
> 
> 
> 
> 
> ------------------------------------------------------------------------
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index ef27e73..645a462 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -78,7 +78,7 @@ int vm_highmem_is_dirtyable;
> /*
>  * The generator of dirty data starts writeback at this percentage
>  */
> -int vm_dirty_ratio = 20;
> +int vm_dirty_ratio = 40;
> 
> /*
>  * vm_dirty_bytes starts at 0 (disabled) so that it is a function of
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
