From: Andi Kleen <andi@firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
In-Reply-To: <200803071007.493903088@firstfloor.org>
Subject: [PATCH] [5/13] Add mask allocator statistics to vmstat.[ch]
Message-Id: <20080307090715.9872F1B419C@basil.firstfloor.org>
Date: Fri,  7 Mar 2008 10:07:15 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

They are a bit on the extensive side now, but I figured out more data
is better for now.

The actual counts are added in the new files.

Signed-off-by: Andi Kleen <ak@suse.de>

---
 include/linux/vmstat.h |    4 ++++
 mm/vmstat.c            |   10 ++++++++++
 2 files changed, 14 insertions(+)

Index: linux/include/linux/vmstat.h
===================================================================
--- linux.orig/include/linux/vmstat.h
+++ linux/include/linux/vmstat.h
@@ -37,6 +37,10 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		FOR_ALL_ZONES(PGSCAN_DIRECT),
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+#ifdef CONFIG_MASK_ALLOC
+		MASK_ALLOC, MASK_FREE, MASK_BITMAP_SKIP, MASK_WAIT,
+		MASK_HIGHER, MASK_LOW_WASTE, MASK_HIGH_WASTE,
+#endif
 		NR_VM_EVENT_ITEMS
 };
 
Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -644,6 +644,16 @@ static const char * const vmstat_text[] 
 	"allocstall",
 
 	"pgrotated",
+
+#ifdef CONFIG_MASK_ALLOC
+	"mask_alloc",
+	"mask_free",
+	"mask_bitmap_skip",
+	"mask_wait",
+	"mask_higher",
+	"mask_low_waste",
+	"mask_high_waste",
+#endif
 #endif
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
