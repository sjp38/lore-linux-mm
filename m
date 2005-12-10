Date: Sat, 10 Dec 2005 20:05:16 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [patch] Fix Kconfig of DMA32 for ia64
Message-Id: <20051210194521.4832.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>
Cc: "Luck, Tony" <tony.luck@intel.com>
List-ID: <linux-mm.kvack.org>

Andew-san.

I realized ZONE_DMA32 on -mm has a trivial bug at Kconfig for ia64.
In include/linux/gfp.h on 2.6.15-rc5-mm1, CONFIG is define like
followings.

#ifdef CONFIG_DMA_IS_DMA32
#define __GFP_DMA32	((__force gfp_t)0x01)	/* ZONE_DMA is ZONE_DMA32
*/
       :
       :

So, CONFIG_"ZONE"_DMA_IS_DMA32 is clearly wrong.
This is patch for it.

Thanks.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: zone_reclaim/arch/ia64/Kconfig
===================================================================
--- zone_reclaim.orig/arch/ia64/Kconfig	2005-12-06 13:48:35.000000000 +0900
+++ zone_reclaim/arch/ia64/Kconfig	2005-12-06 14:52:39.000000000 +0900
@@ -58,7 +58,7 @@ config IA64_UNCACHED_ALLOCATOR
 	bool
 	select GENERIC_ALLOCATOR
 
-config ZONE_DMA_IS_DMA32
+config DMA_IS_DMA32
 	bool
 	default y
 

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
