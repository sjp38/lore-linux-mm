From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/8] Review-based updates to grouping pages by mobility
Date: Tue, 15 May 2007 16:03:11 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

The following patches address points brought up by your review of the
grouping pages by mobility patches. There are quite a number of patches here.

The first patch allows grouping by mobility at sizes other than
MAX_ORDER_NR_PAGES.  The size is based on the order of the system hugepage
where that is defined. When possible this is specified as a compile time
constant to help the optimiser. It does change the handling of hugepagesz
from __setup() to early_param() which needs looking at.

The second and third patches provide some statistics in relation to
fragmentation avoidance.

Patches four and five are fixes for incorrectly flagged allocations sites.

Patches six, seven and eight extend the allocation types available and
convert allocation sites to use them. This corrects a number of areas
where call-sites are annotated incorrectly.

This set of patches handles most of the items in the TODO list that were
brought up during your review. There is another patch which groups page
cache pages separetly to other allocations but I'm holding off on it for
the moment in light of Nicolas's bug reports although they now appear to be
resolved. The last two items are SLAB_PERSISTENT and resizing ZONE_MOVABLE. I
glanced to check if SLAB_PERSISTENT would be useful but it doesn't seem to
be the case yet. The last item was resizing ZONE_MOVABLE at runtime.
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
