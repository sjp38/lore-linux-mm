From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 04 Apr 2007 14:02:20 +1000
Subject: [PATCH 11/14] get_unmapped_area handles MAP_FIXED on ramfs (nommu) 
In-Reply-To: <1175659331.690672.592289266160.qpush@grosgo>
Message-Id: <20070404040231.A110CDDEB8@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

---

 fs/ramfs/file-nommu.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: linux-cell/fs/ramfs/file-nommu.c
===================================================================
--- linux-cell.orig/fs/ramfs/file-nommu.c	2007-03-22 16:18:27.000000000 +1100
+++ linux-cell/fs/ramfs/file-nommu.c	2007-03-22 16:20:14.000000000 +1100
@@ -238,7 +238,10 @@ unsigned long ramfs_nommu_get_unmapped_a
 	struct page **pages = NULL, **ptr, *page;
 	loff_t isize;
 
-	if (!(flags & MAP_SHARED))
+	/* Deal with MAP_FIXED differently ? Forbid it ? Need help from some nommu
+	 * folks there... --BenH.
+	 */
+	if ((flags & MAP_FIXED) || !(flags & MAP_SHARED))
 		return addr;
 
 	/* the mapping mustn't extend beyond the EOF */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
