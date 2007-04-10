From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070410160244.10742.42187.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/4] Updates to groupings pages by mobility patches
Date: Tue, 10 Apr 2007 17:02:44 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Some concerns were raised about performance hotpoints related to
grouping pages by mobility and the fact it was a configurable option. The
following four patches aim to address some of those concerns. They show
small performance benefits on kernbench but the important patch deals with
disabling grouping pages by mobility when there is not enough memory for it
to work.  With these set of patches against 2.6.21-rc6-mm1, it's reasonable
to get rid of page grouping by mobility as a compile-time option.

Patch 1 is a minor correctness issue. A check is made for MIGRATE_RESERVE
	during boot time before any block has been marked. The patch removes
	the unnecessary check.

Patch 2 checks when the system does not have enough memory overall to make
	grouping pages by mobility useful. This patch disables page groupings
	when the situation occurs. This is important for low-memory machines.

Patch 3 is a performance improvement in the per-cpu allocator to do less work
	when grouping pages by mobility

Patch 4 is a performance improvement when looking up flags affecting a
	MAX_ORDER_NR_PAGES area in the SPARSEMEM case. There is no need to
	align the PFN to an area boundary.

The net effect of these patches is a small performance increase and that
I'd be happy to drop the configure option for grouping pages by mobility.
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
