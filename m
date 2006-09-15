Date: Fri, 15 Sep 2006 10:38:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Disable GFP_THISNODE in the non-NUMA case
In-Reply-To: <20060914220011.2be9100a.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609151037520.8198@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

GFP_THISNODE must be set to 0 in the non numa case otherwise we disable
retry and warnings for failing allocations in the SMP and UP case.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm2/include/linux/gfp.h
===================================================================
--- linux-2.6.18-rc6-mm2.orig/include/linux/gfp.h	2006-09-15 12:17:39.000000000 -0500
+++ linux-2.6.18-rc6-mm2/include/linux/gfp.h	2006-09-15 12:29:06.607417253 -0500
@@ -67,7 +67,12 @@ struct vm_area_struct;
 #define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
 			 __GFP_HIGHMEM)
 
+#ifdef CONFIG_NUMA
 #define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
+#else
+#define GFP_THISNODE	0
+#endif
+
 
 /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
    platforms, used as appropriate on others */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
