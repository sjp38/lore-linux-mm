From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC 20/22] v850: Use generic show_mem()
Date: Wed,  2 Apr 2008 22:40:26 +0200
Message-ID: <12071690544083-git-send-email-hannes@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764737AbYDBVvF@vger.kernel.org>
In-Reply-To: <12071688283927-git-send-email-hannes@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org


Signed-off-by: Johannes Weiner <hannes@saeurebad.de>

diff --git a/arch/v850/Kconfig b/arch/v850/Kconfig
index a4d8e72..4379f43 100644
--- a/arch/v850/Kconfig
+++ b/arch/v850/Kconfig
@@ -56,9 +56,6 @@ config ARCH_HAS_ILOG2_U64
 config ARCH_SUPPORTS_AOUT
 	def_bool y
 
-config HAVE_ARCH_SHOW_MEM
-	def_bool y
-
 # Turn off some random 386 crap that can affect device config
 config ISA
 	bool
diff --git a/arch/v850/kernel/setup.c b/arch/v850/kernel/setup.c
index a0a8456..5751709 100644
--- a/arch/v850/kernel/setup.c
+++ b/arch/v850/kernel/setup.c
@@ -298,33 +298,3 @@ init_mem_alloc (unsigned long ram_start, unsigned long ram_len)
 	free_area_init_node (0, NODE_DATA(0), zones_size,
 			     ADDR_TO_PAGE (PAGE_OFFSET), 0);
 }
-
-
-
-/* Taken from m68knommu */
-void show_mem(void)
-{
-    unsigned long i;
-    int free = 0, total = 0, reserved = 0, shared = 0;
-    int cached = 0;
-
-    printk(KERN_INFO "\nMem-info:\n");
-    show_free_areas();
-    i = max_mapnr;
-    while (i-- > 0) {
-	total++;
-	if (PageReserved(mem_map+i))
-	    reserved++;
-	else if (PageSwapCache(mem_map+i))
-	    cached++;
-	else if (!page_count(mem_map+i))
-	    free++;
-	else
-	    shared += page_count(mem_map+i) - 1;
-    }
-    printk(KERN_INFO "%d pages of RAM\n",total);
-    printk(KERN_INFO "%d free pages\n",free);
-    printk(KERN_INFO "%d reserved pages\n",reserved);
-    printk(KERN_INFO "%d pages shared\n",shared);
-    printk(KERN_INFO "%d pages swap cached\n",cached);
-}
-- 
1.5.2.2
