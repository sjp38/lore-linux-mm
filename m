From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/3] slub: record page flag overlays explicitly
References: <exportbomb.1210871946@pinky>
Date: Thu, 15 May 2008 18:19:59 +0100
Message-Id: <1210871999.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

SLUB reuses two page bits for internal purposes, it overlays PG_active
and PG_error.  This is hidden away in slub.c.  Document these overlays
explicitly in the main page-flags enum along with all the others.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 include/linux/page-flags.h |    4 ++++
 mm/slub.c                  |    4 ++--
 2 files changed, 6 insertions(+), 2 deletions(-)
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 2cc1fb1..2e88df6 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -103,6 +103,10 @@ enum pageflags {
 
 	/* XEN */
 	PG_pinned = PG_owner_priv_1,
+
+	/* SLUB */
+	PG_slub_frozen = PG_active,
+	PG_slub_debug = PG_error,
 };
 
 #ifndef __GENERATING_BOUNDS_H
diff --git a/mm/slub.c b/mm/slub.c
index a505a82..fd7c61a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -102,10 +102,10 @@
  * 			the fast path and disables lockless freelists.
  */
 
-#define FROZEN (1 << PG_active)
+#define FROZEN (1 << PG_slub_frozen)
 
 #ifdef CONFIG_SLUB_DEBUG
-#define SLABDEBUG (1 << PG_error)
+#define SLABDEBUG (1 << PG_slub_debug)
 #else
 #define SLABDEBUG 0
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
