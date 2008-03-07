From: Andi Kleen <andi@firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
In-Reply-To: <200803071007.493903088@firstfloor.org>
Subject: [PATCH] [12/13] Add vmstat statistics for new swiotlb code
Message-Id: <20080307090722.B6BCE1B419C@basil.firstfloor.org>
Date: Fri,  7 Mar 2008 10:07:22 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Andi Kleen <ak@suse.de>

---
 include/linux/vmstat.h |    4 ++++
 mm/vmstat.c            |    6 ++++++
 2 files changed, 10 insertions(+)

Index: linux/include/linux/vmstat.h
===================================================================
--- linux.orig/include/linux/vmstat.h
+++ linux/include/linux/vmstat.h
@@ -41,6 +41,10 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		MASK_ALLOC, MASK_FREE, MASK_BITMAP_SKIP, MASK_WAIT,
 		MASK_HIGHER, MASK_LOW_WASTE, MASK_HIGH_WASTE,
 #endif
+#ifdef CONFIG_SWIOTLB_MASK_ALLOC
+		SWIOTLB_USED_PAGES, SWIOTLB_BYTES_WASTED, SWIOTLB_NUM_ALLOCS,
+		SWIOTLB_NUM_FREES,
+#endif
 		NR_VM_EVENT_ITEMS
 };
 
Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -654,6 +654,12 @@ static const char * const vmstat_text[] 
 	"mask_low_waste",
 	"mask_high_waste",
 #endif
+#ifdef CONFIG_SWIOTLB_MASK_ALLOC
+	"swiotlb_used_pages",
+	"swiotlb_bytes_wasted",
+	"swiotlb_num_allocs",
+	"swiotlb_num_frees",
+#endif
 #endif
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
