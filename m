From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070516230110.10314.85884.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/5] Annotation fixes for grouping pages by mobility
Date: Thu, 17 May 2007 00:01:10 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

The following patches deal with annotation fixups and clarifications only. The
GFP_TEMPORARY one and GFP_HIGH_MOVABLE renames one you have already looked
at and acked. It was not clear if you were happy with the bio_alloc, shmem
and pagecache changes but they should be ok based on earlier feedback. Can
you take another look at these three in particular to confirm you are ok
with being pushed towards Andrew (cc'd)? I can deal with the feedback on
the statistics and grouping at an order other than MAX_ORDER separately. The
PAGECACHE one fixes up the grow_dev_page() annotation problem in particular
which has reared its head again and also removes the annotation to bdget()
because associated pages with its mappings do not appear movable. The patches
have passed a compile and basic stress test on x86 against 2.6.22-rc1-mm1.

Thanks.
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
