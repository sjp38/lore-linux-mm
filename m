From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070424180032.22005.82088.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/2] Fix two boot problems related to ZONE_MOVABLE sizing
Date: Tue, 24 Apr 2007 19:00:32 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, apw@shadowen.org, y-goto@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Following this mail are two fixes related to a boot problem in relation
to ZONE_MOVABLE. These are fixes for memory partitioning where kernelcore=
is used and is unrelated to grouping pages by mobility.

The first patch moves kernelcore= parsing to common code. This avoids an
infinite loop that can occur when booting on IA64. As a side-effect,
it extends support of kernelcore= to all architectures that use
architecture-independent zone-sizing.

The second patch aligns ZONE_MOVABLE correctly. The bootmem allocator makes
assumptions on the alignment of zones. This can cause pages to be placed
on the freelists for the wrong zone resulting in a BUG() later. Aligning
ZONE_MOVABLE avoids the problem.

They have been successfully boot-tested with and without kernelcore=
specified on x86_64, ppc64 and IA64 (where the bug was first triggered).
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
