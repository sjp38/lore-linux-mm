From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC 07/22] frv: Use generic show_mem()
Date: Wed,  2 Apr 2008 22:40:13 +0200
Message-ID: <12071689072627-git-send-email-hannes@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763086AbYDBVoj@vger.kernel.org>
In-Reply-To: <12071688283927-git-send-email-hannes@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org


Signed-off-by: Johannes Weiner <hannes@saeurebad.de>

diff --git a/arch/frv/Kconfig b/arch/frv/Kconfig
index c1a5aac..a5aac1b 100644
--- a/arch/frv/Kconfig
+++ b/arch/frv/Kconfig
@@ -107,9 +107,6 @@ config HIGHPTE
 	  with a lot of RAM, this can be wasteful of precious low memory.
 	  Setting this option will put user-space page tables in high memory.
 
-config HAVE_ARCH_SHOW_MEM
-	def_bool y
-
 source "mm/Kconfig"
 
 choice
diff --git a/arch/frv/mm/init.c b/arch/frv/mm/init.c
index b841ecf..f7a16d3 100644
--- a/arch/frv/mm/init.c
+++ b/arch/frv/mm/init.c
@@ -60,37 +60,6 @@ unsigned long empty_zero_page;
 
 /*****************************************************************************/
 /*
- *
- */
-void show_mem(void)
-{
-	unsigned long i;
-	int free = 0, total = 0, reserved = 0, shared = 0;
-
-	printk("\nMem-info:\n");
-	show_free_areas();
-	i = max_mapnr;
-	while (i-- > 0) {
-		struct page *page = &mem_map[i];
-
-		total++;
-		if (PageReserved(page))
-			reserved++;
-		else if (!page_count(page))
-			free++;
-		else
-			shared += page_count(page) - 1;
-	}
-
-	printk("%d pages of RAM\n",total);
-	printk("%d free pages\n",free);
-	printk("%d reserved pages\n",reserved);
-	printk("%d pages shared\n",shared);
-
-} /* end show_mem() */
-
-/*****************************************************************************/
-/*
  * paging_init() continues the virtual memory environment setup which
  * was begun by the code in arch/head.S.
  * The parameters are pointers to where to stick the starting and ending
-- 
1.5.2.2
