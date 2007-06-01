From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070601163010.24933.87242.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/3] Arbitrary grouping and statistics for grouping pages by mobility v4
Date: Fri,  1 Jun 2007 17:30:10 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

These are a resend of the arbitrary grouping and statistics patches that
were removed from -mm due to build failures.  These have been successfully
tested with allnoconfig, allmodconfig and defconfig on x86 and x86_64 using
2.6.21-rc3-mm1 as a base. allnoconfig passes on ppc64 as does a standard
kernel build suitable for booting the machine but allmodconfig failed on
ppc64 with the stock -mm kernel in arch/powerpc/platforms/cell/spufs/file.c
so I didn't test there further. ia64 fails allnoconfig on the vanilla kernel
but a standard boot test was fine.

Changelog since v3
o Ensure that HUGETLB_PAGE_ORDER is not referenced when it is not available.
  Previous versions failed to compile if HUGETLB_PAGE was not set

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

The first patch allows grouping by mobility at sizes other than
MAX_ORDER_NR_PAGES.  The size is based on the order of the system hugepage
where that is defined. When possible this is specified as a compile time
constant to help the optimiser. It does change the handling of hugepagesz
from __setup() to early_param() which needs looking at.

The second and third patches provide some statistics in relation to
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
