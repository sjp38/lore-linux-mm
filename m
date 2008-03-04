From: Christoph Lameter <clameter@sgi.com>
Subject: [rfc 01/10] Pageflags: Use an enum for the flags
Date: Mon, 03 Mar 2008 16:04:53 -0800
Message-ID: <20080304000732.265422736@sgi.com>
References: <20080304000452.514878384@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756234AbYCDAI0@vger.kernel.org>
Content-Disposition: inline; filename=pageflags-use-enum
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Use an enum to ease the maintenance of page flags. This is going to change the
numbering from 0 to 18.

RFC->V1
- Add missing aliases (noticed by Mel)

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/page-flags.h |   56 ++++++++++++++++++++-------------------------
 1 file changed, 26 insertions(+), 30 deletions(-)

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2008-03-03 15:51:51.140239966 -0800
+++ linux-2.6/include/linux/page-flags.h	2008-03-03 15:52:13.552485107 -0800
@@ -67,35 +67,29 @@
  * FLAGS_RESERVED which defines the width of the fields section
  * (see linux/mmzone.h).  New flags must _not_ overlap with this area.
  */
-#define PG_locked	 	 0	/* Page is locked. Don't touch. */
-#define PG_error		 1
-#define PG_referenced		 2
-#define PG_uptodate		 3
-
-#define PG_dirty	 	 4
-#define PG_lru			 5
-#define PG_active		 6
-#define PG_slab			 7	/* slab debug (Suparna wants this) */
-
-#define PG_owner_priv_1		 8	/* Owner use. If pagecache, fs may use*/
-#define PG_arch_1		 9
-#define PG_reserved		10
-#define PG_private		11	/* If pagecache, has fs-private data */
-
-#define PG_writeback		12	/* Page is under writeback */
-#define PG_compound		14	/* Part of a compound page */
-#define PG_swapcache		15	/* Swap page: swp_entry_t in private */
-
-#define PG_mappedtodisk		16	/* Has blocks allocated on-disk */
-#define PG_reclaim		17	/* To be reclaimed asap */
-#define PG_buddy		19	/* Page is free, on buddy lists */
-
-/* PG_readahead is only used for file reads; PG_reclaim is only for writes */
-#define PG_readahead		PG_reclaim /* Reminder to do async read-ahead */
-
-/* PG_owner_priv_1 users should have descriptive aliases */
-#define PG_checked		PG_owner_priv_1 /* Used by some filesystems */
-#define PG_pinned		PG_owner_priv_1	/* Xen pinned pagetable */
+enum pageflags {
+	PG_locked,		/* Page is locked. Don't touch. */
+	PG_error,
+	PG_referenced,
+	PG_uptodate,
+	PG_dirty,
+	PG_lru,
+	PG_active,
+	PG_slab,
+	PG_owner_priv_1,	/* Owner use. If pagecache, fs may use*/
+	PG_checked = PG_owner_priv_1, /* Used by some filesystems */
+	PG_pinned = PG_owner_priv_1, /* Xen pinned pagetable */
+	PG_arch_1,
+	PG_reserved,
+	PG_private,		/* If pagecache, has fs-private data */
+	PG_writeback,		/* Page is under writeback */
+	PG_compound,		/* A compound page */
+	PG_swapcache,		/* Swap page: swp_entry_t in private */
+	PG_mappedtodisk,	/* Has blocks allocated on-disk */
+	PG_reclaim,		/* To be reclaimed asap */
+	/* PG_readahead is only used for file reads; PG_reclaim is only for writes */
+	PG_readahead = PG_reclaim, /* Reminder to do async read-ahead */
+	PG_buddy,		/* Page is free, on buddy lists */
 
 #if (BITS_PER_LONG > 32)
 /*
@@ -105,8 +99,10 @@
  * 64 bit  |           FIELDS             | ??????         FLAGS         |
  *         63                            32                              0
  */
-#define PG_uncached		31	/* Page has been mapped as uncached */
+	PG_uncached = 31,		/* Page has been mapped as uncached */
 #endif
+	NR_PAGEFLAGS
+};
 
 /*
  * Manipulation of page state flags

-- 
