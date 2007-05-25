From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070525092126.17283.41581.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/5] Arbitrary grouping and statistics for grouping pages by mobility
Date: Fri, 25 May 2007 10:21:26 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

The following patches address points brought up during review of the grouping
pages by mobility patches. The main aim of this patchset is to group pages
by an order other than MAX_ORDER-1 and provide some statistics but there
is also one bug fix at the start of the patchset.

Changelog since v2
o Patches acked by Christoph

Changelog since v1 of statistics and grouping by arbitrary order
o Fix a bug in move_freepages_block() calculations
o Make page_order available in internal.h for PageBuddy pages
o Rename fragavoidance to pagetypeinfo for both code and proc filename
o Renamr nr_pages_pageblock to pageblock_nr_pages for consistency
o Print out pageblock_nr_pages and pageblock_order in proc output
o Print out the orders in the header for /proc/pagetypeinfo
o The order being grouped at is no longer printed to the kernel log. The
  necessary information is available in /proc/pagetypeinfo
o Breakout page_order so that statistics do not require special knowledge
  of the buddy allocator

The first patch is a fix to move_freepages_block() where it calculates the
number of blocks used instead of the number of base pages which is what we
are really interested in. This is a bug fix.

The second patch moves page_order() to internal.h as it is needed by
the statistics patch later in the patchset. It is also needed by the
not-ready-for-posting-yet memory compaction prototype.

The third patch allows grouping by mobility at sizes other than
MAX_ORDER_NR_PAGES.  The size is based on the order of the system hugepage
where that is defined. When possible this is specified as a compile time
constant to help the optimiser. It does change the handling of hugepagesz
from __setup() to early_param() which needs looking at.

The fourth and fifth patches provide some statistics in relation to
fragmentation avoidance. The statistics patches are split as the second
set depend on information from PAGE_OWNER when it's available.
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
