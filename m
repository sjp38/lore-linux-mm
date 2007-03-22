From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 22 Mar 2007 17:01:27 +1100
Subject: [RFC/PATCH 11/15] get_unmapped_area handles MAP_FIXED on ramfs (nommu) 
In-Reply-To: <1174543217.531981.572863804039.qpush@grosgo>
Message-Id: <20070322060301.DD1A6DE411@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org
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
