From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080710173001.16433.87538.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/2] Fix two bugs in hugetlbfs MAP_PRIVATE page reservation
Date: Thu, 10 Jul 2008 18:30:01 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: apw@shadowen.org, Mel Gorman <mel@csn.ul.ie>, agl@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The following two patches fix minor issues with the MAP_PRIVATE-reservation
support for hugetlbfs that showed up during testing. The first patch fixes a
problem whereby a check is made for MAP_SHARED mappings that is intended for
MAP_PRIVATE mappings only. The second fixes a BUG_ON that is triggered due to
an unaligned address.

Both patches are fixes for
hugetlb-reserve-huge-pages-for-reliable-map_private-hugetlbfs-mappings-until-fork.patch.
Credit goes to Adam Litke for spotting the problems during regression testing.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
