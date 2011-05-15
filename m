Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5365E6B0024
	for <linux-mm@kvack.org>; Sun, 15 May 2011 18:21:43 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH v2 3/9] mm: remove MPOL_MF_STATS
Date: Sun, 15 May 2011 18:20:23 -0400
Message-Id: <1305498029-11677-4-git-send-email-wilsons@start.ca>
In-Reply-To: <1305498029-11677-1-git-send-email-wilsons@start.ca>
References: <1305498029-11677-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Alexey Dobriyan <adobriyan@gmail.com>, Christoph Lameter <cl@linux-foundation.org>

Mapping statistics in a NUMA environment is now computed using the
generic walk_page_range() logic.  Remove the old/equivalent
functionality.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 mm/mempolicy.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index c894671..d43d05e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -100,7 +100,6 @@
 /* Internal flags */
 #define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
 #define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
-#define MPOL_MF_STATS (MPOL_MF_INTERNAL << 2)		/* Gather statistics */
 
 static struct kmem_cache *policy_cache;
 static struct kmem_cache *sn_cache;
@@ -493,9 +492,7 @@ static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
 			continue;
 
-		if (flags & MPOL_MF_STATS)
-			gather_stats(page, private, pte_dirty(*pte));
-		else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
 			migrate_page_add(page, private, flags);
 		else
 			break;
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
