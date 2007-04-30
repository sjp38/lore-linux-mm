From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070430185524.7142.56162.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/4] Clarify GFP flag usage when grouping pages by mobility
Date: Mon, 30 Apr 2007 19:55:24 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

The following patches are the starting point for addressing points brought
up by your review of the grouping pages by mobility patches.  The main
intention of the patches are to make the usage of GFP flags that group pages
by mobility clearer.

The first patch fixes a problem on m68knommu where
alloc_zeroed_user_highpage_movable() was not fixed up properly. This is a
bug fix that was found while developing the second patch. It needs to be
applied regardless of the remaining patches so I'll be pushing this separetly.

The second patch removes alloc_zeroed_user_highpage() as there
are no in-tree users. External users should be migrated to use
alloc_zeroed_user_highpage_movable(). The function is not marked deprecated
because it was not generating the appropriate gcc warnings.

The third patch uses SLAB_ACCOUNT_RECLAIM to determine when __GFP_RECLAIMABLE
should be used instead of updating individual call sites.

The final patch defines __GFP_TEMPORARY, GFP_TEMPORARY and SLAB_TEMPORARY
for short-lived allocations. Currently __GFP_RECLAIMABLE is used to mean
both reclaimable and short-lived which can be confusing when reading the
call-sites using __GFP_RECLAIMABLE. This patch does not change the final
destination for the pages, but clarifies the callers intent should we wish
to change it later.

Credit goes to Andy Whitcroft for reviewing these before sending out.

Regression tests are currently underway but the risk should be low as
there is no functionalty change as such. Two tests on x86_64 have completed
successfully and I see no reason why any other machine will fail. Please review.

Thanks a lot for your time.
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
