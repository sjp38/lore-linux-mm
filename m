From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC 10/22] m68k: Use generic show_mem()
Date: Wed,  2 Apr 2008 22:40:16 +0200
Message-ID: <1207168941186-git-send-email-hannes@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763481AbYDBVqT@vger.kernel.org>
In-Reply-To: <12071688283927-git-send-email-hannes@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org


Signed-off-by: Johannes Weiner <hannes@saeurebad.de>

diff --git a/arch/m68k/Kconfig b/arch/m68k/Kconfig
index 53b36a8..65db226 100644
--- a/arch/m68k/Kconfig
+++ b/arch/m68k/Kconfig
@@ -396,9 +396,6 @@ config NODES_SHIFT
 	default "3"
 	depends on !SINGLE_MEMORY_CHUNK
 
-config HAVE_ARCH_SHOW_MEM
-	def_bool y
-
 source "mm/Kconfig"
 
 endmenu
diff --git a/arch/m68k/mm/init.c b/arch/m68k/mm/init.c
index f42caa7..19eb3ae 100644
--- a/arch/m68k/mm/init.c
+++ b/arch/m68k/mm/init.c
@@ -70,37 +70,6 @@ void __init m68k_setup_node(int node)
 
 void *empty_zero_page;
 
-void show_mem(void)
-{
-	pg_data_t *pgdat;
-	int free = 0, total = 0, reserved = 0, shared = 0;
-	int cached = 0;
-	int i;
-
-	printk("\nMem-info:\n");
-	show_free_areas();
-	printk("Free swap:       %6ldkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
-	for_each_online_pgdat(pgdat) {
-		for (i = 0; i < pgdat->node_spanned_pages; i++) {
-			struct page *page = pgdat->node_mem_map + i;
-			total++;
-			if (PageReserved(page))
-				reserved++;
-			else if (PageSwapCache(page))
-				cached++;
-			else if (!page_count(page))
-				free++;
-			else
-				shared += page_count(page) - 1;
-		}
-	}
-	printk("%d pages of RAM\n",total);
-	printk("%d free pages\n",free);
-	printk("%d reserved pages\n",reserved);
-	printk("%d pages shared\n",shared);
-	printk("%d pages swap cached\n",cached);
-}
-
 extern void init_pointer_table(unsigned long ptable);
 
 /* References to section boundaries */
-- 
1.5.2.2
