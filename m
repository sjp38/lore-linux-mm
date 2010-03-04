Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D20516B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 22:10:38 -0500 (EST)
Received: by yxe34 with SMTP id 34so1444218yxe.11
        for <linux-mm@kvack.org>; Wed, 03 Mar 2010 19:10:37 -0800 (PST)
Date: Thu, 4 Mar 2010 19:09:16 +0800
From: wzt.wzt@gmail.com
Subject: [PATCH] mm: Fix some coding styles on mm/ tree
Message-ID: <20100304110916.GA3197@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Fix some coding styles on mm/ tree.

Signed-off-by: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>

---
 mm/filemap.c     |   10 ++++------
 mm/filemap_xip.c |    3 +--
 mm/slab.c        |    8 ++++----
 mm/vmscan.c      |    4 ++--
 4 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 698ea80..4c48e87 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2001,9 +2001,8 @@ inline int generic_write_checks(struct file *file, loff_t *pos, size_t *count, i
 				send_sig(SIGXFSZ, current, 0);
 				return -EFBIG;
 			}
-			if (*count > limit - (typeof(limit))*pos) {
+			if (*count > limit - (typeof(limit))*pos)
 				*count = limit - (typeof(limit))*pos;
-			}
 		}
 	}
 
@@ -2012,12 +2011,11 @@ inline int generic_write_checks(struct file *file, loff_t *pos, size_t *count, i
 	 */
 	if (unlikely(*pos + *count > MAX_NON_LFS &&
 				!(file->f_flags & O_LARGEFILE))) {
-		if (*pos >= MAX_NON_LFS) {
+		if (*pos >= MAX_NON_LFS)
 			return -EFBIG;
-		}
-		if (*count > MAX_NON_LFS - (unsigned long)*pos) {
+
+		if (*count > MAX_NON_LFS - (unsigned long)*pos)
 			*count = MAX_NON_LFS - (unsigned long)*pos;
-		}
 	}
 
 	/*
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index 1888b2d..56acab8 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -84,9 +84,8 @@ do_xip_mapping_read(struct address_space *mapping,
 			if (index > end_index)
 				goto out;
 			nr = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
-			if (nr <= offset) {
+			if (nr <= offset)
 				goto out;
-			}
 		}
 		nr = nr - offset;
 		if (nr > len - copied)
diff --git a/mm/slab.c b/mm/slab.c
index 7451bda..18418e1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2216,13 +2216,13 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 	}
 
 	/* 2) arch mandated alignment */
-	if (ralign < ARCH_SLAB_MINALIGN) {
+	if (ralign < ARCH_SLAB_MINALIGN)
 		ralign = ARCH_SLAB_MINALIGN;
-	}
+
 	/* 3) caller mandated alignment */
-	if (ralign < align) {
+	if (ralign < align)
 		ralign = align;
-	}
+
 	/* disable debug if necessary */
 	if (ralign > __alignof__(unsigned long long))
 		flags &= ~(SLAB_RED_ZONE | SLAB_STORE_USER);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c26986c..fbe2793 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1327,9 +1327,9 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	 * zone->pages_scanned is used for detect zone's oom
 	 * mem_cgroup remembers nr_scan by itself.
 	 */
-	if (scanning_global_lru(sc)) {
+	if (scanning_global_lru(sc))
 		zone->pages_scanned += pgscanned;
-	}
+
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
-- 
1.6.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
