Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iAHLIlDi006181
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 16:18:47 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAHLIhOd283268
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 16:18:47 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iAHLIhsK026539
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 16:18:43 -0500
Subject: [patch 2/2] kill off highmem_start_page (in -mm)
From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 17 Nov 2004 13:18:40 -0800
Message-Id: <E1CUXCL-0006YD-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: george@mvista.com, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch should fix kgdb to work without highmem_start_page. 
However, I don't have a kgdb setup, and I'd appreciate someone
testing this to make sure my selection of a new variable is OK.

Also, should this function possibly be using system_state, instead?

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/arch/i386/lib/kgdb_serial.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/i386/lib/kgdb_serial.c~A1-no-highmem_start_page-kgdb arch/i386/lib/kgdb_serial.c
--- memhotplug/arch/i386/lib/kgdb_serial.c~A1-no-highmem_start_page-kgdb	2004-11-17 13:10:33.000000000 -0800
+++ memhotplug-dave/arch/i386/lib/kgdb_serial.c	2004-11-17 13:10:33.000000000 -0800
@@ -407,7 +407,7 @@ void shutdown_for_kgdb(struct async_stru
 #ifdef CONFIG_DISCONTIGMEM
 static inline int kgdb_mem_init_done(void)
 {
-	return highmem_start_page != NULL;
+	return totalram_pages != 0;
 }
 #else
 static inline int kgdb_mem_init_done(void)
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
