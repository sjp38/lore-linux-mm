From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070509082748.19219.48015.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/4] Minor updates and fixes to grouping pages by mobility
Date: Wed,  9 May 2007 09:27:48 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, clameter@sgi.com, apw@shadowen.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

The following patches are some fixes put together as a result of review
feedback from Christoph Lameter. Other patches based on his review are still
being developed but I am sending these now so I can free time to look closer
at the latest SLUB patches.

The first patch fixes a problem on m68knommu where
the helper for alloc_zeroed_user_highpage_movable() was not defined properly. 
This patch should be considered a fix for
add-__gfp_movable-for-callers-to-flag-allocations-from-high-memory-that-may-be-migrated.patch

The second patch removes alloc_zeroed_user_highpage which has no
in-tree users and is not exported. It can also be considered a fix for
add-__gfp_movable-for-callers-to-flag-allocations-from-high-memory-that-may-be-migrated.patch

The third patch removes a parameter from allocflags_to_migratetype()
that is no longer used. It is a fix for the patch
dont-group-high-order-atomic-allocations.patch.

The fourth patch uses the fact that slab marks reclaimable caches
SLAB_ACCOUNT_RECLAIM to determine when __GFP_RECLAIMABLE should be used.
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
