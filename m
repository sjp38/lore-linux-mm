Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D677C6B0085
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:29:20 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 24/25] Re-sort GFP flags and fix whitespace alignment for easier reading.
Date: Fri, 20 Mar 2009 10:03:11 +0000
Message-Id: <1237543392-11797-25-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237543392-11797-1-git-send-email-mel@csn.ul.ie>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Resort the GFP flags after __GFP_MOVABLE got redefined so how the bits
are used are a bit cleared.

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/gfp.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 59eb093..3109a6b 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -46,11 +46,11 @@ struct vm_area_struct;
 #define __GFP_NORETRY	((__force gfp_t)0x1000u)/* See above */
 #define __GFP_COMP	((__force gfp_t)0x4000u)/* Add compound page metadata */
 #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
-#define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
-#define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
-#define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
+#define __GFP_NOMEMALLOC  ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
+#define __GFP_HARDWALL    ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
+#define __GFP_THISNODE	  ((__force gfp_t)0x40000u) /* No fallback, no policies */
 #define __GFP_RECLAIMABLE ((__force gfp_t)0x80000u) /* Page is reclaimable */
-#define __GFP_MOVABLE	((__force gfp_t)0x100000u)  /* Page is movable */
+#define __GFP_MOVABLE	  ((__force gfp_t)0x100000u)/* Page is movable */
 
 #define __GFP_BITS_SHIFT 21	/* Room for 21 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
