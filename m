Received: from fujitsu2.fujitsu.com (localhost [127.0.0.1])
	by fujitsu2.fujitsu.com (8.12.10/8.12.9) with ESMTP id i9Q2aBNo006852
	for <linux-mm@kvack.org>; Mon, 25 Oct 2004 19:36:11 -0700 (PDT)
Date: Mon, 25 Oct 2004 19:35:54 -0700
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: [RFC/Patch]Making Removable zone[2/4]
In-Reply-To: <20041025160642.690F.YGOTO@us.fujitsu.com>
References: <20041025160642.690F.YGOTO@us.fujitsu.com>
Message-Id: <20041025193454.6913.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

User processes and page cache can use removable area by this patch.


 hotremovable-goto/include/linux/gfp.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff -puN include/linux/gfp.h~gfp_removable include/linux/gfp.h
--- hotremovable/include/linux/gfp.h~gfp_removable	Fri Aug 27 21:06:57 2004
+++ hotremovable-goto/include/linux/gfp.h	Fri Aug 27 21:06:57 2004
@@ -11,9 +11,10 @@ struct vm_area_struct;
 /*
  * GFP bitmasks..
  */
-/* Zone modifiers in GFP_ZONEMASK (see linux/mmzone.h - low two bits) */
+/* Zone modifiers in GFP_ZONEMASK (see linux/mmzone.h - low three bits) */
 #define __GFP_DMA	0x01
 #define __GFP_HIGHMEM	0x02
+#define __GFP_REMOVABLE	0x04
 
 /*
  * Action modifiers - doesn't change the zoning
@@ -51,7 +52,7 @@ struct vm_area_struct;
 #define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
 #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
 #define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS)
-#define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HIGHMEM)
+#define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HIGHMEM | __GFP_REMOVABLE)
 
 /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
    platforms, used as appropriate on others */
_

-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
